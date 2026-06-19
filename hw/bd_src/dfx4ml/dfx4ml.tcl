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

    ##------------------------------------------------------------
    ## STAGE 1: ARGUMENT PARSING
    ##------------------------------------------------------------
    # Derive interface_widths from dfx_streamers_list (load_width in bytes → bits)
    set interface_widths {}
    foreach s $dfx_streamers_list {
        lappend interface_widths [expr {[dict get $s load_width] * 8}]
    }

    ##------------------------------------------------------------
    ## STAGE 2: PER-REGION RM BD CREATION
    ##------------------------------------------------------------
    # Create one BD per (region, rm) pair
    for {set r 0} {$r < $num_dfx_region} {incr r} {
        set region_rms [lindex $rm_schemetics_list $r]

        for {set m 0} {$m < [llength $region_rms]} {incr m} {
            set block_name "dfx_pr_region_${r}_rm_${m}"
            set rm_config  [lindex $region_rms $m]
            if {$test_mode == 1} {
                puts "create dfx_region $block_name for testing"
                create_dfx_region_bd $parentCell $block_name $clk_frq \
                    $interface_widths $rm_config "" $m $r $num_dfx_region \
                    [lindex $dfx_regions_list $r]
            } else {
                puts "create dfx_region $block_name (user mode)"
                create_dfx_region_user_bd $parentCell $block_name $clk_frq \
                    $interface_widths $rm_config "" $m
            }
        }

        # Default (parent) RM: a clean placeholder that plugs every region port
        # into a dummy (no kernel / no S2M passthrough).  Used as the static
        # parent PR configuration so the static bitstream is not locked to any
        # real kernel's routing — the real RMs (rm_0..rm_N) are all swapped in
        # as children at runtime.  Built via create_dfx_region_bd in both test
        # and user mode: it only references dfx-repo dummy IPs (Stream_*_Dummy,
        # AXI_Lite_Shut), never the user kernel, and its boundary ports match
        # the real RMs (both generators derive ports from the region streamers).
        set region        [lindex $dfx_regions_list $r]
        set default_load_map  {}
        foreach s_idx [dict get $region load_streamers]  { lappend default_load_map  [list $s_idx -1] }
        set default_store_map {}
        foreach s_idx [dict get $region store_streamers] { lappend default_store_map [list $s_idx -1] }
        set default_rm_config [dict create \
            load_io_map  $default_load_map \
            store_io_map $default_store_map]

        set default_block_name "dfx_pr_region_${r}_rm_default"
        puts "create dfx_region $default_block_name (clean dummy-only parent default)"
        create_dfx_region_bd $parentCell $default_block_name $clk_frq \
            $interface_widths $default_rm_config "" 0 $r $num_dfx_region $region
    }

    ##------------------------------------------------------------
    ## STAGE 3: UNIFIED BD CREATION
    ##------------------------------------------------------------
    # create_dfx_unified_bd returns [array get region_load_port] — forward to caller
    return [create_dfx_unified_bd $parentCell $clk_frq $rm_index_width \
        $num_dfx_streamer $num_dfx_region \
        $dfx_streamers_list $dfx_regions_list $rm_schemetics_list]
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

    ##------------------------------------------------------------
    ## STAGE 1: SUB-BLOCK DISPATCH
    ##------------------------------------------------------------
    # Capture the load-port allocation map returned by create_sub_block_design
    # (which in turn returns it from create_dfx_unified_bd).
    # array set restores the flat key-value list into a local array.
    set alloc [create_sub_block_design $parentCell \
        $clk_frq \
        $rm_index_width \
        $num_dfx_streamer \
        $num_dfx_region \
        $dfx_streamers_list \
        $dfx_regions_list \
        $rm_schemetics_list \
        $test_mode]
    array set region_load_port $alloc

    ##------------------------------------------------------------
    ## STAGE 2: TOP-LEVEL BD INIT
    ##------------------------------------------------------------
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

    ##------------------------------------------------------------
    ## STAGE 3: PR REGION CONTAINERS AND CONNECTIONS
    ##------------------------------------------------------------
    # Create one PR container per region and connect its streamers
    for {set r 0} {$r < $num_dfx_region} {incr r} {
        set region     [lindex $dfx_regions_list $r]
        set region_rms [lindex $rm_schemetics_list $r]

        # Build BD list for this region. The dummy-only default RM leads the
        # list and is the active/reference variant, so the static (parent) build
        # uses the clean placeholder; the real RMs follow as swap-in variants.
        set bd_list [list "dfx_pr_region_${r}_rm_default.bd"]
        for {set m 0} {$m < [llength $region_rms]} {incr m} {
            lappend bd_list "dfx_pr_region_${r}_rm_${m}.bd"
        }
        set bd_list_str [join $bd_list ":"]

        set pr_container [ create_bd_cell -type container \
            -reference "dfx_pr_region_${r}_rm_default" "dfx_pr_region_${r}_0" ]
        set_property -dict [list \
            CONFIG.ACTIVE_SIM_BD   "dfx_pr_region_${r}_rm_default.bd" \
            CONFIG.ACTIVE_SYNTH_BD "dfx_pr_region_${r}_rm_default.bd" \
            CONFIG.ENABLE_DFX      {true} \
            CONFIG.LIST_SIM_BD     $bd_list_str \
            CONFIG.LIST_SYNTH_BD   $bd_list_str \
            CONFIG.LOCK_PROPAGATE  {0} \
        ] $pr_container

        # Connect load streamers: dfx_unified_0 outputs → region inputs
        # s_idx == 0 → DMA path: port stays "M_AXIS_DS0" (single, never multi-ported)
        # s_idx  > 0 → Dfx_Streamer: port is "M_AXIS_DS${s_idx}_p${port_j}"
        set load_streamers [dict get $region load_streamers]
        puts "region ${r} load_streamers: $load_streamers"
        foreach s_idx $load_streamers {
            if {$s_idx == 0} {
                connect_bd_intf_net \
                    -intf_net "dfx_unified_0_M_AXIS_DS0_r${r}" \
                    [get_bd_intf_pins dfx_unified_0/M_AXIS_DS0] \
                    [get_bd_intf_pins dfx_pr_region_${r}_0/S_DS_0]
            } else {
                set port_j $region_load_port($r,$s_idx)
                connect_bd_intf_net \
                    -intf_net "dfx_unified_0_M_AXIS_DS${s_idx}_p${port_j}_r${r}" \
                    [get_bd_intf_pins dfx_unified_0/M_AXIS_DS${s_idx}_p${port_j}] \
                    [get_bd_intf_pins dfx_pr_region_${r}_0/S_DS_${s_idx}]
            }
        }

        # Connect store streamers: region outputs → dfx_unified_0 inputs
        set store_streamers [dict get $region store_streamers]
        puts "region ${r} store_streamers: $store_streamers"
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

    ##------------------------------------------------------------
    ## STAGE 4: FINALIZE
    ##------------------------------------------------------------
    save_bd_design
    close_bd_design dfx4ml
}
