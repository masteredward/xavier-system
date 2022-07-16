#!/bin/bash

IMAGE=${1}

docker run --rm -it --privileged \
  -v /usr/bin/docker:/usr/bin/docker \
  -v /var/run/docker.sock:/var/run/docker.sock \
  -v /opt/xavier/system/xv.yaml:/xv.yaml \
  -v /opt/xavier/system/sources:/sources \
  xv ${IMAGE}