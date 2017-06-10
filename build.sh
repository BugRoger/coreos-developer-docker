#!/bin/bash

set -e

COREOS_TRACK=${2:-beta}
COREOS_VERSION=${3:-1409.1.0}

DEV_CONTAINER=coreos_developer_container.bin.${COREOS_VERSION}
SITE=${COREOS_TRACK}.release.core-os.net/amd64-usr

echo Downloading CoreOS ${COREOS_TRACK} developer image ${COREOS_VERSION}
curl -L https://${SITE}/${COREOS_VERSION}/coreos_developer_container.bin.bz2 -o ${DEV_CONTAINER}.bz2
echo Decompressing
bunzip2 -k ${DEV_CONTAINER}.bz2

sudo systemd-nspawn -i ${DEV_CONTAINER} \
  --bind=${PWD}/bin2docker.sh:/bin2docker.sh \
  --bind=${PWD}:/mnt/host \
  /bin/bash -x /bin2docker.sh

docker load -i coreos_developer_container.tar
