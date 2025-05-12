#!/bin/bash

set -eux

apt install -y ethtool

INTERFACE=$(pos_get_variable --remote interface)
LOG_DIR=$(pos_get_variable --remote log_dir)

# If the ethtool-start.txt file does not yet exist, it is created,
# otherwise the output is saved under ethtool-stop.txt. If this script
# runs more than twice, only the first and last run are saved.

if ls ${LOG_DIR}/ethtool-start.txt 1> /dev/null 2>&1; then
    ethtool -S ${INTERFACE} > ${LOG_DIR}/ethtool-stop.txt
else
    ethtool -S ${INTERFACE} > ${LOG_DIR}/ethtool-start.txt
fi
