import subprocess
import os
import shutil


class HwBuildHelper:

    VIVADO_PRJ_FOLDER_NAME   = "link_prj"
    HWH_PATH_REL             = f"{VIVADO_PRJ_FOLDER_NAME}.gen/sources_1/bd/dfx4ml/hw_handoff/dfx4ml.hwh"
    IMPLEMENTATION_NAME      = "impl_dfx"
    CHILD_IMPL_TEMPLATE_NAME = "child_{idx}_impl_dfx"
    PAR_BIN_TEMPLATE_NAME    = "dfx4ml_i_dfx_pr_0_0_dfx_pr_{idx}_inst_0_partial.bin"
    FULL_BIN_NAME            = "dfx4ml_wrapper.bin"

    def __init__(self,
                 build_folder_path       ,
                 dfx_root_path           ,
                 board                   ,
                 user_repo_path          ,
                 req_gen_ip              ,
                 num_core                ,
                 clk_frq                 ,
                 rm_index_width          ,
                 num_dfx_streamer        ,
                 interface_widths        ,
                 applied_interface_widths,
                 storage_index_widths    ,
                 num_actual_rm           ,
                 input_map_list          ,
                 output_map_list         ,
                 ip_map_list             ,
                 test_mode               ,
                 vivado_path             ,
                 export_folder_path) :
        # example input argument :
        # build_folder_path="./test_prj"
        # dfx_root_path="."
        # board="kv260"
        # user_repo_path=""
        # req_gen_ip=0
        # num_core=4
        # clk_frq=99999001
        # rm_index_width=2
        # num_dfx_streamer=2
        # interface_widths=None
        # applied_interface_widths=None
        # storage_index_widths=None
        # num_actual_rm=2
        # input_map_list=None
        # output_map_list=None
        # ip_map_list=None
        # test_mode=1
        # vivado_path="vivado"
        # export_folder_path="./export_folder_path"
        self.build_folder_path        = os.path.abspath(build_folder_path)
        self.dfx_root_path            = os.path.abspath(dfx_root_path)
        self.board                    = board
        self.user_repo_path           = user_repo_path
        self.req_gen_ip               = req_gen_ip
        self.num_core                 = num_core
        self.clk_frq                  = clk_frq
        self.rm_index_width           = rm_index_width
        self.num_dfx_streamer         = num_dfx_streamer
        self.interface_widths         = interface_widths
        self.applied_interface_widths = applied_interface_widths
        self.storage_index_widths     = storage_index_widths
        self.num_actual_rm            = num_actual_rm
        self.input_map_list           = input_map_list
        self.output_map_list          = output_map_list
        self.ip_map_list              = ip_map_list
        self.test_mode                = test_mode
        self.vivado_path              = vivado_path
        self.export_folder_path       = export_folder_path

        if self.num_actual_rm <= 0:
            raise ValueError("num_actual_rm must be positive")
        # Validate list lengths match num_actual_rm
        if input_map_list is not None and len(input_map_list) != num_actual_rm:
            raise ValueError(
                f"Length of input_map_list ({len(input_map_list)}) does not match num_actual_rm ({num_actual_rm})")
        if input_map_list is not None:
            for i, inner_list in enumerate(input_map_list):
                if len(inner_list) != rm_index_width:
                    raise ValueError(
                        f"Length of input_map_list[{i}] ({len(inner_list)}) does not match rm_index_width ({rm_index_width})")

        if output_map_list is not None and len(output_map_list) != num_actual_rm:
            raise ValueError(
                f"Length of output_map_list ({len(output_map_list)}) does not match num_actual_rm ({num_actual_rm})")


        if output_map_list is not None:
            for i, inner_list in enumerate(output_map_list):
                if len(inner_list) != rm_index_width:
                    raise ValueError(
                        f"Length of output_map_list[{i}] ({len(inner_list)}) does not match rm_index_width ({rm_index_width})")

        if ip_map_list is not None and len(ip_map_list) != num_actual_rm:
            raise ValueError(
                f"Length of ip_map_list ({len(ip_map_list)}) does not match num_actual_rm ({num_actual_rm})")

    def _list_to_tcl(self, lst):
        """Converts a Python list to a Tcl list string."""
        if isinstance(lst, list):
            items = [self._list_to_tcl(i) for i in lst]
            return "{" + " ".join(items) + "}"
        if lst == "":
            return '""'
        return str(lst)

    def run_build(self):
        """Reads a Tcl template, fills it with parameters, and invokes Vivado to run the build."""
        # Create build folder if it doesn't exist
        if not os.path.exists(self.build_folder_path):
            os.makedirs(self.build_folder_path)

        # Define paths
        lib_dir = os.path.dirname(os.path.abspath(__file__))
        template_path = os.path.join(lib_dir, "run_build.tcl.template")
        project_root = os.path.abspath(os.path.join(lib_dir, ".."))
        build_tcl_path = os.path.join(project_root, "hw", "build_script", "build.tcl")

        # Read template
        if not os.path.exists(template_path):
            raise FileNotFoundError(f"Template not found at {template_path}")
            
        with open(template_path, "r") as f:
            template_content = f.read()
            
        

        # Prepare substitutions
        tcl_script = template_content.format(
            build_folder_path        =self.build_folder_path,
            dfx4ml_root              =self.dfx_root_path,
            build_tcl_path           =build_tcl_path,
            board                    =self.board,
            user_repo_path           =self.user_repo_path,
            req_gen_ip               =self.req_gen_ip,
            num_core                 =self.num_core,
            clk_frq                  =self.clk_frq,
            rm_index_width           =self.rm_index_width,
            num_dfx_streamer         =self.num_dfx_streamer,
            interface_widths         =self._list_to_tcl(self.interface_widths),
            applied_interface_widths =self._list_to_tcl(self.applied_interface_widths),
            storage_index_widths     =self._list_to_tcl(self.storage_index_widths),
            num_actual_rm            =self.num_actual_rm,
            input_map_list           =self._list_to_tcl(self.input_map_list),
            output_map_list          =self._list_to_tcl(self.output_map_list),
            ip_map_list              =self._list_to_tcl(self.ip_map_list),
            test_mode                =self.test_mode
        )

        temp_tcl = os.path.join(self.build_folder_path, "run_build.tcl")
        with open(temp_tcl, "w") as f:
            f.write(tcl_script)

        print(f"Running Vivado with {temp_tcl}...")
        try:
            subprocess.run([self.vivado_path, "-mode", "gui", "-source", temp_tcl], check=True, cwd=self.build_folder_path)
        except subprocess.CalledProcessError as e:
            print(f"Vivado execution failed with error: {e}")
        finally:
            # Optionally remove the temporary file
            # os.remove(temp_tcl)
            pass

    def package_export_files(self):

        # make export path
        if not os.path.exists(self.export_folder_path):
            os.makedirs(self.export_folder_path)

        out_hw_folder_path = os.path.join(self.export_folder_path, "hw")
        if not os.path.exists(out_hw_folder_path):
            os.makedirs(out_hw_folder_path)


        #vivado_prj_path = os.path.join(self.build_folder_path, self.VIVADO_PRJ_FOLDER_NAME, self.VIVADO_PRJ_FILE_NAME)
        link_prj_folder_path = os.path.join(self.build_folder_path, self.VIVADO_PRJ_FOLDER_NAME)
        run_folder_path = os.path.join(link_prj_folder_path, self.VIVADO_PRJ_FOLDER_NAME + ".runs")

        # retrieve partial bin stream file
        for rm_idx in range(self.num_actual_rm):
            if (rm_idx == 0):
                impl_folder_path = os.path.join(run_folder_path, self.IMPLEMENTATION_NAME)
            else:
                impl_folder_path = os.path.join(run_folder_path, self.CHILD_IMPL_TEMPLATE_NAME.format(idx=rm_idx))
            par_bin_path = os.path.join(impl_folder_path, self.PAR_BIN_TEMPLATE_NAME.format(idx=rm_idx))

            # Copy partial bitstream to output hardware folder
            new_name = f"rm_{rm_idx}.bin"
            shutil.copy(par_bin_path, os.path.join(out_hw_folder_path, new_name))

        # retrieve full bin stream file
        full_bin_path = os.path.join(run_folder_path, self.IMPLEMENTATION_NAME, self.FULL_BIN_NAME)
        new_full_bin_name = "system.bin"
        shutil.copy(full_bin_path, os.path.join(out_hw_folder_path, new_full_bin_name))

        # retrieve hwh
        hwh_path = os.path.join(link_prj_folder_path, self.HWH_PATH_REL)
        new_hwh_name = "system.hwh"
        shutil.copy(hwh_path, os.path.join(out_hw_folder_path, new_hwh_name))

