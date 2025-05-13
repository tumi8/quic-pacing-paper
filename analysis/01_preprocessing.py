import os
import json
import pyshark
import util


RELATIVE_TIMESTAMP_IDX = 0
RAW_TIMESTAMP_IDX = 1
PACKET_LENGTH_IDX = 2
PACKET_NUMBER_IDX = 3


def inter_packet_gaps(timestamps: list[float]) -> list[float]:
    if len(timestamps) < 2:
        return []
    ips_unfiltered = []
    last = timestamps[0]
    for i in range(1, len(timestamps)):
        tstamp = timestamps[i]
        delta = (tstamp - last) / 1e6
        ips_unfiltered.append(delta)
        last = tstamp
    return ips_unfiltered


def parse_packets_pcap(filename, limit=-1):
    result = []
    first_timestamp_raw = 0
    with pyshark.FileCapture(filename) as packets:
        for i, packet in enumerate(packets):
            if i == limit:
                break
            if not (("udp" in packet and packet.udp.srcport == "4433")
                    or ("tcp" in packet and packet.tcp.srcport == "4433")):
                continue
            raw_timestamp = int(packet.sniff_timestamp.replace(".", ""))
            if first_timestamp_raw == 0:
                first_timestamp_raw = raw_timestamp
            relative_timestamp = raw_timestamp - first_timestamp_raw
            pktlen = int(packet.length)
            packet_number = -1
            if "quic" in packet:
                packet_number = int(packet.quic.packet_number)
            result.append((relative_timestamp, raw_timestamp, pktlen, packet_number))
    return result


def ipg_json_from_packets(packets: list, target_filepath: str):
    relative_timestamps = [pkt[RELATIVE_TIMESTAMP_IDX] for pkt in packets]
    ips_unfiltered = inter_packet_gaps(relative_timestamps)
    if not os.path.exists(target_filepath.rsplit("/", 1)[0]):
        os.makedirs(target_filepath.rsplit("/", 1)[0])
    with open(target_filepath, "w") as f:
        json.dump(ips_unfiltered, f)
    return


if __name__ == "__main__":

    build_dir = "build/data"
    if not os.path.exists(build_dir):
        os.makedirs(build_dir)

    progress_file = os.path.join(build_dir, "preprocessing.progress.json")
    if os.path.exists(progress_file):
        with open(progress_file, "r") as f:
            progress = json.load(f)
    else:
        progress = {"ipg": [], "precision": []}

    col1len = 90
    col2len = 16
    print("\n| " + "FILE".ljust(col1len) + " | " + "PCAP PARSING".ljust(col2len)
          + " | " + "IPG CALCULATION".ljust(col2len) + " |")
    print(f"| {'-'*col1len} | {'-'*col2len} | {'-'*col2len} |")

    pcaps_dir = os.path.join("..", "results", "pcaps")
    for folder in os.listdir(pcaps_dir):
        if not os.path.isdir(os.path.join(pcaps_dir, folder)):
            continue
        for pcap in os.listdir(os.path.join(pcaps_dir, folder)):
            pcap_path = os.path.join(pcaps_dir, folder, pcap)
            if not pcap.endswith(".pcap") or not os.path.isfile(pcap_path):
                continue
            hash = util.sha256sum(pcap_path)
            name = pcap[:-5]
            print(f"| {name.ljust(col1len-8)} ({hash[:5]}) | ", end="", flush=True)

            packets_filepath = os.path.join(build_dir, folder, pcap.replace(".pcap", ".pcap.json"))
            if os.path.exists(packets_filepath):
                with open(packets_filepath, "r") as f:
                    packets_from_pcap = json.load(f)
                print("Already done!".ljust(col2len) + " | ", end="", flush=True)
            else:
                packets_from_pcap = parse_packets_pcap(pcap_path)
                if not os.path.exists(packets_filepath.rsplit("/", 1)[0]):
                    os.makedirs(packets_filepath.rsplit("/", 1)[0])
                with open(packets_filepath, "w") as f:
                    json.dump(packets_from_pcap, f)
                print("Done".ljust(col2len) + " | ", end="", flush=True)

            if hash in progress["ipg"]:
                print("Already done!".ljust(col2len) + " |")
            else:
                target_filepath = os.path.join(build_dir, folder, pcap.replace(".pcap", ".ipg.json"))
                ipg_json_from_packets(packets_from_pcap, target_filepath)
                progress["ipg"].append(hash)
                with open(progress_file, 'w') as f:
                    json.dump(progress, f)
                print("Done".ljust(col2len) + " |")
    print("\nDone.\n")
