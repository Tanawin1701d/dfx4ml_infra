


proc find_v_files {dir} {
    set v_files {}
    foreach item [glob -nocomplain -directory $dir *] {
        if {[file isdirectory $item]} {
            set v_files [concat $v_files [find_v_files $item]]
        } elseif {[string match "*.v" $item]} {
            lappend v_files $item
        }
    }
    return $v_files
}



proc compose_ip { viva_prj_exec_path src_ip_folder_path des_ip_folder_path } {
    # 1. create the folder if it is not exist
    if {![file exists $viva_prj_exec_path]} {
        file mkdir $viva_prj_exec_path
    }

    set project_name [file tail $src_ip_folder_path]

    puts "Composing IP Name: ${project_name}"

    set part "xck26-sfvc784-2LV-c"

    create_project $project_name $viva_prj_exec_path/$project_name -part $part -force
    # 3. import all .v file recursively from src_ip_folder_path
    set v_files [find_v_files $src_ip_folder_path]
    if {[llength $v_files] > 0} {
        add_files -norecurse $v_files
        update_compile_order -fileset sources_1
        set top_module [get_property top [current_fileset]]
        puts "Top module detected: $top_module"
        synth_design -top ${top_module} -part ${part} -lint
        
        
    } else {
        puts "Warning: No .v files found in $src_ip_folder_path"
    }

    # 4. compose the ip in ip_repo/ip_folder (using des_ip_folder_path)
    if {![file exists $des_ip_folder_path]} {
        file mkdir $des_ip_folder_path
    }

    ipx::package_project -root_dir $des_ip_folder_path -vendor user.org -library user -taxonomy /UserIP -import_files -set_current false -force
    puts "\033\[32mSuccess: IP packaged successfully at $des_ip_folder_path\033\[0m"
    
    close_project
    
    
}


proc compose_all_ips {build_tcl_path dfx4ml_root } {

    set viva_exec "${dfx4ml_root}/build_hw/ip_src/viva_ip_exec"

    set ip_modules {
        dfx_icap
        dfx_mng
        dfx_streamer
        dfx_streamer_mreset
        dfx_streamer_mshut
        dfx_streamer_s2m
        dfx_streamer_s2m_free
        dfx_streamer_sreset
        dfx_streamer_sshut
    }

    foreach module $ip_modules {
        set src_path "${dfx4ml_root}/hw/ip_src/${module}"
        set des_path "${build_tcl_path}/ip_repo/${module}"
        puts "Composing IP: $module"
        compose_ip $viva_exec $src_path $des_path
    }
}
