FROM centos:7

WORKDIR /root

RUN yum install epel-release -y && \
    yum install -y \
      ansible \
      python \
      python-pip \
      python-virtualenv \
      python-winrm \
      openssl \
      openssl-perl  # Add c_rehash
RUN python -m pip install --no-deps pypsrp && pip install -U ntlm-auth  # Need to be selective here to avoid requests being reinstalled with a newer version from pip
RUN python -m virtualenv ansible-venv && \
    ansible-venv/bin/python -m pip install \
      ansible \
      pypsrp \
      pywinrm
COPY cert_setup/ca.pem ca.pem
COPY cert_setup/inventory.ini inventory.ini
COPY cert_setup/bootstrap.sh bootstrap.sh
COPY centos7/setup_cert.sh setup_cert.sh
RUN ./setup_cert.sh

ENTRYPOINT ["/bin/sh", "-c", "/bin/bash /root/bootstrap.sh && /bin/bash"]
