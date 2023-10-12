# Smallest image with ubuntu jammy, CUDA and NVDIA drivers installed - 80 mb
FROM --platform=linux/amd64 nvidia/cuda:12.2.0-base-ubuntu22.04

#######################
# Environment Variables
#######################
ENV DEBIAN_FRONTEND noninteractive
ENV LC_ALL en_US.UTF-8
ENV USER jupyter
ENV HOME /home/$USER
# Ensure this matches c.NotebookApp.port in jupyter_notebook_config.py
ENV JUPYTER_PORT 8000
ENV JUPYTER_HOME /etc/jupyter
ENV JUPYTER_KERNELSPEC_DIR /usr/local/share/jupyter
# The welder uid is consistent with the Welder docker definition here:
#  https://github.com/DataBiosphere/welder/blob/master/project/Settings.scala
# Adding welder-user to the Jupyter container isn't strictly required, but it makes welder-added
# files display nicer when viewed in a terminal.
ENV WELDER_USER welder-user
ENV WELDER_UID 1001
# When using PIP_USER=true packages are installed into Python site.USER_BASE, which is '/home/jupyter' for this system.
# Append '/home/jupyter/.local/bin' to PATH
# pip docs: https://pip.pypa.io/en/stable/reference/pip_install/#cmdoption-user
ENV PATH "${PATH}:${HOME}/.local/bin:${HOME}/packages/bin:${POETRY_DIR}/bin"
# We need node >18 for jupyter to work
ENV NODE_MAJOR 20

#######################
# Users Setup
#######################
RUN useradd -m -s /bin/bash $USER
RUN usermod -g users $USER
RUN useradd -m -s /bin/bash -N -u $WELDER_UID $WELDER_USER

#######################
# Prerequisites
#######################
RUN apt-get update && apt-get install -yq --no-install-recommends \
    sudo \
    ca-certificates \ 
    curl \
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

RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
RUN curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | sudo apt-key add -

# Install Node >18
RUN apt-get update && apt-get install -yq --no-install-recommends 
RUN sudo mkdir -p /etc/apt/keyrings
RUN curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | sudo gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg

RUN echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_$NODE_MAJOR.x nodistro main" | sudo tee /etc/apt/sources.list.d/nodesource.list
RUN sudo dpkg --remove --force-remove-reinstreq libnode-dev
RUN sudo apt-get update && apt-get install -f -yq nodejs

########################################
# Manage python dependencies with poetry
########################################
# Install Python 3.10 and add to python path
RUN apt-get update && apt-get install -y python3.10 python3-pip
RUN update-alternatives --install /usr/bin/python python /usr/bin/python3.10 1 \
    && update-alternatives --set python /usr/bin/python3.10

# Install Poetry
RUN curl -sSL https://install.python-poetry.org | python3

# Prevent poetry from creating a virtual environment (we want to install on the docker system python)
RUN poetry config virtualenvs.create false

# Install python dependencies with poetry
COPY poetry.lock .
COPY pyproject.toml .
RUN poetry install --no-root --no-cache --no-interaction

# #######################
# # Utilities
# #######################
COPY scripts $JUPYTER_HOME/scripts
COPY custom $JUPYTER_HOME/custom
COPY jupyter_notebook_config.py $JUPYTER_HOME

# copy workspace_cromwell.py script and make it runnable by all users
RUN curl -o /usr/local/bin/workspace_cromwell.py https://raw.githubusercontent.com/broadinstitute/cromwhelm/1ceedf89587cffd355f37401b179001f029f77ed/scripts/workspace_cromwell.py \
    && chmod +x /usr/local/bin/workspace_cromwell.py

RUN chown -R $USER:users $JUPYTER_KERNELSPEC_DIR \
    && find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \
    # You can get kernel directory by running `jupyter kernelspec list`
    && $JUPYTER_HOME/scripts/kernel/kernelspec.sh $JUPYTER_HOME/scripts/kernel $JUPYTER_KERNELSPEC_DIR/kernels

# Make sure that the jupyter user will have access to the jupyter path in the worksing directory
EXPOSE $JUPYTER_PORT
WORKDIR $HOME
RUN sudo chown -R $USER:users $HOME/.local/share

# make pip install to a user directory, instead of a system directory which requires root.
# this is useful so `pip install` commands can be run in the context of a notebook.
ENV PIP_USER true
USER $USER

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["jupyter", "notebook"]