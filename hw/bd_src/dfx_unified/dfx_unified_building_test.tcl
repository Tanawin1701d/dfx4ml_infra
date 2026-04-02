# Vivado script to create project for KV260 board and call create_root_design

# Set project parameters
set project_name "test_prj"
set project_dir "./test_prj"
set bd_name "dfx_unified"
set part "xck26-sfvc784-2LV-c"
set board_part "xilinx.com:kv260_som:part0:1.4"

# Create project
create_project $project_name $project_dir -part $part -force
set_property board_part $board_part [current_project]

# Add IP repository
set project_root [file normalize [file join [file dirname [info script]] ../../]]
set_property  ip_repo_paths  [list [file join $project_root ip_repo]] [current_project]
update_ip_catalog

# Source the design script
source [file join [file dirname [info script]] dfx_unified.tcl]

# Define arguments for create_root_design
# These values are example parameters; adjust them according to your specific needs.
set clk_frq 99999001 ;
set rm_index_width 2 ;
set num_dfx_streamer 8 ; # dma included
set interface_widths [list 32 32 32 32 32 32 32 32] ;# Must be power of two
set applied_interface_widths [list 32 32 32 32 32 32 32 32] ;# Must be <= interface_widths
set storage_index_widths [list 10 10 10 10 10 10 10 10] ;

# Call create_dfx_unified_bd
create_dfx_unified_bd $parentCell $clk_frq $rm_index_width $num_dfx_streamer $interface_widths $applied_interface_widths $storage_index_widths