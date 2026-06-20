"""dfx_region user-BD TCL generation for the VitisUnifiedDFx4ml backend.

dfx4ml's top build (``hw/bd_src/dfx4ml/dfx4ml.tcl``) calls, once per (region, rm)::

    create_dfx_region_user_bd $parentCell $block_name $clk_frq \
        $interface_widths $rm_config "" $m

when ``test_mode == 0``. That proc is the user's responsibility (it is undefined
in the repo). This module generates it.

The generated proc mirrors the test-mode reference
``hw/bd_src/dfx_region/dfx_region.tcl:create_dfx_region_bd`` but, instead of the
``Stream_Single_S2M`` passthrough, instantiates the hls4ml kernel IP packaged by
this backend (``package_as_xo=False`` → ip_catalog, VLNV
``xilinx.com:hls:<project>_axi_stream:1.0``) and wires each kernel AXI-Stream
port to the matching region streamer port.

Because the user proc is called per (region, rm) but every RM loads a *different*
kernel, a single dispatcher proc resolves the kernel VLNV from ``block_name`` via
a generated lookup table (``_DFX4ML_KERNEL_VLNV``). Each converted hls4ml model
contributes one fragment (its block_name → VLNV mapping); :func:`stitch_dispatcher`
concatenates the fragments and appends the static proc to produce the single TCL
file passed to ``HwBuildHelper`` as ``user_rm_build_tcl_path``.
"""

import os

# kernel port / interface names produced by the VitisUnifiedDFx4ml writer
KERNEL_INST_NAME = 'kernel_0'
KERNEL_CLK_PIN = 'ap_clk'
KERNEL_RST_PIN = 'ap_rst_n'  # active-low, matches dfx region `nreset`
KERNEL_CTRL_BUSIF = 's_axi_control'


def kernel_vlnv(project_name, vendor='xilinx.com', library='hls', version='1.0'):
    """VLNV of the ip_catalog package emitted by Vitis HLS for ``project_name``.

    The packaged top function is ``<project>_axi_stream`` (see the writer's
    ``_get_top_wrap_func_name``), and Vitis HLS ip_catalog packaging uses
    vendor ``xilinx.com`` / library ``hls``.
    """
    return f'{vendor}:{library}:{project_name}_axi_stream:{version}'


def make_fragment(block_name, project_name):
    """Return one ``array set`` line mapping a region/rm block to its kernel VLNV."""
    return f'    {block_name} "{kernel_vlnv(project_name)}"\n'


# ---------------------------------------------------------------------------
# Static dispatcher proc (kernel-instantiating analogue of create_dfx_region_bd)
# ---------------------------------------------------------------------------
# The proc body lives in a dedicated TCL template alongside this module; it is
# rendered by substituting the __VLNV_TABLE__ / __KERNEL__ / __*_PIN__ markers.
_PROC_TEMPLATE_PATH = os.path.join(
    os.path.dirname(os.path.abspath(__file__)), 'dfx_region_user_bd.tcl.template')


def _render_proc(vlnv_table_lines):
    with open(_PROC_TEMPLATE_PATH) as f:
        proc = f.read()
    proc = proc.replace('__VLNV_TABLE__', ''.join(vlnv_table_lines))
    proc = proc.replace('__KERNEL__', KERNEL_INST_NAME)
    proc = proc.replace('__CTRL_BUSIF__', KERNEL_CTRL_BUSIF)
    proc = proc.replace('__CLK_PIN__', KERNEL_CLK_PIN)
    proc = proc.replace('__RST_PIN__', KERNEL_RST_PIN)
    return proc


def stitch_dispatcher(fragments, out_path):
    """Write the combined ``create_dfx_region_user_bd`` TCL.

    Args:
        fragments: list of ``array set`` lines from :func:`make_fragment`
            (one per (region, rm) block).
        out_path: path of the TCL file to write (use as
            ``HwBuildHelper(user_rm_build_tcl_path=...)``).

    Returns:
        out_path.
    """
    os.makedirs(os.path.dirname(os.path.abspath(out_path)), exist_ok=True)
    with open(out_path, 'w') as f:
        f.write(_render_proc(fragments))
    return out_path
