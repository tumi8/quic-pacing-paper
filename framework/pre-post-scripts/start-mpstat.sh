#!/bin/bash

set -eux

apt install -y sysstat

LOG_DIR=$(pos_get_variable --remote log_dir)

mpstat -P ALL 1 > ${LOG_DIR}/mpstat_cpu_util.txt &
