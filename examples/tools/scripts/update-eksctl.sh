#!/bin/bash

OS_ARCH=$(uname -m)
BIN_PATH="/root/bin/eksctl"

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

curl -L https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_${ARCH}.tar.gz | tar xz -C /tmp
mv /tmp/eksctl ${BIN_PATH}

chmod +x ${BIN_PATH}
echo -n "EKSCTL Version: "
eksctl version