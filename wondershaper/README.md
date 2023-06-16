# Dockerfile and Entrypoint for Wondershaper
This Dockerfile and associated entrypoint script provide a way to set up and run Wondershaper, a network traffic shaping tool, within a Docker container. The Docker image is already published and available at us.gcr.io/wondershaper/wondershaper:latest. It is not necessary to republish the image unless modifications are required.

## Dockerfile
The Dockerfile sets up an Ubuntu-based environment, installs the required dependencies, and installs Wondershaper from the official GitHub repository. It also includes an entrypoint script that configures the network interface and applies bandwidth limits using Wondershaper.

To build the Docker image locally, use the following command:

```
docker build -t wondershaper-local-image .
```

To run the local image, use:
```
docker run  --privileged --network=host  wondershaper-local-image
```

## Entrypoint Script (entrypoint.sh)
The entrypoint script (entrypoint.sh) is copied into the Docker image. It performs the following tasks:

Sets the network interface (eth0) and the desired upload bandwidth limit (in kilobits per second).
Applies the bandwidth limits to the network interface using Wondershaper.
Keeps the container running by executing the tail -f /dev/null command.

## Running the Docker Image
To run the Wondershaper container using the published image (us.gcr.io/wondershaper/wondershaper:latest), execute the following command:

```
docker run --name wondershaper-container us.gcr.io/broad-dsp-gcr-public/wondershaper:latest
```

Please note that the image is already published, so you don't need to perform any additional steps unless you want to modify the Dockerfile or the entrypoint script.


Remember to replace wondershaper-container with your preferred container name.



