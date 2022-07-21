FROM fedora:36

RUN dnf install ansible git -y \
  && dnf clean all

COPY /entrypoint.sh /entrypoint.sh

COPY /xv-ansible-playbook.yaml /xv-ansible-playbook.yaml

RUN chmod +x /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

CMD ansible-playbook /xv-ansible-playbook.yaml -vv