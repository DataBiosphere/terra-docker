#!/bin/bash

set -e -x

chown -R jupyter:users $JUPYTER_USER_HOME/
sudo -E -u jupyter /opt/conda/bin/pip install --upgrade jupyter-server
chown -R jupyter:users /opt/conda/etc/jupyter/
sudo -E -u jupyter /opt/conda/bin/jupyter server extension enable --py qiime2 --sys-prefix
