#!/usr/bin/env bash

TMP_KERNELSPEC_DIR=$1
KERNELSPEC_HOME=$2

mkdir ${KERNELSPEC_HOME}/ir

# Replace the contents of the Python kernel scripts
sed -e 's/${PY_VERSION}/3/g' -e 's|${JUPYTER_HOME}|'${JUPYTER_HOME}'|g' ${TMP_KERNELSPEC_DIR}/python_kernelspec.tmpl > ${KERNELSPEC_HOME}/python3/kernel.json
# Enable R kernel
sed 's|${JUPYTER_HOME}|'${JUPYTER_HOME}'|g' ${TMP_KERNELSPEC_DIR}/r_kernelspec.tmpl > ${KERNELSPEC_HOME}/ir/kernel.json