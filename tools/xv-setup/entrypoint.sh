#!/bin/bash

if [[ ! -f "/host/opt/xavier/system/xv-setup.yaml" ]]; then
  cp /host/opt/xavier/system/xv-setup.example.yaml /host/opt/xavier/system/xv-setup.yaml
fi

exec "$@"