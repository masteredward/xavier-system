FROM amazonlinux:2022

COPY --from=docker/buildx-bin:latest /buildx /usr/libexec/docker/cli-plugins/docker-buildx

RUN curl -sSL https://bootstrap.pypa.io/get-pip.py | python3 \
  && pip install python-on-whales pyyaml \
  && pip cache purge

COPY /xv.py /xv.py

RUN chmod +x /xv.py

ENTRYPOINT ["/xv.py"]