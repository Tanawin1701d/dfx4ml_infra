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
    PR_CTRL_BASE     = 0x6_0000  # region r lives at PR_CTRL_BASE + r * PR_CTRL_STRIDE
    PR_CTRL_STRIDE   = 0x1_0000

    def __init__(self, description, num_pr_region=1):
        super().__init__(description=description)

        self.dfx_mng  = DFX_Mng (self, self.DFX_MNG_OFFSET)
        self.dfx_ctrl = DFX_Ctrl(self, self.DFX_CTRL_OFFSET)
        self.dfx_dma  = DFX_Dma (self, self.DMA_OFFSET)
        self.dfx_man  = DFX_Man (self, self.PR_RESET_OFFSET, self.PR_DECUP_OFFSET)

        self.num_pr_region = num_pr_region
        self._pr_ctrl = [
            Pr_Ctrl(self, self.PR_CTRL_BASE + r * self.PR_CTRL_STRIDE)
            for r in range(num_pr_region)
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

    bindto = ['user.org:user:dfx_unified:1.0']