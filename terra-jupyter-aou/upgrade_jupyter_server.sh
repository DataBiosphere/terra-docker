#!/bin/bash

sudo -E -u jupyter pip install --upgrade jupyter-server
jupyter server extension enable --py qiime2 --sys-prefix

