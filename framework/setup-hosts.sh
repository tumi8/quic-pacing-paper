#!/bin/bash

usage() {
    echo "Usage: $0 <testbed-config.json> [-dpdk] [-drivers] [-moonsniff]"
    exit 1
}

install_driver() {
    TESTNODE=$1
    DRIVER=$2

	case "$DRIVER" in
	ice | ixgbe)
		echo "Installing driver $DRIVER on $TESTNODE"
        # Format of the install script: drivers/install-<driver>-<dpdk-version>.sh
		pos commands launch "$TESTNODE" -i "drivers/install-$DRIVER-$DPDK_VERSION.sh"
		;;
	*)
		echo "CAUTION: Driver $DRIVER not supported. Proceeding with default driver version."
		;;
    esac
}

install_packages() {
    pos commands launch "$1" -- bash -c "apt update -y"
    pos commands launch "$1" -- bash -c "DEBIAN_FRONTEND=noninteractive apt install -y python3-pip python3-venv ifstat linux-perf ethtool moreutils libev-dev autoconf cmake libtool pkgconf curl"
}

# Check arguments
if [ "$#" -lt 1 ] || [ "$#" -gt 4 ]; then
    usage
fi

USE_DPDK=0
INSTALL_DRIVERS=0
SETUP_MOONSNIFF=0
for arg in "$@"; do
    case "$arg" in
    "-dpdk")
        USE_DPDK=1
        ;;
    "-drivers")
        INSTALL_DRIVERS=1
        ;;
    "-moonsniff")
        SETUP_MOONSNIFF=1
        ;;
    esac
done

if [ "$((USE_DPDK + INSTALL_DRIVERS + SETUP_MOONSNIFF))" -ne "$(($# - 1))" ] \
    || [ "$1" = "-dpdk" ] || [ "$1" = "-drivers" ] || [ "$1" = "-moonsniff" ]; then
    usage
fi

# Variables
CONFIG=$1

# Duration of the allocation in minutes
DURATION=300

# Image to use for client and server
IMAGE="--staging debian-patched2"
IMAGE_SNIFFER="debian-bookworm"

# DPDK version (required for driver installation)
DPDK_VERSION="23.03"

SERVER=$(jq -r .server.host $CONFIG)
SERVER_INTERFACE=$(jq -r .server.interface.name $CONFIG)
SERVER_DRIVER=$(jq -r .server.interface.driver $CONFIG)
SERVER_IP=$(jq -r .server.ip $CONFIG)
SERVER_IPv6=$(jq -r .server.ipv6 $CONFIG)

CLIENT=$(jq -r .client.host $CONFIG)
CLIENT_INTERFACE=$(jq -r .client.interface.name $CONFIG)
CLIENT_DRIVER=$(jq -r .client.interface.driver $CONFIG)
CLIENT_IP=$(jq -r .client.ip $CONFIG)
CLIENT_IPv6=$(jq -r .client.ipv6 $CONFIG)

SNIFFER=$(jq -r .sniffer.host $CONFIG)

if [ "$SETUP_MOONSNIFF" -eq "1" ] &&  [ "$SNIFFER" = "null" ]; then
    echo "MoonSniff setup enabled, but no sniffer server given in config file!"
    exit 2
fi

SCRIPT_PATH=$(dirname "$0")
cd $SCRIPT_PATH

echo "Client: $CLIENT"
echo "Server: $SERVER"
if [ "$SETUP_MOONSNIFF" -eq "1" ]; then
    echo "Sniffer: $SNIFFER"
fi

if [ "$USE_DPDK" -eq "1" ]; then
    echo "DPDK setup enabled!"
fi

if [ "$INSTALL_DRIVERS" -eq "1" ]; then
    echo "Driver installation enabled!"
fi

echo "Rebooting in 10s, if you want abort now"
sleep 10

shopt -s expand_aliases

# Print commands and exit script if one command fails
set -ex

if [[ -z "$REBOOT_ONLY" ]]; then
	alias goto=":"
	alias GOTO_REBOOT=":"
else
	alias goto="cat >/dev/null <<"
fi
goto GOTO_REBOOT

# Free hosts in case there already exist allocations
pos allocations free -k $SERVER
pos allocations free -k $CLIENT
if [ "$SETUP_MOONSNIFF" -eq "1" ]; then
    pos allocations free -k $SNIFFER
fi

# Allocate hosts
if [ "$SETUP_MOONSNIFF" -eq "1" ]; then
    pos allocations allocate $SERVER $CLIENT $SNIFFER
else
    pos allocations allocate $SERVER $CLIENT
fi

# Set images
pos nodes image $SERVER $IMAGE
pos nodes image $CLIENT $IMAGE
if [ "$SETUP_MOONSNIFF" -eq "1" ]; then
    pos nodes image $SNIFFER $IMAGE_SNIFFER
fi

GOTO_REBOOT
# Reboot hosts
if [ "$SETUP_MOONSNIFF" -eq "1" ]; then
    pos nodes reset $SNIFFER
fi
pos nodes reset $SERVER &
pos nodes reset $CLIENT &
wait  # wait until servers are reset

# Install drivers if DPDK is used (as DPDK requires those drivers) or if option '-drivers' is set
if [ "$USE_DPDK" -eq "1" ] || [ "$INSTALL_DRIVERS" -eq "1" ]; then
    install_driver $SERVER $SERVER_DRIVER &
    install_driver $CLIENT $CLIENT_DRIVER &
    wait
fi

# Setup DPDK if option is set, otherwise just setup interfaces
if [ "$USE_DPDK" -eq "1" ]; then
    ./setup-dpdk.sh $CONFIG
else
    ./setup-interfaces.sh $CONFIG "normal"
fi

# Install packages required for measurements
install_packages $SERVER &
install_packages $CLIENT &
if [ "$SETUP_MOONSNIFF" -eq "1" ]; then
    install_packages $SNIFFER
    # Install MoonGen
	sftp $SNIFFER <<< $"put moongen.tar.gz"
	ssh $SNIFFER <<< $"tar -xzf moongen.tar.gz"
	sftp $SNIFFER <<< $"put -r moongen
put -r common"
    pos commands launch $SNIFFER -i install-moongen.sh &
fi
sftp $CLIENT <<< $"put -r common"
ssh $CLIENT <<< $"/root/common/setup.sh" & 
sftp $SERVER <<< $"put -r common"
ssh $SERVER <<< $"/root/common/setup.sh" &
wait

# Setup hosts file
pos commands launch $CLIENT -- bash -c "echo $SERVER_IPv6 server6 >> /etc/hosts"
pos commands launch $CLIENT -- bash -c "echo $SERVER_IP server >> /etc/hosts"
