FROM ubuntu:18.04

WORKDIR /root

RUN apt-get update && \
    apt-get install -y \
      python3 \
      python3-pip \
      python3-requests \
      python3-virtualenv \
      openssl
RUN python3 -m pip install \
      ansible \
      pypsrp \
      pywinrm
RUN python3 -m virtualenv ansible-venv --python=python3 && \
    ansible-venv/bin/python -m pip install \
      ansible \
      pypsrp \
      pywinrm
COPY cert_setup/ca.pem ca.pem
COPY cert_setup/inventory.ini inventory.ini
COPY cert_setup/bootstrap.sh bootstrap.sh
COPY ubuntu1804/setup_cert.sh setup_cert.sh
RUN ./setup_cert.sh

ENTRYPOINT ["/bin/sh", "-c", "/bin/bash /root/bootstrap.sh && /bin/bash"]
