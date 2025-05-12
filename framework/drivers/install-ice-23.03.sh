#!/bin/bash

ICE_DRIVER_LINK=https://downloadmirror.intel.com/825841/ice-1.14.11.tar.gz

#Install ice driver
wget "$ICE_DRIVER_LINK" -O ice.tar.gz
tar -xf ice.tar.gz
rm ice.tar.gz
pushd ice*/src
make -j install
popd

#Load modules
rmmod ice
modprobe ice
