#!/bin/bash

if [[ $TESTCASE == "goodput" ]]; then

    if [ -z ${REQUESTS+x} ]; then
        exit 0
    else

    start=$(date +%s%N)
	wget \
	    --quiet \
	    --no-check-certificate \
	    --directory-prefix=${DOWNLOADS} \
	    ${REQUESTS}
	end=$(date +%s%N)
	echo {\"start\": $start, \"end\": $end} > ${LOGS:-.}/time.json
    fi

    # on error the client exits on code 101, change to 1
    retVal=$?
    if [ $retVal -eq 101 ]; then
        exit 1
    fi
else
    echo "exited with code 127"
    exit 127
fi
