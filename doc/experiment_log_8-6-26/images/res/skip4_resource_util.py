#!/usr/bin/env python3
"""Visualise the four-part (skip4) DFX resource utilisation against the
Kria KV260 (xck26) device capacity.

Reads the ``skip4_exp_res`` table from the project DuckDB result store and
draws a grouped bar chart of LUT / LUTRAM / FF / BRAM / URAM / DSP usage for
each of the four reconfigurable parts, expressed as a percentage of what the
KV260 actually provides.  Every child impl row already contains the static
region (the static-only parent reports 8354 LUT / 0 DSP), so each bar is
labelled "<part> + static".

The figure and this script live together under ``images/res/``.
"""

import os
import shutil
import tempfile

import duckdb
import numpy as np
import matplotlib
matplotlib.use("Agg")          # headless / batch rendering
import matplotlib.pyplot as plt


# ----------------------------------------------------------------------------
# paths
# ----------------------------------------------------------------------------
DB_PATH = "/media/tanawin/tanawin1701e/project8/dfx4ml/experiment/dfx4ml_result"
TABLE   = "skip4_exp_res"
OUT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PNG = os.path.join(OUT_DIR, "skip4_resource_util.png")


# ----------------------------------------------------------------------------
# Kria KV260 (xck26-sfvc784) maximum available resources
# ----------------------------------------------------------------------------
CAP = {
    "LUT":    117120,
    "LUTRAM":  57600,
    "FF":     234240,
    "BRAM":      144,
    "URAM":       64,
    "DSP":      1248,
}
RESOURCES = list(CAP.keys())

# resource label -> column name in the DuckDB table
DB_COL = {
    "LUT":    "lut",
    "LUTRAM": "lutram",
    "FF":     "ff",
    "BRAM":   "bram",
    "URAM":   "uram",
    "DSP":    "dsp",
}

# config -> friendly legend label, in Part-1..Part-4 reading order.
# config_child_<region>_<rm>; Part->region/rm follows the four-part mapping.
CONFIG_ORDER = [
    "config_child_0_0",   # region 0 / rm 0
    "config_child_1_0",   # region 1 / rm 0
    "config_child_0_1",   # region 0 / rm 1
    "config_child_1_1",   # region 1 / rm 1
]
LABELS = {
    "config_child_0_0": "Part 1 Encoder-A + static",
    "config_child_1_0": "Part 2 Enc-B+Bottleneck + static",
    "config_child_0_1": "Part 3 Decoder-A + static",
    "config_child_1_1": "Part 4 Dec-B+Head + static",
}

COLORS = ["#4C72B0", "#DD8452", "#55A868", "#C44E52", "#8172B3"]


# ----------------------------------------------------------------------------
# data loading
# ----------------------------------------------------------------------------
def load_df():
    """Return the skip4_exp_res table as a DataFrame.

    The live DuckDB file is often locked by a GUI client (DataGrip), so we
    copy it to a temporary file and open that copy read-only.
    """
    tmp = tempfile.NamedTemporaryFile(suffix=".duckdb", delete=False).name
    shutil.copy(DB_PATH, tmp)
    try:
        con = duckdb.connect(tmp, read_only=True)
        df  = con.execute(f"SELECT * FROM {TABLE}").fetchdf()
        con.close()
    finally:
        os.remove(tmp)
    return df


# ----------------------------------------------------------------------------
# plotting
# ----------------------------------------------------------------------------
def main():
    df = load_df()
    # keep only the reconfigurable-module (child) runs, ordered Part 1..4
    df = df[df["config"] != "config_parent"]
    df = df.set_index("config").loc[CONFIG_ORDER].reset_index()
    print(df.to_string())

    configs = df["config"].tolist()
    labels  = [LABELS.get(c, c) for c in configs]

    # absolute counts and percentage utilisation, shaped [config][resource]
    absv = np.array([[df.loc[df.config == c, DB_COL[r]].iloc[0]
                      for r in RESOURCES] for c in configs], dtype=float)
    pct  = np.array([[absv[i][j] / CAP[r] * 100.0
                      for j, r in enumerate(RESOURCES)]
                     for i in range(len(configs))])

    n = len(configs)
    x = np.arange(len(RESOURCES))
    w = 0.84 / n

    fig, ax = plt.subplots(figsize=(15, 7.0))
    for i, lab in enumerate(labels):
        off  = (i - (n - 1) / 2.0) * w
        bars = ax.bar(x + off, pct[i], w, label=lab,
                      color=COLORS[i % len(COLORS)],
                      edgecolor="black", linewidth=0.4)
        for j, b in enumerate(bars):
            ax.annotate(f"{pct[i][j]:.1f}%\n({int(absv[i][j]):,})",
                        (b.get_x() + b.get_width() / 2, b.get_height()),
                        xytext=(0, 2), textcoords="offset points",
                        ha="center", va="bottom", fontsize=5.5)

    # reference lines at 50% and 100% of the device
    ax.axhline(100, color="red", ls="--", lw=1.0)
    ax.text(len(RESOURCES) - 0.45, 101, "100% device limit",
            color="red", ha="right", va="bottom", fontsize=8)
    ax.axhline(50, color="red", ls="--", lw=1.0)
    ax.text(len(RESOURCES) - 0.45, 51, "50% of device",
            color="red", ha="right", va="bottom", fontsize=8)

    ax.set_xticks(x)
    ax.set_xticklabels([f"{r}\n(/{CAP[r]:,})" for r in RESOURCES])
    ax.set_ylabel("Utilisation (% of KV260 / xck26 available)")
    ax.set_title("Four-part (skip4) DFX resource utilisation vs. Kria KV260 capacity")
    ax.set_ylim(0, 115)
    ax.legend(loc="upper center", ncol=n, frameon=False, fontsize=9)
    ax.grid(axis="y", ls=":", alpha=0.5)
    ax.set_axisbelow(True)

    fig.tight_layout()
    fig.savefig(OUT_PNG, dpi=150)
    print("saved:", OUT_PNG)


if __name__ == "__main__":
    main()
