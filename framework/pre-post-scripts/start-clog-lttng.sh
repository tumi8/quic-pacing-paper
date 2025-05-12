#!/bin/bash
# adapted from the log wrapper script of MsQuic: https://github.com/microsoft/msquic/blob/main/scripts/log_wrapper.sh

# This script starts the collection of tracelogs using LTTng and CLOG.
# NOTE: Currently only tested with MsQuic.

apt install -y lttng-tools liblttng-ust-dev

SESSION_NAME=quic-interop
LOG_DIR=$(pos_get_variable --remote log_dir)

lttng destroy ${SESSION_NAME} 2> /dev/null

DATADIR="$LOG_DIR"/clog-lttng-data
mkdir "$DATADIR"
lttng create ${SESSION_NAME} -o="$DATADIR"
lttng enable-event --userspace "CLOG_*" && lttng add-context --userspace --type=vpid --type=vtid
lttng start
