FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:1.0.13 AS python

FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:2.1.6

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

ENV PIP_USER=false

# Grab the requirements from the python base image and reinstall them. By
# comparison, simply copying the python sites-packages can result in issues when
# uninstalling packages: https://github.com/conda/conda/issues/10357
COPY --from=python /etc/terra-docker/requirements.txt /etc/terra-docker/base_requirements.txt

RUN pip install --upgrade -r /etc/terra-docker/base_requirements.txt

# Install GATK
ENV GATK_VERSION 4.2.4.0
ENV GATK_ZIP_PATH /tmp/gatk-${GATK_VERSION}.zip

RUN curl -L -o $GATK_ZIP_PATH https://github.com/broadinstitute/gatk/releases/download/$GATK_VERSION/gatk-$GATK_VERSION.zip \
 && unzip -o $GATK_ZIP_PATH -d /etc/ \
 && ln -s /etc/gatk-$GATK_VERSION/gatk /bin/gatk

# Install Nextflow
ENV NXF_MODE google
RUN mkdir -p /tmp/nextflow && \
  cd /tmp/nextflow && \
  curl -s https://get.nextflow.io | bash && \
  mv nextflow /bin/nextflow && \
  cd $HOME && \
  chmod 777 /bin/nextflow && \
  chown -R $USER:users $HOME/.nextflow && \
  rm -rf /tmp/nextflow

RUN pip install /etc/gatk-$GATK_VERSION/gatkPythonPackageArchive.zip
RUN pip3 install --upgrade markupsafe==2.0.1

COPY cnn-models.patch /etc/gatk-$GATK_VERSION/cnn-models.patch

RUN patch -u /opt/conda/lib/python3.7/site-packages/vqsr_cnn/vqsr_cnn/models.py -i /etc/gatk-$GATK_VERSION/cnn-models.patch

ENV PIP_USER=true

ENV USER jupyter
USER $USER
