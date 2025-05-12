#!/bin/bash

WWW=${WWW::-1}

if [[ $TESTCASE == "goodput" ]]; then
    envsubst '${IP}, ${PORT}, ${WWW}, ${CERTS}' < site-template > /etc/nginx/sites-enabled/default
    # Foreground mode using a modified default config
    # Note: renamed binary in setup-env.sh
    nginx-server
else
    echo "exited with code 127"
    exit 127
fi
