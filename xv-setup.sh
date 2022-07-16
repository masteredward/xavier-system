#!/bin/bash

docker build /opt/xavier/system/tools/xv-setup/ -t xv-setup

docker run --rm -it --privileged \
  -v /:/host \
  xv-setup