#!/bin/bash

# Check arguments
if test "$#" -ne 1; then
	echo "Usage: $0 <testbed-config.json>"
	exit 1
fi

# Variables
CONFIG=$1
SERVER=$(jq -r .server.host $CONFIG)
CLIENT=$(jq -r .client.host $CONFIG)

SCRIPT_PATH=$(dirname "$0")
cd $SCRIPT_PATH

# Print commands and exit script if one command fails
set -ex

# Install DPDK
echo "Installing DPDK"
pos commands launch $SERVER -i install-dpdk.sh &
pos commands launch $CLIENT -i install-dpdk.sh &
wait

# Setup interface
pos commands launch $SERVER -- modprobe vfio-pci
pos commands launch $CLIENT -- modprobe vfio-pci

./setup-interfaces.sh $CONFIG "dpdk-both"

wait
