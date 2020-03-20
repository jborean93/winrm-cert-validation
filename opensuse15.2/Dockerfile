FROM opensuse/leap:15.2

WORKDIR /root

RUN zypper --non-interactive install --auto-agree-with-licenses --no-recommends \
      ansible \
      ca-certificates \
      openssl \
      python3 \
      python3-pip \
      python3-pywinrm \
      python3-requests \
      python3-virtualenv
RUN python3 -m pip install \
      pypsrp
RUN python3 -m virtualenv ansible-venv && \
    ansible-venv/bin/python -m pip install \
      ansible \
      pypsrp \
      pywinrm
COPY cert_setup/ca.pem ca.pem
COPY cert_setup/inventory.ini inventory.ini
COPY cert_setup/bootstrap.sh bootstrap.sh
COPY opensuse15.2/setup_cert.sh setup_cert.sh
RUN ./setup_cert.sh

ENTRYPOINT ["/bin/sh", "-c", "/bin/bash /root/bootstrap.sh && /bin/bash"]
