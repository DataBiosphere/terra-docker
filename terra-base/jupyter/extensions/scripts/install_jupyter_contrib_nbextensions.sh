#!/usr/bin/env bash

set -e
# installs jupyter_contrib_nbextensions https://github.com/ipython-contrib/jupyter_contrib_nbextensions
# also installs the jupyter_nbextensions_configurator https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator
sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextensions_configurator enable --sys-prefix
sudo -E -u jupyter /etc/jupyter/bin/jupyter contrib nbextension install --sys-prefix
sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextension enable toc2/main --sys-prefix
sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextension enable codefolding/main --sys-prefix
sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextension enable collapsible_headings/main --sys-prefix

