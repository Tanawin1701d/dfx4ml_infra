from pynq import DefaultIP, allocate
import numpy as np
import re

from .dfx_man  import DFX_Man
from .dfx_ctrl import DFX_Ctrl
from .dfx_mng  import DFX_Mng
from .dfx_dma  import DFX_Dma
from .pr_ctrl  import Pr_Ctrl


class DFX_Unified_Driver(DefaultIP):
    # Address offsets (relative to the IP's base address)
    DFX_CTRL_OFFSET  = 0x0_0000
    PR_DECUP_OFFSET  = 0x1_0000
    PR_RESET_OFFSET  = 0x2_0000
    DMA_OFFSET       = 0x3_0000
    DFX_MNG_OFFSET   = 0x4_0000
    PR_CTRL_BASE     = 0x5_0000  # region r lives at PR_CTRL_BASE + r * PR_CTRL_STRIDE
    PR_CTRL_STRIDE   = 0x1_0000

    # Set by gen_dfx_unified_driver() in sw_build.py; defaults serve single-region builds.
    NUM_PR_REGION    = NUM_PR_REGION_VAL
    SLOT_INDEX_WIDTH = SLOT_INDEX_WIDTH_VAL
    NUM_STREAMER     = NUM_STREAMER_VAL

    # do not remove even it seems unused, it is used by the PYNQ system
    bindto = ['user.org:user:dfx_unified:1.0']

    def __init__(self, description):
        super().__init__(description=description)

        self.dfx_mng  = DFX_Mng (self, self.DFX_MNG_OFFSET  , self.NUM_PR_REGION,
                                       self.SLOT_INDEX_WIDTH, self.NUM_STREAMER)
        self.dfx_ctrl = DFX_Ctrl(self, self.DFX_CTRL_OFFSET)
        self.dfx_dma  = DFX_Dma (self, self.DMA_OFFSET)
        self.dfx_man  = DFX_Man (self, self.PR_RESET_OFFSET, self.PR_DECUP_OFFSET)

        self._pr_ctrl = [
            Pr_Ctrl(self, self.PR_CTRL_BASE + r * self.PR_CTRL_STRIDE)
            for r in range(self.NUM_PR_REGION)
        ]

    # --- per-region accessors ---

    def get_pr_ctrl(self, region_idx):
        if self.dfx_man.is_decoupled(region_idx):
            raise RuntimeError(
                f"[pr_ctrl] Access denied: PR region {region_idx} is decoupled "
                "(dfx_ctrl is in control or ps_decup_val=1)"
            )
        return self._pr_ctrl[region_idx]

    # --- region-0 alias for backward compatibility ---

    @property
    def pr_ctrl(self):
        return self.get_pr_ctrl(0)