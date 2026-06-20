"""streamer-glue mixin: dfx params + user-BD dispatcher TCL (step 4)."""

from hls4ml_con import streamer_glue

from .dfx_params import compute_dfx_params


class GlueMixin:
    """``compute_streamer_glue`` / ``print_streamer_report`` -- step 4."""

    def compute_streamer_glue(self, user_rm_tcl=None, debug=False):
        """Compute the dfx params and stitch the dispatcher TCL (notebook Cell 8).

        Populates ``self.dfx`` (splattable into HwBuildHelper) and ``self.user_rm_tcl``
        (the ``user_rm_build_tcl_path``). Returns ``self.dfx``.
        """
        self.dfx = compute_dfx_params(
            partitions  = self.partitions,
            total_banks = self.total_banks,
            amt_phase   = self.amt_phase,
            num_regions = self.num_regions,
            debug       = debug,
        )
        self.user_rm_tcl = user_rm_tcl or str(self.out_root / 'create_dfx_region_user_bd.tcl')
        streamer_glue.build_dispatcher_tcl(self.partitions, self.user_rm_tcl)
        return self.dfx

    def print_streamer_report(self):
        """Pretty-print the computed dfx streamer/region/rm allocation."""
        if self.dfx is None:
            raise RuntimeError('call compute_streamer_glue() first')
        print('\n=== dfx_streamers (index 0 = DMA) ===')
        for i, s in enumerate(self.dfx['dfx_streamers']):
            print(' ', i, s)
        print('=== dfx_regions ===')
        for r, d in enumerate(self.dfx['dfx_regions']):
            print(' ', r, d)
        print('=== rm_schemetics ===')
        for r, region in enumerate(self.dfx['rm_schemetics']):
            for m, rm in enumerate(region):
                print(f'  region {r} rm {m}: {rm}')
        print('\nuser_rm_build_tcl ->', self.user_rm_tcl)
