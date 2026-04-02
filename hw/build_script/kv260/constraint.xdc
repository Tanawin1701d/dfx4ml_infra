create_pblock pblock_dfx_pr_0_0
add_cells_to_pblock [get_pblocks pblock_dfx_pr_0_0] [get_cells -quiet [list dfx4ml_i/dfx_pr_0_0]]
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {SLICE_X23Y74:SLICE_X55Y137}
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {DSP48E2_X6Y30:DSP48E2_X12Y53}
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {RAMB18_X0Y30:RAMB18_X2Y53}
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {RAMB36_X0Y15:RAMB36_X2Y26}
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {URAM288_X0Y20:URAM288_X0Y35}
set_property SNAPPING_MODE ON [get_pblocks pblock_dfx_pr_0_0]
