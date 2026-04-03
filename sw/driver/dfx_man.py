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

        # meta data
        self.host_ip = host_ip
        self.offset_reset = offset_reset
        self.offset_decup = offset_decup


    def hold_reset(self):
        print("[man] hold reset pr region")
        self.host_ip.write(self.offset_reset, 0)
        print("[man] hold reset pr region successfully")


    def release_reset(self):
        print("[man] release reset pr region")
        self.host_ip.write(self.offset_reset, 1)
        print("[man] release reset pr region successfully")


    def hold_decup(self):
        print("[man] decup pr region")
        self.host_ip.write(self.offset_decup, 1)
        print("[man] decup pr region successfully")

    def release_decup(self):
        print("[man] release decup pr region")
        self.host_ip.write(self.offset_decup, 0)
        print("[man] release decup pr region successfully")