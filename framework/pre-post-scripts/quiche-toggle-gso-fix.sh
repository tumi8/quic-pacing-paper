#!/bin/bash

IMPLEMENTATION=$(pos_get_variable --remote implementation)

$IMPLEMENTATION/quiche/toggle-gso-fix.sh

