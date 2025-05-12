#!/bin/bash

LOG_DIR=$(pos_get_variable --remote log_dir)

dpdk-proc-info -- --xstats > ${LOG_DIR}/dpdk-proc-info.txt
