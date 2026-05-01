# NebulaOS VM Setup Guide

This guide covers setting up NebulaOS in both VirtualBox and VMware.

## VirtualBox Setup

### Automated Setup

Run the included script:

```bash
./scripts/run-virtualbox.sh
```

This creates a VM with optimal settings and boots from the ISO.

### Manual Setup

1. **Create VM**
   - Name: `NebulaOS`
   - Type: Linux
   - Version: Debian (64-bit)

2. **System Settings**
   - Base Memory: 4096 MB
   - Processors: 2
   - Enable EFI: Yes
   - Boot Order: Optical, Hard Disk

3. **Display**
   - Video Memory: 128 MB
   - Graphics Controller: VMSVGA
   - Enable 3D Acceleration: Yes

4. **Storage**
   - Create a 30 GB VDI disk (dynamically allocated)
   - Attach the `NebulaOS-v1.iso` to the optical drive

5. **Network**
   - Adapter 1: NAT (for internet)
   - Optionally add Adapter 2 as Bridge for LAN access

6. **Audio**
   - Enable audio output and input
   - Host Driver: PulseAudio (Linux) or Core Audio (macOS)

7. **USB**
   - Enable USB 2.0 (EHCI) controller

8. **Start the VM**
   - The live desktop will boot automatically
   - Use the installer to install to the virtual disk

### Post-Installation

After installing, remove the ISO from the optical drive and reboot.

Guest Additions should be auto-installed. If not:
```bash
sudo apt install virtualbox-guest-utils virtualbox-guest-x11
```

Enable shared clipboard:
- Devices > Shared Clipboard > Bidirectional

---

## VMware Workstation/Player Setup

### Automated Setup

```bash
./scripts/run-vmware.sh
```

This generates a `.vmx` configuration file and virtual disk.

### Manual Setup

1. **Create New VM**
   - Guest OS: Debian 12.x 64-bit
   - Firmware: EFI

2. **Hardware Settings**
   - Memory: 4096 MB
   - Processors: 2
   - Hard Disk: 30 GB (PVSCSI recommended)
   - CD/DVD: Use ISO image (`NebulaOS-v1.iso`)
   - Network: NAT
   - Display: 3D acceleration on, 256 MB graphics memory

3. **Boot and Install**
   - Start the VM
   - The live desktop loads automatically
   - Launch the installer from the desktop or app menu

### VMware Tools

Open VM Tools are auto-installed. Verify:
```bash
vmware-toolbox-cmd --version
```

If not working:
```bash
sudo apt install open-vm-tools open-vm-tools-desktop
```

---

## First Boot

### Live Session

The ISO boots into a live desktop session with full functionality.
Use this to explore NebulaOS before installing.

### Installation

1. Launch the **NebulaOS Installer** from the desktop
2. Select your language
3. Choose your keyboard layout
4. Partition the disk:
   - **Erase disk** (recommended for VMs)
   - Or manual partitioning
5. Create your user account
6. Set timezone
7. Review and install
8. Reboot when prompted

### After Installation

1. Log in with your created credentials
2. Connect to the internet (should auto-connect via NAT)
3. Run system update:
   ```bash
   sudo apt update && sudo apt upgrade
   ```
4. Explore Settings to customize themes, AI assistant, etc.

---

## Troubleshooting

### Black Screen After Boot

- Ensure EFI mode is enabled
- Try adding `nomodeset` to kernel parameters at GRUB
- Increase video memory allocation

### No Internet

- Check NAT adapter is enabled
- Run: `sudo systemctl restart NetworkManager`

### Slow Performance

- Ensure 3D acceleration is enabled
- Allocate more RAM (4GB minimum recommended)
- Enable hardware virtualization (VT-x/AMD-V) in BIOS

### Resolution Issues

- VirtualBox: Install Guest Additions
- VMware: Ensure `open-vm-tools-desktop` is installed
- Run: `xrandr --output Virtual-1 --mode 1920x1080`

### Audio Not Working

- VirtualBox: Set audio driver to PulseAudio
- VMware: `sound.virtualDev = "hdaudio"` in .vmx file
- Run: `systemctl --user restart pipewire pipewire-pulse`
