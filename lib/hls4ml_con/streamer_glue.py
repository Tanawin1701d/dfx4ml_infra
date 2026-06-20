"""Glue between hls4ml partitions and the dfx4ml hardware build.

This module stitches the per-partition ``create_dfx_region_user_bd`` TCL fragments into
the single dispatcher file passed as ``user_rm_build_tcl_path``, and exposes a small
helper to read an hls4ml output's geometry.

The dfx streamer-bank allocation itself (``compute_dfx_params``) now lives in
``lib/hls4ml_build.py`` -- import it from there (or via ``Hls4ml_build``).

Topology model
--------------
The caller describes the cut model as a list of *partition* dicts::

    {
        'name':    'halfA',
        'project': 'prj_halfA',        # hls4ml project_name (for the kernel VLNV)
        'region':  0,                  # dfx PR region this RM lives in (0 or 1)
        'rm':      0,                  # RM slot index within the region
        'inputs':  ['DMA'],            # ordered by kernel input  port (axi_input_stream_<k>)
        'outputs': ['ha_bneck', 'ha_skip2', 'ha_skip1'],  # ordered by kernel output port
    }

``'DMA'`` in inputs/outputs refers to streamer index 0 (always the DMA path).
"""

import os

from . import tcl_gen


def stream_geometry_from_hls(hls_model, output_index):
    """Extract ``(shape_without_batch, precision_bits)`` from an hls4ml output var."""
    var = hls_model.get_output_variables()[output_index]
    shape = tuple(int(d) for d in var.shape)
    precision = int(var.type.precision.width)
    return shape, precision


def build_dispatcher_tcl(partitions, out_path):
    """Stitch every partition's (block_name → kernel VLNV) into the dispatcher TCL.

    ``partitions`` is a list of ``hls4ml_build.Partition`` objects. Produces the file
    passed to ``HwBuildHelper(user_rm_build_tcl_path=...)``.
    """
    fragments = [
        tcl_gen.make_fragment(f"dfx_pr_region_{p.region}_rm_{p.rm}", p.project) for p in partitions
    ]
    return tcl_gen.stitch_dispatcher(fragments, out_path)


def collect_fragments_from_outputs(output_dirs, out_path):
    """Alternative: stitch the per-model fragment files emitted by the writer."""
    lines = []
    for d in output_dirs:
        frag = os.path.join(d, 'dfx_region_user_bd.fragment.tcl')
        if os.path.exists(frag):
            with open(frag) as f:
                lines.append(f.read())
    return tcl_gen.stitch_dispatcher(lines, out_path)
