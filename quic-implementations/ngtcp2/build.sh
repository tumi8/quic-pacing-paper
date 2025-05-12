#!/bin/bash


cd $(basename $0)

git rev-parse HEAD > VERSION

./setup-env.sh

cp build/examples/bsslclient ./http_client
cp build/examples/bsslserver ./http_server

zip artifact.zip \
    VERSION \
    setup-env.sh run-client.sh run-server.sh \
    http_client \
    http_server
