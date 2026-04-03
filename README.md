# DFX4ML-INFRA Project ( TENTATIVE )

This project provides a hardware and software build helper for DFX (Dynamic Function eXchange) on FPGA, specifically targeting the KV260 board.

## Project Structure

- `hw/`: Hardware source files and build scripts.
- `sw/`: Software driver and test files.
- `lib/`: Python library modules for building hardware (`hw_build.py`) and software (`sw_build.py`).
- `export/`: Directory where build artifacts are exported.
  - `hw/`: Contains generated bitstreams and hardware handoff files (`system.hwh`, `system.bin`, `rm_*.bin`).
  - `driver/`: Contains Python drivers for interacting with the hardware.
  - `test.ipynb`: A Jupyter notebook for testing the exported system.

## Quick Start

You can use the `quick_start.ipynb` notebook to run the build process.

1.  **Configure Parameters**: Update the `HwBuildHelper` and `SwBuildHelper` parameters in the notebook (e.g., `vivado_path`, `board`, etc.).
2.  **Run Hardware Build**: Execute `hw_builder.run_build()` to invoke Vivado and generate the bitstreams.
3.  **Package Export Files**:
    - Run `hw_builder.package_export_files()` to copy hardware artifacts to the `export/hw` directory.
    - Run `sw_builder.package_export_file()` to copy drivers and the test notebook to the `export` directory.

## Requirements

- Xilinx Vivado (tested with 2023.2).
- Python 3 with `subprocess`, `os`, `shutil`, and `re` modules.
- KV260 Starter Kit (for deployment).
