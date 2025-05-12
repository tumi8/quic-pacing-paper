#!/usr/bin/env bash
set -eux

apt update && DEBIAN_FRONTEND=noninteractive apt install -y libsystemd-dev

ICE_DRIVER_LINK=https://downloadmirror.intel.com/825841/ice-1.14.11.tar.gz

#Install ice driver
wget "$ICE_DRIVER_LINK" -O ice.tar.gz
tar -xf ice.tar.gz
rm ice.tar.gz
pushd ice*/src
make -j install 2> /dev/null
popd

#Load modules
rmmod ice
modprobe ice
modprobe vfio-pci

chown -R root: /root/moongen
cd /root/moongen
/root/moongen/build.sh --noBind
/root/moongen/setup-hugetlbfs.sh

/root/moongen/libmoon/deps/dpdk/usertools/dpdk-devbind.py -u 03:00.0 03:00.1
/root/moongen/libmoon/deps/dpdk/usertools/dpdk-devbind.py --bind=vfio-pci 03:00.0 03:00.1
