#!/bin/bash
cd "$(dirname "$0")"
set -x

if [ ! -d linuxptp ]; then
git clone http://git.code.sf.net/p/linuxptp/code linuxptp
cd linuxptp/
make
make install
cd -
fi

if [ ! -f check_clocks ]; then
gcc check_clocks.c -o check_clocks
fi
