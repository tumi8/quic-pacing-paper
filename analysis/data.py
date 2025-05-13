baseline_data = {
    "quiche": "quiche-gso-txtime-cubic-gso_unpaced",
    "picoquic": "picoquic-cubic",
    "ngtcp2": "ngtcp2-cubic",
    "TCP/TLS": "tcp+tls-cubic",
}

quiche_data = {
    "CUBIC": "quiche-gso-txtime-cubic-gso_unpaced",
    "Reno": "quiche-gso-txtime-reno-gso_unpaced",
    "BBR": "quiche-gso-txtime-bbr-gso_unpaced",
    "BBR2": "quiche-gso-txtime-bbr2-gso_unpaced",
}

ngtcp_data = {
    "CUBIC": "ngtcp2-cubic",
    "Reno": "ngtcp2-reno",
    "BBR": "ngtcp2-bbr",
}

picoquic_data = {
    "CUBIC": "picoquic-cubic",
    "Reno": "picoquic-reno",
    "BBR": "picoquic-bbr",
}

fq_data = {
    "Default": "quiche-gso-txtime-cubic-gso_unpaced",
    "FQ": "quiche-gso-txtime-cubic-fq-gso_unpaced",
    "SF": "quiche-gso-txtime-cubic-gso_unpaced-spurious_fixed",
    "FQ+SF": "quiche-gso-txtime-cubic-fq-gso_unpaced-spurious_fixed",
}

gso_data = {
    "GSO enabled": "quiche-gso-txtime-cubic-fq-gso_unpaced-spurious_fixed",
    "GSO disabled": "quiche-gso-txtime-cubic-fq-gso_disabled-spurious_fixed",
    "GSO paced": "quiche-gso-txtime-cubic-fq-gso_paced-spurious_fixed",
}

etf_data = {
    "FQ+GSO": "quiche-gso-txtime-cubic-fq-gso_unpaced-spurious_fixed",
    "FQ+pacedGSO": "quiche-gso-txtime-cubic-fq-gso_paced-spurious_fixed",
    "ETF+pacedGSO": "quiche-gso-txtime-cubic-etf-delta-200000-gso_paced-spurious_fixed",
    "hwETF+pacedGSO": "quiche-gso-txtime-cubic-etf-delta-200000-gso_paced-offload-spurious_fixed",
}

if __name__ == "__main__":
    print("This file just lists the result directories that are used for evaluation")
    print("It should not be run directly.")
    print("Only the files starting with two digits are executable.")
    exit()
