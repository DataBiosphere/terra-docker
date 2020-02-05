## 0.0.8 - 02/05/2020

- Fix bug in `google_sign_in.js` in the base image
   - See https://broadworkbench.atlassian.net/browse/IA-1653

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.8`

## 0.0.7 - 01/17/2020

- Make image locally runnable with:
   - `docker run --rm -it -p 8000:8000 <image>`
- Add FISS to base image
- Add OpenJDK 11 to base image

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.7`

## 0.0.6 - 11/26/2019

- Fix `WORKSPACE_BUCKET` environment variable

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.6`

## 0.0.5 - 11/16/2019

- Remove apt-get upgrade for security purposes

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.5`

## 0.0.4 - 10/18/2019

- Fix a bug in google_sign_in.js
- Fix WORKSPACE_NAME environment variable
  
Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.4`

## 0.0.3 - 10/09/2019

Check Metadata and lock interval on extension are now staggered

## 0.0.2 - 10/01/2019

Lint the .js extension files

## 0.0.1 - 08/21/2019

- Extends Ubuntu base image
- Add google-cloud-sdk
- Add Python 3.7
- Add pip
- Add conda
- Add Jupyter & JupyterLab
- Add Leonardo customizations/extensions

Image URL: `us.gcr.io/broad-dsp-gcr-public/terra-jupyter-base:0.0.1`
