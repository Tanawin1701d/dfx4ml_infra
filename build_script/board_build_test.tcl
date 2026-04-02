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

set clk_frq 99999001 ;
set rm_index_width 2 ;
set num_dfx_streamer 2 ; # dma included
set interface_widths [list 32 32 ] ;# Must be power of two
set applied_interface_widths [list 32 32] ;# Must be <= interface_widths
set storage_index_widths [list 10 10] ;


set num_actual_rm 2

set input_maps [list 0 -1 ]
set output_maps [list -1 0 ]

set input_1_maps [list -1 0 ]
set output_1_maps [list 0 -1 ]

set input_map_list [list $input_maps $input_1_maps]
set output_map_list [list $output_maps $output_1_maps]
set ip_map_list [list "" ""]
set test_mode 1

set create_new_block 1

set ip_src ""

set project_path [file join $project_root test_prj]
set board "kv260"
set req_gen_ip 0
set num_core 4


build $project_path  \
      $board \
      $req_gen_ip \
      $num_core \
      $clk_frq \
      $rm_index_width \
      $num_dfx_streamer \
      $interface_widths \
      $applied_interface_widths \
      $storage_index_widths \
      $num_actual_rm\
      $input_map_list \
      $output_map_list \
      $ip_map_list \
      $test_mode