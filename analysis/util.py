import hashlib

from cycler import cycler
import numpy as np


def sha256sum(filename):
    with open(filename, 'rb', buffering=0) as f:
        return hashlib.file_digest(f, 'sha256').hexdigest()


def set_size(width, fraction=1, ratio=None, subplots=(1, 1)):
    """Set figure dimensions to avoid scaling in LaTeX."""

    if width == 'acmsmall_full':
        width_pt = 395.8225
    elif width == 'acmsmall_half':
        width_pt = 190.0
    elif width == 'acmsmall_pretty':
        width_pt = 260.0
    elif width == 'acmsmall_tiny':
        width_pt = 160.0
    else:
        if isinstance(width, str):
            raise ValueError(f"Unknown width preset: {width}")
        width_pt = width

    fig_width_pt = width_pt * fraction
    inches_per_pt = 1 / 72.27
    golden_ratio = (5**.5 - 1) / 2  # roughly 0.62
    ratio = golden_ratio if ratio is None else float(ratio)
    fig_width_in = fig_width_pt * inches_per_pt
    fig_height_in = fig_width_in * ratio * (subplots[0] / subplots[1])

    return (fig_width_in, fig_height_in)


def rc_setting(plt, fontsize=9, grid=True):
    """Set the rc parameters for matplotlib. Font size should be document font size."""

    color_cycler = cycler("color", plt.cm.viridis(np.linspace(0, 1, 5)))
    linestyle_cycler = cycler('linestyle', ['-', '--', ':', '-.', '-'])
    prop_cycle = (color_cycler + linestyle_cycler)

    return {
        "text.usetex": True,
        "text.latex.preamble": r'\usepackage{libertine}',
        "font.family": "serif",
        "font.serif": ["Linux Libertine"],
        "axes.labelsize": fontsize,
        "font.size": fontsize,
        "legend.fontsize": fontsize-2,
        "xtick.labelsize": fontsize-1,
        "ytick.labelsize": fontsize-1,
        "axes.grid": grid,
        "grid.linestyle": "--",
        "grid.linewidth": 0.5,
        "grid.color": "#e0e0e0",
        "legend.framealpha": 1,
        "legend.edgecolor": "#e0e0e0",
        "axes.prop_cycle": prop_cycle
    }


def init_layout(plt):
    plt.rcParams.update(rc_setting(plt))


if __name__ == "__main__":
    print("This is a utility module. It should not be run directly.")
    print("Only the files starting with two digits are executable.")
    exit()
