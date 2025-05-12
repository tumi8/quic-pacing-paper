#!/bin/bash

set -x

CC=$(pos_get_variable -r cc)

if [[ $? != 0 ]]; then
    CC="cubic"
fi

if [[ $TESTCASE != "goodput" ]]; then
    echo "exited with code 127"
    exit 127
fi;

PROTO=$(echo $REQUESTS | grep :// | sed -e's,^\(.*://\).*,\1,g')
URL=$(echo ${REQUESTS/$PROTO/})
USER=$(echo $URL | grep @ | cut -d@ -f1)
HOSTPORT=$(echo ${URL/$USER@/} | cut -d/ -f1)
HOST=$(echo $HOSTPORT | sed -e 's,:.*,,g')
PORT=$(echo $HOSTPORT | sed -e 's,^.*:,:,g' -e 's,.*:\([0-9]*\).*,\1,g' -e 's,[^0-9],,g')
FILES=$(echo $URL | grep / | cut -d/ -f2-)

start=$(date +%s%N)

./picoquicdemo \
    -n $HOST \
    -o $DOWNLOADS \
    -G $CC \
    $HOST \
    $PORT \
    $FILES
ret=$?

end=$(date +%s%N)
echo {\"start\": $start, \"end\": $end} > ${LOGS:-.}/time.json
