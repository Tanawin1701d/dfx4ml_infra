# Vivado script to create project for KV260 board and call create_root_design

# Set project parameters
set project_name "test_prj"
set project_dir "./test_prj"
set bd_name "dfx_unified"
set part "xck26-sfvc784-2LV-c"
set board_part "xilinx.com:kv260_som:part0:1.4"

# Add IP repository
set project_root [file normalize [file join [file dirname [info script]] ../]]

source [file join $project_root build_script build.tcl]

set clk_frq 99999001
set rm_index_width 2

# Two streamers (index 0 = DMA pass-through, index 1 = load/store)
# Each dict: load_width (bytes), store_width (bytes), actual_width (bits), amount_row
set dfx_streamers_list [list \
    {load_width 4 store_width 4 actual_width 32 amount_row 1024} \
    {load_width 4 store_width 4 actual_width 32 amount_row 1024} \
]

# One DFX region using streamer 1 for load and store
set dfx_regions_list [list \
    {load_streamers {1} store_streamers {1}} \
]

# One region, two RMs
# Each RM dict: load_io_map (list of {io_idx kernel_idx}), store_io_map
set rm_0_maps {load_io_map {{1 0}} store_io_map {{1 0}}}
set rm_1_maps {load_io_map {{1 0}} store_io_map {{1 0}}}
set rm_schemetics_list [list [list $rm_0_maps $rm_1_maps]]

set num_dfx_streamer [llength $dfx_streamers_list]
set num_dfx_region   [llength $dfx_regions_list]

set test_mode 1

set project_path [file join $project_root test_prj]
set board "kv260"
set req_gen_ip 0
set num_core 4
set user_repo_path ""
set user_rm_build_tcl_path ""
set board_build_tcl_path ""
set constraint_xdc_path ""

build $project_path  \
      [file normalize [file join [file dirname [info script]] ../..]] \
      $board \
      $user_repo_path \
      $user_rm_build_tcl_path \
      $req_gen_ip \
      $num_core \
      $clk_frq \
      $rm_index_width \
      $num_dfx_streamer \
      $num_dfx_region \
      $dfx_streamers_list \
      $dfx_regions_list \
      $rm_schemetics_list \
      $test_mode \
      $board_build_tcl_path \
      $constraint_xdc_path
