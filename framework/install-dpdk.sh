#!/bin/bash

NR_HUGEPAGES=2048

DPDK_VERSION=23.03
DPDK_LINK="https://fast.dpdk.org/rel/dpdk-$DPDK_VERSION.tar.xz"
DPDK_BUILD_PATH=dpdk-build
DPDK_BUILD_CORES=64

#Install dependencies
apt install -y ninja-build meson 

#Install dpdk
wget "$DPDK_LINK" -O dpdk.tar.xz
tar -xf dpdk.tar.xz
rm dpdk.tar.xz

mkdir "$DPDK_BUILD_PATH"
meson setup "dpdk-$DPDK_VERSION" "$DPDK_BUILD_PATH"
pushd "$DPDK_BUILD_PATH"
ninja -j"$DPDK_BUILD_CORES"
ninja install
popd
ldconfig

modprobe vfio-pci

#Allocate huge pages (mounted on default at /dev/hugepages)
echo $NR_HUGEPAGES > /sys/kernel/mm/hugepages/hugepages-2048kB/nr_hugepages
