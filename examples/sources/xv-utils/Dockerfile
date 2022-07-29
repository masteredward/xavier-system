FROM fedora:36
# FROM ubuntu:22.04

RUN dnf update -y \
  && dnf install -y \
    git \
    passwd \
    openssh-clients \
    openssh-server \
    shadow-utils \
    zsh \
  && dnf clean all

# RUN apt update \
#   && apt full-upgrade -y \
#   && apt install -y \
#     curl \
#     git \
#     openssh-client \
#     openssh-server \
#     zsh \
#   && rm -rf /var/lib/apt/lists/*

COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx

COPY /requirements.txt /tmp/requirements.txt

RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 \
  && pip install --no-cache-dir -r /tmp/requirements.txt \
  && pip cache purge \
  && rm /tmp/requirements.txt -f

RUN ssh-keygen -A && passwd -d root \
  # && mkdir -p /run/sshd \
  && printf "\nPasswordAuthentication no\nPermitUserEnvironment yes\n" >> /etc/ssh/sshd_config

RUN usermod -s /usr/bin/zsh root

COPY /entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]

CMD /usr/sbin/sshd -De