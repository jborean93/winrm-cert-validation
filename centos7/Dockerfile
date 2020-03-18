FROM centos:7

WORKDIR /root

# Ensure Ansible and other pre-reqs are installed
RUN yum install epel-release -y && \
    yum install python python-pip openssl openssl-perl -y
RUN python -m pip install ansible pywinrm pypsrp

# Copy the CA cert file to use for trust
COPY cert_setup/ca.pem ca.pem

# Copy a test inventory file to test out various permutations
COPY cert_setup/inventory.ini inventory.ini

# Make sure we can resolve the actual hostname of the cert
COPY cert_setup/bootstrap.sh bootstrap.sh

COPY centos7/setup_cert.sh setup_cert.sh
RUN ./setup_cert.sh

ENTRYPOINT ["/bin/sh", "-c", "/bin/bash /root/bootstrap.sh && /bin/bash"]