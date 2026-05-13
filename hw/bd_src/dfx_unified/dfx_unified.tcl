##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: dma_hier
proc create_hier_cell_dma_hier { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "create_hier_cell_dma_hier() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  ##------------------------------------------------------------
  ## STAGE 1: INTERFACE PINS
  ##------------------------------------------------------------
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA_IN
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA_OUT
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DS0
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DS0


  ##------------------------------------------------------------
  ## STAGE 2: SCALAR PINS
  ##------------------------------------------------------------
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -type rst nreset
  create_bd_pin -dir O -type intr s2mm_introut
  create_bd_pin -dir I decup_load
  create_bd_pin -dir I decup_store

  ##------------------------------------------------------------
  ## STAGE 3: IP INSTANCES
  ##------------------------------------------------------------
  # Create instance: axi_dma_0, and set properties
  set axi_dma_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_dma:7.1 axi_dma_0 ]
  set_property -dict [list \
    CONFIG.c_include_sg {0} \
    CONFIG.c_sg_length_width {26} \
  ] $axi_dma_0


  # Create instance: dfx_decoupler_0, and set properties
  set dfx_decoupler_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_decoupler:1.0 dfx_decoupler_0 ]
  set_property -dict [list \
    CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 ALWAYS_HAVE_AXI_CLK 1 INTF {intf_0 {ID 0 VLNV xilinx.com:interface:axis_rtl:1.0 MODE master SIGNALS {TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TDATA\
{PRESENT 1 WIDTH 32} TUSER {PRESENT 0 WIDTH 0} TLAST {PRESENT 1 WIDTH 1} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 4} TKEEP {PRESENT 1 WIDTH 4}}}} IPI_PROP_COUNT 0} \
    CONFIG.GUI_SELECT_MODE {master} \
    CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
  ] $dfx_decoupler_0


  # Create instance: dfx_decoupler_1, and set properties
  set dfx_decoupler_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_decoupler:1.0 dfx_decoupler_1 ]
  set_property -dict [list \
    CONFIG.ALL_PARAMS {HAS_SIGNAL_STATUS 0 INTF {intf_0 {ID 0 MODE slave VLNV xilinx.com:interface:axis_rtl:1.0 SIGNALS {TVALID {PRESENT 1 WIDTH 1} TREADY {PRESENT 1 WIDTH 1} TDATA {PRESENT 1 WIDTH 32}\
TUSER {PRESENT 0 WIDTH 0} TLAST {PRESENT 1 WIDTH 1} TID {PRESENT 0 WIDTH 0} TDEST {PRESENT 0 WIDTH 0} TSTRB {PRESENT 0 WIDTH 4} TKEEP {PRESENT 1 WIDTH 4}}}} ALWAYS_HAVE_AXI_CLK 1 IPI_PROP_COUNT 0} \
    CONFIG.GUI_SELECT_MODE {slave} \
    CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:axis_rtl:1.0} \
  ] $dfx_decoupler_1


  ##------------------------------------------------------------
  ## STAGE 4: INTERFACE CONNECTIONS
  ##------------------------------------------------------------
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M00_AXI [get_bd_intf_pins S_AXI_LITE] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net S_AXIS_DS0_1 [get_bd_intf_pins S_AXIS_DS0] [get_bd_intf_pins dfx_decoupler_0/rp_intf_0]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins dfx_decoupler_1/s_intf_0] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins M_AXI_DMA_IN] [get_bd_intf_pins axi_dma_0/M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins M_AXI_DMA_OUT] [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]
  connect_bd_intf_net -intf_net dfx_decoupler_0_s_intf_0 [get_bd_intf_pins dfx_decoupler_0/s_intf_0] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net dfx_decoupler_1_rp_intf_0 [get_bd_intf_pins M_AXIS_DS0] [get_bd_intf_pins dfx_decoupler_1/rp_intf_0]

  ##------------------------------------------------------------
  ## STAGE 5: NET CONNECTIONS
  ##------------------------------------------------------------
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins s2mm_introut]
  connect_bd_net -net clk_0_1 [get_bd_pins clk] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins dfx_decoupler_0/intf_0_aclk] [get_bd_pins dfx_decoupler_1/intf_0_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk]
  connect_bd_net -net reset_0_1 [get_bd_pins nreset] [get_bd_pins dfx_decoupler_0/intf_0_arstn] [get_bd_pins dfx_decoupler_1/intf_0_arstn] [get_bd_pins axi_dma_0/axi_resetn]
  connect_bd_net -net dma_decup_store [get_bd_pins decup_store] [get_bd_pins dfx_decoupler_1/decouple]
  connect_bd_net -net dma_decup_load  [get_bd_pins decup_load]  [get_bd_pins dfx_decoupler_0/decouple]


  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_dfx_unified_bd { parentCell clk_frq rm_index_width \
                             num_dfx_streamer num_dfx_region \
                             dfx_streamers_list dfx_regions_list rm_schemetics_list } {

  variable script_folder
  variable design_name

  create_bd_design "dfx_unified"

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }

  ##------------------------------------------------------------
  ## STAGE 1: ARGUMENT PARSING
  ##------------------------------------------------------------
  # Derive per-streamer width lists from dfx_streamers_list
  set interface_widths         {}
  set applied_interface_widths {}
  set amt_rows                 {}
  foreach s $dfx_streamers_list {
    lappend interface_widths         [expr {[dict get $s load_width] * 8}]
    lappend applied_interface_widths [dict get $s actual_width]
    lappend amt_rows                 [dict get $s amount_row]
  }

  # Count total RMs across all regions and per-region RM counts
  set num_rm_per_region {}
  set total_rm 0
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    set n [llength [lindex $rm_schemetics_list $r]]
    lappend num_rm_per_region $n
    incr total_rm $n
  }

  ##------------------------------------------------------------
  ## STAGE 2: VALIDATION
  ##------------------------------------------------------------
  if { $rm_index_width == 0 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "rm_index_width is zero"}
     return
  }
  if { $num_dfx_streamer == 0 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "num_dfx_streamer is zero"}
     return
  }
  if { $num_dfx_region == 0 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "num_dfx_region is zero"}
     return
  }

  for {set i 0} {$i < $num_dfx_streamer} {incr i} {
     set iw  [lindex $interface_widths $i]
     set aiw [lindex $applied_interface_widths $i]
     set sw  [lindex $amt_rows $i]

     if { !($iw != 0 && ($iw & ($iw - 1)) == 0) } {
        catch {common::send_gid_msg -ssname BD::TCL -id 2094 -severity "ERROR" "interface_widths\[$i\] = <$iw> is not a power of two!"}
        return
     }
     if { $aiw > $iw } {
        catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "applied_interface_widths\[$i\] = <$aiw> must be <= interface_widths\[$i\] = <$iw>!"}
        return
     }
     if { $sw <= 0 } {
        catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "amt_rows\[$i\] = <$sw> must be > 0!"}
        return
     }
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj


  ##------------------------------------------------------------
  ## STAGE 3: INTERFACE PORTS
  ##------------------------------------------------------------
  set M_AXI_DMA_IN [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA_IN ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ "$clk_frq" \
   CONFIG.HAS_BRESP {0} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_WSTRB {0} \
   CONFIG.NUM_READ_OUTSTANDING {16} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_ONLY} \
   ] $M_AXI_DMA_IN

  set M_AXI_DMA_OUT [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA_OUT ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ "$clk_frq" \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {WRITE_ONLY} \
   ] $M_AXI_DMA_OUT

  set M_AXIS_DS0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DS0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ "$clk_frq" \
   ] $M_AXIS_DS0

  set S_AXIS_DS0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DS0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ "$clk_frq" \
   CONFIG.HAS_TKEEP {1} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S_AXIS_DS0

  for {set i 1} {$i < $num_dfx_streamer} {incr i} {
    set iw [lindex $interface_widths $i]
    set tdata_num_bytes [expr {$iw / 8}]
    set port_name "S_AXIS_DS$i"
  
    set S_AXIS_DS_PORT [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 $port_name ]
    set_property -dict [ list \
     CONFIG.FREQ_HZ "$clk_frq" \
     CONFIG.HAS_TKEEP {0} \
     CONFIG.HAS_TLAST {1} \
     CONFIG.HAS_TREADY {1} \
     CONFIG.HAS_TSTRB {0} \
     CONFIG.LAYERED_METADATA {undef} \
     CONFIG.TDATA_NUM_BYTES $tdata_num_bytes \
     CONFIG.TDEST_WIDTH {0} \
     CONFIG.TID_WIDTH {0} \
     CONFIG.TUSER_WIDTH {0} \
     ] $S_AXIS_DS_PORT
  }

  set S_AXI_CTRL [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL ]


  set M_AXI_BS [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_BS ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ "$clk_frq" \
   CONFIG.HAS_BRESP {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_WSTRB {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_ONLY} \
   ] $M_AXI_BS

  # Per-region AXI-Lite PR ctrl ports
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    set pr_ctrl_port [ create_bd_intf_port -mode Master \
        -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_LITE_PR_CTRL_${r} ]
    set_property -dict [ list \
      CONFIG.ADDR_WIDTH {32} \
      CONFIG.DATA_WIDTH {32} \
      CONFIG.FREQ_HZ "$clk_frq" \
      CONFIG.PROTOCOL {AXI4LITE} \
    ] $pr_ctrl_port
  }

  for {set i 1} {$i < $num_dfx_streamer} {incr i} {
    set port_name "M_AXIS_DS$i"
    
    set M_AXIS_DS_PORT [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 $port_name ]
    set_property -dict [ list \
     CONFIG.FREQ_HZ "$clk_frq" \
     ] $M_AXIS_DS_PORT
  }
  
  ##------------------------------------------------------------
  ## STAGE 4: SCALAR PORTS
  ##------------------------------------------------------------
  set clk [ create_bd_port -dir I -type clk -freq_hz $clk_frq clk ]
  set nreset [ create_bd_port -dir I -type rst nreset ]
  set dfx_intr [ create_bd_port -dir O -type intr dfx_intr ]
  # Per-region nreset output ports
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    create_bd_port -dir O -type rst dfx_nreset_${r}
  }
  set dbg_amt_load_bytes_0 [ create_bd_port -dir O -from 10 -to 0 dbg_amt_load_bytes_0 ]
  set dbg_amt_store_bytes_0 [ create_bd_port -dir O -from 10 -to 0 dbg_amt_store_bytes_0 ]
  set dbg_state_0 [ create_bd_port -dir O -from 3 -to 0 dbg_state_0 ]

  ##------------------------------------------------------------
  ## STAGE 5: IP INSTANCES
  ##------------------------------------------------------------
  # Create instance: DFX_Mng, and set properties
  # BANK1_RM_SELECT_WIDTH = total_rm (one bit per global RM, pools all regions)
  set DFX_Mng [ create_bd_cell -type ip -vlnv user.org:user:DFX_Mng:1.0 DFX_Mng ]
  set_property -dict [ list \
     CONFIG.NUM_REGION                 "$num_dfx_region" \
     CONFIG.BANK1_INDEX_WIDTH          "$rm_index_width" \
     CONFIG.BANK1_RM_SELECT_WIDTH      "$total_rm" \
     CONFIG.BANK1_DATA_POOL_MASK_WIDTH "$num_dfx_streamer" \
     ] $DFX_Mng

  # Create instance: Dfx_Streamer_i, and set properties
  for {set i 1} {$i < $num_dfx_streamer} {incr i} {
    set Dfx_Streamer_$i [ create_bd_cell -type ip -vlnv user.org:user:Dfx_Streamer:1.0 Dfx_Streamer_$i ]
    set target_streamer [set Dfx_Streamer_$i]
    set aiw [lindex $applied_interface_widths $i] ; # actual/applied index width
    set iw [lindex $interface_widths $i]          ; # interface index width
    set sw [lindex $amt_rows $i]      ; # storage index width
    set_property -dict [ list \
         CONFIG.DATA_WIDTH "$aiw" \
         CONFIG.ITF_DATA_WIDTH "$iw" \
         CONFIG.AMT_ROW "$sw" \
         CONFIG.BANK1_ST_MSK_WIDTH "$num_dfx_streamer" \
         CONFIG.BANK1_LD_MSK_WIDTH "$num_dfx_streamer" \
         CONFIG.STREAMER_IDX "$i" \
         ] $target_streamer
  }

  # Create instance: xlconcat_0, and set properties
  # Calculate total port width and number of interface widths
  
  # Build property list for xlconcat
  set config_list [list]
  
  # First N ports are 1 bit width
  for {set i 0} {$i < $num_dfx_streamer} {incr i} {
    lappend config_list "CONFIG.IN${i}_WIDTH" {1}
  }
  lappend config_list "CONFIG.NUM_PORTS" $num_dfx_streamer


  # Create the fin_store_concat_0 instance
  set fin_store_concat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 fin_store_concat_0 ]
  set_property -dict $config_list $fin_store_concat_0


  # AXI interconnect: 5 fixed masters + 1 per region (dfx_decoupler_pr_ctrl_r)
  set num_mi_periph [expr {5 + $num_dfx_region}]
  set DFX_Ctrl_0_axi_periph [ create_bd_cell -type ip \
      -vlnv xilinx.com:ip:axi_interconnect:2.1 DFX_Ctrl_0_axi_periph ]
  set_property -dict [list \
    CONFIG.NUM_MI $num_mi_periph \
    CONFIG.NUM_SI {2} \
  ] $DFX_Ctrl_0_axi_periph

  # Build DFX_Ctrl_B VS list: one VS per region, RMs from rm_schemetics_list
  set vs_list {}
  set rm_offset 0
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    set vs_name    "VS_${r}"
    set region_rms [lindex $rm_schemetics_list $r]
    set num_region_rms [lindex $num_rm_per_region $r]

    set rm_list {}
    for {set m 0} {$m < $num_region_rms} {incr m} {
      lappend rm_list "rm${m}" [list ID $m NAME "rm${m}" \
          BS [list 0 [list ID 0 ADDR 0 SIZE 0 CLEAR 0]] \
          SHUTDOWN_REQUIRED hw RESET_REQUIRED low]
    }
    lappend vs_list $vs_name [list \
      ID $r \
      NAME $vs_name \
      RM $rm_list \
      POR_RM rm0 \
      NUM_HW_TRIGGERS $num_region_rms \
      NUM_TRIGGERS_ALLOCATED $num_region_rms \
      START_IN_SHUTDOWN 1 \
      RMS_ALLOCATED $num_region_rms \
    ]
    incr rm_offset $num_region_rms
  }

  # Create instance: DFX_Ctrl_B with multiple virtual systems (one per region)
  set DFX_Ctrl_B [ create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_controller:1.0 DFX_Ctrl_B ]
  set_property -dict [list \
    CONFIG.ALL_PARAMS [list \
      HAS_AXI_LITE_IF 1 \
      RESET_ACTIVE_LEVEL 0 \
      CP_FIFO_DEPTH 32 \
      CP_FIFO_TYPE lutram \
      CDC_STAGES 6 \
      VS $vs_list \
      CP_FAMILY ultrascale_plus \
      DIRTY 3 \
    ] \
  ] $DFX_Ctrl_B

  # Create instance: dfx_b_auto_ack, and set properties
  set dfx_b_auto_ack [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 dfx_b_auto_ack ]
  set_property -dict [list \
      CONFIG.CONST_VAL {1} \
      CONFIG.CONST_WIDTH 1 \
    ] $dfx_b_auto_ack

  set axi_dfx_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_dfx_reset ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x00000001} \
    CONFIG.C_GPIO_WIDTH {1} \
  ] $axi_dfx_reset

  # (1+num_dfx_region)-bit output: [num_dfx_region:1]=PS decoupler value per region, [0]=source-select (1=DFX ctrl, 0=PS)
  set axi_dfx_decup [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_dfx_decup ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH [expr {1 + $num_dfx_region}] \
  ] $axi_dfx_decup

  set icapWrap_0 [ create_bd_cell -type ip -vlnv user.org:user:icapWrap:1.0 icapWrap_0 ]

  # Per-region: reset_join, dfx_decup_ctrl, dfx_decoupler_pr_ctrl
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    set reset_join_r [ create_bd_cell -type ip \
        -vlnv xilinx.com:ip:util_vector_logic:2.0 reset_join_${r} ]
    set_property CONFIG.C_SIZE {1} $reset_join_r

    set dfx_decup_ctrl_r [ create_bd_cell -type ip \
        -vlnv user.org:user:dfx_decup_ctrl:1.0 dfx_decup_ctrl_${r} ]
    set_property -dict [list \
        CONFIG.REGION_IDX $r \
        CONFIG.NUM_REGION $num_dfx_region] \
        $dfx_decup_ctrl_r

    set dfx_decoupler_pr_ctrl_r [ create_bd_cell -type ip \
        -vlnv xilinx.com:ip:dfx_decoupler:1.0 dfx_decoupler_pr_ctrl_${r} ]
    set_property -dict [list \
      CONFIG.ALL_PARAMS \
          {HAS_SIGNAL_STATUS 0 ALWAYS_HAVE_AXI_CLK 1 INTF {intf_0 {ID 0 VLNV xilinx.com:interface:aximm_rtl:1.0}}} \
      CONFIG.GUI_SELECT_VLNV {xilinx.com:interface:aximm_rtl:1.0} \
    ] $dfx_decoupler_pr_ctrl_r
  }

  # xlslice instances: slice dfx_rm_program bits per region for each VS's hw_triggers
  # dfx_rm_program[offset_r .. offset_r + M_r - 1] → vsm_VS_r_hw_triggers
  set rm_offset 0
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    set num_region_rms [lindex $num_rm_per_region $r]
    set slicer [ create_bd_cell -type ip \
        -vlnv xilinx.com:ip:xlslice:1.0 dfx_rm_prog_slice_${r} ]
    set_property -dict [list \
      CONFIG.DIN_WIDTH  $total_rm \
      CONFIG.DIN_FROM   [expr {$rm_offset + $num_region_rms - 1}] \
      CONFIG.DIN_TO     $rm_offset \
    ] $slicer
    incr rm_offset $num_region_rms
  }

#  # xlconcat: aggregate per-region vsm_VS_r_rm_reset → dfx_rm_nreset
#  # Each VS provides 1-bit rm_reset; replicate M_r times to fill region's bits in dfx_rm_nreset
#  for {set r 0} {$r < $num_dfx_region} {incr r} {
#    set num_region_rms [lindex $num_rm_per_region $r]
#    set nreset_expand_r [ create_bd_cell -type ip \
#        -vlnv xilinx.com:ip:xlconcat:2.1 dfx_nreset_expand_${r} ]
#    set_property CONFIG.NUM_PORTS $num_region_rms $nreset_expand_r
#  }
  set dfx_rm_nreset_concat [ create_bd_cell -type ip \
      -vlnv xilinx.com:ip:xlconcat:2.1 dfx_rm_nreset_concat ]
  set concat_prop_list [list CONFIG.NUM_PORTS $num_dfx_region]
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    lappend concat_prop_list "CONFIG.IN${r}_WIDTH" [lindex $num_rm_per_region $r]
  }
  set_property -dict $concat_prop_list $dfx_rm_nreset_concat

  # Create instance: dma_hier
  create_hier_cell_dma_hier [current_bd_instance .] dma_hier

  ##------------------------------------------------------------
  ## STAGE 6: INTERFACE CONNECTIONS
  ##------------------------------------------------------------
  connect_bd_intf_net -intf_net DFX_Ctrl_0_M_AXI \
      [get_bd_intf_pins DFX_Mng/M_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M00_AXI \
      [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M00_AXI] [get_bd_intf_pins dma_hier/S_AXI_LITE]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M01_AXI \
      [get_bd_intf_pins DFX_Mng/S_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M02_AXI \
      [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M02_AXI] [get_bd_intf_pins DFX_Ctrl_B/s_axi_reg]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M03_AXI \
      [get_bd_intf_pins axi_dfx_reset/S_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M04_AXI \
      [get_bd_intf_pins axi_dfx_decup/S_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M04_AXI]

  # Per-region decoupler_pr_ctrl connections (M05 .. M05+N-1)
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    set m_idx [format "%02d" [expr {5 + $r}]]
    connect_bd_intf_net -intf_net "DFX_Ctrl_0_axi_periph_M${m_idx}_AXI_r${r}" \
        [get_bd_intf_pins dfx_decoupler_pr_ctrl_${r}/rp_intf_0] \
        [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M${m_idx}_AXI]
    connect_bd_intf_net -intf_net "dfx_decoupler_pr_ctrl_${r}_s_intf_0" \
        [get_bd_intf_ports M_AXI_LITE_PR_CTRL_${r}] \
        [get_bd_intf_pins dfx_decoupler_pr_ctrl_${r}/s_intf_0]
  }

  connect_bd_intf_net -intf_net DFX_Ctrl_B_ICAP \
      [get_bd_intf_pins DFX_Ctrl_B/ICAP] [get_bd_intf_pins icapWrap_0/ICAP]
  connect_bd_intf_net -intf_net DFX_Ctrl_B_M_AXI_MEM \
      [get_bd_intf_ports M_AXI_BS] [get_bd_intf_pins DFX_Ctrl_B/M_AXI_MEM]

  for {set i 1} {$i < [llength $interface_widths]} {incr i} {
    connect_bd_intf_net -intf_net Dfx_Streamer_${i}_M_AXI \
        [get_bd_intf_ports M_AXIS_DS$i] [get_bd_intf_pins Dfx_Streamer_${i}/M_AXI]
    connect_bd_intf_net -intf_net S_AXI_${i}_1 \
        [get_bd_intf_ports S_AXIS_DS$i] [get_bd_intf_pins Dfx_Streamer_${i}/S_AXI]
  }

  connect_bd_intf_net -intf_net S01_AXI_0_1 \
      [get_bd_intf_ports S_AXI_CTRL] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/S01_AXI]
  connect_bd_intf_net -intf_net S_AXIS_DS0_1 \
      [get_bd_intf_ports S_AXIS_DS0] [get_bd_intf_pins dma_hier/S_AXIS_DS0]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S \
      [get_bd_intf_ports M_AXI_DMA_IN] [get_bd_intf_pins dma_hier/M_AXI_DMA_IN]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM \
      [get_bd_intf_ports M_AXI_DMA_OUT] [get_bd_intf_pins dma_hier/M_AXI_DMA_OUT]
  connect_bd_intf_net -intf_net dfx_decoupler_1_rp_intf_0 \
      [get_bd_intf_ports M_AXIS_DS0] [get_bd_intf_pins dma_hier/M_AXIS_DS0]


  ##------------------------------------------------------------
  ## STAGE 7: NET CONNECTIONS
  ##------------------------------------------------------------
  for {set i 1} {$i < [llength $interface_widths]} {incr i} {
    connect_bd_net -net DFX_Ctrl_0_dfx_stream_load_init \
        [get_bd_pins DFX_Mng/dfx_stream_load_init] [get_bd_pins Dfx_Streamer_${i}/loadInit_pool]
    connect_bd_net -net DFX_Ctrl_0_dfx_stream_load_reset \
        [get_bd_pins DFX_Mng/dfx_stream_load_reset] [get_bd_pins Dfx_Streamer_${i}/loadReset_pool]
    connect_bd_net -net DFX_Ctrl_0_dfx_stream_store_init \
        [get_bd_pins DFX_Mng/dfx_stream_store_init] [get_bd_pins Dfx_Streamer_${i}/storeInit_pool]
    connect_bd_net -net DFX_Ctrl_0_dfx_stream_store_reset \
        [get_bd_pins DFX_Mng/dfx_stream_store_reset] [get_bd_pins Dfx_Streamer_${i}/storeReset_pool]
    connect_bd_net -net Dfx_Streamer_${i}_finStore \
        [get_bd_pins Dfx_Streamer_${i}/finStore] [get_bd_pins fin_store_concat_0/In${i}]
  }

  connect_bd_net -net Dfx_Streamer_1_dbg_amt_load_bytes \
      [get_bd_pins Dfx_Streamer_1/dbg_amt_load_bytes] [get_bd_ports dbg_amt_load_bytes_0]
  connect_bd_net -net Dfx_Streamer_1_dbg_amt_store_bytes \
      [get_bd_pins Dfx_Streamer_1/dbg_amt_store_bytes] [get_bd_ports dbg_amt_store_bytes_0]
  connect_bd_net -net Dfx_Streamer_1_dbg_state \
      [get_bd_pins Dfx_Streamer_1/dbg_state] [get_bd_ports dbg_state_0]

  connect_bd_net -net DFX_Mng_dfx_intr \
      [get_bd_pins DFX_Mng/dfx_intr] [get_bd_ports dfx_intr]
  connect_bd_net -net axi_dma_0_s2mm_introut \
      [get_bd_pins dma_hier/s2mm_introut] [get_bd_pins fin_store_concat_0/In0]

  # Per-region: dfx_rm_program slicing → VS hw_triggers
  #             VS rm_decouple → dfx_decup_ctrl_r
  #             VS rm_reset → reset_join_r → dfx_nreset_r port + dfx_rm_nreset_concat
  #             auto-ack (1-bit constant) → VS rm_shutdown_ack
  # Shared fan-out sources: accumulate all region destinations, connect once after loop
  set dfx_reset_pins [list [get_bd_pins axi_dfx_reset/gpio_io_o]]
  set auto_ack_pins  [list [get_bd_pins dfx_b_auto_ack/dout]]
  set dfx_decup_pins [list [get_bd_pins axi_dfx_decup/gpio_io_o]]

  for {set r 0} {$r < $num_dfx_region} {incr r} {
    connect_bd_net -net "dfx_rm_prog_slice_${r}_Dout" \
        [get_bd_pins dfx_rm_prog_slice_${r}/Dout] \
        [get_bd_pins DFX_Ctrl_B/vsm_VS_${r}_hw_triggers]
    connect_bd_net -net "DFX_Ctrl_B_vsm_VS_${r}_rm_decouple" \
        [get_bd_pins DFX_Ctrl_B/vsm_VS_${r}_rm_decouple] \
        [get_bd_pins dfx_decup_ctrl_${r}/decup_dfx_ctrl]
    # vsm_VS_r_rm_reset fans out to: reset_join Op1 + all dfx_nreset_expand In* ports.
    #set num_region_rms [lindex $num_rm_per_region $r]
    #set rm_reset_pins [list \
    #    [get_bd_pins DFX_Ctrl_B/vsm_VS_${r}_rm_reset] \
    #    [get_bd_pins reset_join_${r}/Op1]]
    connect_bd_net -net "DFX_Ctrl_B_vsm_VS_${r}_rm_reset" [get_bd_pins DFX_Ctrl_B/vsm_VS_${r}_rm_reset] \
    [get_bd_pins dfx_rm_nreset_concat/In${r}] \
    [get_bd_pins reset_join_${r}/Op1]
    connect_bd_net -net "reset_join_${r}_Res" \
        [get_bd_pins reset_join_${r}/Res] \
        [get_bd_ports dfx_nreset_${r}]

    #for {set m 0} {$m < $num_region_rms} {incr m} {
    #  lappend rm_reset_pins [get_bd_pins dfx_nreset_expand_${r}/In${m}]
    #}
    #connect_bd_net -net "DFX_Ctrl_B_vsm_VS_${r}_rm_reset" {*}$rm_reset_pins

    #connect_bd_net -net "dfx_nreset_expand_${r}_dout" \
    #    [get_bd_pins dfx_nreset_expand_${r}/dout] \
    #    [get_bd_pins dfx_rm_nreset_concat/In${r}]
    # Accumulate shared fan-out destinations
    lappend dfx_reset_pins [get_bd_pins reset_join_${r}/Op2]
    lappend auto_ack_pins  [get_bd_pins DFX_Ctrl_B/vsm_VS_${r}_rm_shutdown_ack]
    lappend dfx_decup_pins [get_bd_pins dfx_decup_ctrl_${r}/decup_and_ctrl_ps]
  }

  # Connect shared fan-out sources to all regions in single calls
  connect_bd_net -net "axi_dfx_reset_gpio_io_o" {*}$dfx_reset_pins
  connect_bd_net -net "dfx_b_auto_ack_dout"     {*}$auto_ack_pins
  connect_bd_net -net "axi_dfx_decup_gpio_io_o" {*}$dfx_decup_pins

  connect_bd_net -net dfx_rm_nreset_concat_dout \
      [get_bd_pins dfx_rm_nreset_concat/dout] [get_bd_pins DFX_Mng/dfx_rm_nreset]

  # Per-region decup_res fan-out: dfx_decoupler_pr_ctrl + DMA (r=0 only) + streamers.
  # All destinations in one connect_bd_net call per region.
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    set decup_pins [list \
        [get_bd_pins dfx_decup_ctrl_${r}/decup_res] \
        [get_bd_pins dfx_decoupler_pr_ctrl_${r}/decouple]]
    set region [lindex $dfx_regions_list $r]
    foreach l_idx [dict get $region load_streamers] {
      if {$l_idx == 0} {
        lappend decup_pins [get_bd_pins dma_hier/decup_load]
      } elseif {$l_idx > 0} {
        lappend decup_pins [get_bd_pins Dfx_Streamer_${l_idx}/decup_load]
      }
    }
    foreach s_idx [dict get $region store_streamers] {
      if {$s_idx == 0} {
        lappend decup_pins [get_bd_pins dma_hier/decup_store]
      } elseif {$s_idx > 0} {
        lappend decup_pins [get_bd_pins Dfx_Streamer_${s_idx}/decup_store]
      }
    }
    connect_bd_net -net "dfx_decup_ctrl_${r}_decup_res" {*}$decup_pins
  }

  connect_bd_net -net fin_store_concat_0_dout \
      [get_bd_pins fin_store_concat_0/dout] [get_bd_pins DFX_Mng/dfx_stream_fin]

  # Build clock and reset pin lists dynamically for axi_periph master ports
  set clk_pins   [list \
      [get_bd_ports clk] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/S00_ACLK] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/M00_ACLK] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/ACLK] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/S01_ACLK] \
      [get_bd_pins DFX_Ctrl_B/clk] \
      [get_bd_pins DFX_Ctrl_B/icap_clk] \
      [get_bd_pins axi_dfx_reset/s_axi_aclk] \
      [get_bd_pins axi_dfx_decup/s_axi_aclk] \
      [get_bd_pins DFX_Mng/clk] \
      [get_bd_pins icapWrap_0/CLK] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/M01_ACLK] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/M02_ACLK] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/M03_ACLK] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/M04_ACLK] \
      [get_bd_pins dma_hier/clk] \
  ]
  set rst_pins   [list \
      [get_bd_ports nreset] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/S00_ARESETN] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/M00_ARESETN] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/ARESETN] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/S01_ARESETN] \
      [get_bd_pins DFX_Ctrl_B/reset] \
      [get_bd_pins DFX_Ctrl_B/icap_reset] \
      [get_bd_pins axi_dfx_reset/s_axi_aresetn] \
      [get_bd_pins axi_dfx_decup/s_axi_aresetn] \
      [get_bd_pins DFX_Mng/nreset] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/M01_ARESETN] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/M02_ARESETN] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/M03_ARESETN] \
      [get_bd_pins DFX_Ctrl_0_axi_periph/M04_ARESETN] \
      [get_bd_pins dma_hier/nreset] \
  ]
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    set m_idx [format "%02d" [expr {5 + $r}]]
    lappend clk_pins [get_bd_pins DFX_Ctrl_0_axi_periph/M${m_idx}_ACLK]
    lappend clk_pins [get_bd_pins dfx_decoupler_pr_ctrl_${r}/intf_0_aclk]
    lappend rst_pins [get_bd_pins DFX_Ctrl_0_axi_periph/M${m_idx}_ARESETN]
    lappend rst_pins [get_bd_pins dfx_decoupler_pr_ctrl_${r}/intf_0_arstn]
  }
  for {set i 1} {$i < [llength $interface_widths]} {incr i} {
    lappend clk_pins [get_bd_pins Dfx_Streamer_${i}/clk]
    lappend rst_pins [get_bd_pins Dfx_Streamer_${i}/nreset]
  }
  connect_bd_net -net clk_0_1   {*}$clk_pins
  connect_bd_net -net reset_0_1 {*}$rst_pins

  # dfx_rm_program fan-out to all slicers — single call
  set rm_prog_pins [list [get_bd_pins DFX_Mng/dfx_rm_program]]
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    lappend rm_prog_pins [get_bd_pins dfx_rm_prog_slice_${r}/Din]
  }
  connect_bd_net -net DFX_Mng_dfx_rm_program {*}$rm_prog_pins

  ##------------------------------------------------------------
  ## STAGE 8: ADDRESS SEGMENTS
  ##------------------------------------------------------------
  # Fixed addresses: DFX_Mng self=0x00000000, DFX_Ctrl_B=0x00010000,
  #                  DMA=0x00020000, dfx_reset=0x00030000, dfx_decup=0x00040000
  # Per-region PR ctrl starts at 0x00050000, each region 0x00010000 apart
  assign_bd_address -offset 0x00000000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] \
      [get_bd_addr_segs DFX_Mng/S_AXI/reg0] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] \
      [get_bd_addr_segs DFX_Ctrl_B/s_axi_reg/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] \
      [get_bd_addr_segs dma_hier/axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00030000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] \
      [get_bd_addr_segs axi_dfx_reset/S_AXI/Reg] -force
  assign_bd_address -offset 0x00040000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] \
      [get_bd_addr_segs axi_dfx_decup/S_AXI/Reg] -force
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    set pr_offset [format "0x%08X" [expr {0x00060000 + $r * 0x00010000}]]
    assign_bd_address -offset $pr_offset -range 0x00010000 \
        -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] \
        [get_bd_addr_segs M_AXI_LITE_PR_CTRL_${r}/Reg] -force
  }
  assign_bd_address -offset 0x00000000 -range 0x000100000000 \
      -target_address_space [get_bd_addr_spaces DFX_Ctrl_B/Data] \
      [get_bd_addr_segs M_AXI_BS/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 \
      -target_address_space [get_bd_addr_spaces dma_hier/axi_dma_0/Data_MM2S] \
      [get_bd_addr_segs M_AXI_DMA_IN/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 \
      -target_address_space [get_bd_addr_spaces dma_hier/axi_dma_0/Data_S2MM] \
      [get_bd_addr_segs M_AXI_DMA_OUT/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces S_AXI_CTRL] \
      [get_bd_addr_segs DFX_Mng/S_AXI/reg0] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces S_AXI_CTRL] \
      [get_bd_addr_segs DFX_Ctrl_B/s_axi_reg/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces S_AXI_CTRL] \
      [get_bd_addr_segs dma_hier/axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00030000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces S_AXI_CTRL] \
      [get_bd_addr_segs axi_dfx_reset/S_AXI/Reg] -force
  assign_bd_address -offset 0x00040000 -range 0x00010000 \
      -target_address_space [get_bd_addr_spaces S_AXI_CTRL] \
      [get_bd_addr_segs axi_dfx_decup/S_AXI/Reg] -force
  for {set r 0} {$r < $num_dfx_region} {incr r} {
    set pr_offset [format "0x%08X" [expr {0x00060000 + $r * 0x00010000}]]
    assign_bd_address -offset $pr_offset -range 0x00010000 \
        -target_address_space [get_bd_addr_spaces S_AXI_CTRL] \
        [get_bd_addr_segs M_AXI_LITE_PR_CTRL_${r}/Reg] -force
  }


  ##------------------------------------------------------------
  ## STAGE 9: FINALIZE
  ##------------------------------------------------------------
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design

  close_bd_design dfx_unified
}

