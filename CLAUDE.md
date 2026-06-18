# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

**DFX4ML-ARCH** is an FPGA architecture for self-reconfiguring ML inference. The FPGA autonomously swaps its own ML accelerator kernels at runtime via Dynamic Function eXchange (DFX/partial reconfiguration), enabling models too large to fit the device to run segment-by-segment without CPU intervention.

**Target platform:** Zynq UltraScale+ KV260 · Vivado 2023.2 · Ubuntu 22.04 + PYNQ

---

## Build Commands

### Full hardware + software build
Open `quick_start.ipynb` and run all cells. This is the primary entry point.

For the **Keras → hls4ml → dfx4ml** flow (auto-generate user kernels + streamer params
from a partitioned Keras model), use `quick_start_hls4ml.ipynb` instead — see
[hls4ml → dfx4ml Backend](#hls4ml--dfx4ml-backend-libhls4ml_con).

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
    # Each entry is one streamer; load/store_width = AXI-S bus width (bytes), actual_width = data width (bits)
    dfx_regions             = [{"load_streamers": [0], "store_streamers": [0]}],
    # One dict per RP region; index lists refer into dfx_streamers for input/output routing
    rm_schemetics           = [[{"load_io_map": [...], "store_io_map": [...]}, ...]],
    # [region_idx][rm_idx] — I/O port mapping for each RM variant inside a region
    test_mode               = 1,
    vivado_path             = "<abs path to vivado>",
    export_folder_path      = "./export"
)
hw_builder.run_build()
hw_builder.package_export_files()

sw_builder = SwBuildHelper(hw_builder=hw_builder)
# All parameters are derived from hw_builder; explicit values override, and the
# fully manual form still works:
# SwBuildHelper(export_folder_path="./export", num_pr_region=1, rm_index_width=2, num_streamer=1)
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
└── dfx_pr_region_R_0    ← One reconfigurable module per region R (R = 0 … N-1)
    └── dfx_pr_region_R_rm_M_inst_0  ← ML kernel RM variant M (M = 0 … num_rm-1)
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

Sub-driver modules (all in `sw/driver/`):

| Module | Role |
|---|---|
| `dfx_man.py` | PR decouple/reset sub-driver (offsets `0x1_0000`, `0x2_0000`) |
| `dfx_dma.py` | DMA debug sub-driver (offset `0x3_0000`) |
| `pr_ctrl.py` | HLS `ap_ctrl_hs` sub-driver for each RP region |
| `mem_alloc.py` | CMA allocation helpers, Linux overcommit mode control, and cache flush before DMA |

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
2. `hw/build_script/<board>/constraint_<N>_region.xdc` — pblock boundaries, one file per supported region count `N` (kv260 ships `constraint_1_region.xdc` and `constraint_2_region.xdc`; the build selects the file matching `num_dfx_region`)
3. Register the new `board` name in `hw/build_script/build.tcl`

Use `hw/build_script/kv260/` as the reference.

## Integrating a Custom ML Kernel

Set `test_mode=0` and provide:
- `user_repo_path`: Vivado-exported IP folder (must contain `src/` and `xgui/`)
- `user_rm_build_tcl_path`: TCL file defining `create_dfx_region_bd` — the procedure that instantiates your kernel inside the RP block design; AXI-Stream `tkeep` and `tlast` are mandatory
- `ip_map_list`: IP core name strings per kernel slot

Use `hw/bd_src/dfx_region/dfx_region.tcl` as the reference RM implementation.

---

## hls4ml → dfx4ml Backend (`lib/hls4ml_con`)

A hls4ml backend plugin that turns a partitioned Keras model into dfx4ml user
kernels + the three `HwBuildHelper` params. Entry notebook: `quick_start_hls4ml.ipynb`.
The `hls4ml` source is a **git submodule** (`hls4ml/`); do not edit it for dfx-specific
behavior — patch the generated project instead (see the writer pattern below).

Registered via `os.environ['HLS4ML_BACKEND_PLUGINS'] = 'hls4ml_con'` (discovered at
`import hls4ml`); backend name `'VitisUnifiedDFx4ml'` (key `'vitisunifieddfx4ml'`).

| File | Role |
|---|---|
| `backend.py` | Registers the `VitisUnifiedDFx4ml` backend (extends hls4ml `VitisUnified`) |
| `writer.py` | `VitisUnifiedDFx4mlWriter` — multi-port flat AXI-Stream kernels (one AXIS port/streamer, TKEEP+TLAST), csim/cosim, ip_catalog packaging, post-write patches |
| `streamer_glue.py` | `build_dispatcher_tcl()` stitches the user-BD TCL; `stream_geometry_from_hls()`. (`compute_dfx_params` moved to `lib/hls4ml_build.py`.) |
| `tcl_gen.py` | Renders `create_dfx_region_user_bd` from `dfx_region_user_bd.tcl.template`; one VLNV fragment per (region, rm) |
| `dfx_region_user_bd.tcl.template` | TCL proc body (markers `__VLNV_TABLE__`/`__KERNEL__`/`__CTRL_BUSIF__`/`__*_PIN__`) |
| `templates/vitis_unified/` | dfx-modified kernel templates (`myproject_axi_stream.{cpp,h}`, `nnet_helpers_dfx.h`) |

**Topology model** — the caller describes the cut as a list of `Partition` objects
(see the typed helpers below), one per (region, rm). `compute_dfx_params(partitions, …)`
(in `lib/hls4ml_build/dfx_params.py`) gathers each producer's `partition.streams`,
assigns streamers (index 0 = DMA always), unions per-region load/store streamers, and
builds per-(region,rm) `(streamer_idx, kernel_port)` maps (`kernel_port == -1` ⇒ that RM
leaves the port idle → a Stream_*_Dummy is wired in). All regions must declare the same
RM count. Bus widths must be powers of two.

**Wiring into the build** — `HwBuildHelper` accepts `dfx=compute_dfx_params(...)` and
unpacks `dfx_streamers`/`dfx_regions`/`rm_schemetics` from it (explicitly-passed values
still win); pass `user_rm_build_tcl_path=` the file from `build_dispatcher_tcl()`.

### `Hls4ml_build` orchestrator (`lib/hls4ml_build/`)

`Hls4ml_build` wraps the whole Keras → hls4ml → dfx4ml flow as a class (what
`quick_start_hls4ml.ipynb` does cell-by-cell). It is a small package: `builder.py`
(core: ctor/validation/tool-paths) composes the per-stage mixins `_convert.py` /
`_csim.py` / `_synth.py` / `_glue.py` / `_diag.py`; `dfx_params.py` holds
`compute_dfx_params`; `topology.py` holds the typed topology helpers; `__init__.py`
re-exports `Hls4ml_build`, `Partition`, `Stream`, `DMA`, `compute_dfx_params`. Construct it
with `partitions`, `out_root`, conversion config, and the `vitis_path` / `vivado_path`
install dirs (it sources their `settings64.sh` onto `PATH` via `setup_env()`). Methods:
`convert_all(fifo_opt=)` (get the partial model), `csim_partition` / `csim_chain`
(end-to-end csim), `synth_all(fifo_opt=)` (C-synthesis + ip_catalog package, with/without
FIFO-depth optimization), `compute_streamer_glue()` (sets `self.dfx` + `self.user_rm_tcl`),
`diag_bisect(keras_model, probe_layers, x_input)` (per-layer HLS csim bisect — converts a
one-layer-deep probe model for each layer and reports where the fixed-point signal
collapses / goes uniform, reusing the instance's conversion config). It also hosts the
relocated `compute_dfx_params` (in `dfx_params.py`).

**Topology — typed helpers (`topology.py`)** — `Partition` / `Stream` are the **single**
topology representation (no parallel dict schema; the whole pipeline — including
`dfx_streamer_report` — consumes `Stream` objects by attribute). Describe the cut with
`Partition(name, project, model, region, rm=, inputs=[…], outputs=[…])`, where an input is
a stream name (or `DMA`) and an output is `DMA` or
`Stream(name, region, alloc_phase, free_phase, precision=16)`. A `Stream` declares only
its bank-lifetime fields; `shape` is **derived** (filled in by the producing `Partition`
from `model.outputs`) and the geometry fields (`amt_banks_per_entry`, …) are filled in by
`dfx_streamer_report` — never hand-written. `compute_dfx_params` shallow-copies each
`Stream` before allocation so the declared topology stays pristine. After construction a
`Partition` exposes `.streams` (the produced `Stream` objects, with `shape` set),
`.output_names`, and resolved `.input_flat`/`.output_flat`; `amt_phase`/`num_regions` are
**inferred** by `Hls4ml_build` (override any explicitly).

**Handoff** — `HwBuildHelper(hls4ml_build=hb, …)` and `SwBuildHelper(hls4ml_build=hb,
export_folder_path=…)` pull their config from the instance (board, `user_repo_path`,
`user_rm_build_tcl_path`, `dfx`, `rm_index_width`, Vivado path / region+streamer counts);
explicitly-passed values still win. Run `hb.compute_streamer_glue()` first.

**Writer post-write patches** (applied to the generated firmware in
`<out>/firmware/nnet_utils/`, after `super().write_hls()`, so the submodule stays pristine):
- `_patch_nnet_helpers_keeplast` — float AXIS packet → `hls::axis<float,0,0,0,24>` (TKEEP|TLAST)
- `_patch_nnet_dense_resource_lutram` — weight ROM `ROM_nP_BRAM` → `ROM_1P_LUTRAM` for
  reuse_factor > 1 (all 3 dense_resource specializations); guarded for existence and
  idempotency (the commented-out line still contains the search string, so re-running
  without the `ROM_1P_LUTRAM` guard would mangle it — matters on the FIFO re-convert path).

---

## Examples

| Directory | Description |
|---|---|
| `example/multi_region_test2/` | 2 PR regions · 2 RMs each · 2 streamers (basic multi-region pipeline) |
| `example/multi_region_test3/` | 2 PR regions · 2 RMs each · 3 streamers (DMA + 2 independent streamers) |
| `example/multi_region_explore/` | Exploratory multi-region tests |
| `example/exp_dyn_size/` | Dynamic payload-size experiments |
| `example/query_explore/` | Query/inference exploration notebooks |

---

## Key Files Quick Reference

| File | Purpose |
|---|---|
| `lib/hw_build.py` | `HwBuildHelper` — Python build entry point, TCL template renderer; accepts `dfx=` to splat streamer params, or `hls4ml_build=` to pull config from an `Hls4ml_build` |
| `lib/sw_build.py` | `SwBuildHelper` — packages drivers + test notebook; accepts `hw_builder=` or `hls4ml_build=` |
| `lib/hls4ml_build/` | `Hls4ml_build` — orchestrates convert/csim/synth/streamer-glue for a partitioned model (per-stage mixins + `dfx_params.py`'s `compute_dfx_params`); hands off to `HwBuildHelper`/`SwBuildHelper` |
| `lib/run_build.tcl.template` | Template for the generated Vivado build script |
| `lib/hls4ml_con/` | hls4ml → dfx4ml backend plugin (see [section](#hls4ml--dfx4ml-backend-libhls4ml_con)) |
| `quick_start_hls4ml.ipynb` | Keras → hls4ml → dfx4ml entry notebook — driven by the `Hls4ml_build` orchestrator (typed `Partition`/`Stream` topology, `convert_all`/`csim_chain`/`synth_all`/`compute_streamer_glue`, `hls4ml_build=` handoff) |
| `hw/build_script/build.tcl` | Main Vivado build orchestrator (board dispatch + DFX run setup) |
| `hw/ip_src/dfx_mng/dfx_mng_core.v` | DFX Manager RTL core (state machines, register banks) |
| `hw/ip_src/compose_ip.tcl` | Composes all custom IPs into `ip_repo/` |
| `sw/driver/dfx_unified.py` | PYNQ top-level driver (contains `NUM_PR_REGION_VAL` placeholders — do not hardcode values here) |
| `sw/driver/dfx_mng.py` | DFX Manager Python driver |
| `sw/driver/dfx_ctrl.py` | DFX Controller Python driver |
| `sw/driver/mem_alloc.py` | CMA allocation, overcommit mode, cache flush before DMA |
| `doc/tech_report/main.tex` | Full technical report: register maps, state machines, driver internals |
