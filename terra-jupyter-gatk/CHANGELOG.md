## 1.0.3 - 06/29/2020

- Image package installations should not persist
- Update `terra-jupyter-r` version to `1.0.3`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:1.0.3`

## 1.0.2 - 06/26/2020

- Update `terra-jupyter-r` version to `1.0.2`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:1.0.2`

## 1.0.1 - 06/15/2020

- Update `terra-jupyter-python` base image to `0.0.32` and `terra-jupyter-r` base image to `1.0.1`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:1.0.1`

## 1.0.0 - 05/21/2020

- Update `terra-jupyter-r` base image to `1.0.0`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:1.0.0`

## 0.0.16 - 05/18/2020

- Update `terra-jupyter-python` base image to `0.0.12` and `terra-jupyter-r` base image to `0.0.14`
   - Adds jupyter notebook extension collapsible headers and code-folding

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.16`

## 0.0.15 - 04/28/2020

- Update `terra-jupyter-python` base image to `0.0.11`
   - Add Google Cloud support to pysam

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.15`

## 0.0.14 - 04/24/2020

- Update `terra-jupyter-r` version to `0.0.13`
- Update `terra-jupyter-gatk` version to `0.0.14`

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.14`

## 0.0.13 - 02/26/2020

- Install OpenJDK 8 instead of OpenJDK 11 to be compatible with GATK
   - Fixes https://broadworkbench.atlassian.net/browse/IA-1706

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.13`

## 0.0.12 - 02/25/2020

- Update `terra-jupyter-python` version to `0.0.10`
- Update `terra-jupyter-r` version to `0.0.11`
    - Fixes https://broadworkbench.atlassian.net/browse/IA-1676

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.12`                       

## 0.0.11 - 02/05/2020

- Update `terra-jupyter-python` version to `0.0.9`
- Update `terra-jupyter-r` version to `0.0.10`
- Fixes bug: https://broadworkbench.atlassian.net/browse/IA-1653

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-gatk:0.0.11`

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

