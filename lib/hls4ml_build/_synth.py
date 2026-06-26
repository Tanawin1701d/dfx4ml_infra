"""synthesis mixin: C-synthesis + ip_catalog package, with/without FIFO-depth opt."""


class SynthMixin:
    """``synth_partition`` / ``synth_all`` -- step 3."""

    def synth_partition(self, name, csim=False, log_to_stdout=True):
        """C-synthesize + package one partition as an ip_catalog IP (notebook Cell 9)."""
        if name not in self.hls_models:
            raise RuntimeError(
                f"partition '{name}' not converted yet -- "
                f"call convert_all() before synth_all(fifo_opt=False)"
            )
        return self.hls_models[name].build(synth=True, csim=csim, cosim=False, log_to_stdout=log_to_stdout)

    def synth_all(self, fifo_opt=False, log_to_stdout=True):
        """Synthesize + package every partition.

        ``fifo_opt=False`` synthesizes each already-converted partition.
        ``fifo_opt=True`` re-converts each partition with the fifo_depth_optimization flow
        and rebuilds it (the flow owns the optimization, so ``build(fifo_opt=False)`` avoids
        a redundant second pass) -- notebook Cell 10. The optimization is left to manage the
        FIFO depths during conversion; afterwards the configured IO stream depths are
        re-stamped (``apply_io_stream_depths``) so the built model keeps the optimized
        *internal* FIFO depths but uses *our* IO depths.
        """
        for partition in self.partitions:
            print('=' * 50, ('fifo-opt' if fifo_opt else 'synth'), partition.name)
            if fifo_opt:
                hm = self.convert_one(partition, fifo_opt=True)
                self.apply_io_stream_depths(partition, hm)
                hm.build(synth=True, fifo_opt=False, log_to_stdout=log_to_stdout)
            else:
                self.synth_partition(partition.name, log_to_stdout=log_to_stdout)
        print('synthesis done' + (' (fifo-optimized)' if fifo_opt else ''))
        return self.hls_models
