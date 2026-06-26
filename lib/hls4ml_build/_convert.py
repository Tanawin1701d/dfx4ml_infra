"""Conversion mixin: Keras partition -> hls4ml ModelGraph (the 'partial model')."""

import hls4ml

from .topology import DMA


class ConvertMixin:
    """``convert_one`` / ``convert_all`` -- step 1, "get the partial model"."""

    def _stream_depths(self, partition):
        """Per-port hls::stream FIFO depths for a partition's inputs / outputs.

        Depth is a property of the ``Stream`` itself, so an input port reuses the depth
        declared on the matching produced stream (looked up by name). ``DMA`` ports and
        streams that leave ``depth=None`` yield ``None`` -> the writer falls back to the
        depth hls4ml stamps on the stream pragma.
        """
        by_name = {s.name: s.depth for s in self.streams}
        in_depths = [None if inp == DMA else by_name.get(inp) for inp in partition.inputs]
        out_depths = [None if isinstance(o, str) else o.depth for o in partition.outputs]
        return in_depths, out_depths

    def _cfg(self, model):
        """Build the hls4ml config for one partition model (notebook _cfg)."""
        c = hls4ml.utils.config_from_keras_model(model, granularity='name')
        c['Model']['Strategy'] = self.strategy
        c['Model']['ReuseFactor'] = self.reuse_factor
        c['Model']['Precision'] = self.precision
        return c

    def convert_one(self, partition, fifo_opt=False):
        """Convert a single partition to an hls4ml ModelGraph and write its firmware.

        ``fifo_opt=True`` enables the per-partition fifo_depth_optimization flow.
        """
        model = partition.model
        cfg = self._cfg(model)
        if fifo_opt:
            cfg['Flows'] = ['vitisunifieddfx4ml:fifo_depth_optimization']
        in_depths, out_depths = self._stream_depths(partition)
        # During the fifo_depth_optimization flow let hls4ml manage the FIFO depths: the
        # cosim profiles the *internal* FIFOs and our configured IO depths would only
        # perturb that. The IO depths are re-stamped afterwards (apply_io_stream_depths),
        # so the profiling run is converted with the natural (pragma) IO depths.
        conv_in_depths  = None if fifo_opt else in_depths
        conv_out_depths = None if fifo_opt else out_depths
        hm = hls4ml.converters.convert_from_keras_model(
            model,
            hls_config=cfg,
            output_dir=str(self.out_root / partition.name),
            project_name=partition.project,
            input_flat=partition.input_flat,
            output_flat=partition.output_flat,
            in_stream_depths=conv_in_depths,
            out_stream_depths=conv_out_depths,
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
        hm.write()
        self.hls_models[partition.name] = hm
        return hm

    def apply_io_stream_depths(self, partition, hm=None):
        """Re-stamp the partition's configured IO stream depths and re-emit the firmware.

        Used after a ``convert_one(..., fifo_opt=True)`` run: the fifo_depth_optimization
        flow has set the *internal* FIFO depths (stored on the layer pragmas) but left the
        IO ports at their natural depths. Writing our configured IO depths into the unified
        config and re-running the writer flow regenerates the firmware with **our IO depths
        and the optimized internal FIFO depths** -- the AXIS wrapper reads the IO depths
        from config (writer ``_stream_depth``) while the internal layer FIFOs keep the
        depths the optimization stamped on their pragmas. No cosim is re-run.
        """
        hm = hm or self.hls_models[partition.name]
        in_depths, out_depths = self._stream_depths(partition)
        vu = hm.config.config['VitisUnifiedConfig']
        vu['in_stream_depths']  = in_depths
        vu['out_stream_depths'] = out_depths
        hm.write()
        return hm

    def convert_all(self, fifo_opt=False):
        """Convert every partition; returns the {name: ModelGraph} dict."""
        for partition in self.partitions:
            print('=' * 50, 'convert', partition.name)
            self.convert_one(partition, fifo_opt=fifo_opt)
        print('converted:', list(self.hls_models))
        return self.hls_models
