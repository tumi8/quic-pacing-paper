#!/bin/bash

set -eux

#
# Deactivates NIC offloading capabilities for UDP and TCP.
# See https://access.redhat.com/documentation/en-us/red_hat_enterprise_linux/6/html/performance_tuning_guide/network-nic-offloads
# for offloading types.
#
# See https://www.ibm.com/docs/en/linux-on-systems?topic=3-enabling-disabling-tcp-segmentation-offload 
# or
# man ethtool
# for how to enable/disable offloading settings
#
# Note: ethtool allows for name shortening: tcp-segmentation-offload = tso
#

# pos environment variables given by Interop Runner:
#   "interface": interface of this machine used to communicate with other testbed machine
INTERFACE=$(pos_get_variable --remote interface)

# TCP Segmentation Offload (TSO)
ethtool -K ${INTERFACE} tso on

# Generic Segmentation Offload (GSO), used by TCP and UDP
# `tx-checksumming` is a hard requirement for GSO (sendmsg call fails if not activated), thus an error
#                   while trying to activate is not tolerated.
# `tx-udp-segmentation` is the hardware support for UDP GSO (not supported by all systems)
ethtool -K ${INTERFACE} gso on
ethtool -K ${INTERFACE} tx-checksumming on
ethtool -K ${INTERFACE} tx-udp-segmentation on || true

# Generic Receive Offload (GRO), used by TCP and UDP
# `rx-checksumming` improves performance of GRO (if supported)
# `rx-gro-hw` is the hardware support for UDP GRO (not supported by all systems)
ethtool -K ${INTERFACE} gro on
ethtool -K ${INTERFACE} rx-checksumming on || true
ethtool -K ${INTERFACE} rx-gro-hw on || true
