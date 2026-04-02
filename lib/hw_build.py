import argparse
import subprocess
import os
import json

def list_to_tcl(lst):
    """Converts a Python list to a Tcl list string."""
    if isinstance(lst, list):
        items = [list_to_tcl(i) for i in lst]
        return "{" + " ".join(items) + "}"
    return str(lst)

def invoke_vivado_build(args, interface_widths, applied_interface_widths, storage_index_widths, input_map_list, output_map_list, ip_map_list):
    """Generates a temporary Tcl script and invokes Vivado to run the build."""
    # Prepare Tcl script content
    project_root = os.path.abspath(os.path.join(os.path.dirname(__file__), "."))
    build_tcl_path = os.path.join(project_root, "build_script", "build.tcl")
    
    tcl_script = f"""
# Auto-generated Tcl script from Python wrapper
set project_root "{project_root}"
source "{build_tcl_path}"

set project_path "{os.path.abspath(args.project_path)}"
set board "{args.board}"
set user_repo_path "{args.user_repo_path}"
set req_gen_ip {args.req_gen_ip}
set num_core {args.num_core}
set clk_frq {args.clk_frq}
set rm_index_width {args.rm_index_width}
set num_dfx_streamer {args.num_dfx_streamer}

set interface_widths {list_to_tcl(interface_widths)}
set applied_interface_widths {list_to_tcl(applied_interface_widths)}
set storage_index_widths {list_to_tcl(storage_index_widths)}

set num_actual_rm {args.num_actual_rm}
set input_map_list {list_to_tcl(input_map_list)}
set output_map_list {list_to_tcl(output_map_list)}
set ip_map_list {list_to_tcl(ip_map_list)}
set test_mode {args.test_mode}

build $project_path \\
      $board \\
      $user_repo_path \\
      $req_gen_ip \\
      $num_core \\
      $clk_frq \\
      $rm_index_width \\
      $num_dfx_streamer \\
      $interface_widths \\
      $applied_interface_widths \\
      $storage_index_widths \\
      $num_actual_rm \\
      $input_map_list \\
      $output_map_list \\
      $ip_map_list \\
      $test_mode
"""

    temp_tcl = "run_build.tcl"
    with open(temp_tcl, "w") as f:
        f.write(tcl_script)

    print(f"Running Vivado with {temp_tcl}...")
    try:
        subprocess.run([args.vivado_path, "-mode", "batch", "-source", temp_tcl], check=True)
    except subprocess.CalledProcessError as e:
        print(f"Vivado execution failed with error: {e}")
    finally:
        # Optionally remove the temporary file
        # os.remove(temp_tcl)
        pass

def main():
    parser = argparse.ArgumentParser(description="Invoke Vivado build script with parameters.")
    
    # Project Parameters
    parser.add_argument("--project_path", type=str, default="./test_prj", help="Path to the project directory")
    parser.add_argument("--board", type=str, default="kv260", help="Board name (e.g., kv260)")
    parser.add_argument("--user_repo_path", type=str, default="", help="Path to user IP repository")
    parser.add_argument("--req_gen_ip", type=int, default=0, help="Request IP generation (0 or 1)")
    parser.add_argument("--num_core", type=int, default=4, help="Number of CPU cores for synthesis/implementation")
    
    # Design Parameters
    parser.add_argument("--clk_frq", type=int, default=99999001, help="Clock frequency")
    parser.add_argument("--rm_index_width", type=int, default=2, help="RM index width")
    parser.add_argument("--num_dfx_streamer", type=int, default=2, help="Number of DFX streamers")
    
    # List Parameters (expected as JSON strings or comma-separated)
    parser.add_argument("--interface_widths", type=str, default="[32, 32]", help="Interface widths (JSON list)")
    parser.add_argument("--applied_interface_widths", type=str, default="[32, 32]", help="Applied interface widths (JSON list)")
    parser.add_argument("--storage_index_widths", type=str, default="[10, 10]", help="Storage index widths (JSON list)")
    
    # RM and Map Parameters
    parser.add_argument("--num_actual_rm", type=int, default=2, help="Number of actual RMs")
    parser.add_argument("--input_map_list", type=str, default="[[0, -1], [-1, 0]]", help="Input map list (JSON nested list)")
    parser.add_argument("--output_map_list", type=str, default="[[-1, 0], [0, -1]]", help="Output map list (JSON nested list)")
    parser.add_argument("--ip_map_list", type=str, default='["", ""]', help="IP map list (JSON list)")
    
    parser.add_argument("--test_mode", type=int, default=1, help="Test mode (0 or 1)")
    
    parser.add_argument("--vivado_path", type=str, default="vivado", help="Path to vivado executable")

    args = parser.parse_args()

    # Parse JSON list arguments
    interface_widths = json.loads(args.interface_widths)
    applied_interface_widths = json.loads(args.applied_interface_widths)
    storage_index_widths = json.loads(args.storage_index_widths)
    input_map_list = json.loads(args.input_map_list)
    output_map_list = json.loads(args.output_map_list)
    ip_map_list = json.loads(args.ip_map_list)

    invoke_vivado_build(args, interface_widths, applied_interface_widths, storage_index_widths, input_map_list, output_map_list, ip_map_list)

if __name__ == "__main__":
    main()
