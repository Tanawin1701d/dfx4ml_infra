proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
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
  set M_AXI_DMA_IN_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA_IN_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {99999001} \
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
   ] $M_AXI_DMA_IN_0

  set M_AXI_BS_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_BS_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {99999001} \
   CONFIG.HAS_BRESP {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_WSTRB {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {2} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {READ_ONLY} \
   ] $M_AXI_BS_0

  set M_AXI_DMA_OUT_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA_OUT_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {99999001} \
   CONFIG.HAS_BURST {0} \
   CONFIG.HAS_LOCK {0} \
   CONFIG.HAS_QOS {0} \
   CONFIG.HAS_REGION {0} \
   CONFIG.HAS_RRESP {0} \
   CONFIG.NUM_READ_OUTSTANDING {2} \
   CONFIG.NUM_WRITE_OUTSTANDING {16} \
   CONFIG.PROTOCOL {AXI4} \
   CONFIG.READ_WRITE_MODE {WRITE_ONLY} \
   ] $M_AXI_DMA_OUT_0

  set S_AXI_CTRL_0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL_0 ]
  set_property -dict [ list \
   CONFIG.ADDR_WIDTH {32} \
   CONFIG.ARUSER_WIDTH {0} \
   CONFIG.AWUSER_WIDTH {0} \
   CONFIG.BUSER_WIDTH {0} \
   CONFIG.DATA_WIDTH {32} \
   CONFIG.FREQ_HZ {99999001} \
   CONFIG.HAS_BRESP {1} \
   CONFIG.HAS_BURST {1} \
   CONFIG.HAS_CACHE {1} \
   CONFIG.HAS_LOCK {1} \
   CONFIG.HAS_PROT {1} \
   CONFIG.HAS_QOS {1} \
   CONFIG.HAS_REGION {1} \
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
   ] $S_AXI_CTRL_0


  # Create ports
  set dfx_intr_0 [ create_bd_port -dir O -type intr dfx_intr_0 ]
  set clk_0 [ create_bd_port -dir I -type clk -freq_hz 99999001 clk_0 ]
  set nreset_0 [ create_bd_port -dir I -type rst nreset_0 ]

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
  set dfx_pr_0_0 [ create_bd_cell -type container -reference dfx_pr_0 dfx_pr_0_0 ]
  set_property -dict [list \
    CONFIG.ACTIVE_SIM_BD {dfx_pr_0.bd} \
    CONFIG.ACTIVE_SYNTH_BD {dfx_pr_0.bd} \
    CONFIG.ENABLE_DFX {true} \
    CONFIG.LIST_SIM_BD {dfx_pr_0.bd:dfx_pr_1.bd} \
    CONFIG.LIST_SYNTH_BD {dfx_pr_0.bd:dfx_pr_1.bd} \
    CONFIG.LOCK_PROPAGATE {0} \
  ] $dfx_pr_0_0


  # Create interface connections
  connect_bd_intf_net -intf_net S_AXI_CTRL_0_1 [get_bd_intf_ports S_AXI_CTRL_0] [get_bd_intf_pins dfx_unified_0/S_AXI_CTRL]
  connect_bd_intf_net -intf_net dfx_pr_0_0_M_DS_0 [get_bd_intf_pins dfx_pr_0_0/M_DS_0] [get_bd_intf_pins dfx_unified_0/S_AXIS_DS0]
  connect_bd_intf_net -intf_net dfx_pr_0_0_M_DS_1 [get_bd_intf_pins dfx_pr_0_0/M_DS_1] [get_bd_intf_pins dfx_unified_0/S_AXIS_DS1]
  connect_bd_intf_net -intf_net dfx_unified_0_M_AXIS_DS0 [get_bd_intf_pins dfx_unified_0/M_AXIS_DS0] [get_bd_intf_pins dfx_pr_0_0/S_DS_0]
  connect_bd_intf_net -intf_net dfx_unified_0_M_AXIS_DS1 [get_bd_intf_pins dfx_unified_0/M_AXIS_DS1] [get_bd_intf_pins dfx_pr_0_0/S_DS_1]
  connect_bd_intf_net -intf_net dfx_unified_0_M_AXI_BS [get_bd_intf_ports M_AXI_BS_0] [get_bd_intf_pins dfx_unified_0/M_AXI_BS]
  connect_bd_intf_net -intf_net dfx_unified_0_M_AXI_DMA_IN [get_bd_intf_ports M_AXI_DMA_IN_0] [get_bd_intf_pins dfx_unified_0/M_AXI_DMA_IN]
  connect_bd_intf_net -intf_net dfx_unified_0_M_AXI_DMA_OUT [get_bd_intf_ports M_AXI_DMA_OUT_0] [get_bd_intf_pins dfx_unified_0/M_AXI_DMA_OUT]

  # Create port connections
  connect_bd_net -net clk_0_1 [get_bd_ports clk_0] [get_bd_pins dfx_unified_0/clk] [get_bd_pins dfx_pr_0_0/clk]
  connect_bd_net -net dfx_unified_0_dfx_intr [get_bd_pins dfx_unified_0/dfx_intr] [get_bd_ports dfx_intr_0]
  connect_bd_net -net dfx_unified_0_dfx_nreset [get_bd_pins dfx_unified_0/dfx_nreset] [get_bd_pins dfx_pr_0_0/nreset]
  connect_bd_net -net nreset_0_1 [get_bd_ports nreset_0] [get_bd_pins dfx_unified_0/nreset]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -with_name SEG_M_AXI_BS_Reg -target_address_space [get_bd_addr_spaces dfx_unified_0/DFX_Ctrl_B/Data] [get_bd_addr_segs M_AXI_BS_0/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -with_name SEG_M_AXI_DMA_IN_Reg -target_address_space [get_bd_addr_spaces dfx_unified_0/dma_hier/axi_dma_0/Data_MM2S] [get_bd_addr_segs M_AXI_DMA_IN_0/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -with_name SEG_M_AXI_DMA_OUT_Reg -target_address_space [get_bd_addr_spaces dfx_unified_0/dma_hier/axi_dma_0/Data_S2MM] [get_bd_addr_segs M_AXI_DMA_OUT_0/Reg] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dfx_unified_0/DFX_Mng/M_AXI] [get_bd_addr_segs dfx_unified_0/DFX_Ctrl_B/s_axi_reg/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dfx_unified_0/DFX_Mng/M_AXI] [get_bd_addr_segs dfx_unified_0/DFX_Mng/S_AXI/reg0] -force
  assign_bd_address -offset 0x00040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dfx_unified_0/DFX_Mng/M_AXI] [get_bd_addr_segs dfx_unified_0/axi_dfx_decup/S_AXI/Reg] -force
  assign_bd_address -offset 0x00030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dfx_unified_0/DFX_Mng/M_AXI] [get_bd_addr_segs dfx_unified_0/axi_dfx_reset/S_AXI/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces dfx_unified_0/DFX_Mng/M_AXI] [get_bd_addr_segs dfx_unified_0/dma_hier/axi_dma_0/S_AXI_LITE/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}