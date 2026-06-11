#!/usr/bin/env python3
"""Visualise the two-part (skip2) DFX pipeline as a two-lane timeline.

Reads the ``skip2_exp_perf`` table from the project DuckDB result store and
draws a Gantt-style timeline with two lanes:

    lane 1 (top)    : recon_prof  -- partial-bitstream reconfiguration time
    lane 2 (bottom) : exec_prof   -- ML-kernel execution time

Each row of the table (one DFX Manager slot) contributes one box to each
lane.  Both boxes of a slot start at the same absolute time, and the *next*
slot starts at the larger of the two end times -- i.e.

    t_start[i+1] = t_start[i] + max(recon_prof[i], exec_prof[i])

In the two-part scheme both halves share a single PR region over two phases,
so reconfiguration and execution do not overlap: each slot is dominated by
one lane while the other is ~1 cycle, giving a serial reconfigure/execute
schedule (in contrast to the double-buffered four-part scheme).

Profiling counters are clock cycles; they are converted to milliseconds at
the build clock (``clk_frq`` ~ 100 MHz).  The figure and this script live
together under ``images/perf/``.
"""

import os
import shutil
import tempfile

import duckdb
import numpy as np
import matplotlib
matplotlib.use("Agg")          # headless / batch rendering
import matplotlib.pyplot as plt
from matplotlib.patches import Patch


# ----------------------------------------------------------------------------
# paths / constants
# ----------------------------------------------------------------------------
DB_PATH  = "/media/tanawin/tanawin1701e/project8/dfx4ml/experiment/dfx4ml_result"
TABLE    = "skip2_exp_perf"
OUT_DIR  = os.path.dirname(os.path.abspath(__file__))
OUT_PNG  = os.path.join(OUT_DIR, "skip2_perf.png")

CLK_FREQ = 99999001.0          # build clock (Hz), ~100 MHz -> cycles -> ms
NUM_RM   = 2                   # RM variants per PR region (skip2: 1 region x 2 RMs)

# lane geometry: (bottom, height) for broken_barh; recon sits on top
RECON_LANE = (1.10, 0.80)
EXEC_LANE  = (0.10, 0.80)

COLORS = ["#4C72B0", "#DD8452", "#55A868", "#C44E52", "#8172B3",
          "#937860", "#DA8BC3", "#8C8C8C"]


# ----------------------------------------------------------------------------
# data loading
# ----------------------------------------------------------------------------
def load_df():
    """Return the skip2_exp_perf table as a DataFrame, ordered by slot.

    The live DuckDB file is often locked by a GUI client (DataGrip), so we
    copy it to a temporary file and open that copy read-only.
    """
    tmp = tempfile.NamedTemporaryFile(suffix=".duckdb", delete=False).name
    shutil.copy(DB_PATH, tmp)
    try:
        con = duckdb.connect(tmp, read_only=True)
        df  = con.execute(f"SELECT * FROM {TABLE} ORDER BY slot").fetchdf()
        con.close()
    finally:
        os.remove(tmp)
    return df


def decode_rm(v):
    """One-hot RM select -> (region, rm); (-1, -1) if no bit set.

    Bit layout (see example/multi_region_test*/): bit = region*NUM_RM + rm,
    i.e. bit0=r0/rm0, bit1=r0/rm1, bit2=r1/rm0, bit3=r1/rm1.  In the skip2
    scheme there is a single region, so both halves resolve to region 0.
    """
    v = int(v)
    if v <= 0:
        return -1, -1
    b = v.bit_length() - 1
    return b // NUM_RM, b % NUM_RM


# ----------------------------------------------------------------------------
# plotting
# ----------------------------------------------------------------------------
def main():
    df = load_df()
    print(df.to_string())

    cyc2ms = 1.0e3 / CLK_FREQ
    recon  = df["recon_prof"].to_numpy(dtype=float) * cyc2ms
    execp  = df["exec_prof"].to_numpy(dtype=float) * cyc2ms
    slots  = df["slot"].tolist()

    # absolute start time of each slot: next box begins at the later of the
    # two lane end-times of the current slot.
    n      = len(df)
    starts = np.zeros(n)
    for i in range(1, n):
        starts[i] = starts[i - 1] + max(recon[i - 1], execp[i - 1])
    total = starts[-1] + max(recon[-1], execp[-1])

    fig, ax = plt.subplots(figsize=(14, 4.2))

    def draw_lane(lane, durs, rm_col):
        """Draw one lane's boxes + per-box labels (duration, RM part)."""
        for i in range(n):
            c = COLORS[i % len(COLORS)]
            ax.broken_barh([(starts[i], durs[i])], lane,
                           facecolors=c, edgecolor="black", linewidth=0.6)
            region, rm = decode_rm(df[rm_col].iloc[i])
            cx = starts[i] + durs[i] / 2.0
            cy = lane[0] + lane[1] / 2.0
            tag = f"\nregion {region} / RM {rm}" if rm >= 0 else ""
            # only label boxes wide enough to hold text; skip the ~1-cycle ones
            if durs[i] >= 0.04 * total:
                ax.text(cx, cy, f"{durs[i]:.2f} ms{tag}",
                        ha="center", va="center", fontsize=7.5,
                        color="white", fontweight="bold")

    draw_lane(RECON_LANE, recon, "recon_rm_sel")
    draw_lane(EXEC_LANE,  execp, "exec_rm_sel")

    # slot-boundary guides + slot labels along the top
    for i in range(n):
        ax.axvline(starts[i], color="grey", ls=":", lw=0.8, zorder=0)
        ax.text(starts[i], RECON_LANE[0] + RECON_LANE[1] + 0.30,
                f"slot {slots[i]}", ha="left", va="bottom",
                fontsize=8, color="black")
    ax.axvline(total, color="grey", ls=":", lw=0.8, zorder=0)

    # axes cosmetics
    ax.set_xlim(-0.02 * total, total * 1.02)
    ax.set_ylim(0.0, RECON_LANE[0] + RECON_LANE[1] + 0.7)
    ax.set_yticks([EXEC_LANE[0]  + EXEC_LANE[1]  / 2.0,
                   RECON_LANE[0] + RECON_LANE[1] / 2.0])
    ax.set_yticklabels(["exec_prof", "recon_prof"])
    ax.set_xlabel("Absolute time (ms)  @ %.0f MHz" % (CLK_FREQ / 1e6))
    ax.set_title("Two-part (skip2) DFX pipeline timeline "
                 "— reconfiguration vs. execution per slot")
    ax.grid(axis="x", ls=":", alpha=0.4)
    ax.set_axisbelow(True)

    legend = [Patch(facecolor=COLORS[i % len(COLORS)], edgecolor="black",
                    label=f"slot {slots[i]}") for i in range(n)]
    ax.legend(handles=legend, loc="upper right", ncol=n, frameon=False,
              fontsize=8, bbox_to_anchor=(1.0, 1.18))

    fig.text(0.01, 0.01,
             f"total = {total:.2f} ms   "
             f"(recon sum = {recon.sum():.2f} ms, "
             f"exec sum = {execp.sum():.2f} ms)",
             fontsize=8, color="dimgray")

    fig.tight_layout()
    fig.savefig(OUT_PNG, dpi=150)
    print("saved:", OUT_PNG)


if __name__ == "__main__":
    main()
