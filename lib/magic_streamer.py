"""Magic streamer bank/group allocation.

Standalone port of ``_magic_streamer_report`` from
``project7/hls4ml/simple_conv_nn_skip4_vitis_unified.py``.

Given the ordered list of inter-partition output streams produced during a
multi-region DFX run, this computes how many physical DFX streamer banks each
stream needs, packs streams that share geometry+region onto reusable streamers,
then greedily grows the bottleneck streamer until the bank budget is exhausted.

NOTE: this scheme only supports 1 or 2 reconfigurable regions. Stream 'region'
tags must all be 0 (single region) or 0/1 (two regions); anything else raises.
"""

# bank geometry defaults (match the source script)
MAGIC_STREAMER_BANK_WIDTH = 64    # bits per bank I/O
MAGIC_STREAMER_BANK_DEPTH = 4096  # rows per bank


def magic_streamer_report(
    streams,
    total_banks,
    amt_phase,
    bank_width=MAGIC_STREAMER_BANK_WIDTH,
    bank_depth=MAGIC_STREAMER_BANK_DEPTH,
    debug=False,
):
    """Compute and print bank/group allocation for the inter-partition magic streamer.

    Args:
        streams: ordered list of dicts with keys
            name, shape (tuple, no batch), precision (bits),
            region (0|1), alloc_phase (int), free_phase (int).
            Each dict is mutated in place with the derived geometry fields.
        total_banks: bank budget N.
        amt_phase: number of producing partitions (split - 1).
        bank_width: bits per bank I/O.
        bank_depth: rows per bank.
        debug: print the per-phase allocation / upgrade trace.

    Returns:
        dict with the full computation (dfx_streamers, total_banks_used,
        and min_total_query when at least one streamer was allocated).

    Raises:
        ValueError: if regions are not a subset of {0, 1} (1- or 2-region only),
            or a single query does not fit one bank group.
    """

    # --- region guard: 1- or 2-region scheme only -------------------------------
    regions = sorted({s['region'] for s in streams})
    if regions and not set(regions).issubset({0, 1}):
        raise ValueError(
            f"[magic-streamer] regions {regions} unsupported; this scheme only "
            f"handles 1 or 2 regions (region tags must be 0 or 1)."
        )

    BW = bank_width
    BD = bank_depth

    #######################################
    # --- PHASE 1: init ------------------#
    #######################################
    for stream in streams:
        shape = tuple(int(d) for d in stream['shape'])

        amt_entry_per_query = 1
        for d in shape[:-1]:
            amt_entry_per_query *= d
        amt_var_per_entry = shape[-1]
        precision = stream['precision']

        bits_per_entry = precision * amt_var_per_entry
        amt_banks_per_entry = (bits_per_entry + BW - 1) // BW
        amt_query_per_bankGrp = BD // amt_entry_per_query

        stream['shape'] = shape
        stream['amt_entry_per_query'] = amt_entry_per_query
        stream['bits_per_entry'] = bits_per_entry
        stream['amt_banks_per_entry'] = amt_banks_per_entry
        stream['amt_query_per_bankGrp'] = amt_query_per_bankGrp

        # bug-3 check: a stream whose single query already exceeds one bank depth
        # cannot be buffered by the current single-bank-group scheme.
        if amt_query_per_bankGrp == 0:
            raise ValueError(
                f"[magic-streamer] stream '{stream['name']}' has amt_entry_per_query="
                f'{amt_entry_per_query} > BANK_DEPTH={BD}; one query does not fit in a '
                f'single bank group. Increase bank_depth or split the stream.'
            )

    # --- show stream clarification --------------
    stream_border = '  ' + '─' * 148
    print('[magic-streamer] streams:')
    print(stream_border)
    print(
        f'  | {"name":<10} | {"shape":<18} | {"region":>6} | {"alloc_phase":>11} | {"free_phase":>10} '
        f'| {"precision":>9} | {"amt_entry_per_query":>19} | {"bits_per_entry":>14} '
        f'| {"amt_banks_per_entry":>19} | {"amt_query_per_bankGrp":>21} |'
    )
    print(stream_border)
    for s in streams:
        print(
            f'  | {s["name"]:<10} | {str(s["shape"]):<18} | {s["region"]:>6} '
            f'| {s["alloc_phase"]:>11} | {s["free_phase"]:>10} | {s["precision"]:>9} '
            f'| {s["amt_entry_per_query"]:>19} | {s["bits_per_entry"]:>14} '
            f'| {s["amt_banks_per_entry"]:>19} | {s["amt_query_per_bankGrp"]:>21} |'
        )
    print(stream_border)

    ######################################
    # --- PHASE 2: allocate the streamer #
    ######################################

    last_dfx_streamer_id = 1
    dfx_streamers        = []       # the result signal
    free_dfx_streamers   = []
    using_dfx_streamers  = []

    for alloc_phase in range(0, amt_phase):
        if debug:
            print(f'\n[magic-streamer] ───── phase {alloc_phase} ─────')

        phase_streams = [s for s in streams if s['alloc_phase'] == alloc_phase]
        if debug:
            print(f'  streams to allocate ({len(phase_streams)}): {[s["name"] for s in phase_streams]}')
            print(f'  free  pool before: {[d["name"] for d in free_dfx_streamers]}')
            print(f'  using pool before: {[d["name"] for d in using_dfx_streamers]}')

        # allocate stream to dfx streamer
        for stream in phase_streams:
            found = False
            for free_dfx_streamer in free_dfx_streamers:
                if (stream['amt_banks_per_entry'] == free_dfx_streamer['amt_banks_per_entry']) and (
                    stream['region'] == free_dfx_streamer['region']
                ):
                    free_dfx_streamer['next_fin_phase'] = stream['free_phase']
                    free_dfx_streamer['streams'].append(stream)
                    free_dfx_streamers.remove(free_dfx_streamer)
                    using_dfx_streamers.append(free_dfx_streamer)
                    found = True
                    if debug:
                        print(
                            f'    [reuse]  stream {stream["name"]:<10} → {free_dfx_streamer["name"]} '
                            f'(banks/e={stream["amt_banks_per_entry"]}, region={stream["region"]}, '
                            f'next_fin_phase={stream["free_phase"]})'
                        )
                    break
            # if there is no magic streamer, create new one
            if not found:
                new_dfx_streamer = {
                    'name': f'streamer_{last_dfx_streamer_id}',
                    'amt_banks_per_entry': stream['amt_banks_per_entry'],
                    'region': stream['region'],
                    'next_fin_phase': stream['free_phase'],
                    'mul_factor': 1,
                    'streams': [stream],
                }
                last_dfx_streamer_id += 1
                dfx_streamers.append(new_dfx_streamer)
                using_dfx_streamers.append(new_dfx_streamer)
                if debug:
                    print(
                        f'    [create] stream {stream["name"]:<10} → {new_dfx_streamer["name"]} '
                        f'(banks/e={stream["amt_banks_per_entry"]}, region={stream["region"]}, '
                        f'next_fin_phase={stream["free_phase"]})'
                    )

        # try to free the using_dfx_streamer whose next_fin_phase matches current alloc_phase
        for using_dfx_streamer in list(using_dfx_streamers):
            if using_dfx_streamer['next_fin_phase'] == alloc_phase:
                using_dfx_streamers.remove(using_dfx_streamer)
                free_dfx_streamers.append(using_dfx_streamer)
                if debug:
                    print(f'    [free]   {using_dfx_streamer["name"]} (next_fin_phase=={alloc_phase})')

        if debug:
            print(f'  free  pool after : {[d["name"] for d in free_dfx_streamers]}')
            print(f'  using pool after : {[d["name"] for d in using_dfx_streamers]}')

    #############################
    # --- PHASE 3: enlarge gang #
    #############################

    # bug-2 guard: nothing to upgrade if no dfx_streamers were created
    if not dfx_streamers:
        print('[magic-streamer] no dfx_streamers allocated — skipping upgrade loop.')
        return {'dfx_streamers': dfx_streamers, 'total_banks_used': 0}

    if debug:
        print(f'\n[magic-streamer] ───── upgrade loop (budget={total_banks} banks) ─────')
    upgrade_iter = 0
    while True:
        upgrade_iter += 1
        total_banks_used = sum(d['amt_banks_per_entry'] * d['mul_factor'] for d in dfx_streamers)

        if debug:
            print(f'\n  ── iter {upgrade_iter} ──  total_banks_used={total_banks_used}/{total_banks}')
            for d in dfx_streamers:
                cap = d['mul_factor'] * min(s['amt_query_per_bankGrp'] for s in d['streams'])
                print(
                    f'    {d["name"]:<14} mul_factor={d["mul_factor"]:>3} '
                    f'banks={d["amt_banks_per_entry"] * d["mul_factor"]:>4} capacity(Q)={cap}'
                )

        # find the smallest d["mul_factor"] * stream["amt_query_per_bankGrp"]
        upgradable_streamer = min(
            dfx_streamers,
            key=lambda streamer: (
                streamer['mul_factor'] * min(stream['amt_query_per_bankGrp'] for stream in streamer['streams'])
            ),
        )
        banks_delta = upgradable_streamer['amt_banks_per_entry']
        if debug:
            print(f'    -> bottleneck: {upgradable_streamer["name"]} (+{banks_delta} banks if upgraded)')

        # try growing the bottleneck by one bank-group; stop if it would exceed the budget
        if (total_banks_used + banks_delta) > total_banks:
            if debug:
                print(f'    [stop] upgrade would exceed budget ({total_banks_used}+{banks_delta} > {total_banks})')
            break
        upgradable_streamer['mul_factor'] += 1
        if debug:
            print(f'    [upgrade] {upgradable_streamer["name"]}.mul_factor -> {upgradable_streamer["mul_factor"]}')

    # --- show dfx streamr clarification --------------
    outer_border = '  ' + '─' * 92
    inner_border = '      ' + '·' * 86
    print('[magic-streamer] dfx_streamers:')
    print(outer_border)
    print(f'  | {"name":<14} | {"region":>6} | {"amt_banks_per_entry":>19} | {"next_fin_phase":>14} | {"mul_factor":>10} |')
    print(outer_border)
    print(f'      | {"stream":<12} | {"amt_entry_per_query":>19} | {"amt_query_per_bankGrp":>21} | {"total_query":>11} |')
    print(inner_border)
    for d in dfx_streamers:
        print(
            f'  | {d["name"]:<14} | {d["region"]:>6} | {d["amt_banks_per_entry"]:>19} '
            f'| {d["next_fin_phase"]:>14} | {d["mul_factor"]:>10} |'
        )
        print(inner_border)
        for s in d['streams']:
            total_query = d['mul_factor'] * s['amt_query_per_bankGrp']
            print(
                f'      | {s["name"]:<12} | {s["amt_entry_per_query"]:>19} '
                f'| {s["amt_query_per_bankGrp"]:>21} | {total_query:>11} |'
            )
        print(inner_border)
    print(outer_border)

    min_total_query = min(d['mul_factor'] * s['amt_query_per_bankGrp'] for d in dfx_streamers for s in d['streams'])
    print(f'[magic-streamer] lowest total_query across all streams = {min_total_query}')

    return {
        'dfx_streamers': dfx_streamers,
        'total_banks_used': total_banks_used,
        'min_total_query': min_total_query,
    }


    # Example return (2-region halfA streams, total_banks=64, amt_phase=1):
    # {
    #     'dfx_streamers': [
    #         {
    #             'name': 'streamer_1', 'region': 0, 'amt_banks_per_entry': 2,
    #             'next_fin_phase': 1, 'mul_factor': 2,
    #             'streams': [
    #                 {'name': 'ha_bneck', 'shape': (2, 2, 8), 'precision': 16,
    #                  'region': 0, 'alloc_phase': 0, 'free_phase': 1,
    #                  'amt_entry_per_query': 4, 'bits_per_entry': 128,
    #                  'amt_banks_per_entry': 2, 'amt_query_per_bankGrp': 1024},
    #             ],
    #         },
    #         {
    #             'name': 'streamer_2', 'region': 0, 'amt_banks_per_entry': 4,
    #             'next_fin_phase': 1, 'mul_factor': 5,
    #             'streams': [ {'name': 'ha_skip2', ... 'amt_query_per_bankGrp': 256}, ],
    #         },
    #         {
    #             'name': 'streamer_3', 'region': 1, 'amt_banks_per_entry': 2,
    #             'next_fin_phase': 1, 'mul_factor': 20,
    #             'streams': [ {'name': 'ha_skip1', ... 'amt_query_per_bankGrp': 64}, ],
    #         },
    #     ],
    #     'total_banks_used': 64,   # 2*2 + 4*5 + 2*20
    #     'min_total_query': 1280,  # min over all streams of mul_factor * amt_query_per_bankGrp
    # }