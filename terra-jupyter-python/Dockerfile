FROM --platform=linux/amd64 us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:1.2.0

# need to run apt-get and other install commands as root, but switch back to jupyter user for running notebooks
USER root

SHELL ["/usr/bin/bash", "-o", "pipefail", "-c"]

# Enables native Google Cloud Storage support in HTSlib
# Allows tools to directly read/write files from GCS buckets using gs:// URLs
ENV HTSLIB_CONFIGURE_OPTIONS="--enable-gcs"

RUN apt-get update && apt-get install -yq --no-install-recommends \
  # packages specific to terra-jupyter-python \
  python-tk \
  xz-utils \
  libhdf5-dev \
  openssl \
  make \
  liblzo2-dev \
  liblzo2-2 \
  libz-dev \
  libcurl4-openssl-dev \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Copy image pyproject.toml and workspace uv.lock for reproducible builds
COPY terra-jupyter-base/pyproject.toml uv.lock ./


# Install Python packages using UV with lock file for reproducibility
# Note: We install into the conda environment that the user's notebooks will use
# We need to explicitly install wheel and setuptools to avoid errors about missing these prerequisite packages during the general UV install
RUN uv pip install --python ${CONDA_ENV_HOME}/bin/python -r pyproject.toml --no-cache \
  && rm pyproject.toml uv.lock
#  && sed -i 's/pandas.lib/pandas/g' ${CONDA_ENV_HOME}/lib/python3.10/site-packages/ggplot/stats/smoothers.py \
#  # the next few `sed` lines are workaround for a ggplot bug. See https://github.com/yhat/ggpy/issues/662 \
#  && sed -i 's/pandas.tslib.Timestamp/pandas.Timestamp/g' ${CONDA_ENV_HOME}/lib/python3.10/site-packages/ggplot/stats/smoothers.py \
#  && sed -i 's/pd.tslib.Timestamp/pd.Timestamp/g' ${CONDA_ENV_HOME}/lib/python3.10/site-packages/ggplot/stats/smoothers.py \
#  && sed -i 's/pd.tslib.Timestamp/pd.Timestamp/g' ${CONDA_ENV_HOME}/lib/python3.10/site-packages/ggplot/utils.py \
  # Cleanup \
#  && rm pyproject.toml uv.lock


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
