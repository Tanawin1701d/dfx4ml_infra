"""dfx streamer-bank allocation (relocated from hls4ml_con/streamer_glue.py).

`compute_dfx_params` maps a partition/stream topology onto the three HwBuildHelper
constructor params ``dfx_streamers`` / ``dfx_regions`` / ``rm_schemetics``.
"""

import copy

from dfx_streamer_cal import DFX_STREAMER_BANK_DEPTH, DFX_STREAMER_BANK_WIDTH, dfx_streamer_report

DMA_STREAMER_INDEX = 0


def _default_dma_streamer():
    return {'load_width': 4, 'store_width': 4, 'actual_width': 32, 'amount_row': DFX_STREAMER_BANK_DEPTH}


def compute_dfx_params(
    partitions,
    total_banks,
    amt_phase,
    num_regions,
    dma_streamer=None,
    bank_width=DFX_STREAMER_BANK_WIDTH,
    bank_depth=DFX_STREAMER_BANK_DEPTH,
    debug=False,
):
    """Compute the HwBuildHelper streamer params from a list of `Partition` objects.

    The inter-partition streams are taken from each producer's ``partition.streams``.
    Returns a dict with keys ``dfx_streamers``, ``dfx_regions``, ``rm_schemetics``
    (ready to splat into ``HwBuildHelper``), plus ``report`` (the raw
    :func:`dfx_streamer_report` output) and ``stream_to_streamer`` for inspection.
    """
    ##------------------------------------------------------------
    ## PHASE 1: BANK ALLOCATION
    ##   gather the produced streams, pack them onto physical streamer banks
    ##   (shallow-copy each Stream -- dfx_streamer_report fills in geometry /
    ##    normalizes 'shape' on the object, so we keep the declared topology pristine)
    ##------------------------------------------------------------
    streams = [copy.copy(s) for p in partitions for s in p.streams]
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
            stream_to_streamer[s.name] = idx
        bus_bits = d['amt_banks_per_entry'] * bank_width
        if bus_bits & (bus_bits - 1):
            print(
                f"[dfx-streamer] WARNING: streamer {idx} bus width {bus_bits} is not a power of two; "
                f"the dfx region BD requires power-of-two interface widths — adjust precision/packing."
            )
        data_bits = max(s.bits_per_entry for s in d['streams'])
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
        r = p.region
        for io_name in p.inputs:
            region_load[r].add(_streamer_of(io_name))
        for io_name in p.output_names:
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
        rms_by_region[p.region].append(p)
    for region_rms in rms_by_region:
        region_rms.sort(key=lambda part: part.rm)
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
                    for port, io_name in enumerate(p.inputs):
                        if _streamer_of(io_name) == io_idx:
                            k = port
                            break
                load_io_map.append((io_idx, k))
            for io_idx in store_super:
                k = -1
                if p is not None:
                    for port, io_name in enumerate(p.output_names):
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
