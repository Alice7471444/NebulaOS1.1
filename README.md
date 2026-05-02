# 🚀 NebulaOS 1.1 (Aurora)

<div align="center">

<p align="center">

![NebulaOS](https://img.shields.io/badge/NebulaOS-1.1_Aurora-7C3AED?style=for-the-badge&logo=linux)
![Version](https://img.shields.io/badge/version-1.1-blueviolet)
![License](https://img.shields.io/badge/license-GPL--3.0-green)
![Debian](https://img.shields.io/badge/base-Debian%2012-a80030?logo=debian)
![Status](https://img.shields.io/badge/status-Active-success)
![Stars](https://img.shields.io/github/stars/Alice7471444/NebulaOS1.1?style=social)
![Forks](https://img.shields.io/github/forks/Alice7471444/NebulaOS1.1?style=social)

</p>

**✨ A Modern, Lightweight, AI-Powered Desktop Operating System ✨**

*Built on Linux • Inspired by Windows 11 aesthetics • Designed for the future*

</div>

---

<div align="center">

<a href="https://debian.org">
  <img src="https://img.shields.io/badge/debian-12+-a80030?logo=debian" alt="Debian" />
</a>
<a href="https://qt.io">
  <img src="https://img.shields.io/badge/Qt-6-41cd52?logo=qt" alt="Qt6" />
</a>
<a href="https://wayland.freedesktop.org/">
  <img src="https://img.shields.io/badge/Wayland-Ready-41cd52" alt="Wayland" />
</a>
<a href="https://python.org/">
  <img src="https://img.shields.io/badge/Python-3.11+-3776AB?logo=python" alt="Python" />
</a>

</div>

---

## 🌟 Features

| Feature | Description |
|---------|-------------|
| 🎨 **Modern UI** | Windows 11 inspired glassmorphism with smooth 60FPS animations |
| ⚡ **AI Assistant** | Built-in Nebula AI with local + OpenAI API support 🤖 |
| 🔒 **Privacy First** | AppArmor, sandboxed apps, firewall enabled by default |
| 📦 **App Store** | GUI package manager with Flatpak backend |
| 💨 **Lightweight** | Under 2GB RAM idle, boots in under 10 seconds |
| 🖥️ **VM Ready** | First-class VMware and VirtualBox support |

---

## 🚀 Quick Start

### Build the ISO

```bash
git clone https://github.com/Alice7471444/NebulaOS1.1.git
cd NebulaOS1.1
sudo ./build.sh
```

### Launch in VirtualBox

```bash
./scripts/run-virtualbox.sh
```

### Launch in VMware

```bash
./scripts/run-vmware.sh
```

### Default Credentials

| Field | Value |
|-------|-------|
| Username | `nebula` |
| Password | `nebula` |

---

## 🏗️ Architecture

```
NebulaOS v1.1 (Aurora)
├── kernel/              # Kernel configuration & tuning
├── desktop/            # Desktop shell (Qt6/QML)
│   └── shell/           # Main shell: taskbar, start menu, panels
├── apps/               # Core applications
│   ├── settings/        # System Settings
│   ├── app-store/      # GUI App Store
│   └── welcome/        # Welcome app
├── ai-assistant/        # Nebula AI 🤖
├── build-system/       # ISO build configuration
├── installer/          # Calamares installer
├── themes/              # Theme packs (Dark/Light/Neon)
├── docs/                # Documentation
└── scripts/            # VM launch scripts
```

---

## 🖥️ Desktop Environment

### Technology Stack

| Component | Technology |
|-----------|-----------|
| Display Server | Wayland (X11 fallback) |
| Shell Framework | Qt6 + QML |
| Backend Logic | C++ / Rust |
| Applications | Python (PyQt6) |
| Compositor | Custom (labwc fallback) |
| Init System | systemd |
| Audio | PipeWire |

### UI Features

| Feature | Shortcut | Description |
|---------|----------|-------------|
| Start Menu | `Super+S` | App search, pinned/recent apps |
| Search Panel | `Super+Q` | Apps, files, settings, web |
| Quick Settings | `Super+A` | Wi-Fi, Bluetooth, Dark Mode |
| Notification Center | `Super+N` | Do Not Disturb mode |
| Widgets Panel | `Super+W` | Weather, calendar, system monitor |
| AI Assistant | `Super+Space` | Nebula AI integration |
| File Manager | `Super+E` | File browser |
| Terminal | `Super+T` | Terminal emulator |
| Lock Screen | `Super+L` | Lock screen with clock |

---

## 🤖 Nebula AI

<p align="center">

<a href="https://openai.com/">
  <img src="https://img.shields.io/badge/Powered_by-Nebula_AI-8B5CF6?logo=robot" alt="AI" />
</a>

</p>

### Capabilities

| Mode | Description |
|------|-------------|
| **Local Mode** | Rule-based system commands |
| **OpenAI Mode** | Full conversational AI via API |
| **Voice** | Speech-to-text and TTS (espeak-ng) |

### Voice Commands

- "Open [app]" - Launch applications
- "Find [file]" - Search files
- "System info" - Check system status
- "What time is it?" - Show time and date
- "Check battery" - Battery status

---

## 🎨 Themes

<p align="center">

| Theme | Description |
|-------|-------------|
| 🌑 **Nebula Dark** | Deep space black with electric blue |
| ☀️ **Nebula Light** | Clean, airy light theme |
| 🌟 **Nebula Neon** | Cyberpunk neon glow variant |

</p>

### Visual Design

- � glassmorphism / Acrylic blur effects
- 🔘 Rounded corners (12px radius)
- ⚡ Smooth 60 FPS GPU-accelerated animations
- 🌙 Dark/Light/Auto theme switching
- 🎨 Customizable accent colors

---

## 🔐 Security

<p align="center">

| Feature | Description |
|---------|-------------|
| 🛡️ UFW Firewall | Enabled by default (deny incoming) |
| 🔒 AppArmor | Mandatory access control |
| 🔑 SHA-512 | Password hashing |
| 📦 Flatpak | Sandboxed applications |
| 🔄 Auto Updates | Security patches |

</p>

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Super+S` | Start Menu |
| `Super+Q` | Search |
| `Super+N` | Notification Center |
| `Super+A` | Quick Settings |
| `Super+W` | Widgets Panel |
| `Super+E` | File Manager |
| `Super+T` | Terminal |
| `Super+L` | Lock Screen |
| `Super+Space` | Nebula AI |
| `Print` | Screenshot |

---

## 🖥️ System Requirements

### Minimum

| Component | Requirement |
|-----------|-------------|
| CPU | x86_64 dual-core |
| RAM | 2 GB |
| Disk | 15 GB |
| Display | 1024x768 |

### Recommended (VM)

| Component | Requirement |
|-----------|-------------|
| RAM | 4 GB |
| CPU | 2 cores |
| Disk | 30 GB |
| Display | 1920x1080 |
| 3D Accel | Enabled |

---

## 🛠️ Build from Source

```bash
# Desktop Shell
cd desktop/shell
mkdir build && cd build
cmake .. -DCMAKE_BUILD_TYPE=Release
make -j$(nproc)
sudo make install

# Full ISO
sudo apt install live-build debootstrap squashfs-tools xorriso \
    grub-efi-amd64-bin grub-pc-bin mtools

sudo ./build.sh
```

---

## 📜 License

<p align="center">

Licensed under the [GNU General Public License v3.0](LICENSE).

Built with 💜 using open-source software:
Linux, Debian, Qt, PipeWire, Wayland, GRUB, systemd, Flatpak

</p>

---

## 🤝 Contributing

Contributions are welcome! See [CONTRIBUTING.md](docs/CONTRIBUTING.md) for guidelines.

---

<div align="center">

<p>

⭐ Star us on GitHub | 🍴 Fork the project | 🐛 Report issues

</p>

<p>

**NebulaOS v1.1 (Aurora)** — *The future of desktop operating systems*

</p>

</div>