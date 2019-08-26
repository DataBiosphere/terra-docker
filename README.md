This repo provides docker images for running jupyter notebook in [Terra](https://app.terra.bio)

[terra-jupyter-base](terra-jupyter-base/README.md)

[terra-jupyter-r](terra-jupyter-r/README.md)

# Development
Using git secrets
Make sure git secrets is installed:
```
brew install git-secrets
```
Ensure git-secrets is run: If you use the rsync script to run locally you can skip this step

```
cp -r hooks/ .git/hooks/
chmod 755 .git/hooks/apply-git-secrets.sh
```

# Testing
## Test images on leonardo
Follow [instructions](https://broadworkbench.atlassian.net/wiki/spaces/AP/pages/100401153/Testing+notebook+functionality+with+Fiab)

## Automation Tests
[Here](https://github.com/DataBiosphere/leonardo/tree/develop/automation/src/test/scala/org/broadinstitute/dsde/workbench/leonardo/notebooks) are automation tests for various docker image, please update the image hash for relevant tests.