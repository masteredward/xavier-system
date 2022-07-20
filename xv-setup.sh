#!/bin/bash

if [[ $HOSTNAME == "xv-utils" ]]; then
  docker build /xavier/system/tools/xv-setup/ -t xv-setup
else
  docker build /opt/xavier/system/tools/xv-setup/ -t xv-setup
fi

docker run --rm -it --privileged \
  -v /:/host \
  xv-setup