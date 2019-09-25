FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.1
USER root
ENV PIP_USER=false

COPY scripts $JUPYTER_HOME/scripts

# Note Spark and Hadoop are mounted from the outside Dataproc VM.
# Make empty conf dirs for the update-alternatives commands.
RUN apt-get update && apt-get -yq dist-upgrade \
    && apt install -yq --no-install-recommends openjdk-8-jdk \
        g++ \
        liblz4-dev \
    && pip3 install pypandoc \
    && pip3 install hail==0.2.1 \
    && mkdir -p /etc/spark/conf.dist && mkdir -p /etc/hadoop/conf.empty && mkdir -p /etc/hive/conf.dist    \
    && update-alternatives --install /etc/spark/conf spark-conf /etc/spark/conf.dist 100 \ 
    && update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.empty 100 \
    && update-alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.dist 100

ENV PIP_USER=true
USER $USER