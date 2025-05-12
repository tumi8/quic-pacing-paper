#!/bin/bash
set -eux

INTERFACE=$(pos_get_variable --remote interface)
cd /root/common

for i in {1..5}
do
killall ptp4l 2> /dev/null || true
killall phc2sys 2> /dev/null || true
sleep 1

ptp4l -i $INTERFACE -f gPTP.cfg --step_threshold=1 &
sleep 10
pmc -u -b 0 -t 1 "SET GRANDMASTER_SETTINGS_NP clockClass 248 \
        clockAccuracy 0xfe offsetScaledLogVariance 0xffff \
        currentUtcOffset 37 leap61 0 leap59 0 currentUtcOffsetValid 1 \
        ptpTimescale 1 timeTraceable 1 frequencyTraceable 0 \
        timeSource 0xa0"
sleep 5
phc2sys -c /dev/ptp0 -s CLOCK_REALTIME --step_threshold=1 \
        --transportSpecific=1 -w &
sleep 20
./check_clocks -d $INTERFACE && exit 0
done
exit 1
