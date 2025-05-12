#!/bin/bash

set -x

CC=$(pos_get_variable -r cc)
GSO=$(pos_get_variable -r gso)

# Default values defined in https://github.com/cloudflare/quiche/blob/master/apps/src/args.rs#L216
if [[ $? != 0 ]]; then
    CC="cubic"
    GSO=1
fi

if [ "$GSO" -eq "0" ]; then
	GSO="--disable-gso"
else
	GSO=""
fi

WWW=${WWW::-1}

if [[ $TESTCASE == "goodput" ]]; then
	cd quiche
	rm dump.log loss.log || true
	cargo build -Z build-std --target x86_64-unknown-linux-gnu --bin quiche-server &&
	RUST_LOG="info" SSLKEYLOGFILE="sslkeys.log" target/x86_64-unknown-linux-gnu/debug/quiche-server \
	--cc-algorithm ${CC} \
	--name "quiche-interop" \
	--listen "${IP}:${PORT}" \
	--root $WWW \
	--no-retry \
	--no-grease \
	--cert $CERTS/cert.pem \
	--key $CERTS/priv.key \
	$GSO
else
    echo "exited with code 127"
    exit 127
fi
