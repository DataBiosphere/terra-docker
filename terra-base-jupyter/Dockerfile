# Smallest image with ubuntu jammy, CUDA and NVDIA drivers installed - 80 mb
FROM --platform=linux/amd64 nvidia/cuda:12.2.0-base-ubuntu22.04

# Use bash as the shell, like the jupyter terminal (just nicer to work with than sh)
ENV SHELL /usr/bin/bash
SHELL ["/usr/bin/bash", "-c"]

#######################
# Environment Variables
#######################
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8

# We need node >18 for jupyter to work
ENV NODE_MAJOR 20

#############
# Users Setup
#############
# Create the jupyter home directories where they will save their
# notebooks and install their conda environments
# Note that there is no jupyter user created, the intent is to run this docker
# container as root
ENV USER_HOME /home/jupyter
RUN mkdir $USER_HOME
# We want to store the user conda environments in a directory
# that will be in the persistent disk
ENV CONDA_ENV_NAME base-python3.10
ENV CONDA_ENV_HOME $USER_HOME/.envs/$CONDA_ENV_NAME

# Create the welder user
# The welder uid is consistent with the Welder docker definition here:
#  https://github.com/DataBiosphere/welder/blob/master/project/Settings.scala
# Adding welder-user to the Jupyter container isn't strictly required, but it makes welder-added
# files display nicer when viewed in a terminal.
ENV WELDER_USER welder-user
ENV WELDER_UID 1001
RUN useradd -m -s /bin/bash -N -u $WELDER_UID $WELDER_USER

###############
# Prerequisites
###############
RUN apt-get update && apt-get install -yq --no-install-recommends \
    sudo \
    ca-certificates \ 
    curl \
    jq \
    # gnupg requirement
    gnupg \
    dirmngr \
    # useful utilities for debugging within the docker
    nano \
    procps \
    lsb-release \
    # python requirements
    checkinstall \
    build-essential \
    zlib1g-dev \
    # pip requirements
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libexempi8 \
    libnode-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    # install script requirements
    locales \
    # for ssh-agent and ssh-add
    keychain \
    # extras \
    wget \
    bzip2 \
    # git
    git \
    # Uncomment en_US.UTF-8 for inclusion in generation
    && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
    # Generate locale
    && locale-gen \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install Node >18 (needed for jupyterlab)
RUN apt-get update && apt-get install -yq --no-install-recommends 
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN dpkg --remove --force-remove-reinstreq libnode-dev
RUN apt-get update && apt-get install -f -yq nodejs

#####################################
# Install Python 3.10 via Miniconda
#####################################
## Note: CONDA should NOT be used by terra devs to manage dependencies (see the use of poetry below instead),
## but is a widely used tool to manage python environments in a runtime and we should provide it to users
RUN curl -so $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py310_23.5.1-0-Linux-x86_64.sh \
    && chmod +x $HOME/miniconda.sh \
    && $HOME/miniconda.sh -b -p $CONDA_ENV_HOME \
    && rm $HOME/miniconda.sh
ENV PATH "${PATH}:${CONDA_ENV_HOME}/bin"

ENV BASE_PYTHON_PATH $CONDA_ENV_HOME/bin/python
ENV PYTHONDONTWRITEBYTECODE=true

###################################################
# Set up the user to use the conda base environment
###################################################
## The user should have full access to the conda base environment, and can use it directly, or
## create new conda environments on top of it. The important part is that jupyter IS NOT installed
## in the base environment to provide isolation between the user environment, and the jupyter server
## to avoid cross-contamination
COPY conda-environment.yml .
RUN conda env update --prefix $CONDA_ENV_HOME --file conda-environment.yml --prune\
    # Remove packages tarballs and python bytecode files from the image
    && conda clean -afy \
    && find $CONDA_ENV_HOME -follow -type f -name '*.pyc' -delete \
    && rm conda-environment.yml

# Add the user base conda environment as a jupyter kernel - this should be the default now
# This commands activates the conda environment and then calls ipykernel from within
# to install it as a kernel under the same name
RUN conda run -p ${CONDA_ENV_HOME} python -m ipykernel install --user --name=$CONDA_ENV_NAME

# Prep the jupyter terminal to conda init and make sure the base conda environment is 
# activated and the name is displayed in the terminal prompt
COPY conda_init.txt .
RUN cat conda_init.txt >> ~/.bashrc && \
    printf "\nconda activate ${CONDA_ENV_HOME}" >> ~/.bashrc && \
    conda config --set env_prompt '({name})' && \
    source ~/.bashrc && \
    rm conda_init.txt

####################################################
# Install Jupyter in an isolated virtual environment
####################################################
## Virtualenv and POETRY are the prefered tool to create virtual environments and
## manage dependencies for Terra Devs - poetry docs: https://python-poetry.org/docs/
ENV POETRY_HOME /opt/poetry
# Append POETRY_HOME to PATH
ENV PATH "${PATH}:${POETRY_HOME}/bin"
COPY poetry.lock .
COPY pyproject.toml .

ENV JUPYTER_VIRTUAL_ENV=/usr/jupytervenv
# Add jupyter virtual environmemt to PATH
ENV PATH="$JUPYTER_VIRTUAL_ENV/bin:$PATH"

# Install Poetry, set up the virtual environment for jupyter to run and then cleanup / uninstall poetry
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=$POETRY_HOME $BASE_PYTHON_PATH \
    # Create a virtual environment and activate it for poetry to use
    && $BASE_PYTHON_PATH -m venv $JUPYTER_VIRTUAL_ENV \
    && source activate $JUPYTER_VIRTUAL_ENV \
    # Install python dependencies with poetry
    && poetry install --no-interaction --no-ansi --no-dev --no-cache \
    # Cleanup
    && rm poetry.lock && rm pyproject.toml \
    && curl -sSL https://install.python-poetry.org | POETRY_HOME=$POETRY_HOME $BASE_PYTHON_PATH - --uninstall

# ##################################
# # Terra-specific Jupyter Utilities
# ##################################
# Ensure this matches c.ServerApp.port in 'jupyter_server_config.py'
ENV JUPYTER_PORT 8888
EXPOSE $JUPYTER_PORT
ENV JUPYTER_HOME  $JUPYTER_VIRTUAL_ENV/etc/jupyter

# Install the custom extensions to enable welder for file syncing
# This can be done for system python packages so that they are always found
COPY custom $JUPYTER_HOME/custom
COPY custom/jupyter_delocalize.py $JUPYTER_VIRTUAL_ENV/lib/python3.10/site-packages
COPY jupyter_server_config.py $JUPYTER_HOME

# Remove the jupyter environment from the list of available kernels so it is hidden from the user
# Note that this needs to be done with setting the c.KernelSpecManager.ensure_native_kernel flag
# to False in 'jupyter_server_config.py'
RUN jupyter kernelspec remove python3 -y

# Set up the working directory to be /home/jupyter
WORKDIR $USER_HOME

# Copy the script that the service deploying to Terra (e.g. leonardo) will use for docker exec
COPY run-jupyter.sh $JUPYTER_HOME/run-jupyter.sh
# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/usr/jupytervenv/bin/jupyter", "lab"]