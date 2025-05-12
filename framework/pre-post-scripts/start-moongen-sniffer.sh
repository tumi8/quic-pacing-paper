#!/bin/bash

LOG_DIR=$(pos_get_variable --remote log_dir)
CAPTURE_TIME=$(pos_get_variable --remote capture_time)
SNAP_LEN=$(pos_get_variable --remote snap_len)

set -ex

CAPTURE_TIME=${CAPTURE_TIME:-60}  # set default capture time to 60 s
SNAP_LEN=${SNAP_LEN:-128}  # set max. captured packet length to 128 B

# Start MoonGen sniffer
/root/moongen/build/MoonGen \
    /root/moongen/examples/moonsniff/sniffer.lua \
    1 0 \
    --capture \
    --time $CAPTURE_TIME \
    --snaplen $SNAP_LEN \
    --output $LOG_DIR/capture &

# Give MoonGen some time to initialize
sleep 6
