# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np
import os
import subprocess
import re

class DFX_Man:

    def __init__(self, host_ip, offset_reset, offset_decup):

        self.host_ip      = host_ip
        self.offset_reset = offset_reset
        self.offset_decup = offset_decup
        self.ps_decup_val = 0
        self._ctrl_sel    = 0  # software mirror of GPIO[0]: 0=PS controls, 1=DFX ctrl controls


    # --- internal helper ---

    def _write_decup(self):
        # GPIO[1] = ps_decup_val, GPIO[0] = _ctrl_sel (write-only register, tracked in SW)
        self.host_ip.write(self.offset_decup, (self.ps_decup_val << 1) | self._ctrl_sel)


    # --- reset ---

    def hold_reset(self):
        print("[man] hold reset pr region")
        self.host_ip.write(self.offset_reset, 0)
        print("[man] hold reset pr region successfully")

    def release_reset(self):
        print("[man] release reset pr region")
        self.host_ip.write(self.offset_reset, 1)
        print("[man] release reset pr region successfully")


    # --- ownership ---

    def grant_decoupler_to_dfx_ctrl(self):
        """Hand decoupler control to the DFX controller (ctrl_sel=1)."""
        self._ctrl_sel = 1
        self._write_decup()

    def grant_decoupler_to_ps(self):
        """Reclaim decoupler control to PS (ctrl_sel=0)."""
        self._ctrl_sel = 0
        self._write_decup()


    # --- decoupler ---

    def hold_decup(self):
        print("[man] decup pr region")
        self.ps_decup_val = 1
        self._write_decup()
        print("[man] decup pr region successfully")

    def release_decup(self):
        print("[man] release decup pr region")
        self.ps_decup_val = 0
        self._write_decup()
        print("[man] release decup pr region successfully")


    # --- state query ---

    @property
    def is_decoupled(self):
        return bool(self._ctrl_sel) or bool(self.ps_decup_val)