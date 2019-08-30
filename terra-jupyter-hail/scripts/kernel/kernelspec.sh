#!/usr/bin/env bash

TMP_KERNELSPEC_DIR=$1
KERNELSPEC_HOME=$2

# Create directories for PySpark kernels
# Python kernel directories are somehow already created at this point.
mkdir ${KERNELSPEC_HOME}/pyspark3

# Replace the contents of the PySpark kernel scripts
sed -e 's/${PY_VERSION}/3/g' -e 's|${JUPYTER_HOME}|'${JUPYTER_HOME}'|g' ${TMP_KERNELSPEC_DIR}/pyspark_kernelspec.tmpl > ${KERNELSPEC_HOME}/pyspark3/kernel.json
