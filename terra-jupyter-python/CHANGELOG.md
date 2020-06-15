## 0.0.13 - 06/15/2020

- Update `terra-jupyter-base` image version to `0.0.11`

Image URL `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.13`

## 0.0.12 - 05/18/2020

- Update `terra-jupyter-base` image version to `0.0.10`
   - Adds jupyter notebook extension collapsible headers and code-folding

Image URL `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.12`

## 0.0.11 - 04/17/2020

- Add Google Cloud support to pysam.
   
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.11`

## 0.0.10 - 02/25/2020

- Update `terra-jupyter-base` version to `0.0.9`
   - Fixes https://broadworkbench.atlassian.net/browse/IA-1676
   
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.10`

## 0.0.9 - 02/05/2020

- Update `terra-jupyter-base` version to `0.0.8`
   - Fixes https://broadworkbench.atlassian.net/browse/IA-1653

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.9`

## 0.0.8 - 01/17/2020

- Update `terra-jupyter-base` version to `0.0.7`
- Make docker image locally runnable with:
   - `docker run --rm -it -p 8000:8000 <image>`
- Remove FISS from this image since it's now included in the base
- Add OpenJDK 11

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.8`

## 0.0.7 - 01/15/2020

- Install `pandas-profiling` version `2.4.0`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.7`

## 0.0.6 - 12/12/2019

- Upgrade pandas from 0.23.4 to 0.25.3
- Upgrade pandas-gbq from 0.11.0 to 0.12.0
- Upgrade `google-cloud-bigquery` to `1.23.1`
- Upgrade `google-cloud-bigquery-datatransfer` to `0.4.1`
- Upgrade `google-cloud-datastore` to `1.10.0`
- Upgrade `google-cloud-resource-manager` to `0.30.0`
- Upgrade `google-cloud-storage` to `1.23.0`
- Upgrade `firecloud` to `0.16.25`
- Upgrade `six` to `1.13.0`
- Upgrade `setuptools` to `42.0.2`
- Install `pdoc3` instead of `pdoc`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.6`

## 0.0.5 - 11/26/2019

- Fix `WORKSPACE_BUCKET` environment variable

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.5`

## 0.0.4 - 11/16/2019

- Update `terra-jupyter-base` version to `0.0.5`
- Removed apt-get upgrade for security purposes

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.4`

## 0.0.3 - 10/18/2019

- Update `terra-jupyter-base` version to `0.0.4`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.3`

## 0.0.2 - 10/10/2019

Use jupyter base image 0.0.3

## 0.0.1 - 08/28/2019

- added pandas-gqb
- removed jupyter, jupyter-lab, unzip as they are in they base image
- removed google-cloud-core, was already satisfied as a dependency from other packages

| Package | Former Version | Current Version |
|---|---|---|
| google-api-core | 1.5.0 | 1.6.0 |
| keras | 2.2.0 | 2.1.6 |
| markdown | 2.6.9 | 2.4.1 |
| pysam | 0.13 | 0.15.1 |
| scipy | 1.0.0 | 1.2 |
| tensorflow | 1.9.0 | 2.0.0a0 |
| certifi |	2016.2.28 | 2017.4.17 |
| google-cloud-bigquery | 1.7.0 | 1.9.0 |

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-python:0.0.1`
