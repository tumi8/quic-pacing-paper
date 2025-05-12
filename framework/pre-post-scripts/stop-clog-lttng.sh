#!/bin/bash
# adapted from the log wrapper script of MsQuic: https://github.com/microsoft/msquic/blob/main/scripts/log_wrapper.sh

SESSION_NAME=quic-interop
LOG_DIR=$(pos_get_variable --remote log_dir)
IMPLEMENTATION=$(pos_get_variable --remote implementation)
DATADIR="$LOG_DIR"/clog-lttng-data

lttng stop && lttng destroy ${SESSION_NAME}

babeltrace --names all "$DATADIR" > "$LOG_DIR"/"$IMPLEMENTATION".babel.txt
rm -r "$DATADIR"
