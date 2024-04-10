# Smallest image with ubuntu jammy, CUDA and NVDIA drivers installed - 80 mb
FROM --platform=linux/amd64 nvidia/cuda:12.2.0-base-ubuntu22.04

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
# We want to store the user virtual environments in a directory
# that will be in the persistent disk
ENV CONDA_ENV_NAME terra-python3.10
ENV CONDA_ENV_HOME $USER_HOME/.envs/$CONDA_ENV_NAME
RUN mkdir -p $CONDA_ENV_HOME

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

##############################
# Install Python via Miniconda
##############################
## Note: CONDA should not be used by terra devs, but is a widely used tools
## to manage python environments in a runtime and we should provide it to users
ENV CONDA_HOME /opt/conda
RUN curl -so $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py310_23.5.1-0-Linux-x86_64.sh \
    && chmod +x $HOME/miniconda.sh \
    && $HOME/miniconda.sh -b -p $CONDA_HOME \
    && rm $HOME/miniconda.sh
ENV PATH "${PATH}:${CONDA_HOME}/bin"

ENV BASE_PYTHON_PATH /opt/conda/bin/python
ENV PYTHONDONTWRITEBYTECODE=true

################################################
# Install Jupyter in the base python environment
################################################
## POETRY is the prefered tool to create virtual environments and
## manage dependencies - Should be used by Terra devs - poetry docs: https://python-poetry.org/docs/
ENV POETRY_HOME /opt/poetry
# Append POETRY_HOME to PATH
ENV PATH "${PATH}:${POETRY_HOME}/bin"
COPY poetry.lock .
COPY pyproject.toml .

# Install Poetry, set up the base environment for jupyter to run and then cleanup / uninstall poetry
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=$POETRY_HOME $BASE_PYTHON_PATH \
    # Prevent poetry from creating a virtual environment (we want to install on the docker system python)
    && poetry config virtualenvs.create false \
    # Install python dependencies with poetry
    && poetry install --no-dev --no-cache --no-interaction \
    # Cleanup
    && rm poetry.lock && rm pyproject.toml \
    && curl -sSL https://install.python-poetry.org | POETRY_HOME=$POETRY_HOME $BASE_PYTHON_PATH - --uninstall

# Remove the base environment from the list of available kernels so it is hidden from the user
# Note that this needs to be done with setting the c.KernelSpecManager.ensure_native_kernel flag
# to False in 'jupyter_server_config.py'
RUN jupyter kernelspec remove python3 -y

#######################################################
# Create a CONDA virtual environment for user isolation
#######################################################
# Create a new conda environment for the user, activate it, and add it to the list of python kernels
# This step is a bit slow to build, but worth it to provide the user with an isolated environment
COPY conda-environment.yml .
RUN conda env create -f conda-environment.yml --prefix=$CONDA_ENV_HOME\
    # Remove packages tarballs and python bytecode files from the image
    && conda clean -afy \
    && find $CONDA_ENV_HOME -follow -type f -name '*.pyc' -delete \
    && rm conda-environment.yml
# Add the user conda environment as a jupyter kernel - this should be the default now
# This commands activates the conda environment and then calls ipykernel from within
# to install it as a kernel under the same name
RUN conda run -p ${CONDA_ENV_HOME} python -m ipykernel install --user --name=$CONDA_ENV_NAME

# Automagically activate the user conda environment when opening the jupyter terminal
COPY conda_init.txt .
RUN cat conda_init.txt >> ~/.bashrc && \
    printf "\nconda activate ${CONDA_ENV_HOME}" >> ~/.bashrc && \
    conda config --set env_prompt '({name})' && \
    echo "auto_activate_base: false" >> ~/.condarc && \
    rm conda_init.txt

# ##################################
# # Terra-specific Jupyter Utilities
# ##################################
# Ensure this matches c.ServerApp.port in 'jupyter_server_config.py'
ENV JUPYTER_PORT 8888
EXPOSE $JUPYTER_PORT
ENV JUPYTER_HOME /etc/jupyter

# Install the custom extensions to enable welder for file syncing
COPY custom $JUPYTER_HOME/custom
ENV PYTHON_LIBRARIES_PATH $CONDA_HOME/lib/python3.10/site-packages
COPY custom/jupyter_delocalize.py $PYTHON_LIBRARIES_PATH
COPY jupyter_server_config.py $JUPYTER_HOME

# Disable the use of system shell commands in the notebook to avoid users
# interacting with our base python via the notebook
ENV IPYTHON_HOME /etc/ipython/
COPY ipython_config.py $IPYTHON_HOME

# Set up the working directory to be /home/jupyter, and make sure the
# shell is bash, like the jupyter terminal (just nicer to work with than sh)
WORKDIR $USER_HOME
ENV SHELL /usr/bin/bash
SHELL ["/usr/bin/bash", "-c"]
RUN source ~/.bashrc

# Copy the script that the service deploying to Terra (e.g. leonardo) will use for docker exec
COPY run-jupyter.sh $JUPYTER_HOME/run-jupyter.sh
# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/opt/conda/bin/jupyter", "lab"]