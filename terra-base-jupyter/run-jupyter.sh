#!/usr/bin/env bash

set -e

# Change the default umask to support R/W access to the shared volume with welder
umask 002

# TODO: change default to ${HOME}/notebooks once welder is rolled out to all clusters
SERVER_APP_BASE_URL=${1:-${HOME}}
SERVER_APP_WEBSOCKET_URL=${2:-${HOME}}
NOTEBOOKS_DIR=${3:-${HOME}}

JUPYTER_BASE="/usr/jupytervenv/bin/python /usr/jupytervenv/bin/jupyter server"
JUPYTER_CMD="$JUPYTER_BASE --ServerApp.base_url=${SERVER_APP_BASE_URL} --ServerApp.websocket_url=${SERVER_APP_WEBSOCKET_URL} --autoreload&> ${NOTEBOOKS_DIR}/jupyter.log"

echo $JUPYTER_CMD

eval $JUPYTER_CMD
