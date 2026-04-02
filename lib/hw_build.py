import subprocess
import os

class HwBuildHelper:
    def __init__(self, build_folder_path       , board               , user_repo_path  ,
                       req_gen_ip              , num_core            , clk_frq         ,
                       rm_index_width          , num_dfx_streamer    , interface_widths,
                       applied_interface_widths, storage_index_widths, num_actual_rm   ,           
                       input_map_list          , output_map_list     , ip_map_list     ,
                       test_mode               , vivado_path):
        # example input argument :
        # build_folder_path="./test_prj"
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
        self.build_folder_path        = os.path.abspath(build_folder_path)
        self.board                    = board
        self.user_repo_path           = user_repo_path
        self.req_gen_ip               = req_gen_ip
        self.num_core                 = num_core
        self.clk_frq                  = clk_frq
        self.rm_index_width           = rm_index_width
        self.num_dfx_streamer         = num_dfx_streamer
        self.interface_widths         = interface_widths if interface_widths is not None else [32, 32]
        self.applied_interface_widths = applied_interface_widths if applied_interface_widths is not None else [32, 32]
        self.storage_index_widths     = storage_index_widths if storage_index_widths is not None else [10, 10]
        self.num_actual_rm            = num_actual_rm
        self.input_map_list           = input_map_list if input_map_list is not None else [[0, -1], [-1, 0]]
        self.output_map_list          = output_map_list if output_map_list is not None else [[-1, 0], [0, -1]]
        self.ip_map_list              = ip_map_list if ip_map_list is not None else ["", ""]
        self.test_mode                = test_mode
        self.vivado_path              = vivado_path

    def _list_to_tcl(self, lst):
        """Converts a Python list to a Tcl list string."""
        if isinstance(lst, list):
            items = [self._list_to_tcl(i) for i in lst]
            return "{" + " ".join(items) + "}"
        return str(lst)

    def run_build(self):
        """Reads a Tcl template, fills it with parameters, and invokes Vivado to run the build."""
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
            build_folder_path=self.build_folder_path,
            build_tcl_path=build_tcl_path,
            project_path=self.project_path,
            board=self.board,
            user_repo_path=self.user_repo_path,
            req_gen_ip=self.req_gen_ip,
            num_core=self.num_core,
            clk_frq=self.clk_frq,
            rm_index_width=self.rm_index_width,
            num_dfx_streamer=self.num_dfx_streamer,
            interface_widths=self._list_to_tcl(self.interface_widths),
            applied_interface_widths=self._list_to_tcl(self.applied_interface_widths),
            storage_index_widths=self._list_to_tcl(self.storage_index_widths),
            num_actual_rm=self.num_actual_rm,
            input_map_list=self._list_to_tcl(self.input_map_list),
            output_map_list=self._list_to_tcl(self.output_map_list),
            ip_map_list=self._list_to_tcl(self.ip_map_list),
            test_mode=self.test_mode
        )

        temp_tcl = "run_build.tcl"
        with open(temp_tcl, "w") as f:
            f.write(tcl_script)

        print(f"Running Vivado with {temp_tcl}...")
        try:
            subprocess.run([self.vivado_path, "-mode", "batch", "-source", temp_tcl], check=True)
        except subprocess.CalledProcessError as e:
            print(f"Vivado execution failed with error: {e}")
        finally:
            # Optionally remove the temporary file
            # os.remove(temp_tcl)
            pass
