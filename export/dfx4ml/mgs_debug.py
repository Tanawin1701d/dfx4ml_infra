"""
PYNQ Driver for fourSp Hardware Module with DMA and GPIO Control

Hardware Module Description:
The fourSp module detects rising edges on 4 input control signals and generates
corresponding output pulses for load_reset, store_reset, load_init, and store_init.
"""

from pynq import Overlay, allocate
from pynq.lib import DMA
import numpy as np
import time


class FourSpDriver:
    """
    Driver class to interface with the fourSp hardware IP via DMA and GPIO.

    The fourSp module generates single-cycle pulses on rising edges of input signals:
    - in[0] -> load_reset
    - in[1] -> store_reset
    - in[2] -> load_init
    - in[3] -> store_init
    """

    def __init__(self, overlay_path, dma_name='axi_dma_0', gpio_name='axi_gpio_0',  gpio_read_name='axi_gpio_1'):
        """
        Initialize the FourSp driver with overlay, DMA, and GPIO.

        Args:
            overlay_path: Path to the .bit or .hwh overlay file
            dma_name: Name of the DMA IP in the overlay
            gpio_name: Name of the GPIO IP in the overlay
        """
        self.overlay = Overlay(overlay_path)
        self.dma = getattr(self.overlay, dma_name)
        self.gpio = getattr(self.overlay, gpio_name)
        self.gpio_read = getattr(self.overlay, gpio_read_name)
        self.gpio_value = 0x0
        self.reset_gpio()

    def send_data(self, data):
        """
        Send data to the hardware IP via DMA.

        Args:
            data: numpy array or list of data to send

        Returns:
            None
        """
        if not isinstance(data, np.ndarray):
            data = np.array(data, dtype=np.int32)

        input_buffer = allocate(shape=(len(data),), dtype=np.int32)
        input_buffer[:] = data

        self.dma.sendchannel.transfer(input_buffer)
        self.dma.sendchannel.wait()

        input_buffer.close()

    def receive_data(self, length):
        """
        Receive data from the hardware IP via DMA.

        Args:
            length: Number of elements to receive

        Returns:
            numpy array containing received data
        """
        output_buffer = allocate(shape=(length,), dtype=np.int32)

        self.dma.recvchannel.transfer(output_buffer)
        self.dma.recvchannel.wait()

        result = np.copy(output_buffer)
        output_buffer.close()

        return result

    def write_command(self, load_reset=False, store_reset=False,
                      load_init=False, store_init=False):
        """
        Write command to GPIO to trigger control signals via rising edge detection.

        The fourSp module detects rising edges, so this method:
        1. Sets the requested bits high
        2. Waits briefly
        3. Clears the bits to allow future triggers

        Args:
            load_reset: Trigger load_reset signal (bit 0)
            store_reset: Trigger store_reset signal (bit 1)
            load_init: Trigger load_init signal (bit 2)
            store_init: Trigger store_init signal (bit 3)
        """
        # Build command value
        command = 0x0
        if load_reset:
            command |= 0x1
        if store_reset:
            command |= 0x2
        if load_init:
            command |= 0x4
        if store_init:
            command |= 0x8

        # Write high to trigger rising edge
        self.gpio.write(0, command)
        time.sleep(0.001)  # Brief delay to ensure signal is registered

        # Write low to prepare for next trigger
        self.gpio.write(0x0, 0x0)
        time.sleep(0.001)

    def reset_gpio(self):
        """
        Reset all GPIO control signals to 0.
        """
        self.gpio.write(0x0, 0x0)
        self.gpio_value = 0x0

    def read_mgs_meta(self):
        raw_data = self.gpio_read.read(0)

        pattern_11bit_1 = (raw_data      ) & 0x7FF
        pattern_11bit_2 = (raw_data >> 11) & 0x7FF
        pattern_4bit    = (raw_data >> 22)  & 0xF

        # State mapping from hardware
        state_map = {
            0x0: "STATUS_IDLE",
            0x1: "STATUS_STORE",
            0x2: "STATUS_LOAD"
        }

        print(f"load amount : {pattern_11bit_1}")
        print(f"store amount : {pattern_11bit_2}")
        state_str = state_map.get(pattern_4bit, f"UNKNOWN (0x{pattern_4bit:X})")
        print(f"state : {state_str} (0x{pattern_4bit:X})")

# Example usage
# if __name__ == "__main__":
#     import os
#     PRJ_DIR = os.getcwd()
#     PRJ_HW_DIR = os.path.join(PRJ_DIR, 'hw')
#     FULL_BS_NAME = 'system.bin'
#     overlay_path = os.path.join(PRJ_HW_DIR, FULL_BS_NAME)
#
#     if not os.path.exists(overlay_path):
#         print(f"Overlay not found at {overlay_path}")
#     else:
#         # Initialize driver
#         driver = FourSpDriver(overlay_path=overlay_path, dma_name='axi_dma_0', gpio_name='axi_gpio_0')
#
#         # Send data via DMA
#         input_data = np.arange(0, 100, dtype=np.int32)
#         print("Sending data...")
#         driver.send_data(input_data)
#
#         # Trigger load_reset command
#         driver.write_command(load_reset=True)
#         print("Triggered load_reset")
#
#         # Trigger load_init command
#         driver.write_command(load_init=True)
#         print("Triggered load_init")
#
#         # Receive processed data via DMA
#         print("Receiving data...")
#         output_data = driver.receive_data(length=100)
#         print("Received data:", output_data)
#
#         # Trigger store operations
#         driver.write_command(store_reset=True, store_init=True)
#         print("Triggered store_reset and store_init")
