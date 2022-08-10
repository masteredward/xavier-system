#!/bin/bash

mkdir -p /opt/xavier/linuxbrew
chown 1000:1000 /opt/xavier/linuxbrew
docker build /opt/xavier/system/tools/homebrew-installer -t homebrew-installer
docker run --rm -v /opt/xavier/linuxbrew:/home/linuxbrew homebrew-installer
cp -f /opt/xavier/system/tools/homebrew-installer/homebrew.zsh /opt/xavier/root/.oh-my-zsh/custom/homebrew.zsh
cp -f /opt/xavier/system/tools/homebrew-installer/homebrew_bash /opt/xavier/linuxbrew/.bash_profile
chown 1000:1000 /opt/xavier/linuxbrew/.bash_profile
