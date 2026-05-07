from pynq import DefaultIP, allocate
import numpy as np
import re

from .dfx_ctrl import DFX_Ctrl



class DFX_Unified_Driver(DefaultIP):
    def __init__(self, description):
        # constructor
        super().__init__(description=description)

        # address offset for each subIP
        self.DFX_CTRL_OFFSET  = 0x0_0000
        self.dfx_ctrl         = DFX_Ctrl(self, self.DFX_CTRL_OFFSET)



    bindto = ['xilinx.com:ip:dfx_controller:1.0']