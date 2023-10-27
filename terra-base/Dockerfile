# Smallest image with ubuntu jammy, CUDA and NVDIA drivers installed - 80 mb
FROM --platform=linux/amd64 nvidia/cuda:12.2.0-base-ubuntu22.04

#######################
# Environment Variables
#######################
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
# Ensure this matches c.NotebookApp.port in jupyter_notebook_config.py
ENV JUPYTER_PORT 8000
ENV JUPYTER_HOME /etc/jupyter
ENV JUPYTER_KERNELSPEC_DIR /usr/local/share/jupyter
# We need node >18 for jupyter to work
ENV NODE_MAJOR 20

#######################
# Users Setup
#######################
# Create the jupyter user, add it to the `users` group and specify the home directory path
ENV USER jupyter
ENV USER_HOME /home/$USER
RUN useradd -m -s /bin/bash -d $USER_HOME -N -g users $USER
# Create the welder user
# The welder uid is consistent with the Welder docker definition here:
#  https://github.com/DataBiosphere/welder/blob/master/project/Settings.scala
# Adding welder-user to the Jupyter container isn't strictly required, but it makes welder-added
# files display nicer when viewed in a terminal.
ENV WELDER_USER welder-user
ENV WELDER_UID 1001
RUN useradd -m -s /bin/bash -N -u $WELDER_UID $WELDER_USER

# We want to grant the jupyter user limited sudo permissions
# without password so they can install the necessary packages that they 
# want to use on the docker container
RUN mkdir -p /etc/sudoers.d \
        && echo "$USER ALL=(ALL) NOPASSWD: /usr/bin/apt-get install *, /opt/conda/bin/conda install *, /opt/poetry/bin/poetry install" > /etc/sudoers.d/$USER \
        && chmod 0440 /etc/sudoers.d/$USER

#######################
# Prerequisites
#######################
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

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -

# Install Node >18 (needed for jupyterlab)
RUN apt-get update && apt-get install -yq --no-install-recommends 
RUN mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list
RUN dpkg --remove --force-remove-reinstreq libnode-dev
RUN apt-get update && apt-get install -f -yq nodejs

############
# Install R
############
RUN apt-get update && apt-get install -y r-base

################
# Install Python
################
# Install Python 3.10 and add to system python path
# Note that miniconda does come with it's own installation of python,
# but it is cleaner to do a proper system instalation here and set the 
# path properly
RUN apt-get update && apt-get install -y python3.10 python3-pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && update-alternatives --set python /usr/bin/python3.10

############################
# Manage python dependencies
############################
## POETRY is the prefered tool to create virtual environments and
## manage dependencies - Should be used by Terra devs
# Install Poetry
ENV POETRY_HOME /opt/poetry
RUN curl -sSL https://install.python-poetry.org | POETRY_HOME=$POETRY_HOME python3
# Append '/home/jupyter/.local/bin' to PATH
# poetry docs: https://python-poetry.org/docs/
ENV PATH "${PATH}:${POETRY_HOME}/bin"

# Prevent poetry from creating a virtual environment (we want to install on the docker system python)
RUN poetry config virtualenvs.create false

# Install python dependencies with poetry
COPY poetry.lock .
COPY pyproject.toml .
RUN poetry install --no-cache --no-interaction

###################
# Install Miniconda
###################
## CONDA should not be used by terra devs, but is a widely used tools
## to manage python environments in a runtime and we should provide it to users
ENV CONDA_HOME /opt/conda
RUN curl -so $HOME/miniconda.sh https://repo.anaconda.com/miniconda/Miniconda3-py310_23.5.1-0-Linux-x86_64.sh \
    && chmod +x $HOME/miniconda.sh \
    && $HOME/miniconda.sh -b -p $CONDA_HOME \
    && rm $HOME/miniconda.sh
ENV PATH "${PATH}:${CONDA_HOME}/bin"

# #######################
# # Utilities
# #######################
COPY scripts $JUPYTER_HOME/scripts
COPY custom $JUPYTER_HOME/custom
COPY jupyter_notebook_config.py $JUPYTER_HOME
RUN chown -R $USER:users $JUPYTER_HOME

# copy workspace_cromwell.py script and make it runnable by all users
RUN curl -o /usr/local/bin/workspace_cromwell.py https://raw.githubusercontent.com/broadinstitute/cromwhelm/1ceedf89587cffd355f37401b179001f029f77ed/scripts/workspace_cromwell.py \
    && chmod +x /usr/local/bin/workspace_cromwell.py

RUN chown -R $USER:users $JUPYTER_KERNELSPEC_DIR \
    && find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \
    # You can get kernel directory by running `jupyter kernelspec list`
    && $JUPYTER_HOME/scripts/kernel/kernelspec.sh $JUPYTER_HOME/scripts/kernel $JUPYTER_KERNELSPEC_DIR/kernels

# Make sure that the jupyter user will have access to the jupyter path in the working directory
EXPOSE $JUPYTER_PORT
WORKDIR $USER_HOME

# make pip install to a user directory, instead of a system directory which requires root.
# this is useful so `pip install` commands can be run in the context of a notebook.
ENV PIP_USER true
USER $USER

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/usr/local/bin/jupyter-notebook"]