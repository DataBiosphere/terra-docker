#!/usr/bin/env bash

# Registers the R kernel. The python3 kernel is registered by terra-jupyter-base's kernelspec.sh.
# Named r_kernelspec.sh so the COPY in the Dockerfile does not overwrite that script.
TMP_KERNELSPEC_DIR=$1
KERNELSPEC_HOME=$2

mkdir -p ${KERNELSPEC_HOME}/ir

# Enable R kernel
sed 's|${JUPYTER_HOME}|'${JUPYTER_HOME}'|g' ${TMP_KERNELSPEC_DIR}/r_kernelspec.tmpl > ${KERNELSPEC_HOME}/ir/kernel.json
