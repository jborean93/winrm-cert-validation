FROM centos:8

WORKDIR /root

RUN yum install epel-release -y && \
    yum install -y \
      ansible \
      openssl \
      openssl-perl \
      python3 \
      python3-pip \
      python3-requests \
      python3-virtualenv \
      which
RUN sed -i -E 's%#!/usr/bin/python([0-9][0-9]*).([0-9][0-9]*)(.*)%#!/usr/bin/python\1.\2%g' $(which ansible)  # Ansible from yum has the -s flag which means packages installed by pip are ignored (we don't want that)
RUN python3 -m pip install \
      pypsrp \
      pywinrm
RUN python3 -m virtualenv ansible-venv && \
    ansible-venv/bin/python -m pip install \
      ansible \
      pypsrp \
      pywinrm
COPY cert_setup/ca.pem ca.pem
COPY cert_setup/inventory.ini inventory.ini
COPY cert_setup/bootstrap.sh bootstrap.sh
COPY centos8/setup_cert.sh setup_cert.sh
RUN ./setup_cert.sh

ENTRYPOINT ["/bin/sh", "-c", "/bin/bash /root/bootstrap.sh && /bin/bash"]
