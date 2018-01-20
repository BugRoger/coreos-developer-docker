# CoreOS Container Linux - Development Docker Container

[![Build Status](https://travis-ci.org/BugRoger/coreos-developer-docker.svg?branch=master)](https://travis-ci.org/BugRoger/coreos-developer-docker)
[![Docker Pulls](https://img.shields.io/docker/pulls/bugroger/coreos-developer.svg)]()

This repository automatically builds a Docker container of the CoreOS Container
Linux Development image.

The development image contains a more complete linux including a full compiler
toolchain. It allows to modify, extend or build custom binaries, drivers or libraries
for Container Linux that are not included in the production image.

Here we automatically turn the raw developer image into a Docker container. It
allows us to use the familiar Docker workflow. It is especially nice in
combination with multi-stage Docker builds, which allows to create minimal
transport images without the build chain overhead.

## Travis Configuration

The build is using a cron job that executes the build daily. It creates alpha,
beta and stable images. It first pulls the current versions of each CoreOS
release channel. Then it checks if the corresponding image already exists on
Dockerhub. Only then rebuild the image.

This makes the build indempotent and avoids daily churn on Travis.

With the way CoreOS is promoting versions through the channels, this will
usually only build new alpha versions. There's a maximum latency from release
to availability of this Docker image.

## Docker Image

Find the image on Docker Hub: https://hub.docker.com/r/bugroger/coreos-developer/

```
docker pull bugroger/coreos-developer:1576.5.0
```

## Usage in Docker

In order to use this image for compilation of kernel modules, there is some
additional steps as descripted in the [Container Linux Developer
Guide](https://coreos.com/os/docs/latest/kernel-modules.html).

In Docker the `/proc` filesystem does not work as expected, so a few
modifications are required. 

This is an example multi-stage `Dockerfile`:

```
ARG COREOS_VERSION=1576.5.0

FROM bugroger/coreos-developer:${COREOS_VERSION} as BUILD

RUN emerge-gitclone
RUN . /usr/share/coreos/release && \
  git -C /var/lib/portage/coreos-overlay checkout build-${COREOS_RELEASE_VERSION%%.*}
RUN emerge -gKv coreos-sources > /dev/null
RUN cp /usr/lib64/modules/$(ls /usr/lib64/modules)/build/.config /usr/src/linux/
RUN make -C /usr/src/linux modules_prepare

# Your custom code here
# WORKDIR /tmp/build
# RUN git clone ... && make all

FROM alpine 
COPY --from=BUILD /tmp/build/output /opt/custom
```

And execute with:

```
docker build \
  --build-arg COREOS_VERSION=1662.0.0 \
  --tag ${DOCKER_USERNAME}/${IMAGE}:${COREOS_VERSION}-${DRIVER_VERSION} \
  --rm \
  .
```

A complete example using this technique can be seen at
[coreos-nvidia-driver](https://github.com/BugRoger/coreos-nvidia-driver)
