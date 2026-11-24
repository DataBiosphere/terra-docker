#!/usr/bin/env bash

set -e

# Change the default umask to support R/W access to the shared volume with welder
umask 002

NOTEBOOKS_DIR=${1:-${HOME}}

# Notebook 7 starts jupyter-server with Notebook and JupyterLab both loaded. Extensions are
# enabled in /etc/jupyter/jupyter_server_config.d, not on the command line, because a
# command-line jpserver_extensions replaces the whole set.
JUPYTER_CMD="/etc/jupyter/bin/jupyter notebook &> ${NOTEBOOKS_DIR}/jupyter.log"

echo $JUPYTER_CMD

eval $JUPYTER_CMD
