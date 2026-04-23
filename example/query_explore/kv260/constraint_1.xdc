create_pblock pblock_dfx_pr_0_0
add_cells_to_pblock [get_pblocks pblock_dfx_pr_0_0] [get_cells -quiet [list dfx4ml_i/dfx_pr_0_0]]
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {SLICE_X0Y25:SLICE_X40Y239}
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {BUFG_PS_X0Y0:BUFG_PS_X0Y95}
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {DSP48E2_X0Y10:DSP48E2_X11Y95}
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {IOB_X0Y26:IOB_X1Y207}
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {RAMB18_X0Y10:RAMB18_X0Y95}
resize_pblock [get_pblocks pblock_dfx_pr_0_0] -add {RAMB36_X0Y5:RAMB36_X0Y47}
set_property SNAPPING_MODE ON [get_pblocks pblock_dfx_pr_0_0]
