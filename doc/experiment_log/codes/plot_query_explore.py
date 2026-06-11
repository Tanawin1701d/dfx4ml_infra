"""
Generate query-explore figures from DuckDB.
Outputs:
  ../images/query_explore_time_1.png       -- recon_time_1 vs exec_time_1 (all queries)
  ../images/query_explore_time_2.png       -- recon_time_2 vs exec_time_2 (all queries)
  ../images/query_explore_time_1_zoom.png  -- same, zoomed to < 5000 queries
  ../images/query_explore_time_2_zoom.png  -- same, zoomed to < 5000 queries
Times are in clock cycles (100 MHz) → converted to ms.
"""

import duckdb
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from pathlib import Path

DB  = Path(__file__).parent.parent.parent.parent.parent / "experiment" / "dfx4ml_result"
OUT = Path(__file__).parent.parent / "images"
OUT.mkdir(exist_ok=True)

con = duckdb.connect(str(DB), read_only=True)
df  = con.execute(
    "SELECT query_size, recon_time_1, recon_time_2, exec_time_1, exec_time_2, freq "
    "FROM query_explore ORDER BY query_size"
).df()
con.close()

freq_hz = df["freq"].iloc[0] * 1e6   # 100 MHz → Hz
to_ms   = lambda cycles: cycles / freq_hz * 1e3

ANNOT_THRESH = 2500   # only annotate points with query_size >= this


def make_plot(recon_col, exec_col, tag, out_name, xlim=None):
    data = df[df["query_size"] < xlim] if xlim else df
    xs       = data["query_size"].values
    recon_ms = to_ms(data[recon_col].values)
    exec_ms  = to_ms(data[exec_col].values)

    fig, ax = plt.subplots(figsize=(7, 4.5))
    ax.plot(xs, recon_ms, "o-",  color="#4C72B0", linewidth=1.5, markersize=6,
            label=f"recon_time_{tag}")
    ax.plot(xs, exec_ms,  "s--", color="#DD8452", linewidth=1.5, markersize=6,
            label=f"exec_time_{tag}")

    for x, r, e in zip(xs, recon_ms, exec_ms):
        if xlim or x >= ANNOT_THRESH:   # zoom plots always annotate; full plots only >= threshold
            ax.annotate(f"{r:.1f}", (x, r), textcoords="offset points",
                        xytext=(4, 4), fontsize=7, color="#4C72B0")
            ax.annotate(f"{e:.1f}", (x, e), textcoords="offset points",
                        xytext=(4, -12), fontsize=7, color="#DD8452")

    suffix = f" (< {xlim} queries)" if xlim else ""
    ax.set_xlabel("Number of queries")
    ax.set_ylabel("Time (ms)")
    ax.set_title(f"Query Explore — time_{tag}{suffix}\n(KV260, 100 MHz)")
    ax.legend(fontsize=9)
    ax.xaxis.set_minor_locator(ticker.AutoMinorLocator())
    ax.yaxis.set_minor_locator(ticker.AutoMinorLocator())
    ax.grid(linestyle="--", alpha=0.4)
    fig.tight_layout()
    fig.savefig(OUT / out_name, dpi=200)
    plt.close(fig)
    print(f"Saved {out_name}")


make_plot("recon_time_1", "exec_time_1", "1", "query_explore_time_1.png")
make_plot("recon_time_2", "exec_time_2", "2", "query_explore_time_2.png")
make_plot("recon_time_1", "exec_time_1", "1", "query_explore_time_1_zoom.png", xlim=5000)
make_plot("recon_time_2", "exec_time_2", "2", "query_explore_time_2_zoom.png", xlim=5000)
