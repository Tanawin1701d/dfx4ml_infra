"""
Generate reconfiguration-time figures for the experiment log.
Outputs: ../images/recon_time_bar.png  and  ../images/recon_time_scatter.png
"""

import numpy as np
import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
from pathlib import Path

OUT = Path(__file__).parent.parent / "images"
OUT.mkdir(exist_ok=True)

# Measured data
projects   = ["build_prj_0", "build_prj_1"]
sizes_kb   = np.array([1436, 2897])
recon_ms   = np.array([3.678, 7.417])

# Linear fit: t = slope * size_kb + intercept
slope, intercept = np.polyfit(sizes_kb, recon_ms, 1)  # ≈ 0.002560, 0.0010

# Prediction table points
pred_kb = np.array([6000, 8000, 10000, 12000, 14000, 16000, 18000, 20000, 22000])
pred_ms = slope * pred_kb + intercept

# ── Bar chart ─────────────────────────────────────────────────────────────────
fig, ax = plt.subplots(figsize=(5, 3.5))
bars = ax.bar(projects, recon_ms, color=["#4C72B0", "#DD8452"], width=0.4, zorder=3)
ax.bar_label(bars, fmt="%.3f ms", padding=3, fontsize=9)
ax.set_ylabel("Reconfiguration time (ms)")
ax.set_title("Reconfiguration time per build project\n(KV260, 100 MHz)")
ax.yaxis.set_minor_locator(ticker.AutoMinorLocator())
ax.grid(axis="y", linestyle="--", alpha=0.5, zorder=0)
ax.set_ylim(0, max(recon_ms) * 1.25)
fig.tight_layout()
fig.savefig(OUT / "recon_time_bar.png", dpi=200)
plt.close(fig)
print("Saved recon_time_bar.png")

# ── Scatter + fit ──────────────────────────────────────────────────────────────
KV260_KB  = 8  * 1024   # ≈ 8 MB
ZCU102_KB = 22 * 1024   # ≈ 22 MB

x_fit = np.linspace(0, ZCU102_KB * 1.05, 500)
y_fit = slope * x_fit + intercept

fig, ax = plt.subplots(figsize=(6, 4))
ax.plot(x_fit, y_fit, "--", color="gray", linewidth=1.2, label="Linear fit")
ax.scatter(sizes_kb, recon_ms, color="#4C72B0", s=70, zorder=5, label="Measured")
ax.scatter(pred_kb,  pred_ms,  color="#03FC18", s=40, marker="^", zorder=5, label="Predicted")

# Vertical target lines
ax.axvline(KV260_KB,  color="red", linewidth=1.2, linestyle=":",
           label=f"KV260 ≈8 MB ({KV260_KB} KB)")
ax.axvline(ZCU102_KB, color="red", linewidth=1.2, linestyle="-.",
           label=f"ZCU102 ≈22 MB ({ZCU102_KB} KB)")
y_label = slope * ZCU102_KB * 0.05
ax.text(KV260_KB  + 100, y_label, "KV260\n≈8 MB",  color="red", fontsize=7, va="bottom")
ax.text(ZCU102_KB + 100, y_label, "ZCU102\n≈22 MB", color="red", fontsize=7, va="bottom")

for kb, ms in zip(sizes_kb, recon_ms):
    ax.annotate(f"{ms:.3f} ms", (kb, ms), textcoords="offset points",
                xytext=(6, 4), fontsize=8)

ax.set_xlabel("Bitstream size (KB)")
ax.set_ylabel("Reconfiguration time (ms)")
ax.set_title("Bitstream size vs reconfiguration time\n(KV260, 100 MHz)")
ax.legend(fontsize=8)
ax.xaxis.set_minor_locator(ticker.AutoMinorLocator())
ax.yaxis.set_minor_locator(ticker.AutoMinorLocator())
ax.grid(linestyle="--", alpha=0.4)
fig.tight_layout()
fig.savefig(OUT / "recon_time_scatter.png", dpi=200)
plt.close(fig)
print("Saved recon_time_scatter.png")
