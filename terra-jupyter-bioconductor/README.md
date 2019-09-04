terra-jupyter-bioconductor image
================================

This repo contains the `terra-jupyter-bioconductor` image that is compatible
with notebook service in [Terra]("https://app.terra.bio/") called Leonardo. For example, use
`us.gcr.io/broad-dsp-gcr-public/terra-jupyter-bioconductor:{version}` in terra.

## Image contents

The terra-jupyter-bioconductor image extends the [terra-jupyter-r](../terra-jupyter-r/README.md) by
including the following:

### Bioconductor packages 

* SingleCellExperiment

* Genomic Features

* GenomicAlignments

* ShortRead

* DESeq2

**NOTE**: The image is able to install all Bioconductor packages as needed
by the user. Please use `BiocManager::install()` to install additional
packages.

### System dependencies

* libnetcdf-dev

* libhdf5-serial-dev

* libfftw3-dev

* libopenbabel-dev

* libopenmpi-dev

* libexempi3

* libgdal-dev

* libcairo2-dev

* libtiff5-dev

* libgsl0-dev

* libgtk2.0-dev

* libgl1-mesa-dev

* libglu1-mesa-dev

* libgmp3-dev

* libhdf5-dev

* libncurses-dev

* libxpm-dev

* libv8-3.14-dev

* libgtkmm-2.4-dev

* libmpfr-dev

* libudunits2-dev

* libmodule-build-perl

* libapparmor-dev

* libgeos-dev

* libprotoc-dev

* librdf0-dev

* libmagick++-dev

* libsasl2-dev

* libpoppler-cpp-dev

* libprotobuf-dev

* libpq-dev

* libperl-dev

* libarchive-extract-perl

* libfile-copy-recursive-perl

* libcgi-pm-perl

* libdbi-perl

* libdbd-mysql-perl

* libxml-simple-perl

* sqlite

* openmpi-bin

* mpi-default-bin

* openmpi-common

* openmpi-doc

* tcl8.5-dev

* imagemagick

* tabix

* ggobi

* graphviz

* protobuf-compiler

* jags

* xfonts-100dpi

* xfonts-75dpi

* biber

* libsbml

### Python packages

* cwltool

* pyyaml

* scikit-learn

* pandas

To see the complete contents of this image, please see the
[Dockerfile](./Dockerfile).

## Selecting prior versions of this image

To select older versions of this image, you can search the
[CHANGELOG.md](./CHANGELOG.md) for a specific version.

Once you find an image version that you want, simply copy and paste
the image url from the changelog into the corresponding custom docker
field in the Terra notebook runtime widget.
