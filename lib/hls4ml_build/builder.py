"""`Hls4ml_build` core: constructor, topology validation, and tool-path setup.

The conversion / csim / synthesis / streamer-glue methods live in the sibling mixin
modules (`_convert`, `_csim`, `_synth`, `_glue`); this file holds the shared state and
the pieces that don't belong to any single stage.

Topology model
--------------
The caller describes the cut as a list of `topology.Partition` objects (see that module);
each produced inter-partition tensor is a `Stream(...)` on its producer. Stream shapes are
derived from the producing model, and `input_flat`/`output_flat` plus `amt_phase`/
`num_regions` are inferred -- only `region`/`alloc_phase`/`free_phase` (the bank lifetime)
must be given per `Stream`.
"""

import os
import shutil
import subprocess
from pathlib import Path

import hls4ml

from ._convert import ConvertMixin
from ._csim    import CsimMixin
from ._glue    import GlueMixin
from ._synth   import SynthMixin


class Hls4ml_build(ConvertMixin, CsimMixin, SynthMixin, GlueMixin):
    """Orchestrate the Keras -> hls4ml -> dfx4ml flow for a partitioned model.

    Describe the cut with the typed `Partition` / `Stream` helpers. ``amt_phase`` /
    ``num_regions`` are inferred from the topology when omitted. Typical use::

        from hls4ml_build import Hls4ml_build, Partition, Stream, DMA
        parts = [
            Partition('halfA', 'p_halfA', halfA, region=0, inputs=[DMA], outputs=[
                Stream('bneck', region=0, alloc_phase=0, free_phase=1),
                Stream('skip2', region=0, alloc_phase=0, free_phase=1),
                Stream('skip1', region=1, alloc_phase=0, free_phase=1)]),
            Partition('halfB', 'p_halfB', halfB, region=1,
                      inputs=['bneck', 'skip2', 'skip1'], outputs=[DMA]),
        ]
        hb = Hls4ml_build(parts, out_root='./hls4ml_dfx_out',
                          vitis_path='/tools/Xilinx/Vitis/2023.2',
                          vivado_path='/tools/Xilinx/Vivado/2023.2')
        hb.convert_all()              # 1. get the partial model
        hb.csim_chain()               # 2. (optional) end-to-end csim
        hb.compute_streamer_glue()    # 4. streamer glue  (-> hb.dfx, hb.user_rm_tcl)
        hb.synth_all(fifo_opt=True)   # 3. synthesis + package
        # then hand off to the hardware/software build:
        hw = HwBuildHelper(build_folder_path='./build_prj', dfx_root_path='.',
                          export_folder_path='./export', test_mode=0, hls4ml_build=hb)
        hw.run_build(); hw.package_export_files()
        SwBuildHelper(hw_builder=hw).package_export_file()
    """

    def __init__(self,
                 partitions,
                 out_root,
                 amt_phase          = None,
                 num_regions        = None,
                 streams            = None,
                 # ---- conversion config (notebook HLS_PARAMS + _cfg defaults) ----
                 backend            = 'VitisUnifiedDFx4ml',
                 io_type            = 'io_stream',
                 board              = 'kv260',
                 part               = 'xck26-sfvc784-2LV-c',
                 clock_period       = '10ns',
                 input_type         = 'float',
                 output_type        = 'float',
                 axi_mode           = 'axi_stream',
                 precision          = 'ap_fixed<16,6>',
                 reuse_factor       = 8,
                 strategy           = 'Resource',
                 total_banks        = 64,
                 rm_index_width     = 3,
                 vitis_path         = None,
                 vivado_path        = None,
                 setup_env          = True):
        # backend registration sanity check (caller sets HLS4ML_BACKEND_PLUGINS pre-import)
        if backend.lower() not in hls4ml.backends.get_available_backends():
            raise RuntimeError(
                f"hls4ml backend '{backend}' is not registered "
                f"(available: {hls4ml.backends.get_available_backends()}); "
                f"set os.environ['HLS4ML_BACKEND_PLUGINS']='hls4ml_con' before importing hls4ml.")

        self.partitions     = list(partitions)              # list of Partition objects
        self.out_root       = Path(out_root)
        self.streams        = self._collect_streams(self.partitions, streams)
        # amt_phase / num_regions are inferred from the topology when not given
        self.num_regions    = num_regions if num_regions is not None \
            else max(p.region for p in self.partitions) + 1
        self.amt_phase      = amt_phase if amt_phase is not None \
            else max((s.free_phase for s in self.streams), default=1)
        # conversion config
        self.backend        = backend
        self.io_type        = io_type
        self.board          = board
        self.part           = part
        self.clock_period   = clock_period
        self.input_type     = input_type
        self.output_type    = output_type
        self.axi_mode       = axi_mode
        self.precision      = precision
        self.reuse_factor   = reuse_factor
        self.strategy       = strategy
        self.total_banks    = total_banks
        self.rm_index_width = rm_index_width
        # tool install dirs (each holds a settings64.sh)
        self.vitis_path     = vitis_path
        self.vivado_path    = vivado_path

        # outputs populated by later stages
        self.hls_models = {}     # partition name -> hls4ml ModelGraph
        self.dfx        = None   # compute_streamer_glue() result
        self.user_rm_tcl = None  # dispatcher TCL path

        self._validate()

        if setup_env and (vitis_path or vivado_path):
            self.setup_env()

    ##================================================================
    ## topology helpers + validation
    ##================================================================
    @staticmethod
    def _collect_streams(partitions, streams):
        """Flatten the streams each producer partition derives (or use an explicit list)."""
        if streams is not None:
            return streams
        collected = []
        for p in partitions:
            collected.extend(p.streams)
        return collected

    def _validate(self):
        if not self.partitions:
            raise ValueError('partitions must be a non-empty list')
        for p in self.partitions:
            if getattr(p, 'model', None) is None:
                raise ValueError(f"partition '{getattr(p, 'name', '?')}' is missing the keras 'model'")

        # collected stream names must be unique
        names = [s.name for s in self.streams]
        dupes = {n for n in names if names.count(n) > 1}
        if dupes:
            raise ValueError(f'duplicate stream name(s) across partitions: {sorted(dupes)}')
        known = set(names)

        # every non-DMA io name must resolve to a declared stream
        for p in self.partitions:
            for io_name in list(p.inputs) + list(p.output_names):
                if io_name != 'DMA' and io_name not in known:
                    raise ValueError(
                        f"partition '{p.name}' references stream '{io_name}' that no partition "
                        f"produces; produced: {sorted(known)}")

        # exactly one entry ('DMA' input) and one exit ('DMA' output)
        n_entry = sum('DMA' in p.inputs for p in self.partitions)
        n_exit = sum('DMA' in p.output_names for p in self.partitions)
        if n_entry != 1 or n_exit != 1:
            raise ValueError(
                f"expected exactly one 'DMA' input partition and one 'DMA' output partition; "
                f"got {n_entry} entry / {n_exit} exit")

        # warn (do not fail) if partitions are not in producer-first order
        produced = set()
        for p in self.partitions:
            for io_name in p.inputs:
                if io_name != 'DMA' and io_name not in produced:
                    print(f"[hls4ml-build] WARNING: partition '{p.name}' consumes '{io_name}' "
                          f"before any earlier partition produces it; csim_chain expects "
                          f"producer-first order.")
            produced.update(p.output_names)

    ##================================================================
    ## tool paths
    ##================================================================
    @property
    def vivado_bin(self):
        """Absolute path to the vivado executable (what HwBuildHelper needs)."""
        if not self.vivado_path:
            raise ValueError('vivado_path was not provided to Hls4ml_build')
        return os.path.join(self.vivado_path, 'bin', 'vivado')

    def setup_env(self):
        """Source the Vitis/Vivado settings64.sh and import the resulting env onto PATH.

        Mirrors notebook Cell 1b: sources each install dir's settings64.sh in a subshell,
        then copies the whole resulting environment (PATH, LD_LIBRARY_PATH, XILINX_*, ...)
        into this process. Asserts the relevant tools end up on PATH.
        """
        settings = []
        tools = []
        if self.vitis_path:
            settings.append(os.path.join(self.vitis_path, 'settings64.sh'))
            tools += ['v++', 'vitis-run']
        if self.vivado_path:
            settings.append(os.path.join(self.vivado_path, 'settings64.sh'))
            tools += ['vivado']

        if not settings:
            return

        src = ' && '.join(f'source "{s}"' for s in settings)
        env = subprocess.check_output(['bash', '-c', f'{src} && env -0'], text=True).split('\0')
        for line in env:
            if '=' in line:
                k, v = line.split('=', 1)
                os.environ[k] = v

        for tool in tools:
            path = shutil.which(tool)
            if not path:
                raise RuntimeError(f"{tool} still not on PATH after sourcing settings64.sh "
                                   f"(check vitis_path / vivado_path)")
            print(f'{tool:10s}-> {path}')
