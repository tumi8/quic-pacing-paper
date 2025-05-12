#!/bin/bash

set -eux

# SIGINT so it prints the average into the last line of the file.
pkill -SIGINT pidstat

