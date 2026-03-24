# import the library
from pynq import Overlay     # import the overlay
from pynq import allocate    # import for CMA (contingeous memory allocation)
from pynq import DefaultIP   # import the ip connector library for extension
import numpy as np
import os
import subprocess
import re



class DFX_Dma:
    """
    DFX DMA Controller class for managing AXI DMA transfers.

    This class provides an interface to control DMA (Direct Memory Access) operations
    between memory and streaming interfaces. It supports bidirectional transfers:
    - MM2S (Memory-Mapped to Stream): Read from memory and send to stream
    - S2MM (Stream to Memory-Mapped): Read from stream and write to memory
    """

    # MM2S (Memory-Mapped to Stream) Register offsets
    # These registers control reading data from memory and streaming it out
    # MM2S_DMACR (0x00) - MM2S DMA Control Register:
    #   Bit 0: RS (Run/Stop) - 1=run, 0=stop
    #   Bit 1: Reserved
    #   Bit 2: Reset - 1=reset (self-clearing)
    MM2S_DMACR = 0x00  # DMA Control Register - controls MM2S channel operation
    # MM2S_DMASR (0x04) - MM2S DMA Status Register:
    #   Bit 0: Halted - 1=DMA channel halted
    #   Bit 1: Idle - 1=DMA channel idle
    MM2S_DMASR = 0x04  # DMA Status Register - provides MM2S channel status
    MM2S_SA = 0x18  # Source Address (lower 32 bits) - memory address to read from
    MM2S_SA_MSB = 0x1C  # Source Address MSB (upper 32 bits) - for 64-bit addressing
    MM2S_LENGTH = 0x28  # Transfer Length - number of bytes to transfer

    # S2MM (Stream to Memory-Mapped) Register offsets
    # These registers control receiving data from stream and writing to memory
    # S2MM_DMACR (0x30) - S2MM DMA Control Register:
    #   Bit 0: RS (Run/Stop) - 1=run, 0=stop
    #   Bit 1: Reserved
    #   Bit 2: Reset - 1=reset (self-clearing)
    S2MM_DMACR = 0x30  # DMA Control Register - controls S2MM channel operation
    # S2MM_DMASR (0x34) - S2MM DMA Status Register:
    #   Bit 0: Halted - 1=DMA channel halted
    #   Bit 1: Idle - 1=DMA channel idle
    S2MM_DMASR = 0x34  # DMA Status Register - provides S2MM channel status
    S2MM_DA = 0x48  # Destination Address (lower 32 bits) - memory address to write to
    S2MM_DA_MSB = 0x4C  # Destination Address MSB (upper 32 bits) - for 64-bit addressing
    S2MM_LENGTH = 0x58  # Transfer Length - number of bytes to transfer

    def __init__(self, host_ip, offset):
        """
        Initialize the DFX DMA controller.

        Args:
            host_ip: The host IP object that provides read/write access to registers
            offset: Base address offset for this DMA controller in the address space
        """
        # meta data
        self.host_ip = host_ip
        self.offset = offset

    def read(self, addr):
        """
        Read a 32-bit value from a DMA register.

        Args:
            addr: Register offset (relative to DMA base address)

        Returns:
            32-bit register value
        """
        return self.host_ip.read(self.offset + addr)

    def write(self, addr, value):
        """
        Write a 32-bit value to a DMA register.

        Args:
            addr: Register offset (relative to DMA base address)
            value: 32-bit value to write
        """
        self.host_ip.write(self.offset + addr, value)

    def reset(self):
        """
        Reset both MM2S and S2MM DMA channels.

        Sets the reset bit (bit 2) in both control registers and waits for
        the reset to complete. The DMA controller clears the reset bit when done.
        """
        print("[DMA] Resetting DMA channels...")
        # Reset MM2S
        self.write(self.MM2S_DMACR, 0x4)
        # Reset S2MM
        self.write(self.S2MM_DMACR, 0x4)

        # Wait for reset to complete
        while self.read(self.MM2S_DMACR) & 0x4:
            pass
        while self.read(self.S2MM_DMACR) & 0x4:
            pass
        print("[DMA] Reset completed successfully")

    def init(self):
        """
        Initialize and start both DMA channels.

        Sets the run bit (bit 0) in both MM2S and S2MM control registers,
        enabling the DMA channels to accept transfer requests.
        """
        print("[DMA] Initializing DMA channels...")
        # Start MM2S and S2MM
        self.write(self.MM2S_DMACR, 0x1)
        self.write(self.S2MM_DMACR, 0x1)
        print("[DMA] Initialization completed successfully")

    def send(self, addr, length):
        """
        Initiate a MM2S transfer (memory to stream).

        Configures the source address and length, then starts the transfer.
        The transfer reads data from memory and sends it to the stream interface.

        Args:
            addr: 64-bit source memory address
            length: Number of bytes to transfer
        """
        print(f"[DMA] Starting MM2S transfer (addr: 0x{addr:X}, length: {length} bytes)...")
        # MM2S transfer
        self.write(self.MM2S_SA, addr & 0xFFFFFFFF)
        self.write(self.MM2S_SA_MSB, (addr >> 32) & 0xFFFFFFFF)
        self.write(self.MM2S_LENGTH, length)

    def recv(self, addr, length):
        """
        Initiate a S2MM transfer (stream to memory).

        Configures the destination address and length, then starts the transfer.
        The transfer receives data from the stream interface and writes it to memory.

        Args:
            addr: 64-bit destination memory address
            length: Number of bytes to transfer
        """
        print(f"[DMA] Starting S2MM transfer (addr: 0x{addr:X}, length: {length} bytes)...")
        # S2MM transfer
        self.write(self.S2MM_DA, addr & 0xFFFFFFFF)
        self.write(self.S2MM_DA_MSB, (addr >> 32) & 0xFFFFFFFF)
        self.write(self.S2MM_LENGTH, length)

    def get_mm2s_source_addr(self):
        """
        Read the current MM2S source address.

        Returns:
            int: 64-bit source memory address configured for MM2S transfers
        """
        lower = self.read(self.MM2S_SA)
        upper = self.read(self.MM2S_SA_MSB)
        return (upper << 32) | lower

    def get_s2mm_dest_addr(self):
        """
        Read the current S2MM destination address.

        Returns:
            int: 64-bit destination memory address configured for S2MM transfers
        """
        lower = self.read(self.S2MM_DA)
        upper = self.read(self.S2MM_DA_MSB)
        return (upper << 32) | lower

    def check_mm2s_status(self):
        """
        Check the MM2S DMA channel status.

        Returns:
            dict: Dictionary containing status flags:
                - 'halted': True if DMA channel is halted
                - 'idle': True if DMA channel is idle
                - 'raw_status': Raw status register value
        """
        status = self.read(self.MM2S_DMASR)
        return {
            'halted': bool(status & 0x1),
            'idle': bool(status & 0x2),
            'raw_status': status
        }

    def wait_send(self):
        """
        Wait for the MM2S transfer to complete.

        Polls the MM2S status register until the idle bit (bit 1) is set,
        indicating the transfer has finished.
        """
        # Wait for MM2S to be idle (bit 1 of DMASR)
        while not (self.read(self.MM2S_DMASR) & 0x2):
            pass
        print("[DMA] MM2S transfer completed successfully")

    def check_s2mm_status(self):
        """
        Check the S2MM DMA channel status.

        Returns:
            dict: Dictionary containing status flags:
                - 'halted': True if DMA channel is halted
                - 'idle': True if DMA channel is idle
                - 'raw_status': Raw status register value
        """
        status = self.read(self.S2MM_DMASR)
        return {
            'halted': bool(status & 0x1),
            'idle': bool(status & 0x2),
            'raw_status': status
        }

    def wait_recv(self):
        """
        Wait for the S2MM transfer to complete.

        Polls the S2MM status register until the idle bit (bit 1) is set,
        indicating the transfer has finished.
        """
        # Wait for S2MM to be idle (bit 1 of DMASR)
        while not (self.read(self.S2MM_DMASR) & 0x2):
            pass
        print("[DMA] S2MM transfer completed successfully")


