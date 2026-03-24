#!/bin/bash

BASE_PATH="/media/tanawin/tanawin1701e/project8/dfx4ml/dfx4ml_code"
# Remove existing files in export directory
EXPORT_DIR="$BASE_PATH/export/hw"
rm -rf "$EXPORT_DIR"
# Create export directory if it doesn't exist
mkdir -p "$EXPORT_DIR"

# Copy and rename files

cp -v "$BASE_PATH/test1/test1.runs/impl_2/system_wrapper.bin" "$EXPORT_DIR/system.bin"
cp -v "$BASE_PATH/test1/test1.runs/impl_2/system_i_hls4ml_hls4ml_inst_0_partial.bin" "$EXPORT_DIR/par0.bin"
cp -v "$BASE_PATH/test1/test1.runs/child_1_impl_2/system_i_hls4ml_hls4ml_1_inst_0_partial.bin" "$EXPORT_DIR/par1.bin"
cp -v "$BASE_PATH/test1/test1.runs/child_2_impl_2/system_i_hls4ml_hls4ml_2_inst_0_partial.bin" "$EXPORT_DIR/par2.bin"
cp -v "$BASE_PATH/test1/test1.gen/sources_1/bd/system/hw_handoff/system.hwh" "$EXPORT_DIR/system.hwh"
cp -v "$BASE_PATH/viva_experiment/dfx_ctrl.gen/sources_1/bd/dfx_wrapper/ip/dfx_wrapper_dfx_controller_0_0/documentation/configuration_information.txt" "$EXPORT_DIR/dfx_ctrl_meta.txt"

echo "Hardware files collection complete in $EXPORT_DIR"
ls -l "$EXPORT_DIR"
