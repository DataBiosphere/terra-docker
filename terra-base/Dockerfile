# Latest gpu-enabled base image on Ubuntu 22, 132 MB compressed
FROM --platform=linux/amd64 nvidia/cuda:13.0.1-base-ubuntu22.04

LABEL maintainer="DSP Analysis Team <dsp-analysis@broadinstitute.org>"

# TODO:
# ! try moving conda setup before UV setup
# ! specify that UV uses the conda python
# add more comments/clearer naming around the python versions being used
# double check that the correct CUDA/GPU drivers are available, otherwise copy from old base image via a multi-stage build
# look into copying over apt-get packages from the old terra base image in next level of images
# have examples of custom images extending this base image for different use cases (e.g. R, GATK, etc)

# want the command to fail due to an error at any stage in the pipe: https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/usr/bin/bash", "-o", "pipefail", "-c"]

#######################
# General Environment Variables
#######################
ENV DEBIAN_FRONTEND=noninteractive
ENV LC_ALL=en_US.UTF-8

# Version of python to be installed and used
ENV PYTHON_VERSION=3.10
# Paired conda installer
ENV CONDA_INSTALLER=https://repo.anaconda.com/miniconda/Miniconda3-py310_25.9.1-1-Linux-x86_64.sh
ENV JUPYTER_VERSION=5.7.2
ENV NODE_MAJOR=20

#################
# Install Prerequisites
#################
RUN apt-get update && apt-get install -yq --no-install-recommends \
    # basic necessities
    sudo \
    ca-certificates \
    curl \
    jq \
    # gnupg requirement
    gnupg \
    dirmngr \
    # useful utilities for debugging within docker itself \
    nano \
    less \
    procps \
    lsb-release \
    # gcc compiler
    build-essential \
    locales \
    # for ssh-agent and ssh-add
    keychain \
    # extras \
    wget \
    bzip2 \
    git \
    # Uncomment en_US.UTF-8 for inclusion in generation
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    # Generate locale
    && locale-gen \
    # cleanup
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

##############################
# Set up Node for Jupyterlab
##############################
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Install Node >18
RUN apt-get update && apt-get install -yq --no-install-recommends
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN dpkg --remove --force-remove-reinstreq libnode-dev
RUN apt-get update && apt-get install -f -yq nodejs

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
# add R repo for later R package installation \
RUN wget -qO- https://cloud.r-project.org/bin/linux/ubuntu/marutter_pubkey.asc | tee -a /etc/apt/trusted.gpg.d/cran_ubuntu_key.asc \
    && apt-key adv --keyserver keyserver.ubuntu.com --recv-keys E298A3A825C0D65DFD57CBB651716619E084DAB9 \
    && apt-get update && apt-get install -yq --no-install-recommends software-properties-common \
    && add-apt-repository --no-update "deb https://cloud.r-project.org/bin/linux/ubuntu jammy-cran40/" \
    # Install R base
    && apt-get update && apt-get install -y r-base \
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
# ENV PATH="${PATH}:${CONDA_ENV_HOME}/bin:${CONDA_HOME}/bin"
ENV PATH="${PATH}:${CONDA_HOME}/bin"

# In order to override the default kernel, the conda environment must be named 'python3'
ENV CONDA_ENV_NAME=python3
ENV CONDA_ENV_HOME=$USER_HOME/.envs/$CONDA_ENV_NAME
ENV CONDA_FILES=$CONDA_HOME/custom

# Copy over the conda environment files
COPY conda/ $CONDA_FILES
ENV CONDA_FILES=$CONDA_HOME/custom

# Set up the path to the user python from conda
ENV BASE_PYTHON_PATH=$CONDA_HOME/bin/python$PYTHON_VERSION
# Tell conda to NOT write bite code (aka these.pyc files)
ENV PYTHONDONTWRITEBYTECODE=true

# Have to accept the conda terms of service to be able to install packages
RUN conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/main \
 && conda tos accept --override-channels --channel https://repo.anaconda.com/pkgs/r

#RUN conda init bash \
#    && . ~/.bashrc \
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

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh
RUN sh /uv-installer.sh && rm /uv-installer.sh

# Add local bin to PATH for uv
ENV PATH="/root/.local/bin/:$PATH"

ENV JUPYTER_HOME=/etc/jupyter

# Create a virtual environment and install jupyter packages
# setuptools and wheel are required for some of the jupyter extensions
RUN uv venv $JUPYTER_HOME --python $BASE_PYTHON_PATH \
    && source $JUPYTER_HOME/bin/activate \
    && uv pip install wheel \
    && uv pip install setuptools \
     && uv pip install -r pyproject.toml  --no-cache --no-build-isolation \
    # Cleanup
     && rm uv.lock && rm pyproject.toml

# add jupyter to path
ENV PATH="${PATH}:${JUPYTER_HOME}/bin"

# Remove default jupyter kernel (to force use of the conda python kernel)
RUN $JUPYTER_HOME/bin/jupyter kernelspec remove python3 -y

# #######################
# # Terra-specific Utilities
# #######################
# copy over jupyter extensions and kernel config files
COPY jupyter/ $JUPYTER_HOME

# give user ownership of jupyter home and conda env home
# and make extension files executable
RUN chown -R $USER:users $JUPYTER_HOME $CONDA_HOME  \
&& find $JUPYTER_HOME/extensions/scripts -name '*.sh' -type f | xargs chmod +x

# make the run-jupyter script executable
RUN chmod +x -R $JUPYTER_HOME/run-jupyter.sh

# Setup jupyter and r kernels
ENV JUPYTER_KERNELSPEC_DIR=/usr/local/share/jupyter/
RUN chown -R $USER:users $JUPYTER_KERNELSPEC_DIR \
    && find $JUPYTER_HOME/kernel -name '*.sh' -type f | xargs chmod +x \
    # You can get kernel directory by running `jupyter kernelspec list`
    && $JUPYTER_HOME/kernel/kernelspec.sh $JUPYTER_HOME/kernel $JUPYTER_KERNELSPEC_DIR/kernels

# Create the welder user
# The welder uid is consistent with the Welder docker definition here:
#  https://github.com/DataBiosphere/welder/blob/master/project/Settings.scala
# Adding welder-user to the Jupyter container isn't strictly required, but it makes welder-added
# files display nicer when viewed in a terminal.
ENV WELDER_USER welder-user
# This UID must stay consistent with the UID defined in Welder
ENV WELDER_UID 1001
RUN useradd -m -s /bin/bash -N -u $WELDER_UID $WELDER_USER

# Make sure that the jupyter user will have access to the jupyter path in the working directory
EXPOSE $JUPYTER_PORT
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