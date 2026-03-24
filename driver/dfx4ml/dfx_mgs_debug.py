# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np
import os
import subprocess
import re

class DFX_mgs_debug:

    def __init__(self, gpio_ip):
        # meta data
        self.gpio_ip = gpio_ip

    def read_mgs_meta(self):
        raw_data = self.gpio_ip.read(0)

        pattern_11bit_1 = (raw_data      ) & 0x7FF
        pattern_11bit_2 = (raw_data >> 11) & 0x7FF
        pattern_4bit    = (raw_data >> 22)  & 0xF

        # State mapping from hardware
        state_map = {
            0x0: "STATUS_IDLE",
            0x1: "STATUS_STORE",
            0x2: "STATUS_LOAD"
        }

        print(f"load amount : {pattern_11bit_1}")
        print(f"store amount : {pattern_11bit_2}")
        state_str = state_map.get(pattern_4bit, f"UNKNOWN (0x{pattern_4bit:X})")
        print(f"state : {state_str} (0x{pattern_4bit:X})")
