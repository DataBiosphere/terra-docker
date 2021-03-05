# terra-jupyter-conda-gatk image

This repo contains the terra-jupyter-conda-gatk image that is compatible with notebook service in [Terra]("https://app.terra.bio/") called Leonardo.

## Image contents

The terra-jupyter-conda-gatk image extends the [terra-jupyter-base](../terra-jupyter-base) image, supported in this repo.

To see the complete contents of this image please see the [Dockerfile](./Dockerfile).


## Build and Run Instructions

- Build the image
```
docker build . -t terra-jupyter-conda-gatk
```

- Run the container, Then navigate a browser to http://localhost:8000/notebooks to access the Jupyter UI.
```
docker run --rm -it -p 8000:8000 terra-jupyter-conda-gatk
```

- Test it by running the [ravi-gatk-cnn-tutorial.ipynb notebook](./ravi-gatk-cnn-tutorial.ipynb)

- You can gain root access and open a bash terminal as follows:
```
docker run --rm -it -u root -p 8000:8000 --entrypoint /bin/bash terra-jupyter-conda-gatk
```

