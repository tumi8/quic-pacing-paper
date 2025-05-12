#!/bin/bash

IXGBE_DRIVER_LINK=https://netcologne.dl.sourceforge.net/project/e1000/ixgbe%20stable/5.18.11/ixgbe-5.18.11.tar.gz

#Install ixgbe driver
wget "$IXGBE_DRIVER_LINK" -O ixgbe.tar.gz
tar -xf ixgbe.tar.gz
rm ixgbe.tar.gz
pushd ixgbe*/src
make -j
make -j install
popd

#Load modules
rmmod ixgbe
modprobe ixgbe
