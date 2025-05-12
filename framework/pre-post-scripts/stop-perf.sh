#!/bin/bash

set -eux

LOG_DIR=$(pos_get_variable --remote log_dir)

# kill perf
pkill -f perf

# wait until perf has saved all files
sleep 3

# There might be problems on finding correct kernel symbols when "perf report/script" runs
# on a different kernel. Therefore it is done here and the perf.data is deleted afterwards.
perf script -i ${LOG_DIR}/perf.data > ${LOG_DIR}/out.perf
rm ${LOG_DIR}/perf.data
