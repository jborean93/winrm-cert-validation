#!/usr/bin/env bash

# Add the CA cert to the System trust store
cp ca.pem /usr/local/share/ca-certificates/ca.crt  # This extension is required
update-ca-certificates

# Cannot run c_rehash becuase the Python version with Ubuntu 14.04 does not support verifying certs with a dir.
