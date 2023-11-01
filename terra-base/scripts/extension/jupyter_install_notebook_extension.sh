#!/bin/bash
set -e

if [ -n "$1" ]; then
  JUPYTER_EXTENSION=$1
  JUPYTER_EXTENSION_NAME=`basename ${JUPYTER_EXTENSION%%.*}`
  mkdir -p ${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}
  if [[ ${JUPYTER_EXTENSION} == *'.tar.gz' ]]; then
    tar -xzf ${JUPYTER_EXTENSION} -C${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}
  else
    mv ${JUPYTER_EXTENSION} ${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}/main.js
  fi
  jupyter nbclassic-extension install ${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}/ --user
  jupyter nbclassic-extension enable ${JUPYTER_EXTENSION_NAME}/main
fi
