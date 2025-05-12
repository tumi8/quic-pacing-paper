#!/bin/bash
cd "$(dirname "$0")"

set -eux

python3 toggle.py apps/src/sendto.rs "&[cmsg_gso, cmsg_txtime, cmsg_rate],"
python3 toggle.py apps/src/sendto.rs "&[cmsg_gso, cmsg_txtime],"
