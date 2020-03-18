#!/usr/bin/env bash

# Add the CA cert to the System trust store
cp ca.pem /etc/pki/ca-trust/source/anchors/
update-ca-trust extract

# Creates a symlink hash of ca-bundle.crt in /etc/pki/tls/certs required when ca path is a dir. This is part of the
# openssl-perl package.
c_rehash
