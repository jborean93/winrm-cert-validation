#!/usr/bin/env bash

sed -i 's|%SYSTEM_DIR%|/etc/ssl/certs|g' inventory.ini
sed -i 's|%SYSTEM_FILE%|ca-certificates.crt|g' inventory.ini

cp ca.pem /usr/local/share/ca-certificates/ca.crt  # This extension is required
update-ca-certificates
c_rehash
