import os
import subprocess
import re

def sub_process_print(prefix, sub_process_res):
    
    print(f"{prefix} STDOUT:", sub_process_res.stdout)
    print(f"{prefix} ERROR :", sub_process_res.stderr)
    print("--------------------------------")
    

def change_pl_config_mode(mode, is_root, password): ### mode should be "pcap", "icap"
    indicator = "1"
    if mode == "icap":
        indicator = "0"
    elif mode == "pcap":
        pass
    else:
        raise Exception("change PL config Mode has mode error")
    
    
    change_cmd_input_val = f"0xFFCA3008 0xFFFFFFFF 0x{indicator}"
    trigger_cmd_input_val = "0xFFCA3008"
    config_file = "/sys/firmware/zynqmp/config_reg"
    #password = "4205634425444869"  # default sudo password for PYNQ-ZU

    # Compose the command string
    cmd_change = f"sudo -S tee {config_file}"
    cmd_trigger = f"sudo -S tee {config_file}"
    cmd_read    = f"cat {config_file}"
    
    password_cmd = (password + '\n') if not is_root else ""

    # Run the change command
    result = subprocess.run(
        cmd_change,
        input=password_cmd + change_cmd_input_val + '\n',
        shell=True,
        capture_output=True,
        text=True
    )
    sub_process_print("CHANGE CMD", result)

    # Run the trigger command
    result = subprocess.run(
        cmd_trigger,
        input=password_cmd + trigger_cmd_input_val + '\n',
        shell=True,
        capture_output=True,
        text=True
    )

    sub_process_print("TRIGGER CMD", result)

    
    result = subprocess.run(
        cmd_read,
        shell=True,
        capture_output=True,
        text=True
    )

    sub_process_print("READ CMD", result)