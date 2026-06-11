#!/bin/bash
# Script to transfer export folder to PYNQ board (Ubuntu 22.04)
# Usage: ./transfer_to_pynq.sh [export_folder_path] [pynq_ip] [pynq_user] [password] [despath]

# Default values
EXPORT_FOLDER="${1:-../export}"
PYNQ_IP="${2:-192.168.1.149}"
PYNQ_USER="${3:-root}"
PYNQ_PASSWORD="${4:-}"
PYNQ_DEST_PATH=${5:-/root/jupyter_notebooks/dfx4ml}

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if export folder exists
if [ ! -d "$EXPORT_FOLDER" ]; then
    echo -e "${RED}Error: Export folder '$EXPORT_FOLDER' does not exist${NC}"
    exit 1
fi

echo -e "${YELLOW}Transferring files to PYNQ board...${NC}"
echo "Export folder: $EXPORT_FOLDER"
echo "PYNQ IP: $PYNQ_IP"
echo "PYNQ user: $PYNQ_USER"
echo "Password: $([ -n "$PYNQ_PASSWORD" ] && echo "****" || echo "not provided (using SSH key)")"
echo "Destination: $PYNQ_DEST_PATH"
echo ""

# Remove existing destination directory on PYNQ board
echo -e "${YELLOW}Removing existing destination directory on PYNQ board...${NC}"
if [ -n "$PYNQ_PASSWORD" ]; then
    sshpass -p "${PYNQ_PASSWORD}" ssh ${PYNQ_USER}@${PYNQ_IP} "rm -rf ${PYNQ_DEST_PATH}"
else
    ssh ${PYNQ_USER}@${PYNQ_IP} "rm -rf ${PYNQ_DEST_PATH}"
fi

# Create destination directory on PYNQ board
echo -e "${YELLOW}Creating destination directory on PYNQ board...${NC}"
if [ -n "$PYNQ_PASSWORD" ]; then
    sshpass -p "${PYNQ_PASSWORD}" ssh ${PYNQ_USER}@${PYNQ_IP} "mkdir -p ${PYNQ_DEST_PATH}"
else
    ssh ${PYNQ_USER}@${PYNQ_IP} "mkdir -p ${PYNQ_DEST_PATH}"
fi

if [ $? -ne 0 ]; then
    echo -e "${RED}Error: Failed to create destination directory on PYNQ board${NC}"
    echo "Please check:"
    echo "  - PYNQ board is powered on and connected to network"
    echo "  - IP address is correct"
    echo "  - SSH access is configured (you may need to add SSH key)"
    exit 1
fi

# Transfer files using scp
echo -e "${YELLOW}Transferring files...${NC}"
if [ -n "$PYNQ_PASSWORD" ]; then
    sshpass -p "${PYNQ_PASSWORD}" scp -r ${EXPORT_FOLDER}/* ${PYNQ_USER}@${PYNQ_IP}:${PYNQ_DEST_PATH}/
else
    scp -r ${EXPORT_FOLDER}/* ${PYNQ_USER}@${PYNQ_IP}:${PYNQ_DEST_PATH}/
fi

if [ $? -eq 0 ]; then
    echo -e "${GREEN}Transfer completed successfully!${NC}"
    echo "Files are available at: ${PYNQ_USER}@${PYNQ_IP}:${PYNQ_DEST_PATH}"
else
    echo -e "${RED}Error: Transfer failed${NC}"
    exit 1
fi
