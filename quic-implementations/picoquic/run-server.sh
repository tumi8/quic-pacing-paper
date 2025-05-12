#!/bin/bash

set -x

GSO=$(pos_get_variable -r gso)
CC=$(pos_get_variable -r cc)

if [[ $? != 0 ]]; then
    CC="cubic"
fi

case $GSO in
	False|false|No|no|Off|off|0)
		GSO='-0'
		;;
	*)
		GSO=''
		;;
esac

if [[ $TESTCASE != "goodput" ]]; then
    echo "exited with code 127"
    exit 127
fi

./picoquicdemo $GSO \
    -c $CERTS/cert.pem \
    -k $CERTS/priv.key \
    -p $PORT \
    -a $IP \
    -w $WWW \
    -G $CC \
    -n $SERVERNAME
ret=$?

exit $?
