#!/bin/bash
# Leonardo calls this for user-specified classic nbextensions.
# Notebook 7 and JupyterLab 4 do not load them, so warn and skip instead of failing the runtime.
if [ -n "$1" ]; then
  echo "terra-jupyter: classic nbextension '$1' is not supported by Notebook 7; skipping."
fi
