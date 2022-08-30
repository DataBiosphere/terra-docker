#!/bin/bash

base="nvcr.io/nvidia/cuda:11.3.1-base-ubuntu20.04"

cp -r ../terra-jupyter-base/custom ../terra-jupyter-minimal-base/custom
cp -r ../terra-jupyter-base/scripts ../terra-jupyter-minimal-base/scripts
cp -r ../terra-jupyter-base/jupyter_notebook_config.py ../terra-jupyter-minimal-base/jupyter_notebook_config.py

docker build \
  -t terra-jupyter-minimal-gpu-base:0.0.1 \
  -f ../terra-jupyter-minimal-base/Dockerfile \
  --build-arg BASE_IMAGE=${base} \
  ../terra-jupyter-minimal-base/

rm -r ../terra-jupyter-minimal-base/custom
rm -r ../terra-jupyter-minimal-base/scripts
rm ../terra-jupyter-minimal-base/jupyter_notebook_config.py
