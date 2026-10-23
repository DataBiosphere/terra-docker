#!/bin/bash

set -e

if [ -n "$1" ]; then
  JUPYTER_EXTENSION=$1
  uv pip install ${JUPYTER_EXTENSION}
  sudo -E -u jupyter jupyter serverextension enable --py ${JUPYTER_EXTENSION} --sys-prefix
  # `jupyter nbextension` does not exist in Notebook 7 (classic nbextensions are not supported).
  # sudo -E -u jupyter jupyter nbextension install --py ${JUPYTER_EXTENSION} --sys-prefix
  # sudo -E -u jupyter jupyter nbextension enable --py ${JUPYTER_EXTENSION} --sys-prefix
fi
