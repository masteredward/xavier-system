FROM debian:11-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update \
  && apt install -y \
      build-essential \
      procps \
      curl \
      file \
      git \
  && rm -rf /var/lib/apt/lists/*

RUN useradd -s /bin/bash linuxbrew

USER linuxbrew

CMD curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh | bash