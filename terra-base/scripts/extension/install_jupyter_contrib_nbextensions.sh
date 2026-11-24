#!/usr/bin/env bash
# Leonardo runs this on every runtime create, outside its retry wrapper, so it must exit 0.
# Notebook 7 and JupyterLab 4 do not load classic nbextensions; table of contents and code
# folding are built in.
echo "terra-base 2.x: classic contrib nbextensions are not supported; skipping."
