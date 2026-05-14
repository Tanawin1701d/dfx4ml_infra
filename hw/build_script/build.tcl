proc import_dep { build_tcl_path dfx4ml_root req_gen_ip test_mode user_repo_path user_rm_build_tcl_path} {

    # Add IP repository
    source [file join $dfx4ml_root hw ip_src compose_ip.tcl]

    if {$req_gen_ip == 1} {
        compose_all_ips $build_tcl_path $dfx4ml_root
    }

    set repo_paths [list [file join $build_tcl_path ip_repo]]
    if {$test_mode != 1} {
        source $user_rm_build_tcl_path
        lappend repo_paths $user_repo_path
    }
    set_property  ip_repo_paths  $repo_paths [current_project]

    update_ip_catalog

    # Source the design script
    source [file join $dfx4ml_root hw bd_src dfx_region dfx_region.tcl]
    source [file join $dfx4ml_root hw bd_src dfx_unified dfx_unified.tcl]
    source [file join $dfx4ml_root hw bd_src dfx4ml dfx4ml.tcl]
}

proc prepare_model4syn { num_core dfx_regions_list rm_schemetics_list xdc_path } {

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

    set num_dfx_region [llength $dfx_regions_list]

    # Parent PR configuration: all regions use rm_0
    set parent_partitions [list]
    for {set r 0} {$r < $num_dfx_region} {incr r} {
        lappend parent_partitions \
            "dfx4ml_i/dfx_pr_region_${r}_0:dfx_pr_region_${r}_rm_0_inst_0"
    }
    puts "DEBUG: create_pr_configuration -name config_parent -partitions $parent_partitions"
    create_pr_configuration -name config_parent -partitions $parent_partitions

    puts "DEBUG: create_run impl_dfx -parent_run synth_1 -flow {Vivado Implementation 2023} -pr_config config_parent -dfx_mode STANDARD"
    create_run impl_dfx -parent_run synth_1 \
        -flow {Vivado Implementation 2023} -pr_config config_parent -dfx_mode STANDARD
    set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true [get_runs impl_dfx]

    # Child runs: one per (region r, rm m) for m > 0.
    # Non-target regions are declared as greybox — Vivado treats them as empty
    # placeholders and does not re-implement them.  The resulting partial
    # bitstream only writes frames belonging to region r, so it is composable
    # with any other region's partial at runtime (same static DCP base).

    set child_idx 0
    for {set r 0} {$r < $num_dfx_region} {incr r} {
        set region_rms [lindex $rm_schemetics_list $r]
        set num_rms    [llength $region_rms]

        # create config for each rm
        for {set rm 0} {$rm < $num_rms} {incr rm} {
            set greybox_list [list]
            for {set grey_rg_id 0} {$grey_rg_id < $num_dfx_region} {incr grey_rg_id} {
                if {$grey_rg_id != $r} {
                    lappend greybox_list "dfx4ml_i/dfx_pr_region_${grey_rg_id}_0"
                }
            }
            set partitions_list [list "dfx4ml_i/dfx_pr_region_${r}_0:dfx_pr_region_${r}_rm_${rm}_inst_0"]
            puts "DEBUG: create_pr_configuration -name config_child_${r}_${rm} -partitions $partitions_list -greyboxes $greybox_list"
            create_pr_configuration -name config_child_${r}_${rm} \
                -partitions $partitions_list \
                -greyboxes $greybox_list

            # Child run inherits static routing from impl_dfx and re-implements only region r
            puts "DEBUG: create_run child_${child_idx}_impl_dfx -parent_run impl_dfx -flow {Vivado Implementation 2023} -pr_config config_child_${r}_${rm}"
            create_run child_${child_idx}_impl_dfx -parent_run impl_dfx \
                -flow {Vivado Implementation 2023} -pr_config config_child_${r}_${rm}

            # Enable .bin output for ICAP loading at runtime
            set_property STEPS.WRITE_BITSTREAM.ARGS.BIN_FILE true \
                [get_runs child_${child_idx}_impl_dfx]
            incr child_idx
        }

    }

    current_run [get_runs impl_dfx]

    puts "get xdc file ..."
    add_files -fileset constrs_1 $xdc_path
    set_property target_constrs_file $xdc_path [current_fileset -constrset]
    # Pblock add_cells_to_pblock requires the design to be linked first.
    # PROCESSING_ORDER LATE causes Vivado to defer read_xdc to the
    # opt_design phase (after link_design), where PR cells are visible.
    #set_property PROCESSING_ORDER LATE [get_files $xdc_path]
}



proc syn_and_impl { num_core dfx_regions_list rm_schemetics_list } {

    launch_runs synth_1 -jobs $num_core

    set run_list [list impl_dfx]
    set num_dfx_region [llength $dfx_regions_list]
    set child_idx 0
    for {set r 0} {$r < $num_dfx_region} {incr r} {
        set region_rms     [lindex $rm_schemetics_list $r]
        set num_region_rms [llength $region_rms]
        for {set rm 0} {$rm < $num_region_rms} {incr rm} {
            puts "DEBUG: Adding child run to list: child_${child_idx}_impl_dfx (region $r, RM $rm)"
            lappend run_list child_${child_idx}_impl_dfx
            incr child_idx
        }
    }
    launch_runs {*}$run_list -to_step write_bitstream -jobs $num_core
    wait_on_run {*}$run_list
}



proc build {build_tcl_path \
            dfx4ml_root \
            board \
            user_repo_path \
            user_rm_build_tcl_path \
            req_gen_ip \
            num_core \
            clk_frq \
            rm_index_width \
            num_dfx_streamer \
            num_dfx_region \
            dfx_streamers_list \
            dfx_regions_list \
            rm_schemetics_list \
            test_mode \
            board_build_tcl_path \
            constraint_xdc_path \
            } {

    set parentCell ""
    set run_syn 1

    if {$board == "kv260"} {
        puts "prepare model for kv260 generation"
        source [file join $dfx4ml_root hw build_script kv260 board_build.tcl]
        set constraint_path [file join $dfx4ml_root hw build_script kv260 constraint.xdc]
        puts "kv260 xdc file is at $constraint_path"
        build_kv260_prj $build_tcl_path
        import_dep $build_tcl_path $dfx4ml_root $req_gen_ip $test_mode \
            $user_repo_path $user_rm_build_tcl_path
        create_kv260_dfx4ml_design $parentCell $clk_frq $rm_index_width \
            $num_dfx_streamer $num_dfx_region \
            $dfx_streamers_list $dfx_regions_list $rm_schemetics_list $test_mode
    } elseif {$board == "no_syn"} {
        puts "prepare model for custom board (no synthesis) generation"
        source [file join $dfx4ml_root hw build_script custom board_build.tcl]
        build_no_syn_prj $build_tcl_path
        import_dep $build_tcl_path $dfx4ml_root $req_gen_ip $test_mode \
            $user_repo_path $user_rm_build_tcl_path
        create_no_syn_dfx4ml_design $parentCell $clk_frq $rm_index_width \
            $num_dfx_streamer $num_dfx_region \
            $dfx_streamers_list $dfx_regions_list $rm_schemetics_list $test_mode
        set run_syn 0
    } elseif {$board == "custom"} {
        puts "prepare model for custom board generation"
        if {$board_build_tcl_path == "" || $constraint_xdc_path == ""} {
            error "board=custom requires board_build_tcl_path and constraint_xdc_path to be specified."
        }
        source $board_build_tcl_path
        set constraint_path $constraint_xdc_path
        puts "custom board_build_tcl: $board_build_tcl_path"
        puts "custom constraint xdc: $constraint_path"
        build_custom_prj $build_tcl_path
        import_dep $build_tcl_path $dfx4ml_root $req_gen_ip $test_mode \
            $user_repo_path $user_rm_build_tcl_path
        create_custom_dfx4ml_design $parentCell $clk_frq $rm_index_width \
            $num_dfx_streamer $num_dfx_region \
            $dfx_streamers_list $dfx_regions_list $rm_schemetics_list $test_mode
    } else {
        error "Unsupported board: $board. Supported values: kv260, no_syn, custom."
    }

    if {$run_syn == 1} {
        puts "prepare configuration"
        prepare_model4syn $num_core $dfx_regions_list $rm_schemetics_list $constraint_path

        puts "synthesis and implementation"
        syn_and_impl $num_core $dfx_regions_list $rm_schemetics_list
    }

    exit

}
