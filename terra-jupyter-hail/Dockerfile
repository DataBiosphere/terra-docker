FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:2.1.1

USER root


ENV PIP_USER=false
ENV PYTHONPATH=$PYTHONPATH:/usr/lib/spark/python
# The user's conda env (the python3 kernel). A bare "python3" resolves to Ubuntu 26.04's
# /usr/bin/python3 (3.14), which has none of the packages below.
ENV PYSPARK_PYTHON=$CONDA_ENV_HOME/bin/python
ENV HAIL_VERSION=0.2.139
# Ubuntu 26.04's default java is 25, which Spark 3.5 / Hadoop 3.3 cannot start on
# (Subject.getSubject was removed). Pin Spark to Java 11.
ENV JAVA_HOME=/usr/lib/jvm/java-21-openjdk-amd64
ENV PATH=$JAVA_HOME/bin:$PATH

# terra-jupyter-base 2.0.2 already registers the python3 kernel (in $JUPYTER_KERNELSPEC_DIR, pointing at
# the conda env) and makes the scripts executable, so the kernelspec.sh call that was here is dropped:
# /opt/conda/share/jupyter/kernels no longer exists and the base's kernelspec.sh writes python3/kernel.json only.
#
# pip is the conda env's: there is no system pip3 on 26.04, and the pip3 on PATH is conda base's, not the
# kernel's env.
RUN PIP="$CONDA_ENV_HOME/bin/python -m pip" \
    # Note Spark and Hadoop are mounted from the outside Dataproc VM.
    # Make empty conf dirs for the update-alternatives commands.
    && mkdir -p /etc/spark/conf.dist && mkdir -p /etc/hadoop/conf.empty && mkdir -p /etc/hive/conf.dist \
    && update-alternatives --install /etc/spark/conf spark-conf /etc/spark/conf.dist 100 \
    && update-alternatives --install /etc/hadoop/conf hadoop-conf /etc/hadoop/conf.empty 100 \
    && update-alternatives --install /etc/hive/conf hive-conf /etc/hive/conf.dist 100 \
    && apt-get update \
    # Java 21 for Spark, plus the compiler and BLAS/LAPACK libraries Hail loads natively. \
    # libopenblas-base -> deprecated in newer ubuntu
    && apt-get install -yq --no-install-recommends \
        openjdk-21-jre-headless \
        g++ \
        libopenblas0 \
        liblapack3 \
    && $PIP install --no-cache-dir --root-user-action=ignore pypandoc gnomad==0.6.4 \
    # Install hail with its dependencies, including pyspark (3.5.x), so it also runs outside Dataproc.
    && $PIP install --no-cache-dir --root-user-action=ignore hail==$HAIL_VERSION \
    # Files pip added are root-owned; hand them to the jupyter user (only those, so the rest of the env
    # is not copied into this layer) so `pip install` in a notebook can upgrade them.
    && find $CONDA_ENV_HOME ! -user $USER -exec chown -h $USER:users {} + \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

ENV PIP_USER=true
USER $USER
