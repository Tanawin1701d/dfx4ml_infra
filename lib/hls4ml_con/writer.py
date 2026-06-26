"""VitisUnifiedDFx4ml writer.

Extends hls4ml's ``VitisUnifiedWriter`` (the Clean submodule base, which is
single-port) with:

* multi-port flat AXI-Stream kernels (one AXIS port per dfx streamer, each with
  TKEEP|TLAST) — ported from the ``VitisUnifiedPartialExp`` branch;
* csim + cosim ("all sim") support for those multi-port flat kernels — the
  bridge and testbench are generated for N inputs / M outputs (the PartialExp
  branch skipped sim for flat kernels);
* ip_catalog packaging (``package_as_xo=False``);
* a per-model ``create_dfx_region_user_bd`` TCL fragment (see :mod:`tcl_gen`)
  that lets the kernel drop into the dfx4ml reconfigurable region.

Templates that this writer modifies (``myproject_axi_stream.cpp`` / ``.h``,
``nnet_helpers_dfx.h`` and ``hls_kernel_config.cfg`` — the latter flips
``syn.schedule.enable_dsp_full_reg`` on and binds ``mul`` to DSP) are shipped
under ``templates/vitis_unified`` next to this file; unchanged templates (bridge,
testbench, linker) are read from the base hls4ml package.
"""

import os
import shutil

import hls4ml.writer.vitis_unified_writer as _vu_mod
from hls4ml.writer.vitis_unified_writer import VitisUnifiedWriter

from . import tcl_gen

_DFX_TPL_DIR = os.path.join(os.path.dirname(os.path.abspath(__file__)), 'templates', 'vitis_unified')
_BASE_TPL_DIR = os.path.join(os.path.dirname(os.path.abspath(_vu_mod.__file__)), '..', 'templates', 'vitis_unified')


class VitisUnifiedDFx4mlWriter(VitisUnifiedWriter):

    # ------------------------------------------------------------------ #
    # flat / packaging config (read straight from the config dict so we do
    # not depend on a flat-aware VitisUnifiedConfig subclass)
    # ------------------------------------------------------------------ #
    def _vu_cfg(self):
        return self.vitis_unified_config.config['VitisUnifiedConfig']

    def _is_axi_flat_input(self):
        assert self._is_axi_stream(), "axi_mode must be 'axi_stream' to use input_flat"
        return bool(self._vu_cfg().get('input_flat', False))

    def _is_axi_flat_output(self):
        assert self._is_axi_stream(), "axi_mode must be 'axi_stream' to use output_flat"
        return bool(self._vu_cfg().get('output_flat', False))

    def _stream_depth(self, ports, cfg_key, i):
        """FIFO depth for the i-th model stream port.

        Use the user-configured ``in_stream_depths`` / ``out_stream_depths`` entry when
        one is given (a per-port list in the config); otherwise fall back to the depth
        hls4ml stamped on the variable's stream pragma (``pragma == ('stream', depth)``).
        """
        depths = self._vu_cfg().get(cfg_key) or []
        if i < len(depths) and depths[i] is not None:
            return depths[i]
        return ports[i].pragma[1]

    def _get_package_as_xo(self):
        return bool(self._vu_cfg().get('package_as_xo', False))

    # ------------------------------------------------------------------ #
    # name / type helpers (ported from PartialExp)
    # ------------------------------------------------------------------ #
    def _get_axis_model_stream_name(self, is_input, idx):
        return f'model_{"input" if is_input else "output"}_stream_{idx}'

    def _get_axis_axi_port_name(self, is_input, idx):
        return f'axi_{"input" if is_input else "output"}_stream_{idx}'

    def _get_dma_float_type_name(self):
        return 'dma_data_packet'

    def _port_packet_type(self, is_input, idx, is_flat):
        if is_flat:
            return f'dma_{"input" if is_input else "output"}_flat_data_packet_{idx}'
        return self._get_dma_float_type_name()

    # ================================================================== #
    # kernel config: choose ip_catalog vs xo
    # ================================================================== #
    def _write_hls_kernel_config(self, model, is_csim=False):
        suffix = 'csim' if is_csim else 'cosim'
        kernel_type = 'xo' if self._get_package_as_xo() else 'ip_catalog'
        with (
            open(os.path.join(_DFX_TPL_DIR, 'hls_kernel_config.cfg')) as fin,
            open(f'{model.config.get_output_dir()}/hls_kernel_config_{suffix}.cfg', 'w') as fout,
        ):
            for line in fin.readlines():
                if '{PART}' in line:
                    line = line.replace('{PART}', model.config.get_config_value('Part'))
                if '{CLK}' in line:
                    line = line.replace('{CLK}', model.config.get_config_value('ClockPeriod'))
                if '{CLK_UC}' in line:
                    line = line.replace('{CLK_UC}', model.config.get_config_value('ClockUncertainty'))
                if '{OUTDIR}' in line:
                    line = line.replace('{OUTDIR}', model.config.get_output_dir())
                if '{TOP_NAME}' in line:
                    line = line.replace('{TOP_NAME}', self._get_top_wrap_func_name(model, self._is_axi_master()))
                if '{FILE_NAME_WRAP}' in line:
                    line = line.replace('{FILE_NAME_WRAP}', self._get_wrapper_file_name(model, self._is_axi_master()))
                if '{SIM_FILE_NAME}' in line:
                    line = line.replace('{SIM_FILE_NAME}', self._get_sim_file_name())
                if '{FILE_NAME_BASE}' in line:
                    line = line.replace('{FILE_NAME_BASE}', self._get_project_name(model))
                if '{OUTPUT_KERNEL_TYPE}' in line:
                    line = line.replace('{OUTPUT_KERNEL_TYPE}', kernel_type)
                if '{ENABLE_FIFO_SIZING}' in line:
                    line = line.replace('{ENABLE_FIFO_SIZING}', 'false')
                if is_csim and (('enable_fifo_sizing' in line) or ('-DRTL_SIM' in line)):
                    line = '#' + line
                fout.write(line)

    # ================================================================== #
    # AXIS wrapper: multi-port flat (ported from PartialExp)
    # ================================================================== #
    def _write_wrapper_axis(self, model):
        inp_gmem_t, out_gmem_t, inputs, outputs = self.vitis_unified_config.get_corrected_types()
        is_flat_in = self._is_axi_flat_input()
        is_flat_out = self._is_axi_flat_output()

        if not is_flat_in and len(inputs) != 1:
            raise ValueError(f'AXIS wrapper requires exactly 1 input when input_flat=False. Found {len(inputs)}.')
        if not is_flat_out and len(outputs) != 1:
            raise ValueError(f'AXIS wrapper requires exactly 1 output when output_flat=False. Found {len(outputs)}.')

        indent = '    '

        in_dma_types = [self._port_packet_type(True, i, is_flat_in) for i in range(len(inputs))]
        out_dma_types = [self._port_packet_type(False, i, is_flat_out) for i in range(len(outputs))]

        axi_in_ports = [self._get_axis_axi_port_name(True, i) for i in range(len(inputs))]
        axi_out_ports = [self._get_axis_axi_port_name(False, i) for i in range(len(outputs))]
        model_in_streams = [self._get_axis_model_stream_name(True, i) for i in range(len(inputs))]
        model_out_streams = [self._get_axis_model_stream_name(False, i) for i in range(len(outputs))]
        all_model_streams = model_in_streams + model_out_streams

        top_func_name = self._get_top_wrap_func_name(model, False)
        sig_params = [f'hls::stream<{in_dma_types[i]}> &{axi_in_ports[i]}' for i in range(len(inputs))] + [
            f'hls::stream<{out_dma_types[i]}> &{axi_out_ports[i]}' for i in range(len(outputs))
        ]
        sig_body = ',\n'.join(f'{indent}{p}' for p in sig_params)
        top_func_decl_cpp = f'void {top_func_name}(\n{sig_body},\n{indent}int batch_size) {{\n'
        top_func_decl_h = f'void {top_func_name}(\n{sig_body},\n{indent}int batch_size);\n'

        compute_streams_str = ', '.join(all_model_streams)
        compute_call_args_str = compute_streams_str + ', batch_size'

        if is_flat_in:
            load_calls = ''.join(
                f'{indent}load_input_flat<N_IN_{i}>({axi_in_ports[i]}, {model_in_streams[i]}, batch_size);\n'
                for i in range(len(inputs))
            )
        else:
            load_calls = f'{indent}load_input({axi_in_ports[0]}, {model_in_streams[0]}, batch_size);\n'

        if is_flat_out:
            store_calls = ''.join(
                f'{indent}store_result_flat<N_OUT_{i}>({model_out_streams[i]}, {axi_out_ports[i]}, batch_size);\n'
                for i in range(len(outputs))
            )
        else:
            store_calls = f'{indent}store_result({model_out_streams[0]}, {axi_out_ports[0]}, batch_size);\n'

        # ---- .cpp ----
        with (
            open(os.path.join(_DFX_TPL_DIR, 'myproject_axi_stream.cpp')) as fin,
            open(f'{model.config.get_output_dir()}/firmware/{self._get_project_name(model)}_axi_stream.cpp', 'w') as fout,
        ):
            for line in fin.readlines():
                newline = line
                if 'MY_PROJECT(' in newline:
                    newline = newline.replace('MY_PROJECT', self._get_project_name(model))
                if '// hls-fpga-machine-learning insert include' in newline:
                    newline = f'#include "{self._get_project_name(model)}_axi_stream.h"\n'
                if '// hls-fpga-machine-learning insert top-func-decl' in newline:
                    newline = top_func_decl_cpp
                if '// hls-fpga-machine-learning insert interface' in newline:
                    newline = ''.join(f'{indent}#pragma HLS INTERFACE axis port={p}\n' for p in axi_in_ports + axi_out_ports)
                    newline += (
                        f'{indent}#pragma HLS INTERFACE s_axilite port=return bundle=control\n'
                        f'{indent}#pragma HLS INTERFACE s_axilite port=batch_size bundle=control\n'
                    )
                if '// hls-fpga-machine-learning insert stream decl' in newline:
                    newline = ''
                    for i, inp in enumerate(inputs):
                        newline += (
                            f'{indent}static hls::stream<{inp.type.name}> {model_in_streams[i]}("{model_in_streams[i]}");\n'
                        )
                    for i, out in enumerate(outputs):
                        newline += (
                            f'{indent}static hls::stream<{out.type.name}> {model_out_streams[i]}("{model_out_streams[i]}");\n'
                        )
                    newline += '\n'
                    for i in range(len(inputs)):
                        depth = self._stream_depth(inputs, 'in_stream_depths', i)
                        newline += f'{indent}#pragma HLS STREAM variable={model_in_streams[i]} depth={depth}\n'
                    for i in range(len(outputs)):
                        depth = self._stream_depth(outputs, 'out_stream_depths', i)
                        newline += f'{indent}#pragma HLS STREAM variable={model_out_streams[i]} depth={depth}\n'
                if '// hls-fpga-machine-learning insert stream parameter' in newline:
                    stream_params = ', '.join(
                        [f'hls::stream<{inp.type.name}> &{model_in_streams[i]}' for i, inp in enumerate(inputs)]
                        + [f'hls::stream<{out.type.name}> &{model_out_streams[i]}' for i, out in enumerate(outputs)]
                    )
                    newline = newline.replace('// hls-fpga-machine-learning insert stream parameter', stream_params)
                if '// hls-fpga-machine-learning insert compute-streams' in newline:
                    newline = newline.replace('// hls-fpga-machine-learning insert compute-streams', compute_streams_str)
                if '// hls-fpga-machine-learning insert load-calls' in newline:
                    newline = load_calls
                if '// hls-fpga-machine-learning insert compute-call-args' in newline:
                    newline = newline.replace('// hls-fpga-machine-learning insert compute-call-args', compute_call_args_str)
                if '// hls-fpga-machine-learning insert store-calls' in newline:
                    newline = store_calls
                if 'INPUT_LAYER_TYPE' in newline:
                    newline = newline.replace('INPUT_LAYER_TYPE', inputs[0].type.name)
                if 'OUTPUT_LAYER_TYPE' in newline:
                    newline = newline.replace('OUTPUT_LAYER_TYPE', outputs[0].type.name)
                if 'OUTPUT_GMEM_TYPE' in newline:
                    newline = newline.replace('OUTPUT_GMEM_TYPE', out_gmem_t)
                fout.write(newline)

        # ---- .h ----
        with (
            open(os.path.join(_DFX_TPL_DIR, 'myproject_axi_stream.h')) as fin,
            open(f'{model.config.get_output_dir()}/firmware/{self._get_project_name(model)}_axi_stream.h', 'w') as fout,
        ):
            for line in fin.readlines():
                newline = line
                if 'MYPROJECT' in newline:
                    newline = newline.replace('MYPROJECT', self._get_project_name(model).upper())
                if '// hls-fpga-machine-learning insert include' in newline:
                    newline = f'#include "{self._get_project_name(model)}.h"\n#include "ap_axi_sdata.h"\n'
                if '// hls-fpga-machine-learning insert definitions' in newline:
                    newline = ''
                    for i, inp in enumerate(inputs):
                        newline += f'static const unsigned N_IN_{i} = {inp.size()};\n'
                    for i, out in enumerate(outputs):
                        newline += f'static const unsigned N_OUT_{i} = {out.size()};\n'
                    newline += (
                        f'typedef hls::axis<{inp_gmem_t}, 0, 0, 0, '
                        f'(AXIS_ENABLE_KEEP | AXIS_ENABLE_LAST)> {self._get_dma_float_type_name()};\n'
                    )
                    for i, inp in enumerate(inputs):
                        newline += (
                            f'typedef hls::axis<{inp.type.name}, 0, 0, 0, '
                            f'(AXIS_ENABLE_KEEP | AXIS_ENABLE_LAST)> dma_input_flat_data_packet_{i};\n'
                        )
                    for i, out in enumerate(outputs):
                        newline += (
                            f'typedef hls::axis<{out.type.name}, 0, 0, 0, '
                            f'(AXIS_ENABLE_KEEP | AXIS_ENABLE_LAST)> dma_output_flat_data_packet_{i};\n'
                        )
                if '// hls-fpga-machine-learning insert top-func-decl-h' in newline:
                    newline = top_func_decl_h
                fout.write(newline)

    # ================================================================== #
    # Bridge (csim): multi-port flat-aware
    # ================================================================== #
    def write_bridge(self, model):
        with (
            open(os.path.join(_BASE_TPL_DIR, 'myproject_bridge.cpp')) as fin,
            open(f'{model.config.get_output_dir()}/{model.config.get_project_name()}_bridge.cpp', 'w') as fout,
        ):
            model_inputs = model.get_input_variables()
            model_outputs = model.get_output_variables()
            model_brams = [var for var in model.get_weight_variables() if var.storage.lower() == 'bram']
            indent = '    '
            is_flat_in = self._is_axi_flat_input()
            is_flat_out = self._is_axi_flat_output()

            for line in fin.readlines():
                if 'MYPROJECT' in line:
                    newline = line.replace('MYPROJECT', self._get_project_name(model).upper())
                elif 'myproject' in line:
                    newline = line.replace('myproject', self._get_project_name(model))
                elif 'PROJECT_FILE_NAME' in line:
                    newline = line.replace('PROJECT_FILE_NAME', self._get_wrapper_file_name(model, self._is_axi_master()))
                elif '#include "firmware/nnet_utils/nnet_helpers.h"' in line:
                    newline = line + '#include "firmware/nnet_utils/nnet_helpers_dfx.h"\n'
                elif '// hls-fpga-machine-learning insert bram' in line:
                    newline = line
                    for bram in model_brams:
                        newline += f'#include "firmware/weights/{bram.name}.h"\n'
                elif '// hls-fpga-machine-learning insert header' in line:
                    dtype = line.split('#', 1)[1].strip()
                    input_ios = [
                        f'{dtype} {self._get_io_port_name(inp, True, idx)}[{inp.size_cpp()}]'
                        for idx, inp in enumerate(model_inputs)
                    ]
                    output_ios = [
                        f'{dtype} {self._get_io_port_name(out, False, idx)}[{out.size_cpp()}]'
                        for idx, out in enumerate(model_outputs)
                    ]
                    newline = indent + ', '.join(input_ios) + ',\n'
                    newline += indent + ', '.join(output_ios) + '\n'
                elif '// hls-fpga-machine-learning insert wrapper' in line:
                    dtype = line.split('#', 1)[1].strip()
                    newline = ''
                    if dtype == self.vitis_unified_config.get_input_type():
                        if self._is_axi_master():
                            input_vars = [self._get_io_port_name(inp, True, idx) for idx, inp in enumerate(model_inputs)]
                            output_vars = [self._get_io_port_name(out, False, idx) for idx, out in enumerate(model_outputs)]
                            newline += indent + self._get_top_wrap_func_name(model, True) + '(\n'
                            newline += indent + ', '.join(input_vars) + ',\n'
                            newline += indent + ', '.join(output_vars) + ',\n'
                            newline += indent + '1);\n'
                        else:
                            newline += self._gen_bridge_axis_wrapper(
                                model, model_inputs, model_outputs, is_flat_in, is_flat_out, indent
                            )
                elif '// hls-fpga-machine-learning insert trace_outputs' in line:
                    newline = ''
                    for layer in model.get_layers():
                        func = layer.get_attr('function_cpp', None)
                        if func and model.config.trace_output and layer.get_attr('trace', False):
                            for var in layer.get_variables():
                                newline += (
                                    indent
                                    + 'nnet::trace_outputs->insert(std::pair<std::string, void *>('
                                    + f'"{layer.name}", (void *) malloc({var.size_cpp()} * element_size)));\n'
                                )
                elif '// hls-fpga-machine-learning insert namespace' in line:
                    newline = ''
                    namespace = model.config.get_writer_config().get('Namespace', None)
                    if namespace is not None:
                        newline += indent + f'using namespace {namespace};\n'
                else:
                    newline = line
                fout.write(newline)

    def _gen_bridge_axis_wrapper(self, model, model_inputs, model_outputs, is_flat_in, is_flat_out, indent):
        """Body of the float bridge wrapper: drive/drain N input / M output AXIS ports."""
        out = ''
        in_streams = []
        out_streams = []
        # declare + fill input AXIS streams from float arrays
        for i, inp in enumerate(model_inputs):
            ptype = self._port_packet_type(True, i, is_flat_in)
            sname = self._get_io_port_name(inp, True, i) + '_ap'
            fname = self._get_io_port_name(inp, True, i)
            in_streams.append(sname)
            out += indent + f'hls::stream<{ptype}> {sname};\n'
            if is_flat_in:
                out += indent + (
                    f'nnet::convert_data_axis_flat<{ptype}, {inp.type.name}, N_IN_{i}>({fname}, {sname});\n'
                )
            else:
                out += indent + f'nnet::convert_data_axis<float, float, N_IN_{i}>({fname}, {sname});\n'
        # declare output AXIS streams
        for j, outv in enumerate(model_outputs):
            ptype = self._port_packet_type(False, j, is_flat_out)
            sname = self._get_io_port_name(outv, False, j) + '_ap'
            out_streams.append(sname)
            out += indent + f'hls::stream<{ptype}> {sname};\n'
        # call the kernel
        call_args = ', '.join(in_streams + out_streams + ['1'])
        out += indent + f'{self._get_top_wrap_func_name(model, False)}({call_args});\n'
        # drain outputs back to float arrays
        for j, outv in enumerate(model_outputs):
            ptype = self._port_packet_type(False, j, is_flat_out)
            sname = self._get_io_port_name(outv, False, j) + '_ap'
            fname = self._get_io_port_name(outv, False, j)
            if is_flat_out:
                out += indent + (
                    f'nnet::convert_data_axis_flat<{ptype}, {outv.type.name}, N_OUT_{j}>({sname}, {fname});\n'
                )
            else:
                out += indent + f'nnet::convert_data_axis<float, float, N_OUT_{j}>({sname}, {fname});\n'
        return out

    # ================================================================== #
    # Testbench (cosim): multi-port flat-aware
    # ================================================================== #
    def write_wrapper_test(self, model):
        if self._is_axi_master():
            return super().write_wrapper_test(model)

        model_inputs = model.get_input_variables()
        model_outputs = model.get_output_variables()
        model_brams = [var for var in model.get_weight_variables() if var.storage.lower() == 'bram']
        is_flat_in = self._is_axi_flat_input()
        is_flat_out = self._is_axi_flat_output()

        in_stream_names = [f'tb_in_{i}' for i in range(len(model_inputs))]
        out_stream_names = [f'tb_out_{j}' for j in range(len(model_outputs))]

        with (
            open(os.path.join(_BASE_TPL_DIR, 'myproject_test.cpp')) as fin,
            open(f'{model.config.get_output_dir()}/{self._get_sim_file_name()}.cpp', 'w') as fout,
        ):
            self.vitis_unified_config.get_corrected_types()
            fout.write('//// generated by VitisUnifiedDFx4ml Backend\n')

            for line in fin.readlines():
                indent = ' ' * (len(line) - len(line.lstrip(' ')))
                if 'myproject' in line:
                    newline = line.replace('myproject', self._get_project_name(model))
                elif '// hls-fpga-machine-learning insert include' in line:
                    newline = line + f'#include "firmware/{self._get_wrapper_file_name(model, False)}.h"\n'
                elif '#include "firmware/nnet_utils/nnet_helpers.h"' in line:
                    newline = line + '#include "firmware/nnet_utils/nnet_helpers_dfx.h"\n'
                elif '// hls-fpga-machine-learning insert bram' in line:
                    newline = line
                    for bram in model_brams:
                        newline += f'#include "firmware/weights/{bram.name}.h"\n'
                elif '// hls-fpga-machine-learning insert data' in line:
                    newline = line + self._gen_tb_input_decls(
                        model_inputs, in_stream_names, is_flat_in, 3 * indent, from_vector=True
                    )
                    newline += self._gen_tb_output_decls(model_outputs, out_stream_names, is_flat_out, 3 * indent)
                elif '// hls-fpga-machine-learning insert zero' in line:
                    newline = line + self._gen_tb_input_decls(
                        model_inputs, in_stream_names, is_flat_in, 3 * indent, from_vector=False
                    )
                    newline += self._gen_tb_output_decls(model_outputs, out_stream_names, is_flat_out, 3 * indent)
                elif '// hls-fpga-machine-learning insert top-level-function' in line:
                    call_args = ', '.join(in_stream_names + out_stream_names + ['1'])
                    newline = line + indent + f'{self._get_top_wrap_func_name(model, False)}({call_args});\n'
                elif '// hls-fpga-machine-learning insert predictions' in line:
                    newline = line
                    for out in model_outputs:
                        newline += indent + f'for(int i = 0; i < {out.size()}; i++) {{\n'
                        newline += indent + '  std::cout << pr[i] << " ";\n'
                        newline += indent + '}\n'
                        newline += indent + 'std::cout << std::endl;\n'
                elif '// hls-fpga-machine-learning insert tb-output' in line:
                    newline = line
                    tb_stream = model.config.get_writer_config().get('TBOutputStream', 'both')
                    if tb_stream != 'stdout':
                        newline += self._gen_tb_output_print(model_outputs, out_stream_names, is_flat_out, indent, 'fout', 'false')
                elif ('// hls-fpga-machine-learning insert output' in line) or (
                    '// hls-fpga-machine-learning insert quantized' in line
                ):
                    newline = line
                    tb_stream = model.config.get_writer_config().get('TBOutputStream', 'both')
                    keep_output = str(tb_stream != 'stdout').lower()
                    if tb_stream != 'file':
                        newline += self._gen_tb_output_print(
                            model_outputs, out_stream_names, is_flat_out, indent, 'std::cout', keep_output
                        )
                elif '// hls-fpga-machine-learning insert namespace' in line:
                    newline = ''
                    namespace = model.config.get_writer_config().get('Namespace', None)
                    if namespace is not None:
                        newline += indent + f'using namespace {namespace};\n'
                else:
                    newline = line
                fout.write(newline)

    def _gen_tb_input_decls(self, model_inputs, in_stream_names, is_flat_in, indent, from_vector):
        """Declare + fill input AXIS streams (from the ``in`` vector or with zeros)."""
        out = ''
        offset = 0
        for i, inp in enumerate(model_inputs):
            ptype = self._port_packet_type(True, i, is_flat_in)
            sname = in_stream_names[i]
            out += indent + f'hls::stream<{ptype}> {sname};\n'
            if not from_vector:
                if is_flat_in:
                    out += indent + f'nnet::fill_zero_axis_flat<{ptype}, {inp.type.name}, N_IN_{i}>({sname});\n'
                else:
                    out += indent + f'nnet::fill_zero_axi<{ptype}, N_IN_{i}>({sname}, false);\n'
            else:
                if is_flat_in:
                    out += indent + (
                        f'nnet::convert_data_axis_flat<{ptype}, {inp.type.name}, N_IN_{i}>(&in[{offset}], {sname});\n'
                    )
                else:
                    # non-flat is always a single input (offset 0); use the vector overload
                    out += indent + f'nnet::convert_data_axis<float, float, N_IN_{i}>(in, {sname});\n'
            offset += inp.size()
        return out

    def _gen_tb_output_decls(self, model_outputs, out_stream_names, is_flat_out, indent):
        out = ''
        for j, outv in enumerate(model_outputs):
            ptype = self._port_packet_type(False, j, is_flat_out)
            out += indent + f'hls::stream<{ptype}> {out_stream_names[j]};\n'
        return out

    def _gen_tb_output_print(self, model_outputs, out_stream_names, is_flat_out, indent, dest, keep):
        out = ''
        for j, outv in enumerate(model_outputs):
            ptype = self._port_packet_type(False, j, is_flat_out)
            sname = out_stream_names[j]
            if is_flat_out:
                out += indent + (
                    f'nnet::print_result_axis_flat<{ptype}, {outv.type.name}, N_OUT_{j}>({sname}, {dest}, {keep});\n'
                )
            else:
                out += indent + f'nnet::print_result_axis<{ptype}, N_OUT_{j}>({sname}, {dest}, {keep});\n'
        return out

    # ================================================================== #
    # Main entrypoint
    # ================================================================== #
    def write_hls(self, model, is_multigraph=False):
        super().write_hls(model, is_multigraph=is_multigraph)
        self._install_dfx_sim_headers(model)
        self._patch_nnet_helpers_keeplast(model)
        # self._patch_nnet_dense_resource_lutram(model)
        self._write_dfx_region_fragment(model)

    def _install_dfx_sim_headers(self, model):
        """Copy the flat AXIS converter header into the generated firmware tree."""
        dst_dir = os.path.join(model.config.get_output_dir(), 'firmware', 'nnet_utils')
        os.makedirs(dst_dir, exist_ok=True)
        shutil.copy2(os.path.join(_DFX_TPL_DIR, 'nnet_helpers_dfx.h'), os.path.join(dst_dir, 'nnet_helpers_dfx.h'))

    def _patch_nnet_helpers_keeplast(self, model):
        """Enable TKEEP|TLAST (flags=24) on the float AXIS packet in convert_data_axis.

        The dfx region requires TKEEP/TLAST on every AXIS port, so the float
        (DMA) packet typedef uses ``hls::axis<float,0,0,0,(KEEP|LAST)>``. The
        stock convert_data_axis helpers use ``hls::axis<float,0,0,0>``; patch the
        copied header so the non-flat bridge/test path type-matches the wrapper.
        """
        path = os.path.join(model.config.get_output_dir(), 'firmware', 'nnet_utils', 'nnet_helpers.h')
        if not os.path.exists(path):
            return
        with open(path) as f:
            content = f.read()
        patched = content.replace('hls::axis<float, 0, 0, 0>', 'hls::axis<float, 0, 0, 0, 24>')
        if patched != content:
            with open(path, 'w') as f:
                f.write(patched)

    def _patch_nnet_dense_resource_lutram(self, model):
        """Map the weight ROM to LUTRAM instead of BRAM for reuse_factor > 1.

        The stock dense_resource template pins the weight array to
        ``ROM_nP_BRAM`` when reuse_factor > 1; on a dfx region the BRAM budget is
        tight, so patch the copied firmware header to use ``ROM_1P_LUTRAM``
        instead. Patches all three dense_resource specializations.
        """
        path = os.path.join(model.config.get_output_dir(), 'firmware', 'nnet_utils', 'nnet_dense_resource.h')
        if not os.path.exists(path):
            return
        with open(path) as f:
            content = f.read()
        if 'ROM_1P_LUTRAM' in content:  # already patched (e.g. fifo re-convert) — replacement is not idempotent
            return
        patched = content.replace(
            '#pragma HLS RESOURCE variable=weights core=ROM_nP_BRAM',
            '// #pragma HLS RESOURCE variable=weights core=ROM_nP_BRAM\n'
            '        #pragma HLS RESOURCE variable=weights core=ROM_1P_LUTRAM',
        )
        if patched != content:
            with open(path, 'w') as f:
                f.write(patched)

    def _write_dfx_region_fragment(self, model):
        """Emit this model's (block_name → kernel VLNV) fragment for the dfx region BD.

        Region/RM placement is provided by the streamer-glue step via the writer
        config keys ``dfx_region_idx`` / ``dfx_rm_idx``; when absent the fragment
        is still written with a best-effort block name so a single-region build
        works out of the box.
        """
        cfg = self._vu_cfg()
        region_idx = cfg.get('dfx_region_idx', 0)
        rm_idx = cfg.get('dfx_rm_idx', 0)
        block_name = f'dfx_pr_region_{region_idx}_rm_{rm_idx}'
        fragment = tcl_gen.make_fragment(block_name, self._get_project_name(model))
        frag_path = os.path.join(model.config.get_output_dir(), 'dfx_region_user_bd.fragment.tcl')
        with open(frag_path, 'w') as f:
            f.write(fragment)
