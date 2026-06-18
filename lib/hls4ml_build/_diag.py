"""diagnostic mixin: layer-by-layer HLS csim bisect to locate signal collapse.

Ported from the standalone `_diag_hls_bisect` experiment. Probes each named layer of a
Keras model with a one-layer-deep csim and compares the HLS output range/mean against the
Keras reference, so you can see exactly where (and at which layer) the fixed-point HLS
signal goes uniform / diverges -- the usual symptom of a too-small precision or a packing
bug. Reuses this instance's backend + conversion config so the probe matches the real build.
"""

import os
import shutil
from pathlib import Path

import numpy as np

import hls4ml


class DiagMixin:
    """``diag_bisect`` -- per-layer csim bisect for signal-collapse diagnosis."""

    def diag_bisect(self, keras_model, probe_layers, x_input, base_dir=None):
        """Convert + compile + predict a probe sub-model for each layer, HLS vs Keras.

        For every name in ``probe_layers`` a sub-model ``keras_model.input -> layer.output``
        is converted with this instance's backend/conversion config, csim-compiled, and run
        on ``x_input``. Each layer prints the keras vs hls range/mean and a status:
        ``OK`` / ``COLLAPSED`` / ``COLLAPSED(uniform)`` / ``ERROR(...)``.

        Args:
            keras_model: the full Keras model to probe (single input).
            probe_layers (list[str]): layer names to probe, in forward order.
            x_input: input array matching ``keras_model.input``.
            base_dir (str | Path | None): where the per-probe projects are written
                (default ``<out_root>/diag``).

        Returns:
            dict[str, str]: layer name -> status string.
        """
        # keras imported lazily so importing hls4ml_build never hard-requires tensorflow
        from tensorflow.keras.models import Model

        base = Path(base_dir) if base_dir else (self.out_root / 'diag')
        base.mkdir(parents=True, exist_ok=True)

        print('\n' + '=' * 60)
        print('DIAGNOSTIC: HLS csim bisect -- looking for signal collapse')
        print('=' * 60)

        inp_tensor = keras_model.input
        results = {}
        for layer_name in probe_layers:
            try:
                out_tensor = keras_model.get_layer(layer_name).output
            except ValueError:
                print(f'  [diag] "{layer_name}" not found -- skipping')
                continue

            probe = Model(inp_tensor, out_tensor, name=f'probe_{layer_name}')
            y_keras = probe.predict(x_input, verbose=0)
            k_min, k_max, k_mean, k_std = (float(f(y_keras)) for f in (np.min, np.max, np.mean, np.std))

            probe_dir = str(base / f'diag_{layer_name}')
            if os.path.exists(probe_dir):
                shutil.rmtree(probe_dir)

            try:
                hm = hls4ml.converters.convert_from_keras_model(
                    probe,
                    hls_config=self._cfg(probe),
                    output_dir=probe_dir,
                    project_name=f'diag_{layer_name}',
                    input_flat=False,
                    output_flat=False,
                    package_as_xo=False,
                    backend=self.backend,
                    io_type=self.io_type,
                    board=self.board,
                    part=self.part,
                    clock_period=self.clock_period,
                    input_type=self.input_type,
                    output_type=self.output_type,
                    axi_mode=self.axi_mode,
                )
                hm.compile()
                y_hls = hm.predict(x_input)
                h_min, h_max, h_mean, h_std = (float(f(y_hls)) for f in (np.min, np.max, np.mean, np.std))
                uniform = h_std < 1e-6 and k_std > 1e-3
                mean_ok = abs(h_mean - k_mean) < 0.5 * (abs(k_mean) + 1e-6)
                status = 'COLLAPSED(uniform)' if uniform else ('OK' if mean_ok else 'COLLAPSED')
            except Exception as exc:
                h_min = h_max = h_mean = float('nan')
                status = f'ERROR({type(exc).__name__})'

            results[layer_name] = status
            print(
                f'  [{layer_name:12s}]  '
                f'keras=[{k_min:+.4f}, {k_max:+.4f}] mean={k_mean:+.4f}  '
                f'hls=[{h_min:+.4f}, {h_max:+.4f}] mean={h_mean:+.4f}  {status}'
            )
        print('=' * 60 + '\n')
        return results
