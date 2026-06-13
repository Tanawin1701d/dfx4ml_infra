import subprocess
import os
import shutil


class HwBuildHelper:

    VIVADO_PRJ_FOLDER_NAME    = "link_prj"
    HWH_PATH_REL              = f"{VIVADO_PRJ_FOLDER_NAME}.gen/sources_1/bd/dfx4ml/hw_handoff/dfx4ml.hwh"
    DFX_CTRL_CON_PATH_REL     = (f"{VIVADO_PRJ_FOLDER_NAME}.gen/sources_1/bd/dfx4ml/bd/dfx_unified_inst_0/ip/"
                                 f"dfx_unified_inst_0_DFX_Ctrl_B_0/documentation/configuration_information.txt")
    IMPLEMENTATION_NAME       = "impl_dfx"
    CHILD_IMPL_TEMPLATE_NAME  = "child_{idx}_impl_dfx"
    # {r} = region index, {m} = rm index within region
    PAR_BIN_TEMPLATE_NAME     = ("dfx4ml_i_dfx_pr_region_{r}_0"
                                 "_dfx_pr_region_{r}_rm_{m}_inst_0_partial.bin")
    FULL_BIN_NAME             = "dfx4ml_wrapper.bin"
    DFX_UNIFED_VLNV           = "xilinx.com:ip:dfx_unified:1.0"

    def __init__(self,
                 build_folder_path,
                 dfx_root_path,
                 board,
                 user_repo_path,
                 user_rm_build_tcl_path,
                 req_gen_ip,
                 num_core,
                 clk_frq,
                 rm_index_width,
                 dfx_streamers      = None,
                 dfx_regions        = None,
                 rm_schemetics      = None,
                 test_mode          = 1,
                 vivado_path        = "",
                 export_folder_path = "",
                 board_build_tcl    = "",
                 constraint_xdc     = "",
                 dfx                = None):
        # dfx_streamers : list of dicts, index 0 = DMA streamer
        #   each dict: { load_width: int(bytes), store_width: int(bytes),
        #                actual_width: int(bits), amount_row: int }
        # dfx_regions   : list of dicts, one per reconfigurable region
        #   each dict: { load_streamers: [global_streamer_idx,...],
        #                store_streamers: [global_streamer_idx,...] }
        # rm_schemetics : 2-D list [region_idx][rm_idx]
        #   each element dict: { load_io_map:  [(io_index, kernel_idx),...],
        #                        store_io_map: [(io_index, kernel_idx),...] }
        # dfx : convenience — the dict returned by
        #   lib.hls4ml_con.streamer_glue.compute_dfx_params(). When given, the
        #   dfx_streamers / dfx_regions / rm_schemetics are unpacked from it (an
        #   explicitly-passed value still wins over the dfx entry).
        if dfx is not None:
            if dfx_streamers is None: dfx_streamers = dfx["dfx_streamers"]
            if dfx_regions   is None: dfx_regions   = dfx["dfx_regions"]
            if rm_schemetics is None: rm_schemetics = dfx["rm_schemetics"]
        _missing_dfx = [n for n, v in (("dfx_streamers", dfx_streamers),
                                       ("dfx_regions", dfx_regions),
                                       ("rm_schemetics", rm_schemetics)) if v is None]
        if _missing_dfx:
            raise ValueError(
                f"missing {', '.join(_missing_dfx)}; pass them explicitly or supply "
                f"dfx=compute_dfx_params(...)")

        custom_params = {"board_build_tcl": board_build_tcl, "constraint_xdc": constraint_xdc}
        if board == "custom":
            missing = [k for k, v in custom_params.items() if not v]
            if missing:
                raise ValueError(f"{', '.join(missing)} must be specified when board='custom'")
        else:
            ignored = [k for k, v in custom_params.items() if v]
            for k in ignored:
                print(f"Warning: {k} is provided but will be ignored because board='{board}' "
                      f"(only used when board='custom')")

        self.ip_only_mode            = False
        _abspath = lambda p: os.path.abspath(p) if p else p
        self.build_folder_path       = _abspath(build_folder_path)
        self.dfx_root_path           = _abspath(dfx_root_path)
        self.board                   = board
        self.user_repo_path          = _abspath(user_repo_path)
        self.user_rm_build_tcl_path  = _abspath(user_rm_build_tcl_path)
        self.req_gen_ip              = req_gen_ip
        self.num_core                = num_core
        self.clk_frq                 = clk_frq
        self.rm_index_width          = rm_index_width
        self.dfx_streamers           = dfx_streamers
        self.dfx_regions             = dfx_regions
        self.rm_schemetics           = rm_schemetics
        self.test_mode               = test_mode
        self.vivado_path             = vivado_path
        self.export_folder_path      = _abspath(export_folder_path)
        self.board_build_tcl         = _abspath(board_build_tcl)
        self.constraint_xdc          = _abspath(constraint_xdc)

        # Derived counts
        self.num_dfx_streamer  = len(dfx_streamers)
        self.num_dfx_region    = len(dfx_regions)
        self.num_rm_per_region = [len(rms) for rms in rm_schemetics]
        self.total_rm          = sum(self.num_rm_per_region)

        # Validation

        if rm_index_width <= 0:
            raise ValueError("rm_index_width must be positive")

        if self.num_dfx_streamer == 0:
            raise ValueError("dfx_streamers must have at least one entry (DMA streamer at index 0)")

        required_streamer_keys = {"load_width", "store_width", "actual_width", "amount_row"}
        for i, s in enumerate(dfx_streamers):
            missing = required_streamer_keys - set(s.keys())
            if missing:
                raise ValueError(f"dfx_streamers[{i}] is missing keys: {missing}")

        if self.num_dfx_region == 0:
            raise ValueError("dfx_regions must have at least one entry")

        if len(rm_schemetics) != self.num_dfx_region:
            raise ValueError(
                f"len(rm_schemetics) ({len(rm_schemetics)}) must equal "
                f"len(dfx_regions) ({self.num_dfx_region})")

        if len(set(self.num_rm_per_region)) > 1:
            raise ValueError(
                f"all regions must have the same number of RMs, got: {self.num_rm_per_region}")

        required_region_keys = {"load_streamers", "store_streamers"}
        for r, region in enumerate(dfx_regions):
            missing = required_region_keys - set(region.keys())
            if missing:
                raise ValueError(f"dfx_regions[{r}] is missing keys: {missing}")
            for s_idx in region["load_streamers"]:
                if s_idx < 0 or s_idx >= self.num_dfx_streamer:
                    raise ValueError(
                        f"dfx_regions[{r}].load_streamers contains invalid index {s_idx}; "
                        f"valid range: 0..{self.num_dfx_streamer - 1}")
            for s_idx in region["store_streamers"]:
                if s_idx < 0 or s_idx >= self.num_dfx_streamer:
                    raise ValueError(
                        f"dfx_regions[{r}].store_streamers contains invalid index {s_idx}; "
                        f"valid range: 0..{self.num_dfx_streamer - 1}")
            if len(rm_schemetics[r]) == 0:
                raise ValueError(f"rm_schemetics[{r}] must have at least one RM entry")

        # Validate that no streamer is referenced more than 8 times across all regions'
        # load_streamers (each reference consumes one physical load port; max is 8).
        from collections import Counter
        load_port_usage = Counter()
        for region in dfx_regions:
            for s_idx in region["load_streamers"]:
                load_port_usage[s_idx] += 1
        for s_idx, count in load_port_usage.items():
            if count > 8:
                raise ValueError(
                    f"Streamer {s_idx} is referenced {count} times across all regions' "
                    f"load_streamers, but the maximum supported load ports per streamer is 8."
                )

    @classmethod
    def for_ip_only(cls, build_folder_path, dfx_root_path, vivado_path):
        """Create a minimal instance for IP-only composition (build_ip_only())."""
        obj = object.__new__(cls)
        _abspath = lambda p: os.path.abspath(p) if p else p
        obj.ip_only_mode      = True
        obj.build_folder_path = _abspath(build_folder_path)
        obj.dfx_root_path     = _abspath(dfx_root_path)
        obj.vivado_path       = vivado_path
        return obj

    def _list_to_tcl(self, obj):
        """Recursively convert Python list/dict/tuple/scalar to a Tcl value string."""
        if isinstance(obj, list):
            items = [self._list_to_tcl(i) for i in obj]
            return "{" + " ".join(items) + "}"
        if isinstance(obj, tuple):
            items = [self._list_to_tcl(i) for i in obj]
            return "{" + " ".join(items) + "}"
        if isinstance(obj, dict):
            items = []
            for k, v in obj.items():
                items.append(str(k))
                items.append(self._list_to_tcl(v))
            return "{" + " ".join(items) + "}"
        if obj == "":
            return '""'
        return str(obj)

    def run_build(self):
        """Reads a Tcl template, fills it with parameters, and invokes Vivado to run the build."""
        if self.ip_only_mode:
            raise RuntimeError(
                "run_build() cannot be called in IP generation only mode. "
                "Use build_ip_only() instead.")

        if not os.path.exists(self.build_folder_path):
            os.makedirs(self.build_folder_path)

        lib_dir        = os.path.dirname(os.path.abspath(__file__))
        template_path  = os.path.join(lib_dir, "run_build.tcl.template")
        project_root   = os.path.abspath(os.path.join(lib_dir, ".."))
        build_tcl_path = os.path.join(project_root, "hw", "build_script", "build.tcl")

        if not os.path.exists(template_path):
            raise FileNotFoundError(f"Template not found at {template_path}")

        with open(template_path, "r") as f:
            template_content = f.read()

        tcl_script = template_content.format(
            build_folder_path       = self.build_folder_path,
            dfx4ml_root             = self.dfx_root_path,
            build_tcl_path          = build_tcl_path,
            board                   = self.board,
            user_repo_path          = self.user_repo_path,
            user_rm_build_tcl_path  = self.user_rm_build_tcl_path,
            req_gen_ip              = self.req_gen_ip,
            num_core                = self.num_core,
            clk_frq                 = self.clk_frq,
            rm_index_width          = self.rm_index_width,
            num_dfx_streamer        = self.num_dfx_streamer,
            num_dfx_region          = self.num_dfx_region,
            dfx_streamers_list      = self._list_to_tcl(self.dfx_streamers),
            dfx_regions_list        = self._list_to_tcl(self.dfx_regions),
            rm_schemetics_list      = self._list_to_tcl(self.rm_schemetics),
            test_mode               = self.test_mode,
            board_build_tcl         = self.board_build_tcl,
            constraint_xdc          = self.constraint_xdc,
        )

        temp_tcl = os.path.join(self.build_folder_path, "run_build.tcl")
        with open(temp_tcl, "w") as f:
            f.write(tcl_script)

        print(f"Running Vivado with {temp_tcl}...")
        try:
            subprocess.run(
                [self.vivado_path, "-mode", "gui", "-source", temp_tcl],
                check=True, cwd=self.build_folder_path)
        except subprocess.CalledProcessError as e:
            print(f"Vivado execution failed with error: {e}")
        finally:
            pass

    def build_ip_only(self):
        """Composes all DFX4ML IPs only, without running synthesis or implementation."""
        if not os.path.exists(self.build_folder_path):
            os.makedirs(self.build_folder_path)

        lib_dir                = os.path.dirname(os.path.abspath(__file__))
        template_path          = os.path.join(lib_dir, "run_build_ip_only.tcl.template")
        project_root           = os.path.abspath(os.path.join(lib_dir, ".."))
        build_ip_only_tcl_path = os.path.join(project_root, "hw", "build_script", "build_ip_only.tcl")

        if not os.path.exists(template_path):
            raise FileNotFoundError(f"Template not found at {template_path}")

        with open(template_path, "r") as f:
            template_content = f.read()

        tcl_script = template_content.format(
            build_folder_path      = self.build_folder_path,
            dfx4ml_root            = self.dfx_root_path,
            build_ip_only_tcl_path = build_ip_only_tcl_path,
        )

        temp_tcl = os.path.join(self.build_folder_path, "run_build_ip_only.tcl")
        with open(temp_tcl, "w") as f:
            f.write(tcl_script)

        print(f"Running Vivado IP-only build with {temp_tcl}...")
        try:
            subprocess.run(
                [self.vivado_path, "-mode", "gui", "-source", temp_tcl],
                check=True, cwd=self.build_folder_path)
        except subprocess.CalledProcessError as e:
            print(f"Vivado execution failed with error: {e}")

    def augment_hwh_file(self, hwh_path):
        import re
        with open(hwh_path, "r") as f:
            lines = f.readlines()

        # Build set of internal sub-addresses to suppress (0xA0010000..0xA004FFFF
        # for fixed IPs, plus per-region PR ctrl at 0xA0050000+r*0x10000)
        _suppress_bases = set()
        for _base in [0xA0010000, 0xA0020000, 0xA0030000, 0xA0040000]:
            _suppress_bases.add(f'0x{_base:08X}')
        for _r in range(self.num_dfx_region):
            _suppress_bases.add(f'0x{0xA0050000 + _r * 0x00010000:08X}')

        # HIGHVALUE for the combined address map window seen by the host
        _high_val = f'0x{0xA0050000 + self.num_dfx_region * 0x00010000 - 1:08X}'

        new_lines = []
        for line in lines:
            if (('INSTANCE="dfx_unified_0"' in line) or
                    re.search(r'INSTANCE="dfx_pr_region_\d+_0"', line)) \
                    and ('<MEMRANGE' in line):
                if 'BASEVALUE="0xA0000000"' in line:
                    line = re.sub(r'HIGHVALUE="0x[0-9A-Fa-f]+"',
                                  f'HIGHVALUE="{_high_val}"', line)
                    line = re.sub(r'SLAVEBUSINTERFACE="s_axi_reg"',
                                  'SLAVEBUSINTERFACE="S_AXI_CTRL"', line)
                    new_lines.append(line)
                elif any(f'BASEVALUE="{b}"' in line for b in _suppress_bases):
                    print(f"Warning: Removing BASEVALUE from line: {line}")
                    continue
                else:
                    new_lines.append(line)
            elif 'FULLNAME="/dfx_unified_0"' in line and '<MODULE' in line:
                # convert the dfx_unified bd to ip that PYNQ can be recognized
                line = ('    <MODULE COREREVISION="1" FULLNAME="/dfx_unified_0" '
                        'HWVERSION="1.0" INSTANCE="dfx_unified_0" IPTYPE="PERIPHERAL" '
                        'IS_ENABLE="1" MODCLASS="PERIPHERAL" MODTYPE="dfx_unified" '
                        'VLNV="user.org:user:dfx_unified:1.0">\n')
                new_lines.append(line)
            else:
                new_lines.append(line)

        with open(hwh_path, "w") as f:
            f.writelines(new_lines)

    def package_export_files(self):
        if not os.path.exists(self.export_folder_path):
            os.makedirs(self.export_folder_path)

        out_hw_folder_path = os.path.join(self.export_folder_path, "hw")
        if not os.path.exists(out_hw_folder_path):
            os.makedirs(out_hw_folder_path)

        link_prj_folder_path = os.path.join(self.build_folder_path, self.VIVADO_PRJ_FOLDER_NAME)
        run_folder_path      = os.path.join(link_prj_folder_path,
                                             self.VIVADO_PRJ_FOLDER_NAME + ".runs")

        # Collect partial bitstreams.
        # Every (region, rm) pair gets its own child run (child_0, child_1, ...),
        # iterating regions then RMs in order — matching syn_and_impl in build.tcl.
        # impl_dfx is the static parent run only; partials come exclusively from child runs.
        child_idx = 0
        for region_idx, region_rms in enumerate(self.rm_schemetics):
            for rm_idx in range(len(region_rms)):
                impl_folder_path = os.path.join(
                    run_folder_path,
                    self.CHILD_IMPL_TEMPLATE_NAME.format(idx=child_idx))

                par_bin_path = os.path.join(
                    impl_folder_path,
                    self.PAR_BIN_TEMPLATE_NAME.format(r=region_idx, m=rm_idx))
                new_name = f"region_{region_idx}_rm_{rm_idx}.bin"
                shutil.copy(par_bin_path, os.path.join(out_hw_folder_path, new_name))
                child_idx += 1

        # Full bitstream
        full_bin_path    = os.path.join(run_folder_path, self.IMPLEMENTATION_NAME, self.FULL_BIN_NAME)
        shutil.copy(full_bin_path, os.path.join(out_hw_folder_path, "system.bin"))

        # Hardware handoff file
        hwh_path     = os.path.join(link_prj_folder_path, self.HWH_PATH_REL)
        new_hwh_path = os.path.join(out_hw_folder_path, "system.hwh")
        shutil.copy(hwh_path, new_hwh_path)
        self.augment_hwh_file(new_hwh_path)

        # DFX controller configuration
        dfx_ctrl_con_path = os.path.join(link_prj_folder_path, self.DFX_CTRL_CON_PATH_REL)
        shutil.copy(dfx_ctrl_con_path, os.path.join(out_hw_folder_path, "dfx_ctrl_con.txt"))
