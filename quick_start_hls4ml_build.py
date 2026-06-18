# ── quick_start_hls4ml_build.py ──────────────────────────────────────────────
# Use the ML model (quick_start_hls4ml_model.py) to build dfx4ml hardware:
# declares the topology configs, runs convert/csim/diag/streamer-glue/synth, and
# drives the Vivado hardware + PYNQ software build.
import os, sys, json, shutil
from pathlib import Path

REPO = Path.cwd()
sys.path.insert(0, str(REPO / 'lib'))            # lib/hls4ml_build + lib/hls4ml_con + lib/dfx_streamer_cal
sys.path.insert(0, str(REPO / 'hls4ml'))         # hls4ml submodule source
os.environ['HLS4ML_BACKEND_PLUGINS'] = 'hls4ml_con'   # discovered at `import hls4ml`
os.environ.setdefault('TF_CPP_MIN_LOG_LEVEL', '3')

import numpy as np

import hls4ml
from hls4ml_build import Hls4ml_build, Partition, Stream, DMA   # orchestrator + typed topology helpers
from lib.hw_build import HwBuildHelper
from lib.sw_build import SwBuildHelper

# the trained model, partition sub-models, locked inputs + probe list
from quick_start_hls4ml_model import (
    full_model, halfA, halfB, part1, part2, part3, part4,
    X_full, PROBE_LAYERS, OUT_ROOT, LOCK_DIR,
)

assert 'vitisunifieddfx4ml' in hls4ml.backends.get_available_backends(), \
    'VitisUnifiedDFx4ml backend not registered — check HLS4ML_BACKEND_PLUGINS / sys.path'
print('OK: VitisUnifiedDFx4ml registered')

# Vitis / Vivado 2023.2 install dirs (each holds settings64.sh); Hls4ml_build.setup_env()
# sources them onto PATH at construction.
VITIS_PATH  = '/tools/Xilinx/Vitis/2023.2'
VIVADO_PATH = '/tools/Xilinx/Vivado/2023.2'

# ── declare the configs + select the run mode ───────────────────────────────
# MODE selects which hardware config is built:
#   'config_2'   — 2 partitions (halfA/halfB) in a single PR region, swapped at runtime
#   'config_4'   — 4 partitions across 2 PR regions (2 RMs each)
#   'config_all' — run convert/csim/diag for BOTH config_2 and config_4 (comparison only;
#                  no hardware build, since one bitstream can hold only one topology)
MODE = 'config_all'

CONFIGS = {
 # single PR region: halfA (rm 0) and halfB (rm 1) are swapped at runtime in the
 # same region; all streams live in region 0 (streamers persist across the swap).
 'config_2': [
   Partition('halfA', 'p_halfA', halfA, region=0, rm=0, inputs=[DMA], outputs=[
       Stream('bneck', region=0, alloc_phase=0, free_phase=1),
       Stream('skip2', region=0, alloc_phase=0, free_phase=1),
       Stream('skip1', region=0, alloc_phase=0, free_phase=1)]),
   Partition('halfB', 'p_halfB', halfB, region=0, rm=1,
             inputs=['bneck', 'skip2', 'skip1'], outputs=[DMA]),
 ],
 'config_4': [
   Partition('part1', 'p_part1', part1, region=0, inputs=[DMA], outputs=[
       Stream('a1',    region=0, alloc_phase=0, free_phase=1),
       Stream('skip1', region=1, alloc_phase=0, free_phase=2)]),
   Partition('part2', 'p_part2', part2, region=1, inputs=['a1'], outputs=[
       Stream('bneck', region=1, alloc_phase=1, free_phase=2),
       Stream('skip2', region=1, alloc_phase=1, free_phase=2)]),
   Partition('part3', 'p_part3', part3, region=0, rm=1, inputs=['bneck', 'skip2'], outputs=[
       Stream('p3',    region=0, alloc_phase=2, free_phase=3)]),
   Partition('part4', 'p_part4', part4, region=1, rm=1, inputs=['p3', 'skip1'], outputs=[DMA]),
 ],
}
print('MODE =', MODE)

# ── run-stage toggles ───────────────────────────────────────────────────────
RUN_CSIM    = True      # end-to-end csim across the partitions of each config
RUN_DIAG    = True      # per-layer HLS csim bisect on the full model (signal-collapse diag)
RUN_SYNTH   = False     # C-synthesis + ip_catalog package (needs Vitis)
RUN_FIFO    = True     # FIFO-depth optimization (needs Vitis cosim — heavy)
RUN_HWBUILD = True      # dfx4ml Vivado hardware build (config_2 / config_4 only)

# shared Hls4ml_build construction config (everything except `partitions`)
HB_KW = dict(
    out_root       = OUT_ROOT,
    board          = 'kv260',
    part           = 'xck26-sfvc784-2LV-c',
    clock_period   = '10ns',
    precision      = 'ap_fixed<16,6>',
    reuse_factor   = 8,
    strategy       = 'Resource',
    total_banks    = 64,
    rm_index_width = 3,
    vitis_path     = VITIS_PATH,
    vivado_path    = VIVADO_PATH,
)


# ── the per-config pipeline ──────────────────────────────────────────────────
def run_config(label, parts, *, do_hwbuild, do_diag):
    """Convert (→ csim → diag → streamer-glue → synth) one config; optionally hw-build."""
    print('\n' + '#' * 70)
    print(f'# {label}: {[p.name for p in parts]}')
    print('#' * 70)

    hb = Hls4ml_build(partitions=parts, **HB_KW)
    print('inferred: amt_phase =', hb.amt_phase, '| num_regions =', hb.num_regions)

    hb.convert_all()

    if RUN_CSIM:
        final, bus = hb.csim_chain(x0=X_full, peek=10)
        print('end-to-end output shape:', None if final is None else np.asarray(final).shape)

    if do_diag:
        # diag probes the full model layer-by-layer (split-independent), so it is run
        # once per invocation regardless of how the model is partitioned.
        hb.diag_bisect(full_model, PROBE_LAYERS, X_full)

    hb.compute_streamer_glue()
    hb.print_streamer_report()

    if RUN_SYNTH:
        hb.synth_all()
    if RUN_FIFO:
        hb.synth_all(fifo_opt=True)

    if do_hwbuild and RUN_HWBUILD:
        hw = HwBuildHelper(
            build_folder_path  = './build_prj',
            dfx_root_path      = '.',
            export_folder_path = './export',
            req_gen_ip         = 1,
            num_core           = 4,
            clk_frq            = 99999001,
            test_mode          = 0,          # user kernels
            hls4ml_build       = hb,         # board/user_repo/tcl/dfx/rm_width/vivado from hb
        )
        hw.run_build()
        hw.package_export_files()
        SwBuildHelper(hw_builder=hw).package_export_file()
        print('hardware + software build complete -> ./export')

    return hb


# ── dispatch on MODE ─────────────────────────────────────────────────────────
if MODE in ('config_2', 'config_4'):
    run_config(MODE, CONFIGS[MODE], do_hwbuild=True, do_diag=RUN_DIAG)
elif MODE == 'config_all':
    # convert/csim/diag comparison across both topologies; no hardware build (a single
    # bitstream holds one topology). diag is split-independent so it runs only once.
    for _i, _name in enumerate(('config_2', 'config_4')):
        run_config(_name, CONFIGS[_name], do_hwbuild=False, do_diag=(RUN_DIAG and _i == 0))
else:
    raise ValueError(f"unknown MODE {MODE!r} — expected one of config_2 / config_4 / config_all")

print('\nDone. lock dir:', LOCK_DIR)
