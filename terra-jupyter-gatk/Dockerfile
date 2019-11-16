FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.4 AS python

FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:0.0.5

# copy everything pip installed from the python image
COPY --from=python /usr/local/lib/python3.7/dist-packages /usr/local/lib/python3.7/dist-packages

USER root

# need to apt-get everything for python since we can only copy pip installed packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
  python3.7-dev \
  python-tk \
  tk-dev \
  libssl-dev \
  xz-utils \
  libhdf5-dev \
  openssl \
  make \
  liblzo2-dev \
  zlib1g-dev \
  libz-dev \
  default-jre \
  default-jdk \
  samtools \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

ENV GATK_VERSION 4.1.3.0
ENV GATK_ZIP_PATH /tmp/gatk-${GATK_VERSION}.zip

RUN curl -L -o $GATK_ZIP_PATH https://github.com/broadinstitute/gatk/releases/download/$GATK_VERSION/gatk-$GATK_VERSION.zip \
 && unzip -o $GATK_ZIP_PATH -d /etc/ \
 && ln -s /etc/gatk-$GATK_VERSION/gatk /bin/gatk


ENV USER jupyter-user
USER $USER


