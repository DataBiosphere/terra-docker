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
  git-lfs \
  # specify Java 8
  && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

RUN rm /usr/bin/python
RUN ln -s /usr/bin/python3.6 /usr/bin/python

COPY gatk-ovtf.patch /home/jupyter-user/gatk-ovtf.patch

RUN git config --global user.email "you@example.com"
RUN git config --global user.name "Your Name"

RUN git clone https://github.com/broadinstitute/gatk.git
RUN cd gatk \
    && git checkout 4.2.0.0 \
    && git am --signoff ../gatk-ovtf.patch \
    && ./gradlew bundle

RUN cp -r /home/jupyter-user/gatk/build/bundle-files-collected /etc/gatk-tfov \
    && ln -s /etc/gatk-tfov/gatk /bin/gatk


COPY run_gatk.sh /home/jupyter-user/run_gatk.sh
RUN chmod +x /home/jupyter-user/run_gatk.sh

ENV USER jupyter-user
USER $USER

RUN wget https://bootstrap.pypa.io/get-pip.py \
    && python3.6 get-pip.py

USER root
RUN rm /usr/local/bin/pip
RUN ln -s /home/jupyter-user/.local/bin/pip3.6 /usr/local/bin/pip
USER $USER

RUN python -m pip install --upgrade pip \
    && pip install --force-reinstall tensorflow==2.4.1 \
    && pip install openvino_tensorflow \
    && pip install keras matplotlib sklearn \
    && pip install /etc/gatk-tfov/gatkPythonPackageArchive.zip

ENV TF_DISABLE_MKL=1

