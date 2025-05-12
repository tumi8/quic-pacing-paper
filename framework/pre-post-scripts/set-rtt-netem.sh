#!/bin/bash

set -eux

INTERFACE=$(pos_get_variable --remote interface)
RTT=$(pos_get_variable --remote rtt)
# rate is in mbps
let RATE=5
let DELAY=RTT/2
# convert delay to seconds (we accomodate packets for 2*delay (=rtt) in netem => one for netem latency and one for tbf queue)
# limit = (rate * 1000000 * rtt / 1000) / 1392
let LIMIT=(RATE*2000*DELAY)/1392

modprobe ifb numifbs=1
ip link set dev ifb0 up

tc qdisc add dev $INTERFACE handle 1 root netem delay ${DELAY}ms
tc qdisc add dev $INTERFACE handle ffff: ingress
tc filter add dev $INTERFACE parent ffff: matchall action mirred egress redirect dev ifb0
# latency param for tbf is discarded because of inner qdisc but apparently still required
tc qdisc add dev ifb0 handle 1 root tbf rate ${RATE}mbps burst 1540b latency ${RTT}
tc qdisc add dev ifb0 parent 1: handle 2 netem delay ${DELAY}ms limit ${LIMIT}

rm backlog.log || true
while true;
do
    tc -s -d qdisc show dev ifb0 | sed -n 's/.*backlog \([^ ]*\).*/\1/p';
    if [ ${PIPESTATUS[0]} -ne "0" ];
    then
            break
    fi
    sleep 0.001;
done | ts "%b %d %Y %H:%M:%.S;" > backlog.log &
