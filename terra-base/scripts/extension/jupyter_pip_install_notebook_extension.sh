#!/bin/bash
set -e

if [ -n "$1" ]; then
  JUPYTER_EXTENSION=$1
  pip3 install ${JUPYTER_EXTENSION}
  jupyter nbclassic-extension install --py ${JUPYTER_EXTENSION} --user
  jupyter nbclassic-extension enable --py ${JUPYTER_EXTENSION}
fi
