FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.1
USER root

# Use Spark 2.2.0 which corresponds to Dataproc 1.2. See:
#   https://cloud.google.com/dataproc/docs/concepts/versioning/dataproc-versions
# Note: we are actually using Spark 2.2.1, but the Hail package is built using 2.2.0
ENV SPARK_VER 2.4.0
ENV SPARK_HOME=/usr/lib/spark

# result of `gsutil cat gs://hail-common/builds/0.2/latest-hash/cloudtools-3-spark-2.2.0.txt` on 26 March 2019
ENV HAILHASH daed180b84d8
# ENV HAILJAR hail-0.2-$HAILHASH-Spark-$SPARK_VER.jar
# ENV HAILPYTHON hail-0.2-$HAILHASH.zip
# ENV HAIL_HOME /etc/hail
ENV KERNELSPEC_HOME /usr/local/share/jupyter/kernels

ENV PATH $SPARK_HOME:$SPARK_HOME/python:$SPARK_HOME/bin:$HAIL_HOME:$PATH
ENV PYTHONPATH $PYTHONPATH:$HAIL_HOME/$HAILPYTHON:$HAIL_HOME/python:$SPARK_HOME/python:$JUPYTER_HOME/custom

# Note Spark and Hadoop are mounted from the outside Dataproc VM.
# Make empty conf dirs for the update-alternatives commands.
RUN apt install openjdk-8-jdk \
&& pip3 install hail
# mkdir -p /etc/spark/conf.dist && mkdir -p /etc/hadoop/conf.empty && mkdir -p /etc/hive/conf.dist \
#  && update-alternatives --install /etc/spark/conf spark-conf /etc/spark/conf.dist 100 \
#  && update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.empty 100 \
#  && update-alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.dist 100 \
#  && pip3 install hail

USER $USER