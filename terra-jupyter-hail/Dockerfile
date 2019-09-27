FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.1
USER root
ENV PIP_USER=false

COPY scripts $JUPYTER_HOME/scripts

ENV SPARK_VER 2.2.3
ENV SPARK_HOME=/usr/lib/spark
ENV PYTHONPATH $PYTHONPATH:$SPARK_HOME/python

# Note Spark and Hadoop are mounted from the outside Dataproc VM.
# Make empty conf dirs for the update-alternatives commands.
RUN apt-get update && apt-get -yq dist-upgrade \
    && apt install -yq --no-install-recommends openjdk-8-jdk \
        g++ \
        liblz4-dev \
    && pip3 install pypandoc \    
    && pip3 install --no-dependencies hail==0.2.1 \
    && X=$(mktemp -d) \
    && mkdir -p $X \
    && (cd $X && pip3 download hail==0.2.1 --no-dependencies && \
        unzip hail*.whl &&  \
        grep 'Requires-Dist: ' hail*dist-info/METADATA | sed 's/Requires-Dist: //' | sed 's/ (//' | sed 's/)//' | grep -v 'pyspark' | xargs pip install) \
    && rm -rf $X

ENV PIP_USER=true
USER $USER