#!/usr/bin/env bash

TMP_KERNELSPEC_DIR=$1
KERNELSPEC_HOME=$2

mkdir ${KERNELSPEC_HOME}/r

# Replace the contents of the Python kernel scripts. The kernel runs the user's conda env Python by
# absolute path: a bare "python3" would depend on PATH, which Leonardo overrides.
sed -e 's/${PY_VERSION}/3/g' -e 's|${JUPYTER_HOME}|'${JUPYTER_HOME}'|g' -e 's|${PYTHON_BIN}|'${CONDA_ENV_HOME}'/bin/python|g' ${TMP_KERNELSPEC_DIR}/python_kernelspec.tmpl > ${KERNELSPEC_HOME}/python3/kernel.json
# Enable R kernel
sed 's|${JUPYTER_HOME}|'${JUPYTER_HOME}'|g' ${TMP_KERNELSPEC_DIR}/r_kernelspec.tmpl > ${KERNELSPEC_HOME}/r/kernel.json