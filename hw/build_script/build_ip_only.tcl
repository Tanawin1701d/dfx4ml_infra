
proc build_ip_only { build_tcl_path dfx4ml_root } {
    source [file join $dfx4ml_root hw ip_src compose_ip.tcl]
    compose_all_ips $build_tcl_path $dfx4ml_root
    puts "\033\[32mIP composition complete!\033\[0m"
    exit
}
