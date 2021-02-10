# Contributing

`terra-docker` consists of docker images that are compatible with the notebooks service in Terra called Leonardo. We follow the naming convention of `terra-[application]-[image_name]` (for example `terra-jupyter-aou`).

## Opening a PR

We do our work on a feature branch based on master. When you open a pull request, add the JIRA issue number to the PR title. This will make a reference from JIRA to the GitHub issue. Briefly describe your changes in the description section.

This is also a good opportunity to verify that all the appropriate image versions were bumped. It is important to keep in mind which images extend from where ([Image Dependecies](https://github.com/DataBiosphere/terra-docker#image-dependencies)). Make sure to bump the version of the image you are changing and update its reference in all images that extend from it.

You can also run `amm ./updateVersions.sc <image name> <release note>` to upgrade derived images. If you're updating `terra-jupyter-aou` image, please make a pull request similar to [this PR](https://github.com/DataBiosphere/leonardo/pull/1612) (less updating `terra_jupyter_aou_old`).

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

Once all the Leo PRs have been released, we can update Terra UI to display these new image versions.

The leonardo-build-terra-docker job builds this repo, and after each build it will re-generate a master version file, and upload it under the name specified in the conf. This master version file contains an entry for each image that will appear in the UI. This file is NOT automatically included in the UI. As of now, we wish to control when we change what shows up in the UI via a manual process. Currently, you must go to the google bucket. In this [bucket](https://console.cloud.google.com/storage/browser/terra-docker-image-documentation?authuser=1&project=broad-dsp-gcr-public&rapt=AEjHL4NRGpDcVgK-6J704V1iQh_pDdlrm5lR0OylMI3biUiEAQkOvDuqsN9U7tFS3woVdP0KQrT1mpue7Oyk6slJ1fisoxOVVQ), you will find a file named `terra-docker-versions-new.json`. Make sure this file looks good to you. Copy this file and name it `terra-docker-versions.json` in console or Run `gsutil mv gs://terra-docker-image-documentation/terra-docker-versions-new.json gs://terra-docker-image-documentation/terra-docker-versions.json` with Broad Google account (this will overwrite the existing `terra-docker-versions.json` file) in google cloud console. The newest images will instantly show up in all UIs on refresh.
