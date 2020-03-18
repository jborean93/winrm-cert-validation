#!/usr/bin/env bash

# Create CA cert and key
openssl genrsa -aes256 -out ca.key -passout pass:password
openssl req -new -x509 -days 365 -key ca.key -out ca.pem -subj "/CN=Ansible Root" -passin pass:password

# Generate cert and key for WinRM certificate
openssl genrsa -aes256 -out cert.key -passout pass:password
openssl req -new -sha256 -subj "/CN=$1" -key cert.key -out cert.csr -config openssl.conf -reqexts req -passin pass:password
openssl x509 -req -in cert.csr -CA ca.pem -CAkey ca.key -CAcreateserial -out cert.pem -days 365 -extfile openssl.conf -extensions req -passin pass:password

# Generate pfx for Windows cert store
openssl pkcs12 -export -out cert.pfx -inkey cert.key -in cert.pem -passin pass:password -passout pass:password
