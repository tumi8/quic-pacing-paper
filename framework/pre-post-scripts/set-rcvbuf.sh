#!/bin/bash

set -eux

SIZE=$(pos_get_variable --remote rmem_value)

sysctl -w net.core.rmem_max=$SIZE
sysctl -w net.core.rmem_default=$SIZE
