#!/bin/bash

pip install --upgrade jupyter-server
jupyter server extension enable --py qiime2 --sys-prefix

