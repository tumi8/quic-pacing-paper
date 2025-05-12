#!/bin/bash

set -eux

#
# Sets the NIC offloading capabilities for UDP and TCP to their default values.
# See `activate-nic-offload.sh` for more details.
#

# pos environment variables given by Interop Runner:
#   "interface": interface of this machine used to communicate with other testbed machine
INTERFACE=$(pos_get_variable --remote interface)

# TCP Segmentation Offload (TSO)
ethtool -K ${INTERFACE} tso on

# Generic Segmentation Offload (GSO), used by TCP and UDP
# `tx-checksumming` is a hard requirement for GSO (sendmsg call fails if not activated).
# `tx-udp-segmentation` is the hardware support for UDP GSO (not supported by all systems).
ethtool -K ${INTERFACE} gso on
ethtool -K ${INTERFACE} tx-checksumming on || true
ethtool -K ${INTERFACE} tx-udp-segmentation on || true

# Generic Receive Offload (GRO), used by TCP and UDP
# `rx-checksumming` improves performance of GRO (if supported).
# `rx-gro-hw` is the hardware support for UDP GRO (not supported by all systems).
ethtool -K ${INTERFACE} gro on
ethtool -K ${INTERFACE} rx-checksumming on || true
ethtool -K ${INTERFACE} rx-gro-hw on || true
