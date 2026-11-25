#!/bin/bash
# Installs a JupyterLab 4 extension. JupyterLab 4 only loads prebuilt extensions, which are
# distributed as Python packages: pass a pip requirement, a wheel, or a source archive.
set -e

if [ -n "$1" ]; then
  JUPYTER_EXTENSION=$1
  if [[ ${JUPYTER_EXTENSION} == *'.js' || ${JUPYTER_EXTENSION} == *'.ts' ]]; then
    echo "terra-jupyter: single-file JupyterLab extensions ('${JUPYTER_EXTENSION}') are not supported; package it as a prebuilt extension. Skipping."
    exit 0
  fi
  uv pip install --python ${JUPYTER_HOME}/bin/python ${JUPYTER_EXTENSION}
fi
