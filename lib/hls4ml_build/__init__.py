"""High-level orchestration for the Keras -> hls4ml -> dfx4ml flow.

`Hls4ml_build` captures, as a reusable class, the procedural pipeline that previously
lived only as cells in `quick_start_hls4ml.ipynb`. The class body is split by concern:

| module          | role                                                              |
|-----------------|-------------------------------------------------------------------|
| `builder.py`    | `Hls4ml_build` core: ctor, topology validation, tool-path setup   |
| `_convert.py`   | `ConvertMixin`  -- convert partitions to hls4ml ModelGraphs        |
| `_csim.py`      | `CsimMixin`     -- single-partition + end-to-end chained csim      |
| `_synth.py`     | `SynthMixin`    -- C-synthesis + package (with/without FIFO opt)   |
| `_glue.py`      | `GlueMixin`     -- streamer glue + dispatcher TCL                  |
| `dfx_params.py` | `compute_dfx_params` (relocated from `hls4ml_con/streamer_glue`)   |
| `topology.py`   | `Partition` / `Stream` / `DMA` -- typed, low-boilerplate topology  |

Public API: ``from hls4ml_build import Hls4ml_build, Partition, Stream, DMA, compute_dfx_params``.
"""

from .builder import Hls4ml_build
from .dfx_params import compute_dfx_params
from .topology import DMA, Partition, Stream

__all__ = ['Hls4ml_build', 'Partition', 'Stream', 'DMA', 'compute_dfx_params']
