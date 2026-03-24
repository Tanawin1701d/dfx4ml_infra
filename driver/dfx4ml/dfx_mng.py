# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np
import os
import subprocess
import re

class DFX_Mng:

    def __init__(self, host_ip, offset):

        # meta data
        self.offset  = offset
        self.host_ip = host_ip
        # Bit Layout start bit
        self.BL_COL_ST  =  2 
        self.BL_ROW_ST  =  6 
        self.BL_BNK_ST  = 14 
        # Bit Layout size
        self.BIT_COL_SZ = 4
        self.BIT_ROW_SZ = 8
        self.BIT_BNK_SZ = 2
        # |-- BIT_BNK_SZ --|-- BIT_ROW_SZ --|-- BIT_COL_SZ --|

        # bank 0 register address meta
        # ==                  (bankId, rowIdx, colIdx)
        self.REG_CTRL       = (0,0,0)
        self.REG_ST         = (0,1,0)
        self.REG_MAINCNT    = (0,2,0)
        self.REG_ENDCNT     = (0,3,0)
        self.REG_DMA_ADDR   = (0,4,0)
        self.REG_DFX_ADDR   = (0,5,0)
        self.REG_INTR_ENA   = (0,6,0)
        self.REG_INTR       = (0,7,0)
        self.REG_ROUND_TRIP = (0,8,0)

        #### the row must be change to match the slot
        ######(bankId, rowIdx(row can vary), colIdx)
        self.SLOT_SRC_ADDR    = (1,0,0)
        self.SLOT_SRC_SIZE    = (1,0,1)
        self.SLOT_DES_ADDR    = (1,0,2)
        self.SLOT_DES_SIZE    = (1,0,3)
        self.SLOT_STATUS      = (1,0,4)
        self.SLOT_PROF        = (1,0,5)
        self.SLOT_LD_MASK     = (1,0,6)
        self.SLOT_ST_MASK     = (1,0,7)
        self.SLOT_STINTR_MASK = (1,0,8)



        self.LIM_AMT_SLOT = 4 ### limit amount slot

    def read(self, addr):
        return self.host_ip.read(self.offset + addr)

    def write(self, addr, value):
        self.host_ip.write(self.offset + addr, value)

    def gen_addr(self, bank_id, row_idx, col_idx):
        return (bank_id << self.BL_BNK_ST) | (row_idx << self.BL_ROW_ST) | (col_idx << self.BL_COL_ST)
    
    def gen_addr_for_slot(self, slot_t, slot_idx):
        return self.gen_addr(slot_t[0], slot_idx, slot_t[2])

    # =============================================
    # ===== getter ================================
    # =============================================

    def get_status(self):
        return self.read(self.gen_addr(*self.REG_ST))
    def get_main_cnt(self):
        return self.read(self.gen_addr(*self.REG_MAINCNT))
    def get_end_cnt(self):
        return self.read(self.gen_addr(*self.REG_ENDCNT))
    def get_dma_addr(self):
        return self.read(self.gen_addr(*self.REG_DMA_ADDR))
    def get_dfx_addr(self):
        return self.read(self.gen_addr(*self.REG_DFX_ADDR))
    def get_intr_ena(self):
        return self.read(self.gen_addr(*self.REG_INTR_ENA))
    def get_intr(self):
        return self.read(self.gen_addr(*self.REG_INTR))
    def get_round_trip(self):
        return self.read(self.gen_addr(*self.REG_ROUND_TRIP))
    
    def get_slot(self, slot_idx):

        addr_src_addr  = self.gen_addr_for_slot(self.SLOT_SRC_ADDR, slot_idx)
        addr_src_sz    = self.gen_addr_for_slot(self.SLOT_SRC_SIZE, slot_idx)
        addr_des_addr  = self.gen_addr_for_slot(self.SLOT_DES_ADDR, slot_idx)
        addr_des_sz    = self.gen_addr_for_slot(self.SLOT_DES_SIZE, slot_idx)
        addr_status   = self.gen_addr_for_slot(self.SLOT_STATUS, slot_idx)
        addr_prof     = self.gen_addr_for_slot(self.SLOT_PROF, slot_idx)
        addr_ld_mask   = self.gen_addr_for_slot(self.SLOT_LD_MASK, slot_idx)
        addr_st_mask   = self.gen_addr_for_slot(self.SLOT_ST_MASK, slot_idx)
        addr_st_intr   = self.gen_addr_for_slot(self.SLOT_STINTR_MASK, slot_idx)


        data_src_addr  = self.read(addr_src_addr)
        data_src_sz    = self.read(addr_src_sz)
        data_des_addr  = self.read(addr_des_addr)
        data_des_sz    = self.read(addr_des_sz)
        data_status   = self.read(addr_status)
        data_prof     = self.read(addr_prof)
        data_ld_mask   = self.read(addr_ld_mask)
        data_st_mask   = self.read(addr_st_mask)
        data_st_intr   = self.read(addr_st_intr)

        return data_src_addr, data_src_sz, data_des_addr, data_des_sz, data_status, data_prof, \
        data_ld_mask, data_st_mask, data_st_intr
        

    # =============================================
    # ===== setter ================================
    # =============================================

    def set_control(self, value): #### status registesr will be neglect
        return self.write(self.gen_addr(*self.REG_CTRL), value)
    # def setMainCnt(self, value):
    #     return self.write(self.gen_addr(*self.REG_MAINCNT), value)
    def set_end_cnt(self, value):
        return self.write(self.gen_addr(*self.REG_ENDCNT), value)
    def set_dma_addr(self, value):
        return self.write(self.gen_addr(*self.REG_DMA_ADDR), value)
    def set_dfx_addr(self, value):
        return self.write(self.gen_addr(*self.REG_DFX_ADDR), value)
    def set_intr_ena(self, value):
        return self.write(self.gen_addr(*self.REG_INTR_ENA), value)
    def set_intr(self, value):
        return self.write(self.gen_addr(*self.REG_INTR), value)
    def set_round_trip(self, value):
        return self.write(self.gen_addr(*self.REG_ROUND_TRIP), value)
    
    def set_slot(self, slot_t, slot_idx, value):
        addr  = self.gen_addr_for_slot(slot_t, slot_idx)
        self.write(addr, value)

    def set_whole_slot(self, slot_idx, data_list):

        addr_src_addr  = self.gen_addr_for_slot(self.SLOT_SRC_ADDR, slot_idx)
        addr_src_sz    = self.gen_addr_for_slot(self.SLOT_SRC_SIZE, slot_idx)
        addr_des_addr  = self.gen_addr_for_slot(self.SLOT_DES_ADDR, slot_idx)
        addr_des_sz    = self.gen_addr_for_slot(self.SLOT_DES_SIZE, slot_idx)
        addr_status   = self.gen_addr_for_slot(self.SLOT_STATUS, slot_idx)
        addr_prof     = self.gen_addr_for_slot(self.SLOT_PROF, slot_idx)
        addr_ld_mask   = self.gen_addr_for_slot(self.SLOT_LD_MASK, slot_idx)
        addr_st_mask   = self.gen_addr_for_slot(self.SLOT_ST_MASK, slot_idx)
        addr_st_intr   = self.gen_addr_for_slot(self.SLOT_STINTR_MASK, slot_idx)

        self.write(addr_src_addr, data_list[0])
        self.write(addr_src_sz  , data_list[1])
        self.write(addr_des_addr, data_list[2])
        self.write(addr_des_sz  , data_list[3])
        self.write(addr_status , data_list[4])
        self.write(addr_prof   , data_list[5])
        self.write(addr_ld_mask , data_list[6])
        self.write(addr_st_mask , data_list[7])
        self.write(addr_st_intr , data_list[8])

    # =============================================
    # ===== command ===============================
    # =============================================

    def clear_engine(self):
        print("[cmd] clear the engine")
        self.set_control(0)
        print("[cmd] clear the engine successfully")


    def shutdown_engine(self):
        print("[cmd] shutdown the engine")
        self.set_control(1)
        print("[cmd] shutdown successfully")

    def clear_intr(self):
        print("[cmd] clear the interrupt")
        self.set_intr(1) # it is write on clear register
        print("[cmd] clear the interrupt successfully")

    def start_engine(self):
        print("[cmd] start the engine")
        self.set_control(2)
        print("[cmd] start the successfully")

    # =============================================
    # ===== debugger ==============================
    # =============================================

    def status_to_str(self, status_idx):
        mapper = [ "SHUTDOWN","REPROG","W4SLAVERESET","W4SLAVEOP","CLEAR_MGS","INITIALIZE_MGS",
                  "INITIALIZE_DMA","SET_DMA_LOAD","SET_DMA_STORE","TRIGGERING","WAIT4FIN","PAUSEONERROR"
        ]

        if status_idx not in range(0, len(mapper)):
            return "STATUS ERROR"
        return mapper[status_idx]
        
    def print_main_status(self):


        print("----- MAIN STATUS ------------------")
        status  = self.get_status()
        print("--------> STATUS = ", self.status_to_str(status))
        main_cnt = self.get_main_cnt()
        print("--------> MAINCNT = ", main_cnt)
        end_cnt  = self.get_end_cnt()
        print("--------> ENDCNT  = ", end_cnt)
        dma_addr = self.get_dma_addr()
        print("--------> DMAADDR  = ", hex(dma_addr))
        dfx_addr = self.get_dfx_addr()
        print("--------> DFXADDR  = ", hex(dfx_addr))
        intr_ena = self.get_intr_ena()
        print("--------> INTR_ENA = ", hex(intr_ena))
        intr    = self.get_intr()
        print("--------> INTR     = ", hex(intr))
        round_trip = self.get_round_trip()
        print("--------> ROUND_TRIP = ", hex(round_trip))


    def print_slot_data(self):

        print("----- SLOT DATA ------------------")

        if self.get_status() != 0:
            print("---------- cannot print slot data due to the system is not in shutdown state")
            return

        for slot_idx in range (self.LIM_AMT_SLOT):
            s_addr, s_size, d_addr, d_size, status, prof, data_ld_mask, data_st_mask, data_st_intr = self.get_slot(slot_idx)

            print(f"------> slot {slot_idx} :")
            print(f"        srcAddr   : {hex(s_addr)},  srcSize   : {hex(s_size)}")
            print(f"        desAddr   : {hex(d_addr)},  desSize   : {hex(d_size)}")
            print(f"        status    : {hex(status)}")
            print(f"        profileCnt: {hex(prof)}")
            print(f"        loadMask  : {bin(data_ld_mask)}")
            print(f"        storeMask : {bin(data_st_mask)}")
            print(f"        stIntrMask: {bin(data_st_intr)}")

    def print_debug(self):
        self.print_main_status()
        self.print_slot_data()
        print("-------------------------------")