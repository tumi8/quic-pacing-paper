#!/bin/bash

print_help() {
    echo "Usage: $0 <testbed> <dpdk-both|dpdk-server|dpdk-client|normal>"
    exit 1
}

#dpdk_server <host> <interface name> <interface pci>
setup_dpdk_interface() {
    echo "Binding interface $2($3) to DPDK on $1"
    #Interface might already be bound to dpdk > ignore errors
    pos commands launch $1 -- ip l set down dev $2 2> /dev/null
    pos commands launch $1 -- dpdk-devbind.py -b vfio-pci $3
}

#dpdk_server <host> <interface name> <interface pci> <driver> <ipv4> <ipv6> 
setup_normal_interface() {
    #Check if dpdk is installed
    #DPDK might not be installed > ignore errors
    pos commands launch $1 -- dpdk-devbind.py -s 2> /dev/null
    if [ $? -eq 0 ]; then
        echo "DPDK is installed on $1. Releasing interface $3 from DPDK if necessary."
        pos commands launch $1 -- dpdk-devbind.py -b $4 $3
    fi

    #Normal setup
    echo "Setting up interface $2 on $1"
    #IP might already be bound > ignore errors
    pos commands launch $1 -- ip a add $5/24 brd + dev $2 2> /dev/null
    pos commands launch $1 -- ip a add $6/64 dev $2 2> /dev/null
    pos commands launch $1 -- ip link set $2 up
}

# Check arguments
if test "$#" -ne 2; then
	print_help
	exit 1
fi

CONFIG=$1
SERVER=$(jq -r .server.host $CONFIG)
CLIENT=$(jq -r .client.host $CONFIG)
SERVER_INTERFACE=$(jq -r .server.interface.name $CONFIG)
CLIENT_INTERFACE=$(jq -r .client.interface.name $CONFIG)
SERVER_PCI=$(jq -r .server.interface.pci_id $CONFIG)
CLIENT_PCI=$(jq -r .client.interface.pci_id $CONFIG)
SERVER_IP=$(jq -r .server.ip $CONFIG)
CLIENT_IP=$(jq -r .client.ip $CONFIG)
SERVER_IPV6=$(jq -r .server.ipv6 $CONFIG)
CLIENT_IPV6=$(jq -r .client.ipv6 $CONFIG)
SERVER_DRIVER=$(jq -r .server.interface.driver $CONFIG)
CLIENT_DRIVER=$(jq -r .client.interface.driver $CONFIG)

echo "Setting up interfaces on $SERVER and $CLIENT"
if [ "$2" == "dpdk-both" ]; then
    setup_dpdk_interface $SERVER $SERVER_INTERFACE $SERVER_PCI
    setup_dpdk_interface $CLIENT $CLIENT_INTERFACE $CLIENT_PCI
    wait
elif [ "$2" == "dpdk-server" ]; then
    setup_dpdk_interface $SERVER $SERVER_INTERFACE $SERVER_PCI
    setup_normal_interface $CLIENT $CLIENT_INTERFACE $CLIENT_PCI $CLIENT_DRIVER $CLIENT_IP $CLIENT_IPV6
    wait
elif [ "$2" == "dpdk-client" ]; then
    setup_normal_interface $SERVER $SERVER_INTERFACE $SERVER_PCI $SERVER_DRIVER $SERVER_IP $SERVER_IPV6
    setup_dpdk_interface $CLIENT $CLIENT_INTERFACE $CLIENT_PCI
    wait
elif [ "$2" == "normal" ]; then
    setup_normal_interface $SERVER $SERVER_INTERFACE $SERVER_PCI $SERVER_DRIVER $SERVER_IP $SERVER_IPV6
    setup_normal_interface $CLIENT $CLIENT_INTERFACE $CLIENT_PCI $CLIENT_DRIVER $CLIENT_IP $CLIENT_IPV6
    wait
else
    print_help
fi
