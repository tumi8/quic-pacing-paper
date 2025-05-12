# Kernel Patch for paced GSO

This directory contains [`txtime-gso.patch`](txtime-gso.patch), the kernel patch we used in our measurements to enable paced GSO.

We also applied [`patch-6.1.90-rt30.patch`](https://cdn.kernel.org/pub/linux/kernel/projects/rt/6.1/older/patch-6.1.90-rt30.patch.xz) for the real-time kernel.

While all hosts in our measurement run Debian Bookworm, client and server use Linux kernel 6.1.112-rt30 and the sniffer uses 6.1.0-17-amd64.

