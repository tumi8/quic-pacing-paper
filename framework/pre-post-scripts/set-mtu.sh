#!/bin/bash

MTU=$(pos_get_variable --remote mtu)
INTERFACE=$(pos_get_variable --remote interface)

ip link set dev $INTERFACE mtu $MTU

