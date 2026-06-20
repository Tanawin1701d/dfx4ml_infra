"""VitisUnifiedDFx4ml backend.

Subclass of hls4ml's ``VitisUnified`` backend, registered under a new name so the
dfx4ml-specific writer (multi-port flat AXI-Stream kernels + dfx region BD TCL)
is used instead of the stock one. All synthesis / sim / packaging machinery is
inherited unchanged; only the writer flow and the flat config options differ.
"""

from hls4ml.backends import VivadoBackend
from hls4ml.backends.vitis_unified.vitis_unified_backend import VitisUnifiedBackend
from hls4ml.model.flow import register_flow

BACKEND_NAME = 'VitisUnifiedDFx4ml'
_BACKEND_PREFIX = BACKEND_NAME.lower()  # 'vitisunifieddfx4ml'


class VitisUnifiedDFx4mlBackend(VitisUnifiedBackend):
    def __init__(self):
        # Replicate VitisUnifiedBackend.__init__ but with the new name. The
        # super(VivadoBackend, self) hop skips Vitis/Vivado __init__ (so their
        # passes are not re-registered) and lands on FPGABackend.__init__, which
        # binds self.writer = get_writer('VitisUnifiedDFx4ml').
        super(VivadoBackend, self).__init__(name=BACKEND_NAME)
        self._register_layer_attributes()
        self._register_flows()

    def _register_flows(self):
        vitis_ip = 'vitis:ip'
        writer_passes = ['make_stamp', f'{_BACKEND_PREFIX}:write_hls']
        self._writer_flow = register_flow('write', writer_passes, requires=['vitis:ip'], backend=self.name)
        self._default_flow = vitis_ip

        fifo_depth_opt_passes = [f'{_BACKEND_PREFIX}:fifo_depth_optimization'] + writer_passes
        register_flow('fifo_depth_optimization', fifo_depth_opt_passes, requires=['vitis:ip'], backend=self.name)

    def create_initial_config(
        self,
        board='kv260',
        part=None,
        clock_period=5,
        clock_uncertainty='12.5%',
        io_type='io_stream',
        driver='python',
        input_type='float',
        output_type='float',
        in_stream_buf_size=128,
        out_stream_buf_size=128,
        axi_mode='axi_stream',
        input_flat=False,
        output_flat=False,
        package_as_xo=False,
        **kwargs,
    ):
        config = super().create_initial_config(
            board=board,
            part=part,
            clock_period=clock_period,
            clock_uncertainty=clock_uncertainty,
            io_type=io_type,
            driver=driver,
            input_type=input_type,
            output_type=output_type,
            in_stream_buf_size=in_stream_buf_size,
            out_stream_buf_size=out_stream_buf_size,
            axi_mode=axi_mode,
            **kwargs,
        )

        # dfx4ml additions: flat (multi-port) AXIS + ip_catalog packaging.
        config['VitisUnifiedConfig']['input_flat'] = input_flat
        config['VitisUnifiedConfig']['output_flat'] = output_flat
        config['VitisUnifiedConfig']['package_as_xo'] = package_as_xo
        return config
