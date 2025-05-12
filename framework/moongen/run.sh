#!/usr/bin/env bash
set -ex

if [[ -z $1 ]]; then
	SNAPLEN=0
else
	SNAPLEN=$1
fi

mkdir -p /root/logs
/root/common/sync.py dagda && (/root/moongen/build/MoonGen /root/moongen/examples/moonsniff/sniffer.lua 0 1 --capture --time 10000 --snaplen $SNAPLEN --output logs/capture &)
sleep 20 &
sleep_pid=$!
wait -n
if [ kill -0 $sleep_pid 2> /dev/null ]; then
	kill $sleep_pid
  	exit 1
else
	exit 0
fi
