#!/bin/bash
# Installs a package with a server extension and a prebuilt JupyterLab extension from pip.
set -e

if [ -n "$1" ]; then
  JUPYTER_EXTENSION=$1
  uv pip install --python ${JUPYTER_HOME}/bin/python ${JUPYTER_EXTENSION}
  sudo -E -u jupyter ${JUPYTER_HOME}/bin/jupyter server extension enable --py ${JUPYTER_EXTENSION} --sys-prefix
fi
