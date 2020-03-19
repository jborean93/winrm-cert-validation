#!/usr/bin/env bash

sed -i 's|%SYSTEM_DIR%|/etc/pki/tls/certs|g' inventory.ini
sed -i 's|%SYSTEM_FILE%|ca-bundle.crt|g' inventory.ini

cp ca.pem /etc/pki/ca-trust/source/anchors/
update-ca-trust extract
c_rehash
