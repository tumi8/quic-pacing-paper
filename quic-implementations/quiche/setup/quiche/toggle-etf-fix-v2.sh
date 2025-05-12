#!/bin/bash
cd "$(dirname "$0")"

set -eux

python3 toggle.py apps/src/sendto.rs "send_time = adjust_send_time_for_etf_v2("

