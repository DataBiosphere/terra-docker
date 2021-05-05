# adapted from https://hub.docker.com/r/jupyter/base-notebook/ AKA https://github.com/jupyter/docker-stacks/tree/master/base-notebook

FROM marketplace.gcr.io/google/ubuntu1804:latest
USER root

#######################
# Prerequisites
#######################
ENV DEBIAN_FRONTEND noninteractive

RUN apt-get update && apt-get install -yq --no-install-recommends \

    # gnupg requirement
    dirmngr \
    gnupg \

    # curl requirement
    ca-certificates \
    curl \

    # google-cloud-sdk requirement
    lsb-release \
    gcc-6 \
    gcc-8 \

    # useful utilities for debugging within the docker
    unzip \
    nano \
    vim \
    procps \

    # python requirements
    checkinstall \
    build-essential \
    zlib1g-dev \

    # pip requirements
    libssl1.0-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python-openssl \

    # install script requirements
    sudo \
    wget \
    locales \
    git \
    jq \

    # for ssh-agent and ssh-add
    keychain \

    # for jupyterlab extensions
    nodejs-dev \
    node-gyp \
    npm \

    # openjdk 11
    default-jre \
    default-jdk \

 # Uncomment en_US.UTF-8 for inclusion in generation
 && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
 # Generate locale
 && locale-gen \

 # google-cloud-sdk separately because it need lsb-release and other prereqs installed above
 && export CLOUD_SDK_REPO="cloud-sdk-$(lsb_release -c -s)" \
 && echo "deb http://packages.cloud.google.com/apt $CLOUD_SDK_REPO main" > /etc/apt/sources.list.d/google-cloud-sdk.list \
 && curl https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add - \
 && apt-get update \
 && apt-get install -yq --no-install-recommends \
    google-cloud-sdk \

 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV LC_ALL en_US.UTF-8

#######################
# Python / Jupyter
#######################

ENV USER jupyter-user
ENV UID 1000
RUN useradd -m -s /bin/bash -N -u $UID $USER

ENV HOME /home/$USER

# The welder uid is consistent with the Welder docker definition here:
#  https://github.com/DataBiosphere/welder/blob/master/project/Settings.scala
# Adding welder-user to the Jupyter container isn't strictly required, but it makes welder-added
# files display nicer when viewed in a terminal.
ENV WELDER_USER welder-user
ENV WELDER_UID 1001
RUN useradd -m -s /bin/bash -N -u $WELDER_UID $WELDER_USER

# ensure this matches c.NotebookApp.port in jupyter_notebook_config.py
ENV JUPYTER_PORT 8000
ENV JUPYTER_HOME /etc/jupyter
ENV USER_INSTALL_DIR /home/jupyter-user/notebooks/packages

# Prepend existing PYTHONPATH if it's not empty; otherwise prepend it
ENV PYTHONPATH ${PYTHONPATH:+$PYTHONPATH:}$JUPYTER_HOME/custom:$USER_INSTALL_DIR
ENV PATH ${PATH:+$PATH:}$USER_INSTALL_DIR/bin

# # Python3, kernel, and pip
RUN apt update \
   && apt install -yq software-properties-common \
   && add-apt-repository ppa:deadsnakes/ppa \
   && apt install -yq python3.7-dev \
   && update-alternatives --install /usr/local/bin/python3 python3 /usr/bin/python3.7 1 \
   && apt-get -yq install python3-pip \
   && /usr/local/bin/python3 -m pip install --upgrade pip

RUN pip3 -V \
 # When we upgraded from jupyter 5.7.8 to 6.1.1, we broke terminal button on terra-ui.
 # Hence, make sure to manually test out "launch terminal" button (the button in the green bar next to start and stop buttons)
 # to make sure we don't accidentally break it every time we upgrade notebook version until we figure out an automation test for this
 && pip3 install notebook==6.1.1 \
 && pip3 install jupyter==1.0.0 \
 && pip3 install python-datauri \
 && pip3 install jupyterlab==0.35.4 \
 && pip3 install cookiecutter \
 && pip3 install jupyter_contrib_nbextensions \
 && pip3 install jupyter_nbextensions_configurator \
 # for jupyter_delocalize.py and jupyter_notebook_config.py
 && pip3 install tornado==5.1.1 \
 && pip3 install requests \
 && pip3 install six==1.15.0 \
 && pip3 install firecloud==0.16.25 \
 && pip3 install terra-notebook-utils==0.7.0 \
 && pip3 install crcmod \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# tmp hack min-5
# I'm not installing jupyterlab and I can't update init-actions.sh to not access it
RUN mkdir -p /usr/local/share/jupyter/lab

# make pip install to a user directory, instead of a system directory which requires root.
# this is useful so `pip install` commands can be run in the context of a notebook.
ENV PIP_USER=true
# When using PIP_USER=true packages are installed into Python site.USER_BASE, which is '/home/jupyter-user' for this system.
# Append '/home/jupyter-user/.local/bin' to PATH
# pip docs: https://pip.pypa.io/en/stable/reference/pip_install/#cmdoption-user
ENV PATH="${PATH}:/home/jupyter-user/.local/bin"

# Default terminal directory should be where PD is mounted
RUN echo 'cd /home/jupyter-user/notebooks' >> /home/jupyter-user/.bashrc

#######################
# Utilities
#######################

COPY scripts $JUPYTER_HOME/scripts
COPY custom $JUPYTER_HOME/custom
COPY jupyter_notebook_config.py $JUPYTER_HOME

RUN chown -R $USER:users $JUPYTER_HOME \
 && chown -R $USER:users /usr/local/share/jupyter/lab \
 && find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-6 200 \
 && update-alternatives --install /usr/bin/gcc gcc /usr/bin/gcc-8 100 \
 && $JUPYTER_HOME/scripts/extension/install_jupyter_contrib_nbextensions.sh \
 && mkdir $HOME/.jupyter/custom/ \
 && cp $JUPYTER_HOME/custom/google_sign_in.js $HOME/.jupyter/custom/ \
 && cp $JUPYTER_HOME/custom/extension_entry_jupyter.js $HOME/.jupyter/custom/custom.js \
 && cp $JUPYTER_HOME/custom/safe-mode.js $HOME/.jupyter/custom/ \
 && cp $JUPYTER_HOME/custom/edit-mode.js $HOME/.jupyter/custom/ \
 && mkdir $JUPYTER_HOME/nbconfig \
 && $JUPYTER_HOME/scripts/kernel/kernelspec.sh $JUPYTER_HOME/scripts/kernel /usr/local/share/jupyter/kernels

USER $USER
WORKDIR $HOME

EXPOSE $JUPYTER_PORT

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/usr/local/bin/jupyter", "notebook"]
