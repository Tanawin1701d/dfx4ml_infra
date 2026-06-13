"""Glue between hls4ml partitions and the dfx4ml hardware build.

After the per-partition hls4ml models are converted (so their inter-partition
output geometries are known) but *before* synthesis / fifo-depth optimisation,
this module:

1. builds the ``streams`` list and runs :func:`dfx_streamer_cal.dfx_streamer_report`
   to allocate physical dfx streamer banks;
2. maps the allocation onto the three :class:`HwBuildHelper` constructor params
   ``dfx_streamers`` / ``dfx_regions`` / ``rm_schemetics``;
3. stitches the per-partition ``create_dfx_region_user_bd`` TCL fragments into the
   single dispatcher file passed as ``user_rm_build_tcl_path``.

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

and a list of *stream* dicts (the inter-partition tensors), exactly the schema
:func:`dfx_streamer_report` expects::

    {'name': 'ha_bneck', 'shape': (2, 2, 8), 'precision': 16,
     'region': 0, 'alloc_phase': 0, 'free_phase': 1}

``'DMA'`` in inputs/outputs refers to streamer index 0 (always the DMA path).
"""

import os

from dfx_streamer_cal import DFX_STREAMER_BANK_DEPTH, DFX_STREAMER_BANK_WIDTH, dfx_streamer_report

from . import tcl_gen

DMA_STREAMER_INDEX = 0


def stream_geometry_from_hls(hls_model, output_index):
    """Extract ``(shape_without_batch, precision_bits)`` from an hls4ml output var."""
    var = hls_model.get_output_variables()[output_index]
    shape = tuple(int(d) for d in var.shape)
    precision = int(var.type.precision.width)
    return shape, precision


def _default_dma_streamer():
    return {'load_width': 4, 'store_width': 4, 'actual_width': 32, 'amount_row': DFX_STREAMER_BANK_DEPTH}


def compute_dfx_params(
    partitions,
    streams,
    total_banks,
    amt_phase,
    num_regions,
    dma_streamer=None,
    bank_width=DFX_STREAMER_BANK_WIDTH,
    bank_depth=DFX_STREAMER_BANK_DEPTH,
    debug=False,
):
    """Compute the HwBuildHelper streamer params from a partition/stream description.

    Returns a dict with keys ``dfx_streamers``, ``dfx_regions``, ``rm_schemetics``
    (ready to splat into ``HwBuildHelper``), plus ``report`` (the raw
    :func:`dfx_streamer_report` output) and ``stream_to_streamer`` for inspection.
    """
    ##------------------------------------------------------------
    ## PHASE 1: BANK ALLOCATION
    ##   pack the streams onto physical streamer banks
    ##------------------------------------------------------------
    report = dfx_streamer_report(
        streams, total_banks=total_banks, amt_phase=amt_phase, bank_width=bank_width, bank_depth=bank_depth, debug=debug
    )

    ##------------------------------------------------------------
    ## PHASE 2: STREAMER INDEX ASSIGNMENT
    ##   index 0 = DMA, 1.. = report order; build stream_to_streamer
    ##   (key = stream name, value = streamer idx) and the hw_streamers list
    ##------------------------------------------------------------
    stream_to_streamer = {}
    bits_per_streamer = {}
    hw_streamers = [dma_streamer or _default_dma_streamer()]  # index 0 = DMA
    for offset, d in enumerate(report['dfx_streamers']):
        idx = offset + 1
        for s in d['streams']:
            stream_to_streamer[s['name']] = idx
        bus_bits = d['amt_banks_per_entry'] * bank_width
        if bus_bits & (bus_bits - 1):
            print(
                f"[dfx-streamer] WARNING: streamer {idx} bus width {bus_bits} is not a power of two; "
                f"the dfx region BD requires power-of-two interface widths — adjust precision/packing."
            )
        data_bits = max(s['bits_per_entry'] for s in d['streams'])
        bits_per_streamer[idx] = bus_bits
        hw_streamers.append(
            {
                'load_width': bus_bits // 8,
                'store_width': bus_bits // 8,
                'actual_width': data_bits,
                'amount_row': d['mul_factor'] * bank_depth,
            }
        )

    def _streamer_of(io_name):
        return DMA_STREAMER_INDEX if io_name == 'DMA' else stream_to_streamer[io_name]

    ##------------------------------------------------------------
    ## PHASE 3: REGION STREAMER SUPERSET
    ##   per region, collect the union of streamers feeding (load) and
    ##   draining (store) it across all its RM variants
    ##------------------------------------------------------------
    # list indexed by region, each a set of streamer indices, e.g. for 2 regions:
    #   region_load  = [{0, 2}, {1}]   region 0 loads from streamers 0 & 2, region 1 from 1
    #   region_store = [{1},    {0}]   region 0 stores to streamer 1, region 1 to 0
    region_load = [set() for _ in range(num_regions)]
    region_store = [set() for _ in range(num_regions)]
    for p in partitions:
        r = p['region']
        for io_name in p['inputs']:
            region_load[r].add(_streamer_of(io_name))
        for io_name in p['outputs']:
            region_store[r].add(_streamer_of(io_name))
    dfx_regions = [
        {'load_streamers': sorted(region_load[r]), 'store_streamers': sorted(region_store[r])}
        for r in range(num_regions)
    ]

    ##------------------------------------------------------------
    ## PHASE 4: GROUP RMs BY REGION
    ##   group partitions by region, each group ordered by rm slot index
    ##   list indexed by region, each a list of partition dicts, e.g.:
    ##     rms_by_region = [[partA_rm0, partA_rm1],   # region 0, two RM variants
    ##                      [partB_rm0, partB_rm1]]    # region 1, two RM variants
    ##------------------------------------------------------------
    rms_by_region = [[] for _ in range(num_regions)]
    for p in partitions:
        rms_by_region[p['region']].append(p)
    for region_rms in rms_by_region:
        region_rms.sort(key=lambda part: part['rm'])
    n_rm = max((len(x) for x in rms_by_region), default=0)

    # all populated regions must declare the same number of RMs
    for r in range(num_regions):
        if rms_by_region[r] and len(rms_by_region[r]) != n_rm:
            raise ValueError(
                f'region {r} has {len(rms_by_region[r])} RMs but another region has {n_rm}; '
                f'all regions must declare the same number of RMs for the dfx build.'
            )

    ##------------------------------------------------------------
    ## PHASE 5: RM SCHEMATICS
    ##   rm_schemetics[region][rm]: for each streamer in the region superset,
    ##   record (streamer_idx, kernel_port) — kernel_port == -1 when this RM
    ##   variant leaves that port idle (a dummy is wired in the BD instead)
    ##   list[region] of list[rm] of dict, e.g. region 0 (load superset {0,2},
    ##   store superset {1}) with two RMs:
    ##     rm_schemetics[0] = [
    ##       {'load_io_map': [(0, 0), (2, 1)],  'store_io_map': [(1, 0)]},   # rm0 uses both loads
    ##       {'load_io_map': [(0, 0), (2, -1)], 'store_io_map': [(1, 0)]},   # rm1 leaves streamer 2 idle
    ##     ]
    ##------------------------------------------------------------
    rm_schemetics = []
    for r in range(num_regions):
        region_dicts = []
        load_super = dfx_regions[r]['load_streamers']
        store_super = dfx_regions[r]['store_streamers']
        for m in range(n_rm):
            p = rms_by_region[r][m] if m < len(rms_by_region[r]) else None
            load_io_map = []
            store_io_map = []
            for io_idx in load_super:
                k = -1
                if p is not None:
                    for port, io_name in enumerate(p['inputs']):
                        if _streamer_of(io_name) == io_idx:
                            k = port
                            break
                load_io_map.append((io_idx, k))
            for io_idx in store_super:
                k = -1
                if p is not None:
                    for port, io_name in enumerate(p['outputs']):
                        if _streamer_of(io_name) == io_idx:
                            k = port
                            break
                store_io_map.append((io_idx, k))
            region_dicts.append({'load_io_map': load_io_map, 'store_io_map': store_io_map})
        rm_schemetics.append(region_dicts)

    ##------------------------------------------------------------
    ## PHASE 6: ASSEMBLE RESULT
    ##   the first three keys splat straight into HwBuildHelper;
    ##   the rest are for inspection / validation
    ##------------------------------------------------------------
    return {
        'dfx_streamers': hw_streamers,
        'dfx_regions': dfx_regions,
        'rm_schemetics': rm_schemetics,
        'report': report,
        'stream_to_streamer': stream_to_streamer,
        'interface_widths': bits_per_streamer,
    }


def build_dispatcher_tcl(partitions, out_path):
    """Stitch every partition's (block_name → kernel VLNV) into the dispatcher TCL.

    Produces the file passed to ``HwBuildHelper(user_rm_build_tcl_path=...)``.
    """
    fragments = [
        tcl_gen.make_fragment(f"dfx_pr_region_{p['region']}_rm_{p['rm']}", p['project']) for p in partitions
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
