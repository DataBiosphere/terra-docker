#!/bin/bash

pip install --upgrade jupyter-server
jupyter server extension enable --py qiime2 --sys-prefix
chown -R rstudio:users $RSTUDIO_USER_HOME/.config
