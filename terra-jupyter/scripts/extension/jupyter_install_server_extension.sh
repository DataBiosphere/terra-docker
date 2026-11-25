#!/bin/bash
# Installs a server extension from a .tar.gz source archive into the Jupyter environment.
set -e

if [ -n "$1" ]; then
  JUPYTER_EXTENSION=$1
  JUPYTER_EXTENSION_NAME=`basename ${JUPYTER_EXTENSION%%.*}`
  mkdir -p ${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}
  tar -xzf ${JUPYTER_EXTENSION} -C${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}
  uv pip install --python ${JUPYTER_HOME}/bin/python -e ${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}
  sudo -E -u jupyter ${JUPYTER_HOME}/bin/jupyter server extension enable --py ${JUPYTER_EXTENSION_NAME} --sys-prefix
fi
