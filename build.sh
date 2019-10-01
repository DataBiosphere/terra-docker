#!/bin/bash
# Run `gcloud auth configure-docker --quiet` before running this script
# Example: ./build.sh terra-jupyter-base

PYTHON_IMAGES=("terra-jupyter-hail" "terra-jupyter-python" "terra-jupyter-base" "terra-jupyter-bioconductor" "terra-jupyter-gatk")
R_IMAGES=("terra-jupyter-r" "terra-jupyter-bioconductor" "terra-jupyter-gatk")

function contains() {
    local n=$#
    local value=${!n}
    for ((i=1;i < $#;i++)) {
        if [ "${!i}" == "${value}" ]; then
            echo "true"
            return 0
        fi
    }
    echo "false"
    return 1
}

IMAGE_DIR=$1
VERSION=$(cat $IMAGE_DIR/VERSION)

TAG_NAME=$(git log --pretty=format:'%h' -n 1)
REPO="us.gcr.io/broad-dsp-gcr-public"
DOCUMENTATION_BUCKET="gs://terra-docker-image-documentation"

IMAGE_EXISTS=$(gcloud container images list-tags $REPO/$IMAGE_DIR | grep $VERSION)

if [ -z "$IMAGE_EXISTS" ]
then
    echo "An image for this version does not exist. Proceeding with build"
else
    echo "An image for the version you are trying to build already exists. Ensure you have updated the VERSION file."
    #unreserved exit code for checking in jenkins
    exit 14
fi

# will fail if you are not gcloud authed as dspci-wb-gcr-service-account
docker run --rm  -v ~/.vault-token:/root/.vault-token:ro broadinstitute/dsde-toolbox:latest vault read --format=json secret/dsde/dsp-techops/common/dspci-wb-gcr-service-account.json | jq .data > dspci-wb-gcr-service-account.json
gcloud auth activate-service-account --key-file=dspci-wb-gcr-service-account.json

docker image build ./$IMAGE_DIR --tag $REPO/$IMAGE_DIR:$TAG_NAME --tag $REPO/$IMAGE_DIR:$VERSION \
    && docker push $REPO/$IMAGE_DIR:$TAG_NAME \
    && docker push $REPO/$IMAGE_DIR:$VERSION

docker run --rm -itd -u root -e PIP_USER=false --entrypoint='/bin/bash' --name $IMAGE_DIR $REPO/$IMAGE_DIR:$TAG_NAME

PYTHON_OUTPUT_FILE="$IMAGE_DIR-$VERSION-python-packages.txt"
R_OUTPUT_FILE="$IMAGE_DIR-$VERSION-r-packages.txt"


#update remote documentation
#determine if we should produce python or R documentation for a package, and upload it to a bucket if so
if [ $(contains "${PYTHON_IMAGES[@]}" "$IMAGE_DIR") == "true" ]; then
    docker exec $IMAGE_DIR pip list > $PYTHON_OUTPUT_FILE;
    echo "gsutil cping $PYTHON_OUTPUT_FILE to $DOCUMENTATION_BUCKET"
    gsutil cp $PYTHON_OUTPUT_FILE $DOCUMENTATION_BUCKET
fi

if [ $(contains "${R_IMAGES[@]}" "$IMAGE_DIR") == "true" ]; then
    #R is a wonderful language that requires you to execute code within a shell to find the packages
    docker exec $IMAGE_DIR sh -c "echo 'ip <- as.data.frame(installed.packages()[,c(1,3:4)]) \n rownames(ip) <- NULL \n ip <- ip[is.na(ip\$Priority),1:2,drop=FALSE] \n print(ip, row.names=FALSE)' > temp.r; Rscript temp.r; rm temp.r" > $R_OUTPUT_FILE
    echo "gsutil cping $R_OUTPUT_FILE to $DOCUMENTATION_BUCKET"
    gsutil cp $R_OUTPUT_FILE $DOCUMENTATION_BUCKET
fi

docker kill $IMAGE_DIR
docker image rm -f $REPO/$IMAGE_DIR:$VERSION
docker image rm -f $REPO/$IMAGE_DIR:$TAG_NAME

echo "Successfully completed build script for $IMAGE_DIR"
