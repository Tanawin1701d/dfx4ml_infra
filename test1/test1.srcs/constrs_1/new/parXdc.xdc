create_pblock pblock_hls4ml
add_cells_to_pblock [get_pblocks pblock_hls4ml] [get_cells -quiet [list system_i/hls4ml]]
resize_pblock [get_pblocks pblock_hls4ml] -add {SLICE_X29Y79:SLICE_X48Y130}
resize_pblock [get_pblocks pblock_hls4ml] -add {DSP48E2_X7Y32:DSP48E2_X11Y51}
resize_pblock [get_pblocks pblock_hls4ml] -add {RAMB18_X1Y32:RAMB18_X1Y51}
resize_pblock [get_pblocks pblock_hls4ml] -add {RAMB36_X1Y16:RAMB36_X1Y25}
resize_pblock [get_pblocks pblock_hls4ml] -add {URAM288_X0Y24:URAM288_X0Y31}
set_property SNAPPING_MODE ON [get_pblocks pblock_hls4ml]
