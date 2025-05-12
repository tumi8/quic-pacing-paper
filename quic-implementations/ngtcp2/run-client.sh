#!/bin/bash

set -x

CC=$(pos_get_variable -r cc)

if [[ $? != 0 ]]; then
    CC="cubic"
fi

if [ $TESTCASE != "goodput" ]; then
    echo "exited with code 127"
    exit 127
fi

apf=$(echo $REQUESTS | sed 's/http.:\/\///')
addr=$(echo $apf | sed 's/:.*//')
prt=$(echo $apf | sed 's/.*://' | sed 's/\/.*//')

start=$(date +%s%N)
./http_client \
    -q --download $DOWNLOADS \
    --no-quic-dump --no-http-dump \
    --cc=$CC \
    $addr $prt \
    $REQUESTS

ret=$?

end=$(date +%s%N)
echo {\"start\": $start, \"end\": $end} > ${LOGS:-.}/time.json

exit 0
