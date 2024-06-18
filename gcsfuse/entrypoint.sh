#!/bin/bash

# Check if BUCKET_NAMES and MOUNT_VOLUMES are set
if [ -z "$BUCKET_NAMES" ] || [ -z "$MOUNT_VOLUMES" ]; then
  echo "BUCKET_NAMES and MOUNT_VOLUMES environment variables are not set. Exiting..."
  exit 1
fi

# Convert space-separated strings to arrays
IFS=' ' read -r -a buckets <<< "$BUCKET_NAMES"
IFS=' ' read -r -a volumes <<< "$MOUNT_VOLUMES"

# Check if the number of buckets and volumes are equal
if [ ${#buckets[@]} -ne ${#volumes[@]} ]; then
  echo "The number of bucket names and mount volumes do not match. Exiting..."
  exit 1
fi

# Iterate over the arrays
for index in "${!buckets[@]}"
do
  bucket=${buckets[index]}
  volume=${volumes[index]}

  # Create the mount directory if it doesn't exist
  mkdir -p $volume

  # Mount the GCS bucket
  gcsfuse --implicit-dirs -o allow_other,rw $bucket $volume
done

# Keep the container running
tail -f /dev/null