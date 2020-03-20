FROM archlinux:latest

WORKDIR /root

RUN pacman -Sy --noconfirm \
      ansible \
      ca-certificates-utils \
      openssl \
      python \
      python-pip \
      python-pywinrm \
      python-requests \
      python-virtualenv
RUN python -m pip install \
      pypsrp
RUN python -m virtualenv ansible-venv && \
    ansible-venv/bin/python -m pip install \
      ansible \
      pypsrp \
      pywinrm
COPY cert_setup/ca.pem ca.pem
COPY cert_setup/inventory.ini inventory.ini
COPY cert_setup/bootstrap.sh bootstrap.sh
COPY archlinux/setup_cert.sh setup_cert.sh
RUN ./setup_cert.sh

ENTRYPOINT ["/bin/sh", "-c", "/bin/bash /root/bootstrap.sh && /bin/bash"]
