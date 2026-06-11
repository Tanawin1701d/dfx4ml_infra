#!/usr/bin/env python3
"""
prepare_export_data.py
----------------------
Copy the HLS reference vectors into this example's export/data folder,
verifying the full source shapes and slicing down to AMT_QUERY rows.

  x_input  : (1000000, 8, 8, 1)  →  (AMT_QUERY, 8, 8, 1)
  y_pred   : (   20000,       4) →  (AMT_QUERY,       4)
"""

import os
import numpy as np

# ── parameters ─────────────────────────────────────────────────────────────
AMT_QUERY = 900                                            # rows kept after slice

PRJ_DIR    = os.path.dirname(os.path.abspath(__file__))
EXPORT_DIR = os.path.join(PRJ_DIR, "export", "data")

# ── source files ───────────────────────────────────────────────────────────
HLS_ROOT  = "/media/tanawin/tanawin1701e/project7/hls4ml/hls4ml_output2"
X_SRC     = os.path.join(HLS_ROOT, "_exp_locked_skip4",    "x_input_1000000.npy")
Y_SRC     = os.path.join(HLS_ROOT, "hls4mlprj_skip4_full", "y_pred_hls.npy")

# ── expected full source shapes (checked before slicing) ───────────────────
X_FULL_SHAPE = (1000000, 8, 8, 1)
Y_FULL_SHAPE = (20000,   4)                               # note: not (100000, 4)

# ── destination files ──────────────────────────────────────────────────────
X_DST = os.path.join(EXPORT_DIR, "x_input.npy")
Y_DST = os.path.join(EXPORT_DIR, "y_pred_hls.npy")


def main():
    os.makedirs(EXPORT_DIR, exist_ok=True)

    # ── x_input ────────────────────────────────────────────────────────────
    x = np.load(X_SRC)
    assert x.shape == X_FULL_SHAPE, f"x shape mismatch: {x.shape} vs {X_FULL_SHAPE}"
    x_slice = x[:AMT_QUERY]                                # (AMT_QUERY, 8, 8, 1)
    assert x_slice.shape == (AMT_QUERY, 8, 8, 1), x_slice.shape
    np.save(X_DST, x_slice)
    print(f"x_input : {x.shape} -> {x_slice.shape}  saved {X_DST}")

    # ── y_pred ─────────────────────────────────────────────────────────────
    y = np.load(Y_SRC)
    assert y.shape == Y_FULL_SHAPE, f"y shape mismatch: {y.shape} vs {Y_FULL_SHAPE}"
    y_slice = y[:AMT_QUERY]                                # (AMT_QUERY, 4)
    assert y_slice.shape == (AMT_QUERY, 4), y_slice.shape
    np.save(Y_DST, y_slice)
    print(f"y_pred  : {y.shape} -> {y_slice.shape}  saved {Y_DST}")


if __name__ == "__main__":
    main()