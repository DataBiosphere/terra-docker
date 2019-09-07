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
    && find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x

ENV PIP_USER=true
USER $USER