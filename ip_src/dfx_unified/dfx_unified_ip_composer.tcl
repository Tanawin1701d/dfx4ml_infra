# Vivado script to create project for KV260 board and call create_root_design

# Set project parameters
set project_name "kv260_dfx_project"
set project_dir "./kv260_dfx_project"
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

# Create block design
create_bd_design $bd_name

# Source the design script
source [file join [file dirname [info script]] dfx_unified.tcl]

# Define arguments for create_root_design
# These values are example parameters; adjust them according to your specific needs.
set parentCell ""
set clk_frq 99999001 ;
set rm_index_width 2 ;
set num_dfx_streamer 8 ; # dma included
set interface_widths [list 32 32 32 32 32 32 32 32] ;# Must be power of two
set applied_interface_widths [list 32 32 32 32 32 32 32 32] ;# Must be <= interface_widths
set storage_index_widths [list 10 10 10 10 10 10 10 10] ;

# Call create_root_design
create_root_design $parentCell $clk_frq $rm_index_width $num_dfx_streamer $interface_widths $applied_interface_widths $storage_index_widths

# Finalize block design
save_bd_design
validate_bd_design
make_wrapper -files [get_files ${project_dir}/${project_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd] -top
add_files -norecurse ${project_dir}/${project_name}.gen/sources_1/bd/${bd_name}/hdl/${bd_name}_wrapper.v

puts "Project $project_name created successfully with KV260 board support."


ipx::package_project -root_dir [file join $project_root ip_repo dfx_unified] -vendor user.org -library user -taxonomy /UserIP -import_files -set_current false -force

ipx::unload_core [file join $project_root ip_repo dfx_unified component.xml]
ipx::edit_ip_in_project -upgrade true -name tmp_edit_project -directory [file join $project_root ip_repo dfx_unified ] [file join $project_root ip_repo dfx_unified component.xml]

set_property name dfx_unified [ipx::current_core]
set_property display_name dfx_unified_v1_0 [ipx::current_core]
set_property description dfx_unified_v1_0 [ipx::current_core]

set_property ipi_drc {ignore_freq_hz false} [ipx::current_core]
set_property sdx_kernel true [ipx::current_core]
set_property sdx_kernel_type rtl [ipx::current_core]
set_property vitis_drc {ctrl_protocol ap_ctrl_none} [ipx::current_core]

ipx::save_core [ipx::current_core]
file delete -force [file join $project_root ip_repo unified_xo dfx_unified.xo]
package_xo  -xo_path [file join $project_root ip_repo unified_xo dfx_unified.xo] -kernel_name dfx_unified -ip_directory [file join $project_root ip_repo dfx_unified] -ctrl_protocol ap_ctrl_none

close_project