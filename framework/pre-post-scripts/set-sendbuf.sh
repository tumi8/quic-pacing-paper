#!/bin/bash

set -eux

SIZE=$(pos_get_variable --remote wmem_value)

sysctl -w net.core.wmem_max=$SIZE
sysctl -w net.core.wmem_default=$SIZE
