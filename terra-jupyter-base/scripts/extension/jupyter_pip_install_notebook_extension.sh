#!/bin/bash
set -e

if [ -n "$1" ]; then
  JUPYTER_EXTENSION=$1
  uv pip install ${JUPYTER_EXTENSION}
  # `jupyter nbextension` does not exist in Notebook 7 (classic nbextensions are not supported).
  # The package is still installed, in case it also ships a JupyterLab / Notebook 7 extension.
  # (also fixed the `--sys-prefixr` typo in the install line below)
  # sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextension install --py ${JUPYTER_EXTENSION} --sys-prefix
  # sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextension enable --py ${JUPYTER_EXTENSION} --sys-prefix
fi
