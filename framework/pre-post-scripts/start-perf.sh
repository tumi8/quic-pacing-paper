#!/bin/bash

set -eux

apt install -y linux-perf

LOG_DIR=$(pos_get_variable --remote log_dir)
ROLE=$(pos_get_variable --remote role)
IMPLEMENTATION=$(pos_get_variable --remote implementation)

# odd frequency "to avoid accidentally sampling in lockstep with some periodic activity, which would produce skewed results"
# source: https://www.brendangregg.com/perf.html#TimedProfiling
PERF_FREQUENCY=1997

perf record -a -g --call-graph dwarf -F ${PERF_FREQUENCY} -o ${LOG_DIR}/perf.data &
