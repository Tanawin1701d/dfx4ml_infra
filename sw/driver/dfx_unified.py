from pynq import DefaultIP, allocate
import numpy as np
import re

from .dfx_man  import DFX_Man
from .dfx_ctrl import DFX_Ctrl
from .dfx_mng  import DFX_Mng
from .dfx_dma  import DFX_Dma
from .pr_ctrl  import Pr_Ctrl


class DFX_Unified_Driver(DefaultIP):
    def __init__(self, description):
        # constructor
        super().__init__(description=description)

        # address offset for each subIP
        self.DFX_MNG_OFFSET   = 0x4_0000
        self.DFX_CTRL_OFFSET  = 0x0_0000
        self.DMA_OFFSET       = 0x3_0000
        self.PR_RESET_OFFSET  = 0x2_0000
        self.PR_DECUP_OFFSET  = 0x1_0000
        self.PR_CTRL_OFFSET   = 0x5_0000


        self.dfx_mng  = DFX_Mng (self, self.DFX_MNG_OFFSET )
        self.dfx_ctrl = DFX_Ctrl(self, self.DFX_CTRL_OFFSET)
        self.dfx_man  = DFX_Man (self, self.PR_RESET_OFFSET, self.PR_DECUP_OFFSET)
        self.dfx_dma  = DFX_Dma (self, self.DMA_OFFSET)
        self.pr_ctrl  = Pr_Ctrl (self, self.PR_CTRL_OFFSET)

    bindto = ['user.org:user:dfx_unified:1.0']