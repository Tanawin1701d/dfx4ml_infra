proc create_sub_block_design {parentCell \
                              clk_frq \
                              rm_index_width \
                              num_dfx_streamer \
                              interface_widths \
                              applied_interface_widths \
                              amt_rows \
                              num_actual_rm\
                              input_map_list \
                              output_map_list \
                              ip_map_list \
                              test_mode \
} {

    # the integrity check of this argument below will be handled by dfx unified
    # rm_index_width
    # num_dfx_streamer
    # interface_widths
    # applied_interface_widths
    # amt_rows

    # the integrity check for this argument below will be handled by dfx region
    # inside element input_map_list
    # inside element output_map_list
    # inside element ip_map_list

    # integrity check of this system
    set max_rm_allowed [expr {int(pow(2, $rm_index_width))}]
    if {($num_actual_rm + 1) > $max_rm_allowed} {
        error "ERROR: num_actual_rm + 1 (= [expr {$num_actual_rm + 1}]) exceeds maximum allowed value of 2^rm_index_width (= $max_rm_allowed)"
    }

    # check size of input_map_list
    if {[llength $input_map_list] != $num_actual_rm} {
        error "ERROR: size of input_map_list (= [llength $input_map_list]) does not equal num_actual_rm (= $num_actual_rm)"
    }

    # check size of output_map_list
    if {[llength $output_map_list] != $num_actual_rm} {
        error "ERROR: size of output_map_list (= [llength $output_map_list]) does not equal num_actual_rm (= $num_actual_rm)"
    }
    
    # check size of ip_map_list
    if {[llength $ip_map_list] != $num_actual_rm} {
        error "ERROR: size of ip_map_list (= [llength $ip_map_list]) does not equal num_actual_rm (= $num_actual_rm)"
    }
    
    # Create DFX regions for each RM
    for {set i 0} {$i < $num_actual_rm} {incr i} {
        set input_maps  [lindex $input_map_list $i]
        set output_maps [lindex $output_map_list $i]
        set ip_src      [lindex $ip_map_list $i]

        if {$test_mode == 1} {
            puts "create dfx_region for testing"
            create_dfx_region_bd $parentCell "dfx_pr_${i}" $clk_frq \
                                 $num_dfx_streamer $interface_widths \
                                 $input_maps $output_maps \
                                 $ip_src $i
        } else {
            puts "create dfx_region for testing"
            create_dfx_region_user_bd $parentCell "dfx_pr_${i}" $clk_frq \
                                 $num_dfx_streamer $interface_widths \
                                 $input_maps $output_maps \
                                 $ip_src $i

        }
    }

    create_dfx_unified_bd $parentCell $clk_frq $rm_index_width \
                              $num_dfx_streamer $interface_widths \
                              $applied_interface_widths $amt_rows

}


proc create_dfx4ml_design { parentCell \
                            clk_frq \
                            rm_index_width \
                            num_dfx_streamer \
                            interface_widths \
                            applied_interface_widths \
                            amt_rows \
                            num_actual_rm\
                            input_map_list \
                            output_map_list \
                            ip_map_list \
                            test_mode \
                            create_new_block \
} {



  # input argument check will be checked by create_sub_block_design

  create_sub_block_design $parentCell \
                          $clk_frq \
                          $rm_index_width \
                          $num_dfx_streamer \
                          $interface_widths \
                          $applied_interface_widths \
                          $amt_rows \
                          $num_actual_rm\
                          $input_map_list \
                          $output_map_list \
                          $ip_map_list \
                          $test_mode

  # Create dfx4ml block design

  if {$create_new_block} {
    create_bd_design "dfx4ml"
  } else {
    open_bd_design "dfx4ml"
  }



  # Create instance: dfx_unified_0, and set properties
  set dfx_unified_0 [ create_bd_cell -type container -reference dfx_unified dfx_unified_0 ]
  set_property -dict [list \
    CONFIG.ACTIVE_SIM_BD {dfx_unified.bd} \
    CONFIG.ACTIVE_SYNTH_BD {dfx_unified.bd} \
    CONFIG.ENABLE_DFX {0} \
    CONFIG.LIST_SIM_BD {dfx_unified.bd} \
    CONFIG.LIST_SYNTH_BD {dfx_unified.bd} \
    CONFIG.LOCK_PROPAGATE {0} \
  ] $dfx_unified_0


  # Create instance: dfx_pr_0_0, and set properties
  # Generate list of BD names dynamically
  set bd_list {}
  for {set i 0} {$i < $num_actual_rm} {incr i} {
    lappend bd_list "dfx_pr_${i}.bd"
  }
  set bd_list_str [join $bd_list ":"]

  set dfx_pr_0_0 [ create_bd_cell -type container -reference dfx_pr_0 dfx_pr_0_0 ]
  set_property -dict [list \
    CONFIG.ACTIVE_SIM_BD {dfx_pr_0.bd} \
    CONFIG.ACTIVE_SYNTH_BD {dfx_pr_0.bd} \
    CONFIG.ENABLE_DFX {true} \
    CONFIG.LIST_SIM_BD $bd_list_str \
    CONFIG.LIST_SYNTH_BD $bd_list_str \
    CONFIG.LOCK_PROPAGATE {0} \
  ] $dfx_pr_0_0


  # Create interface connections

  for {set i 0} {$i < $num_dfx_streamer} {incr i} {
    connect_bd_intf_net -intf_net dfx_pr_0_0_M_DS_${i} [get_bd_intf_pins dfx_pr_0_0/M_DS_${i}] [get_bd_intf_pins dfx_unified_0/S_AXIS_DS${i}]
    connect_bd_intf_net -intf_net dfx_unified_0_M_AXIS_DS${i} [get_bd_intf_pins dfx_unified_0/M_AXIS_DS${i}] [get_bd_intf_pins dfx_pr_0_0/S_DS_${i}]
  }

  connect_bd_intf_net -intf_net dfx_unified_0_M_AXI_LITE_PR_CTRL [get_bd_intf_pins dfx_unified_0/M_AXI_LITE_PR_CTRL] [get_bd_intf_pins dfx_pr_0_0/S_AXI_LITE_PR_CTRL]

  # Create port connections
  connect_bd_net -net dfx_unified_0_dfx_nreset [get_bd_pins dfx_unified_0/dfx_nreset] [get_bd_pins dfx_pr_0_0/nreset]

  save_bd_design

  close_bd_design dfx4ml
}