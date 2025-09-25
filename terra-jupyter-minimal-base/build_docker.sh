#!/bin/bash

# this copying stuff is here because there are requirements here and in ../terra-jupyter-base/
# but the build context cannot be both
cp -r ../terra-jupyter-base/custom custom
cp -r ../terra-jupyter-base/scripts scripts
cp -r ../terra-jupyter-base/jupyter_notebook_config.py jupyter_notebook_config.py

docker build -t terra-jupyter-minimal-base:0.0.3 .

rm -r custom
rm -r scripts
rm jupyter_notebook_config.py

# if requirements.txt, requirements_gcc.txt, and gcc_pkgs.txt get moved to the ../terra-jupyter-base/ folder,
# then all of the above could be replaced by this:
#docker build -t terra-jupyter-minimal-base:0.0.1 -f Dockerfile ../terra-jupyter-base/
