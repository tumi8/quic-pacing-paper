import os
import re
import json

import numpy as np

from data import baseline_data, etf_data, gso_data


def print_metric(name, values, unit="", type="float", prefix="* ", print_single_value=False):
    mean_val, std_val, var_val = np.mean(values), np.std(values), np.var(values)
    formatted_values = [float(f"{val:0.2f}") for val in values]
    if type == "int":
        formatted_values = [int(f"{val}") for val in values]
    output = f"{prefix}{name:<10}: {mean_val:.2f} ± {std_val:.2f} {unit} (variance: {var_val:.4f})"
    if print_single_value:
        output += f" (values: {formatted_values})"
    print(output)


def print_stats(dataset):
    detailed_results_dir = os.path.join("..", "results", "detailed")
    for name, measurement in dataset.items():
        measurement_dir = os.path.join(detailed_results_dir, measurement)
        goodputs = []
        drops = []
        for repetition in os.listdir(measurement_dir):
            rep_dir = os.path.join(measurement_dir, repetition)
            if not os.path.isdir(rep_dir):
                continue
            result_file_path = os.path.join(rep_dir, "result.json")
            with open(result_file_path) as f:
                result = json.load(f)
            goodput = 0
            if result["measurements"][0][0]["result"] == "succeeded":
                goodput = result["measurements"][0][0]["details"][0]
                goodputs.append(goodput)
            impl_dir_name = [name for name in os.listdir(rep_dir) if os.path.isdir(os.path.join(rep_dir, name))][0]
            client_tc_log_path = os.path.join(rep_dir, impl_dir_name, "goodput", "1", "client", "tc-stats.txt")

            with open(client_tc_log_path, "r") as f:
                tc_stats = f.read()
                dropped_packets = re.findall(r"\(dropped (\d+)", tc_stats)
                dropped_packets = list(map(int, dropped_packets))[2]
                drops.append(dropped_packets)

        print(f"* {measurement}")
        print_metric("Goodput", goodputs, "Mbps", prefix="  * ")
        print_metric("Dropped", drops, "packets", "int", prefix="  * ")


if __name__ == "__main__":

    print("Baseline Stats:")
    print_stats(baseline_data)
    print("")

    print("GSO Stats:")
    print_stats(gso_data)
    print("")

    print("ETF Stats:")
    print_stats(etf_data)
    print("")
