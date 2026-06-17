"""Typed topology description for the dfx4ml flow -- the single representation.

The whole pipeline (`Hls4ml_build`, `compute_dfx_params`, `dfx_streamer_report`,
`build_dispatcher_tcl`) speaks `Partition` / `Stream` objects directly; there is no
parallel dict schema. Describing the cut this way removes the boilerplate of hand-written
dicts:

* each produced inter-partition tensor is a `Stream(...)` carrying *only* its dfx bank-
  lifetime fields (`region` / `alloc_phase` / `free_phase`) -- its shape is taken straight
  from the producing Keras model's matching output port (and precision defaults to 16);
* `input_flat` / `output_flat` are inferred from whether that side talks to the `DMA`;
* the consumer side just lists stream names in `inputs` (no shapes -- the producer owns
  them).

Example::

    from hls4ml_build import Partition, Stream, DMA
    parts = [
        Partition('halfA', 'p_halfA', halfA, region=0, inputs=[DMA], outputs=[
            Stream('bneck', region=0, alloc_phase=0, free_phase=1),
            Stream('skip2', region=0, alloc_phase=0, free_phase=1),
            Stream('skip1', region=1, alloc_phase=0, free_phase=1)]),
        Partition('halfB', 'p_halfB', halfB, region=1,
                  inputs=['bneck', 'skip2', 'skip1'], outputs=[DMA]),
    ]
"""

from dataclasses import dataclass, field
from typing import Any

DMA = 'DMA'   # sentinel for the external DMA path (streamer index 0)


@dataclass
class Stream:
    """One inter-partition tensor a partition produces -- the single stream representation.

    Only the dfx bank-lifetime fields are declared: ``region`` (which region owns the
    bank), ``alloc_phase`` / ``free_phase`` (its lifetime in reconfiguration phases), and
    optionally ``precision`` (when the stream is quantized differently from the model
    output). Everything else is *derived*, never hand-written:

    * ``shape`` is filled in by the producing :class:`Partition` from the matching Keras
      output port (so a hand-typed shape can't disagree with the model);
    * the geometry fields (``amt_entry_per_query`` ... ``amt_query_per_bankGrp``) are
      filled in by :func:`dfx_streamer_cal.dfx_streamer_report` during bank allocation.

    `dfx_streamer_report` / `compute_dfx_params` consume these objects by attribute (no
    dict round-trip); ``compute_dfx_params`` shallow-copies each one first so the bank-
    allocation pass never mutates the declared topology.
    """
    name        : str
    region      : int
    alloc_phase : int
    free_phase  : int
    precision   : int = 16
    # ---- derived (not declared); see class docstring -----------------------------------
    shape                 : tuple = field(default=None, init=False) # set by producing Partition
    amt_entry_per_query   : int   = field(default=None, init=False) # set by dfx_streamer_report
    bits_per_entry        : int   = field(default=None, init=False)
    amt_banks_per_entry   : int   = field(default=None, init=False)
    amt_query_per_bankGrp : int   = field(default=None, init=False)


@dataclass
class Partition:
    """One RM variant (kernel) placed at (``region``, ``rm``) -- a node of the cut.

    ``inputs`` / ``outputs`` are ordered by kernel port. An input is a stream name (or
    ``DMA``); an output is ``DMA`` or a ``Stream(...)``. ``input_flat`` / ``output_flat``
    are inferred at construction (flat unless that side is a lone ``DMA`` port); pass them
    explicitly to override. After construction, ``streams`` holds the produced inter-
    partition ``Stream`` objects (with ``shape`` filled in from ``model.outputs``) and
    ``output_names`` gives the per-port names.
    """
    name        : str
    project     : str
    model       : Any
    region      : int
    rm          : int = 0
    inputs      : list = field(default_factory=lambda: [DMA])
    outputs     : list = field(default_factory=lambda: [DMA])
    input_flat  : bool = None
    output_flat : bool = None
    streams     : list = field(default_factory=list, init=False)   # produced streams (derived)

    def __post_init__(self):
        out_names = self.output_names
        if self.input_flat is None:
            self.input_flat = (list(self.inputs) != [DMA])
        if self.output_flat is None:
            self.output_flat = (out_names != [DMA])

        # derive each produced stream's shape from the model output at the same port index
        model_outs = list(self.model.outputs)
        if len(model_outs) != len(self.outputs):
            raise ValueError(
                f"partition '{self.name}': model has {len(model_outs)} output(s) but "
                f"{len(self.outputs)} output port(s) were declared; they must line up "
                f"(kernel-port order == model-output order)")
        self.streams = []
        for i, o in enumerate(self.outputs):
            if isinstance(o, str):
                continue   # a DMA port produces no inter-partition stream
            o.shape = tuple(int(d) for d in model_outs[i].shape[1:])
            self.streams.append(o)

    @property
    def output_names(self):
        """Per-port output names (`DMA` or the `Stream.name`), in kernel-port order."""
        return [o if isinstance(o, str) else o.name for o in self.outputs]
