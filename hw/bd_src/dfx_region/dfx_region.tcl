##################################################################
# DESIGN PROCs
##################################################################

proc create_dfx_region_bd { \
    parentCell \
    block_name \
    clk_frq \
    interface_widths \
    rm_config \
    ip_name \
    rm_id \
    vm_id \
    amount_region \
    region_config \
} {

  ##------------------------------------------------------------
  ## STAGE 1: ARGUMENT PARSING
  ##------------------------------------------------------------
  set load_io_map  [dict get $rm_config load_io_map]
  set store_io_map [dict get $rm_config store_io_map]

  # Port sets come from the region definition (superset across all RMs)
  set region_load_idxs  [dict get $region_config load_streamers]
  set region_store_idxs [dict get $region_config store_streamers]

  # Active (non-dummy) streamer indices for this RM from rm_config
  set active_load_idxs {}
  foreach pair $load_io_map {
      if { [lindex $pair 1] != -1 } {
          lappend active_load_idxs [lindex $pair 0]
      }
  }
  set active_store_idxs {}
  foreach pair $store_io_map {
      if { [lindex $pair 1] != -1 } {
          lappend active_store_idxs [lindex $pair 0]
      }
  }

  ##------------------------------------------------------------
  ## STAGE 2: VALIDATION
  ##------------------------------------------------------------
  if { [llength $region_load_idxs] == 0 && [llength $region_store_idxs] == 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" \
          "region_config has empty load_streamers and store_streamers"}
      return
  }

  foreach idx [concat $region_load_idxs $region_store_idxs] {
      if { $idx >= [llength $interface_widths] } {
          catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" \
              "streamer index $idx exceeds interface_widths length [llength $interface_widths]"}
          return
      }
      set iw [lindex $interface_widths $idx]
      if { !($iw != 0 && ($iw & ($iw - 1)) == 0) } {
          catch {common::send_gid_msg -ssname BD::TCL -id 2094 -severity "ERROR" \
              "interface_widths\[$idx\] = <$iw> is not a power of two!"}
          return
      }
  }

  ##------------------------------------------------------------
  ## STAGE 3: BD INIT
  ##------------------------------------------------------------
  create_bd_design $block_name
  set oldCurInst [current_bd_instance .]

  ##------------------------------------------------------------
  ## STAGE 4: INTERFACE PORTS (based on region_config)
  ##------------------------------------------------------------
  # Slave (load) ports — one per streamer in region load_streamers
  foreach io_idx $region_load_idxs {
      set S_DS_${io_idx} [ create_bd_intf_port -mode Slave \
          -vlnv xilinx.com:interface:axis_rtl:1.0 S_DS_${io_idx} ]
      set_property -dict [ list \
          CONFIG.FREQ_HZ          "$clk_frq" \
          CONFIG.HAS_TKEEP        {1} \
          CONFIG.HAS_TLAST        {1} \
          CONFIG.HAS_TREADY       {1} \
          CONFIG.HAS_TSTRB        {0} \
          CONFIG.LAYERED_METADATA {undef} \
          CONFIG.TDATA_NUM_BYTES  [expr {[lindex $interface_widths ${io_idx}] / 8}] \
          CONFIG.TDEST_WIDTH      {0} \
          CONFIG.TID_WIDTH        {0} \
          CONFIG.TUSER_WIDTH      {0} \
      ] [set S_DS_${io_idx}]
  }

  # Master (store) ports — one per streamer in region store_streamers
  foreach io_idx $region_store_idxs {
      set M_DS_${io_idx} [ create_bd_intf_port -mode Master \
          -vlnv xilinx.com:interface:axis_rtl:1.0 M_DS_${io_idx} ]
  }

  set S_AXI_LITE_PR_CTRL [ create_bd_intf_port -mode Slave \
      -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE_PR_CTRL ]
  set_property -dict [ list \
      CONFIG.ADDR_WIDTH {32} \
      CONFIG.DATA_WIDTH {32} \
      CONFIG.FREQ_HZ    "$clk_frq" \
      CONFIG.PROTOCOL   {AXI4LITE} \
  ] $S_AXI_LITE_PR_CTRL

  ##------------------------------------------------------------
  ## STAGE 5: SCALAR PORTS
  ##------------------------------------------------------------
  # Build ASSOCIATED_BUSIF from region ports
  set busif_list {S_AXI_LITE_PR_CTRL}
  foreach io_idx $region_load_idxs  { lappend busif_list "S_DS_${io_idx}" }
  foreach io_idx $region_store_idxs { lappend busif_list "M_DS_${io_idx}" }

  set clk [ create_bd_port -dir I -type clk -freq_hz $clk_frq clk ]
  set_property -dict [ list \
      CONFIG.ASSOCIATED_BUSIF  [join $busif_list ":"] \
      CONFIG.ASSOCIATED_RESET  {nreset} \
  ] $clk
  set nreset [ create_bd_port -dir I nreset ]

  ##------------------------------------------------------------
  ## STAGE 6: IP INSTANCES
  ##------------------------------------------------------------
  # S2M widths: first active entry in rm_config, fall back to 32
  set s2m_s_width 32
  foreach pair $load_io_map {
      if { [lindex $pair 1] != -1 } {
          set s2m_s_width [lindex $interface_widths [lindex $pair 0]]
          break
      }
  }
  set s2m_m_width 32
  foreach pair $store_io_map {
      if { [lindex $pair 1] != -1 } {
          set s2m_m_width [lindex $interface_widths [lindex $pair 0]]
          break
      }
  }

  set Stream_Single_S2M_0 [ create_bd_cell -type ip \
      -vlnv user.org:user:Stream_Single_S2M:1.0 Stream_Single_S2M_0 ]
  set_property -dict [list \
      CONFIG.S_DATA_WIDTH    "$s2m_s_width" \
      CONFIG.M_DATA_WIDTH    "$s2m_m_width" \
      CONFIG.VM_ID           "$vm_id" \
      CONFIG.AMOUNT_REGION   "$amount_region" \
      CONFIG.RM_ID           "$rm_id" \
  ] $Stream_Single_S2M_0

  set AXI_Lite_Shut_0 [ create_bd_cell -type ip \
      -vlnv user.org:user:AXI_Lite_Shut:1.0 AXI_Lite_Shut_0 ]

  ##------------------------------------------------------------
  ## STAGE 7: INTERFACE CONNECTIONS
  ##------------------------------------------------------------
  # Load ports: active in rm_config → S2M; rest → Stream_Slave_Dummy
  foreach io_idx $region_load_idxs {
      if { [lsearch $active_load_idxs $io_idx] >= 0 } {
          connect_bd_intf_net -intf_net S_DS_${io_idx}_1 \
              [get_bd_intf_ports S_DS_${io_idx}] \
              [get_bd_intf_pins Stream_Single_S2M_0/S_AXI]
      } else {
          set Stream_Slave_Dummy_${io_idx} [ create_bd_cell -type ip \
              -vlnv user.org:user:Stream_Slave_Dummy:1.0 Stream_Slave_Dummy_${io_idx} ]
          set_property -dict [list CONFIG.DATA_WIDTH "[lindex $interface_widths ${io_idx}]"] \
              [set Stream_Slave_Dummy_${io_idx}]
          connect_bd_intf_net -intf_net S_DS_${io_idx}_1 \
              [get_bd_intf_ports S_DS_${io_idx}] \
              [get_bd_intf_pins Stream_Slave_Dummy_${io_idx}/S_AXI]
          connect_bd_net -net clk_0_1    [get_bd_ports clk]    [get_bd_pins Stream_Slave_Dummy_${io_idx}/clk]
          connect_bd_net -net nreset_0_1 [get_bd_ports nreset] [get_bd_pins Stream_Slave_Dummy_${io_idx}/nreset]
      }
  }

  # Store ports: active in rm_config → S2M; rest → Stream_Master_Dummy
  foreach io_idx $region_store_idxs {
      if { [lsearch $active_store_idxs $io_idx] >= 0 } {
          connect_bd_intf_net -intf_net M_DS_${io_idx}_1 \
              [get_bd_intf_pins Stream_Single_S2M_0/M_AXI] \
              [get_bd_intf_ports M_DS_${io_idx}]
      } else {
          set Stream_Master_Dummy_${io_idx} [ create_bd_cell -type ip \
              -vlnv user.org:user:Stream_Master_Dummy:1.0 Stream_Master_Dummy_${io_idx} ]
          set_property -dict [list CONFIG.DATA_WIDTH "[lindex $interface_widths ${io_idx}]"] \
              [set Stream_Master_Dummy_${io_idx}]
          connect_bd_intf_net -intf_net M_DS_${io_idx}_1 \
              [get_bd_intf_pins Stream_Master_Dummy_${io_idx}/M_AXI] \
              [get_bd_intf_ports M_DS_${io_idx}]
          connect_bd_net -net clk_0_1    [get_bd_ports clk]    [get_bd_pins Stream_Master_Dummy_${io_idx}/clk]
          connect_bd_net -net nreset_0_1 [get_bd_ports nreset] [get_bd_pins Stream_Master_Dummy_${io_idx}/nreset]
      }
  }

  connect_bd_intf_net -intf_net S_AXI_LITE_PR_CTRL_1 \
      [get_bd_intf_ports S_AXI_LITE_PR_CTRL] \
      [get_bd_intf_pins AXI_Lite_Shut_0/S_AXI]

  ##------------------------------------------------------------
  ## STAGE 8: NET CONNECTIONS
  ##------------------------------------------------------------
  connect_bd_net -net clk_0_1 \
      [get_bd_ports clk] \
      [get_bd_pins Stream_Single_S2M_0/clk] \
      [get_bd_pins AXI_Lite_Shut_0/clk]
  connect_bd_net -net nreset_0_1 \
      [get_bd_ports nreset] \
      [get_bd_pins Stream_Single_S2M_0/nreset] \
      [get_bd_pins AXI_Lite_Shut_0/nreset]

  ##------------------------------------------------------------
  ## STAGE 9: ADDRESS SEGMENTS
  ##------------------------------------------------------------
  assign_bd_address -offset 0x00000000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces S_AXI_LITE_PR_CTRL] \
      [get_bd_addr_segs AXI_Lite_Shut_0/S_AXI/reg0] -force

  ##------------------------------------------------------------
  ## STAGE 10: FINALIZE
  ##------------------------------------------------------------
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
  close_bd_design $block_name
}
