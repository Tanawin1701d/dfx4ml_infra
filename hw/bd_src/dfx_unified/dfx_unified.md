# dfx_unified.tcl — Structure Summary

Vivado BD script that assembles the full DFX unified block design.
Contains two top-level procs.

---

## Proc: `create_hier_cell_dma_hier`

Creates the DMA hierarchical cell (`dma_hier`) containing the AXI DMA engine and its decouplers.

| Stage | Description |
|-------|-------------|
| 1 | **Interface Pins** — AXI-Lite slave, AXI-MM master (DMA in/out), AXI-Stream slave/master (DS0) |
| 2 | **Scalar Pins** — `clk`, `nreset`, `s2mm_introut`, `decouple` |
| 3 | **IP Instances** — `axi_dma_0`, `dfx_decoupler_0` (master/AXIS), `dfx_decoupler_1` (slave/AXIS) |
| 4 | **Interface Connections** — wire DMA ↔ decouplers ↔ hier boundary pins |
| 5 | **Net Connections** — clock, reset, decouple, interrupt fanout |

---

## Proc: `create_dfx_unified_bd`

Main entry point. Builds the complete `dfx_unified` block design for N streamers and M DFX regions.

### Signature

```tcl
create_dfx_unified_bd  parentCell  clk_frq  rm_index_width \
                       num_dfx_streamer  num_dfx_region \
                       dfx_streamers_list  dfx_regions_list  rm_schemetics_list
```

| Parameter | Description |
|-----------|-------------|
| `clk_frq` | System clock frequency (Hz) |
| `rm_index_width` | Bit width of the RM index bus |
| `num_dfx_streamer` | Total number of DFX streamers (DS0 is fixed DMA, DS1+ are Dfx_Streamer IPs) |
| `num_dfx_region` | Number of independent DFX reconfigurable regions |
| `dfx_streamers_list` | List of dicts: one entry per streamer — see structure below |
| `dfx_regions_list` | List of dicts: one entry per DFX region — see structure below |
| `rm_schemetics_list` | 2-D nested list `[region_idx][rm_idx]` — see structure below |

---

### Data Structures

#### `dfx_streamers_list`

A list of dicts, one entry per streamer. **Index 0 is always the DMA streamer** (DS0 / `dma_hier`); index 1+ map to `Dfx_Streamer_i` IPs.

| Key | Type | Unit | Description |
|-----|------|------|-------------|
| `load_width` | int | bytes | Physical AXI-Stream bus width used for loading data into the RM |
| `store_width` | int | bytes | Physical AXI-Stream bus width used for storing data out of the RM |
| `actual_width` | int | bits | Actual data precision the RM operates on (`≤ load_width × 8`) |
| `amount_row` | int | rows | Number of rows (depth) in the streamer's internal buffer |

**Constraints**
- `load_width × 8` must be a power of two
- `actual_width ≤ load_width × 8`
- `amount_row > 0`

**Tcl pattern**
```tcl
set dfx_streamers_list [list \
    {load_width <bytes> store_width <bytes> actual_width <bits> amount_row <rows>} \
    ...
]
```

**Tcl example** — 2 streamers, both 32-bit wide, 1024-row buffer
```tcl
set dfx_streamers_list [list \
    {load_width 4 store_width 4 actual_width 32 amount_row 1024} \
    {load_width 4 store_width 4 actual_width 32 amount_row 1024} \
]
```

**Python example**
```python
dfx_streamers = [
    {"load_width": 4, "store_width": 4, "actual_width": 32, "amount_row": 1024},  # index 0: DMA
    {"load_width": 4, "store_width": 4, "actual_width": 32, "amount_row": 1024},  # index 1: Dfx_Streamer_1
]
```

---

#### `dfx_regions_list`

A list of dicts, one entry per DFX reconfigurable region.

| Key | Type | Description |
|-----|------|-------------|
| `load_streamers` | list of int | Global streamer indices whose `decup` pin is driven by this region's decouple signal (for loading data into RM) |
| `store_streamers` | list of int | Global streamer indices associated with this region for storing data out of RM |

> Index 0 in a streamer list refers to DS0 (DMA). Only `load_streamers` with index `> 0` are wired to `Dfx_Streamer_i/decup` in the BD; DS0 decoupling is handled separately via `dma_hier/decouple` when region 0.

**Tcl pattern**
```tcl
set dfx_regions_list [list \
    {load_streamers {<idx> ...} store_streamers {<idx> ...}} \
    ...
]
```

**Tcl example** — 1 region using streamer 1 for both load and store
```tcl
set dfx_regions_list [list \
    {load_streamers {1} store_streamers {1}} \
]
```

**Tcl example** — 2 regions, region 0 uses streamer 1, region 1 uses streamer 2
```tcl
set dfx_regions_list [list \
    {load_streamers {1} store_streamers {1}} \
    {load_streamers {2} store_streamers {2}} \
]
```

**Python example**
```python
dfx_regions = [
    {"load_streamers": [1], "store_streamers": [1]},  # region 0
    {"load_streamers": [2], "store_streamers": [2]},  # region 1
]
```

---

#### `rm_schemetics_list`

A 2-D nested list indexed as `[region_idx][rm_idx]`. Each element is a dict describing one Reconfigurable Module (RM).

| Key | Type | Description |
|-----|------|-------------|
| `load_io_map` | list of `{io_idx kernel_idx}` pairs | Maps each streamer IO port index to a kernel port index for loading |
| `store_io_map` | list of `{io_idx kernel_idx}` pairs | Maps each streamer IO port index to a kernel port index for storing |

> In Tcl, pairs are written as `{io_idx kernel_idx}` (two-element list). In Python they are `(io_index, kernel_idx)` tuples.

**Tcl pattern**
```tcl
# One RM:
set rm_x_maps {load_io_map {{<io_idx> <kernel_idx>} ...} store_io_map {{<io_idx> <kernel_idx>} ...}}

# Assemble into regions:
set rm_schemetics_list [list \
    [list $rm_region0_rm0 $rm_region0_rm1 ...] \
    [list $rm_region1_rm0 ...]                 \
    ...
]
```

**Tcl example** — 1 region, 2 RMs, each mapping streamer 1 IO 0 → kernel port 0
```tcl
set rm_0_maps {load_io_map {{1 0}} store_io_map {{1 0}}}
set rm_1_maps {load_io_map {{1 0}} store_io_map {{1 0}}}
set rm_schemetics_list [list [list $rm_0_maps $rm_1_maps]]
```

**Tcl example** — 2 regions, 2 RMs each
```tcl
set r0_rm0 {load_io_map {{1 0}} store_io_map {{1 0}}}
set r0_rm1 {load_io_map {{1 0}} store_io_map {{1 0}}}
set r1_rm0 {load_io_map {{2 0}} store_io_map {{2 0}}}
set r1_rm1 {load_io_map {{2 0}} store_io_map {{2 0}}}
set rm_schemetics_list [list \
    [list $r0_rm0 $r0_rm1] \
    [list $r1_rm0 $r1_rm1] \
]
```

**Python example**
```python
rm_schemetics = [
    # region 0: 2 RMs
    [
        {"load_io_map": [(1, 0)], "store_io_map": [(1, 0)]},  # RM 0
        {"load_io_map": [(1, 0)], "store_io_map": [(1, 0)]},  # RM 1
    ],
    # region 1: 2 RMs
    [
        {"load_io_map": [(2, 0)], "store_io_map": [(2, 0)]},  # RM 0
        {"load_io_map": [(2, 0)], "store_io_map": [(2, 0)]},  # RM 1
    ],
]
```

---

### Build Stages

| Stage | Description |
|-------|-------------|
| 1 | **Argument Parsing** — derive `interface_widths`, `applied_interface_widths`, `amt_rows`; count `total_rm` and `num_rm_per_region` |
| 2 | **Validation** — check `rm_index_width`, `num_dfx_streamer`, `num_dfx_region` non-zero; verify each streamer's width is power-of-two and `actual ≤ interface` |
| 3 | **Interface Ports** — AXI-MM (`M_AXI_DMA_IN/OUT`, `M_AXI_BS`), AXI-Stream (`S/M_AXIS_DS0..N`), AXI-Lite (`S_AXI_CTRL`, per-region `M_AXI_LITE_PR_CTRL_r`) |
| 4 | **Scalar Ports** — `clk`, `nreset`, `dfx_intr`, per-region `dfx_nreset_r`, debug ports |
| 5 | **IP Instances** — `DFX_Mng`, `Dfx_Streamer_1..N`, `fin_store_concat_0`, `DFX_Ctrl_0_axi_periph`, `DFX_Ctrl_B`, `icapWrap_0`, `axi_dfx_reset`, `axi_dfx_decup`, `dummy_dfx_mng_hw_plug`, `dfx_b_auto_ack`; per-region: `reset_join_r`, `dfx_decup_ctrl_r`, `dfx_decoupler_pr_ctrl_r`, `dfx_rm_prog_slice_r`, `dfx_nreset_expand_r`, `dfx_rm_nreset_concat`; then `dma_hier` |
| 6 | **Interface Connections** — AXI interconnect master routing (M00–M04 fixed, M05+ per region), ICAP, bitstream memory, streamer AXI-Stream ports |
| 7 | **Net Connections** — streamer control signals (`load/store init/reset`), DFX ctrl→VS hw_triggers (via slicers), decouple fanout per region, clock/reset fanout to all IPs, `dfx_rm_program` fanout to slicers |
| 8 | **Address Segments** — fixed map (via `DFX_Mng/M_AXI` and `S_AXI_CTRL`): `0x00000000` DFX_Mng, `0x00010000` DFX_Ctrl_B, `0x00020000` DMA, `0x00030000` dfx_reset, `0x00040000` dfx_decup, `0x00050000+r×0x10000` per-region PR ctrl |
| 9 | **Finalize** — restore current BD instance, `validate_bd_design`, `save_bd_design`, `close_bd_design` |

---

### Key Architecture Notes

- **DS0** (streamer 0) is always the AXI DMA path (`dma_hier`); DS1+ are `Dfx_Streamer` IP instances.
- **DFX_Ctrl_B** manages one Virtual System (VS) per region; each VS tracks its own RMs independently.
- **dfx_rm_program** is a flat bit-vector spanning all regions; `dfx_rm_prog_slice_r` carves out each region's slice for its VS hw_triggers.
- **dfx_rm_nreset** is reconstructed from per-region `dfx_nreset_expand_r` (replicates 1-bit VS reset to M_r bits) concatenated by `dfx_rm_nreset_concat`.
- **Decouple path**: `axi_dfx_decup` (PS) → `dfx_decup_ctrl_r` → `decup_res` fans out to `dfx_decoupler_pr_ctrl_r`, `dma_hier` (region 0 only), and each region's load streamers.
- **AXI interconnect** has 2 slaves (DFX_Mng internal, PS `S_AXI_CTRL`) and `5 + num_dfx_region` masters.
