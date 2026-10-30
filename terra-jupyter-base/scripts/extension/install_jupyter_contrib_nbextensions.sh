#!/usr/bin/env bash

set -e
# installs jupyter_contrib_nbextensions https://github.com/ipython-contrib/jupyter_contrib_nbextensions
# also installs the jupyter_nbextensions_configurator https://github.com/Jupyter-contrib/jupyter_nbextensions_configurator
#
# Every step below needs `jupyter nbextension`, which does not exist in Notebook 7 (classic nbextensions
# are not supported), and jupyter_contrib_nbextensions / the configurator are not installed in the image.
# Notebook 7 has a built-in table of contents and collapsible headings. Exit 0 so callers don't fail.
echo "install_jupyter_contrib_nbextensions.sh: classic nbextensions are not supported on Notebook 7, skipping"
exit 0
# sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextensions_configurator enable --sys-prefix
# sudo -E -u jupyter /etc/jupyter/bin/jupyter contrib nbextension install --sys-prefix
# sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextension enable toc2/main --sys-prefix
# sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextension enable codefolding/main --sys-prefix
# sudo -E -u jupyter /etc/jupyter/bin/jupyter nbextension enable collapsible_headings/main --sys-prefix

