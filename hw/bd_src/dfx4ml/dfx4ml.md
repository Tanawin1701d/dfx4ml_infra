# dfx4ml.tcl — Structure Summary

Top-level orchestration script that creates all sub-block designs (per-region RM BDs and the unified BD) and assembles them into the `dfx4ml` top-level block design.
Contains 2 top-level procs.

---

## Proc: `create_sub_block_design`

Drives creation of all child block designs: one `dfx_pr_region` BD per (region, RM) pair, then the single `dfx_unified` BD.

### Signature

```tcl
create_sub_block_design  parentCell  clk_frq  rm_index_width \
                         num_dfx_streamer  num_dfx_region \
                         dfx_streamers_list  dfx_regions_list  rm_schemetics_list \
                         test_mode
```

| Parameter | Description |
|-----------|-------------|
| `parentCell` | Parent BD cell path (pass `""` to use root) |
| `clk_frq` | System clock frequency (Hz) forwarded to child BD procs |
| `rm_index_width` | Bit width of the RM index bus, forwarded to `create_dfx_unified_bd` |
| `num_dfx_streamer` | Total number of DFX streamers |
| `num_dfx_region` | Number of independent DFX reconfigurable regions |
| `dfx_streamers_list` | List of dicts — one entry per streamer (see `dfx_unified.md`) |
| `dfx_regions_list` | List of dicts — one entry per DFX region (see `dfx_unified.md`) |
| `rm_schemetics_list` | 2-D nested list `[region_idx][rm_idx]` (see `dfx_unified.md`) |
| `test_mode` | `1` = use `create_dfx_region_bd` (test fixtures); `0` = use `create_dfx_region_user_bd` (user kernels) |

### Build Stages

| Stage | Description |
|-------|-------------|
| 1 | **Argument Parsing** — derive `interface_widths` list (load bytes → bits) from `dfx_streamers_list` |
| 2 | **Per-Region RM BD Creation** — for each `(region, rm)` pair build `input_maps`/`output_maps` from `load_streamers`/`store_streamers`, then call `create_dfx_region_bd` or `create_dfx_region_user_bd` based on `test_mode` |
| 3 | **Unified BD Creation** — call `create_dfx_unified_bd` with the full parameter set to build the shared control/DMA fabric |

### Key Architecture Notes

- `input_maps` / `output_maps` are fixed-length lists (`num_dfx_streamer` elements) initialized to `-1`; only indices listed in `load_streamers` / `store_streamers` are set to the streamer index, so unconnected ports stay as `-1` for the RM BD proc to skip.
- The `test_mode` flag selects between a test-fixture RM (`create_dfx_region_bd`) and a user-kernel RM (`create_dfx_region_user_bd`); both receive identical arguments.

---

## Proc: `create_dfx4ml_design`

Main entry point. Builds all sub-BDs, then assembles the `dfx4ml` top-level BD with container cells and all inter-container connections.

### Signature

```tcl
create_dfx4ml_design  parentCell  clk_frq  rm_index_width \
                      num_dfx_streamer  num_dfx_region \
                      dfx_streamers_list  dfx_regions_list  rm_schemetics_list \
                      test_mode  create_new_block
```

| Parameter | Description |
|-----------|-------------|
| `parentCell` | Parent BD cell path (pass `""` to use root) |
| `clk_frq` | System clock frequency (Hz) |
| `rm_index_width` | Bit width of the RM index bus |
| `num_dfx_streamer` | Total number of DFX streamers |
| `num_dfx_region` | Number of independent DFX reconfigurable regions |
| `dfx_streamers_list` | List of dicts — one entry per streamer (see `dfx_unified.md`) |
| `dfx_regions_list` | List of dicts — one entry per DFX region (see `dfx_unified.md`) |
| `rm_schemetics_list` | 2-D nested list `[region_idx][rm_idx]` (see `dfx_unified.md`) |
| `test_mode` | Forwarded to `create_sub_block_design` — selects test vs. user RM BD |
| `create_new_block` | `1` = `create_bd_design "dfx4ml"`; `0` = `open_bd_design "dfx4ml"` |

### Build Stages

| Stage | Description |
|-------|-------------|
| 1 | **Sub-Block Dispatch** — call `create_sub_block_design` to create all child BDs before opening the top-level |
| 2 | **Top-Level BD Init** — create or open the `dfx4ml` BD; instantiate `dfx_unified_0` as a non-DFX container referencing `dfx_unified.bd` |
| 3 | **PR Region Containers and Connections** — for each region: create `dfx_pr_region_${r}_0` container (DFX-enabled, listing all RM BDs), then wire load/store AXI-Stream interfaces, the AXI-Lite PR ctrl port, and the per-region `dfx_nreset` net |
| 4 | **Finalize** — `save_bd_design` + `close_bd_design dfx4ml` |

### Key Architecture Notes

- `dfx_unified_0` has `ENABLE_DFX {0}` — it is a static container; only the `dfx_pr_region_${r}_0` containers have `ENABLE_DFX {true}`.
- Each PR container's `LIST_SYNTH_BD` / `LIST_SIM_BD` is a colon-separated string of all RM BDs for that region; `ACTIVE_SYNTH_BD` defaults to `rm_0`.
- AXI-Stream connections follow the naming convention `dfx_unified_0/M_AXIS_DS${s_idx}` → `dfx_pr_region_${r}_0/S_DS_${s_idx}` for load, reversed for store.
- Input validation is fully delegated to `create_dfx_unified_bd` and the region BD procs — this proc performs no checks itself.
