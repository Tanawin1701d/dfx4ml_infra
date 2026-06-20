"""Conversion mixin: Keras partition -> hls4ml ModelGraph (the 'partial model')."""

import hls4ml


class ConvertMixin:
    """``convert_one`` / ``convert_all`` -- step 1, "get the partial model"."""

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
        hm = hls4ml.converters.convert_from_keras_model(
            model,
            hls_config=cfg,
            output_dir=str(self.out_root / partition.name),
            project_name=partition.project,
            input_flat=partition.input_flat,
            output_flat=partition.output_flat,
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

    def convert_all(self, fifo_opt=False):
        """Convert every partition; returns the {name: ModelGraph} dict."""
        for partition in self.partitions:
            print('=' * 50, 'convert', partition.name)
            self.convert_one(partition, fifo_opt=fifo_opt)
        print('converted:', list(self.hls_models))
        return self.hls_models
