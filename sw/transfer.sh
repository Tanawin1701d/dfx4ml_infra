#!/bin/bash

# --- Configuration ---
TARGET_USER="root"
TARGET_PASS="42056344"
TARGET_IP="192.168.1.149"
TARGET_PATH="/root/jupyter_notebooks/dfx4ml"

# Local source directory (parent directory of this script)
LOCAL_DIR="$(dirname "$(realpath "$0")")"

# --- Colors for visual feedback ---
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# --- Helper functions ---
log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

# --- Script Logic ---

echo -e "${BLUE}==================================================${NC}"
echo -e "${BLUE}        DFX4ML Data Transfer Tool                 ${NC}"
echo -e "${BLUE}==================================================${NC}"

# 1. Dependency Check
if ! command -v sshpass &> /dev/null; then
    log_error "sshpass not found."
    echo "Please install it using: sudo apt update && sudo apt install sshpass"
    exit 1
fi

# 2. Preparation: Ensure remote path exists and is clean
log_info "Cleaning remote directory: ${YELLOW}$TARGET_PATH${NC} on ${YELLOW}$TARGET_IP${NC}"
if sshpass -p "$TARGET_PASS" ssh -o StrictHostKeyChecking=no "$TARGET_USER@$TARGET_IP" "mkdir -p $TARGET_PATH && rm -rf $TARGET_PATH/*"; then
    log_success "Remote directory prepared."
else
    log_error "Failed to prepare remote directory. Check connection/credentials."
    exit 1
fi

# 3. Data Transfer
log_info "Transferring files from ${YELLOW}$LOCAL_DIR${NC}..."
# Using scp -r to transfer all contents except the script itself to avoid clutter if needed, 
# but transferring everything is requested.
if sshpass -p "$TARGET_PASS" scp -o StrictHostKeyChecking=no -r "$LOCAL_DIR"/* "$TARGET_USER@$TARGET_IP:$TARGET_PATH"; then
    log_success "Transfer completed successfully."
else
    log_error "Transfer failed."
    exit 1
fi

echo -e "${BLUE}==================================================${NC}"
echo -e "${GREEN}             PROCESS COMPLETE                    ${NC}"
echo -e "${BLUE}==================================================${NC}"
