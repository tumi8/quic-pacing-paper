#!/bin/bash

set -eux

apt install -y sysstat

# IMPORTANT: adapt the corresponding variable in the parsing script when you change the interval!
INTERVAL=1 # sec

LOG_DIR=$(pos_get_variable --remote log_dir)
ROLE=$(pos_get_variable --remote role)
IMPLEMENTATION=$(pos_get_variable --remote implementation)

if [[ "${IMPLEMENTATION}" == quiche* ]]; then
    BIN_NAME="quiche-${ROLE}"
elif [[ "${IMPLEMENTATION}" == lsquic* ]]; then
    BIN_NAME="http_${ROLE}"
elif [[ "${IMPLEMENTATION}" == picoquic* ]]; then
    BIN_NAME="picoquicdemo"
elif [[ "${IMPLEMENTATION}" == picoquic-dpdk ]]; then
    BIN_NAME="dpdk_picoquic"
elif [[ "${IMPLEMENTATION}" == xquic* ]]; then
    BIN_NAME="demo_${ROLE}"
elif [[ "${IMPLEMENTATION}" == s2n-quic* ]]; then
    BIN_NAME="s2n-quic-qns"
elif [[ "${IMPLEMENTATION}" == mvfst* ]]; then
    BIN_NAME="hq"
elif [[ "${IMPLEMENTATION}" == nginx* ]]; then
    BIN_NAME="nginx"
elif [[ "${IMPLEMENTATION}" == neqo* ]]; then
    BIN_NAME="neqo-${ROLE}"
elif [[ "${IMPLEMENTATION}" == msquic* ]]; then
    # Note that this covers both server ('quicinteropserver') and client ('quicinterop'), as
    # pidstat -G searches for a substring. Full matching is not possible, because the server
    # binary name is too long and thus cut (resulting in 'quicinteropserver' not being matched).
    BIN_NAME="quicinterop"
elif [[ "${IMPLEMENTATION}" == tcp* ]] || [[ "${IMPLEMENTATION}" == "tls1.3" ]]; then
    if [ "${ROLE}" = "server" ]; then
	    # TCP+TLS uses renamed nginx as server
        BIN_NAME="nginx-server"
    else
        # TCP+TLS uses wget as client
        BIN_NAME="wget"
    fi
else
    echo "Implementation ${IMPLEMENTATION} not supported by pidstat script"
    exit 1
fi

pidstat -G "${BIN_NAME}" -h -u -w -t ${INTERVAL} > "${LOG_DIR}"/pidstat.txt &
