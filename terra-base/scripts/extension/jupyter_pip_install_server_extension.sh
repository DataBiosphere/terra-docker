#!/bin/bash

set -e

if [ -n "$1" ]; then
  JUPYTER_EXTENSION=$1
  uv pip install ${JUPYTER_EXTENSION}
  sudo -E -u jupyter /etc/jupyter/bin/jupyter serverextension enable --py ${JUPYTER_EXTENSION} --sys-prefix
fi
