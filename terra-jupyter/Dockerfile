###############################
# Build the Terra JupyterLab extension (prebuilt, shipped as a wheel)
###############################
FROM node:24-trixie AS labextension

RUN apt-get update && apt-get install -yq --no-install-recommends python3 python3-venv \
    && rm -rf /var/lib/apt/lists/*
COPY jupyterlab-extension /src
RUN python3 -m venv /build \
    && /build/bin/pip install --no-cache-dir build \
    && /build/bin/python -m build --wheel --outdir /wheels /src

###############################
# terra-jupyter
###############################
FROM us.gcr.io/broad-dsp-gcr-public/terra-core:0.0.1

LABEL maintainer="DSP Analysis Team <dsp-analysis@broadinstitute.org>"

# want the command to fail due to an error at any stage in the pipe: https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/usr/bin/bash", "-o", "pipefail", "-c"]

#######################
# General Environment Variables
#######################
ENV DEBIAN_FRONTEND=noninteractive

# Version of python to be installed and used
ENV PYTHON_VERSION=3.13
# Paired conda installer
ENV CONDA_INSTALLER=https://repo.anaconda.com/miniconda/Miniconda3-py313_26.9.4-1-Linux-x86_64.sh
ENV NODE_MAJOR=24

#################
# Install Prerequisites
#################
RUN apt-get update && apt-get install -yq --no-install-recommends \
    # gnupg requirement
    gnupg \
    dirmngr \
    # useful utilities for debugging within docker itself
    nano \
    # gcc compiler
    build-essential \
    # for ssh-agent and ssh-add
    keychain \
    # extras
    wget \
    bzip2 \
    git \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#######################
# CUDA runtime, as in nvidia/cuda:13.5.0-base-ubuntu26.04
#######################
ENV NV_CUDA_CUDART_VERSION=13.5.37-1
RUN curl -fsSLo /tmp/cuda-keyring.deb https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2604/x86_64/cuda-keyring_1.1-1_all.deb \
    && dpkg -i /tmp/cuda-keyring.deb \
    && rm /tmp/cuda-keyring.deb \
    && apt-get update && apt-get install -yq --no-install-recommends \
        cuda-cudart-13-5=${NV_CUDA_CUDART_VERSION} \
        cuda-toolkit-13-5-config-common=${NV_CUDA_CUDART_VERSION} \
        cuda-toolkit-13-config-common=${NV_CUDA_CUDART_VERSION} \
        cuda-toolkit-config-common=${NV_CUDA_CUDART_VERSION} \
        cuda-compat-13-5 \
    && echo "/usr/local/cuda/lib64" >> /etc/ld.so.conf.d/nvidia.conf \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*
ENV CUDA_VERSION=13.5.0
ENV PATH=/usr/local/nvidia/bin:/usr/local/cuda/bin:${PATH}
ENV LD_LIBRARY_PATH=/usr/local/nvidia/lib:/usr/local/nvidia/lib64:/usr/local/cuda/lib64
ENV NVIDIA_VISIBLE_DEVICES=all
ENV NVIDIA_DRIVER_CAPABILITIES=compute,utility
ENV NVIDIA_REQUIRE_CUDA="cuda>=13.5"

##############################
# Node, for JupyterLab extensions that users build
##############################
RUN mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" > /etc/apt/sources.list.d/nodesource.list \
    && apt-get update && apt-get install -yq --no-install-recommends nodejs \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

##########################
# Create the User's Jupyter User
##########################
# Create the jupyter user and give sudo permission
ENV USER=jupyter
# This UID must stay static to be one greater than the welder user (1001)
ENV USER_UID=1002

# Create the user home and add to the users group
ENV USER_HOME=/home/$USER
RUN useradd -m -s /bin/bash -d $USER_HOME -N -u $USER_UID  $USER
RUN usermod -g users $USER

# We want to grant the user sudo permissions without password
# so they can install the necessary packages that they want to use on the docker container
RUN echo "$USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$USER \
    && chmod 0440 /etc/sudoers.d/$USER

############
# Install R
############
RUN curl -fsSL https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | gpg --dearmor -o /etc/apt/keyrings/cran.gpg \
    && . /etc/os-release \
    && echo "deb [signed-by=/etc/apt/keyrings/cran.gpg] https://cloud.r-project.org/bin/linux/ubuntu ${VERSION_CODENAME}-cran40/" > /etc/apt/sources.list.d/cran.list \
    && apt-get update && apt-get install -yq --no-install-recommends r-base r-base-dev r-cran-irkernel \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

############################################
# Install Miniconda and setup base conda environment
############################################
## CONDA should not be used by devs to manage package dependencies,
# but is a widely used tool to manage python environments in a runtime
# and we should provide it to users

# download and install conda
ENV CONDA_HOME=/opt/conda

RUN curl -so $HOME/miniconda.sh $CONDA_INSTALLER \
    && chmod +x $HOME/miniconda.sh \
    && $HOME/miniconda.sh -b -p $CONDA_HOME \
    && rm $HOME/miniconda.sh
ENV PATH="${PATH}:${CONDA_HOME}/bin"

# In order to override the default kernel, the conda environment must be named 'python3'
ENV CONDA_ENV_NAME=python3
ENV CONDA_ENV_HOME=$USER_HOME/.envs/$CONDA_ENV_NAME
ENV CONDA_FILES=$CONDA_HOME/custom

# Copy over the conda environment files
COPY conda/ $CONDA_FILES

# Set up the path to the user python from conda
ENV BASE_PYTHON_PATH=$CONDA_HOME/bin/python$PYTHON_VERSION
# Tell conda to NOT write bite code (aka these.pyc files)
ENV PYTHONDONTWRITEBYTECODE=true

# Have to accept the conda terms of service to be able to install packages
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
 && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

RUN conda env create --prefix $CONDA_ENV_HOME --file $CONDA_FILES/conda-environment.yaml \
    # Remove packages tarballs and python bytecode files from the image
    && conda clean -afy \
    && rm $CONDA_FILES/conda-environment.yaml \
    # Make sure the USER is the owner of the folder where the base conda is installed
    && chown -R $USER:users $USER_HOME

# Create the base conda environment that will be used by the jupyter user
RUN conda run -p ${CONDA_ENV_HOME} python -m ipykernel install --name=$CONDA_ENV_NAME


##############################
# Setup UV Environment for Jupyter
##############################
# Using UV (Universal Virtualenv) to create a virtual environment
# UV is used in place of poetry for speed and simplicity.

# NOTE: this is for the environment the jupyter server will be running in,
# separate from the jupyter user's conda environment.
COPY uv.lock .
COPY pyproject.toml .

# Setup UV environment variables
# - tells uv to copy the Python files into the container from the cache mount,
# - tell uv to byte-compile packages for faster application startups,
# - don't seed venv, we need to install separately
# - don't cache to keep the image size small
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_VENV_SEED=false \
    UV_NO_CACHE=true

# Install uv where every user can run it: Leonardo's extension scripts call it as the jupyter user.
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN UV_INSTALL_DIR=/usr/local/bin UV_NO_MODIFY_PATH=1 sh /uv-installer.sh && rm /uv-installer.sh

ENV JUPYTER_HOME=/etc/jupyter

# Create a virtual environment and install the jupyter packages
COPY --from=labextension /wheels /tmp/wheels
RUN uv venv $JUPYTER_HOME --python $BASE_PYTHON_PATH \
    && uv pip install --python $JUPYTER_HOME/bin/python -r pyproject.toml \
    && uv pip install --python $JUPYTER_HOME/bin/python /tmp/wheels/*.whl \
    # Cleanup
    && rm -rf uv.lock pyproject.toml /tmp/wheels

# add jupyter to path
ENV PATH="${PATH}:${JUPYTER_HOME}/bin"

# Remove default jupyter kernel (to force use of the conda python kernel)
RUN $JUPYTER_HOME/bin/jupyter kernelspec remove python3 -y

# #######################
# # Terra-specific Utilities
# #######################

# Copy over utility scripts and config files
ENV JUPYTER_SCRIPTS=$JUPYTER_HOME/scripts
ENV JUPYTER_CUSTOM=$JUPYTER_HOME/custom
ENV JUPYTER_EXTENSIONS=$JUPYTER_SCRIPTS/extension
ENV JUPYTER_KERNEL=$JUPYTER_SCRIPTS/kernel

COPY scripts $JUPYTER_HOME/scripts
COPY custom $JUPYTER_HOME/custom
COPY jupyter_server_config.py jupyter_notebook_config.py $JUPYTER_HOME/
COPY jupyter_server_config.d $JUPYTER_HOME/jupyter_server_config.d
COPY tests $JUPYTER_HOME/tests

# Leonardo also sets this in the container; set it here so the image works on its own.
ENV PYTHONPATH=$JUPYTER_CUSTOM

# give user ownership of jupyter home and conda env home
# and make extension files executable
RUN chown -R $USER:users $JUPYTER_HOME $CONDA_HOME  \
&& find $JUPYTER_EXTENSIONS -name '*.sh' -type f | xargs chmod +x

# make the run-jupyter script executable
RUN chmod +x -R $JUPYTER_SCRIPTS/run-jupyter.sh

# Setup jupyter and r kernels
ENV JUPYTER_KERNELSPEC_DIR=/usr/local/share/jupyter/
RUN chown -R $USER:users $JUPYTER_KERNELSPEC_DIR \
    && find $JUPYTER_KERNEL -name '*.sh' -type f | xargs chmod +x \
    # You can get kernel directory by running `jupyter kernelspec list`
    && $JUPYTER_KERNEL/kernelspec.sh $JUPYTER_KERNEL $JUPYTER_KERNELSPEC_DIR/kernels

# Leonardo's start script checks this file to know the jupyter command is in /etc/jupyter/bin.
# The name comes from terra-base and is part of Leonardo's contract, so it must not change.
RUN touch /etc/jupyter/.terra-base-marker

# Make sure that the jupyter user will have access to the jupyter path in the working directory
EXPOSE 8000
WORKDIR $USER_HOME

# make pip install to a user directory, instead of a system directory which requires root.
# this is useful so `pip install` commands can be run in the context of a notebook.
ENV PIP_USER=true
USER $USER

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/etc/jupyter/bin/jupyter", "notebook"]
