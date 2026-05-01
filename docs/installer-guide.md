# NebulaOS Installer Guide

NebulaOS uses a customized Calamares installer providing a modern graphical
installation experience similar to Windows 11.

## Starting the Installer

### From Live Desktop

1. Boot from the NebulaOS ISO
2. The live desktop loads automatically
3. Double-click the **Install NebulaOS** icon on the desktop
4. Or find it in the Start Menu under System

### From Boot Menu

1. At the GRUB boot menu, select **Install NebulaOS**
2. The installer launches directly

## Installation Steps

### 1. Welcome

- Review system requirements
- Verify internet connectivity
- Check minimum storage (15 GB) and RAM (2 GB)
- Select your language

### 2. Location

- Select your region and timezone
- The system clock will be configured accordingly

### 3. Keyboard

- Choose your keyboard layout
- Test the layout in the preview area
- Multiple layouts can be added

### 4. Partitions

#### Erase Disk (Recommended)

- Erases the entire disk and creates optimal partitions
- Swap options: None, Small (2 GB), Suspend (RAM size), Swap file
- Encryption option available

#### Manual Partitioning

Required partitions:
| Mount Point | Type  | Size         | Notes            |
|-------------|-------|-------------|------------------|
| `/boot/efi` | FAT32 | 512 MB      | EFI System       |
| `/`         | ext4  | 15+ GB      | Root filesystem  |
| `swap`      | swap  | 2-8 GB      | Optional         |

Supported filesystems: ext4, btrfs, xfs

#### Dual Boot

The installer can detect existing operating systems and configure GRUB
for dual-boot with Windows, macOS, or other Linux distributions.

### 5. Users

- **Full Name**: Your display name
- **Username**: Login name (lowercase, no spaces)
- **Password**: Minimum 6 characters
- **Hostname**: Computer name (auto-generated from username)
- Options:
  - Log in automatically (not recommended)
  - Use same password for root
  - Require password to log in

### 6. Summary

Review all settings before installation begins:
- Partition layout
- Packages to install
- User configuration
- Bootloader configuration

Click **Install** to begin.

### 7. Installation Progress

The installer will:
1. Partition and format disks
2. Copy system files
3. Install packages
4. Configure bootloader (GRUB2)
5. Set up users and locale
6. Install VM guest tools
7. Apply NebulaOS customization

This takes approximately 10-20 minutes.

### 8. Finished

- Remove the installation media (ISO)
- Click **Restart Now**
- The system boots into NebulaOS

## Post-Installation

### First Login

1. Enter your username and password at the login screen
2. The NebulaOS desktop loads

### Initial Setup

The Welcome app guides you through:
- Theme selection (Dark / Light / Blue)
- Default browser confirmation
- AI assistant setup
- System update check

### Connect to Internet

- Wi-Fi: Click the network icon in the taskbar
- Ethernet: Should auto-connect

### System Update

```bash
sudo apt update && sudo apt upgrade
```

Or go to Settings > Updates > Check for updates.

## Troubleshooting

### Installer Crashes

- Ensure minimum requirements are met
- Try with more RAM allocated
- Check the installer log: `/var/log/installer/`

### Boot Fails After Install

- Ensure EFI mode matches what was used during install
- Check GRUB installation was successful
- Try booting from the live ISO and repairing GRUB

### Partition Errors

- Ensure the disk is not mounted elsewhere
- For VMs, make sure no other VM is using the same disk
- Try erasing the disk option instead of manual partitioning
