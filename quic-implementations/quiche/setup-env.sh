#!/bin/bash

set -x

# rust
if [ ! -f rustup.sh ]; then
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs > rustup.sh
chmod +x rustup.sh
./rustup.sh -y --default-toolchain nightly-2024-11-11
. "$HOME/.cargo/env"
rustup component add rust-src
fi

# quiche
if [ ! -d quiche ]; then
git clone --recursive https://github.com/cloudflare/quiche
cp setup/unix/time.rs /root/.rustup/toolchains/nightly-2024-11-11-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/std/src/sys/pal/unix
cp setup/time.rs /root/.rustup/toolchains/nightly-2024-11-11-x86_64-unknown-linux-gnu/lib/rustlib/src/rust/library/std/src
cd quiche
git checkout 5bccde6ead15688326e05364abab51a910242423
cargo fetch
cp -r ../setup/quiche/* .
cp -r ../setup/nix-* /root/.cargo/registry/src/index.crates.io-*
cargo build -Z build-std --target x86_64-unknown-linux-gnu --bin quiche-client
cargo build -Z build-std --target x86_64-unknown-linux-gnu --bin quiche-server
cd -
fi
