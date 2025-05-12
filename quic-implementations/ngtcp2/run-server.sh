#!/bin/bash

set -x

CC=$(pos_get_variable -r cc)
GSO=$(pos_get_variable -r gso)

if [[ $? != 0 ]]; then
    CC="cubic"
    GSO=1
fi

if [ "$GSO" -eq "0" ]; then
	GSO="--max-gso-dgrams=1"
else
	GSO=""
fi

if [ $TESTCASE != "goodput" ]; then
    echo "exited with code 127"
    exit 127
fi

SSLKEYLOGFILE="sslkeys.log" ./http_server \
    -q -d $WWW \
    $IP $PORT \
    --cc=$CC \
    ${CERTS}priv.key \
    ${CERTS}cert.pem \
    $GSO

exit 0
