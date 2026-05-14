# Pblock definitions for DFX reconfigurable regions.
# Add one pblock entry per region matching the num_dfx_region in your build config.
# Cell names follow the pattern: dfx4ml_i/dfx_pr_region_<R>_0

# create_pblock pblock_dfx_pr_region_0_0
# add_cells_to_pblock [get_pblocks pblock_dfx_pr_region_0_0] [get_cells -quiet [list dfx4ml_i/dfx_pr_region_0_0]]
# resize_pblock [get_pblocks pblock_dfx_pr_region_0_0] -add {CLOCKREGION_X1Y1:CLOCKREGION_X2Y1}
# set_property SNAPPING_MODE ON [get_pblocks pblock_dfx_pr_region_0_0]

# Example second region (uncomment and adjust clock region for your floorplan):
# create_pblock pblock_dfx_pr_region_1_0
# add_cells_to_pblock [get_pblocks pblock_dfx_pr_region_1_0] [get_cells -quiet [list dfx4ml_i/dfx_pr_region_1_0]]
# resize_pblock [get_pblocks pblock_dfx_pr_region_1_0] -add {CLOCKREGION_X0Y1:CLOCKREGION_X0Y2}
# set_property SNAPPING_MODE ON [get_pblocks pblock_dfx_pr_region_1_0]

create_pblock pblock_dfx_pr_region_0_0
add_cells_to_pblock [get_pblocks pblock_dfx_pr_region_0_0] [get_cells -quiet [list dfx4ml_i/dfx_pr_region_0_0]]
resize_pblock [get_pblocks pblock_dfx_pr_region_0_0] -add {SLICE_X0Y0:SLICE_X40Y119}
resize_pblock [get_pblocks pblock_dfx_pr_region_0_0] -add {DSP48E2_X0Y0:DSP48E2_X11Y47}
resize_pblock [get_pblocks pblock_dfx_pr_region_0_0] -add {IOB_X0Y0:IOB_X1Y103}
resize_pblock [get_pblocks pblock_dfx_pr_region_0_0] -add {RAMB18_X0Y0:RAMB18_X0Y47}
resize_pblock [get_pblocks pblock_dfx_pr_region_0_0] -add {RAMB36_X0Y0:RAMB36_X0Y23}
set_property SNAPPING_MODE ON [get_pblocks pblock_dfx_pr_region_0_0]

create_pblock pblock_dfx_pr_region_1_0
add_cells_to_pblock [get_pblocks pblock_dfx_pr_region_1_0] [get_cells -quiet [list dfx4ml_i/dfx_pr_region_1_0]]
resize_pblock [get_pblocks pblock_dfx_pr_region_1_0] -add {CLOCKREGION_X0Y2:CLOCKREGION_X1Y3}
set_property SNAPPING_MODE ON [get_pblocks pblock_dfx_pr_region_1_0]