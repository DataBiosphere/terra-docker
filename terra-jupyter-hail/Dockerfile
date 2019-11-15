FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.3
USER root
ENV PIP_USER=false

# COPY scripts $JUPYTER_HOME/scripts

ENV SPARK_VER 2.4.4
ENV SPARK_HOME=/usr/lib/spark
ENV PYTHONPATH $PYTHONPATH:$SPARK_HOME/python
ENV HAIL_HOME "/usr/local/lib/python3.7/dist-packages/hail"
ENV HAILJAR "/usr/local/lib/python3.7/dist-packages/hail/hail-all-spark.jar"

# Note Spark and Hadoop are mounted from the outside Dataproc VM.
# Make empty conf dirs for the update-alternatives commands.
RUN mkdir -p /etc/spark/conf.dist && mkdir -p /etc/hadoop/conf.empty && mkdir -p /etc/hive/conf.dist \
    && update-alternatives --install /etc/spark/conf spark-conf /etc/spark/conf.dist 100 \
    && update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.empty 100 \
    && update-alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.dist 100 \
    && apt-get update && apt-get -yq dist-upgrade \
    # && find $JUPYTER_HOME/scripts -name '*.sh' -type f | xargs chmod +x \    
    && apt install -yq --no-install-recommends openjdk-8-jdk \
        g++ \
        liblz4-dev \
    && pip3 install pypandoc \    
    && pip3 install --no-dependencies hail==0.2.26 \
    && X=$(mktemp -d) \
    && mkdir -p $X \
    && (cd $X && pip3 download hail==0.2.26 --no-dependencies && \
        unzip hail*.whl &&  \
        grep 'Requires-Dist: ' hail*dist-info/METADATA | sed 's/Requires-Dist: //' | sed 's/ (//' | sed 's/)//' | grep -v 'pyspark' | xargs pip install) \
    && rm -rf $X

ENV PIP_USER=true
USER $USER