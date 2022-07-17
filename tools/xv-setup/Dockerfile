FROM fedora:36

RUN dnf install ansible git -y \
  && dnf clean all

COPY /xv-ansible-playbook.yaml /xv-ansible-playbook.yaml

CMD ansible-playbook /xv-ansible-playbook.yaml -vv