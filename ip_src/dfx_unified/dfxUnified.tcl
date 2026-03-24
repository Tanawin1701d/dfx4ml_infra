
################################################################
# This is a generated script based on design: dfx_wrapper
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2023.2
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   if { [string compare $scripts_vivado_version $current_vivado_version] > 0 } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2042 -severity "ERROR" " This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Sourcing the script failed since it was created with a future version of Vivado."}

   } else {
     catch {common::send_gid_msg -ssname BD::TCL -id 2041 -severity "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   }

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source dfx_wrapper_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xck26-sfvc784-2LV-c
   set_property BOARD_PART xilinx.com:kv260_som_som240_1_connector_kv260_carrier_som240_1_connector:part0:1.4 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name dfx_wrapper

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_gid_msg -ssname BD::TCL -id 2001 -severity "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_gid_msg -ssname BD::TCL -id 2002 -severity "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_gid_msg -ssname BD::TCL -id 2003 -severity "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_gid_msg -ssname BD::TCL -id 2004 -severity "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_gid_msg -ssname BD::TCL -id 2005 -severity "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_gid_msg -ssname BD::TCL -id 2006 -severity "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
user.org:user:DFX_Ctrl:1.0\
user.org:user:Dfx_Streamer:1.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:dfx_controller:1.0\
xilinx.com:ip:util_vector_logic:2.0\
xilinx.com:ip:axi_gpio:2.0\
user.org:user:icapWrap:1.0\
xilinx.com:ip:axi_dma:7.1\
xilinx.com:ip:dfx_decoupler:1.0\
"

   set list_ips_missing ""
   common::send_gid_msg -ssname BD::TCL -id 2011 -severity "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_gid_msg -ssname BD::TCL -id 2012 -severity "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_gid_msg -ssname BD::TCL -id 2023 -severity "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

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
  set M_AXI_DMA_IN [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA_IN ]
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
   ] $M_AXI_DMA_IN

  set M_AXI_DMA_OUT [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 M_AXI_DMA_OUT ]
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
   ] $M_AXI_DMA_OUT

  set M_AXIS_DS0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DS0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {99999001} \
   ] $M_AXIS_DS0

  set S_AXIS_DS0 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DS0 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {99999001} \
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

  set S_AXIS_DS1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_AXIS_DS1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {99999001} \
   CONFIG.HAS_TKEEP {0} \
   CONFIG.HAS_TLAST {1} \
   CONFIG.HAS_TREADY {1} \
   CONFIG.HAS_TSTRB {0} \
   CONFIG.LAYERED_METADATA {undef} \
   CONFIG.TDATA_NUM_BYTES {4} \
   CONFIG.TDEST_WIDTH {0} \
   CONFIG.TID_WIDTH {0} \
   CONFIG.TUSER_WIDTH {0} \
   ] $S_AXIS_DS1

  set S_AXI_CTRL [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI_CTRL ]
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
   ] $M_AXI_BS

  set M_AXIS_DS1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_AXIS_DS1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {99999001} \
   ] $M_AXIS_DS1


  # Create ports
  set clk [ create_bd_port -dir I -type clk -freq_hz 99999001 clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M_AXI_DMA_IN:M_AXI_DMA_OUT:M_AXIS_DS0:S_AXIS_DS0:S_AXIS_DS1:S_AXI_CTRL:M_AXI_BS:M_AXIS_DS1} \
 ] $clk
  set nreset [ create_bd_port -dir I -type rst nreset ]
  set pr_reset [ create_bd_port -dir O -from 0 -to 0 pr_reset ]
  set dfx_intr [ create_bd_port -dir O -type intr dfx_intr ]
  set dbg_amt_load_bytes_0 [ create_bd_port -dir O -from 10 -to 0 dbg_amt_load_bytes_0 ]
  set dbg_amt_store_bytes_0 [ create_bd_port -dir O -from 10 -to 0 dbg_amt_store_bytes_0 ]
  set dbg_state_0 [ create_bd_port -dir O -from 3 -to 0 dbg_state_0 ]

  # Create instance: DFX_Ctrl_A, and set properties
  set DFX_Ctrl_A [ create_bd_cell -type ip -vlnv user.org:user:DFX_Ctrl:1.0 DFX_Ctrl_A ]

  # Create instance: Dfx_Streamer_1, and set properties
  set Dfx_Streamer_1 [ create_bd_cell -type ip -vlnv user.org:user:Dfx_Streamer:1.0 Dfx_Streamer_1 ]

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [list \
    CONFIG.IN1_WIDTH {1} \
    CONFIG.IN2_WIDTH {6} \
    CONFIG.NUM_PORTS {3} \
  ] $xlconcat_0


  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property CONFIG.CONST_VAL {0} $xlconstant_0


  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]
  set_property -dict [list \
    CONFIG.CONST_VAL {0} \
    CONFIG.CONST_WIDTH {6} \
  ] $xlconstant_1


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


  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]

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
  connect_bd_intf_net -intf_net DFX_Ctrl_0_M_AXI [get_bd_intf_pins DFX_Ctrl_A/M_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/S00_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M00_AXI [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M00_AXI] [get_bd_intf_pins dma_hier/S_AXI_LITE]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M01_AXI [get_bd_intf_pins DFX_Ctrl_A/S_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M01_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M02_AXI [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M02_AXI] [get_bd_intf_pins DFX_Ctrl_B/s_axi_reg]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M03_AXI [get_bd_intf_pins axi_dfx_reset/S_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M03_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_0_axi_periph_M04_AXI [get_bd_intf_pins axi_dfx_decup/S_AXI] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/M04_AXI]
  connect_bd_intf_net -intf_net DFX_Ctrl_B_ICAP [get_bd_intf_pins DFX_Ctrl_B/ICAP] [get_bd_intf_pins icapWrap_0/ICAP]
  connect_bd_intf_net -intf_net DFX_Ctrl_B_M_AXI_MEM [get_bd_intf_ports M_AXI_BS] [get_bd_intf_pins DFX_Ctrl_B/M_AXI_MEM]
  connect_bd_intf_net -intf_net Dfx_Streamer_1_M_AXI [get_bd_intf_ports M_AXIS_DS1] [get_bd_intf_pins Dfx_Streamer_1/M_AXI]
  connect_bd_intf_net -intf_net S01_AXI_0_1 [get_bd_intf_ports S_AXI_CTRL] [get_bd_intf_pins DFX_Ctrl_0_axi_periph/S01_AXI]
  connect_bd_intf_net -intf_net S_AXIS_DS0_1 [get_bd_intf_ports S_AXIS_DS0] [get_bd_intf_pins dma_hier/S_AXIS_DS0]
  connect_bd_intf_net -intf_net S_AXI_0_1 [get_bd_intf_ports S_AXIS_DS1] [get_bd_intf_pins Dfx_Streamer_1/S_AXI]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_MM2S [get_bd_intf_ports M_AXI_DMA_IN] [get_bd_intf_pins dma_hier/M_AXI_DMA_IN]
  connect_bd_intf_net -intf_net axi_dma_0_M_AXI_S2MM [get_bd_intf_ports M_AXI_DMA_OUT] [get_bd_intf_pins dma_hier/M_AXI_DMA_OUT]
  connect_bd_intf_net -intf_net dfx_decoupler_1_rp_intf_0 [get_bd_intf_ports M_AXIS_DS0] [get_bd_intf_pins dma_hier/M_AXIS_DS0]

  # Create port connections
  connect_bd_net -net DFX_Ctrl_0_slaveMgsLoadInit [get_bd_pins DFX_Ctrl_A/slaveMgsLoadInit] [get_bd_pins Dfx_Streamer_1/loadInit_pool]
  connect_bd_net -net DFX_Ctrl_0_slaveMgsLoadReset [get_bd_pins DFX_Ctrl_A/slaveMgsLoadReset] [get_bd_pins Dfx_Streamer_1/loadReset_pool]
  connect_bd_net -net DFX_Ctrl_0_slaveMgsStoreInit [get_bd_pins DFX_Ctrl_A/slaveMgsStoreInit] [get_bd_pins Dfx_Streamer_1/storeInit_pool]
  connect_bd_net -net DFX_Ctrl_0_slaveMgsStoreReset [get_bd_pins DFX_Ctrl_A/slaveMgsStoreReset] [get_bd_pins Dfx_Streamer_1/storeReset_pool]
  connect_bd_net -net DFX_Ctrl_A_hw_intr [get_bd_pins DFX_Ctrl_A/hw_intr] [get_bd_ports dfx_intr]
  connect_bd_net -net DFX_Ctrl_A_slaveReprog [get_bd_pins DFX_Ctrl_A/slaveReprog] [get_bd_pins DFX_Ctrl_B/vsm_vs4ml_hw_triggers]
  connect_bd_net -net DFX_Ctrl_B_vsm_vs4ml_rm_decouple [get_bd_pins DFX_Ctrl_B/vsm_vs4ml_rm_decouple] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net DFX_Ctrl_B_vsm_vs4ml_rm_reset [get_bd_pins DFX_Ctrl_B/vsm_vs4ml_rm_reset] [get_bd_pins reset_join/Op1]
  connect_bd_net -net Dfx_Streamer_1_dbg_amt_load_bytes [get_bd_pins Dfx_Streamer_1/dbg_amt_load_bytes] [get_bd_ports dbg_amt_load_bytes_0]
  connect_bd_net -net Dfx_Streamer_1_dbg_amt_store_bytes [get_bd_pins Dfx_Streamer_1/dbg_amt_store_bytes] [get_bd_ports dbg_amt_store_bytes_0]
  connect_bd_net -net Dfx_Streamer_1_dbg_state [get_bd_pins Dfx_Streamer_1/dbg_state] [get_bd_ports dbg_state_0]
  connect_bd_net -net Dfx_Streamer_1_finStore [get_bd_pins Dfx_Streamer_1/finStore] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_dfx_decup_gpio_io_o [get_bd_pins axi_dfx_decup/gpio_io_o] [get_bd_pins util_vector_logic_0/Op2]
  connect_bd_net -net axi_dfx_reset_gpio_io_o [get_bd_pins axi_dfx_reset/gpio_io_o] [get_bd_pins reset_join/Op2]
  connect_bd_net -net axi_dma_0_s2mm_introut [get_bd_pins dma_hier/s2mm_introut] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net clk_0_1 [get_bd_ports clk] [get_bd_pins DFX_Ctrl_0_axi_periph/S00_ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/M00_ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/S01_ACLK] [get_bd_pins DFX_Ctrl_B/clk] [get_bd_pins DFX_Ctrl_B/icap_clk] [get_bd_pins axi_dfx_reset/s_axi_aclk] [get_bd_pins axi_dfx_decup/s_axi_aclk] [get_bd_pins DFX_Ctrl_A/clk] [get_bd_pins icapWrap_0/CLK] [get_bd_pins DFX_Ctrl_0_axi_periph/M01_ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/M02_ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/M03_ACLK] [get_bd_pins DFX_Ctrl_0_axi_periph/M04_ACLK] [get_bd_pins dma_hier/clk] [get_bd_pins Dfx_Streamer_1/clk]
  connect_bd_net -net reset_0_1 [get_bd_ports nreset] [get_bd_pins DFX_Ctrl_0_axi_periph/S00_ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/M00_ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/S01_ARESETN] [get_bd_pins DFX_Ctrl_B/reset] [get_bd_pins DFX_Ctrl_B/icap_reset] [get_bd_pins axi_dfx_reset/s_axi_aresetn] [get_bd_pins axi_dfx_decup/s_axi_aresetn] [get_bd_pins DFX_Ctrl_A/reset] [get_bd_pins DFX_Ctrl_0_axi_periph/M01_ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/M02_ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/M03_ARESETN] [get_bd_pins DFX_Ctrl_0_axi_periph/M04_ARESETN] [get_bd_pins dma_hier/nreset] [get_bd_pins Dfx_Streamer_1/reset]
  connect_bd_net -net reset_join_Res [get_bd_pins reset_join/Res] [get_bd_ports pr_reset] [get_bd_pins DFX_Ctrl_A/nslaveReset]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins util_vector_logic_0/Res] [get_bd_pins dma_hier/decouple] [get_bd_pins Dfx_Streamer_1/decup]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins xlconcat_0/dout] [get_bd_pins DFX_Ctrl_A/mgsFinExec]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins xlconstant_0/dout] [get_bd_pins DFX_Ctrl_A/hw_ctrl_start] [get_bd_pins DFX_Ctrl_A/hw_intr_clear]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins xlconstant_1/dout] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins xlconstant_2/dout] [get_bd_pins DFX_Ctrl_B/vsm_vs4ml_rm_shutdown_ack]

  # Create address segments
  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DFX_Ctrl_A/M_AXI] [get_bd_addr_segs DFX_Ctrl_A/S_AXI/reg0] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DFX_Ctrl_A/M_AXI] [get_bd_addr_segs DFX_Ctrl_B/s_axi_reg/Reg] -force
  assign_bd_address -offset 0x00040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DFX_Ctrl_A/M_AXI] [get_bd_addr_segs axi_dfx_decup/S_AXI/Reg] -force
  assign_bd_address -offset 0x00030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DFX_Ctrl_A/M_AXI] [get_bd_addr_segs axi_dfx_reset/S_AXI/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces DFX_Ctrl_A/M_AXI] [get_bd_addr_segs dma_hier/axi_dma_0/S_AXI_LITE/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces DFX_Ctrl_B/Data] [get_bd_addr_segs M_AXI_BS/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces dma_hier/axi_dma_0/Data_MM2S] [get_bd_addr_segs M_AXI_DMA_IN/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x000100000000 -target_address_space [get_bd_addr_spaces dma_hier/axi_dma_0/Data_S2MM] [get_bd_addr_segs M_AXI_DMA_OUT/Reg] -force
  assign_bd_address -offset 0x00000000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs DFX_Ctrl_A/S_AXI/reg0] -force
  assign_bd_address -offset 0x00010000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs DFX_Ctrl_B/s_axi_reg/Reg] -force
  assign_bd_address -offset 0x00040000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs axi_dfx_decup/S_AXI/Reg] -force
  assign_bd_address -offset 0x00030000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs axi_dfx_reset/S_AXI/Reg] -force
  assign_bd_address -offset 0x00020000 -range 0x00010000 -target_address_space [get_bd_addr_spaces S_AXI_CTRL] [get_bd_addr_segs dma_hier/axi_dma_0/S_AXI_LITE/Reg] -force


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################


common::send_gid_msg -ssname BD::TCL -id 2052 -severity "CRITICAL WARNING" "This Tcl script was generated from a block design that is out-of-date/locked. It is possible that design <$design_name> may result in errors during construction."

create_root_design ""


