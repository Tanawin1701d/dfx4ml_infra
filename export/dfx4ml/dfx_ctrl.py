# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np
import os
import subprocess
import re

class DFX_Ctrl:
    def __init__(self, host_ip, offset):

        # meta data and the storage
        self.offset = offset
        self.host_ip = host_ip
        self.is_meta_configured = False
        self.storage          = None
        # BLS Bit Layout Size
        self.BLS_DATA   = 2 # register contain 4 byte (2 bit addressing)
        self.BLS_REGID  = 4 # register Id
        self.BLS_BANKID = 2 # bank id
        # |-- BLS_BANKID --|-- BLS_REG_ID --|-- BLS_DATA --|
        # GENERAL BANK
        self.BANK_GENREG      = 0     
        self.GENREG_STATUS    = 0
        self.GENREG_CTRL      = 0
        self.GENREG_SWTRIGGER = 1
        # TRIGGER RM MAPPING
        self.BANK_RMM         = 1
        # RM INFO
        self.BANK_RMINFO      = 2
        # BITSTREAM INFO
        self.BANK_BSINFO      = 3

    def read(self, addr):
        return self.host_ip.read(self.offset + addr)

    def write(self, addr, value):
        self.host_ip.write(self.offset + addr, value)

    # ============================================
    # CONFIG
    # ============================================
    # config intend to retrieve the meta data from the dfx controller specification
    # to determine the address of the pr slot address

    def config(self, meta_path):
        reg_bank_idx, reg_col_idx = self._retrieve_config(meta_path)
        self.BLS_REGID  = reg_col_idx [1] - reg_col_idx [0] + 1
        self.BLS_BANKID = reg_bank_idx[1] - reg_bank_idx[0] + 1
        self.is_meta_configured = True

    # config check
    def _retrieve_config(self, path):
        reg_bank_idx = None
        reg_col_idx  = None

        with open(path, 'r') as file:
            for line in file:
                if "Selects the Register Bank" in line:
                    reg_bank_idx = self._extract_bit_range(line)
                    print(f"reg detect index {reg_bank_idx}")
                    
                if "Selects the Register within the bank" in line:
                    reg_col_idx = self._extract_bit_range(line)
                    print(f"reg detect index {reg_col_idx}")

        return reg_bank_idx, reg_col_idx



    def _extract_bit_range(self, line):

        match = re.search(r'\[\s*(\d+)\s*:\s*(\d+)\s*\]', line)
        if match:
            high = int(match.group(1))
            low  = int(match.group(2))
            return low, high
        else:
            return None

    # address generator
    def _get_address(self, bank_id, reg_id): ### todo make it compatible for more than 1 slot
        if not self.is_meta_configured:
            raise Exception("this module has not initialized yet, any attempt to interact with the IP will be abort")
        return (bank_id << (self.BLS_DATA + self.BLS_REGID)) + (reg_id << (self.BLS_DATA))

    # ============================================
    # GENERAL COMMAND
    # ============================================
    def shutdown_engine(self): # the internal register can be reconfigured
        print("shutdown dfx Controller")
        self.set_ctrl(0)
    
    def restart_no_status(self):
        print("restart the dfx Controller with no status")
        self.set_ctrl(1)
        
    def restart_with_status(self):   # TODO please check
        print("restart the dfx Controller with status")
        
    def trig(self, trigger_id):
        print("trig the rmId ", trigger_id)
        self.set_ctrl_trigger(trigger_id)

    # ============================================
    # GETTER AND SETTER COMMAND
    # ============================================
        
    #  general register bank0
    #
    # |statusRegister, controlRegister|
    # | trigger register              |
    #
    def get_status(self):
        reg_addr = self._get_address(self.BANK_GENREG, self.GENREG_STATUS)
        print("[get status register] @", hex(reg_addr))
        return self.read(reg_addr)
    
    def get_ctrl(self):
        reg_addr = self._get_address(self.BANK_GENREG, self.GENREG_CTRL)
        print("[get ctrl register] @", hex(reg_addr))
        return self.read(reg_addr)
    
    def set_ctrl(self, command):
        reg_addr = self._get_address(self.BANK_GENREG, self.GENREG_CTRL)
        print("[set ctrl register] @", hex(reg_addr), " with command ", hex(command))
        self.write(reg_addr, command)
    
    def get_ctrl_trigger(self):
        reg_addr = self._get_address(self.BANK_GENREG, self.GENREG_SWTRIGGER)
        print("[get Ctrl Trigger] @", hex(reg_addr))
        return self.read(reg_addr)
    
    def set_ctrl_trigger(self, trigger_id):
        reg_addr = self._get_address(self.BANK_GENREG, self.GENREG_SWTRIGGER)
        print("[set Ctrl Trigger] @", hex(reg_addr))
        self.write(reg_addr, trigger_id)
        
    # Reconfig Module Map bank1
    # | RM0 |
    # | RM1 |
    # | RM2 |
    # .
    def get_rmm(self, trigger_id):
        reg_addr = self._get_address(self.BANK_RMM, trigger_id)
        print("[get RM MAP] @", hex(reg_addr))
        return self.read(reg_addr)
    
    def set_rmm(self, trigger_id, info_id):
        reg_addr = self._get_address(self.BANK_RMM, trigger_id)
        print("[set RM MAP] @", hex(reg_addr), " info ", hex(info_id))
        self.write(reg_addr, info_id)
        
    # Reconfig Module Map bank2
    # | BS_ID0 | CT_ID0 |
    # | BS_ID1 | CT_ID1 |
    # | BS_ID2 | CT_ID2 |
    # .
    def get_rm_info(self, info_id):
        bs_idx_addr = self._get_address(self.BANK_RMINFO, info_id * 2)
        ### *2 because each row has two element
        ctrl_addr  = self._get_address(self.BANK_RMINFO, (info_id * 2) + 1)
        print("[get RM INFO] bsIdxAddr@", hex(bs_idx_addr), " ctrlAddr@", hex(ctrl_addr))
        return (self.read(bs_idx_addr), self.read(ctrl_addr))
    
    def set_rm_info(self, info_id, bs_idx, ctrl_cmd):
        ### *2 because each row has two element
        bs_idx_addr = self._get_address(self.BANK_RMINFO, info_id * 2)
        ctrl_addr  = self._get_address(self.BANK_RMINFO, (info_id * 2) + 1)
        print("[get RM INFO] bsIdxAddr@", hex(bs_idx_addr), " ctrlAddr@", hex(ctrl_addr))
        self.write(bs_idx_addr, bs_idx)
        self.write(ctrl_addr, ctrl_cmd)
    ####### BIN stream bank3
    # | BIN_ADDR0 | SIZE0 |
    # | BIN_ADDR1 | SIZE1 |
    # | BIN_ADDR2 | SIZE2 |
    # .
    def get_bs_info(self, bs_id):
        ### *3 because each row has three element
        stream_ident_addr  = self._get_address(self.BANK_BSINFO, (bs_id * 4))
        stream_addr       = self._get_address(self.BANK_BSINFO, (bs_id * 4) + 1)
        size_addr         = self._get_address(self.BANK_BSINFO, (bs_id * 4) + 2)
        print("[get BS INFO] streamAddr@", hex(stream_addr), " sizeAddr@", hex(size_addr))
        return (self.read(stream_ident_addr), self.read(stream_addr), self.read(size_addr))
    
    def set_bs_info(self, bs_id, phy_stream_addr, stream_size):
    
        stream_ident_addr  = self._get_address(self.BANK_BSINFO, (bs_id * 4))
        stream_addr       = self._get_address(self.BANK_BSINFO, (bs_id * 4) + 1)
        size_addr         = self._get_address(self.BANK_BSINFO, (bs_id * 4) + 2)
        print("[get BS INFO] streamAddr@", hex(stream_addr), " sizeAddr@", hex(size_addr))
        self.write(stream_ident_addr, 1)
        self.write(stream_addr     , phy_stream_addr)
        self.write(size_addr       , stream_size)
        
    ######## AUTO META DATA RECONFIGURE
    def set_simple_meta_data(self, idx, stream_phy_addr, stream_phy_size):
        
        print("setting RM Mapping to ", idx)
        self.set_rmm(idx, idx)
        print("setting RM INFO to ", idx)
        ctrl_value = 0B0_10_0_00
        print("control value for active low reset is ", hex(ctrl_value))
        self.set_rm_info(idx, idx, ctrl_value)
        
        print("setting BS INFO to ", idx, " with streamAddress: ", stream_phy_addr, " with size: ", stream_phy_size)
        self.set_bs_info(idx, stream_phy_addr, stream_phy_size)
    
    # ==================================
    # DEBUGGER
    # ==================================

    def print_status(self):
        
        status = self.get_status()
        
        print(">>status of the system vs0")
        print("-------> Is device shutdown: ", (status >> 7) & 0x1)
        print("-------> current error code: ", hex((status >> 3) & 0xF))
        print("-------> active RM_ID      : ", hex((status >> 8) & 0xFFFF))
        print("-------> state      : ", hex(status & 0x7))
        
    def print_simple_meta_data(self, idx):
        print("get metadata info for row", idx)
        print("RM MAPPER: ", self.get_rmm   (idx))
        print("RM INFO  : ", self.get_rm_info(idx))
        print("BS INFO  : ", self.get_bs_info(idx))
        
        
        
    # ==================================
    # ALLOCATE BIN STREAM ON MAIN MEMORY
    # ==================================
    
    def allocate_bit_stream_cma(self, path):
              
        print(">>allocateBitStream")
        
        print("opening file ", path)
        with open(path, 'rb') as f:
            data = f.read()
        file_size = len(data)
        print("copying the data")
        data_u32  = np.frombuffer(data, dtype='<u4')  # Big-endian uint32
        buffer    = allocate(shape=(len(data_u32),), dtype='>u4')
        buffer[:] = data_u32
        print("copy complete")
        print("file size ", file_size)
        print("---------------------------------")
        return buffer, buffer.physical_address, file_size