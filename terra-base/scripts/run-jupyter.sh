#!/usr/bin/env bash

set -e

# Change the default umask to support R/W access to the shared volume with welder
umask 002

# TODO: change default to ${HOME}/notebooks once welder is rolled out to all clusters
NOTEBOOKS_DIR=${1:-${HOME}}

# Forces python 3.10
JUPYTER_BASE="/etc/jupyter/bin/python3.10 /etc/jupyter/bin/jupyter-notebook"
JUPYTER_CMD="$JUPYTER_BASE --NotebookApp.nbserver_extensions=\"{'jupyter_localize_extension':True}\" &> ${NOTEBOOKS_DIR}/jupyter.log"

echo $JUPYTER_CMD

eval $JUPYTER_CMD
