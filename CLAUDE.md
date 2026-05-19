# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DFX4ML-ARCH** is an FPGA architecture for self-reconfiguring ML inference. The FPGA autonomously swaps its own ML accelerator kernels at runtime via Dynamic Function eXchange (DFX/partial reconfiguration), enabling models too large to fit the device to run segment-by-segment without CPU intervention.

**Target platform:** Zynq UltraScale+ KV260 · Vivado 2023.2 · Ubuntu 22.04 + PYNQ

---

## Build Commands

### Full hardware + software build
Open `quick_start.ipynb` and run all cells. This is the primary entry point.

### Python build from a script
```python
from lib.hw_build import HwBuildHelper
from lib.sw_build import SwBuildHelper

hw_builder = HwBuildHelper(
    build_folder_path       = "./build_prj",
    dfx_root_path           = ".",
    board                   = "kv260",
    user_repo_path          = "",
    user_rm_build_tcl_path  = "",
    req_gen_ip              = 1,        # must be 1 on first run
    num_core                = 4,
    clk_frq                 = 99999001,
    rm_index_width          = 2,
    dfx_streamers           = [{"load_width": 4, "store_width": 4, "actual_width": 32, "amount_row": 1024}],
    dfx_regions             = [{"load_streamers": [0], "store_streamers": [0]}],
    rm_schemetics           = [[{...}, {...}]],  # [region_idx][rm_idx]
    test_mode               = 1,
    vivado_path             = "<abs path to vivado>",
    export_folder_path      = "./export"
)
hw_builder.run_build()
hw_builder.package_export_files()

sw_builder = SwBuildHelper(export_folder_path="./export", num_pr_region=1, rm_index_width=2, num_streamer=1)
sw_builder.package_export_file()
```

### IP-only build (no synthesis)
```python
hw_builder = HwBuildHelper.for_ip_only("./build_prj", ".", "<vivado path>")
hw_builder.build_ip_only()
```

### LaTeX documentation
```bash
cd doc/tech_report && latexmk -pdf main.tex
cd doc/experiment_log && latexmk -pdf main.tex
```

---

## Architecture

### Hardware layers

The FPGA fabric is split into two permanent regions:

| Region | Key IPs |
|---|---|
| **Static Region** | DFX Manager (`dfx_mng`), DFX Controller (`dfx_unified` BD + Xilinx DFX Ctrl IP), DFX Streamer(s) (`dfx_streamer`), DMA Controller, ICAP3 wrapper (`dfx_icap`) |
| **Reconfigurable Region (RP)** | Swappable ML kernel loaded at runtime from DDR through ICAP3 |

The **DFX Manager** (`hw/ip_src/dfx_mng/`) is the autonomous orchestrator. It:
1. Commands the DFX Controller to fetch a partial `.bin` bitstream from DDR → ICAP3
2. Pre-loads/stores data via DFX Streamers (on-chip BRAM buffers)
3. Triggers ML kernel execution via the PR Ctrl IP (HLS `ap_ctrl_hs`)
4. Chains sessions via a slot-linked-list in its register bank — no host CPU involvement in the loop

**DFX Streamer** (`hw/ip_src/dfx_streamer/`) is a parameterized AXI-Stream ↔ BRAM buffer that sits between the DMA and the RP boundary, buffering data pre/post-reconfiguration.

### Block Design hierarchy (Vivado)

```
dfx4ml (top BD)
├── dfx_unified_0        ← Static control BD (PS + DMA + DFX Manager + DFX Ctrl + Streamers)
│   ├── dma_hier         ← AXI DMA + decoupler wiring
│   ├── dfx_mng_0        ← DFX Manager IP
│   ├── dfx_ctrl         ← Xilinx DFX Controller IP
│   └── dfx_streamer_N   ← N BRAM streamer instances
└── dfx_pr_region_R_0    ← One reconfigurable module per region R
    └── dfx_pr_region_R_rm_M_inst_0  ← ML kernel RM variant M
```

`hw/bd_src/dfx_unified/dfx_unified.tcl` builds the static sub-BD.  
`hw/bd_src/dfx_region/dfx_region.tcl` builds one RM BD (test loopback or user kernel).  
`hw/bd_src/dfx4ml/dfx4ml.tcl` stitches both into the top-level BD.

### Build pipeline (Python → Tcl → Vivado)

`HwBuildHelper.run_build()` fills `lib/run_build.tcl.template` with Python parameters, writes `build_prj/run_build.tcl`, then spawns Vivado in GUI mode to source it.  
The template calls `build {}` in `hw/build_script/build.tcl`, which:
1. Sources the board-specific script (`kv260/board_build.tcl`)
2. Calls `import_dep` → composes custom IPs into `build_prj/ip_repo/` via `hw/ip_src/compose_ip.tcl`
3. Creates the block designs and wraps them
4. Sets up DFX parent/child implementation runs (one child run per `(region, rm)` pair)
5. Runs synthesis + implementation + write_bitstream

`package_export_files()` copies `.bin` / `.hwh` / `dfx_ctrl_con.txt` to `export/hw/` and patches the `.hwh` so PYNQ recognises `dfx_unified_0` as a `PERIPHERAL`.

### Software / PYNQ driver stack

`sw/driver/dfx_unified.py` — PYNQ `DefaultIP` subclass; bound to `user.org:user:dfx_unified:1.0`. Instantiated automatically by `pynq.Overlay`. Composes all sub-drivers at a fixed AXI address map:

| Offset | Sub-driver |
|---|---|
| `0x0_0000` | `DFX_Ctrl` — partial bitstream management |
| `0x1_0000` | PR decouple (via `DFX_Man`) |
| `0x2_0000` | PR reset (via `DFX_Man`) |
| `0x3_0000` | `DFX_Dma` — DMA debug |
| `0x4_0000` | `DFX_Mng` — main orchestrator registers |
| `0x5_0000 + r*0x1_0000` | `Pr_Ctrl[r]` — HLS ap_ctrl for region `r` |

**`SwBuildHelper._configure_unified_driver()`** stamps build-time constants (`NUM_PR_REGION_VAL`, `SLOT_INDEX_WIDTH_VAL`, `NUM_STREAMER_VAL`) into the exported copy of `dfx_unified.py` — the source file in `sw/driver/` contains these as literal placeholder strings.

### DFX Manager register model (`sw/driver/dfx_mng.py`)

Registers are addressed via a three-field bit layout: `bank_id | row_idx | col_idx`. Bank 0 holds global control/status. Bank 1 is the slot table — a linked list of sessions each describing: DMA src/dst address+size, profiling counters, which RP region and RM variant to load (`vs_rm_recon_sel`, `vs_rm_exec_sel` as one-hot), and streamer load/store/complete masks.

Main state machine states: `SHUTDOWN → PROCESS → PRE_SHUTDOWN`.

---

## Naming Conventions

- Python classes and Verilog module names: `Pascal_Snake_Case` (e.g., `Hw_Build_Helper`, `Dfx_Streamer`)
- Python variables and methods: `snake_case`
- Some legacy modules predate this convention; a refactoring pass is planned

---

## Adding Board Support

Three files are needed per board:
1. `hw/build_script/<board>/board_build.tcl` — PS block, interconnect, board IPs; must define `build_<board>_prj` and `create_<board>_dfx4ml_design` procs
2. `hw/build_script/<board>/constraint.xdc` — pblock boundaries for each RP region
3. Register the new `board` name in `hw/build_script/build.tcl`

Use `hw/build_script/kv260/` as the reference.

## Integrating a Custom ML Kernel

Set `test_mode=0` and provide:
- `user_repo_path`: Vivado-exported IP folder (must contain `src/` and `xgui/`)
- `user_rm_build_tcl_path`: TCL file defining `create_dfx_region_bd` — the procedure that instantiates your kernel inside the RP block design; AXI-Stream `tkeep` and `tlast` are mandatory
- `ip_map_list`: IP core name strings per kernel slot

Use `hw/bd_src/dfx_region/dfx_region.tcl` as the reference RM implementation.

---

## Key Files Quick Reference

| File | Purpose |
|---|---|
| `lib/hw_build.py` | `HwBuildHelper` — Python build entry point, TCL template renderer |
| `lib/sw_build.py` | `SwBuildHelper` — packages drivers + test notebook |
| `lib/run_build.tcl.template` | Template for the generated Vivado build script |
| `hw/build_script/build.tcl` | Main Vivado build orchestrator (board dispatch + DFX run setup) |
| `hw/ip_src/dfx_mng/dfx_mng_core.v` | DFX Manager RTL core (state machines, register banks) |
| `hw/ip_src/compose_ip.tcl` | Composes all custom IPs into `ip_repo/` |
| `sw/driver/dfx_unified.py` | PYNQ top-level driver (contains `NUM_PR_REGION_VAL` placeholders — do not hardcode values here) |
| `sw/driver/dfx_mng.py` | DFX Manager Python driver |
| `sw/driver/dfx_ctrl.py` | DFX Controller Python driver |
| `doc/tech_report/main.tex` | Full technical report: register maps, state machines, driver internals |
