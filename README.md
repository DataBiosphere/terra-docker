This repo provides docker images for running jupyter notebook in [Terra](https://app.terra.bio)

# Terra Base Images
[terra-jupyter-base](terra-jupyter-base/README.md)

[terra-jupyter-python](terra-jupyter-python/README.md)

[terra-jupyter-r](terra-jupyter-r/README.md)

[terra-jupyter-hail](terra-jupyter-hail/README.md)

[terra-jupyter-gatk](terra-jupyter-gatk/README.md)

[terra-jupyter-bioconductor](terra-jupyter-bioconductor/README.md)

# How to create your own Custom image to use with notebooks on Terra
Custom docker images need to use a Terra base image (see above) in order to work with the service that runs notebooks on Terra
* You can use any of the base images above
* Here is an example of how to build off of a base image: Add `FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.1` to your dockerfile (`terra-jupyter-base` is the smallest image you can extend from)
* Customize your image (see the [terra-jupyter-python](terra-jupyter-python/Dockerfile) dockerfile for an example of how to extend from one of our base images
* Publish the image to either GCR or Dockerhub; the image must be public to be used
* Use the published container image location when creating notebook runtime
* Dockerhub image example: [image name]:[tag]
* GCR image example: us.gcr.io/repository/[image name]:[tag]
    

# Development
## Using git secrets
Make sure git secrets is installed:
```
brew install git-secrets
```
Ensure git-secrets is run: If you use the rsync script to run locally you can skip this step

```
cp -r hooks/ .git/hooks/
chmod 755 .git/hooks/apply-git-secrets.sh
```

## Generate New Image
If you are adding a new image:
- Create a new directory with the Dockerfile and a CHANGELOG.md. 
- Add the directory name (also referred to as the image name) as an entry to the image_data array in the file in config/conf.json. For more info on what is needed for a new image, see the section on the config

If you are updating an existing image:
- Update the version in config/conf.json
- Update CHANGELOG.md
- Ensure that no `From` statements need to be updated based on the image you updated (i.e., if you update the base image, you will need to update several other images)
- Follow [instructions](https://broadworkbench.atlassian.net/wiki/spaces/AP/pages/100401153/Testing+notebook+functionality+with+Fiab) to test the image
- Once you merge a PR, A [jenkins job](https://fc-jenkins.dsp-techops.broadinstitute.org/job/leonardo-build-terra-docker/) will automatically detect which image you have updated and build it + generate documentation. 

If you wish to build locally, run `docker build [your_dir] -t [name]`. 

It is not advised to run build.sh locally, as this will push to the remote docker repo and delete the image locally upon completion.  

## Testing your image manually
- In a terminal, do `gcloud auth login` and follow the instructions to authenticate with a google account that has appropriate permissions in Terra
- Create a cluster
  - Do ```curl -X PUT --header 'Content-Type: application/json' --header "Authorization: Bearer `gcloud auth print-access-token`" -d @/tmp/createCluster https://leonardo.dsde-prod.broadinstitute.org/api/cluster/{google project}/{cluster name}```
  - /tmp/createCluster looks like
    ```
    {
        "jupyterDockerImage": "{your image url}"
    }
    ```
- Go to `https://portal.firecloud.org/`
- Create a notebook and choose the cluster you just created
- Open the notebook and check if things work as expected

## Automation Tests
[Here](https://github.com/DataBiosphere/leonardo/tree/develop/automation/src/test/scala/org/broadinstitute/dsde/workbench/leonardo/notebooks) are automation tests for various docker image, please update the image hash for relevant tests. You can run the job build-terra-docker to automatically create a PR with your branch if you manually specify versions.

## Config

There is a config file located at `config/conf.json` that contains the configuration used by all automated jobs and build scripts that interface with this repo. 

There are some constants included, such as the tools supported by this repo. Of particular interest is the image_data array.

Each time you update or add an image, you will need to update the appropriate entry in this array:
```
{
    "name": "terra-jupyter-base", //the name of the image. should correspond to the directory it is located

    "base_label": "Minimal",      //the base name used in the UI for this image. This is appended with some information about the packages in this image.

    "tools": ["python"],          //the tools present in this image. see the top-level "tools" array for valid entries. 
                                  //The significance of 'tools' is that there is expected to be an entry in the documentation specifying the version of this tool
                                  //If you wish to add a tool, you will need to add a handler to the function get_doc_builder in generate_package_documentation.py

    "packages": { "python": ["pandas"] },               //The packages that we wish to single out to display to the user at a later date. 
                                  //The difference between a package and a tool is that a tool can have a set of packages associated with it (i.e. pip packages for python)
                                  // A package  must have a tool associated with it
    "version": "0.0.4",           //The current version the image is at

    "automated_flags": {          //Flags used as control flow for scripts

        "generate_docs": true,    //Whether documentation should be auto-generated for this image. This is superceded by the build flag (i.e. if build=false, this flag is ignored)

        "build": true,            //Whether or not the jenkins job that builds the docker images in this repo should build this image

        "include_in_custom_dataproc": true  //Whether or not the jenkins job that builds the custom dataproc image should include this image. 
                                            //This is superceded by the build flag
    }
},
```

## How this interacts with terra-uia

## Terra-ui representation
The leonardo-build-terra-docker job builds this repo, and after each build it will re-generate a master version file, and upload it under the name specified in the conf.
This master version file contains an entry for each image that will appear in the UI. This file is *NOT* automatically included in the UI.
As of now, we wish to control when we change what shows up in the UI via a manual process. Currently, you must go to the google bucket `gs://terra-docker-image-documentation`.
In this bucket, you will find a file matching the name conf.version_master_file. 
If you change that file, which will be updated each build, to `terra-docker-versions.json`, the newest images will instantly show up in all UIs on refresh.


## Scripts

The scripts folder has scripts used for building.
- `generate_package_docs.py` This script is run once by build.sh each time an image is built. It is used to generate a .json with the versions for the packages in the image
- `generate_version_docs.py` This script is run each time an image is built. It builds a new file master version file for the UI to look up the current versions to reference. 