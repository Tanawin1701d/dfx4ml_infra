# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
import subprocess          # import the subprocess library for running shell commands
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np

def sub_process_print(prefix, sub_process_res):
    
    print(f"{prefix} STDOUT:", sub_process_res.stdout)
    print(f"{prefix} ERROR :", sub_process_res.stderr)
    print("--------------------------------")
    

def change_mem_commit_mode(allow_over_commit, is_root): ### mode should be "pcap", "icap"
    
    if allow_over_commit:
        indicator = "1"
    else:
        indicator = "0"
    
    
    trigger_cmd_input_val = indicator
    config_file = "/proc/sys/vm/overcommit_memory"
    password = "xilinx"  # default sudo password for PYNQ-ZU

    # Compose the command string
    cmd_trigger = f"sudo -S tee {config_file}"
    cmd_read    = f"cat {config_file}"
    
    password_cmd = (password + '\n') if not is_root else ""

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


def alloc_data_uint(alloc_shape = (16, ), alloc_type = np.float32, input_x = None):
    buf0 = allocate(shape=alloc_shape, dtype=alloc_type)
    #### copy the data
    if input_x is not None:
        print("start copy from input to allocate buffer")
        if (alloc_shape != input_x.shape) or (alloc_type != input_x.dtype):
            raise Exception("the specified shape and input_x shape is mismatch")
        np.copyto(buf0, input_x)
        print("copy finish")

    return buf0, buf0.physical_address, buf0.nbytes