#!/usr/bin/env python3
"""Combined two-/four-part (skip2 vs skip4) DFX pipeline timeline.

Overlays both schemes on a single shared time axis so the schedules can be
compared directly.  Four lanes are stacked:

    skip4 recon_prof  (top)
    skip4 exec_prof
    skip2 recon_prof
    skip2 exec_prof   (bottom)

Each scheme is drawn with the same per-slot box model as the standalone
``skip4_perf.py`` / ``skip2_perf.py`` scripts: both lanes of a slot start at
the same absolute time, and the next slot starts at the later of the two end
times,  t_start[i+1] = t_start[i] + max(recon_prof[i], exec_prof[i]).

The skip2 timeline is shifted so that its origin lines up with the start of
skip4 *slot 1* (skip4 slot 0 is the init-only reconfiguration of the first
RM).  Profiling counters are clock cycles, converted to ms at the build clock
(``clk_frq`` ~ 100 MHz).  The figure and this script live together under
``images/perf/``.
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
# paths / constants
# ----------------------------------------------------------------------------
DB_PATH    = "/media/tanawin/tanawin1701e/project8/dfx4ml/experiment/dfx4ml_result"
SKIP4_TBL  = "skip4_exp_perf"
SKIP2_TBL  = "skip2_exp_perf"
OUT_DIR    = os.path.dirname(os.path.abspath(__file__))
OUT_PNG    = os.path.join(OUT_DIR, "skip_combined_perf.png")

CLK_FREQ   = 99999001.0        # build clock (Hz), ~100 MHz -> cycles -> ms
NUM_RM     = 2                 # RM variants per PR region (one-hot = region*NUM_RM + rm)

LANE_H     = 0.80              # height of one lane
# (bottom, height) for broken_barh; recon sits above exec within each scheme
SKIP4_RECON = (3.50, LANE_H)
SKIP4_EXEC  = (2.60, LANE_H)
SKIP2_RECON = (1.10, LANE_H)
SKIP2_EXEC  = (0.20, LANE_H)

COLORS = ["#4C72B0", "#DD8452", "#55A868", "#C44E52", "#8172B3",
          "#937860", "#DA8BC3", "#8C8C8C"]


# ----------------------------------------------------------------------------
# data loading / decoding
# ----------------------------------------------------------------------------
def load_df(table):
    """Return a *_exp_perf table as a DataFrame, ordered by slot.

    The live DuckDB file is often locked by a GUI client (DataGrip), so we
    copy it to a temporary file and open that copy read-only.
    """
    tmp = tempfile.NamedTemporaryFile(suffix=".duckdb", delete=False).name
    shutil.copy(DB_PATH, tmp)
    try:
        con = duckdb.connect(tmp, read_only=True)
        df  = con.execute(f"SELECT * FROM {table} ORDER BY slot").fetchdf()
        con.close()
    finally:
        os.remove(tmp)
    return df


def decode_rm(v):
    """One-hot RM select -> (region, rm); (-1, -1) if no bit set.

    Bit layout (see example/multi_region_test*/): bit = region*NUM_RM + rm,
    i.e. bit0=r0/rm0, bit1=r0/rm1, bit2=r1/rm0, bit3=r1/rm1.
    """
    v = int(v)
    if v <= 0:
        return -1, -1
    b = v.bit_length() - 1
    return b // NUM_RM, b % NUM_RM


def schedule(df):
    """Return (recon_ms, exec_ms, starts_ms, total_ms) for a perf table."""
    cyc2ms = 1.0e3 / CLK_FREQ
    recon  = df["recon_prof"].to_numpy(dtype=float) * cyc2ms
    execp  = df["exec_prof"].to_numpy(dtype=float) * cyc2ms
    n      = len(df)
    starts = np.zeros(n)
    for i in range(1, n):
        starts[i] = starts[i - 1] + max(recon[i - 1], execp[i - 1])
    total = starts[-1] + max(recon[-1], execp[-1])
    return recon, execp, starts, total


# ----------------------------------------------------------------------------
# plotting
# ----------------------------------------------------------------------------
def draw_scheme(ax, df, recon, execp, starts, t0, recon_lane, exec_lane,
                slot_label_y, total_span):
    """Draw one scheme's two lanes (boxes + labels) shifted by ``t0``."""
    n = len(df)

    def lane(lane_geom, durs, rm_col):
        for i in range(n):
            x = t0 + starts[i]
            c = COLORS[i % len(COLORS)]
            ax.broken_barh([(x, durs[i])], lane_geom,
                           facecolors=c, edgecolor="black", linewidth=0.6)
            region, rm = decode_rm(df[rm_col].iloc[i])
            tag = f"\nregion {region} / RM {rm}" if rm >= 0 else ""
            # only label boxes wide enough to hold text; skip the ~1-cycle ones
            if durs[i] >= 0.04 * total_span:
                ax.text(x + durs[i] / 2.0, lane_geom[0] + lane_geom[1] / 2.0,
                        f"{durs[i]:.2f} ms{tag}", ha="center", va="center",
                        fontsize=7.0, color="white", fontweight="bold")

    lane(recon_lane, recon, "recon_rm_sel")
    lane(exec_lane,  execp, "exec_rm_sel")

    # per-scheme slot-boundary guides + slot labels, confined to this band
    y0 = exec_lane[0]
    y1 = recon_lane[0] + recon_lane[1]
    for i in range(n):
        x = t0 + starts[i]
        ax.vlines(x, y0, y1, color="grey", ls=":", lw=0.8, zorder=0)
        ax.text(x, y1 + 0.04, f"slot {df['slot'].iloc[i]}", ha="left",
                va="bottom", fontsize=7.5, color="black")
    ax.vlines(t0 + starts[-1] + max(recon[-1], execp[-1]), y0, y1,
              color="grey", ls=":", lw=0.8, zorder=0)


def main():
    df4 = load_df(SKIP4_TBL)
    df2 = load_df(SKIP2_TBL)

    recon4, exec4, starts4, total4 = schedule(df4)
    recon2, exec2, starts2, total2 = schedule(df2)

    # skip2 origin aligns with the start of skip4 slot 1 (skip4 slot 0 is
    # init-only reconfiguration of the first RM).
    offset = starts4[1]
    span   = max(total4, offset + total2)

    fig, ax = plt.subplots(figsize=(16, 6.2))

    draw_scheme(ax, df4, recon4, exec4, starts4, 0.0,
                SKIP4_RECON, SKIP4_EXEC,
                SKIP4_RECON[0] + SKIP4_RECON[1], span)
    draw_scheme(ax, df2, recon2, exec2, starts2, offset,
                SKIP2_RECON, SKIP2_EXEC,
                SKIP2_RECON[0] + SKIP2_RECON[1], span)

    # alignment marker: skip2 t=0 == skip4 slot 1 start
    ax.axvline(offset, color="#C44E52", ls="--", lw=1.3, zorder=1)
    ax.text(offset + span * 0.004, SKIP4_RECON[0] + SKIP4_RECON[1] + 0.30,
            "skip2 start  =  skip4 slot 1", color="#C44E52",
            ha="left", va="bottom", fontsize=8.5, fontweight="bold")

    # scheme group separators / shading for readability
    ax.axhspan(SKIP4_EXEC[0] - 0.10, SKIP4_RECON[0] + SKIP4_RECON[1] + 0.05,
               color="#4C72B0", alpha=0.04, zorder=0)
    ax.axhspan(SKIP2_EXEC[0] - 0.10, SKIP2_RECON[0] + SKIP2_RECON[1] + 0.05,
               color="#55A868", alpha=0.04, zorder=0)

    # axes cosmetics
    ax.set_xlim(-0.01 * span, span * 1.02)
    ax.set_ylim(0.0, SKIP4_RECON[0] + SKIP4_RECON[1] + 0.75)
    ax.set_yticks([
        SKIP4_RECON[0] + SKIP4_RECON[1] / 2.0,
        SKIP4_EXEC[0]  + SKIP4_EXEC[1]  / 2.0,
        SKIP2_RECON[0] + SKIP2_RECON[1] / 2.0,
        SKIP2_EXEC[0]  + SKIP2_EXEC[1]  / 2.0,
    ])
    ax.set_yticklabels(["skip4  recon_prof", "skip4  exec_prof",
                        "skip2  recon_prof", "skip2  exec_prof"])
    ax.set_xlabel("Absolute time (ms)  @ %.0f MHz" % (CLK_FREQ / 1e6))
    ax.set_title("Combined DFX pipeline timeline — skip4 (4-part) vs. skip2 "
                 "(2-part), aligned at skip4 slot 1")
    ax.grid(axis="x", ls=":", alpha=0.4)
    ax.set_axisbelow(True)

    fig.text(0.01, 0.01,
             f"skip4 total = {total4:.2f} ms   |   "
             f"skip2 total = {total2:.2f} ms "
             f"(ends at {offset + total2:.2f} ms with offset {offset:.2f} ms)",
             fontsize=8.5, color="dimgray")

    fig.tight_layout()
    fig.savefig(OUT_PNG, dpi=150)
    print("saved:", OUT_PNG)


if __name__ == "__main__":
    main()
