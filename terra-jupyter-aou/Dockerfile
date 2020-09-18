FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.16 AS python

FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.6

# copy everything pip installed from the python image
COPY --from=python /usr/local/lib/python3.7/dist-packages /usr/local/lib/python3.7/dist-packages

USER root

# need to apt-get everything for python since we can only copy pip installed packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
  jq \
  python3.7-dev \
  python-tk \
  openjdk-8-jdk \
  tk-dev \
  libssl-dev \
  xz-utils \
  libhdf5-dev \
  openssl \
  make \
  liblzo2-dev \
  zlib1g-dev \
  libz-dev \
  libmagick++-dev \
  iproute2 \
  # specify Java 8
  && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install Wondershaper from source, for client-side egress limiting.
RUN cd /usr/local/share && \
  git clone https://github.com/magnific0/wondershaper.git --depth 1 && \
  cd wondershaper && \
  make install && \
  cd $HOME

# Install the variantstore branch of the GATK jar. This will eventually be
# merged into the main release, at which point we can simply download the usual
# GATK release jar and delete this entire section.
ENV GATK_COMMIT=c79cd40

# GATK build process requires git-lfs.
RUN mkdir /tmp/git-lfs && \
  curl -L -o /tmp/git-lfs/git-lfs.tar.gz https://github.com/git-lfs/git-lfs/releases/download/v2.12.0/git-lfs-linux-amd64-v2.12.0.tar.gz && \
  cd /tmp/git-lfs && \
  tar -xvzf git-lfs.tar.gz && \
  ./install.sh && \
  git lfs install && \
  cd $HOME

RUN cd /tmp && \
  git clone https://github.com/broadinstitute/gatk && \
  cd gatk && \
  # From the ah_var_store branch
  git checkout $GATK_COMMIT && \
  ./gradlew bundle && \
  mv build/bundle-files-collected /usr/local/share/gatk-$GATK_COMMIT && \
  ln -s /usr/local/share/gatk-$GATK_COMMIT/gatk /bin/gatk && \
  cd $HOME && \
  rm -rf /tmp/gatk

RUN /home/jupyter-user/miniconda/bin/conda install -c bioconda plink && \
  ln -s /home/jupyter-user/miniconda/bin/plink /bin/plink

RUN echo "Sys.setenv(RETICULATE_PYTHON = '$(which python3)')" >> ~/.Rprofile

# Install Notebook libraries as the user.

ENV USER jupyter-user
USER $USER

RUN pip3 install --upgrade \
  # Fix plotnine and its dependency mizani to a version that's compatible with 0.25.* of pandas.
  # The next versions require pandas 1.0 which we're not ready to upgrade to just yet.
  plotnine==0.6.0 \
  mizani==0.6.0 \
  # Parent image pins tensorflow to an old alpha version. Override here for now.
  tensorflow==2.3.0 \
  # This version of numpy should already be installed but isn't. See IA-2122.
  # This line can be removed once that ticket is resolved.
  numpy==1.19.0 \
  statsmodels==0.10.0rc2 \
  "git+git://github.com/all-of-us/workbench-snippets.git#egg=terra_widgets&subdirectory=py"

RUN R -e 'devtools::install_github("all-of-us/bigrquery")'
