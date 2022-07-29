FROM ubuntu:22.04
# FROM debian:11-slim

ARG DEBIAN_FRONTEND=noninteractive

RUN apt update \
  && apt full-upgrade -y \
  && apt install -y \
    curl \
    git \
    openssh-client \
    openssh-server \
    zsh \
  && rm -rf /var/lib/apt/lists/*

RUN ssh-keygen -A && passwd -d root \
  && mkdir -p /run/sshd \
  && printf "\nPasswordAuthentication no\nPermitUserEnvironment yes\n" >> /etc/ssh/sshd_config

RUN usermod -s /usr/bin/zsh root

COPY /entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]

CMD /usr/sbin/sshd -De