"""Brief smoke tests for terra-jupyter-base.

Minimal tests simply import packages and run 'hello world' code to determine whether any exceptions
are thrown.

TODO(all): Add additional tests and/or tests with particular assertions, as we encounter Python package version
incompatibilities not currently detected by these tests.
"""

import os
import re
import signal
import subprocess
import time
import urllib.request

import pytest

JUPYTER_HOME = "/etc/jupyter"
JUPYTER = f"{JUPYTER_HOME}/bin/jupyter"
EXTENSION_SCRIPTS = f"{JUPYTER_HOME}/scripts/extension"

def test_firecloud():
  import firecloud

def test_terra_notebook_utils():
  os.system("gcloud auth application-default login")
  import terra_notebook_utils

# Re-add this test if one day base image no longer declares `/home/jupyter` as a VOLUME
# toc2 is also not supporting our version of notebook anymore
# def test_extensions():
#   output = subprocess.check_output("jupyter nbextension list", shell=True)
#   if not "toc2/main" in str(output):
#     pytest.fail("toc not enabled") 
    
#   if not "codefolding/main" in str(output):
#     pytest.fail("codefolding not enabled")  

#   if not "collapsible_headings/main" in str(output):
#     pytest.fail("collapsible_headings not enabled")


#######################
# Leonardo startup compatibility
#######################
# Leonardo's startup script runs, for every Jupyter runtime:
#   docker exec -u root -e PIP_USER=false jupyter-server \
#     /etc/jupyter/scripts/extension/jupyter_install_notebook_extension.sh /etc/jupyter/jupyter-iframe-extension.js
# and retries it up to 3 times. A non-zero exit aborts the startup script before run-jupyter.sh,
# so Jupyter never starts and the runtime times out. Notebook 7 has no `jupyter nbextension`.

def _as_root(cmd):
  """Run like `docker exec -u root -e PIP_USER=false` (the image's jupyter user has passwordless sudo)."""
  prefix = [] if os.geteuid() == 0 else ["sudo", "-E"]
  return subprocess.run(prefix + ["env", "PIP_USER=false"] + cmd, capture_output=True, text=True)

def test_leonardo_iframe_extension_call_exits_0(tmp_path):
  extension = tmp_path / "jupyter-iframe-extension.js"
  extension.write_text("// placeholder for Leonardo's jupyter-iframe-extension.js\n")
  # Twice: Leonardo retries, and the old script was not safe to re-run (it mv'ed the file away)
  for attempt in (1, 2):
    result = _as_root([f"{EXTENSION_SCRIPTS}/jupyter_install_notebook_extension.sh", str(extension)])
    assert result.returncode == 0, f"attempt {attempt} exited {result.returncode}:\n{result.stdout}\n{result.stderr}"

def test_leonardo_jupyter_setup_commands_succeed():
  # The image-dependent commands Leonardo's gce-init.sh runs after the extension step and before
  # run-jupyter.sh (network steps such as the gitignore download and `pip install nbstripout` are left
  # out). Any failure here aborts the startup script and the runtime times out.
  # (command, run as root?) -- root ones are `docker exec -u 0` in gce-init.sh
  commands = [
    ("sed -i 's/127.0.0.1/welder/g' /etc/jupyter/custom/jupyter_delocalize.py", False),
    ("/etc/jupyter/scripts/extension/install_jupyter_contrib_nbextensions.sh"
     " && mkdir -p /home/jupyter/.jupyter/custom/"
     " && chown -R jupyter:users /home/jupyter/.jupyter"
     " && cp /etc/jupyter/custom/google_sign_in.js /home/jupyter/.jupyter/custom/"
     " && ls -la /etc/jupyter/custom/extension_entry_jupyter.js"
     " && cp /etc/jupyter/custom/extension_entry_jupyter.js /home/jupyter/.jupyter/custom/custom.js"
     " && cp /etc/jupyter/custom/safe-mode.js /home/jupyter/.jupyter/custom/"
     " && cp /etc/jupyter/custom/edit-mode.js /home/jupyter/.jupyter/custom/"
     " && mkdir -p /etc/jupyter/nbconfig", True),
    # needs /etc/jupyter/jupyter_notebook_config.py to exist (see the placeholder file in the image)
    ("sed -i '/^# to mount there as it effectively deletes existing files on the image/,+5d'"
     " /etc/jupyter/jupyter_notebook_config.py", False),
  ]
  for command, root in commands:
    result = _as_root(["bash", "-c", command]) if root else \
      subprocess.run(["bash", "-c", command], capture_output=True, text=True)
    assert result.returncode == 0, f"`{command}` exited {result.returncode}:\n{result.stdout}\n{result.stderr}"

def test_kernels_do_not_depend_on_home_dir():
  # Leonardo mounts the runtime's persistent disk over the notebooks dir (/home/jupyter), hiding whatever
  # the image put there. A kernel whose interpreter lives under it dies on Terra with
  # "/home/jupyter/.envs/python3/bin/python: No such file or directory".
  import glob, json
  home = "/home/jupyter"
  kernel_files = glob.glob("/usr/local/share/jupyter/kernels/*/kernel.json") + \
                 glob.glob(f"{JUPYTER_HOME}/share/jupyter/kernels/*/kernel.json")
  assert kernel_files, "no kernelspecs found"
  for kernel_file in kernel_files:
    argv = json.load(open(kernel_file))["argv"]
    for arg in argv:
      if arg.startswith("/"):
        assert not arg.startswith(home + "/"), f"{kernel_file} uses {arg}, which is hidden by Leonardo's {home} mount"
        assert os.path.exists(arg), f"{kernel_file} uses {arg}, which does not exist"

#######################
# Kernels and the user's conda env
#######################
CONDA_ENV_HOME = os.environ.get("CONDA_ENV_HOME", "/opt/conda/envs/python3")
KERNELSPEC_DIR = "/usr/local/share/jupyter/kernels"

# Starts a kernel through jupyter_client in the jupyter server's venv, so the kernelspec is resolved
# and launched exactly as the server does it, then runs code in it and prints the output.
_KERNEL_RUNNER = """
import sys
from jupyter_client.manager import start_new_kernel
kernel_name, code = sys.argv[1], sys.argv[2]
km, kc = start_new_kernel(kernel_name=kernel_name, startup_timeout=120)
out = []
def hook(msg):
  content = msg["content"]
  if msg["msg_type"] == "stream":
    out.append(content["text"])
  elif msg["msg_type"] in ("execute_result", "display_data"):
    out.append(content["data"].get("text/plain", "") + "\\n")
  elif msg["msg_type"] == "error":
    out.append("\\n".join(content["traceback"]))
try:
  reply = kc.execute_interactive(code, timeout=600, output_hook=hook)
finally:
  kc.stop_channels()
  km.shutdown_kernel(now=True)
sys.stdout.write("".join(out))
sys.exit(0 if reply["content"]["status"] == "ok" else 1)
"""

def _emulated_cpu():
  """The CPU vendor when this amd64 container runs under emulation (e.g. Docker Desktop on Apple Silicon), else None."""
  try:
    with open("/proc/cpuinfo") as f:
      for line in f:
        if line.startswith(("vendor_id", "model name")):
          for vendor in ("VirtualApple", "QEMU"):
            if vendor in line:
              return vendor
  except OSError:
    pass
  return None

# Under amd64 emulation (Rosetta "VirtualApple" / QEMU) every ipykernel starts but never answers
# kernel_info -- it also happens with a plain python:3.14 image -- so the kernel tests can't tell anything
# about the image there. They run normally on real amd64 (CI, Terra VMs).
requires_native_cpu = pytest.mark.skipif(
  _emulated_cpu() is not None,
  reason=f"jupyter kernels do not respond under {_emulated_cpu()} amd64 emulation; run on native amd64")

def run_in_kernel(kernel_name, code):
  result = subprocess.run([f"{JUPYTER_HOME}/bin/python", "-c", _KERNEL_RUNNER, kernel_name, code],
                          capture_output=True, text=True, timeout=900)
  assert result.returncode == 0, f"{kernel_name} kernel failed:\n{result.stdout}\n{result.stderr}"
  return result.stdout

def kernelspecs():
  import json
  output = subprocess.check_output([JUPYTER, "kernelspec", "list", "--json"], text=True)
  return json.loads(output)["kernelspecs"]

def test_python3_kernel_is_registered():
  specs = kernelspecs()
  assert "python3" in specs, f"no python3 kernel: {sorted(specs)}"
  python3 = specs["python3"]
  assert python3["resource_dir"] == f"{KERNELSPEC_DIR}/python3"
  argv = python3["spec"]["argv"]
  assert argv[0] == f"{JUPYTER_HOME}/scripts/kernel/kernel_bootstrap.sh"
  assert argv[1] == f"{CONDA_ENV_HOME}/bin/python", f"python3 kernel does not use the conda env: {argv}"

@requires_native_cpu
def test_python3_kernel_runs_in_conda_env():
  output = run_in_kernel("python3", "import os, sys; print(sys.executable); print('WORKSPACE_NAME' in os.environ)")
  executable, bootstrapped = output.split()[-2:]
  assert executable == f"{CONDA_ENV_HOME}/bin/python"
  # kernel_bootstrap.sh exports WORKSPACE_NAME, so this shows the kernel was started through it
  assert bootstrapped == "True", "kernel was not started through kernel_bootstrap.sh"

def test_python_versions():
  # conda base, the jupyter server venv and the user's conda env all use PYTHON_VERSION (3.13);
  # only Ubuntu's /usr/bin/python3 differs. run-jupyter.sh starts the server with python<PYTHON_VERSION>.
  python_version = os.environ["PYTHON_VERSION"]
  assert python_version == "3.13"
  for python in ["/opt/conda/bin/python", f"{JUPYTER_HOME}/bin/python{python_version}", f"{CONDA_ENV_HOME}/bin/python"]:
    output = subprocess.check_output([python, "-c", "import sys; print('%d.%d' % sys.version_info[:2])"], text=True)
    assert output.strip() == python_version, f"{python} is Python {output.strip()}"
  assert f"{JUPYTER_HOME}/bin/python{python_version} " in open(f"{JUPYTER_HOME}/scripts/run-jupyter.sh").read()

def test_conda_env_is_registered_with_conda():
  import json
  output = subprocess.check_output(["/opt/conda/bin/conda", "env", "list", "--json"], text=True)
  assert CONDA_ENV_HOME in json.loads(output)["envs"]

def test_conda_env_pip():
  output = subprocess.check_output([f"{CONDA_ENV_HOME}/bin/python", "-m", "pip", "--version"], text=True)
  assert CONDA_ENV_HOME in output, f"pip does not belong to the conda env: {output}"

def test_pip_user_install_is_importable_from_conda_env(tmp_path):
  # Notebook users run `pip install` with the image's PIP_USER=true, which installs to ~/.local
  env = dict(os.environ, HOME=str(tmp_path), PIP_USER="true")
  env.pop("PIP_TARGET", None)
  install = subprocess.run([f"{CONDA_ENV_HOME}/bin/python", "-m", "pip", "install", "--no-deps", "emoji==2.14.1"],
                           env=env, capture_output=True, text=True)
  assert install.returncode == 0, f"pip install failed:\n{install.stdout}\n{install.stderr}"
  location = subprocess.check_output([f"{CONDA_ENV_HOME}/bin/python", "-c", "import emoji; print(emoji.__file__)"],
                                     env=env, text=True).strip()
  assert location.startswith(f"{tmp_path}/.local/"), f"emoji was not installed to the user site: {location}"

def test_extension_scripts_do_not_call_nbextension():
  # `jupyter nbextension` (and contrib/configurator, which wrap it) does not exist in Notebook 7
  pattern = re.compile(r"jupyter\s+(nbextension|contrib\s+nbextension|nbextensions_configurator)\b")
  offenders = []
  for name in sorted(os.listdir(EXTENSION_SCRIPTS)):
    with open(os.path.join(EXTENSION_SCRIPTS, name)) as f:
      for number, line in enumerate(f, 1):
        if not line.lstrip().startswith("#") and pattern.search(line):
          offenders.append(f"{name}:{number}: {line.strip()}")
  assert not offenders, "classic nbextension calls found:\n" + "\n".join(offenders)

#######################
# Jupyter server: Notebook 7 + nbclassic
#######################
# Start Jupyter the way Leonardo does (scripts/run-jupyter.sh, with jupyter_server_config.py) and
# check that both the Notebook 7 UI (/tree) and the classic UI (/nbclassic/tree) are served.
GOOGLE_PROJECT = "smoke-project"
CLUSTER_NAME = "smoke-cluster"
BASE_URL = f"http://127.0.0.1:8000/notebooks/{GOOGLE_PROJECT}/{CLUSTER_NAME}/"

def _get(path):
  with urllib.request.urlopen(BASE_URL + path, timeout=10) as response:
    return response.status, response.read().decode("utf-8", "replace")

@pytest.fixture(scope="module")
def jupyter_server(tmp_path_factory):
  notebooks_dir = tmp_path_factory.mktemp("notebooks")
  env = dict(os.environ, GOOGLE_PROJECT=GOOGLE_PROJECT, CLUSTER_NAME=CLUSTER_NAME, HOME=str(notebooks_dir))
  env.pop("WELDER_ENABLED", None)
  # run-jupyter.sh writes the server log to <notebooks dir>/jupyter.log
  process = subprocess.Popen([f"{JUPYTER_HOME}/scripts/run-jupyter.sh", str(notebooks_dir)],
                             env=env, start_new_session=True)
  log_file = notebooks_dir / "jupyter.log"
  deadline = time.time() + 120
  try:
    while True:
      if process.poll() is not None:
        pytest.fail(f"run-jupyter.sh exited {process.returncode}:\n{log_file.read_text() if log_file.exists() else ''}")
      try:
        if _get("api/status")[0] == 200:
          break
      except OSError:
        pass
      if time.time() > deadline:
        pytest.fail(f"Jupyter did not start within 120s:\n{log_file.read_text() if log_file.exists() else ''}")
      time.sleep(2)
    yield log_file
  finally:
    os.killpg(process.pid, signal.SIGTERM)
    process.wait(timeout=30)

def test_jupyter_server_versions():
  output = subprocess.check_output([f"{JUPYTER_HOME}/bin/python", "-c",
                                    "import notebook, nbclassic; print(notebook.__version__, nbclassic.__version__)"],
                                   text=True)
  notebook_version, nbclassic_version = output.split()
  assert notebook_version.startswith("7."), f"expected Notebook 7, got {notebook_version}"
  assert nbclassic_version, "nbclassic is not installed"

def test_jupyter_starts_notebook_7(jupyter_server):
  status, body = _get("tree")
  assert status == 200
  assert '"appName": "Jupyter Notebook"' in body, "/tree is not the Notebook 7 UI"

def test_jupyter_starts_nbclassic(jupyter_server):
  status, body = _get("nbclassic/tree")
  assert status == 200
  assert "nbclassic/base/" in body, "/nbclassic/tree is not the classic notebook UI"
  assert "nbclassic | extension was successfully loaded" in jupyter_server.read_text()
