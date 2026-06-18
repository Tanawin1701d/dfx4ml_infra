# ── quick_start_hls4ml_model.py ──────────────────────────────────────────────
# ML model only: the full Keras model, locked/trained weights, the partition
# sub-models (which reuse the full model's layers → shared weights), and the
# locked reproducible input pool. Imported by quick_start_hls4ml_build.py.
import os
from pathlib import Path

os.environ.setdefault('TF_CPP_MIN_LOG_LEVEL', '3')

import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.keras import layers

REPO = Path.cwd()

# ── reproducibility — seeds + lock files ────────────────────────────────────
# Locking the trained weights and the input pool to disk makes every re-run produce
# the *same* csim / diag numbers. Seeds only matter the first time (before the lock
# files exist); after that the weights/inputs are loaded verbatim.
SEED = 0
np.random.seed(SEED)
tf.random.set_seed(SEED)

OUT_ROOT     = REPO / 'hls4ml_dfx_out'
LOCK_DIR     = OUT_ROOT / '_lock'
WEIGHTS_FILE = LOCK_DIR / 'full_weights.h5'
INPUT_FILE   = LOCK_DIR / 'x_input_pool.npy'
LOCK_DIR.mkdir(parents=True, exist_ok=True)

MAX_QUERIES = 1000      # size of the locked input pool
NUM_QUERIES = 2         # samples actually fed to csim / diag (keep small — csim is slow)

# ── build the full model (named layers) + lock/train weights ─────────────────
# Built inline (not via helpers) so the partition sub-models below can reuse these exact
# layer objects via full_model.get_layer(...) — that is what makes every partition share
# the full model's weights (and stay consistent with the locked weights).
# Partition cuts marked inline: config_4 splits at part1|part2|part3|part4;
# config_2 splits halfA|halfB (halfA = part1+part2, halfB = part3+part4).
inp = keras.Input(shape=(8, 8, 1), name='in0')
# ── part1 (enc-A) ── halfA ─────────────────────────────  in: DMA → out: p1_out, skip1
s1     = layers.Conv2D(8,  3, padding='same', activation='relu', name='enc_conv1')(inp)   # (8,8,8)  skip1
x      = layers.Conv2D(16, 3, padding='same', activation='relu', name='enc_conv1b')(s1)
x      = layers.Conv2D(16, 3, padding='same', activation='relu', name='enc_conv2')(x)
p1_out = layers.MaxPool2D(2, name='enc_pool1')(x)                                         # (4,4,16)
# ── part2 (enc-B) ──────────────────────────────────────  in: p1_out → out: bneck, skip2
s2     = layers.Conv2D(16, 3, padding='same', activation='relu', name='enc_conv3')(p1_out)# (4,4,16) skip2
x      = layers.MaxPool2D(2, name='enc_pool2')(s2)                                        # (2,2,16)
p2_out = layers.Conv2D(8,  3, padding='same', activation='relu', name='bottleneck')(x)    # (2,2,8)
# ── part3 (dec-A) ── halfB ─────────────────────────────  in: bneck, skip2 → out: p3
y      = layers.UpSampling2D(2, name='dec_up1')(p2_out)
y      = layers.Conv2D(16, 3, padding='same', activation='relu', name='dec_conv1')(y)
y      = layers.Add(name='skip2_add')([y, s2])
p3_out = layers.Conv2D(16, 3, padding='same', activation='relu', name='dec_conv1b')(y)    # (4,4,16)
# ── part4 (dec-B) ──────────────────────────────────────  in: p3, skip1 → out: DMA
y      = layers.UpSampling2D(2, name='dec_up2')(p3_out)
y      = layers.Conv2D(8,  3, padding='same', activation='relu', name='dec_conv2')(y)
y      = layers.Add(name='skip1_add')([y, s1])
y      = layers.GlobalAveragePooling2D(name='gap')(y)
y      = layers.Dense(64, activation='relu', name='dense1')(y)
full_out = layers.Dense(4, activation=None, name='dense_out')(y)                           # (4,)

full_model = keras.Model(inp, full_out, name='full')
full_model.compile(optimizer='adam', loss='categorical_crossentropy', metrics=['accuracy'])
print('full model params:', full_model.count_params())


def init_weights(model):
    """Load locked weights, or train a few epochs to break symmetry, then save+lock."""
    if WEIGHTS_FILE.exists():
        model.load_weights(str(WEIGHTS_FILE), by_name=True, skip_mismatch=True)
        return f'weights loaded ← {WEIGHTS_FILE}'
    # untrained relu nets often collapse to all-zero activations; train briefly so the
    # weights are non-trivial (and HLS csim has real signal to chew on).
    np.random.seed(SEED)
    X_tr = np.random.rand(500, 8, 8, 1).astype(np.float32)
    y_tr = np.eye(4)[np.random.randint(0, 4, 500)]
    print('[train] training 20 epochs to break weight symmetry…')
    model.fit(X_tr, y_tr, epochs=20, batch_size=32, verbose=0)
    model.save_weights(str(WEIGHTS_FILE))
    return f'weights trained + saved → {WEIGHTS_FILE}'


print('[lock]', init_weights(full_model))

# ── partition sub-models (reuse full_model layers → shared weights) ──────────
L = full_model.get_layer

# 4-partition: part1 (enc-A) → part2 (enc-B) → part3 (dec-A) → part4 (dec-B)
part1 = keras.Model(inp, [p1_out, s1], name='part1')                 # → p1_main, skip1

p2_in = keras.Input((4, 4, 16), name='p2_in')
_s2   = L('enc_conv3')(p2_in)
_bn   = L('bottleneck')(L('enc_pool2')(_s2))
part2 = keras.Model(p2_in, [_bn, _s2], name='part2')                 # → bneck, skip2

p3_bn = keras.Input((2, 2, 8), name='p3_bneck'); p3_s2 = keras.Input((4, 4, 16), name='p3_skip2')
_y    = L('dec_conv1b')(L('skip2_add')([L('dec_conv1')(L('dec_up1')(p3_bn)), p3_s2]))
part3 = keras.Model([p3_bn, p3_s2], _y, name='part3')                # → p3

p4_p3 = keras.Input((4, 4, 16), name='p4_p3'); p4_s1 = keras.Input((8, 8, 8), name='p4_skip1')
_y    = L('skip1_add')([L('dec_conv2')(L('dec_up2')(p4_p3)), p4_s1])
_y    = L('dense_out')(L('dense1')(L('gap')(_y)))
part4 = keras.Model([p4_p3, p4_s1], _y, name='part4')                # → out

# 2-partition: halfA (encoder, 1 in / 3 out) → halfB (decoder, 3 in / 1 out)
halfA = keras.Model(inp, [p2_out, s2, s1], name='halfA')             # → bneck, skip2, skip1

hB_bn = keras.Input((2, 2, 8), name='hB_bneck')
hB_s2 = keras.Input((4, 4, 16), name='hB_skip2')
hB_s1 = keras.Input((8, 8, 8), name='hB_skip1')
_y    = L('dec_conv1b')(L('skip2_add')([L('dec_conv1')(L('dec_up1')(hB_bn)), hB_s2]))
_y    = L('skip1_add')([L('dec_conv2')(L('dec_up2')(_y)), hB_s1])
_y    = L('dense_out')(L('dense1')(L('gap')(_y)))
halfB = keras.Model([hB_bn, hB_s2, hB_s1], _y, name='halfB')         # → out

print('partition models:', [m.name for m in (full_model, halfA, halfB, part1, part2, part3, part4)])

# ── lock the input pool (reproducible csim/diag inputs) ──────────────────────
def load_input_pool():
    """Load the locked input pool, or generate + save it on first run."""
    if INPUT_FILE.exists():
        pool = np.load(str(INPUT_FILE))
        print(f'[lock] loaded {pool.shape[0]:,} samples ← {INPUT_FILE}')
    else:
        np.random.seed(42)
        pool = np.random.rand(MAX_QUERIES, 8, 8, 1).astype(np.float32)
        np.save(str(INPUT_FILE), pool)
        print(f'[lock] saved {MAX_QUERIES:,} samples → {INPUT_FILE}')
    return pool

X_pool = load_input_pool()
X_full = X_pool[:NUM_QUERIES]

# forward-order layer list probed by Hls4ml_build.diag_bisect
PROBE_LAYERS = [
    'enc_conv1', 'enc_conv1b', 'enc_conv2', 'enc_pool1', 'enc_conv3', 'enc_pool2',
    'bottleneck', 'dec_up1', 'dec_conv1', 'skip2_add', 'dec_conv1b', 'dec_up2',
    'dec_conv2', 'skip1_add', 'gap', 'dense1', 'dense_out',
]
