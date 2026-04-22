proc build_no_syn_prj {{build_dir "build"}} {
    # Create build directory if it doesn't exist
    file mkdir $build_dir

    # Set the board part for KV260
    set board_part "xilinx.com:kv260_som:part0:1.4"

    set project_path [file join $build_dir link_prj]

    # Create and build the Vivado project
    create_project -force link_prj $project_path -part xck26-sfvc784-2LV-c
    set_property board_part $board_part [current_project]

    puts "Building Vivado project for KV260 in directory: $build_dir"
}



proc create_no_syn_dfx4ml_design { parentCell \
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

    set create_new_block 1
    create_dfx4ml_design $parentCell  \
                         $clk_frq  \
                         $rm_index_width  \
                         $num_dfx_streamer  \
                         $interface_widths  \
                         $applied_interface_widths  \
                         $amt_rows  \
                         $num_actual_rm  \
                         $input_map_list  \
                         $output_map_list  \
                         $ip_map_list  \
                         $test_mode  \
                         $create_new_block


}