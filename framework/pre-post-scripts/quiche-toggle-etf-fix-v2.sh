#!/bin/bash

IMPLEMENTATION=$(pos_get_variable --remote implementation)

$IMPLEMENTATION/quiche/toggle-etf-fix-v2.sh

