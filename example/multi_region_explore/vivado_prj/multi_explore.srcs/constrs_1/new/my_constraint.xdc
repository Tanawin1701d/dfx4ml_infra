


create_pblock pblock_hier_1_1
set_property SNAPPING_MODE ON [get_pblocks pblock_hier_1_1]
create_pblock pblock_hier_1_2
add_cells_to_pblock [get_pblocks pblock_hier_1_2] [get_cells -quiet [list system_i/hier_1]]
resize_pblock [get_pblocks pblock_hier_1_2] -add {SLICE_X0Y0:SLICE_X40Y119}
resize_pblock [get_pblocks pblock_hier_1_2] -add {DSP48E2_X0Y0:DSP48E2_X11Y47}
resize_pblock [get_pblocks pblock_hier_1_2] -add {IOB_X0Y0:IOB_X1Y103}
resize_pblock [get_pblocks pblock_hier_1_2] -add {RAMB18_X0Y0:RAMB18_X0Y47}
resize_pblock [get_pblocks pblock_hier_1_2] -add {RAMB36_X0Y0:RAMB36_X0Y23}
set_property SNAPPING_MODE ON [get_pblocks pblock_hier_1_2]
create_pblock pblock_hier_0_1
add_cells_to_pblock [get_pblocks pblock_hier_0_1] [get_cells -quiet [list system_i/hier_0]]
resize_pblock [get_pblocks pblock_hier_0_1] -add {CLOCKREGION_X0Y2:CLOCKREGION_X1Y3}
set_property SNAPPING_MODE ON [get_pblocks pblock_hier_0_1]
