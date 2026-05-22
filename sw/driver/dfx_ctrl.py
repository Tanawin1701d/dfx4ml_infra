from pynq import allocate
import numpy as np
import re


class DFX_Ctrl:
    def __init__(self, host_ip, offset):

        self.offset = offset
        self.host_ip = host_ip
        self.is_meta_configured = False
        self.storage          = None
        # BLS Bit Layout Size
        self.BLS_DATA   = 2
        self.BLS_REGID  = 4
        self.BLS_BANKID = 2
        self.BLS_VSID   = 1
        # |-- BLS_VSID --|-- BLS_BANKID --|-- BLS_REG_ID --|-- BLS_DATA --|
        # GENERAL BANK
        self.BANK_GENREG      = 0
        self.GENREG_STATUS    = 0
        self.GENREG_CTRL      = 0
        self.GENREG_SWTRIGGER = 1
        # TRIGGER RM MAPPING
        self.BANK_RMM    = 1
        # RM INFO
        self.BANK_RMINFO = 2
        # BITSTREAM INFO
        self.BANK_BSINFO = 3

    def read(self, addr):
        return self.host_ip.read(self.offset + addr)

    def write(self, addr, value):
        self.host_ip.write(self.offset + addr, value)

    # ── print helpers ─────────────────────────────────────────────────────────

    @staticmethod
    def _hdr(slot_id: int, label: str) -> str:
        return f"  [slot {slot_id}] {label}"

    @staticmethod
    def _rd(slot_id: int, name: str, addr: int) -> None:
        print(f"  rd  slot {slot_id}  {name:<16}  @{addr:#010x}")

    @staticmethod
    def _wr(slot_id: int, name: str, addr: int, val: int) -> None:
        print(f"  wr  slot {slot_id}  {name:<16}  @{addr:#010x}  ← {val:#010x}")

    # ── config ────────────────────────────────────────────────────────────────

    def config(self, meta_path):
        vs_idx, reg_bank_idx, reg_col_idx = self._retrieve_config(meta_path)
        self.BLS_VSID   = vs_idx[1]       - vs_idx[0]       + 1
        self.BLS_REGID  = reg_col_idx[1]  - reg_col_idx[0]  + 1
        self.BLS_BANKID = reg_bank_idx[1] - reg_bank_idx[0] + 1
        self.is_meta_configured = True
        print(f"  config  vs=[{vs_idx[1]}:{vs_idx[0]}]"
              f"  bank=[{reg_bank_idx[1]}:{reg_bank_idx[0]}]"
              f"  reg=[{reg_col_idx[1]}:{reg_col_idx[0]}]"
              f"  →  VSID={self.BLS_VSID}  BANKID={self.BLS_BANKID}  REGID={self.BLS_REGID}")

    def _retrieve_config(self, path):
        vs_idx       = None
        reg_bank_idx = None
        reg_col_idx  = None
        with open(path, 'r') as file:
            for line in file:
                if "Selects the Virtual Socket Manager" in line:
                    vs_idx = self._extract_bit_range(line)
                if "Selects the Register Bank" in line:
                    reg_bank_idx = self._extract_bit_range(line)
                if "Selects the Register within the bank" in line:
                    reg_col_idx = self._extract_bit_range(line)
        return vs_idx, reg_bank_idx, reg_col_idx

    @staticmethod
    def _extract_bit_range(line):
        match = re.search(r'\[\s*(\d+)\s*:\s*(\d+)\s*]', line)
        if match:
            return int(match.group(2)), int(match.group(1))
        return None

    # ── address generator ─────────────────────────────────────────────────────

    def _get_address(self, slot_id, bank_id, reg_id):
        if not self.is_meta_configured:
            raise Exception("DFX_Ctrl is not configured — call config() first")
        vs_shift   = self.BLS_DATA + self.BLS_REGID + self.BLS_BANKID
        bank_shift = self.BLS_DATA + self.BLS_REGID
        return (slot_id << vs_shift) + (bank_id << bank_shift) + (reg_id << self.BLS_DATA)

    # ── general commands ──────────────────────────────────────────────────────

    def shutdown_engine(self, slot_id):
        print(self._hdr(slot_id, "SHUTDOWN"))
        self.set_ctrl(slot_id, 0)

    def restart_no_status(self, slot_id):
        print(self._hdr(slot_id, "RESTART  (no-status)"))
        self.set_ctrl(slot_id, 1)

    def restart_with_status(self, slot_id):   # TODO please check
        print(self._hdr(slot_id, "RESTART  (with-status)"))

    def trig(self, slot_id, trigger_id):
        print(self._hdr(slot_id, f"TRIG     trigger={trigger_id}"))
        self.set_ctrl_trigger(slot_id, trigger_id)

    # ── getters / setters ─────────────────────────────────────────────────────

    def get_status(self, slot_id):
        addr = self._get_address(slot_id, self.BANK_GENREG, self.GENREG_STATUS)
        self._rd(slot_id, "STATUS", addr)
        return self.read(addr)

    def get_ctrl(self, slot_id):
        addr = self._get_address(slot_id, self.BANK_GENREG, self.GENREG_CTRL)
        self._rd(slot_id, "CTRL", addr)
        return self.read(addr)

    def set_ctrl(self, slot_id, command):
        addr = self._get_address(slot_id, self.BANK_GENREG, self.GENREG_CTRL)
        self._wr(slot_id, "CTRL", addr, command)
        self.write(addr, command)

    def get_ctrl_trigger(self, slot_id):
        addr = self._get_address(slot_id, self.BANK_GENREG, self.GENREG_SWTRIGGER)
        self._rd(slot_id, "SW_TRIGGER", addr)
        return self.read(addr)

    def set_ctrl_trigger(self, slot_id, trigger_id):
        addr = self._get_address(slot_id, self.BANK_GENREG, self.GENREG_SWTRIGGER)
        self._wr(slot_id, "SW_TRIGGER", addr, trigger_id)
        self.write(addr, trigger_id)

    def get_rmm(self, slot_id, trigger_id):
        addr = self._get_address(slot_id, self.BANK_RMM, trigger_id)
        self._rd(slot_id, f"RM_MAP[{trigger_id}]", addr)
        return self.read(addr)

    def set_rmm(self, slot_id, trigger_id, info_id):
        addr = self._get_address(slot_id, self.BANK_RMM, trigger_id)
        self._wr(slot_id, f"RM_MAP[{trigger_id}]", addr, info_id)
        self.write(addr, info_id)

    def get_rm_info(self, slot_id, info_id):
        bs_addr   = self._get_address(slot_id, self.BANK_RMINFO, info_id * 2)
        ctrl_addr = self._get_address(slot_id, self.BANK_RMINFO, info_id * 2 + 1)
        self._rd(slot_id, f"RM_BS_IDX[{info_id}]", bs_addr)
        self._rd(slot_id, f"RM_CTRL[{info_id}]",   ctrl_addr)
        return self.read(bs_addr), self.read(ctrl_addr)

    def set_rm_info(self, slot_id, info_id, bs_idx, ctrl_cmd):
        bs_addr   = self._get_address(slot_id, self.BANK_RMINFO, info_id * 2)
        ctrl_addr = self._get_address(slot_id, self.BANK_RMINFO, info_id * 2 + 1)
        self._wr(slot_id, f"RM_BS_IDX[{info_id}]", bs_addr,   bs_idx)
        self._wr(slot_id, f"RM_CTRL[{info_id}]",   ctrl_addr, ctrl_cmd)
        self.write(bs_addr,   bs_idx)
        self.write(ctrl_addr, ctrl_cmd)

    def get_bs_info(self, slot_id, bs_id):
        ident_addr  = self._get_address(slot_id, self.BANK_BSINFO, bs_id * 4)
        stream_addr = self._get_address(slot_id, self.BANK_BSINFO, bs_id * 4 + 1)
        size_addr   = self._get_address(slot_id, self.BANK_BSINFO, bs_id * 4 + 2)
        self._rd(slot_id, f"BS_ID[{bs_id}]",      ident_addr)
        self._rd(slot_id, f"BS_ADDR[{bs_id}]",    stream_addr)
        self._rd(slot_id, f"BS_SIZE[{bs_id}]",    size_addr)
        return self.read(ident_addr), self.read(stream_addr), self.read(size_addr)

    def set_bs_info(self, slot_id, bs_id, phy_stream_addr, stream_size):
        ident_addr  = self._get_address(slot_id, self.BANK_BSINFO, bs_id * 4)
        stream_addr = self._get_address(slot_id, self.BANK_BSINFO, bs_id * 4 + 1)
        size_addr   = self._get_address(slot_id, self.BANK_BSINFO, bs_id * 4 + 2)
        self._wr(slot_id, f"BS_ID[{bs_id}]",   ident_addr,  1)
        self._wr(slot_id, f"BS_ADDR[{bs_id}]", stream_addr, phy_stream_addr)
        self._wr(slot_id, f"BS_SIZE[{bs_id}]", size_addr,   stream_size)
        self.write(ident_addr,  1)
        self.write(stream_addr, phy_stream_addr)
        self.write(size_addr,   stream_size)

    # ── auto meta-data ────────────────────────────────────────────────────────

    def set_simple_meta_data(self, slot_id, idx, stream_phy_addr, stream_phy_size):
        ctrl_value = 0b0_10_0_00
        print(f"  -- set_simple_meta_data  slot {slot_id}  idx {idx}"
              f"  addr={stream_phy_addr:#010x}  size={stream_phy_size}  ctrl={ctrl_value:#04x}")
        self.set_rmm    (slot_id, idx, idx)
        self.set_rm_info(slot_id, idx, idx, ctrl_value)
        self.set_bs_info(slot_id, idx, stream_phy_addr, stream_phy_size)

    # ── debug display ─────────────────────────────────────────────────────────

    def print_status(self, slot_id):
        status = self.get_status(slot_id)
        is_shutdown = (status >> 7) & 0x1
        error_code  = (status >> 3) & 0xF
        active_rm   = (status >> 8) & 0xFFFF
        state       =  status       & 0x7
        print(f"  ┌─ slot {slot_id}  STATUS ──────────────────┐")
        print(f"  │  state      : {state:#05x}                    │")
        print(f"  │  shutdown   : {'yes' if is_shutdown else 'no '}                     │")
        print(f"  │  error      : {error_code:#05x}                    │")
        print(f"  │  active RM  : {active_rm:#06x}                   │")
        print(f"  └────────────────────────────────────┘")

    def print_simple_meta_data(self, slot_id, idx):
        rmm              = self.get_rmm    (slot_id, idx)
        bs_idx, ctrl     = self.get_rm_info(slot_id, idx)
        ident, addr, sz  = self.get_bs_info(slot_id, idx)
        print(f"  ┌─ slot {slot_id}  row {idx} ──────────────────────────────────────────────┐")
        print(f"  │  RM_MAP  : {rmm:#010x}                                               │")
        print(f"  │  RM_INFO : bs_idx={bs_idx:#010x}  ctrl={ctrl:#010x}                   │")
        print(f"  │  BS_INFO : ident={ident:#010x}   addr={addr:#010x}   size={sz:<10} │")
        print(f"  └────────────────────────────────────────────────────────────────────┘")

    # ── CMA allocation ────────────────────────────────────────────────────────

    def allocate_bit_stream_cma(self, path):
        print(f"  cma  loading  {path}")
        with open(path, 'rb') as f:
            data = f.read()
        file_size = len(data)
        data_u32  = np.frombuffer(data, dtype='<u4')
        buffer    = allocate(shape=(len(data_u32),), dtype='>u4')
        buffer[:] = data_u32
        buffer.flush()   # write cache → DRAM so DMA sees fresh data
        print(f"       size={file_size}  phy_addr={buffer.physical_address:#010x}")
        return buffer, buffer.physical_address, file_size
