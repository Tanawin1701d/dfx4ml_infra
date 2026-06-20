"""VitisUnifiedDFx4ml — hls4ml backend plugin for the dfx4ml FPGA flow.

This package is an *external* hls4ml backend plugin (it lives in the dfx4ml repo,
not inside the hls4ml submodule). It registers a new backend, ``VitisUnifiedDFx4ml``,
that subclasses the submodule's ``VitisUnified`` backend and emits multi-port
flat AXI-Stream kernels that drop straight into the dfx4ml reconfigurable region,
plus the ``create_dfx_region_user_bd`` TCL and the dfx_streamer allocation.

Enable it before importing hls4ml::

    import os, sys
    sys.path.insert(0, '<repo>/lib')
    os.environ['HLS4ML_BACKEND_PLUGINS'] = 'hls4ml_con'
    import hls4ml                      # discovers + registers the plugin
    assert 'vitisunifieddfx4ml' in hls4ml.backends.get_available_backends()

``backend`` / ``writer`` are imported lazily inside :func:`register` so that
importing helper submodules (``streamer_glue``, ``tcl_gen``) does not pull in
hls4ml — this keeps registration free of import-order / circular-import hazards.
"""

BACKEND_NAME = 'VitisUnifiedDFx4ml'

__all__ = ['BACKEND_NAME', 'register']


def register(register_backend=None, register_writer=None):
    """Plugin entry point invoked by hls4ml's ``load_backend_plugins()``.

    hls4ml passes ``register_backend`` / ``register_writer`` as keyword args; we
    also fall back to importing them so the module can be registered manually.
    The writer must be registered first because the backend constructor binds its
    writer via ``get_writer(name)``.
    """
    if register_backend is None:
        from hls4ml.backends import register_backend
    if register_writer is None:
        from hls4ml.writer import register_writer

    from .backend import VitisUnifiedDFx4mlBackend
    from .writer import VitisUnifiedDFx4mlWriter

    register_writer(BACKEND_NAME, VitisUnifiedDFx4mlWriter)
    register_backend(BACKEND_NAME, VitisUnifiedDFx4mlBackend)
