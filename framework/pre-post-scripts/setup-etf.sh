#!/bin/bash

set -eux

INTERFACE=$(pos_get_variable --remote interface)
DELTA=$(pos_get_variable --remote delta)
OFFLOAD=$(pos_get_variable --remote offload)
PORT=$(pos_get_variable --remote port)

case $OFFLOAD in
	True|true|Yes|yes|On|on|1)
		OFFLOAD=offload
		;;
	*)
		OFFLOAD=''
		;;
esac

tc qdisc add dev $INTERFACE handle 1 root drr
tc class add dev $INTERFACE parent 1: classid 1:1 drr
tc class add dev $INTERFACE parent 1: classid 1:2 drr
tc qdisc add dev $INTERFACE parent 1:1 handle 2: pfifo_fast
tc qdisc add dev $INTERFACE parent 1:2 handle 3: etf clockid CLOCK_TAI delta $DELTA $OFFLOAD

tc filter add dev $INTERFACE pref 9 protocol ip u32 match ip sport $PORT 0xffff match ip protocol 17 0xff flowid 1:2
tc filter add dev $INTERFACE pref 10 matchall flowid 1:1
