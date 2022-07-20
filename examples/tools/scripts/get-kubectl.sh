#!/bin/bash

VERSION=${1}
OS_ARCH=$(uname -m)
BIN_PATH="/root/bin/kubectl"

case ${OS_ARCH} in
  aarch64)
    ARCH="arm64"
    ;;
  x86_64)
    ARCH="amd64"
    ;;
  *)
    echo "Unsupported Architeture: ${OS_ARCH}"
    exit
    ;;
esac

case ${VERSION} in
  "")
    echo "Enter an EKS version - Supported versions: 1.18 to 1.22"
    exit
    ;;
  1.22)
    curl -L https://s3.us-west-2.amazonaws.com/amazon-eks/1.22.6/2022-03-09/bin/linux/${ARCH}/kubectl -o ${BIN_PATH}
    ;;
  1.21)
    curl -L https://s3.us-west-2.amazonaws.com/amazon-eks/1.21.2/2021-07-05/bin/linux/${ARCH}/kubectl -o ${BIN_PATH}
    ;;
  1.20)
    curl -L https://s3.us-west-2.amazonaws.com/amazon-eks/1.20.4/2021-04-12/bin/linux/${ARCH}/kubectl -o ${BIN_PATH}
    ;;
  1.19)
    curl -L https://s3.us-west-2.amazonaws.com/amazon-eks/1.19.6/2021-01-05/bin/linux/${ARCH}/kubectl -o ${BIN_PATH}
    ;;
  1.18)
    curl -L https://s3.us-west-2.amazonaws.com/amazon-eks/1.18.9/2020-11-02/bin/linux/${ARCH}/kubectl -o ${BIN_PATH}
    ;;
  *)
    echo "Unsupported Version: ${VERSION} - Supported versions: 1.18 to 1.22"
    exit
    ;;
esac

chmod +x ${BIN_PATH}
kubectl version --client --short