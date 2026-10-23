#!/usr/bin/env bash

TMP_KERNELSPEC_DIR=$1
KERNELSPEC_HOME=$2

# The R kernel is NOT registered in terra-jupyter-base: IRkernel is not installed here, so an R kernel
# would die on start ("there is no package called 'IRkernel'"). terra-jupyter-r installs IRkernel and
# registers the R kernel (as "ir", the name Terra R notebooks use) after that install.
# mkdir -p ${KERNELSPEC_HOME}/ir

# Replace the contents of the Python kernel scripts.
# The interpreter must be the absolute path into the user's conda env: a bare "python3"
# resolves against PATH, where /usr/bin comes first and the conda env isn't present at
# all, so the kernel started as /usr/bin/python3 and died with
# "No module named ipykernel_launcher".
sed -e 's/${PY_VERSION}/3/g' \
    -e 's|${JUPYTER_HOME}|'${JUPYTER_HOME}'|g' \
    -e 's|${CONDA_ENV_HOME}|'${CONDA_ENV_HOME}'|g' \
    ${TMP_KERNELSPEC_DIR}/python_kernelspec.tmpl > ${KERNELSPEC_HOME}/python3/kernel.json
# Enable R kernel -- done in terra-jupyter-r, see above
# sed 's|${JUPYTER_HOME}|'${JUPYTER_HOME}'|g' ${TMP_KERNELSPEC_DIR}/r_kernelspec.tmpl > ${KERNELSPEC_HOME}/ir/kernel.json
