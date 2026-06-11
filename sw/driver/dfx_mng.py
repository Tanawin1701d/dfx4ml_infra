# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np
import os
import subprocess
import re

class DFX_Mng:

    def __init__(self, host_ip, offset, num_pr_region, slot_index_width, num_streamer):

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
        # == (bankId, rowIdx, colIdx)
        self.REG_CTRL               = (0, 0x00, 0)  # write only
        self.REG_MAIN_STATE         = (0, 0x01, 0)  # read only
        self.REG_RECON_STATE        = (0, 0x02, 0)  # read only
        self.REG_EXEC_STATE         = (0, 0x03, 0)  # read only
        self.REG_LAST_SESSION       = (0, 0x04, 0)  # read/write (writable in SHUTDOWN)
        self.REG_CUR_QUERY          = (0, 0x05, 0)  # read only
        self.REG_AMT_QUERY          = (0, 0x06, 0)  # read/write (writable in SHUTDOWN)
        self.REG_AMT_QUERY_PER_ITER = (0, 0x07, 0)  # read/write (writable in SHUTDOWN)
        self.REG_DMA_IP_ADDR        = (0, 0x08, 0)  # read/write (writable in SHUTDOWN)
        self.REG_PR_IP_ADDR         = (0, 0x09, 0)  # read/write (writable in SHUTDOWN)
        self.REG_INTR_ENA           = (0, 0x0A, 0)  # read/write (writable in SHUTDOWN)
        self.REG_INTR_STATUS        = (0, 0x0B, 0)  # read only
        self.REG_MPERF              = (0, 0x0C, 0)  # read/write (writable in SHUTDOWN); auto-increments while recon/exec engine is active

        # bank 1 slot field address meta
        # rowIdx is replaced by slot_idx at call time via gen_addr_for_slot
        # == (bankId, rowIdx(slot_idx), colIdx)
        self.SLOT_DMA_SRC_ADDR    = (1, 0, 0x0)
        self.SLOT_DMA_SRC_SIZE    = (1, 0, 0x1)
        self.SLOT_DMA_DES_ADDR    = (1, 0, 0x2)
        self.SLOT_DMA_DES_SIZE    = (1, 0, 0x3)
        self.SLOT_PROF_RECON      = (1, 0, 0x4)
        self.SLOT_PROF_EXEC       = (1, 0, 0x5)
        self.SLOT_VS_RM_RECON_SEL = (1, 0, 0x6)
        self.SLOT_VS_RM_EXEC_SEL  = (1, 0, 0x7)
        self.SLOT_LOAD_MASK       = (1, 0, 0x8)
        self.SLOT_STORE_MASK      = (1, 0, 0x9)
        self.SLOT_COMPLETE_MASK   = (1, 0, 0xA)
        self.SLOT_NEXT_SESSION    = (1, 0, 0xB)

        self.NUM_REGION       = num_pr_region
        self.SLOT_INDEX_WIDTH = slot_index_width
        self.LIM_AMT_SLOT     = 1 << slot_index_width
        self.NUM_STREAMER     = num_streamer

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

    def get_main_state(self):
        return self.read(self.gen_addr(*self.REG_MAIN_STATE))
    def get_recon_state(self):
        return self.read(self.gen_addr(*self.REG_RECON_STATE))
    def get_exec_state(self):
        return self.read(self.gen_addr(*self.REG_EXEC_STATE))
    def get_last_session(self):
        return self.read(self.gen_addr(*self.REG_LAST_SESSION))
    def get_cur_query(self):
        return self.read(self.gen_addr(*self.REG_CUR_QUERY))
    def get_amt_query(self):
        return self.read(self.gen_addr(*self.REG_AMT_QUERY))
    def get_amt_query_per_iter(self):
        return self.read(self.gen_addr(*self.REG_AMT_QUERY_PER_ITER))
    def get_dma_ip_addr(self):
        return self.read(self.gen_addr(*self.REG_DMA_IP_ADDR))
    def get_pr_ip_addr(self):
        return self.read(self.gen_addr(*self.REG_PR_IP_ADDR))
    def get_intr_ena(self):
        return self.read(self.gen_addr(*self.REG_INTR_ENA))
    def get_intr_status(self):
        return self.read(self.gen_addr(*self.REG_INTR_STATUS))
    def get_mperf(self):
        return self.read(self.gen_addr(*self.REG_MPERF))

    def get_slot(self, slot_idx):

        addr_src_addr      = self.gen_addr_for_slot(self.SLOT_DMA_SRC_ADDR,    slot_idx)
        addr_src_size      = self.gen_addr_for_slot(self.SLOT_DMA_SRC_SIZE,    slot_idx)
        addr_des_addr      = self.gen_addr_for_slot(self.SLOT_DMA_DES_ADDR,    slot_idx)
        addr_des_size      = self.gen_addr_for_slot(self.SLOT_DMA_DES_SIZE,    slot_idx)
        addr_prof_recon    = self.gen_addr_for_slot(self.SLOT_PROF_RECON,      slot_idx)
        addr_prof_exec     = self.gen_addr_for_slot(self.SLOT_PROF_EXEC,       slot_idx)
        addr_rm_recon_sel  = self.gen_addr_for_slot(self.SLOT_VS_RM_RECON_SEL, slot_idx)
        addr_rm_exec_sel   = self.gen_addr_for_slot(self.SLOT_VS_RM_EXEC_SEL,  slot_idx)
        addr_load_mask     = self.gen_addr_for_slot(self.SLOT_LOAD_MASK,       slot_idx)
        addr_store_mask    = self.gen_addr_for_slot(self.SLOT_STORE_MASK,      slot_idx)
        addr_complete_mask = self.gen_addr_for_slot(self.SLOT_COMPLETE_MASK,   slot_idx)
        addr_next_session  = self.gen_addr_for_slot(self.SLOT_NEXT_SESSION,    slot_idx)

        data_src_addr      = self.read(addr_src_addr)
        data_src_size      = self.read(addr_src_size)
        data_des_addr      = self.read(addr_des_addr)
        data_des_size      = self.read(addr_des_size)
        data_prof_recon    = self.read(addr_prof_recon)
        data_prof_exec     = self.read(addr_prof_exec)
        data_rm_recon_sel  = self.read(addr_rm_recon_sel)
        data_rm_exec_sel   = self.read(addr_rm_exec_sel)
        data_load_mask     = self.read(addr_load_mask)
        data_store_mask    = self.read(addr_store_mask)
        data_complete_mask = self.read(addr_complete_mask)
        data_next_session  = self.read(addr_next_session)

        return (data_src_addr, data_src_size, data_des_addr, data_des_size,
                data_prof_recon, data_prof_exec, data_rm_recon_sel, data_rm_exec_sel,
                data_load_mask, data_store_mask, data_complete_mask, data_next_session)

    # =============================================
    # ===== setter ================================
    # =============================================

    def set_control(self, value):
        return self.write(self.gen_addr(*self.REG_CTRL), value)
    def set_last_session(self, value):
        return self.write(self.gen_addr(*self.REG_LAST_SESSION), value)
    def set_amt_query(self, value):
        return self.write(self.gen_addr(*self.REG_AMT_QUERY), value)
    def set_amt_query_per_iter(self, value):
        return self.write(self.gen_addr(*self.REG_AMT_QUERY_PER_ITER), value)
    def set_dma_ip_addr(self, value):
        return self.write(self.gen_addr(*self.REG_DMA_IP_ADDR), value)
    def set_pr_ip_addr(self, value):
        return self.write(self.gen_addr(*self.REG_PR_IP_ADDR), value)
    def set_intr_ena(self, value):
        return self.write(self.gen_addr(*self.REG_INTR_ENA), value)
    def set_mperf(self, value):
        return self.write(self.gen_addr(*self.REG_MPERF), value)

    def set_slot(self, slot_t, slot_idx, value):
        if slot_t in (self.SLOT_VS_RM_RECON_SEL, self.SLOT_VS_RM_EXEC_SEL) and value != 0 and bin(value).count('1') != 1:
            field = "vs_rm_recon_sel" if slot_t == self.SLOT_VS_RM_RECON_SEL else "vs_rm_exec_sel"
            raise ValueError(
                f"[slot {slot_idx}] {field}={bin(value)}: must be exactly one-hot "
                f"(exactly one PR region selected per session)"
            )
        addr = self.gen_addr_for_slot(slot_t, slot_idx)
        self.write(addr, value)

    def set_whole_slot(self, slot_idx, data_list):
        # data_list order: [src_addr, src_size, des_addr, des_size,
        #                   prof_recon, prof_exec, vs_rm_recon_sel, vs_rm_exec_sel,
        #                   load_mask, store_mask, complete_mask, next_session]
        fields = [
            self.SLOT_DMA_SRC_ADDR, self.SLOT_DMA_SRC_SIZE,
            self.SLOT_DMA_DES_ADDR, self.SLOT_DMA_DES_SIZE,
            self.SLOT_PROF_RECON,   self.SLOT_PROF_EXEC,
            self.SLOT_VS_RM_RECON_SEL, self.SLOT_VS_RM_EXEC_SEL,
            self.SLOT_LOAD_MASK,    self.SLOT_STORE_MASK,
            self.SLOT_COMPLETE_MASK, self.SLOT_NEXT_SESSION,
        ]
        for field, value in zip(fields, data_list):
            self.set_slot(field, slot_idx, value)

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

    def start_engine(self):
        if not self.validate_query_config():
            print("[cmd] start aborted — fix query config first")
            return
        print("[cmd] start the engine")
        self.set_control(2)
        print("[cmd] start the engine successfully")

    # =============================================
    # ===== debugger ==============================
    # =============================================

    def main_state_to_str(self, s):
        mapper = {
            0: "SHUTDOWN",
            1: "PROCESS",
            2: "PRE_SHUTDOWN",
        }
        return mapper.get(s, "UNKNOWN")

    def recon_state_to_str(self, s):
        mapper = {
            0: "SHUTDOWN",
            1: "REPROG",
            2: "W4SLAVERESET",
            3: "W4SLAVEOP",
            4: "FIN_SYNC",
        }
        return mapper.get(s, "UNKNOWN")

    def exec_state_to_str(self, s):
        mapper = {
            0:  "SHUTDOWN",
            1:  "PR_CTRL_REQ_SKIP_CHECK",
            2:  "INITIALIZE_PR_CTRL",
            3:  "CLEAR_MGS",
            4:  "INITIALIZE_MGS",
            5:  "INITIALIZE_DMA",
            6:  "SET_DMA_LOAD",
            7:  "SET_DMA_STORE",
            8:  "TRIGGERING",
            9:  "WAIT4FIN",
            10: "FIN_SYNC",
        }
        return mapper.get(s, "UNKNOWN")

    def validate_query_config(self):
        """Returns True if amt_query will terminate cleanly (divisible by amt_query_per_iter)."""
        amt      = self.get_amt_query()
        per_iter = self.get_amt_query_per_iter()
        print(f"[query check] amt={amt}  per_iter={per_iter}")
        if per_iter == 0:
            print("[query check] FAIL — per_iter is zero")
            return False
        if amt % per_iter != 0:
            needed = amt + (per_iter - amt % per_iter)
            print(f"[query check] FAIL — {amt} % {per_iter} = {amt % per_iter}  (nearest valid: {needed})")
            return False
        print(f"[query check] OK — {amt // per_iter} iteration(s)")
        return True

    def print_main_status(self):
        main_state         = self.get_main_state()
        recon_state        = self.get_recon_state()
        exec_state         = self.get_exec_state()
        last_session       = self.get_last_session()
        cur_query          = self.get_cur_query()
        amt_query          = self.get_amt_query()
        amt_query_per_iter = self.get_amt_query_per_iter()
        dma_ip_addr        = self.get_dma_ip_addr()
        pr_ip_addr         = self.get_pr_ip_addr()
        intr_ena           = self.get_intr_ena()
        intr_status        = self.get_intr_status()
        mperf              = self.get_mperf()

        W = 55
        progress = (f"{cur_query}/{amt_query}"
                    if amt_query > 0 else f"{cur_query}/-")

        print("┌" + "─" * W + "┐")
        print(f"│{'  DFX Manager — Main Status':^{W}}│")
        print("├" + "─" * W + "┤")
        print(f"│  {'MAIN_STATE':<22}: {self.main_state_to_str(main_state):<{W-26}}│")
        print(f"│  {'RECON_STATE':<22}: {self.recon_state_to_str(recon_state):<{W-26}}│")
        print(f"│  {'EXEC_STATE':<22}: {self.exec_state_to_str(exec_state):<{W-26}}│")
        print("├" + "─" * W + "┤")
        print(f"│  {'LAST_SESSION':<22}: {last_session:<{W-26}}│")
        print(f"│  {'QUERY (cur/amt)':<22}: {progress:<{W-26}}│")
        print(f"│  {'AMT_QUERY_PER_ITER':<22}: {amt_query_per_iter:<{W-26}}│")
        print("├" + "─" * W + "┤")
        print(f"│  {'DMA_IP_ADDR':<22}: {hex(dma_ip_addr):<{W-26}}│")
        print(f"│  {'PR_IP_ADDR':<22}: {hex(pr_ip_addr):<{W-26}}│")
        print("├" + "─" * W + "┤")
        intr_line = f"ena={'1' if intr_ena else '0'}  status={'1 (pending)' if intr_status else '0'}"
        print(f"│  {'INTERRUPT':<22}: {intr_line:<{W-26}}│")
        print(f"│  {'MPERF':<22}: {mperf:<{W-26}}│")
        print("└" + "─" * W + "┘")

    def print_slot_data(self):
        W = 55
        print("┌" + "─" * W + "┐")
        print(f"│{'  DFX Manager — Slot Data':^{W}}│")
        print("├" + "─" * W + "┤")

        if self.get_main_state() != 0:
            msg = "read-back unavailable: not in SHUTDOWN state"
            print(f"│  {msg:<{W-2}}│")
            print("└" + "─" * W + "┘")
            return

        for slot_idx in range(self.LIM_AMT_SLOT):
            (s_addr, s_size, d_addr, d_size,
             prof_recon, prof_exec, rm_recon_sel, rm_exec_sel,
             load_mask, store_mask, complete_mask, next_session) = self.get_slot(slot_idx)

            slot_label = f"  slot [{slot_idx}]"
            print(f"│{slot_label:<{W}}│")
            print(f"│    {'src':<6}: addr={hex(s_addr):<12}  size={hex(s_size):<{W-36}}│")
            print(f"│    {'des':<6}: addr={hex(d_addr):<12}  size={hex(d_size):<{W-36}}│")
            print(f"│    {'recon':<6}: rm_sel={bin(rm_recon_sel):<8}  prof={prof_recon:<{W-34}}│")
            print(f"│    {'exec':<6}: rm_sel={bin(rm_exec_sel):<8}  prof={prof_exec:<{W-34}}│")
            masks = f"load={bin(load_mask)}  store={bin(store_mask)}  done={bin(complete_mask)}"
            print(f"│    {'masks':<6}: {masks:<{W-12}}│")
            print(f"│    {'next':<6}: slot {next_session:<{W-17}}│")
            if slot_idx < self.LIM_AMT_SLOT - 1:
                print("│" + "·" * W + "│")

        print("└" + "─" * W + "┘")

    def print_debug(self):
        self.print_main_status()
        self.print_slot_data()

    # =============================================
    # ===== test ==================================
    # =============================================

    def test_reg_readback(self):
        """
        Shut down the IP, write test patterns to every R/W register,
        read back, and verify each value matches (applying the hardware
        register width mask where the register is narrower than 32 bits).

        NOTE: this test is destructive — all writable registers are
        overwritten. Call clear_engine() / re-initialise after if needed.

        Returns True if every check passes, False otherwise.
        """
        failures = []

        def check(name, wrote, got, mask=0xFFFFFFFF):
            expected = wrote & mask
            actual   = got   & mask
            ok       = (expected == actual)
            tag      = "PASS" if ok else "FAIL"
            print(f"  [{tag}] {name:<46}  wrote={hex(expected):<12}  got={hex(actual):<12}")
            if not ok:
                failures.append((name, expected, actual))

        # ---- step 1: force SHUTDOWN ----------------------------------------
        print("[test] issuing SHUTDOWN command ...")
        self.shutdown_engine()
        if self.get_main_state() != 0:
            print("[test] ERROR: MAIN_STATE is not SHUTDOWN — aborting test")
            return False
        print("[test] IP confirmed in SHUTDOWN state\n")

        # ---- step 2: Bank 0 R/W registers ----------------------------------
        print("[test] ===== Bank 0 R/W registers =====")

        last_session_mask = (1 << (self.SLOT_INDEX_WIDTH - 1)) - 1
        self.set_last_session(last_session_mask)
        check("REG_LAST_SESSION",       last_session_mask, self.get_last_session(), mask=last_session_mask)

        self.set_amt_query(0xDEADBEEF)
        check("REG_AMT_QUERY",          0xDEADBEEF, self.get_amt_query())

        self.set_amt_query_per_iter(0xCAFEBABE)
        check("REG_AMT_QUERY_PER_ITER", 0xCAFEBABE, self.get_amt_query_per_iter())

        self.set_dma_ip_addr(0x12345678)
        check("REG_DMA_IP_ADDR",        0x12345678, self.get_dma_ip_addr())

        self.set_pr_ip_addr(0x87654321)
        check("REG_PR_IP_ADDR",         0x87654321, self.get_pr_ip_addr())

        self.set_intr_ena(0x1)
        check("REG_INTR_ENA",           0x1,        self.get_intr_ena(),           mask=0x1)

        # mperf free-runs while recon/exec engine is not in SHUTDOWN, so the
        # read-back is only deterministic when both engines are confirmed idle
        mperf_checked = (self.get_recon_state() == 0) and (self.get_exec_state() == 0)
        if mperf_checked:
            self.set_mperf(0x5A5A5A5A)
            check("REG_MPERF",          0x5A5A5A5A, self.get_mperf())
        else:
            print("  [SKIP] REG_MPERF — recon/exec engine not in SHUTDOWN (counter free-running)")

        # ---- step 3: Bank 1 slot registers ---------------------------------
        print(f"\n[test] ===== Bank 1 slot registers (0..{self.LIM_AMT_SLOT - 1}) =====")

        for s in range(self.LIM_AMT_SLOT):
            print(f"\n  -- slot {s} --")

            src_addr      = (0xA0000000 | (s << 16)) & 0xFFFFFFFF
            src_size      = (0x00100000 | (s <<  8)) & 0x3FFFFFF   # 26-bit
            des_addr      = (0xB0000000 | (s << 16)) & 0xFFFFFFFF
            des_size      = (0x00200000 | (s <<  8)) & 0x3FFFFFF   # 26-bit
            prof_recon    = (0xAABBCC00 | s)         & 0xFFFFFFFF
            prof_exec     = (0x11223300 | s)         & 0xFFFFFFFF
            onehot_mask   = (1 << self.NUM_REGION) - 1
            streamer_mask = (1 << self.NUM_STREAMER) - 1
            rm_recon_sel  = (1 << (s % self.NUM_REGION)) & onehot_mask   # one-hot, NUM_PR_REGION-bit
            rm_exec_sel   = (1 << (s % self.NUM_REGION)) & onehot_mask   # one-hot, NUM_PR_REGION-bit
            load_mask     = (0xAA | s)  & streamer_mask             # NUM_STREAMER-bit
            store_mask    = (0x55 | s)  & streamer_mask             # NUM_STREAMER-bit
            complete_mask = (0x33 | s)  & streamer_mask             # NUM_STREAMER-bit
            next_session  = (s + 1) % self.LIM_AMT_SLOT            # 3-bit, linked-list chain

            self.set_slot(self.SLOT_DMA_SRC_ADDR,    s, src_addr)
            self.set_slot(self.SLOT_DMA_SRC_SIZE,    s, src_size)
            self.set_slot(self.SLOT_DMA_DES_ADDR,    s, des_addr)
            self.set_slot(self.SLOT_DMA_DES_SIZE,    s, des_size)
            self.set_slot(self.SLOT_PROF_RECON,      s, prof_recon)
            self.set_slot(self.SLOT_PROF_EXEC,       s, prof_exec)
            self.set_slot(self.SLOT_VS_RM_RECON_SEL, s, rm_recon_sel)
            self.set_slot(self.SLOT_VS_RM_EXEC_SEL,  s, rm_exec_sel)
            self.set_slot(self.SLOT_LOAD_MASK,       s, load_mask)
            self.set_slot(self.SLOT_STORE_MASK,      s, store_mask)
            self.set_slot(self.SLOT_COMPLETE_MASK,   s, complete_mask)
            self.set_slot(self.SLOT_NEXT_SESSION,    s, next_session)

            (rb_src_addr, rb_src_size, rb_des_addr, rb_des_size,
             rb_prof_recon, rb_prof_exec, rb_rm_recon_sel, rb_rm_exec_sel,
             rb_load_mask, rb_store_mask, rb_complete_mask,
             rb_next_session) = self.get_slot(s)

            check(f"slot[{s}] SLOT_DMA_SRC_ADDR",    src_addr,      rb_src_addr)
            check(f"slot[{s}] SLOT_DMA_SRC_SIZE",    src_size,      rb_src_size,     mask=0x3FFFFFF)
            check(f"slot[{s}] SLOT_DMA_DES_ADDR",    des_addr,      rb_des_addr)
            check(f"slot[{s}] SLOT_DMA_DES_SIZE",    des_size,      rb_des_size,     mask=0x3FFFFFF)
            check(f"slot[{s}] SLOT_PROF_RECON",      prof_recon,    rb_prof_recon)
            check(f"slot[{s}] SLOT_PROF_EXEC",       prof_exec,     rb_prof_exec)
            check(f"slot[{s}] SLOT_VS_RM_RECON_SEL", rm_recon_sel,  rb_rm_recon_sel, mask=onehot_mask)
            check(f"slot[{s}] SLOT_VS_RM_EXEC_SEL",  rm_exec_sel,   rb_rm_exec_sel,  mask=onehot_mask)
            check(f"slot[{s}] SLOT_LOAD_MASK",       load_mask,     rb_load_mask,    mask=streamer_mask)
            check(f"slot[{s}] SLOT_STORE_MASK",      store_mask,    rb_store_mask,   mask=streamer_mask)
            check(f"slot[{s}] SLOT_COMPLETE_MASK",   complete_mask, rb_complete_mask,mask=streamer_mask)
            check(f"slot[{s}] SLOT_NEXT_SESSION",    next_session,  rb_next_session, mask=(1 << self.SLOT_INDEX_WIDTH) - 1)

        # ---- step 4: summary -----------------------------------------------
        total  = (7 if mperf_checked else 6) + self.LIM_AMT_SLOT * 12
        passed = total - len(failures)
        print(f"\n[test] ===== Result: {passed}/{total} passed =====")
        if failures:
            print("[test] FAILED registers:")
            for name, exp, got in failures:
                print(f"         {name}: expected={hex(exp)}, got={hex(got)}")
        else:
            print("[test] All registers PASSED")
        return len(failures) == 0
