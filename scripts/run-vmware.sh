#!/bin/bash
set -euo pipefail

#=============================================================================
# NebulaOS VMware Launch Script
# Creates and launches a VMware Workstation/Fusion VM
#=============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/../build-system/config.sh"

VM_NAME="NebulaOS"
VM_DIR="${NEBULA_ROOT}/vm/vmware"
VM_RAM=4096
VM_CPUS=2
VM_DISK_SIZE=30  # GB
ISO_PATH="${NEBULA_ISO_OUTPUT}/${NEBULA_ISO_NAME}"

RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
NC='\033[0m'

log()  { echo -e "${CYAN}[NebulaOS VM]${NC} $*"; }
ok()   { echo -e "${GREEN}[  OK  ]${NC} $*"; }
err()  { echo -e "${RED}[ERROR ]${NC} $*"; }

if [[ ! -f "$ISO_PATH" ]]; then
    err "ISO not found: $ISO_PATH"
    echo "  Build it first: sudo ./build.sh"
    exit 1
fi

mkdir -p "$VM_DIR"

# Generate VMX configuration
VMX_FILE="${VM_DIR}/${VM_NAME}.vmx"

log "Creating VMware VM configuration..."

cat > "$VMX_FILE" << VMXEOF
.encoding = "UTF-8"
config.version = "8"
virtualHW.version = "18"
pciBridge0.present = "TRUE"
pciBridge4.present = "TRUE"
pciBridge4.virtualDev = "pcieRootPort"
pciBridge4.functions = "8"
vmci0.present = "TRUE"
hpet0.present = "TRUE"

displayName = "${VM_NAME}"
guestOS = "debian12-64"
firmware = "efi"

memsize = "${VM_RAM}"
numvcpus = "${VM_CPUS}"
cpuid.coresPerSocket = "${VM_CPUS}"

scsi0.present = "TRUE"
scsi0.virtualDev = "pvscsi"

scsi0:0.present = "TRUE"
scsi0:0.fileName = "${VM_NAME}.vmdk"

sata0.present = "TRUE"
sata0:0.present = "TRUE"
sata0:0.deviceType = "cdrom-image"
sata0:0.fileName = "${ISO_PATH}"
sata0:0.startConnected = "TRUE"

ethernet0.present = "TRUE"
ethernet0.virtualDev = "vmxnet3"
ethernet0.connectionType = "nat"
ethernet0.addressType = "generated"
ethernet0.wakeOnPcktRcv = "FALSE"

usb.present = "TRUE"
ehci.present = "TRUE"
usb_xhci.present = "TRUE"

sound.present = "TRUE"
sound.virtualDev = "hdaudio"
sound.autodetect = "TRUE"

svga.vramSize = "134217728"
svga.graphicsMemoryKB = "262144"
mks.enable3d = "TRUE"

tools.syncTime = "TRUE"
tools.upgrade.policy = "manual"

isolation.tools.copy.disable = "FALSE"
isolation.tools.paste.disable = "FALSE"
isolation.tools.dnd.disable = "FALSE"

gui.fullScreenAtPowerOn = "FALSE"
gui.fitGuestUsingNativeDisplayResolution = "TRUE"

annotation = "NebulaOS v${NEBULA_VERSION} - Modern Desktop Operating System"
VMXEOF

ok "VMX configuration created: $VMX_FILE"

# Create virtual disk if it doesn't exist
VMDK_FILE="${VM_DIR}/${VM_NAME}.vmdk"
if [[ ! -f "$VMDK_FILE" ]]; then
    if command -v vmware-vdiskmanager &>/dev/null; then
        log "Creating virtual disk with vmware-vdiskmanager..."
        vmware-vdiskmanager -c -s "${VM_DISK_SIZE}GB" -a pvscsi -t 0 "$VMDK_FILE"
    elif command -v qemu-img &>/dev/null; then
        log "Creating virtual disk with qemu-img..."
        qemu-img create -f vmdk "$VMDK_FILE" "${VM_DISK_SIZE}G"
    else
        err "No disk creation tool found. Install VMware Workstation or qemu-img."
        exit 1
    fi
    ok "Virtual disk created: ${VM_DISK_SIZE}GB"
fi

# Launch VM
if command -v vmrun &>/dev/null; then
    log "Starting VM with vmrun..."
    vmrun start "$VMX_FILE" gui
elif command -v vmware &>/dev/null; then
    log "Opening VM in VMware Workstation..."
    vmware "$VMX_FILE" &
elif command -v vmplayer &>/dev/null; then
    log "Opening VM in VMware Player..."
    vmplayer "$VMX_FILE" &
else
    log "VMware not detected. VM files created at: $VM_DIR"
    log "Open ${VMX_FILE} in VMware Workstation/Player/Fusion to start."
fi

echo ""
echo -e "${GREEN}============================================${NC}"
echo -e "${GREEN}  NebulaOS VMware VM Ready!${NC}"
echo -e "${GREEN}============================================${NC}"
echo ""
echo "  VM Directory: $VM_DIR"
echo "  VMX File:     $VMX_FILE"
echo "  RAM:          ${VM_RAM}MB"
echo "  CPUs:         $VM_CPUS"
echo "  Disk:         ${VM_DISK_SIZE}GB"
echo ""
echo "  Default credentials:"
echo "    User:       nebula"
echo "    Password:   nebula"
echo ""
echo "  Recommended VMware settings:"
echo "    - Enable 3D acceleration"
echo "    - Enable EFI boot"
echo "    - Install VMware Tools after first boot"
echo ""
