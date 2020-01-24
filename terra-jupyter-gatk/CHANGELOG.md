## 0.0.10 - 01/17/2020

- Update `terra-jupyter-python` version to `0.0.8`
- Update `terra-jupyter-r` version to `0.0.9`
- Make docker image locally runnable with:
   - `docker run --rm -it -p 8000:8000 <image>`
- Remove `default-jre` and `default-jdk` since they are now provided in the base image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.10`

## 0.0.9 - 1/15/2020

- Update `terra-jupyter-python` version to `0.0.7`
- Update `terra-jupyter-r` version to `0.0.8`

Image URL: us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.9

## 0.0.8 - 1/11/2020

- Upgrade GATK version to `4.1.4.1`

Image URL: us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.8

## 0.0.7 - 1/2/2020

- Upgrade `terra-jupyter-python` version

Image URL: us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.7

## 0.0.6 - 11/26/2019

- Fix `WORKSPACE_BUCKET` environment variable

Image URL: us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.6

## 0.0.5 - 11/22/2019
- Update `terra-jupyter-r` version to `0.0.6`

`Image URL: us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.5`

## 0.0.4 - 11/16/2019
- Update `terra-jupyter-r` version to `0.0.5`
- Update `terra-jupyter-python` version to `0.0.4`
- Remove apt-get upgrade for security purposes

`Image URL: us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.4`

## 0.0.3 - 10/18/2019
- Update `terra-jupyter-r` version to `0.0.4`

`Image URL: us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.3`

## 0.0.2 - 10/10/2019

Use version 0.0.2 of python image

## 0.0.1 - 09/24/2019

- added all from terra-jupyter-python:0.0.1
- added all from terra-jupyter-r:0.0.3
- added Open JDK
- added GATK 4.1.3.0
- added Samtools

