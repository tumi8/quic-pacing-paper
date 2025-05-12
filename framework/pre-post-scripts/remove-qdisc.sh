#!/bin/bash

set -xu

INTERFACE=$(pos_get_variable --remote interface)

tc qdisc del dev $INTERFACE root || true
tc qdisc del dev $INTERFACE ingress || true
modprobe -r ifb || true
