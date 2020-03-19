FROM ubuntu:14.04

WORKDIR /root

# Ensure Ansible and other pre-reqs are installed
RUN apt-get update && \
    apt-get install build-essential libssl-dev libffi-dev python python-dev python-pip openssl -y
RUN python -m pip install ansible pywinrm pypsrp cryptography==2.0.3

# Copy the CA cert file to use for trust
COPY cert_setup/ca.pem ca.pem

# Copy a test inventory file to test out various permutations
COPY cert_setup/inventory.ini inventory.ini

# Make sure we can resolve the actual hostname of the cert
COPY cert_setup/bootstrap.sh bootstrap.sh

COPY ubuntu1404/setup_cert.sh setup_cert.sh
RUN ./setup_cert.sh

ENTRYPOINT ["/bin/sh", "-c", "/bin/bash /root/bootstrap.sh && /bin/bash"]
