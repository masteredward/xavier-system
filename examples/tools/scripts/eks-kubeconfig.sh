#!/bin/bash

CLUSTER_NAME=${1}

docker run --rm -it \
  -v /root/.aws:/root/.aws \
  -v /opt/xavier/root/.kube:/root/.kube \
  -e AWS_PROFILE=${AWS_PROFILE} \
  amazon/aws-cli eks \
  update-kubeconfig \
  --name ${CLUSTER_NAME}