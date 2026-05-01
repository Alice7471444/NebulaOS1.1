#!/bin/bash
set -euo pipefail

#=============================================================================
# NebulaOS VirtualBox Launch Script
# Creates and configures a VM optimized for NebulaOS
#=============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../build-system/config.sh"

VM_NAME="NebulaOS"
VM_RAM=4096
VM_CPUS=2
VM_DISK_SIZE=30720  # 30GB in MB
VM_DISK="${NEBULA_ROOT}/vm/NebulaOS.vdi"
ISO_PATH="${NEBULA_ISO_OUTPUT}/${NEBULA_ISO_NAME}"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${CYAN}[NebulaOS VM]${NC} $*"; }
ok()   { echo -e "${GREEN}[  OK  ]${NC} $*"; }
err()  { echo -e "${RED}[ERROR ]${NC} $*"; }

# Check prerequisites
if ! command -v VBoxManage &>/dev/null; then
    err "VirtualBox is not installed. Please install VirtualBox first."
    echo "  Download: https://www.virtualbox.org/wiki/Downloads"
    exit 1
fi

if [[ ! -f "$ISO_PATH" ]]; then
    err "ISO not found: $ISO_PATH"
    echo "  Build it first: sudo ./build.sh"
    exit 1
fi

# Check if VM already exists
if VBoxManage showvminfo "$VM_NAME" &>/dev/null; then
    log "VM '$VM_NAME' already exists."
    read -p "Delete and recreate? [y/N] " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        VBoxManage unregistervm "$VM_NAME" --delete 2>/dev/null || true
    else
        log "Starting existing VM..."
        VBoxManage startvm "$VM_NAME" --type gui
        exit 0
    fi
fi

log "Creating VirtualBox VM: $VM_NAME"

# Create VM
VBoxManage createvm --name "$VM_NAME" --ostype Debian_64 --register

# Configure VM
VBoxManage modifyvm "$VM_NAME" \
    --memory $VM_RAM \
    --cpus $VM_CPUS \
    --vram 128 \
    --graphicscontroller vmsvga \
    --accelerate3d on \
    --firmware efi \
    --boot1 dvd \
    --boot2 disk \
    --nic1 nat \
    --natpf1 "ssh,tcp,,2222,,22" \
    --audio-driver pulse \
    --audio-out on \
    --audio-in on \
    --clipboard-mode bidirectional \
    --draganddrop bidirectional \
    --usb on \
    --usbehci on \
    --nested-hw-virt on \
    --description "NebulaOS v${NEBULA_VERSION} - Modern Desktop OS"

ok "VM configured"

# Create virtual disk
mkdir -p "$(dirname "$VM_DISK")"
VBoxManage createmedium disk --filename "$VM_DISK" --size $VM_DISK_SIZE --format VDI --variant Standard
ok "Virtual disk created: ${VM_DISK_SIZE}MB"

# Add storage controllers
VBoxManage storagectl "$VM_NAME" --name "SATA" --add sata --controller IntelAhci --portcount 2 --bootable on
VBoxManage storagectl "$VM_NAME" --name "IDE" --add ide

# Attach disk and ISO
VBoxManage storageattach "$VM_NAME" --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$VM_DISK"
VBoxManage storageattach "$VM_NAME" --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium "$ISO_PATH"
ok "Storage attached"

# Start VM
log "Starting NebulaOS VM..."
VBoxManage startvm "$VM_NAME" --type gui

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  NebulaOS VM Started!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "  VM Name:     $VM_NAME"
echo "  RAM:         ${VM_RAM}MB"
echo "  CPUs:        $VM_CPUS"
echo "  Disk:        ${VM_DISK_SIZE}MB"
echo "  SSH:         ssh -p 2222 nebula@localhost"
echo ""
echo "  Default credentials:"
echo "    User:      nebula"
echo "    Password:  nebula"
echo ""
