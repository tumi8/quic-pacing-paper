#!/bin/bash

set -ux

LOG_DIR=$(pos_get_variable --remote log_dir)
INTERFACE=$(pos_get_variable --remote interface)

tc -s -d qdisc show dev ${INTERFACE} > ${LOG_DIR}/tc-stats.txt
tc -s -d qdisc show dev ifb0 >> ${LOG_DIR}/tc-stats.txt
exit 0
