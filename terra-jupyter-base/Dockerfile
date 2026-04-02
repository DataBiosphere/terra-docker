FROM --platform=linux/amd64 us.gcr.io/broad-dsp-gcr-public/terra-base:1.0.1

USER root

#######################
# Prerequisites
#######################
ENV DEBIAN_FRONTEND noninteractive

# Some of the packages from the old deepleaning image in terra-base
# this is an attempt to keep compatibility with the old image
RUN apt-get update && apt-get install -yq --no-install-recommends \
    # packages from terra-jupyter-base missing in terra-base \
    checkinstall \
    zlib1g-dev \
    libssl-dev \
    libbz2-dev \
    libreadline-dev \
    libsqlite3-dev \
    libnvinfer8 \
    libnvinfer-plugin8 \
    python3-libnvinfer \
    llvm \
    libncurses5-dev \
    libncursesw5-dev \
    tk-dev \
    libffi-dev \
    liblzma-dev \
    python3-openssl \
    default-jre \
    default-jdk \
    apt-transport-https \
    apt-utils \
    blt \
    bsdextrautils \
    cpp-12 \
    dctrl-tools \
    dialog \
    dkms \
    emacs \
    emacs-bin-common \
    emacs-common \
    emacs-gtk \
    emacsen-common \
    fonts-lmodern \
    fuse \
    gcc-12 \
    groff-base \
    hdf5-helpers \
    htop \
    inotify-tools \
    install-info \
    kmod \
    libaec-dev \
    libaec0 \
    libasan8 \
    libcmark-gfm-extensions0.29.0.gfm.3 \
    libcmark-gfm0.29.0.gfm.3 \
    libcurl4-openssl-dev \
    libevent-core-2.1-7 \
    libfuse2 \
    libgcc-12-dev \
    libgd3 \
    libgpm2 \
    libhdf5-103-1 \
    libhdf5-cpp-103-1 \
    libhdf5-dev \
    libhdf5-fortran-102 \
    libhdf5-hl-100 \
    libhdf5-hl-cpp-100 \
    libhdf5-hl-fortran-100 \
    libibverbs1 \
    libinotifytools0 \
    libjansson4 \
    libkpathsea6 \
    libm17n-0 \
    libnl-3-200 \
    libnl-genl-3-200 \
    libnl-route-3-200 \
    libnuma-dev \
    libnuma1 \
    libopenblas-base \
    libopenblas0 \
    libopenblas0-pthread \
    libotf1 \
    libpci3 \
    libpipeline1 \
    libpopt0 \
    libprotobuf23 \
    libprotoc23 \
    libptexenc1 \
    libpython3.10 \
    libsnappy-dev \
    libsnappy1v5 \
    libsodium23 \
    libsynctex2 \
    libsz2 \
    libteckit0 \
    libtexlua53 \
    libtexluajit2 \
    libtsan2 \
    libuchardet0 \
    libutempter0 \
    libzzip-0-13 \
    m17n-db \
    man-db \
    pandoc \
    pandoc-data \
    pci.ids \
    pciutils \
    pkg-config \
    protobuf-compiler \
    python3-distutils \
    python3-lib2to3 \
    python3-libnvinfer \
    python3-pip \
    python3-setuptools \
    python3-snappy \
    python3-tk \
    python3-wheel \
    rsync \
    screen \
    t1utils \
    tex-common \
    texlive \
    texlive-base \
    texlive-binaries \
    texlive-fonts-recommended \
    texlive-latex-base \
    texlive-latex-recommended \
    tk8.6-blt2.5 \
    tmux \
    tree \
    vim \
    vim-common \
    vim-runtime \
    xxd \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV LC_ALL en_US.UTF-8

##############################################
# Install Python packages to the conda env
##############################################

# Copy image pyproject.toml and workspace uv.lock for reproducible builds
COPY terra-jupyter-base/pyproject.toml ./
COPY uv.lock ./

RUN uv pip install --python ${CONDA_ENV_HOME}/bin/python -r pyproject.toml --no-cache \
    && rm pyproject.toml uv.lock


# make pip install to a user directory, instead of a system directory which requires root.
# this is useful so `pip install` commands can be run in the context of a notebook.
ENV USER=jupyter
ENV PIP_USER=true

ENTRYPOINT ["/etc/jupyter/bin/jupyter", "notebook"]