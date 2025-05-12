#!/bin/bash

IMPLEMENTATION=$(pos_get_variable --remote implementation)

$IMPLEMENTATION/quiche/toggle-spurious-fix.sh

