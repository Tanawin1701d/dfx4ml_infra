proc create_sub_block_design {parentCell \
                              clk_frq \
                              rm_index_width \
                              num_dfx_streamer \
                              num_dfx_region \
                              dfx_streamers_list \
                              dfx_regions_list \
                              rm_schemetics_list \
                              test_mode \
} {

    # Derive interface_widths from dfx_streamers_list (load_width in bytes → bits)
    set interface_widths {}
    foreach s $dfx_streamers_list {
        lappend interface_widths [expr {[dict get $s load_width] * 8}]
    }

    # Create one BD per (region, rm) pair
    for {set r 0} {$r < $num_dfx_region} {incr r} {
        set region     [lindex $dfx_regions_list $r]
        set region_rms [lindex $rm_schemetics_list $r]

        set load_streamers  [dict get $region load_streamers]
        set store_streamers [dict get $region store_streamers]

        # Build input_maps / output_maps (length = num_dfx_streamer, -1 = not connected)
        set input_maps  [lrepeat $num_dfx_streamer -1]
        foreach s_idx $load_streamers {
            lset input_maps $s_idx $s_idx
        }
        set output_maps [lrepeat $num_dfx_streamer -1]
        foreach s_idx $store_streamers {
            lset output_maps $s_idx $s_idx
        }

        for {set m 0} {$m < [llength $region_rms]} {incr m} {
            set block_name "dfx_pr_region_${r}_rm_${m}"
            if {$test_mode == 1} {
                puts "create dfx_region $block_name for testing"
                create_dfx_region_bd $parentCell $block_name $clk_frq \
                    $num_dfx_streamer $interface_widths \
                    $input_maps $output_maps "" $m
            } else {
                puts "create dfx_region $block_name (user mode)"
                create_dfx_region_user_bd $parentCell $block_name $clk_frq \
                    $num_dfx_streamer $interface_widths \
                    $input_maps $output_maps "" $m
            }
        }
    }

    create_dfx_unified_bd $parentCell $clk_frq $rm_index_width \
        $num_dfx_streamer $num_dfx_region \
        $dfx_streamers_list $dfx_regions_list $rm_schemetics_list
}


proc create_dfx4ml_design { parentCell \
                            clk_frq \
                            rm_index_width \
                            num_dfx_streamer \
                            num_dfx_region \
                            dfx_streamers_list \
                            dfx_regions_list \
                            rm_schemetics_list \
                            test_mode \
                            create_new_block \
} {

    # input argument checking is delegated to create_sub_block_design / create_dfx_unified_bd

    create_sub_block_design $parentCell \
        $clk_frq \
        $rm_index_width \
        $num_dfx_streamer \
        $num_dfx_region \
        $dfx_streamers_list \
        $dfx_regions_list \
        $rm_schemetics_list \
        $test_mode

    # Create dfx4ml top-level block design
    if {$create_new_block} {
        create_bd_design "dfx4ml"
    } else {
        open_bd_design "dfx4ml"
    }

    # Create instance: dfx_unified_0
    set dfx_unified_0 [ create_bd_cell -type container -reference dfx_unified dfx_unified_0 ]
    set_property -dict [list \
        CONFIG.ACTIVE_SIM_BD   {dfx_unified.bd} \
        CONFIG.ACTIVE_SYNTH_BD {dfx_unified.bd} \
        CONFIG.ENABLE_DFX      {0} \
        CONFIG.LIST_SIM_BD     {dfx_unified.bd} \
        CONFIG.LIST_SYNTH_BD   {dfx_unified.bd} \
        CONFIG.LOCK_PROPAGATE  {0} \
    ] $dfx_unified_0

    # Create one PR container per region and connect its streamers
    for {set r 0} {$r < $num_dfx_region} {incr r} {
        set region     [lindex $dfx_regions_list $r]
        set region_rms [lindex $rm_schemetics_list $r]

        # Build BD list for this region
        set bd_list {}
        for {set m 0} {$m < [llength $region_rms]} {incr m} {
            lappend bd_list "dfx_pr_region_${r}_rm_${m}.bd"
        }
        set bd_list_str [join $bd_list ":"]

        set pr_container [ create_bd_cell -type container \
            -reference "dfx_pr_region_${r}_rm_0" "dfx_pr_region_${r}_0" ]
        set_property -dict [list \
            CONFIG.ACTIVE_SIM_BD   "dfx_pr_region_${r}_rm_0.bd" \
            CONFIG.ACTIVE_SYNTH_BD "dfx_pr_region_${r}_rm_0.bd" \
            CONFIG.ENABLE_DFX      {true} \
            CONFIG.LIST_SIM_BD     $bd_list_str \
            CONFIG.LIST_SYNTH_BD   $bd_list_str \
            CONFIG.LOCK_PROPAGATE  {0} \
        ] $pr_container

        # Connect load streamers: dfx_unified_0 outputs → region inputs
        set load_streamers [dict get $region load_streamers]
        foreach s_idx $load_streamers {
            connect_bd_intf_net \
                -intf_net "dfx_unified_0_M_AXIS_DS${s_idx}_r${r}" \
                [get_bd_intf_pins dfx_unified_0/M_AXIS_DS${s_idx}] \
                [get_bd_intf_pins dfx_pr_region_${r}_0/S_DS_${s_idx}]
        }

        # Connect store streamers: region outputs → dfx_unified_0 inputs
        set store_streamers [dict get $region store_streamers]
        foreach s_idx $store_streamers {
            connect_bd_intf_net \
                -intf_net "dfx_pr_region_${r}_0_M_DS${s_idx}" \
                [get_bd_intf_pins dfx_pr_region_${r}_0/M_DS_${s_idx}] \
                [get_bd_intf_pins dfx_unified_0/S_AXIS_DS${s_idx}]
        }

        # AXI-Lite PR ctrl: dfx_unified per-region port → region container
        connect_bd_intf_net \
            -intf_net "dfx_unified_0_M_AXI_LITE_PR_CTRL_${r}" \
            [get_bd_intf_pins dfx_unified_0/M_AXI_LITE_PR_CTRL_${r}] \
            [get_bd_intf_pins dfx_pr_region_${r}_0/S_AXI_LITE_PR_CTRL]

        # nreset: per-region dfx_nreset from dfx_unified → region container
        connect_bd_net \
            -net "dfx_unified_0_dfx_nreset_${r}" \
            [get_bd_pins dfx_unified_0/dfx_nreset_${r}] \
            [get_bd_pins dfx_pr_region_${r}_0/nreset]
    }

    save_bd_design
    close_bd_design dfx4ml
}
