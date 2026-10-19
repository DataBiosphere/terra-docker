#!/bin/bash
set -e

# DISABLED: classic notebook extensions (nbextensions) are not supported by Notebook 7, which has no
# `jupyter nbextension` command. Leonardo calls this script for /etc/jupyter/jupyter-iframe-extension.js
# on every runtime start; failing here aborted Leonardo's startup script before Jupyter was started,
# so the runtime timed out. Exit 0 so startup continues. The nbclassic UI (/nbclassic) is installed,
# but its extensions are managed with `jupyter nbclassic-extension`, not this script.
echo "jupyter_install_notebook_extension.sh: classic nbextensions are not supported on Notebook 7, skipping ${1:-<none>}"
exit 0

# if [ -n "$1" ]; then
#   JUPYTER_EXTENSION=$1
#   JUPYTER_EXTENSION_NAME=`basename ${JUPYTER_EXTENSION%%.*}`
#   mkdir -p ${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}
#   if [[ ${JUPYTER_EXTENSION} == *'.tar.gz' ]]; then
#     tar -xzf ${JUPYTER_EXTENSION} -C${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}
#   else
#     mv ${JUPYTER_EXTENSION} ${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}/main.js
#   fi
#   sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextension install ${JUPYTER_HOME}/${JUPYTER_EXTENSION_NAME}/ --sys-prefix
#   sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextension enable ${JUPYTER_EXTENSION_NAME}/main --sys-prefix
# fi
