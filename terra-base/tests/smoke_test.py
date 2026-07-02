"""Smoke tests for the terra-base image.

Verifies that both the user-facing conda kernel env and the Jupyter server venv run the
image's target Python (the PYTHON_VERSION set in the Dockerfile), and that the Jupyter
stack and the Terra (Leonardo) notebook extensions import on that Python.

Has no third-party dependencies, so CI can run it without installing anything:

    docker run --rm --entrypoint="" terra-base:smoke-test \
        /etc/jupyter/bin/python /tests/smoke_test.py

Run it with the Jupyter *server* venv python (it shells out to check the kernel env too).
The functions are also pytest-discoverable if pytest is available in that interpreter.
"""
import os
import subprocess
import sys

# The Jupyter server runs in this venv; user notebook code runs in the conda kernel env.
SERVER_PY = "/etc/jupyter/bin/python"
KERNEL_PY = "/home/jupyter/.envs/python3/bin/python"
# Where the Dockerfile copies the Leonardo extensions (loaded via run-jupyter.sh).
CUSTOM_DIR = "/etc/jupyter/custom"


def _target_version():
    """The image's target Python as 'major.minor' (from ENV PYTHON_VERSION), or None."""
    return os.environ.get("PYTHON_VERSION", "").strip() or None


def _minor(python_path):
    out = subprocess.check_output(
        [python_path, "-c", "import sys; print('%d.%d' % sys.version_info[:2])"]
    )
    return out.decode().strip()


def test_kernel_env_matches_target():
    target = _target_version()
    got = _minor(KERNEL_PY)
    if target:
        assert got == target, f"conda kernel env is Python {got}, expected {target}"


def test_server_venv_matches_target():
    target = _target_version()
    got = _minor(SERVER_PY)
    if target:
        assert got == target, f"jupyter server venv is Python {got}, expected {target}"


def test_server_and_kernel_agree():
    assert _minor(SERVER_PY) == _minor(KERNEL_PY), "server venv and kernel env Python differ"


def test_jupyter_stack_imports():
    # Runs under the server venv python, where the Jupyter stack lives.
    import notebook  # noqa: F401
    import jupyterlab  # noqa: F401
    import jupyter_server  # noqa: F401
    import nbclassic  # noqa: F401
    import jupyter_core  # noqa: F401
    import traitlets  # noqa: F401
    import notebook.utils  # noqa: F401  exercises the distutils->setuptools shim on 3.12+


def test_terra_extensions_import():
    sys.path.insert(0, CUSTOM_DIR)
    import jupyter_localize_extension  # noqa: F401
    import jupyter_delocalize  # noqa: F401


if __name__ == "__main__":
    import traceback

    tests = [v for k, v in sorted(globals().items()) if k.startswith("test_") and callable(v)]
    failed = 0
    for test in tests:
        try:
            test()
            print(f"PASS {test.__name__}")
        except Exception:
            failed += 1
            print(f"FAIL {test.__name__}")
            traceback.print_exc()
    print(f"\n{len(tests) - failed}/{len(tests)} passed")
    sys.exit(1 if failed else 0)
