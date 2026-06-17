"""DFx4ml FIFO-depth optimization pass.

The stock ``initialize_large_fifos`` filters the layer-output FIFOs down to the
*internal* ones before profiling, on the assumption that there is exactly one
top-level input and one top-level output (the external AXI-Stream/AXI-Master ports
can't be profiled and are implementation dependent). It encodes that assumption by
excluding only ``get_input_variables()[0]`` / ``get_output_variables()[0]``.

The ``VitisUnifiedDFx4ml`` backend emits *multi-port* flat AXI-Stream kernels — one
AXIS port per dfx_streamer — so a model has more than one external input/output. With
the stock filter, every external port past index ``[0]`` leaks into ``vars_to_profile``
and gets mis-treated as an internal FIFO. This pass overrides the filter to exclude
*all* top-level input and output variables; everything else is inherited from the
``vitis_unified`` pass unchanged (the unified project-path layout, the ``_i_U``/``_U``
name cleanup, and the ``get_vitis_hls_exec_dir`` resolution).

Registered as ``vitisunifieddfx4ml:fifo_depth_optimization`` (auto-discovered from this
``passes/`` dir by the backend) — the flow wired up in ``backend.py`` refers to it.
"""

# everything except the multi-port filter comes from the vitis_unified pass, which our
# backend extends — NOT the plain vitis pass (its project path / name cleanup differ).
from hls4ml.backends.vitis_unified.passes.fifo_depth_optimization import (
    FifoDepthOptimization as _VitisUnifiedFifoDepthOptimization,
)
from hls4ml.backends.vitis_unified.passes.fifo_depth_optimization import (
    execute_cosim_to_profile_fifos,
    generate_depths_file,
    get_vitis_optimized_fifo_depths,
    set_optimized_fifo_depths,
)


def initialize_large_fifos(model, profiling_fifo_depth):
    """Set every *internal* FIFO depth to a large value so it can be profiled.

    Same as the stock helper, but excludes **all** top-level input and output
    variables (multi-port flat AXIS kernels have more than one of each) instead of
    only the first one.

    Args:
        model (ModelGraph): The model to which FIFO depth optimization is applied.
        profiling_fifo_depth (int): A large non-negative integer, larger than the max
            expected depth of the FIFOs.

    Returns:
        Dict[str, int]: FIFO names mapped to their initial depths, for later comparison.
    """

    # all external ports (every input + every output) — they are AXI-Stream / AXI-Master
    # connected to other IP and can't be profiled, so keep only the internal FIFOs.
    io_var_names = {var.name for var in model.get_input_variables() + model.get_output_variables()}
    vars_to_profile = {
        output_variable_name: output_variable
        for output_variable_name, output_variable in model.output_vars.items()
        if ('StreamVariable' in str(type(output_variable))) and output_variable.name not in io_var_names
    }

    # bump the internal FIFOs to `profiling_fifo_depth` so they implement in BRAM and
    # get profiled during co-simulation.
    initial_fifo_depths = {}
    for output_variable in vars_to_profile.values():
        if output_variable.pragma:
            initial_fifo_depths[output_variable.name] = int(output_variable.pragma[1])
            output_variable.pragma = (output_variable.pragma[0], profiling_fifo_depth)
    return initial_fifo_depths


class FifoDepthOptimization(_VitisUnifiedFifoDepthOptimization):
    """Multi-port-aware FIFO depth optimization for the dfx4ml backend."""

    def transform(self, model):
        if not isinstance(self.profiling_fifo_depth, int) or self.profiling_fifo_depth <= 0:
            raise ValueError('The FIFO depth for profiling (profiling_fifo_depth variable) must be a non-negative integer.')

        # check axi-stream or io-stream
        if not (model.config.get_config_value('IOType') == 'io_stream'):
            raise RuntimeError('To use this optimization you have to set `IOType` field to `io_stream` in the HLS config.')

        hls_prj_path = model.config.backend.writer.get_vitis_hls_exec_dir(model)

        initial_fifo_depths = initialize_large_fifos(model, self.profiling_fifo_depth)
        execute_cosim_to_profile_fifos(model)
        optimized_fifo_depths = get_vitis_optimized_fifo_depths(model, cus_hls_prj_path=hls_prj_path + '/hls')
        generate_depths_file(model, initial_fifo_depths, optimized_fifo_depths)
        set_optimized_fifo_depths(model, optimized_fifo_depths)

        print('FIFO optimization completed')

        return False
