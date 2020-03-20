FROM ubuntu:16.04

WORKDIR /root

RUN apt-get update && \
    apt-get install -y \
      openssl \
      python \
      python-pip \
      python-requests \
      python-virtualenv
RUN python -m pip install \
      ansible \
      pypsrp \
      pywinrm \
      cryptography==1.2.3  # Don't break existing pip on the system
RUN python -m virtualenv ansible-venv && \
    ansible-venv/bin/python -m pip install \
      ansible \
      pypsrp \
      pywinrm
COPY cert_setup/ca.pem ca.pem
COPY cert_setup/inventory.ini inventory.ini
COPY cert_setup/bootstrap.sh bootstrap.sh
COPY ubuntu1604/setup_cert.sh setup_cert.sh
RUN ./setup_cert.sh

ENTRYPOINT ["/bin/sh", "-c", "/bin/bash /root/bootstrap.sh && /bin/bash"]
