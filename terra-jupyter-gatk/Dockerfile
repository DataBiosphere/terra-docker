ARG BASE_PLATFORM=linux/amd64
FROM --platform=${BASE_PLATFORM} us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:2.1.1 AS python

FROM --platform=${BASE_PLATFORM} us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:3.1.0

USER root

SHELL ["/usr/bin/bash", "-o", "pipefail", "-c"]

# terra-jupyter-r 3.0.0 is built on terra-jupyter-base 2.0.1 (nvidia/cuda Ubuntu 26.04, conda Python 3.13 env
# at $CONDA_ENV_HOME, R 4.6.1, OpenJDK 25 as the default java).
#
# GATK 4.7 needs Java 17. Ubuntu 26.04's default java is 25, so make Java 17 the default for the whole image
# (GATK, Picard jars run directly, Nextflow, which runs on 17+).
# Setting JAVA_HOME / PATH is not enough on a Terra runtime: Leonardo's jupyter-docker-compose-gce.yaml replaces
# the container's PATH with a fixed list without $JAVA_HOME/bin, so `java` there is always /usr/bin/java. The
# alternatives below point /usr/bin/java (and javac, keytool, ...) at Java 17.
ENV JAVA_HOME=/usr/lib/jvm/java-17-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

ENV PIP_USER=false

# Package names verified against Ubuntu 26.04 (resolute).
# Entries that are commented out are kept for reference with the reason they were dropped.
RUN apt-get update && apt-get install -yq --no-install-recommends \
  openjdk-17-jdk-headless \
  git-lfs \
  liblzo2-dev \
  # clears the executable-stack flag on libraries in the gatk conda env (see below) \
  patchelf \
  ########## Removed / redundant on Ubuntu 26.04 ##########
  # python-tk: no longer exists, python3-tk is installed in terra-jupyter-base \
  # python-tk \
  # libz-dev: virtual package with no candidate, zlib1g-dev replaces it \
  # libz-dev \
  # installed in terra-jupyter-base (as are the htslib build deps for samtools / bcftools below: \
  # libbz2-dev, liblzma-dev, libcurl4-openssl-dev, libncurses-dev) \
  # tk-dev \
  # libssl-dev \
  # xz-utils \
  # libhdf5-dev \
  # openssl \
  # make \
  # zlib1g-dev \
  # Java 17 has a lower alternatives priority than 25, so set every alternative it provides explicitly
  && for tool in $JAVA_HOME/bin/*; do \
       name=$(basename "$tool"); \
       if update-alternatives --list "$name" 2>/dev/null | grep -qx "$tool"; then \
         update-alternatives --set "$name" "$tool"; \
       fi; \
     done \
  && /usr/bin/java -version 2>&1 | grep -q '"17\.' \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Reinstall the python packages from the python base image into the user's conda env. By comparison,
# simply copying the python site-packages can result in issues when uninstalling packages:
# https://github.com/conda/conda/issues/10357
# terra-jupyter-python 2.0.0 lists its packages in pyproject.toml (it was requirements.txt).
COPY --from=python /etc/terra-docker/pyproject.toml /etc/terra-docker/pyproject.toml

# Install GATK
ENV GATK_VERSION=4.7.0.0
ENV GATK_ZIP_PATH=/tmp/gatk-${GATK_VERSION}.zip

# GATK's python tools (gCNV, NVScoreVariants) need the exact environment in the gatkcondaenv.yml shipped in
# the GATK zip: gcnvkernel asserts pymc == 5.10.1, which needs Python 3.10, numpy 1.26 and pytensor 2.18, so it
# cannot go into the user's Python 3.13 env (pymc 6). Like GATK's own docker image, create a separate `gatk`
# conda env from that file. It installs gatkPythonPackageArchive.zip by relative path, so run it from the
# GATK directory.
ENV GATK_CONDA_ENV_HOME=$CONDA_HOME/envs/gatk

# conda-forge's pytorch 2.1 ships libtorch_cpu.so flagged as needing an executable stack. glibc >= 2.41
# (2.43 on Ubuntu 26.04) refuses to dlopen such libraries ("cannot enable executable stack as shared object
# requires: Invalid argument"), so `import torch` and NVScoreVariants fail. The library does not use it, so
# clear the flag on every library in the env that has it.
#
# GATK runs `java`, `python3` (and `Rscript` for its plots) from PATH. /bin/gatk is a wrapper that puts Java 17
# and the gatk env first on PATH for GATK only:
# - Java 17 is also /usr/bin/java (see the alternatives above); $JAVA_HOME/bin first keeps GATK on 17 even if a
#   user changes the default java.
# - `python3` would otherwise resolve to Ubuntu's /usr/bin/python3 (3.14). Putting an env's bin on the image's
#   PATH would also swap in that env's `jupyter` / `python` for users.
RUN curl -L -o $GATK_ZIP_PATH https://github.com/broadinstitute/gatk/releases/download/$GATK_VERSION/gatk-$GATK_VERSION.zip \
 && unzip -o $GATK_ZIP_PATH -d /etc/ \
 && rm $GATK_ZIP_PATH \
 && cd /etc/gatk-$GATK_VERSION \
 && conda env create -y -n gatk -f gatkcondaenv.yml \
 && conda clean -afy \
 && find $GATK_CONDA_ENV_HOME -type f -name '*.so*' -print0 \
    | while IFS= read -r -d '' lib; do \
        if patchelf --print-execstack "$lib" 2>/dev/null | grep -q 'execstack: X'; then \
          patchelf --clear-execstack "$lib" && echo "cleared executable stack: $lib"; \
        fi; \
      done \
 && chown -R $USER:users $GATK_CONDA_ENV_HOME \
 && printf '#!/usr/bin/env bash\nPATH=%s/bin:%s/bin:$PATH exec /etc/gatk-%s/gatk "$@"\n' $JAVA_HOME $GATK_CONDA_ENV_HOME $GATK_VERSION > /bin/gatk \
 && chmod 755 /bin/gatk

# uv (from terra-jupyter-base, on root's PATH) installs into the conda env; there is no system pip on 26.04.
# jupyter-contrib-nbextensions (and the packages only it pulls in) from the python base image is removed: it only works with
# the classic notebook and imports notebook.services, which Notebook 7 dropped. nbconvert loads its exporters
# on startup, so with it installed `jupyter nbconvert` / `import nbconvert` fail in the user's env.
# The old setuptools<71, markupsafe==2.1.2, python-dateutil==2.8.2 and nbconvert==7.11.0 pins are dropped:
# they predate Python 3.13 and the python base image ships newer versions.
# Files uv adds are root-owned; hand them to the jupyter user (only those, so the rest of the env is not
# copied into this layer) so `pip install` in a notebook can upgrade them.
RUN uv pip install --python ${CONDA_ENV_HOME}/bin/python --no-cache -r /etc/terra-docker/pyproject.toml \
  && uv pip uninstall --python ${CONDA_ENV_HOME}/bin/python \
     jupyter-contrib-nbextensions \
     jupyter-nbextensions-configurator \
     jupyter-contrib-core \
     jupyter-highlight-selected-word \
  && find ${CONDA_ENV_HOME} ! -user $USER -exec chown -h $USER:users {} +

# Install Nextflow
# NXF_MODE=google is dropped: the launcher no longer reads it, and Google Batch support is a built-in plugin.
ENV NEXTFLOW_VERSION=26.10.3
RUN mkdir -p /tmp/nextflow && \
  cd /tmp/nextflow && \
  wget -qO- https://github.com/nextflow-io/nextflow/releases/download/v${NEXTFLOW_VERSION}/nextflow | bash && \
  mv nextflow /bin/nextflow && \
  cd $HOME && \
  chmod 777 /bin/nextflow && \
  chown -R $USER:users $HOME/.nextflow && \
  rm -rf /tmp/nextflow

# GNU tar 1.35 on Ubuntu 26.04 fails with "Cannot open: Function not implemented" when the amd64 image is
# built under emulation on Apple Silicon, so extract the tool tarballs with python's tarfile instead.

# Install samtools
ENV SAMTOOLS_VERSION=1.24
RUN mkdir -p /tmp/samtools && \
    cd /tmp/samtools && \
    curl -L -o samtools.tar.bz2 https://github.com/samtools/samtools/releases/download/${SAMTOOLS_VERSION}/samtools-${SAMTOOLS_VERSION}.tar.bz2 && \
    python3 -c 'import sys, tarfile; tarfile.open(sys.argv[1]).extractall(filter="data")' samtools.tar.bz2 && \
    cd samtools-${SAMTOOLS_VERSION} && \
    ./configure && \
    make && \
    make install && \
    cd $HOME && \
    rm -rf /tmp/samtools

# Install bcftools
ENV BCFTOOLS_VERSION=1.24
RUN mkdir -p /tmp/bcftools && \
    cd /tmp/bcftools && \
    curl -L -o bcftools.tar.bz2 https://github.com/samtools/bcftools/releases/download/${BCFTOOLS_VERSION}/bcftools-${BCFTOOLS_VERSION}.tar.bz2 && \
    python3 -c 'import sys, tarfile; tarfile.open(sys.argv[1]).extractall(filter="data")' bcftools.tar.bz2 && \
    cd bcftools-${BCFTOOLS_VERSION} && \
    ./configure && \
    make && \
    make install && \
    cd $HOME && \
    rm -rf /tmp/bcftools

# Install bedtools
ENV BEDTOOLS_VERSION=2.31.1
RUN mkdir -p /tmp/bedtools && \
    cd /tmp/bedtools && \
    wget https://github.com/arq5x/bedtools2/releases/download/v${BEDTOOLS_VERSION}/bedtools-${BEDTOOLS_VERSION}.tar.gz && \
    python3 -c 'import sys, tarfile; tarfile.open(sys.argv[1]).extractall(filter="data")' bedtools-${BEDTOOLS_VERSION}.tar.gz && \
    cd bedtools2 && \
    make && \
    make install && \
    cd $HOME && \
    rm -rf /tmp/bedtools

# The vqsr_cnn patch (cnn-models.patch) is gone: GATK 4.6.1.0 removed CNNScoreVariants and its vqsr_cnn
# python package. NVScoreVariants (pytorch) replaces it.

ENV PIP_USER=true

ENV USER=jupyter

USER $USER
