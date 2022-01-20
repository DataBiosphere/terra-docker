FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:1.0.3 AS python

FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:2.0.4

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
ENV GATK_VERSION 4.2.4.0
ENV GATK_ZIP_PATH /tmp/gatk-${GATK_VERSION}.zip

RUN curl -L -o $GATK_ZIP_PATH https://github.com/broadinstitute/gatk/releases/download/$GATK_VERSION/gatk-$GATK_VERSION.zip \
 && unzip -o $GATK_ZIP_PATH -d /etc/ \
 && ln -s /etc/gatk-$GATK_VERSION/gatk /bin/gatk

ENV PIP_USER=false

# Force reinstalling TF-2.5.1, Keras-2.5.0 to satisfy OVTF compatibility.
RUN pip install --force-reinstall tensorflow==2.5.1 keras==2.5.0rc0
RUN conda install six typing_extensions --force-reinstall \
    && pip install openvino_tensorflow==1.0.0 \
    && pip install matplotlib sklearn \
    && pip install /etc/gatk-$GATK_VERSION/gatkPythonPackageArchive.zip
ENV PIP_USER=true

COPY gatk-ovtf.patch /etc/gatk-$GATK_VERSION/gatk-ovtf.patch

RUN cd /opt/conda/lib/python3.7/site-packages/vqsr_cnn/vqsr_cnn/ \
    && patch -p1 < /etc/gatk-$GATK_VERSION/gatk-ovtf.patch

COPY --chown=jupyter:users run_gatk.sh /home/jupyter/run_gatk.sh
COPY --chown=jupyter:users GATK-OVTF-Notebook.ipynb /home/jupyter/GATK-OVTF-Notebook.ipynb

ENV USER jupyter
USER $USER
