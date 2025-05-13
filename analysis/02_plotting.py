import os
import json

import numpy as np
import matplotlib.pyplot as plt

from util import init_layout, set_size
from data import baseline_data, quiche_data, ngtcp_data, picoquic_data, gso_data, fq_data

FIGURE_SIZE = "acmsmall_pretty"
FIGURE_RATIO = None


def update_output_size(size, ratio=None):
    global FIGURE_SIZE, FIGURE_RATIO
    FIGURE_SIZE = size
    FIGURE_RATIO = ratio


def data_list_from_measurements_dict(data_dict):
    data = {}
    for k, v in data_dict.items():
        data[k] = []
        datapath = os.path.join("build", "data", v)
        if not os.path.exists(datapath):
            print(f"Warning: {datapath} does not exist.")
            print("Please run the preprocessing script first.")
            print("Exiting...")
            exit()
        for d in os.listdir(datapath):
            if d.endswith(".ipg.json"):
                data[k].extend(json.load(open(os.path.join(datapath, d))))
    return data


def figure(func):
    def inner(*args, **kwargs):
        global FIGURE_SIZE, FIGURE_RATIO
        fig = plt.figure(figsize=set_size(FIGURE_SIZE, ratio=FIGURE_RATIO))
        file_ending = ".pdf"
        fig.canvas.header_visible = False
        ax = fig.subplots()
        save_as = func(ax, *args, **kwargs)
        if save_as:
            save_as = f"build/figures/{save_as}{file_ending}"
            print(f"Saving figure to {save_as}")
            fig.savefig(save_as, bbox_inches="tight")
            plt.close(fig)

    return inner


@figure
def cdf_multi(ax, ips_list, type="ipg", ylabel="CDF", save_as=""):
    """Generate a CDF plot. Two types are supported: inter-packet gap (ipg) and packet train size (trainsize)."""
    ylim = [0, 1.05]

    if type == "ipg":
        xlim = [-0.05, 2.05]
        xlabel = "Inter-Packet Gap [ms]"
    elif type == "trainsize":
        max = 20
        xlim = [0.5, max + 0.5]
        xlabel = "Packet Train Length [packets]"
        xticks = range(1, max + 1)
        ax.set_xticks(xticks)
        if len(xticks) > 12:
            ax.set_xticklabels([x if x % 5 == 0 or x == 1 else "" for x in xticks])

    ax.set_xlim(xlim)
    ax.set_xlabel(xlabel)
    ax.set_ylim(ylim)
    ax.set_ylabel(ylabel)

    for label, ips in ips_list.items():
        ax.ecdf(ips, label=label)

    lines, labels = ax.get_legend_handles_labels()
    ax.legend(lines, labels, loc="lower right")

    return f"{save_as}-{type}-cdf" if save_as else ""


def ips_to_trainsize(ips, threshold=0.1):
    below_threshold = np.array(ips) < threshold
    lengths = []
    count = 1
    for is_below in below_threshold:
        if not is_below:
            lengths.extend(count * [count])
            count = 0
        count += 1
    lengths.extend(count * [count])
    return lengths


def generate_baseline_plots():
    data_ipg = data_list_from_measurements_dict(baseline_data)
    data_trainsize = {k: ips_to_trainsize(v) for k, v in data_ipg.items()}
    label = "baseline"
    ylabel = r"$\frac{\mathrm{\#Packets}}{\mathrm{PTL}}$ [CDF]"
    cdf_multi(data_ipg, save_as=label)
    cdf_multi(data_trainsize, type="trainsize", ylabel=ylabel, save_as=label)


def generate_default_plots(data, label):
    data_ipg = data_list_from_measurements_dict(data)
    data_trainsize = {k: ips_to_trainsize(v) for k, v in data_ipg.items()}
    ylabel = r"$\frac{\mathrm{\#Packets}}{\mathrm{Packet Train Length}}$ [CDF]"
    cdf_multi(data_ipg, save_as=label)
    cdf_multi(data_trainsize, type="trainsize", ylabel=ylabel, save_as=label)


def generate_gso_plots():
    return generate_default_plots(gso_data, "gso")


def generate_fq_plots():
    return generate_default_plots(fq_data, "fq")


def generate_implementation_plots(data, label):
    data_ipg = data_list_from_measurements_dict(data)
    data_trainsize = {k: ips_to_trainsize(v) for k, v in data_ipg.items()}
    ylabel = r"$\frac{\mathrm{\#Packets}}{\mathrm{PTL}}$ [CDF]"
    cdf_multi(data_ipg, save_as=label)
    cdf_multi(data_trainsize, type="trainsize", ylabel=ylabel, save_as=label)


def generate_all_plots():
    if not os.path.exists("build/figures"):
        os.makedirs("build/figures")

    update_output_size("acmsmall_half")
    generate_baseline_plots()

    update_output_size("acmsmall_pretty", 0.55)
    generate_gso_plots()
    update_output_size("acmsmall_pretty", 0.58)
    generate_fq_plots()

    update_output_size("acmsmall_tiny")
    generate_implementation_plots(quiche_data, "quiche")
    generate_implementation_plots(ngtcp_data, "ngtcp")
    generate_implementation_plots(picoquic_data, "picoquic")


init_layout(plt)
generate_all_plots()
