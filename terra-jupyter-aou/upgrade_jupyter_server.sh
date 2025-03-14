#!/bin/bash

set -e -x

sudo -E -u jupyter pip install --upgrade jupyter-server
chown -R jupyter:users /opt/conda/etc/jupyter/
sudo -E -u jupyter /opt/conda/etc/jupyter server extension enable --py qiime2 --sys-prefix
chown -R jupyter:users $JUPYTER_USER_HOME/
