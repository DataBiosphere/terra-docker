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

* AnnotationHub

* ExperimentHub

* ensembldb

* scRNAseq

* scran

* Rtsne

**NOTE**: The image is able to install all Bioconductor packages as needed
by the user. Please use `BiocManager::install()` to install additional
packages.

To see the complete contents of this image, please see the
[Dockerfile](./Dockerfile).

## Selecting prior versions of this image

To select older versions of this image, you can search the
[CHANGELOG.md](./CHANGELOG.md) for a specific version.

Once you find an image version that you want, simply copy and paste
the image url from the changelog into the corresponding custom docker
field in the Terra notebook runtime widget.
