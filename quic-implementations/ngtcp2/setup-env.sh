#!/bin/bash

set -x

NGHTTP3_VERSION=v0.11.0
NGTCP2_VERSION=v0.15.0
GO_VERSION=go1.20.4
BORINGSSL_COMMIT=b0341041b03ea71d8371a9692aedae263fc06ee9

if [ ! -f go.tgz ]; then
curl -o go.tgz https://dl.google.com/go/${GO_VERSION}.linux-amd64.tar.gz
rm -rf /usr/local/go
tar -C /usr/local -xzf go.tgz
export PATH=/usr/local/go/bin:$PATH
fi

if [ ! -d boringssl ]; then
git clone https://github.com/google/boringssl
cd boringssl
git checkout $BORINGSSL_COMMIT
cmake -B build
make -C build
cd ..
fi

if [ ! -d nghttp3 ]; then
git clone -b $NGHTTP3_VERSION https://github.com/ngtcp2/nghttp3
cd nghttp3
autoreconf -i
./configure --prefix=$PWD/build --enable-lib-only
make -j$(nproc) check
make install
cd ..
fi

if [ ! -d ngtcp2 ]; then
git clone -b $NGTCP2_VERSION https://github.com/ngtcp2/ngtcp2
cd ngtcp2
git apply < ../patches/static_build.patch
cd ..
cp -r setup/* .
mkdir build
cd build
cmake -DCMAKE_BUILD_TYPE=Release \
    -DENABLE_BORINGSSL=1 \
    -DBORINGSSL_LIBRARIES="$PWD/../boringssl/build/ssl/libssl.a;$PWD/../boringssl/build/crypto/libcrypto.a;-lpthread;dl" \
    -DBORINGSSL_INCLUDE_DIR=$PWD/../boringssl/include \
    -DLIBNGHTTP3_LIBRARY=../nghttp3/build/lib/libnghttp3.a \
    -DLIBNGHTTP3_INCLUDE_DIR=../nghttp3/build/include/  ../ngtcp2
make bsslclient bsslserver
cd ..
fi
