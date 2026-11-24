# terra-core image

Minimal OS layer shared by Terra tool images. It has no tool of its own: no Jupyter, RStudio,
Python, R, conda or CUDA. Use a tool image (for example [terra-base](../terra-base/README.md) or
[terra-app](../terra-app/README.md)) as the base of a custom image, not this one.

## Image contents

`terra-core` extends `ubuntu:26.04` with:

- `bash`, `ca-certificates`, `curl`, `jq`, `less`, `locales`, `procps`, `sudo`
- The `en_US.UTF-8` locale (`LC_ALL=en_US.UTF-8`)
- `welder-user` with UID 1001, matching [Welder](https://github.com/DataBiosphere/welder)

The default `ubuntu` user (UID 1000) is removed so that tool images can use UID 1000.

It does not include the Google Cloud SDK; tool images add it when they need it.

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).

## Building the image

```bash
docker build terra-core -t us.gcr.io/broad-dsp-gcr-public/terra-core:{version}
```
