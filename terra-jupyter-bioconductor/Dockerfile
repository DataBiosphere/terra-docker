FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:2.0.15

USER root

## Install Bioconductor Core packages
RUN curl -O https://raw.githubusercontent.com/Bioconductor/anvil-docker/master/anvil-rstudio-bioconductor/install.R \
	&& R -f install.R \
	&& rm -rf install.R \
	 # deep learning image comes with higher version of libprotobuf 3.16, which isn't compatible
	&& conda uninstall libprotobuf --force \
	# After unstalling libprotobuf, this is needed to not break pandas_gbq
	&& conda install --no-deps pyarrow

USER $USER
