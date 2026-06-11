# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np
import os
import subprocess
import re

class DFX_Man:
    # axi_dfx_decup GPIO bit layout (write-only, mirrored in host_ip._decup_shadow):
    #   bit[0]        : ctrl_sel  — 0=PS controls decoupler, 1=DFX ctrl controls
    #   bit[region+1] : ps_decup_val for that region

    def __init__(self, host_ip, offset_reset, offset_decup):
        self.host_ip        = host_ip
        self.offset_reset   = offset_reset
        self.offset_decup   = offset_decup
        self._decup_shadow  = 0  # local mirror; write-only HW register


    # --- internal helper ---

    def _write_decup(self):
        self.host_ip.write(self.offset_decup, self._decup_shadow)


    # --- reset (global) ---

    def hold_reset(self):
        print("[man] hold reset pr region")
        self.host_ip.write(self.offset_reset, 0)
        print("[man] hold reset pr region successfully")

    def release_reset(self):
        print("[man] release reset pr region")
        self.host_ip.write(self.offset_reset, 1)
        print("[man] release reset pr region successfully")


    # --- ownership (ctrl_sel bit[0], global) ---

    def grant_decoupler_to_dfx_ctrl(self):
        self._decup_shadow |= 0x1
        self._write_decup()

    def grant_decoupler_to_ps(self):
        self._decup_shadow &= ~0x1
        self._write_decup()


    # --- decoupler (per-region bit[region+1]) ---

    def hold_decup(self, region=0):
        print(f"[man] decup pr region {region}")
        self._decup_shadow |= (1 << (region + 1))
        self._write_decup()
        print(f"[man] decup pr region {region} successfully")

    def release_decup(self, region=0):
        print(f"[man] release decup pr region {region}")
        self._decup_shadow &= ~(1 << (region + 1))
        self._write_decup()
        print(f"[man] release decup pr region {region} successfully")


    # --- state query ---

    def is_decoupled(self, region=0):
        shadow   = self._decup_shadow
        ctrl_sel = shadow & 0x1
        ps_decup = (shadow >> (region + 1)) & 0x1
        return bool(ctrl_sel) or bool(ps_decup)