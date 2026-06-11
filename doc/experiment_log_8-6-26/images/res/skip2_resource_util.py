#!/usr/bin/env python3
"""Visualise the two-part (skip2) DFX resource utilisation against the
Kria KV260 (xck26) device capacity.

Reads the ``skip2_exp_res`` table from the project DuckDB result store and
draws a grouped bar chart of LUT / LUTRAM / FF / BRAM / URAM / DSP usage,
expressed as a percentage of what the KV260 actually provides.

The figure and this script live together under ``images/perf/``.
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
TABLE   = "skip2_exp_res"
OUT_DIR = os.path.dirname(os.path.abspath(__file__))
OUT_PNG = os.path.join(OUT_DIR, "skip2_resource_util.png")


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

# friendly legend labels for each `config` value found in the table
LABELS = {
    "config_parent":    "Full design (impl_dfx)",
    "config_child_0_0": "Half A + static region",
    "config_child_0_1": "Half B + static region",
}

COLORS = ["#4C72B0", "#DD8452", "#55A868", "#C44E52", "#8172B3"]


# ----------------------------------------------------------------------------
# data loading
# ----------------------------------------------------------------------------
def load_df():
    """Return the skip2_exp_res table as a DataFrame.

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
    # keep only the reconfigurable-module (child) runs, drop the parent impl
    df = df[df["config"] != "config_parent"].reset_index(drop=True)
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
    w = 0.80 / n

    fig, ax = plt.subplots(figsize=(12.5, 6.8))
    for i, lab in enumerate(labels):
        off  = (i - (n - 1) / 2.0) * w
        bars = ax.bar(x + off, pct[i], w, label=lab,
                      color=COLORS[i % len(COLORS)],
                      edgecolor="black", linewidth=0.4)
        for j, b in enumerate(bars):
            ax.annotate(f"{pct[i][j]:.1f}%\n({int(absv[i][j]):,})",
                        (b.get_x() + b.get_width() / 2, b.get_height()),
                        xytext=(0, 2), textcoords="offset points",
                        ha="center", va="bottom", fontsize=6.3)

    # device-limit reference line
    ax.axhline(100, color="red", ls="--", lw=1.0)
    ax.text(len(RESOURCES) - 0.45, 101, "100% device limit",
            color="red", ha="right", va="bottom", fontsize=8)

    ax.set_xticks(x)
    ax.set_xticklabels([f"{r}\n(/{CAP[r]:,})" for r in RESOURCES])
    ax.set_ylabel("Utilisation (% of KV260 / xck26 available)")
    ax.set_title("Two-part (skip2) DFX resource utilisation vs. Kria KV260 capacity")
    ax.set_ylim(0, 115)
    ax.legend(loc="upper center", ncol=n, frameon=False)
    ax.grid(axis="y", ls=":", alpha=0.5)
    ax.set_axisbelow(True)

    fig.tight_layout()
    fig.savefig(OUT_PNG, dpi=150)
    print("saved:", OUT_PNG)


if __name__ == "__main__":
    main()
