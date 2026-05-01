# NebulaOS

<div align="center">

**A Modern, Lightweight, AI-Powered Desktop Operating System**

*Inspired by Windows 11 aesthetics. Built on Linux. Designed for the future.*

[![Version](https://img.shields.io/badge/version-1.0-blue)](https://github.com/nebulaos)
[![License](https://img.shields.io/badge/license-GPL--3.0-green)](LICENSE)
[![Base](https://img.shields.io/badge/base-Debian%20Bookworm-red)](https://debian.org)

</div>

---

## Overview

NebulaOS is a custom Linux-based desktop operating system featuring:

- **Modern UI** - Windows 11 inspired desktop shell with glassmorphism, smooth animations, and rounded corners
- **Qt6/QML Desktop Shell** - GPU-accelerated compositor with Wayland support
- **AI Assistant** - Built-in Nebula AI with local and OpenAI API support
- **App Store** - GUI application store with Flatpak backend
- **Privacy-Focused** - AppArmor, sandboxed apps, firewall enabled by default
- **Lightweight** - Under 2GB RAM idle, boots in under 15 seconds
- **VM Ready** - First-class VMware and VirtualBox support

## Quick Start

### Prerequisites

- Debian 12+ or Ubuntu 22.04+ build host
- 30GB+ free disk space
- Root access (for live-build)
- 8GB+ RAM recommended for building

### Build the ISO

```bash
git clone https://github.com/nebulaos/NebulaOS.git
cd NebulaOS
sudo ./build.sh
```

The ISO will be generated at `iso-output/NebulaOS-v1.iso`.

### Launch in VirtualBox

```bash
./scripts/run-virtualbox.sh
```

### Launch in VMware

```bash
./scripts/run-vmware.sh
```

### Default Credentials

| Field    | Value    |
|----------|----------|
| Username | `nebula` |
| Password | `nebula` |

## Architecture

```
NebulaOS
├── kernel/          # Kernel configuration and tuning
├── desktop/         # Desktop shell (Qt6/QML)
│   ├── shell/       # Main shell: taskbar, start menu, panels
│   ├── widgets/     # Desktop widgets
│   └── themes/      # Theme engine
├── apps/            # Core applications
│   ├── settings/    # System Settings (PyQt6)
│   ├── app-store/   # GUI App Store (PyQt6 + Flatpak)
│   ├── file-manager/
│   ├── terminal/
│   ├── text-editor/
│   ├── calculator/
│   └── ...
├── installer/       # Calamares installer configuration
├── ai-assistant/    # Nebula AI (Python + PyQt6)
├── build-system/    # ISO build configuration
│   ├── config.sh    # Central build config
│   └── packages.list
├── themes/          # Theme packs (JSON + assets)
│   ├── dark/
│   ├── light/
│   └── nebula-blue/
├── scripts/         # VM launch scripts
├── docs/            # Documentation
└── iso-output/      # Generated ISO files
```

## Desktop Environment

### Technology Stack

| Component      | Technology          |
|---------------|---------------------|
| Display Server | Wayland (X11 fallback) |
| Shell Framework | Qt6 + QML          |
| Backend Logic  | C++ / Rust          |
| Applications   | Python (PyQt6)      |
| Compositor     | Custom (labwc fallback) |
| Init System    | systemd             |
| Audio          | PipeWire            |

### UI Features

- **Centered Taskbar** with pinned apps, system tray, and clock
- **Start Menu** with app search, pinned apps, and recent items
- **Search Panel** for apps, files, settings, and web
- **Notification Center** with Do Not Disturb mode
- **Quick Settings** with toggles for Wi-Fi, Bluetooth, Dark Mode, etc.
- **Widgets Panel** with weather, calendar, system monitor, and AI
- **Virtual Desktops** with smooth switching
- **Snap Layouts** for window tiling (halves, thirds, quarters)
- **Lock Screen** with clock and user profile

### Visual Design

- Glassmorphism / Acrylic blur effects
- Rounded corners (12px radius)
- Smooth 60 FPS GPU-accelerated animations
- Dark/Light/Auto theme switching
- Customizable accent colors
- Neon-accented cyberpunk variant theme

## Applications

### Preinstalled

| Category     | Apps                                           |
|-------------|------------------------------------------------|
| Browser     | Firefox ESR                                     |
| Files       | Thunar with tabs, split view                    |
| Terminal    | Alacritty                                       |
| Editor      | gedit / xed                                     |
| Calculator  | GNOME Calculator                                |
| Calendar    | GNOME Calendar                                  |
| Media       | Celluloid (Video), Rhythmbox (Music)            |
| System      | GNOME System Monitor, GParted                   |
| Settings    | NebulaOS Settings (custom)                      |
| App Store   | NebulaOS Store (custom, Flatpak backend)        |
| AI          | Nebula AI (custom)                              |

### Developer Tools

Pre-installed: Git, Python 3, Node.js, GCC, Make, CMake, Rust/Cargo

## Nebula AI

The built-in AI assistant supports:

- **Local Mode** - Rule-based system commands, app launching, file search
- **OpenAI Mode** - Full conversational AI via OpenAI API
- **Voice** - Speech-to-text and text-to-speech (espeak-ng)
- **System Integration** - Launch apps, search files, check system status
- **Keyboard Shortcut** - `Super+Space` to toggle

Configure in Settings > AI Assistant.

## Themes

Three built-in themes with full customization:

| Theme        | Description                          |
|-------------|--------------------------------------|
| Nebula Dark  | Deep space black with electric blue  |
| Nebula Light | Clean, airy light theme              |
| Nebula Blue  | Cyberpunk neon blue variant          |

Customize: accent colors, blur intensity, opacity, corner radius, animations.

## System Requirements

### Minimum

- CPU: x86_64 dual-core
- RAM: 2 GB
- Disk: 15 GB
- Display: 1024x768

### Recommended (VM)

- RAM: 4 GB
- CPU: 2 cores
- Disk: 30 GB
- Display: 1920x1080
- 3D Acceleration: Enabled

## VM Setup

See [docs/vm-setup.md](docs/vm-setup.md) for detailed instructions.

### VirtualBox Settings

- Type: Linux, Debian (64-bit)
- RAM: 4096 MB
- Video: 128 MB, VMSVGA, 3D Acceleration
- Disk: 30 GB VDI
- Network: NAT
- Boot: EFI
- Guest Additions: Auto-installed

### VMware Settings

- Guest OS: Debian 12 x64
- RAM: 4096 MB
- Video: 256 MB, 3D Acceleration
- Disk: 30 GB PVSCSI
- Network: NAT
- Firmware: EFI

## Building from Source

### Desktop Shell

```bash
cd desktop/shell
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install
```

### Full ISO

```bash
# Install build dependencies
sudo apt install live-build debootstrap squashfs-tools xorriso \
    grub-efi-amd64-bin grub-pc-bin mtools

# Build
sudo ./build.sh
```

## Keyboard Shortcuts

| Shortcut        | Action                |
|----------------|----------------------|
| `Super+S`      | Open Start Menu       |
| `Super+Q`      | Open Search           |
| `Super+N`      | Notification Center   |
| `Super+A`      | Quick Settings        |
| `Super+W`      | Widgets Panel         |
| `Super+E`      | File Manager          |
| `Super+T`      | Terminal              |
| `Super+L`      | Lock Screen           |
| `Super+Space`  | Nebula AI             |
| `Print`        | Screenshot            |

## Security

- UFW firewall enabled (deny incoming, allow outgoing)
- AppArmor mandatory access control
- Password hashing with SHA-512
- Sandboxed Flatpak applications
- Automatic security updates

## License

NebulaOS is released under the [GNU General Public License v3.0](LICENSE).

## Contributing

Contributions are welcome! See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

## Credits

Built with love using open-source software:
Linux, Debian, Qt, PipeWire, Wayland, GRUB, systemd, Flatpak, and many more.
