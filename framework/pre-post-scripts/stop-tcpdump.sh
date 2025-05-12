#!/bin/bash

LOG_DIR=$(pos_get_variable --remote log_dir)
ROLE=$(pos_get_variable --remote role)

set -eux

pkill -f tcpdump

if [ -f "${LOG_DIR}/keys.log" ] && [ -f "${LOG_DIR}/trace-${ROLE}.pcap" ]; then
    editcap --inject-secrets tls,"${LOG_DIR}/keys.log" "${LOG_DIR}/trace-${ROLE}.pcap" "${LOG_DIR}/trace-${ROLE}-embedded-keys.pcapng"
fi
