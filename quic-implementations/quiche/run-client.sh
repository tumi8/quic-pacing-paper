#!/bin/bash

CC=$(pos_get_variable -r cc)

# Default values defined in https://github.com/cloudflare/quiche/blob/master/apps/src/args.rs#L216
if [[ $? != 0 ]]; then
    CC="cubic"
fi


if [[ $TESTCASE == "goodput" ]]; then

    # Handle empty request for compliance
    if [ -z ${REQUESTS+x} ]; then
        # unset
        exit 0
    else
        start=$(date +%s%N)
	    RUST_LOG="info" quiche/target/x86_64-unknown-linux-gnu/debug/quiche-client \
            --no-verify \
            --cc-algorithm ${CC} \
            --wire-version 00000001 \
            --dump-responses $DOWNLOADS \
    	    --no-grease \
            $REQUESTS
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
