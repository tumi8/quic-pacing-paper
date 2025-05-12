#!/bin/bash

set -eux

INTERFACE=$(pos_get_variable --remote interface)

tc qdisc add dev $INTERFACE handle 1 root fq flow_limit 10000
