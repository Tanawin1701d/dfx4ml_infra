##################################################################
# DESIGN PROCs
##################################################################

proc create_dfx_region_bd { \
    parentCell \
    block_name \
    clk_frq \
    num_dfx_streamer \
    interface_widths \
    input_maps \
    output_maps \
    ip_name \
} {

#  variable script_folder
#  variable design_name

#  if { $parentCell eq "" } {
#     set parentCell [get_bd_cells /]
#  }
#
#  # Get object for parentCell
#  set parentObj [get_bd_cells $parentCell]
#  if { $parentObj == "" } {
#     catch {common::send_gid_msg -ssname BD::TCL -id 2090 -severity "ERROR" "Unable to find parent cell <$parentCell>!"}
#     return
#  }
#
#  # Make sure parentObj is hier blk
#  set parentType [get_property TYPE $parentObj]
#  if { $parentType ne "hier" } {
#     catch {common::send_gid_msg -ssname BD::TCL -id 2091 -severity "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
#     return
#  }
#
#  # Save current instance; Restore later

#
#  # Set parent object as current
#  current_bd_instance $parentObj

  create_bd_design $block_name

  set oldCurInst [current_bd_instance .]

# integrity check
  if { $num_dfx_streamer == 0 } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "num_dfx_streamer <num_dfx_streamer> is zero"}
     return
  }
  # Check num_dfx_streamer matches array lengths
  if { $num_dfx_streamer != [llength $interface_widths] } {
     catch {common::send_gid_msg -ssname BD::TCL -id 2092 -severity "ERROR" "num_dfx_streamer <$num_dfx_streamer> must equal length of interface_widths <[llength $interface_widths]>!"}
     return
  }

  for {set i 0} {$i < $num_dfx_streamer} {incr i} {
     set iw  [lindex $interface_widths $i]         ;# iw      interface width
     if { !($iw != 0 && ($iw & ($iw - 1)) == 0) } {
        catch {common::send_gid_msg -ssname BD::TCL -id 2094 -severity "ERROR" "interface_widths\[$i\] = <$iw> is not a power of two!"}
        return
     }
   }



  # Create interface ports
  for {set i 0} {$i < $num_dfx_streamer} {incr i} {
    set M_DS_$i [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:axis_rtl:1.0 M_DS_$i ]

    set S_DS_$i [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 S_DS_$i ]
    set_property -dict [ list \
     CONFIG.FREQ_HZ "$clk_frq" \
     CONFIG.HAS_TKEEP {1} \
     CONFIG.HAS_TLAST {1} \
     CONFIG.HAS_TREADY {1} \
     CONFIG.HAS_TSTRB {0} \
     CONFIG.LAYERED_METADATA {undef} \
     CONFIG.TDATA_NUM_BYTES [expr [lindex $interface_widths $i] / 8] \
     CONFIG.TDEST_WIDTH {0} \
     CONFIG.TID_WIDTH {0} \
     CONFIG.TUSER_WIDTH {0} \
     ] [set S_DS_$i]
  }


  # Create ports
  set clk [ create_bd_port -dir I -type clk -freq_hz $clk_frq clk ]
  set_property -dict [ list \
   CONFIG.ASSOCIATED_BUSIF {M_DS_0:S_M_DS_0:S_DS_0} \
 ] $clk
  set nreset [ create_bd_port -dir I nreset ]

  # Create instance: Stream_Single_S2M_0, and set properties
  set Stream_Single_S2M_0 [ create_bd_cell -type ip -vlnv user.org:user:Stream_Single_S2M:1.0 Stream_Single_S2M_0 ]

  # Create interface connections

  for {set i 0} {$i < [llength $input_maps]} {incr i} {
    set target_port [lindex $input_maps $i]
    if { $target_port == -1 } {
        set Stream_Slave_Dummy_${i} [ create_bd_cell -type ip -vlnv user.org:user:Stream_Slave_Dummy:1.0 Stream_Slave_Dummy_${i} ]
        connect_bd_intf_net -intf_net S_DS_${i}_1 [get_bd_intf_ports S_DS_${i}] [get_bd_intf_pins Stream_Slave_Dummy_${i}/S_AXI]
        connect_bd_net -net clk_0_1 [get_bd_ports clk] [get_bd_pins Stream_Slave_Dummy_${i}/clk]
        connect_bd_net -net nreset_0_1 [get_bd_ports nreset] [get_bd_pins Stream_Slave_Dummy_${i}/nreset]

    } else {
        connect_bd_intf_net -intf_net S_DS_${i}_1 [get_bd_intf_ports S_DS_${i}] [get_bd_intf_pins Stream_Single_S2M_0/S_AXI]
    }
  }

  for {set i 0} {$i < [llength $output_maps]} {incr i} {
    set target_port [lindex $output_maps $i]
    if { $target_port == -1 } {
        set Stream_Master_Dummy_$i [ create_bd_cell -type ip -vlnv user.org:user:Stream_Master_Dummy:1.0 Stream_Master_Dummy_$i ]
        connect_bd_intf_net -intf_net M_DS_${i}_1 [get_bd_intf_pins Stream_Master_Dummy_${i}/M_AXI] [get_bd_intf_ports M_DS_${i}]
        connect_bd_net -net clk_0_1 [get_bd_ports clk] [get_bd_pins Stream_Master_Dummy_${i}/clk]
        connect_bd_net -net nreset_0_1 [get_bd_ports nreset] [get_bd_pins Stream_Master_Dummy_${i}/nreset]

    } else {
        connect_bd_intf_net -intf_net M_DS_${i}_1 [get_bd_intf_pins Stream_Single_S2M_0/M_AXI] [get_bd_intf_ports M_DS_${i}]
    }
  }



  # Create port connections
  connect_bd_net -net clk_0_1 [get_bd_ports clk] [get_bd_pins Stream_Single_S2M_0/clk]
  connect_bd_net -net nreset_0_1 [get_bd_ports nreset] [get_bd_pins Stream_Single_S2M_0/nreset]

  # Create address segments


  # Restore current instance
  current_bd_instance $oldCurInst

  validate_bd_design
  save_bd_design

  close_bd_design $block_name
}