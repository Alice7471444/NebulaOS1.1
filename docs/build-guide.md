# NebulaOS Build Guide

Complete guide to building NebulaOS from source.

## Prerequisites

### Build Host Requirements

- **OS**: Debian 12 (Bookworm) or Ubuntu 22.04+
- **RAM**: 8 GB minimum (16 GB recommended)
- **Disk**: 30 GB free space
- **CPU**: Multi-core recommended for faster builds
- **Network**: Internet access for package downloads
- **Privileges**: Root access required

### Install Build Dependencies

```bash
sudo apt update
sudo apt install -y \
    live-build \
    debootstrap \
    squashfs-tools \
    xorriso \
    grub-efi-amd64-bin \
    grub-pc-bin \
    mtools \
    git \
    curl \
    wget
```

## Build Process

### Clone the Repository

```bash
git clone https://github.com/nebulaos/NebulaOS.git
cd NebulaOS
```

### Full Build

```bash
sudo ./build.sh
```

This will:
1. Verify build dependencies
2. Configure live-build with NebulaOS settings
3. Set up package lists
4. Install build hooks
5. Copy desktop files, themes, and apps
6. Build the root filesystem
7. Generate the bootloader
8. Create the ISO image
9. Generate SHA256 checksum

The build takes 30-60 minutes depending on your system and internet speed.

### Output

```
iso-output/
├── NebulaOS-v1.iso        # Bootable ISO image
└── NebulaOS-v1.iso.sha256 # SHA256 checksum
```

### Build Options

```bash
# Clean previous build artifacts
sudo ./build.sh clean

# Configure only (without building)
sudo ./build.sh config

# Full build
sudo ./build.sh build
```

## Configuration

### Central Config (`build-system/config.sh`)

Key settings you can customize:

```bash
NEBULA_VERSION="1.0"        # Version number
NEBULA_SUITE="bookworm"     # Debian release
NEBULA_ARCH="amd64"         # Architecture
NEBULA_COMPRESSION="xz"     # ISO compression (xz, gzip, lz4)
NEBULA_DISPLAY_SERVER="wayland"  # wayland or x11
```

### Package List (`build-system/packages.list`)

Add or remove packages from the ISO by editing this file.
One package per line, comments with `#`.

## Building the Desktop Shell

The Qt6/QML desktop shell can be built separately:

```bash
cd desktop/shell
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
```

Requirements:
- Qt6 development packages
- CMake 3.20+
- C++20 compiler

```bash
sudo apt install -y \
    qt6-base-dev \
    qt6-declarative-dev \
    qt6-wayland-dev \
    qt6-multimedia-dev \
    qt6-svg-dev \
    cmake \
    g++
```

## Customization

### Adding Custom Themes

1. Create a directory under `themes/your-theme-name/`
2. Add a `theme.json` file (see existing themes for format)
3. Optionally add wallpapers and icon packs
4. Rebuild the ISO

### Adding Applications

1. Add package names to `build-system/packages.list`
2. Or add custom apps to `apps/your-app/`
3. Create a `.desktop` file for menu integration
4. Rebuild

### Custom Branding

Edit files in:
- `installer/calamares/branding/nebulaos/` - Installer branding
- `build-system/config.sh` - OS name and version
- GRUB theme in `build.sh` (`setup_grub_theme` function)

## Troubleshooting

### Build Fails at Package Installation

- Check internet connectivity
- Verify Debian mirror is accessible
- Try: `sudo ./build.sh clean && sudo ./build.sh`

### ISO Won't Boot

- Verify the ISO checksum: `sha256sum -c NebulaOS-v1.iso.sha256`
- Ensure EFI boot is enabled in the VM
- Try both BIOS and EFI boot modes

### Disk Space Issues

- Clean build: `sudo ./build.sh clean`
- The build cache can be large; check `.cache/` directory
- Ensure 30 GB+ free space before building

## CI/CD (Optional)

Example GitHub Actions workflow:

```yaml
name: Build NebulaOS ISO
on:
  push:
    branches: [main]
  workflow_dispatch:

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - name: Install dependencies
        run: |
          sudo apt update
          sudo apt install -y live-build debootstrap squashfs-tools \
            xorriso grub-efi-amd64-bin grub-pc-bin mtools

      - name: Build ISO
        run: sudo ./build.sh

      - name: Upload ISO
        uses: actions/upload-artifact@v4
        with:
          name: NebulaOS-ISO
          path: iso-output/NebulaOS-v1.iso
```
