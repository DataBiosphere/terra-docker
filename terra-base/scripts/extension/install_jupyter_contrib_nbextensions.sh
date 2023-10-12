#!/usr/bin/env bash

set -e
# installs jupyter_contrib_nbextensions https://github.com/ipython-contrib/jupyter_contrib_nbextensions
# also installs the jupyter_nbextensions_configurator https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator
sudo -E -u jupyter nbextensions_configurator enable --user
sudo -E -u jupyter contrib nbextension install --user
sudo -E -u jupyter nbextension enable toc2/main
sudo -E -u jupyter nbextension enable codefolding/main
sudo -E -u jupyter nbextension enable collapsible_headings/main

