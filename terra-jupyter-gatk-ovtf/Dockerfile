FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.23 AS python

FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.13

# copy everything pip installed from the python image
COPY --from=python /usr/local/lib/python3.6/dist-packages /usr/local/lib/python3.6/dist-packages

USER root

# need to apt-get everything for python since we can only copy pip installed packages
RUN apt-get update && apt-get install -yq --no-install-recommends \
  python3.6-dev \
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
  # specify Java 8
  && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN rm /usr/bin/python
RUN ln -s /usr/bin/python3.6 /usr/bin/python

#RUN wget https://bootstrap.pypa.io/get-pip.py \
#    && python3.6 get-pip.py


COPY gatk-tfov /home/jupyter-user/gatk-tfov
COPY models /home/jupyter-user/models
COPY wheels /home/jupyter-user/wheels
#ENV GATK_VERSION 4.1.4.1
#ENV GATK_ZIP_PATH /tmp/gatk-${GATK_VERSION}.zip
RUN mv /home/jupyter-user/gatk-tfov /etc/. \
 && ln -s /etc/gatk-tfov/gatk /bin/gatk

#RUN curl -L -o $GATK_ZIP_PATH https://github.com/broadinstitute/gatk/releases/download/$GATK_VERSION/gatk-$GATK_VERSION.zip \
# && unzip -o $GATK_ZIP_PATH -d /etc/ \
# && ln -s /etc/gatk-$GATK_VERSION/gatk /bin/gatk

COPY run_gatk_keras.sh /home/jupyter-user/run_gatk_keras.sh
RUN chmod +x /home/jupyter-user/run_gatk_keras.sh
COPY run_gatk_frozen.sh /home/jupyter-user/run_gatk_frozen.sh
RUN chmod +x /home/jupyter-user/run_gatk_frozen.sh
COPY run_gatk_keras_mkl.sh /home/jupyter-user/run_gatk_keras_mkl.sh
RUN chmod +x /home/jupyter-user/run_gatk_keras_mkl.sh
COPY run_gatk_mkl.sh /home/jupyter-user/run_gatk_mkl.sh
RUN chmod +x /home/jupyter-user/run_gatk_mkl.sh
COPY run_gatk_cpu.sh /home/jupyter-user/run_gatk_cpu.sh
RUN chmod +x /home/jupyter-user/run_gatk_cpu.sh
COPY download_resources.sh /home/jupyter-user/download_resources.sh
RUN chmod +x /home/jupyter-user/download_resources.sh
COPY calc.sh /home/jupyter-user/calc.sh
#COPY GATKDemo.ipynb /home/jupyter-user/GATKDemo.ipynb

ENV USER jupyter-user
USER $USER

RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3.6 get-pip.py

USER root
RUN rm /usr/local/bin/pip
RUN ln -s /home/jupyter-user/.local/bin/pip3.6 /usr/local/bin/pip
USER $USER

RUN python -m pip install --upgrade pip \
    && pip install --force-reinstall tensorflow==2.2.2 \
    && pip install wheels/openvino_tensorflow-0.5.0-py2.py3-none-manylinux2010_x86_64.whl \
    && pip install keras matplotlib sklearn \
    && pip install /etc/gatk-tfov/gatkPythonPackageArchive.zip

ENV TF_DISABLE_MKL=1

