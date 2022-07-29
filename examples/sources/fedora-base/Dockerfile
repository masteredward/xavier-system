FROM fedora:36

RUN dnf update -y \
  && dnf install -y \
    git \
    passwd \
    openssh-clients \
    openssh-server \
    shadow-utils \
    zsh \
  && dnf clean all

RUN ssh-keygen -A && passwd -d root \
  && printf "\nPasswordAuthentication no\nPermitUserEnvironment yes\n" >> /etc/ssh/sshd_config

RUN usermod -s /usr/bin/zsh root

COPY /entrypoint.sh /entrypoint.sh

RUN chmod +x /entrypoint.sh

EXPOSE 22

ENTRYPOINT ["/entrypoint.sh"]

CMD /usr/sbin/sshd -De