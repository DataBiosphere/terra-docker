FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:1.0.1 AS python

FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:2.0.1

# copy everything pip installed from the python image
COPY --from=python /opt/conda/lib/python3.7/site-packages /opt/conda/lib/python3.7/site-packages

USER root

# need to apt-get everything for python since we can only copy pip installed packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
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
  samtools \
  git-lfs \
  # specify Java 8
  && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install GATK
RUN mkdir /gatk-build
COPY cnn-models.patch /gatk-build/cnn-models.patch

RUN cd /gatk-build \
    && git config --global user.email "you@example.com" \
    && git config --global user.name "Your Name" \
    && git clone https://github.com/broadinstitute/gatk.git \
    && cd gatk \
    && git checkout 4.2.0.0 \
    && git apply ../cnn-models.patch \
    && ./gradlew bundle \
    && cp -r /gatk-build/gatk/build/bundle-files-collected /etc/gatk \
    && ln -s /etc/gatk/gatk /bin/gatk \
    && cd .. && rm -rf gatk


RUN pip install /etc/gatk/gatkPythonPackageArchive.zip

ENV USER jupyter
USER $USER
ENV PIP_USER=true
