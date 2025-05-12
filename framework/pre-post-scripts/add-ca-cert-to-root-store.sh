#!/bin/bash

set -eux

CERTS_DIR=$(pos_get_variable --remote certs_dir)

if ls ${CERTS_DIR}/ca.pem 1> /dev/null 2>&1; then
    cp ${CERTS_DIR}/ca.pem /usr/local/share/ca-certificates/interop-ca.crt 
    update-ca-certificates 
fi
