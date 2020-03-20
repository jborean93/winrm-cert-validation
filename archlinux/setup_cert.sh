#!/usr/bin/env bash

sed -i 's|%SYSTEM_DIR%|/etc/ssl/certs|g' inventory.ini
sed -i 's|%SYSTEM_FILE%|/etc/ssl/certs/ca-certificates.crt|g' inventory.ini

cp ca.pem /etc/ca-certificates/trust-source/anchors
update-ca-trust extract
c_rehash
