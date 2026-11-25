#!/bin/bash
# Checks a terra-jupyter image against what Leonardo's GCE init and start scripts and Terra UI expect,
# then runs the Python tests inside the image.
# Example: ./terra-jupyter/tests/contract_test.sh terra-jupyter:smoke-test
set -euo pipefail

IMAGE=${1:-terra-jupyter:smoke-test}
CONTAINER=terra-jupyter-contract-$$
PROJECT=test-project
RUNTIME=test-runtime
BASE=/notebooks/${PROJECT}/${RUNTIME}

cleanup() { docker rm -f "${CONTAINER}" >/dev/null 2>&1 || true; }
trap cleanup EXIT

run() { docker run --rm --entrypoint /bin/bash "${IMAGE}" -c "$1"; }

check() {
  local description=$1
  shift
  if "$@"; then
    echo "PASS: ${description}"
  else
    echo "FAIL: ${description}"
    exit 1
  fi
}

# Static checks on the image.
check "JUPYTER_HOME is /etc/jupyter and Leonardo's .terra-base-marker exists" \
  run 'test "${JUPYTER_HOME}" = /etc/jupyter && test -f /etc/jupyter/.terra-base-marker'
check "jupyter user has UID 1002 in group users; welder-user has UID 1001" \
  run 'test "$(id -u jupyter)" = 1002 && id -gn jupyter | grep -qw users && test "$(id -u welder-user)" = 1001'
check "files Leonardo copies or edits exist" \
  run 'cd /etc/jupyter && ls custom/google_sign_in.js custom/extension_entry_jupyter.js custom/safe-mode.js custom/edit-mode.js custom/jupyter_delocalize.py jupyter_notebook_config.py >/dev/null'
check "Leonardo's scripts are executable" \
  run 'cd /etc/jupyter/scripts && test -x run-jupyter.sh && for f in extension/*.sh; do test -x "$f" || exit 1; done'
check "Python 3.13 for Jupyter and the user conda env" \
  run '/etc/jupyter/bin/python --version | grep -q "Python 3.13" && ${CONDA_ENV_HOME}/bin/python --version | grep -q "Python 3.13"'
check "JupyterLab 4 and Notebook 7" \
  run '/etc/jupyter/bin/jupyter lab --version | grep -q "^4\." && /etc/jupyter/bin/jupyter notebook --version | grep -q "^7\."'
check "Node 24, R, git and uv are available" \
  run 'node --version | grep -q "^v24\." && R --version >/dev/null && git --version >/dev/null && uv --version >/dev/null'
check "Terra JupyterLab extension is installed and enabled" \
  run '/etc/jupyter/bin/jupyter labextension list 2>&1 | grep -E "terra-jupyterlab-extension .*enabled"'
check "python3 and r kernelspecs are installed" \
  run '/etc/jupyter/bin/jupyter kernelspec list | grep -qw python3 && /etc/jupyter/bin/jupyter kernelspec list | grep -qw r'

# Leonardo's init steps that run outside its retry wrapper.
# Same environment as Leonardo's jupyter-docker-compose-gce.yaml, including its PATH override.
LEO_PATH="/root/.local/bin:/etc/jupyter/bin:/opt/conda/bin:/usr/local/nvidia/bin:/usr/local/cuda/bin:/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin:/home/jupyter/.local/bin:/home/jupyter/packages/bin"
docker run -d --name "${CONTAINER}" --entrypoint tail \
  -e GOOGLE_PROJECT=${PROJECT} -e CLUSTER_NAME=${RUNTIME} -e RUNTIME_NAME=${RUNTIME} -e WELDER_ENABLED=false \
  -e NOTEBOOKS_DIR=/home/jupyter -e PIP_USER=true -e R_LIBS=/home/jupyter/packages \
  -e PYTHONPATH=/etc/jupyter/custom:/usr/lib/spark/python:/home/jupyter/packages -e PATH="${LEO_PATH}" \
  "${IMAGE}" -f /dev/null >/dev/null

check "custom JS copy chain succeeds as root" docker exec -u 0 "${CONTAINER}" /bin/bash -c '
  $JUPYTER_HOME/scripts/extension/install_jupyter_contrib_nbextensions.sh \
  && mkdir -p /home/jupyter/.jupyter/custom/ \
  && chown -R jupyter:users /home/jupyter/.jupyter \
  && cp $JUPYTER_HOME/custom/google_sign_in.js /home/jupyter/.jupyter/custom/ \
  && ls -la $JUPYTER_HOME/custom/extension_entry_jupyter.js \
  && cp $JUPYTER_HOME/custom/extension_entry_jupyter.js /home/jupyter/.jupyter/custom/custom.js \
  && cp $JUPYTER_HOME/custom/safe-mode.js /home/jupyter/.jupyter/custom/ \
  && cp $JUPYTER_HOME/custom/edit-mode.js /home/jupyter/.jupyter/custom/ \
  && mkdir -p $JUPYTER_HOME/nbconfig'
check "user nbextension install is skipped, not failed" docker exec "${CONTAINER}" \
  /etc/jupyter/scripts/extension/jupyter_install_notebook_extension.sh /tmp/saturn-iframe-extension.js
check "nbstripout install and git config succeed as the default user" docker exec "${CONTAINER}" /bin/bash -c \
  'pip install nbstripout && nbstripout --install --global && git config --global core.excludesfile /home/jupyter/gitignore_global'
check "sed on jupyter_notebook_config.py succeeds" docker exec "${CONTAINER}" \
  sed -i '/^# to mount there as it effectively deletes existing files on the image/,+5d' /etc/jupyter/jupyter_notebook_config.py

notebook_with() {
  local kernel=$1 language=$2 source=$3
  printf '{"cells": [{"cell_type": "code", "source": %s, "metadata": {}, "outputs": [], "execution_count": null}], "metadata": {"kernelspec": {"name": "%s", "display_name": "%s", "language": "%s"}}, "nbformat": 4, "nbformat_minor": 5}' \
    "$(printf '%s' "${source}" | python3 -c 'import json,sys; print(json.dumps(sys.stdin.read()))')" "${kernel}" "${kernel}" "${language}"
}
docker exec "${CONTAINER}" /bin/bash -c "cat > /tmp/py.ipynb" <<<"$(notebook_with python3 python 'import sys; assert sys.executable.startswith("/home/jupyter/.envs/python3/"), sys.executable')"
docker exec "${CONTAINER}" /bin/bash -c "cat > /tmp/r.ipynb" <<<"$(notebook_with r R 'stopifnot(1 + 1 == 2)')"
check "python3 kernel runs code in the user's conda env" docker exec "${CONTAINER}" /etc/jupyter/bin/jupyter execute /tmp/py.ipynb
check "r kernel runs code" docker exec "${CONTAINER}" /etc/jupyter/bin/jupyter execute /tmp/r.ipynb

# Start the server the way Leonardo does and call the endpoints Leonardo and Terra UI use.
docker exec -d "${CONTAINER}" /bin/bash -c '/etc/jupyter/scripts/run-jupyter.sh /home/jupyter'
for _ in $(seq 1 60); do
  if docker exec "${CONTAINER}" curl -sf "http://localhost:8000${BASE}/api/status" >/dev/null; then break; fi
  sleep 2
done
docker exec "${CONTAINER}" /bin/bash -c 'echo "{\"cells\": [], \"metadata\": {}, \"nbformat\": 4, \"nbformat_minor\": 5}" > /home/jupyter/test.ipynb'

http_ok() { docker exec "${CONTAINER}" curl -sf -o /dev/null "http://localhost:8000${BASE}$1"; }
check "Leonardo health check api/status" http_ok /api/status
check "Leonardo idle check api/sessions" http_ok /api/sessions
check "Notebook 7 tree view" http_ok /tree
check "Notebook 7 notebook URL used by Terra UI" http_ok /notebooks/test.ipynb
check "JupyterLab" http_ok /lab
check "api/terra/config reports the runtime" docker exec "${CONTAINER}" /bin/bash -c \
  "curl -sf http://localhost:8000${BASE}/api/terra/config | grep -q '\"googleProject\": \"${PROJECT}\"'"
docker rm -f "${CONTAINER}" >/dev/null

# Python tests for the server extension and the Welder contents manager.
# The container is thrown away, so the test tools go straight into the Jupyter environment.
check "pytest suite" docker run --rm --entrypoint /bin/bash "${IMAGE}" -c '
  uv pip install -q --python /etc/jupyter/bin/python pytest "pytest-jupyter[server]" requests-mock \
  && cd /etc/jupyter/tests && /etc/jupyter/bin/python -m pytest -q -p no:cacheprovider'

echo "All terra-jupyter contract checks passed"
