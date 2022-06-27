# adapted from https://hub.docker.com/r/jupyter/base-notebook/ AKA https://github.com/jupyter/docker-stacks/tree/master/base-notebook

FROM gcr.io/deeplearning-platform-release/tf-gpu.2-7

USER root

#######################
# Prerequisites
#######################
ENV DEBIAN_FRONTEND noninteractive

RUN sudo -i \
    echo "deb http://security.ubuntu.com/ubuntu/ bionic main" >> /etc/apt/sources.list \
    sudo apt update libexempi3

RUN sudo -i \
    echo "deb http://us.archive.ubuntu.com/ubuntu/ bionic universe" >> /etc/apt/sources.list \
    sudo apt update libv8-3.14-dev

# nvidia is updating and rotating the signing keys used by the apt, dnf/yum, and zypper package managers beginning April 27, 2022
# see article: https://developer.nvidia.com/blog/updating-the-cuda-linux-gpg-repository-key/
# first we remove the bad keys from base image (https://github.com/NVIDIA/nvidia-docker/issues/1631#issuecomment-1112828208)
RUN rm /etc/apt/sources.list.d/cuda.list \
    && rm /etc/apt/sources.list.d/nvidia-ml.list \
    && sudo apt-key del 7fa2af80 \
    && curl -L -O https://developer.download.nvidia.com/compute/cuda/repos/ubuntu2004/x86_64/cuda-keyring_1.0-1_all.deb \
    && sudo dpkg -i cuda-keyring_1.0-1_all.deb

RUN apt-get update && apt-get install -yq --no-install-recommends \
    # gnupg requirement
    dirmngr \
    gnupg \
    # curl requirement
    ca-certificates \
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
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python-openssl \
    libexempi3 \
    libv8-3.14-dev \
    # install script requirements
    sudo \
    locales \
    # for ssh-agent and ssh-add
    keychain \
    # openjdk 11
    default-jre \
    default-jdk \
 # Uncomment en_US.UTF-8 for inclusion in generation
 && sed -i 's/^# *\(en_US.UTF-8\)/\1/' /etc/locale.gen \
 # Generate locale
 && locale-gen \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

ENV LC_ALL en_US.UTF-8

#######################
# Python / Jupyter
#######################

ENV USER jupyter
RUN usermod -g users jupyter
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

RUN pip3 -V \
 # When we upgraded from jupyter 5.7.8 to 6.1.1, we broke terminal button on terra-ui.
 # Hence, make sure to manually test out "launch terminal" button (the button in the green bar next to start and stop buttons)
 # to make sure we don't accidentally break it every time we upgrade notebook version until we figure out an automation test for this
 && pip3 install python-datauri \
 && pip3 install jupyter_contrib_nbextensions \
 && pip3 install jupyter_nbextensions_configurator \
 && pip3 install markupsafe==2.0.1 \
 # Avoid broken lower versions: https://github.com/jupyter/nbconvert/pull/1624
 && pip3 install "nbconvert>=6.4.5" \
 # for jupyter_delocalize.py and jupyter_notebook_config.py
 && pip3 install requests \
 && pip3 install firecloud \
 && pip3 install terra-notebook-utils \
 && pip3 install crcmod \
 # For gcloud alpha storage support.
 && pip3 install google-crc32c --target /usr/lib/google-cloud-sdk/lib/third_party

# install Cromshell 2.0
RUN git clone https://github.com/broadinstitute/cromshell.git \
 && cd cromshell \
 && git checkout cromshell_2.0 \
 && pip install .

# verify cromshell 2.0 is installed
RUN cromshell-alpha version

# tmp hack min-5
# I'm not installing jupyterlab and I can't update init-actions.sh to not access it
RUN mkdir -p /usr/local/share/jupyter/lab

# make pip install to a user directory, instead of a system directory which requires root.
# this is useful so `pip install` commands can be run in the context of a notebook.
ENV PIP_USER=true
# When using PIP_USER=true packages are installed into Python site.USER_BASE, which is '/home/jupyter' for this system.
# Append '/home/jupyter/.local/bin' to PATH
# pip docs: https://pip.pypa.io/en/stable/reference/pip_install/#cmdoption-user
ENV PATH="${PATH}:${HOME}/.local/bin:${HOME}/packages/bin"

#######################
# Utilities
#######################

COPY scripts $JUPYTER_HOME/scripts
COPY custom $JUPYTER_HOME/custom
COPY jupyter_notebook_config.py $JUPYTER_HOME

# copy workspace_cromwell.py script and make it runnable by all users
RUN curl -o /usr/local/bin/workspace_cromwell.py https://raw.githubusercontent.com/broadinstitute/cromwhelm/1ceedf89587cffd355f37401b179001f029f77ed/scripts/workspace_cromwell.py \
 && chmod +x /usr/local/bin/workspace_cromwell.py

RUN chown -R $USER:users $JUPYTER_HOME \
# Disable nb_conda for now. Consider re-enable in the future
 && jupyter nbextension disable nb_conda --py --sys-prefix \
 && find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \
#  You can get kernel directory by running `jupyter kernelspec list`
 && $JUPYTER_HOME/scripts/kernel/kernelspec.sh $JUPYTER_HOME/scripts/kernel /opt/conda/share/jupyter/kernels

USER $USER
EXPOSE $JUPYTER_PORT
WORKDIR $HOME

# Note: this entrypoint is provided for running Jupyter independently of Leonardo.
# When Leonardo deploys this image onto a cluster, the entrypoint is overwritten to enable
# additional setup inside the container before execution.  Jupyter execution occurs when the
# init-actions.sh script uses 'docker exec' to call run-jupyter.sh.
ENTRYPOINT ["/opt/conda/bin/jupyter", "notebook"]
