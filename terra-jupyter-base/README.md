<h1>Terra-jupyter-base image</h1>

This repo contains the terra-jupyter-base image that is compatible with notebook service in <a href="https://app.terra.bio/">Terra</a> called Leonardo.

<h3>Image contents</h3>

The terra-jupyter-base extends the <a href="https://github.com/tianon/docker-brew-ubuntu-core/blob/9db8c72dd02e8f9fd5dba82ff9266174b088e2e6/bionic/Dockerfile">Ubuntu base image</a>  by including the following:

* OS prerequisites
* google-cloud-sdk
* Python 3.7
* pip
* conda
* Jupyter & JupyterLab
* Leonardo customizations/extensions

To see the complete contents of this image please see the <a href="https://github.com/DataBiosphere/terra-docker/blob/master/terra-jupyter-base/Dockerfile">Dockerfile</a>.

<h3>Selecting prior versions of this image</h3>

To select an older version this image, you can search the <a href="https://github.com/DataBiosphere/terra-docker/blob/master/terra-jupyter-base/Dockerfile">CHANGELOG.md</a> for a specific package version you need (e.g. pandas 0.25.0).

Once you find an image version that you want, simply copy and paste the image url from the changelog into the corresponding custom docker field in the Terra notebook runtime widget. 
