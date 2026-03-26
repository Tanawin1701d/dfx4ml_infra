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

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_LITE

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA_IN

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA_OUT

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DS0

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DS0


  # Create pins
  create_bd_pin -dir I -type clk clk
  create_bd_pin -dir I -type rst nreset
  create_bd_pin -dir O -type intr s2mm_introut
  create_bd_pin -dir I decouple

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


  # Create interface connections
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M00_AXI [get_bd_intf_pins S_AXI_LITE] [get_bd_intf_pins axi_dma_0/S_AXI_LITE]
  connect_bd_intf_net -intf_net S_AXIS_DS0_1 [get_bd_intf_pins S_AXIS_DS0] [get_bd_intf_pins dfx_decoupler_0/rp_intf_0]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXIS_MM2S [get_bd_intf_pins dfx_decoupler_1/s_intf_0] [get_bd_intf_pins axi_dma_0/M_AXIS_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_pins M_AXI_DMA_IN] [get_bd_intf_pins axi_dma_0/M_AXI_MM2S]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_pins M_AXI_DMA_OUT] [get_bd_intf_pins axi_dma_0/M_AXI_S2MM]
  connect_bd_intf_net -intf_net dfx_decoupler_0_s_intf_0 [get_bd_intf_pins dfx_decoupler_0/s_intf_0] [get_bd_intf_pins axi_dma_0/S_AXIS_S2MM]
  connect_bd_intf_net -intf_net dfx_decoupler_1_rp_intf_0 [get_bd_intf_pins M_AXIS_DS0] [get_bd_intf_pins dfx_decoupler_1/rp_intf_0]

  # Create port connections
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins axi_dma_0/s2mm_introut] [get_bd_pins s2mm_introut]
  connect_bd_net -net clk_0_1 [get_bd_pins clk] [get_bd_pins axi_dma_0/m_axi_mm2s_aclk] [get_bd_pins axi_dma_0/m_axi_s2mm_aclk] [get_bd_pins dfx_decoupler_0/intf_0_aclk] [get_bd_pins dfx_decoupler_1/intf_0_aclk] [get_bd_pins axi_dma_0/s_axi_lite_aclk]
  connect_bd_net -net reset_0_1 [get_bd_pins nreset] [get_bd_pins dfx_decoupler_0/intf_0_arstn] [get_bd_pins dfx_decoupler_1/intf_0_arstn] [get_bd_pins axi_dma_0/axi_resetn]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins decouple] [get_bd_pins dfx_decoupler_1/decouple] [get_bd_pins dfx_decoupler_0/decouple]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell clk_frq rm_index_width num_dfx_streamer interface_widths applied_interface_widths storage_index_widths} {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
  }
  
  # Check rm_index_width is not zero
  if { $rm_index_width == 0 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "rm_index_width <$rm_index_width> is zero"}
     return
  }

  # 1. num_dfx_streamer must be power of two
  if { $num_dfx_streamer == 0 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "num_dfx_streamer <num_dfx_streamer> is zero"}
     return
  }
  
  # Check num_dfx_streamer matches array lengths
  if { $num_dfx_streamer != [llength $interface_widths] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "num_dfx_streamer <$num_dfx_streamer> must equal length of interface_widths <[llength $interface_widths]>!"}
     return
  }

  if { $num_dfx_streamer != [llength $applied_interface_widths] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "num_dfx_streamer <$num_dfx_streamer> must equal length of applied_interface_widths <[llength $applied_interface_widths]>!"}
     return
  }
  
  if { $num_dfx_streamer != [llength $storage_index_widths] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "num_dfx_streamer <$num_dfx_streamer> must equal length of storage_index_widths <[llength $storage_index_widths]>!"}
     return
  }
  
  

  # 2. interface_widths elements must be power of two
  # 3. applied_interface_widths elements must be <= interface_widths elements at same index
  if { [llength $interface_widths] != [llength $applied_interface_widths] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2093 -severity "ERROR" "interface_widths and applied_interface_widths must have the same length!"}
     return
  }

  for {set i 0} {$i < $num_dfx_streamer} {incr i} {
     set iw  [lindex $interface_widths $i]         ;# iw      interface width
     set aiw [lindex $applied_interface_widths $i] ;# aiw     applied interface width
     set sw  [lindex $storage_index_widths $i]     ;# sw      storage index width

     if { !($iw != 0 && ($iw & ($iw - 1)) == 0) } {
        catch {common::send_gid_msg -ssname BD::TCL -id 2094 -severity "ERROR" "interface_widths\[$i\] = <$iw> is not a power of two!"}
        return
     }

     if { $aiw > $iw } {
        catch {common::send_gid_msg -ssname BD::TCL -id 2095 -severity "ERROR" "applied_interface_widths\[$i\] = <$aiw> must be lower or equal to interface_widths\[$i\] = <$iw>!"}
        return
     }

     if { $sw <= 0 } {
        catch {common::send_gid_msg -ssname BD::TCL -id 2096 -severity "ERROR" "storage_index_widths\[$i\] = <$sw> must be greater than 0!"}
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


  # Create interface ports
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
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ "$clk_frq" \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {1} \
   CONFIG.HAS_WSTRB {1} \
   CONFIG.ID_WIDTH {1} \
   CONFIG.MAX_BURST_LENGTH {256} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_READ_THREADS {1} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_THREADS {1} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_WRITE} \
   CONFIG.RUSER_BITS_PER_BYTE {0} \
   CONFIG.RUSER_WIDTH {0} \
   CONFIG.SUPPORTS_NARROW_BURST {1} \
   CONFIG.WUSER_BITS_PER_BYTE {0} \
   CONFIG.WUSER_WIDTH {0} \
   ] $S_AXI_CTRL

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

  for {set i 1} {$i < $num_dfx_streamer} {incr i} {
    set port_name "M_AXIS_DS$i"
    
    set M_AXIS_DS_PORT [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 $port_name ]
    set_property -dict [ list \
     CONFIG.FREQ_HZ "$clk_frq" \
     ] $M_AXIS_DS_PORT
  }


  # Create ports
  set clk [ create_bd_port -dir I -type clk -freq_hz $clk_frq clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M_AXI_DMA_IN:M_AXI_DMA_OUT:M_AXIS_DS0:S_AXIS_DS0:S_AXIS_DS1:S_AXI_CTRL:M_AXI_BS:M_AXIS_DS1} \
 ] $clk
  set nreset [ create_bd_port -dir I -type rst nreset ]
  set pr_reset [ create_bd_port -dir O -from 0 -to 0 pr_reset ]
  set dfx_intr [ create_bd_port -dir O -type intr dfx_intr ]
  set dbg_amt_load_bytes_0 [ create_bd_port -dir O -from 10 -to 0 dbg_amt_load_bytes_0 ]
  set dbg_amt_store_bytes_0 [ create_bd_port -dir O -from 10 -to 0 dbg_amt_store_bytes_0 ]
  set dbg_state_0 [ create_bd_port -dir O -from 3 -to 0 dbg_state_0 ]

  # Create instance: DFX_Mng, and set properties
  set DFX_Mng [ create_bd_cell -type ip -vlnv user.org:user:DFX_Mng:1.0 DFX_Mng ]
  set_property -dict [ list \
     CONFIG.BANK1_INDEX_WIDTH  "$rm_index_width" \
     CONFIG.BANK1_LD_MSK_WIDTH "$num_dfx_streamer" \
     CONFIG.BANK1_ST_MSK_WIDTH "$num_dfx_streamer" \
     ] $DFX_Mng

  # Create instance: Dfx_Streamer_i, and set properties
  for {set i 1} {$i < $num_dfx_streamer} {incr i} {
    set Dfx_Streamer_$i [ create_bd_cell -type ip -vlnv user.org:user:Dfx_Streamer:1.0 Dfx_Streamer_$i ]
    set target_streamer [set Dfx_Streamer_$i]
    set aiw [lindex $applied_interface_widths $i] ; # actual/applied index width
    set iw [lindex $interface_widths $i]          ; # interface index width
    set sw [lindex $storage_index_widths $i]      ; # storage index width
    set_property -dict [ list \
         CONFIG.DATA_WIDTH "$aiw" \
         CONFIG.ITF_DATA_WIDTH "$iw" \
         CONFIG.STORAGE_IDX_WIDTH "$sw" \
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


  # Create instance: DFX_Ctrl_0_axi_periph, and set properties
  set DFX_Ctrl_0_axi_periph [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 DFX_Ctrl_0_axi_periph ]
  set_property -dict [list \
    CONFIG.NUM_MI {5} \
    CONFIG.NUM_SI {2} \
  ] $DFX_Ctrl_0_axi_periph


  # Create instance: DFX_Ctrl_B, and set properties
  set DFX_Ctrl_B [ create_bd_cell -type ip -vlnv xilinx.com:ip:dfx_controller:1.0 DFX_Ctrl_B ]
  set_property -dict [list \
    CONFIG.ALL_PARAMS {HAS_AXI_LITE_IF 1 RESET_ACTIVE_LEVEL 0 CP_FIFO_DEPTH 32 CP_FIFO_TYPE lutram CDC_STAGES 6 VS {vs4ml {ID 0 NAME vs4ml RM {rm0 {ID 0 NAME rm0 BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED\
hw RESET_REQUIRED low} rm1 {ID 1 NAME rm1 BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED hw RESET_REQUIRED low} rm3 {ID 3 NAME rm3 BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED hw RESET_REQUIRED\
low} rm2 {ID 2 NAME rm2 BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED hw RESET_REQUIRED low} rm4 {ID 4 NAME rm4 BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED hw RESET_REQUIRED low} rm5\
{ID 5 NAME rm5 BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED hw RESET_REQUIRED low} rm6 {ID 6 NAME rm6 BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED hw RESET_REQUIRED low} rm7 {ID 7 NAME\
rm7 BS {0 {ID 0 ADDR 0 SIZE 0 CLEAR 0}} SHUTDOWN_REQUIRED hw RESET_REQUIRED low}} POR_RM rm0 NUM_HW_TRIGGERS 8 NUM_TRIGGERS_ALLOCATED 8 START_IN_SHUTDOWN 1 RMS_ALLOCATED 8}} CP_FAMILY ultrascale_plus DIRTY\
3} \
    CONFIG.GUI_RM_NEW_NAME {rm7} \
    CONFIG.GUI_RM_RESET_REQUIRED {low} \
    CONFIG.GUI_RM_SHUTDOWN_TYPE {hw} \
    CONFIG.GUI_VS_NEW_NAME {vs4ml} \
    CONFIG.GUI_VS_NUM_HW_TRIGGERS {8} \
    CONFIG.GUI_VS_NUM_RMS_ALLOCATED {8} \
    CONFIG.GUI_VS_NUM_TRIGGERS_ALLOCATED {8} \
  ] $DFX_Ctrl_B

  set dummy_dfx_mng_hw_plug [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 dummy_dfx_mng_hw_plug ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH 1 \
  ] $dummy_dfx_mng_hw_plug


  # Create instance: dfx_b_auto_ack, and set properties
  set dfx_b_auto_ack [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 dfx_b_auto_ack ]
  set_property -dict [list \
      CONFIG.CONST_VAL {1} \
      CONFIG.CONST_WIDTH 1 \
    ] $dfx_b_auto_ack

  # Create instance: reset_join, and set properties
  set reset_join [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 reset_join ]
  set_property CONFIG.C_SIZE {1} $reset_join


  # Create instance: axi_dfx_reset, and set properties
  set axi_dfx_reset [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_dfx_reset ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_DOUT_DEFAULT {0x00000001} \
    CONFIG.C_GPIO_WIDTH {1} \
  ] $axi_dfx_reset


  # Create instance: axi_dfx_decup, and set properties
  set axi_dfx_decup [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_dfx_decup ]
  set_property -dict [list \
    CONFIG.C_ALL_OUTPUTS {1} \
    CONFIG.C_GPIO_WIDTH {1} \
  ] $axi_dfx_decup


  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [list \
    CONFIG.C_OPERATION {or} \
    CONFIG.C_SIZE {1} \
  ] $util_vector_logic_0


  # Create instance: icapWrap_0, and set properties
  set icapWrap_0 [ create_bd_cell -type ip -vlnv user.org:user:icapWrap:1.0 icapWrap_0 ]

  # Create instance: dma_hier
  create_hier_cell_dma_hier [current_bd_instance .] dma_hier

  # Create interface connections
  connect_bd_intf_net -intf_net DFX_Ctrl_0_M_AXI [get_bd_intf_pins DFX_Mng/M_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M00_AXI [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M00_AXI] [get_bd_intf_pins dma_hier/S_AXI_LITE]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M01_AXI [get_bd_intf_pins DFX_Mng/S_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M02_AXI [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M02_AXI] [get_bd_intf_pins DFX_Ctrl_B/s_axi_reg]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M03_AXI [get_bd_intf_pins axi_dfx_reset/S_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M04_AXI [get_bd_intf_pins axi_dfx_decup/S_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_B_ICAP [get_bd_intf_pins DFX_Ctrl_B/ICAP] [get_bd_intf_pins icapWrap_0/ICAP]
  connect_bd_intf_net -intf_net DFX_Ctrl_B_M_AXI_MEM [get_bd_intf_ports M_AXI_BS] [get_bd_intf_pins DFX_Ctrl_B/M_AXI_MEM]
  for {set i 1} {$i < [llength $interface_widths]} {incr i} {
    set port_name_s "S_AXIS_DS$i"
    set port_name_m "M_AXIS_DS$i"
    
    connect_bd_intf_net -intf_net Dfx_Streamer_${i}_M_AXI [get_bd_intf_ports $port_name_m] [get_bd_intf_pins Dfx_Streamer_${i}/M_AXI]
    connect_bd_intf_net -intf_net S_AXI_${i}_1 [get_bd_intf_ports $port_name_s] [get_bd_intf_pins Dfx_Streamer_${i}/S_AXI]

  }
  
  connect_bd_intf_net -intf_net S01_AXI_0_1 [get_bd_intf_ports S_AXI_CTRL] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/S01_AXI]
  connect_bd_intf_net -intf_net S_AXIS_DS0_1 [get_bd_intf_ports S_AXIS_DS0] [get_bd_intf_pins dma_hier/S_AXIS_DS0]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_ports M_AXI_DMA_IN] [get_bd_intf_pins dma_hier/M_AXI_DMA_IN]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_ports M_AXI_DMA_OUT] [get_bd_intf_pins dma_hier/M_AXI_DMA_OUT]
  connect_bd_intf_net -intf_net dfx_decoupler_1_rp_intf_0 [get_bd_intf_ports M_AXIS_DS0] [get_bd_intf_pins dma_hier/M_AXIS_DS0]

  # Create port connections

  
  for {set i 1} {$i < [llength $interface_widths]} {incr i} {
    connect_bd_net -net DFX_Ctrl_0_slaveMgsLoadInit [get_bd_pins DFX_Mng/slaveMgsLoadInit] [get_bd_pins Dfx_Streamer_${i}/loadInit_pool]
    connect_bd_net -net DFX_Ctrl_0_slaveMgsLoadReset [get_bd_pins DFX_Mng/slaveMgsLoadReset] [get_bd_pins Dfx_Streamer_${i}/loadReset_pool]
    connect_bd_net -net DFX_Ctrl_0_slaveMgsStoreInit [get_bd_pins DFX_Mng/slaveMgsStoreInit] [get_bd_pins Dfx_Streamer_${i}/storeInit_pool]
    connect_bd_net -net DFX_Ctrl_0_slaveMgsStoreReset [get_bd_pins DFX_Mng/slaveMgsStoreReset] [get_bd_pins Dfx_Streamer_${i}/storeReset_pool]
    connect_bd_net -net util_vector_logic_0_Res [get_bd_pins util_vector_logic_0/Res] [get_bd_pins dma_hier/decouple] [get_bd_pins Dfx_Streamer_${i}/decup]
    connect_bd_net -net Dfx_Streamer_${i}_finStore [get_bd_pins Dfx_Streamer_${i}/finStore] [get_bd_pins fin_store_concat_0/In${i}]
  }
  
  
  connect_bd_net -net Dfx_Streamer_1_dbg_amt_load_bytes [get_bd_pins Dfx_Streamer_1/dbg_amt_load_bytes] [get_bd_ports dbg_amt_load_bytes_0]
  connect_bd_net -net Dfx_Streamer_1_dbg_amt_store_bytes [get_bd_pins Dfx_Streamer_1/dbg_amt_store_bytes] [get_bd_ports dbg_amt_store_bytes_0]
  connect_bd_net -net Dfx_Streamer_1_dbg_state [get_bd_pins Dfx_Streamer_1/dbg_state] [get_bd_ports dbg_state_0]




  connect_bd_net -net DFX_Mng_hw_intr [get_bd_pins DFX_Mng/hw_intr] [get_bd_ports dfx_intr]
  connect_bd_net -net DFX_Mng_slaveReprog [get_bd_pins DFX_Mng/slaveReprog] [get_bd_pins DFX_Ctrl_B/vsm_vs4ml_hw_triggers]
  connect_bd_net -net DFX_Ctrl_B_vsm_vs4ml_rm_decouple [get_bd_pins DFX_Ctrl_B/vsm_vs4ml_rm_decouple] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net DFX_Ctrl_B_vsm_vs4ml_rm_reset [get_bd_pins DFX_Ctrl_B/vsm_vs4ml_rm_reset] [get_bd_pins reset_join/Op1]

  connect_bd_net -net axi_dfx_decup_gpio_io_o [get_bd_pins axi_dfx_decup/gpio_io_o] [get_bd_pins util_vector_logic_0/Op2]
  connect_bd_net -net axi_dfx_reset_gpio_io_o [get_bd_pins axi_dfx_reset/gpio_io_o] [get_bd_pins reset_join/Op2]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins dma_hier/s2mm_introut] [get_bd_pins fin_store_concat_0/In0]
  connect_bd_net -net clk_0_1 [get_bd_ports clk] [get_bd_pins DFX_Ctrl_0_axi_periph/S00_ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/M00_ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/S01_ACLK] [get_bd_pins DFX_Ctrl_B/clk] [get_bd_pins DFX_Ctrl_B/icap_clk] [get_bd_pins axi_dfx_reset/s_axi_aclk] [get_bd_pins axi_dfx_decup/s_axi_aclk] [get_bd_pins DFX_Mng/clk] [get_bd_pins icapWrap_0/CLK] [get_bd_pins DFX_Ctrl_0_axi_periph/M01_ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/M02_ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/M03_ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/M04_ACLK] [get_bd_pins dma_hier/clk]
  connect_bd_net -net reset_0_1 [get_bd_ports nreset] [get_bd_pins DFX_Ctrl_0_axi_periph/S00_ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/M00_ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/S01_ARESETN] [get_bd_pins DFX_Ctrl_B/reset] [get_bd_pins DFX_Ctrl_B/icap_reset] [get_bd_pins axi_dfx_reset/s_axi_aresetn] [get_bd_pins axi_dfx_decup/s_axi_aresetn] [get_bd_pins DFX_Mng/reset] [get_bd_pins DFX_Ctrl_0_axi_periph/M01_ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/M02_ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/M03_ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/M04_ARESETN] [get_bd_pins dma_hier/nreset]
  connect_bd_net -net reset_join_Res [get_bd_pins reset_join/Res] [get_bd_ports pr_reset] [get_bd_pins DFX_Mng/nslaveReset]
  
  for {set i 1} {$i < [llength $interface_widths]} {incr i} {
    connect_bd_net -net clk_0_1   [get_bd_ports clk]    [get_bd_pins Dfx_Streamer_${i}/clk]
    connect_bd_net -net reset_0_1 [get_bd_ports nreset] [get_bd_pins Dfx_Streamer_${i}/reset]
  }

  connect_bd_net -net fin_store_concat_0_dout [get_bd_pins fin_store_concat_0/dout] [get_bd_pins DFX_Mng/mgsFinExec]
  connect_bd_net -net dummy_dfx_mng_hw_plug_dout [get_bd_pins dummy_dfx_mng_hw_plug/dout] [get_bd_pins DFX_Mng/hw_ctrl_start] [get_bd_pins DFX_Mng/hw_intr_clear]
  
  
  connect_bd_net -net dfx_b_auto_ack_dout [get_bd_pins dfx_b_auto_ack/dout] [get_bd_pins DFX_Ctrl_B/vsm_vs4ml_rm_shutdown_ack]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] [get_bd_addr_segs DFX_Mng/S_AXI/reg0] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] [get_bd_addr_segs DFX_Ctrl_B/s_axi_reg/Reg] -force
  assign_bd_address -offset 0x00040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] [get_bd_addr_segs axi_dfx_decup/S_AXI/Reg] -force
  assign_bd_address -offset 0x00030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] [get_bd_addr_segs axi_dfx_reset/S_AXI/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DFX_Mng/M_AXI] [get_bd_addr_segs dma_hier/axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces DFX_Ctrl_B/Data] [get_bd_addr_segs M_AXI_BS/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces dma_hier/axi_dma_0/Data_MM2S] [get_bd_addr_segs M_AXI_DMA_IN/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces dma_hier/axi_dma_0/Data_S2MM] [get_bd_addr_segs M_AXI_DMA_OUT/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs DFX_Mng/S_AXI/reg0] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs DFX_Ctrl_B/s_axi_reg/Reg] -force
  assign_bd_address -offset 0x00040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs axi_dfx_decup/S_AXI/Reg] -force
  assign_bd_address -offset 0x00030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs axi_dfx_reset/S_AXI/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs dma_hier/axi_dma_0/S_AXI_LITE/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}

