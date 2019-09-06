FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.1
USER root
ENV PIP_USER=false

# Note Spark and Hadoop are mounted from the outside Dataproc VM.
# Make empty conf dirs for the update-alternatives commands.
RUN apt-get update && apt-get -yq dist-upgrade \
    && apt install -yq --no-install-recommends openjdk-8-jdk \
    && pip3 install --no-dependencies hail==0.2.1 \
    && X=$(mktemp -d) \
    && mkdir -p $X \
    && (cd $X && pip3 download hail==0.2.1 --no-dependencies && \
        unzip hail*.whl &&  \
        grep 'Requires-Dist: ' hail*dist-info/METADATA | sed 's/Requires-Dist: //' | sed 's/ (//' | sed 's/)//' | grep -v 'pyspark' | xargs pip3 install) \
    && rm -rf $X 
    # \
    # && find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x

ENV PIP_USER=true
USER $USER