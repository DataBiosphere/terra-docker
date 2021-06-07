FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-r:1.0.15

USER root

## Install Bioconductor Core packages
RUN curl -O https://raw.githubusercontent.com/Bioconductor/anvil-docker/master/anvil-rstudio-bioconductor/install.R \
	&& R -f install.R \
	&& rm -rf install.R

USER $USER
