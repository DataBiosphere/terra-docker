# Contributing

`terra-docker` consists of docker images that are compatible with the notebooks service in Terra called Leonardo. We follow the naming convention of `terra-[application]-[image_name]` (for example `terra-jupyter-aou`).

## Opening a PR

We do our work on a feature branch based on master. When you open a pull request, add the JIRA issue number to the PR title. This will make a reference from JIRA to the GitHub issue. Briefly describe your changes in the description section.

This is also a good opportunity to verify that all the appropriate image versions were bumped. It is important to keep in mind which images extend from where ([Image Dependecies](https://github.com/DataBiosphere/terra-docker#image-dependencies)). Make sure to bump the version of the image you are changing and update its reference in all images that extend from it.

You can also run `amm ./updateVersions.sc <image name> <release note>` to upgrade derived images. If you're updating `terra-jupyter-aou` image, please make a pull request similar to [this PR](https://github.com/DataBiosphere/leonardo/pull/1612) (less updating `terra_jupyter_aou_old`).

## Legacy Image Versioning

We have two legacy images - `terra-jupyter-gatk_legacy` and `terra-jupyter-bioconductor_legacy`. The version of these legacy images is the version prior to a major or minor version bump. For example, if `terra-jupyter-gatk` is at version `2.1.3` and we release either `3.0.0` (major version bump) or `2.2.0` (minor version bump) then the `terra-jupyter-gatk_legacy` would be `2.1.3`.

## External Contributions

If you are from outside the Broad, don't worry about adding a JIRA issue number to PRs. More to come on external contributions.

If you are handling these contributions from the Broad side, please remember to create a corresponding JIRA ticket. This ticket number will be used to track contributions internally.

## Community Images

Community images must be vetted before they will be introduced into Terra.
To contribute a community image, please engage the Interactive Analysis team via email at `workbench-interactive-analysis@broadinstitute.org` prior to making a PR. 

If you wish to add an approved community image to the terra UI, you must update the json file `config/community_images.json`. 
It contains an array of community images. The fields needed (with comments removed) are:

```
{
    //Unique Id for the image
    "id": "Pegasus", 
    //label that will be shown for the image in the terra UI dropdown
    //Typically used to call out important versions
    "label": "Pegasus (Pegasuspy 1.0, Python 3.7, scPlot 0.0.16, harmony-pytorch 0.1.3)",
    //The version for the image. This will need to be updated if iteration occurs
    "version": "1.0",
    //When the version above was created
    "updated": "2020-07-21",
    //A link to documentation about the packages in the image
    //This needs to be properly formatted .json file. For examples, see the bucket linked below
    //If you don't wish to generate documentation, leave this set to the empty placeholder below 
    //See the section below for details
    "packages": "https://storage.googleapis.com/terra-docker-image-documentation/placeholder.json",
    //The image URI
    "image": "cumulusprod/pegasus-terra:1.0",
    //If the image needs spark to run. E.g. Hail.
    "requiresSpark": false,
    //This should always be true if you are contributing a community image
    "isCommunity": true
}]
```

This image will show up in the terra UI when either
1. When the documentation script is manually run (on request to #dsp-callisto)
2. When the next batch of images are build (occurs frequently but not with any schedule)

#### Community Images Package Documentaton

You can have a .json file with package versions and the tools that your image uses. You have a few options in terms of documentation
1. If your image fairly static, you can manually create the `.json` file needed and update it as appropriate
2. You can use an empty placeholder for the package documentation, and provide important version callouts in the label

## Merging your PR

Make sure to get two thumbs before merging your PR. We often reach out to the AOU or Bioconductor team to also review changes we are making to their images (Bioconductor team may also want to review changes to `terra-jupyter-r`).

Once you merge your PR, this will automatically kick off a Jenkins job (given title "terra-docker image hash update") to create a PR in Leonardo that bumps the image versions in [reference.conf](https://github.com/DataBiosphere/leonardo/blob/develop/automation/src/test/resources/reference.conf) under automation. This allows for our automation tests in Leonardo to run against your new docker image changes. 

There will be a notification in the slack channel `#dsp-callisto-internal` once this job finishes running with a link to the automatically created Leonardo PR. Make sure to add the JIRA issue number to the title of this PR as well.

The terra-docker image hash update [job](https://fc-jenkins.dsp-techops.broadinstitute.org/job/swatomation-pipeline/)  mentioned above determines which images (including derived images) have been changed and builds each image with the appropriate tag.


## Merging the terra-docker image hash update job PR

Once all automation tests (including coverage) have passed, you can merge this PR with the approval of one team member.

Merging this PR will automatically kick off another Jenkins [job](https://fc-jenkins.dsp-techops.broadinstitute.org/job/leonardo-dataproc-image/) (given title "Automated custom-image hash update"). This job generates a file called `terra-docker-versions-new.json` which we will use later.

There will be a notification in the slack channel `#dsp-callisto-internal` as well once this job finishes running with a link to the automatically created Leonardo PR. Make sure to also add the JIRA issue number to the title of this PR. If there is no JIRA issue number, please create a JIRA ticket for tracking purposes. In the ticket description, include any information provided by the contributor and fill out the security impact description as needed. 

## Merging the terra-docker custom image hash update job PR

Once you have a team member's approval, you can merge this PR. Merging this PR means that the new terra-docker versions will be available in Leonardo. If there are any Leo changes that go along with your `terra-docker` changes, this is a good place to push them to.

## Terra UI representation

Once the Terra-Docker changes have been released, we can update Terra UI to display these new image versions.

The leonardo-build-terra-docker job builds this repo, and after each build it will re-generate a master version file, and upload it under `gs://terra-docker-image-documentation/terra-docker-versions-new.json`. The bucket location is [here](https://console.cloud.google.com/storage/browser/terra-docker-image-documentation?authuser=1&project=broad-dsp-gcr-public&rapt=AEjHL4NRGpDcVgK-6J704V1iQh_pDdlrm5lR0OylMI3biUiEAQkOvDuqsN9U7tFS3woVdP0KQrT1mpue7Oyk6slJ1fisoxOVVQ). This master version file contains an entry for each image that will appear in the UI. Make sure the contents of this file look good. 

Before the Leo PR is merged into develop, the user will need to copy the  `terra-docker-versions-new.json` with the new images by doing `gsutil cp gs://terra-docker-image-documentation/terra-docker-versions-new.json gs://terra-docker-image-documentation/terra-docker-versions-candidate.json` using their Broad account. The remainder of the update process will be covered through Leo deployment and promotion. As part of reliability changes, the versions file will live in the corresponding bucket with the following name convention: `terra-docker-image-documentation-{environment}` under the DSDE {Environment} project. 
