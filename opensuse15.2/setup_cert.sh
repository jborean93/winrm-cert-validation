#!/usr/bin/env bash

sed -i 's|%SYSTEM_DIR%|/etc/ssl/certs|g' inventory.ini
sed -i 's|%SYSTEM_FILE%|/etc/ssl/ca-bundle.pem|g' inventory.ini

cp ca.pem /etc/pki/trust/anchors
update-ca-certificates
c_rehash
