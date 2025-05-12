#!/bin/bash

cd $(basename $0)

git rev-parse HEAD > VERSION

./setup-env.sh

cp target/x86_64-unknown-linux-gnu/debug/quiche-server .
cp target/x86_64-unknown-linux-gnu/debug/quiche-client .

zip artifact.zip \
    VERSION \
    setup-env.sh run-client.sh run-server.sh \
    quiche-client \
    quiche-server
