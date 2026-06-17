# ── Cell 1: environment + plugin registration ───────────────────────────────
import os, sys, json, shutil
from pathlib import Path

REPO = Path.cwd()
sys.path.insert(0, str(REPO / 'lib'))            # lib/hls4ml_build + lib/hls4ml_con + lib/dfx_streamer_cal
sys.path.insert(0, str(REPO / 'hls4ml'))         # hls4ml submodule source
os.environ['HLS4ML_BACKEND_PLUGINS'] = 'hls4ml_con'   # discovered at `import hls4ml`
os.environ.setdefault('TF_CPP_MIN_LOG_LEVEL', '3')

import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

import hls4ml
from hls4ml_build import Hls4ml_build, Partition, Stream, DMA   # orchestrator + typed topology helpers
from lib.hw_build import HwBuildHelper
from lib.sw_build import SwBuildHelper

assert 'vitisunifieddfx4ml' in hls4ml.backends.get_available_backends(), \
    'VitisUnifiedDFx4ml backend not registered — check HLS4ML_BACKEND_PLUGINS / sys.path'
print('OK: VitisUnifiedDFx4ml registered')

# Vitis / Vivado 2023.2 install dirs (each holds settings64.sh); Hls4ml_build.setup_env()
# sources them onto PATH at construction.
VITIS_PATH  = '/tools/Xilinx/Vitis/2023.2'
VIVADO_PATH = '/tools/Xilinx/Vivado/2023.2'

# ── Cell 2: build the full model and its composable stages ──────────────────
def enc_a(x):                       # inp(8,8,1) -> (p1_main(4,4,16), skip1(8,8,8))
    s1 = layers.Conv2D(8, 3, padding='same', activation='relu', name='enc_conv1')(x)
    x = layers.Conv2D(16, 3, padding='same', activation='relu', name='enc_conv1b')(s1)
    x = layers.Conv2D(16, 3, padding='same', activation='relu', name='enc_conv2')(x)
    p1 = layers.MaxPool2D(2, name='enc_pool1')(x)                  # (4,4,16)
    return p1, s1

def enc_b(p1):                      # p1_main(4,4,16) -> (bneck(2,2,8), skip2(4,4,16))
    s2 = layers.Conv2D(16, 3, padding='same', activation='relu', name='enc_conv3')(p1)
    x = layers.MaxPool2D(2, name='enc_pool2')(s2)                  # (2,2,16)
    bn = layers.Conv2D(8, 3, padding='same', activation='relu', name='bottleneck')(x)
    return bn, s2

def dec_a(bn, s2):                  # (bneck, skip2) -> p3(4,4,16)
    y = layers.UpSampling2D(2, name='dec_up1')(bn)
    y = layers.Conv2D(16, 3, padding='same', activation='relu', name='dec_conv1')(y)
    y = layers.Add(name='skip2_add')([y, s2])
    return layers.Conv2D(16, 3, padding='same', activation='relu', name='dec_conv1b')(y)

def dec_b(p3, s1):                  # (p3(4,4,16), skip1(8,8,8)) -> out(4,)
    y = layers.UpSampling2D(2, name='dec_up2')(p3)
    y = layers.Conv2D(8, 3, padding='same', activation='relu', name='dec_conv2')(y)
    y = layers.Add(name='skip1_add')([y, s1])
    y = layers.GlobalAveragePooling2D(name='gap')(y)
    y = layers.Dense(64, activation='relu', name='dense1')(y)
    return layers.Dense(4, activation=None, name='dense_out')(y)   # (4,)

inp = keras.Input(shape=(8, 8, 1), name='in0')
_p1, _s1 = enc_a(inp); _bn, _s2 = enc_b(_p1); _p3 = dec_a(_bn, _s2); _out = dec_b(_p3, _s1)
full_model = keras.Model(inp, _out, name='full')
print('full model params:', full_model.count_params())

# ── Cell 3: derive the partition sub-models ─────────────────────────────────
# 2-partition: halfA (encoder, 1 in / 3 out) -> halfB (decoder, 3 in / 1 out)
hA_in = keras.Input((8, 8, 1), name='hA_in')
hA_p1, hA_s1 = enc_a(hA_in); hA_bn, hA_s2 = enc_b(hA_p1)
halfA = keras.Model(hA_in, [hA_bn, hA_s2, hA_s1], name='halfA')   # out order: bneck, skip2, skip1

hB_bn = keras.Input((2, 2, 8), name='hB_bneck')
hB_s2 = keras.Input((4, 4, 16), name='hB_skip2')
hB_s1 = keras.Input((8, 8, 8), name='hB_skip1')
halfB = keras.Model([hB_bn, hB_s2, hB_s1], dec_b(dec_a(hB_bn, hB_s2), hB_s1), name='halfB')

# 4-partition: part1 (enc-A) -> part2 (enc-B) -> part3 (dec-A) -> part4 (dec-B)
p1_in = keras.Input((8, 8, 1), name='p1_in'); p1_main, p1_s1 = enc_a(p1_in)
part1 = keras.Model(p1_in, [p1_main, p1_s1], name='part1')
p2_in = keras.Input((4, 4, 16), name='p2_in')
part2 = keras.Model(p2_in, list(enc_b(p2_in)), name='part2')
p3_bn = keras.Input((2, 2, 8), name='p3_bneck'); p3_s2 = keras.Input((4, 4, 16), name='p3_skip2')
part3 = keras.Model([p3_bn, p3_s2], dec_a(p3_bn, p3_s2), name='part3')
p4_p3 = keras.Input((4, 4, 16), name='p4_p3'); p4_s1 = keras.Input((8, 8, 8), name='p4_skip1')
part4 = keras.Model([p4_p3, p4_s1], dec_b(p4_p3, p4_s1), name='part4')
print('partition models:', [m.name for m in (halfA, halfB, part1, part2, part3, part4)])

# ── Cell 4: declare the partitions (typed; shapes auto-derived from the models)
SPLIT = '2part'

CONFIGS = {
 # single PR region: halfA (rm 0) and halfB (rm 1) are swapped at runtime in the
 # same region; all streams live in region 0 (streamers persist across the swap).
 '2part': [
   Partition('halfA', 'p_halfA', halfA, region=0, rm=0, inputs=[DMA], outputs=[
       Stream('bneck', region=0, alloc_phase=0, free_phase=1),
       Stream('skip2', region=0, alloc_phase=0, free_phase=1),
       Stream('skip1', region=0, alloc_phase=0, free_phase=1)]),
   Partition('halfB', 'p_halfB', halfB, region=0, rm=1,
             inputs=['bneck', 'skip2', 'skip1'], outputs=[DMA]),
 ],
 '4part': [
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
PARTS = CONFIGS[SPLIT]
print('SPLIT =', SPLIT, '|', [p.name for p in PARTS])

# ── Cell 5: build the orchestrator and convert all partitions ───────────────
OUT_ROOT = REPO / 'hls4ml_dfx_out'

hb = Hls4ml_build(
    partitions   = PARTS,
    out_root     = OUT_ROOT,
    # amt_phase / num_regions are inferred from the topology (override if needed)
    board        = 'kv260',
    part         = 'xck26-sfvc784-2LV-c',
    clock_period = '10ns',
    precision    = 'ap_fixed<16,6>',
    reuse_factor = 8,
    strategy     = 'Resource',
    total_banks  = 64,
    rm_index_width = 3,
    vitis_path   = VITIS_PATH,
    vivado_path  = VIVADO_PATH,
)
print('inferred: amt_phase =', hb.amt_phase, '| num_regions =', hb.num_regions)
hb.convert_all()

# ── Cell 6: end-to-end csim ─────────────────────────────────────────────────
RUN_CSIM = True
if RUN_CSIM:
    final, bus = hb.csim_chain(n=2, peek=10)
    print('end-to-end output shape:', None if final is None else np.asarray(final).shape)
else:
    print('RUN_CSIM=False — skipping csim')

# ── Cell 7: compute dfx params + stitch the user-BD dispatcher TCL ──────────
hb.compute_streamer_glue()
hb.print_streamer_report()

# ── Cell 8: synthesize + package each partition ─────────────────────────────
# RUN_SYNTH = False
# if RUN_SYNTH:
#     hb.synth_all()
#     print('synthesis done')
# else:
#     print('RUN_SYNTH=False — set True to synthesize (needs Vitis on PATH)')

# ── Cell 9: per-partition fifo-depth optimization ───────────────────────────
RUN_FIFO = True
if RUN_FIFO:
    hb.synth_all(fifo_opt=True)
    print('all partitions converted + fifo-optimized')
else:
    print('RUN_FIFO=False — set True to run FIFO optimization (needs Vitis)')

# ── Cell 10: dfx4ml hardware build ──────────────────────────────────────────
RUN_HWBUILD = True
if RUN_HWBUILD:
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
    print('hardware build complete')
else:
    print('RUN_HWBUILD=False — set True to run the dfx4ml Vivado build')

# ── Cell 11: software / PYNQ export ─────────────────────────────────────────
if RUN_HWBUILD:
    SwBuildHelper(hw_builder=hw).package_export_file()
    print('software export complete -> ./export')
else:
    print('run the hardware build first (RUN_HWBUILD=True)')
