This repo provides docker images for running jupyter notebook in [Terra](https://app.terra.bio)

# Terra Base Images
[terra-jupyter-base](terra-jupyter-base/README.md)

[terra-jupyter-r](terra-jupyter-r/README.md)

[terra-jupyter-hail](terra-jupyter-hail/README.md)

# How to create your own terra images
* Add `FROM us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.1` to your dockerfile (`terra-jupyter-base` is the smallest image you can extend from)
* Customize your image (see the [terra-jupyter-python](terra-jupyter-python/Dockerfile) dockerfile for an example)
* Publish the image to either GCR or Dockerhub; the image must be public to be used
* Use the published image URL when creating notebook runtime

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
    - Create a new directory with the Dockerfile, a VERSION file and a CHANGELOG.md. 
    - Add the directory name to the file jenkins/imageDirs.txt 
    - Add your directory name to the array(s) R_IMAGES and/or PYTHON_IMAGES at the top of build.sh based on which packages are relevant to document

If you are updating an existing image:
    - Update VERSION file
    - Update CHANGELOG.md
    - Follow [instructions](https://broadworkbench.atlassian.net/wiki/spaces/AP/pages/100401153/Testing+notebook+functionality+with+Fiab) to test the image
    - Once you merge a PR, A jenkins job will automatically detect which image you have updated and build it + generate documentation. 

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
[Here](https://github.com/DataBiosphere/leonardo/tree/develop/automation/src/test/scala/org/broadinstitute/dsde/workbench/leonardo/notebooks) are automation tests for various docker image, please update the image hash for relevant tests.
