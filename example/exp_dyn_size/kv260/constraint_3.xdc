current_instance -quiet
create_pblock pblock_dfx_pr_0_0
add_cells_to_pblock [get_pblocks pblock_dfx_pr_0_0] [get_cells -quiet [list dfx4ml_i/dfx_pr_0_0]]
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {CLOCKREGION_X1Y0:CLOCKREGION_X2Y2}
set_property SNAPPING_MODE ON [get_pblocks pblock_dfx_pr_0_0]

# Vivado Generated miscellaneous constraints 

#revert back to original instance
current_instance -quiet
