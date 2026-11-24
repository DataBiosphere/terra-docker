#!/bin/bash
# Installs a server extension from a pip package name into the Jupyter environment.
set -e

if [ -n "$1" ]; then
  JUPYTER_EXTENSION=$1
  uv pip install --python ${JUPYTER_HOME}/bin/python ${JUPYTER_EXTENSION}
  sudo -E -u jupyter ${JUPYTER_HOME}/bin/jupyter server extension enable --py ${JUPYTER_EXTENSION} --sys-prefix
fi
