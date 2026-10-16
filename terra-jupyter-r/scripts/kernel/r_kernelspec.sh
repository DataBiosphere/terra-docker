#!/usr/bin/env bash

TMP_KERNELSPEC_DIR=$1
KERNELSPEC_HOME=$2

# Register the R kernel as "ir", the name Terra R notebooks use. terra-jupyter-base only registers
# the python3 kernel (its kernelspec.sh is left as is), since IRkernel is not installed there.
# Run this after IRkernel::installspec(), which creates ${KERNELSPEC_HOME}/ir with the R logos: the
# kernel.json written here replaces IRkernel's so the kernel starts through kernel_bootstrap.sh.
mkdir -p ${KERNELSPEC_HOME}/ir
sed 's|${JUPYTER_HOME}|'${JUPYTER_HOME}'|g' ${TMP_KERNELSPEC_DIR}/r_kernelspec.tmpl > ${KERNELSPEC_HOME}/ir/kernel.json
