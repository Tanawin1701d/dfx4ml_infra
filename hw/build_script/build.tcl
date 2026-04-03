proc import_dep { build_tcl_path dfx4ml_root req_gen_ip test_mode user_repo_path} {

    # Add IP repository
    source [file join $dfx4ml_root hw ip_src compose_ip.tcl]

    if {$req_gen_ip == 1} {
        compose_all_ips $build_tcl_path $dfx4ml_root
    }

    set repo_paths [list [file join $build_tcl_path ip_repo]]
    if {$test_mode != 1} {
        lappend repo_paths $user_repo_path
    }
    set_property  ip_repo_paths  $repo_paths [current_project]

    update_ip_catalog

    # Source the design script
    source [file join $dfx4ml_root hw bd_src dfx_region dfx_region.tcl]
    source [file join $dfx4ml_root hw bd_src dfx_unified dfx_unified.tcl]
    source [file join $dfx4ml_root hw bd_src dfx4ml dfx4ml.tcl]
}

proc prepare_model4syn { num_core num_actual_rm xdc_path } {

    # generate dfx4ml block design
    puts "generate block design"
    set bd_file [get_files -quiet dfx4ml.bd]
    if {[llength $bd_file] == 0} {
        error "Block design not found!"
    }
    # Generate BD targets
    generate_target all $bd_file
    # Export IP files
    export_ip_user_files -of_objects $bd_file \
        -no_script -sync -force -quiet
    # Create IP runs
    create_ip_run [get_files -of_objects [get_fileset sources_1] $bd_file]
    # Get synthesis runs
    set synth_runs [get_runs -filter {IS_SYNTHESIS && NAME =~ "*_synth_1"}]
    if {[llength $synth_runs] == 0} {
        error "No synthesis runs found!"
    }
    # Launch + wait
    launch_runs {*}$synth_runs -jobs $num_core
    wait_on_run {*}$synth_runs

    puts "IP generation complete!"

    # generate HDL wrapper
    puts "make dfx4ml wrapper"
    set wrapper_path [make_wrapper -files $bd_file -top]
    puts "Wrapper generated at: $wrapper_path"
    add_files -norecurse $wrapper_path
    update_compile_order -fileset sources_1

    # config for dfx
    for {set i 0} {$i < $num_actual_rm} {incr i} {
        puts "Creating PR configuration step #$i ..."
        create_pr_configuration -name config_$i -partitions [list dfx4ml_i/dfx_pr_0_0:dfx_pr_${i}_inst_0 ]
    }

    for {set i 0} {$i < $num_actual_rm} {incr i} {
        puts "Creating run step #$i ..."
        if {$i == 0} {
            create_run impl_dfx -parent_run synth_1 -flow {Vivado Implementation 2023} -pr_config config_$i -dfx_mode STANDARD
            set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_dfx]
        } else {
            create_run child_${i}_impl_dfx -parent_run impl_dfx -flow {Vivado Implementation 2023} -pr_config config_$i
            set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs child_${i}_impl_dfx]
        }
    }
    current_run [get_runs impl_dfx]

    puts "get xdc file ..."
    # set xdc file
    add_files -fileset constrs_1 $xdc_path
    set_property target_constrs_file $xdc_path [current_fileset -constrset]


}



proc syn_and_impl { num_core num_actual_rm } {

    launch_runs synth_1 -jobs $num_core
    
    set run_list [list impl_dfx]
    for {set i 1} {$i < $num_actual_rm} {incr i} {
        lappend run_list child_${i}_impl_dfx
    }
    launch_runs {*}$run_list -to_step write_bitstream -jobs $num_core
    wait_on_run {*}$run_list

}



proc build {build_tcl_path \
            dfx4ml_root \
            board \
            user_repo_path \
            req_gen_ip \
            num_core \
            clk_frq \
            rm_index_width \
            num_dfx_streamer \
            interface_widths \
            applied_interface_widths \
            storage_index_widths \
            num_actual_rm \
            input_map_list \
            output_map_list \
            ip_map_list \
            test_mode \
            } {

    set parentCell ""

    if {$board == "kv260"} {
        puts "prepare model for kv260 generation"
        source [file join $dfx4ml_root hw build_script kv260 board_build.tcl]
        set constraint_path [file join $dfx4ml_root hw build_script kv260 constraint.xdc]
        puts "kv260 xdc file is at $constraint_path"
        build_kv260_prj $build_tcl_path
        import_dep $build_tcl_path $dfx4ml_root $req_gen_ip $test_mode $user_repo_path
        create_kv260_dfx4ml_design $parentCell $clk_frq $rm_index_width \
                                  $num_dfx_streamer $interface_widths $applied_interface_widths \
                                  $storage_index_widths $num_actual_rm $input_map_list \
                                  $output_map_list $ip_map_list $test_mode
    } else {
        error "Unsupported board: $board. Only 'kv260' is supported."
    }


    puts "prepare configuration"
    prepare_model4syn $num_core $num_actual_rm $constraint_path

    puts "synthesis and implementation"
    syn_and_impl $num_core $num_actual_rm

    exit

}