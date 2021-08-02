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
  # specify Java 8
  && update-alternatives --set java /usr/lib/jvm/java-8-openjdk-amd64/jre/bin/java \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*

# Install miniconda to /miniconda
RUN curl -LO https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh
RUN bash Miniconda3-latest-Linux-x86_64.sh -p /miniconda -b
RUN rm Miniconda3-latest-Linux-x86_64.sh
ENV PATH=/miniconda/bin:${PATH}
RUN conda update -y conda

ENV GATK_VERSION 4.2.0.0
ENV GATK_ZIP_PATH /tmp/gatk-${GATK_VERSION}.zip


RUN curl -L -o $GATK_ZIP_PATH https://github.com/broadinstitute/gatk/releases/download/$GATK_VERSION/gatk-$GATK_VERSION.zip \
 && unzip -o $GATK_ZIP_PATH -d /etc/ \
 && ln -s /etc/gatk-$GATK_VERSION/gatk /bin/gatk

# Install GATK Python
RUN cd /etc/gatk-$GATK_VERSION/  \
 && conda env create -f gatkcondaenv.yml
RUN conda install -y -n gatk -c anaconda ipykernel \
 && /miniconda/envs/gatk/bin/python -m ipykernel install --user --name=gatk

ENV USER jupyter
USER $USER


