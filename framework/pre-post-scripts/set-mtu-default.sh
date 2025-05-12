#!/bin/bash

DEFAULT_MTU=1500 # Default network MTU
INTERFACE=$(pos_get_variable --remote interface)

ip link set dev $INTERFACE mtu $DEFAULT_MTU
