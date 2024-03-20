#!/usr/bin/env bash

# installs jupyter_contrib_nbextensions https://github.com/ipython-contrib/jupyter_contrib_nbextensions
# unfortunately this package is not compatible with new versions of notebooks
# or nbclassic, so this is a temporary hack to directly install the js extensions
# using NBclassic

set -e
NBEXTENSION_HOME=/usr/local/lib/python3.10/dist-packages/jupyter_contrib_nbextensions/nbextensions
jupyter nbclassic-extension install ${NBEXTENSION_HOME}/toc2 --user
jupyter nbclassic-extension install ${NBEXTENSION_HOME}/codefolding --user
jupyter nbclassic-extension install ${NBEXTENSION_HOME}/collapsible_headings --user
jupyter nbclassic-extension enable toc2/main
jupyter nbclassic-extension enable codefolding/main
jupyter nbclassic-extension enable collapsible_headings/main
