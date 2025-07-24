#!/usr/bin/env bash

set -e

# Change the default umask to support R/W access to the shared volume with welder
umask 002

NOTEBOOKS_DIR=${HOME}/notebooks

# Forces python 3
JUPYTER_BASE="/usr/jupytervenv/bin/python /usr/jupytervenv/bin/jupyter server"
JUPYTER_CMD="$JUPYTER_BASE --NotebookApp.nbserver_extensions=\"{'jupyter_localize_extension':True}\" &> ${NOTEBOOKS_DIR}/jupyter.log"

echo $JUPYTER_CMD

eval $JUPYTER_CMD
