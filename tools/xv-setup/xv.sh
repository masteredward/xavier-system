#!/bin/bash

IMAGE=${1}

docker run --rm -it --privileged \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/xavier/sources:/sources \
  xv ${IMAGE}