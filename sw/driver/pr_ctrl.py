from pynq import Overlay
from pynq import allocate
from pynq import DefaultIP
import numpy as np

class Pr_Ctrl:
    # Register offsets (byte addresses)
    REG_CTRL       = 0x00
    REG_GIE        = 0x04
    REG_IER        = 0x08
    REG_ISR        = 0x0c
    REG_BATCH_SIZE = 0x10

    # Control register bits
    BIT_AP_START      = 0
    BIT_AP_DONE       = 1
    BIT_AP_IDLE       = 2
    BIT_AP_READY      = 3
    BIT_AUTO_RESTART  = 7
    BIT_INTERRUPT     = 9

    def __init__(self, host_ip, offset):
        self.host_ip = host_ip
        self.offset  = offset

    def read(self, addr):
        return self.host_ip.read(self.offset + addr)

    def write(self, addr, value):
        self.host_ip.write(self.offset + addr, value)

    # =============================================
    # ===== getter ================================
    # =============================================

    def get_ctrl(self):
        return self.read(self.REG_CTRL)

    def get_ap_start(self):
        return (self.read(self.REG_CTRL) >> self.BIT_AP_START) & 0x1

    def get_ap_done(self):
        return (self.read(self.REG_CTRL) >> self.BIT_AP_DONE) & 0x1

    def get_ap_idle(self):
        return (self.read(self.REG_CTRL) >> self.BIT_AP_IDLE) & 0x1

    def get_ap_ready(self):
        return (self.read(self.REG_CTRL) >> self.BIT_AP_READY) & 0x1

    def get_auto_restart(self):
        return (self.read(self.REG_CTRL) >> self.BIT_AUTO_RESTART) & 0x1

    def get_interrupt(self):
        return (self.read(self.REG_CTRL) >> self.BIT_INTERRUPT) & 0x1

    def get_gie(self):
        return self.read(self.REG_GIE) & 0x1

    def get_ier(self):
        return self.read(self.REG_IER) & 0x3

    def get_isr(self):
        return self.read(self.REG_ISR) & 0x3

    def get_batch_size(self):
        return self.read(self.REG_BATCH_SIZE)

    # =============================================
    # ===== setter ================================
    # =============================================

    def set_ap_start(self, value):
        ctrl = self.read(self.REG_CTRL)
        ctrl = (ctrl & ~(1 << self.BIT_AP_START)) | ((value & 0x1) << self.BIT_AP_START)
        self.write(self.REG_CTRL, ctrl)

    def set_auto_restart(self, enable):
        ctrl = self.read(self.REG_CTRL)
        ctrl = (ctrl & ~(1 << self.BIT_AUTO_RESTART)) | ((enable & 0x1) << self.BIT_AUTO_RESTART)
        self.write(self.REG_CTRL, ctrl)

    def set_gie(self, enable):
        self.write(self.REG_GIE, enable & 0x1)

    def set_ier(self, value):
        self.write(self.REG_IER, value & 0x3)

    def set_isr(self, value):
        # TOW: toggle on write to clear
        self.write(self.REG_ISR, value & 0x3)

    def set_batch_size(self, value):
        self.write(self.REG_BATCH_SIZE, value)

    # =============================================
    # ===== command ===============================
    # =============================================

    def start(self):
        print("[cmd] ap_start")
        self.set_ap_start(1)

    def enable_auto_restart(self):
        print("[cmd] enable auto_restart")
        self.set_auto_restart(1)

    def disable_auto_restart(self):
        print("[cmd] disable auto_restart")
        self.set_auto_restart(0)

    def enable_global_intr(self):
        print("[cmd] enable global interrupt")
        self.set_gie(1)

    def disable_global_intr(self):
        print("[cmd] disable global interrupt")
        self.set_gie(0)

    def enable_done_intr(self):
        self.set_ier(self.get_ier() | 0x1)

    def enable_ready_intr(self):
        self.set_ier(self.get_ier() | 0x2)

    def clear_done_intr(self):
        self.set_isr(0x1)

    def clear_ready_intr(self):
        self.set_isr(0x2)

    def clear_all_intr(self):
        self.set_isr(0x3)

    def wait_done(self):
        while not self.get_ap_done():
            pass

    def run(self, batch_size):
        print(f"[cmd] run with batch_size={batch_size}")
        self.set_batch_size(batch_size)
        self.start()
        self.wait_done()
        print("[cmd] done")

    # =============================================
    # ===== debugger ==============================
    # =============================================

    def print_status(self):
        ctrl = self.get_ctrl()
        print("----- HLS IP STATUS ------------------")
        print(f"  ap_start     : {(ctrl >> self.BIT_AP_START)     & 0x1}")
        print(f"  ap_done      : {(ctrl >> self.BIT_AP_DONE)      & 0x1}")
        print(f"  ap_idle      : {(ctrl >> self.BIT_AP_IDLE)      & 0x1}")
        print(f"  ap_ready     : {(ctrl >> self.BIT_AP_READY)     & 0x1}")
        print(f"  auto_restart : {(ctrl >> self.BIT_AUTO_RESTART) & 0x1}")
        print(f"  interrupt    : {(ctrl >> self.BIT_INTERRUPT)    & 0x1}")
        print(f"  GIE          : {self.get_gie()}")
        print(f"  IER          : {bin(self.get_ier())}")
        print(f"  ISR          : {bin(self.get_isr())}")
        print(f"  batch_size   : {self.get_batch_size()}")
        print("--------------------------------------")