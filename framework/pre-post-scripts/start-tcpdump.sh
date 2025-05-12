#!/bin/bash

set -eux

DEBIAN_FRONTEND=noninteractive apt install -y tcpdump tshark

LOG_DIR=$(pos_get_variable --remote log_dir)
ROLE=$(pos_get_variable --remote role)
INTERFACE=$(pos_get_variable --remote interface)

nohup tcpdump -i ${INTERFACE} -U -w ${LOG_DIR}/trace-${ROLE}.pcap  > /dev/null &
