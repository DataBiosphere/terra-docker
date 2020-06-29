FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.13 AS python

FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.3

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

RUN echo "Sys.setenv(RETICULATE_PYTHON = '$(which python3)')" >> ~/.Rprofile

ENV USER jupyter-user
USER $USER

# Install Notebook libraries as the user.

RUN pip3 install --upgrade \
  plotnine \
  statsmodels==0.10.0rc2

RUN R -e 'devtools::install_github("all-of-us/bigrquery")'

