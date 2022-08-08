FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:1.0.11 AS python

FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:2.1.6

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
ENV GATK_VERSION 4.2.4.1
ENV GATK_ZIP_PATH /tmp/gatk-${GATK_VERSION}.zip

RUN curl -L -o $GATK_ZIP_PATH https://github.com/broadinstitute/gatk/releases/download/$GATK_VERSION/gatk-$GATK_VERSION.zip \
 && unzip -o $GATK_ZIP_PATH -d /etc/ \
 && ln -s /etc/gatk-$GATK_VERSION/gatk /bin/gatk

# Install OpenVINO™ integration with TensorFlow (OVTF)
ENV TF_VER 2.7.0
ENV KERAS_VER 2.7.0
ENV OVTF_VER 1.1.0
ENV TF_ENABLE_ONEDNN_OPTS 1

ENV PIP_USER=false

# Force reinstalling TF and Keras to satisfy OVTF compatibility.
RUN pip install --force-reinstall tensorflow==$TF_VER keras==$KERAS_VER markupsafe==2.0.1
RUN conda install six typing_extensions --force-reinstall \
    && pip install openvino_tensorflow==$OVTF_VER \
    && pip install matplotlib sklearn \
    && pip install /etc/gatk-$GATK_VERSION/gatkPythonPackageArchive.zip
ENV PIP_USER=true

COPY gatk-ovtf.patch /etc/gatk-$GATK_VERSION/gatk-ovtf.patch
COPY ovtf-cuda-disabling.patch /etc/gatk-$GATK_VERSION/ovtf-cuda-disabling.patch

# Apply patch to GATK to fix TFv2 compatibility.
RUN cd /opt/conda/lib/python3.7/site-packages/vqsr_cnn/vqsr_cnn/ \
    && patch -p1 < /etc/gatk-$GATK_VERSION/gatk-ovtf.patch

# Apply patch to OVTF to disable CUDA devices if OVTF is enabled.
RUN cd /opt/conda/lib/python3.7/site-packages/openvino_tensorflow/ \
    && patch __init__.py < /etc/gatk-$GATK_VERSION/ovtf-cuda-disabling.patch

COPY --chown=jupyter:users run_gatk.sh /home/jupyter/run_gatk.sh
COPY --chown=jupyter:users GATK-OVTF-Notebook.ipynb /home/jupyter/GATK-OVTF-Notebook.ipynb

ENV USER jupyter
USER $USER
