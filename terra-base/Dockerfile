# Latest gpu-enabled base image on Ubuntu 24, 313MB
FROM --platform=linux/amd64 nvidia/cuda:12.9.1-base-ubuntu24.04

LABEL maintainer="DSP Analysis Team <dsp-analysis@broadinstitute.org>"

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
ENV CONDA_INSTALLER=https://repo.anaconda.com/miniconda/Miniconda3-py310_23.5.1-0-Linux-x86_64.sh
ENV JUPYTER_VERSION=5.7.2
ENV NODE_MAJOR=20

###############
# Install Prerequisites
###############
RUN apt-get update && apt-get install -yq --no-install-recommends \
    # basic necessities
    sudo \
    ca-certificates \
    curl \
    jq \
    # gnupg requirement
    gnupg \
    dirmngr \
    # useful utilities for debugging within docker itself
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
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

##############################
# Set up Node for Jupyterlab
##############################
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Install Node >18 (needed for jupyterlab)
RUN apt-get update && apt-get install -yq --no-install-recommends
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN dpkg --remove --force-remove-reinstreq libnode-dev
RUN apt-get update && apt-get install -f -yq nodejs


#####################
# Create the Jupyter User (what users will see in Terra)
#####################
# Create the jupyter user and give sudo permission
ENV JUPYTER_USER=jupyter
ENV JUPYTER_UID=1002

# Create the jupyter user home and add the user to the users group
ENV JUPYTER_USER_HOME=/home/$JUPYTER_USER
RUN useradd -m -s /bin/bash -d $JUPYTER_USER_HOME -N -u $JUPYTER_UID -g users $JUPYTER_USER

# We want to grant the jupyter user sudo permissions without password
 # so they can install the necessary packages that they want to use on the docker container
RUN echo "$JUPYTER_USER ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/$JUPYTER_USER \
    && chmod 0440 /etc/sudoers.d/$JUPYTER_USER

################
# Create Welder user
################
# The welder uid must be consistent with the Welder docker definition here:
#  https://github.com/DataBiosphere/welder/blob/master/project/Settings.scala
# Adding welder-user to the Jupyter container isn't strictly required, but it makes welder-added
# files display nicer when viewed in a terminal.
ENV WELDER_USER=welder-user
ENV WELDER_UID=1001
RUN useradd -m  -s /bin/bash -N -u $WELDER_UID $WELDER_USER

############
# Install R
############
RUN apt-get update && apt-get install -y r-base

################
# Install Python
################
# Install Python 3.10 and add to system python path
# Miniconda does come with it's own installation of python, but it
# is cleaner to do a proper system instalation here and set the path
#RUN apt-get update && apt-get install -y python$PYTHON_VERSION python3-pip
#RUN update-alternatives --install /usr/bin/python python /usr/bin/python$PYTHON_VERSION 1 \
#   && update-alternatives --set python /usr/bin/python$PYTHON_VERSION

# Set up the path to the user python -->  /home/jupyter/.envs/base-python3.10/bin/python
#ENV BASE_PYTHON_PATH=usr/bin/python3
#
###############
# Install Miniconda
###############
## Note: CONDA is not used here to manage dependencies, but as a tool to manage python environments.
## We want to store the user conda environments in a directory that will be in the persistent disk
## Attention: If you change the Conda home location, please update conda_init.txt accordingly
ENV CONDA_ENV_NAME=base-python${PYTHON_VERSION}
ENV CONDA_ENV_HOME=$JUPYTER_USER_HOME/.envs/$CONDA_ENV_NAME
RUN curl -so $JUPYTER_USER_HOME/miniconda.sh ${CONDA_INSTALLER} \
    && chmod +x $JUPYTER_USER_HOME/miniconda.sh \
    && $JUPYTER_USER_HOME/miniconda.sh -b -p $CONDA_ENV_HOME \
    && rm $JUPYTER_USER_HOME/miniconda.sh
ENV PATH="${PATH}:${CONDA_ENV_HOME}/bin"

## Set up the path to the user python -->  /home/jupyter/.envs/base-python3.10/bin/python
ENV BASE_PYTHON_PATH=$CONDA_ENV_HOME/bin/python

# Tell conda to NOT write bite code (aka these.pyc files)
ENV PYTHONDONTWRITEBYTECODE=true

###################################################
# Set up the user to use the conda base environment
###################################################
## The user should have full access to the conda base environment, and can use it directly, or
## create new conda environments on top of it. The important part is that jupyter IS NOT installed
## in the base environment to provide isolation between the user environment, and the jupyter server
## to avoid cross-contamination
COPY conda-env.yml .
RUN conda env update --prefix $CONDA_ENV_HOME --file conda-env.yml --prune \
    # Remove packages tarballs and python bytecode files from the image
    && conda clean -afy \
    && rm conda-env.yml \
    # Make sure the JUPYTER_USER is the owner of the folder where
    # the base conda is installed
    && chown -R $JUPYTER_USER:users $JUPYTER_USER_HOME \
    # enable conda libmamba: https://www.anaconda.com/blog/a-faster-conda-for-a-growing-community \
    && conda install -n base conda-libmamba-solver \
    && conda config --set solver libmamba

# Add the user base conda environment as a jupyter kernel - this should be the default now
# This commands activates the conda environment and then calls ipykernel from within
# to install it as a kernel under the same name
RUN conda run -p $CONDA_ENV_HOME python -m ipykernel install --name=$CONDA_ENV_NAME

# Prep the jupyter terminal to conda init and make sure the base conda environment is
# activated and the name is displayed in the terminal prompt
COPY conda_init.txt .
RUN cat conda_init.txt >> $JUPYTER_USER_HOME/.bashrc && \
    printf "\nconda activate ${CONDA_ENV_HOME}" >> $JUPYTER_USER_HOME/.bashrc && \
    conda config --set env_prompt '({name})' && \
    source $JUPYTER_USER_HOME/.bashrc && \
    rm conda_init.txt


##########
# Setup UV
##########
# - Silence uv complaining about not being able to use hard links,
# - tell uv to byte-compile packages for faster application startups,
# - prevent uv from accidentally downloading isolated Python builds,
# - specify Python version
# - don't seed venv with wheel and setuptools, we need to install specific versions
# - don't cache to keep the image size small
# - use system python to avoid installing a new python version
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON=$PYTHON_VERSION \
    UV_VENV_SEED=false \
    UV_NO_CACHE=true \
    UV_SYSTEM_PYTHON=1

###############
# Setup virtualenv
###############
# Using UV (Universal Virtualenv) to create a virtual environment
# UV is used in place of poetry for speed and simplicity.
# NOTE: this is separate from the jupyter user
ENV JUPYTER_HOME=/usr/jupytervenv
ENV VIRTUAL_ENV=$JUPYTER_HOME

COPY uv.lock .
COPY pyproject.toml .

# Add jupyter virtual environment to PATH,
# but make sure to add it at the end so that the
# Conda base python takes precedence
# (aka the ! operator in iPython shells should NOT access the jupyter virtualenvironment)
ENV PATH "${PATH}:${JUPYTER_HOME}/bin"
ENV PATH="/root/.local/bin/:$PATH"

# Download the latest installer
ADD https://astral.sh/uv/install.sh /uv-installer.sh
#--python $BASE_PYTHON_PATH
RUN sh /uv-installer.sh && rm /uv-installer.sh \
    # Create a virtual environment and activate it for UV to use
    && uv venv $JUPYTER_HOME --python $BASE_PYTHON_PATH \
    && source $JUPYTER_HOME/bin/activate \
    && PYTHONEXECUTABLE=/usr/bin/env python3 \
    # Install the python dependencies using uv
     && uv pip install wheel \
     && uv pip install 'setuptools==59.8.0' \
     && uv pip install -r pyproject.toml  --no-cache --no-build-isolation \
    # Cleanup
     && rm uv.lock && rm pyproject.toml
    # Uninstall uv
#     && uv cache clean \
#     && rm ~/.local/bin/uv ~/.local/bin/uvx

# Install nbstripout
RUN nbstripout --install --global

# ##################################
# # Terra-specific Jupyter Utilities
# ##################################
# Ensure this matches c.NotebookApp.port in 'jupyter_notebook_config.py'
ENV JUPYTER_PORT=8000
EXPOSE $JUPYTER_PORT
ENV JUPYTER_KERNELSPEC_DIR=/usr/local/share/jupyter

# Install nbstripout
RUN nbstripout --install --global

# copy workspace_cromwell.py script and make it runnable by all users
RUN curl -o /usr/local/bin/workspace_cromwell.py https://raw.githubusercontent.com/broadinstitute/cromwhelm/1ceedf89587cffd355f37401b179001f029f77ed/scripts/workspace_cromwell.py \
    && chmod +x /usr/local/bin/workspace_cromwell.py

# Copy over custom extensions
COPY scripts $JUPYTER_HOME/scripts
COPY custom $JUPYTER_HOME/custom
COPY jupyter_notebook_config.py $JUPYTER_HOME
RUN chown -R $JUPYTER_USER:users $JUPYTER_HOME

# Remove the jupyter environment from the list of available kernels so it is hidden from the user
# NOTE: This depends on setting the c.KernelSpecManager.ensure_native_kernel flag
# to False in 'jupyter_server_config.py'
#RUN $JUPYTER_HOME/bin/jupyter kernelspec remove python3 -y

 # setup the jupyter kernel
RUN chown -R $JUPYTER_USER:users $JUPYTER_KERNELSPEC_DIR \
    && find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \
    # You can get kernel directory by running `jupyter kernelspec list`
    && $JUPYTER_HOME/scripts/kernel/kernelspec.sh $JUPYTER_HOME/scripts/kernel $JUPYTER_KERNELSPEC_DIR/kernels

# Set up the user and working directory, which is where the persistent disk will be mounted
# this is different from where Jupyter is installed
USER $JUPYTER_USER
WORKDIR $JUPYTER_USER_HOME

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
# .venv/bin/jupyter lab
#ENTRYPOINT ["/usr/jupytervenv/bin/jupyter", "lab"]