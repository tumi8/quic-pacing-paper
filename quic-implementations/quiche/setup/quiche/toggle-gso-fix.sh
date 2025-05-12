#!/bin/bash
cd "$(dirname "$0")"

set -eux

python3 toggle.py quiche/src/recovery/congestion/mod.rs "if self.rate_update_allowed"
python3 toggle.py quiche/src/recovery/congestion/mod.rs "self.set_pacing_rate(rate as u64, now); // :)"
python3 toggle.py apps/src/bin/quiche-server.rs "client.conn.allow_rate_update();"

