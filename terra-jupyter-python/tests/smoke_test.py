"""Brief smoke tests for terra-jupyter-python.

Minimal tests simply import packages and run 'hello world' code to determine whether any exceptions
are thrown.

TODO(all): Add additional tests and/or tests with particular assertions, as we encounter Python package version
incompatibilities not currently detected by these tests.
"""

import os
import subprocess
import sys
import tomllib
from importlib import metadata

import pytest
import pandas as pd
import numpy as np
import pandas_gbq
import pysam
import tensorflow as tf
from google.oauth2 import service_account
from packaging.requirements import Requirement

JUPYTER_HOME = "/etc/jupyter"
CONDA_ENV_HOME = os.environ.get("CONDA_ENV_HOME", "/opt/conda/envs/python3")
# Installed by the Dockerfile; terra-jupyter-gatk copies it and reinstalls the same packages
PYPROJECT = "/etc/terra-docker/pyproject.toml"

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

def test_tests_run_in_conda_env():
  # The workflow runs pytest with the conda env's python; the checks below rely on it
  assert os.path.realpath(sys.prefix) == os.path.realpath(CONDA_ENV_HOME)

def test_pyproject_dependencies_installed():
  with open(PYPROJECT, "rb") as f:
    dependencies = tomllib.load(f)["project"]["dependencies"]
  problems = []
  for dependency in dependencies:
    requirement = Requirement(dependency)
    if requirement.marker and not requirement.marker.evaluate():
      continue
    try:
      version = metadata.version(requirement.name)
    except metadata.PackageNotFoundError:
      problems.append(f"{requirement.name} is not installed")
      continue
    if version not in requirement.specifier:
      problems.append(f"{requirement.name} {version} does not satisfy {requirement}")
  assert not problems, "\n".join(problems)

# Imports the usual Terra notebook starts with
NOTEBOOK_IMPORTS = """\
from firecloud import api as fapi
import os
import io
import pandas as pd
import numpy as np
import matplotlib.pyplot as plt
import seaborn as sns
import warnings
"""

def test_notebook_imports():
  exec(NOTEBOOK_IMPORTS, {})

@requires_native_cpu
def test_python3_kernel_notebook_imports():
  run_in_kernel("python3", NOTEBOOK_IMPORTS + "\n".join([
    "df = pd.DataFrame({'x': np.arange(10), 'y': np.arange(10) ** 2})",
    "sns.lineplot(data=df, x='x', y='y')",
    "plt.close('all')",
    "assert callable(fapi.list_workspaces)",
    "print('ok')",
  ]))

@requires_native_cpu
def test_python3_kernel_imports_image_packages():
  output = run_in_kernel("python3", "\n".join([
    "import sys",
    "import Bio, bokeh, matplotlib_venn, numpy, pandas, pandas_gbq, plotnine, pymc, pysam, scipy, sklearn, tensorflow",
    "print(sys.executable)",
  ]))
  assert output.split()[-1] == f"{CONDA_ENV_HOME}/bin/python"

def test_pandas():
  
  pd.DataFrame(
    {
      "A": 1.0,
      "B": pd.Timestamp("20130102"),
      "C": pd.Series(1, index=list(range(4)), dtype="float32"),
      "D": np.array([3] * 4, dtype="int32"),
      "E": pd.Categorical(["test", "train", "test", "train"]),
      "F": "foo",
    }
  )
  
# def test_pandas_gbq():

#   sql = """
#   SELECT country_name, alpha_2_code
#   FROM `bigquery-public-data.utility_us.country_code_iso`
#   WHERE alpha_2_code LIKE 'A%'
#   """
#   # Credentials
#   credentials = service_account.Credentials.from_service_account_file('/tmp/credentials.json')
#   print(os.environ['GOOGLE_PROJECT'])
#   pandas_gbq.read_gbq(sql, project_id=os.environ['GOOGLE_PROJECT'], credentials=credentials)
  
def test_tensorflow_gfile():

  tf.io.gfile.copy(src='gs://gcp-public-data--broad-references/refdisk_manifest.json',
                   dst='/tmp/refdisk_manifest.json',
                   overwrite=True)

def test_tensorflow_hello_world():
  print("TensorFlow version : ", tf.version.GIT_VERSION, tf.version.VERSION)
  hello = tf.constant('Hello, TensorFlow!')
  tf.print(hello)

def test_pysam():

  # Create BAM file from scratch
  # Code stolen from https://pysam.readthedocs.io/en/latest/usage.html#creating-bam-cram-sam-files-from-scratch
  header = { 'HD': {'VN': '1.0'},
            'SQ': [{'LN': 1575, 'SN': 'chr1'},
                   {'LN': 1584, 'SN': 'chr2'}] }

  file_name = "out.bam"
  with pysam.AlignmentFile(file_name, "wb", header=header) as outf:
    a = pysam.AlignedSegment()
    a.query_name = "read_28833_29006_6945"
    a.query_sequence="AGCTTAGCTAGCTACCTATATCTTGGTCTTGGCCG"
    a.flag = 99
    a.reference_id = 0
    a.reference_start = 32
    a.mapping_quality = 20
    a.cigar = ((0,10), (2,1), (0,25))
    a.next_reference_id = 0
    a.next_reference_start=199
    a.template_length=167
    a.query_qualities = pysam.qualitystring_to_array("<<<<<<<<<<<<<<<<<<<<<:<9/,&,22;;<<<")
    a.tags = (("NM", 1),
              ("RG", "L1"))
    outf.write(a)

  # Verify output file exists
  assert os.path.isfile(file_name)

  # Call samtools to sort the file
  # This will fail if the file is not a valid BAM file
  pysam.sort("-o", "sorted.bam", file_name)
  assert os.path.isfile("sorted.bam")
