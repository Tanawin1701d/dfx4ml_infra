create_pblock pblock_hier_1
add_cells_to_pblock [get_pblocks pblock_hier_1] [get_cells -quiet [list system_i/hier_1]]
resize_pblock [get_pblocks pblock_hier_1] -add {SLICE_X28Y60:SLICE_X34Y75}
resize_pblock [get_pblocks pblock_hier_1] -add {DSP48E2_X7Y24:DSP48E2_X9Y29}
set_property SNAPPING_MODE ON [get_pblocks pblock_hier_1]


create_pblock pblock_hier_0
add_cells_to_pblock [get_pblocks pblock_hier_0] [get_cells -quiet [list system_i/hier_0]]
resize_pblock [get_pblocks pblock_hier_0] -add {SLICE_X29Y137:SLICE_X35Y152}
resize_pblock [get_pblocks pblock_hier_0] -add {DSP48E2_X7Y56:DSP48E2_X9Y59}
set_property SNAPPING_MODE ON [get_pblocks pblock_hier_0]
