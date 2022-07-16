FROM fedora:36

RUN dnf install ansible git -y \
  && dnf clean all

CMD ansible-playbook /host/opt/xavier/system/tools/xv-setup/xv-ansible-playbook.yaml -vv