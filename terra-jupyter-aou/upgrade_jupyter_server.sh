#!/bin/bash

set -e -x

sudo -E -u jupyter pip install --upgrade jupyter-server
sudo -E -u jupyter jupyter server extension enable --py qiime2 --sys-prefix
chown -R jupyter:users $JUPYTER_USER_HOME/
