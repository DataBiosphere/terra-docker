# Latest gpu-enabled base image on Ubuntu 24, 313MB
FROM --platform=linux/amd64 nvidia/cuda:12.8.1-base-ubuntu24.04

LABEL maintainer="DSP Analysis Team <dsp-analysis@broadinstitute.org>"

# want the command to fail due to an error at any stage in the pipe: https://github.com/hadolint/hadolint/wiki/DL4006
SHELL ["/usr/bin/bash", "-o", "pipefail", "-c"]

#######################
# General Environment Variables
#######################
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8

# Version of python to be installed and used
ENV PYTHON_VERSION=3.10
# Paired conda installer
ENV CONDA_INSTALLER https://repo.anaconda.com/miniconda/Miniconda3-py310_23.5.1-0-Linux-x86_64.sh
ENV JUPYTER_VERSION=5.3.1

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
    # - `tini` is installed as a helpful container entrypoint,
    #   reaps zombie processes and such of the actual executable we want to start
    #   See https://github.com/krallin/tini#why-tini for details
    tini \
    # Uncomment en_US.UTF-8 for inclusion in generation
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    # Generate locale
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

#####################
# Create the Jupyter User
#####################
# Create the jupyter user and give sudo permission
ENV JUPYTER_USER jupyter
ENV JUPYTER_UID 1000
# Create the jupyter user home
ENV JUPYTER_USER_HOME /home/$JUPYTER_USER
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
ENV WELDER_USER welder-user
ENV WELDER_UID 1001
RUN useradd -m  -s /bin/bash -N -u $WELDER_UID $WELDER_USER

############
# Install R
############
RUN apt-get update && apt-get install -y r-base

#############################
# Install Miniconda and setup Python
#############################
## Note: CONDA should NOT be used by terra devs to manage dependencies,
## but is a widely used tool to manage python environments in a runtime and we should provide it to users
## We want to store the user conda environments in a directory that will be in the persistent disk
## Attention: If you change the Conda home location, please update conda_init.txt accordingly
ENV CONDA_ENV_NAME base-python${PYTHON_VERSION}
ENV CONDA_ENV_HOME $JUPYTER_USER_HOME/.envs/$CONDA_ENV_NAME
RUN curl -so $JUPYTER_USER_HOME/miniconda.sh ${CONDA_INSTALLER} \
    && chmod +x $JUPYTER_USER_HOME/miniconda.sh \
    && $JUPYTER_USER_HOME/miniconda.sh -b -p $CONDA_ENV_HOME \
    && rm $JUPYTER_USER_HOME/miniconda.sh
ENV PATH "${PATH}:${CONDA_ENV_HOME}/bin"

# Set up the path to the user python
ENV BASE_PYTHON_PATH $CONDA_ENV_HOME/bin/python
# Tell conda to NOT write bite code (aka these.pyc files)
ENV PYTHONDONTWRITEBYTECODE=true

###################################################
# Set up the user to use the conda base environment
###################################################
## The user should have full access to the conda base environment, and can use it directly, or
## create new conda environments on top of it. The important part is that jupyter IS NOT installed
## in the base environment to provide isolation between the user environment, and the jupyter server
## to avoid cross-contamination
COPY conda-environment.yml .
RUN conda env update --prefix $CONDA_ENV_HOME --file conda-environment.yml --prune \
    # Remove packages tarballs and python bytecode files from the image
    && conda clean -afy \
    && rm conda-environment.yml \
    && conda install jupyter_core==$JUPYTER_VERSION \
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
# - and specify Python version
ENV UV_LINK_MODE=copy \
    UV_COMPILE_BYTECODE=1 \
    UV_PYTHON_DOWNLOADS=never \
    UV_PYTHON='python{$PYTHON_VERSION}' \
    UV_PROJECT_ENVIRONMENT=/usr/local

# Run the UV installer then remove it
RUN curl -LsSf https://astral.sh/uv/install.sh | sh \
    && rm /uv-installer.sh

###############
# Setup virtualenv
###############

ENV JUPYTER_HOME /usr/jupytervenv
# Add jupyter virtual environmemt to PATH,
# but make sure to add it at the end so that the
# Conda base python takes precedence
# (aka the ! operator in iPython shells should NOT access the jupyter virtualenvironment)
ENV PATH "${PATH}:${JUPYTER_HOME}/bin"

RUN uv venv --python $PYTHON_VERSION $JUPYTER_HOME \
    && source $JUPYTER_HOME/bin/activate \

# ##################################
# # Terra-specific Jupyter Utilities
# ##################################
# Ensure this matches c.ServerApp.port in 'jupyter_server_config.py'
ENV JUPYTER_PORT 8000
EXPOSE $JUPYTER_PORT

# Install the custom extensions to enable welder for file syncing
COPY custom $JUPYTER_HOME/etc/jupyter/custom
COPY custom/jupyter_delocalize.py $JUPYTER_HOME/lib/python${PYTHON_VERSION}/site-packages
COPY jupyter_server_config.py $JUPYTER_HOME/etc/jupyter

# Remove the jupyter environment from the list of available kernels so it is hidden from the user
# Note that this needs to be done with setting the c.KernelSpecManager.ensure_native_kernel flag
# to False in 'jupyter_server_config.py'
RUN $JUPYTER_HOME/bin/jupyter kernelspec remove python3 -y

# Copy the script that the service deploying to Terra (e.g. leonardo) will use for docker exec
COPY run-jupyter.sh $JUPYTER_HOME/run-jupyter.sh
RUN chmod +x $JUPYTER_HOME/run-jupyter.sh

# Set up the user and working directory, which is where the persistent disk will be mounted
USER $JUPYTER_USER
WORKDIR $JUPYTER_USER_HOME/persistent_disk

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/usr/local/bin/jupyter-nbclassic"]