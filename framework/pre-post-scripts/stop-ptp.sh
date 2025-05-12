#!/bin/bash

set -ux
killall ptp4l 2> /dev/null || true
killall phc2sys 2> /dev/null || true
