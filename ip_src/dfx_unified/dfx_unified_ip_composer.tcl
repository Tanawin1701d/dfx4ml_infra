# Vivado script to create project for KV260 board and call create_root_design

# Set project parameters
set project_name "kv260_dfx_project"
set project_dir "./kv260_dfx_project"
set bd_name "design_1"
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
set slot_index_width 3 ;# Must be a power of two
set interface_widths [list 32 32 32 32 32 32 32 32] ;# Must be power of two
set applied_interface_widths [list 32 32 32 32 32 32 32 32] ;# Must be <= interface_widths

# Call create_root_design
create_root_design $parentCell $slot_index_width $interface_widths $applied_interface_widths

# Finalize block design
save_bd_design
validate_bd_design
make_wrapper -files [get_files ${project_dir}/${project_name}.srcs/sources_1/bd/${bd_name}/${bd_name}.bd] -top
add_files -norecurse ${project_dir}/${project_name}.gen/sources_1/bd/${bd_name}/hdl/${bd_name}_wrapper.v

puts "Project $project_name created successfully with KV260 board support."
