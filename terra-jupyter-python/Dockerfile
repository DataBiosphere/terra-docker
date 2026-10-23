ARG BASE_PLATFORM=linux/amd64
FROM --platform=${BASE_PLATFORM} us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:2.1.0

# need to run apt-get and other install commands as root, but switch back to jupyter user for running notebooks
USER root

SHELL ["/usr/bin/bash", "-o", "pipefail", "-c"]

# Enables native Google Cloud Storage support in HTSlib
# Allows tools to directly read/write files from GCS buckets using gs:// URLs
ENV HTSLIB_CONFIGURE_OPTIONS="--enable-gcs"

# python-lzo has no wheel for Python 3.13, so it is built from source and needs the LZO headers
RUN apt-get update && apt-get install -yq --no-install-recommends \
  liblzo2-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


# Install this image's Python packages into the user's conda env (the notebook kernel's python).
# pyproject.toml stays at /etc/terra-docker/ so images built FROM this one (terra-jupyter-gatk) can
# reinstall the same packages.
# Files uv adds are root-owned; hand them to the jupyter user (only those, so the rest of the env
# is not copied into this layer) so `pip install` in a notebook can upgrade them.
COPY pyproject.toml /etc/terra-docker/pyproject.toml
RUN uv pip install --python ${CONDA_ENV_HOME}/bin/python -r /etc/terra-docker/pyproject.toml --no-cache \
  && find ${CONDA_ENV_HOME} ! -user $USER -exec chown -h $USER:users {} +

ENV USER=jupyter
USER $USER
# We want pip to install into the user's dir when the notebook is running.
ENV PIP_USER=true
# Enable Intel oneDNN optimizatoin by default
ENV TF_ENABLE_ONEDNN_OPTS=1

# # Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# # When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# # additional setup inside the container before execution.  Jupyter execution occurs when the
# # init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/etc/jupyter/bin/jupyter", "notebook"]
