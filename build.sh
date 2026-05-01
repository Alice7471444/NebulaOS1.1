#!/bin/bash
set -euo pipefail

#=============================================================================
# NebulaOS ISO Build Script
# Generates a bootable ISO using Debian live-build
#=============================================================================

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
source "${SCRIPT_DIR}/build-system/config.sh"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m'

log()   { echo -e "${CYAN}[NebulaOS]${NC} $*"; }
ok()    { echo -e "${GREEN}[  OK  ]${NC} $*"; }
warn()  { echo -e "${YELLOW}[ WARN ]${NC} $*"; }
err()   { echo -e "${RED}[ERROR ]${NC} $*"; }

banner() {
    echo -e "${BLUE}"
    echo "  ███╗   ██╗███████╗██████╗ ██╗   ██╗██╗      █████╗  ██████╗ ███████╗"
    echo "  ████╗  ██║██╔════╝██╔══██╗██║   ██║██║     ██╔══██╗██╔═══██╗██╔════╝"
    echo "  ██╔██╗ ██║█████╗  ██████╔╝██║   ██║██║     ███████║██║   ██║███████╗"
    echo "  ██║╚██╗██║██╔══╝  ██╔══██╗██║   ██║██║     ██╔══██║██║   ██║╚══════║"
    echo "  ██║ ╚████║███████╗██████╔╝╚██████╔╝███████╗██║  ██║╚██████╔╝███████║"
    echo "  ╚═╝  ╚═══╝╚══════╝╚═════╝  ╚═════╝ ╚══════╝╚═╝  ╚═╝ ╚═════╝ ╚══════╝"
    echo -e "${NC}"
    echo "  Build System v${NEBULA_VERSION} (${NEBULA_CODENAME})"
    echo ""
}

check_root() {
    if [[ $EUID -ne 0 ]]; then
        err "This script must be run as root (sudo ./build.sh)"
        exit 1
    fi
}

check_dependencies() {
    log "Checking build dependencies..."
    local deps=(live-build debootstrap squashfs-tools xorriso grub-efi-amd64-bin grub-pc-bin mtools)
    local missing=()

    for dep in "${deps[@]}"; do
        if ! dpkg -l "$dep" &>/dev/null; then
            missing+=("$dep")
        fi
    done

    if [[ ${#missing[@]} -gt 0 ]]; then
        log "Installing missing dependencies: ${missing[*]}"
        apt-get update
        apt-get install -y "${missing[@]}"
    fi
    ok "All build dependencies satisfied"
}

clean_build() {
    log "Cleaning previous build..."
    rm -rf "${NEBULA_BUILD_DIR}"
    mkdir -p "${NEBULA_BUILD_DIR}"
    mkdir -p "${NEBULA_ISO_OUTPUT}"
    ok "Build directory cleaned"
}

configure_live_build() {
    log "Configuring live-build..."
    cd "${NEBULA_BUILD_DIR}"

    # Build lb config command with only supported options
    local lb_args=(
        --distribution "${NEBULA_SUITE}"
        --architectures "${NEBULA_ARCH}"
        --archive-areas "main contrib non-free non-free-firmware"
        --mirror-bootstrap "${NEBULA_MIRROR}"
        --mirror-chroot "${NEBULA_MIRROR}"
        --mirror-binary "${NEBULA_MIRROR}"
        --bootappend-live "boot=live components hostname=${NEBULA_HOSTNAME} username=${NEBULA_DEFAULT_USER} locales=${NEBULA_DEFAULT_LOCALE} timezone=${NEBULA_DEFAULT_TIMEZONE}"
        --iso-application "${NEBULA_NAME}"
        --iso-publisher "${NEBULA_NAME} Project"
        --iso-volume "${NEBULA_ISO_LABEL}"
        --image-name "${NEBULA_NAME}"
        --binary-images iso-hybrid
        --memtest none
        --updates true
        --security true
        --checksums sha256
        --compression "${NEBULA_COMPRESSION}"
        --apt-recommends true
        --debootstrap-options "--variant=minbase"
    )

    # Add bootloaders (try grub-efi first, fall back to syslinux only)
    if dpkg -l grub-efi-amd64-bin &>/dev/null; then
        lb_args+=(--bootloaders "grub-efi,syslinux")
    else
        lb_args+=(--bootloaders "syslinux")
    fi

    lb config "${lb_args[@]}"

    ok "Live-build configured"
}

setup_package_lists() {
    log "Setting up package lists..."
    mkdir -p "${NEBULA_BUILD_DIR}/config/package-lists"

    # Copy main package list
    cp "${NEBULA_ROOT}/build-system/packages.list" \
       "${NEBULA_BUILD_DIR}/config/package-lists/nebula.list.chroot"

    ok "Package lists configured"
}

setup_hooks() {
    log "Setting up build hooks..."
    mkdir -p "${NEBULA_BUILD_DIR}/config/hooks/live"
    mkdir -p "${NEBULA_BUILD_DIR}/config/hooks/normal"

    # Chroot hook: runs inside the chroot during build
    cat > "${NEBULA_BUILD_DIR}/config/hooks/normal/0100-nebula-setup.hook.chroot" << 'HOOK'
#!/bin/bash
set -e

echo "[NebulaOS] Running chroot setup hook..."

# Enable systemd services
systemctl enable NetworkManager || true
systemctl enable bluetooth || true
systemctl enable ufw || true
systemctl enable apparmor || true

# Configure firewall
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh

# Create nebula user if not exists
if ! id "nebula" &>/dev/null; then
    useradd -m -s /bin/bash -G sudo,audio,video,plugdev,netdev,bluetooth nebula
    echo "nebula:nebula" | chpasswd
fi

# Setup Flatpak
flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo || true

# Configure GRUB
sed -i 's/GRUB_TIMEOUT=5/GRUB_TIMEOUT=3/' /etc/default/grub || true
sed -i 's/#GRUB_GFXMODE=.*/GRUB_GFXMODE=1920x1080/' /etc/default/grub || true

# Set locale
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
locale-gen
update-locale LANG=en_US.UTF-8

# Set timezone
ln -sf /usr/share/zoneinfo/UTC /etc/localtime

echo "[NebulaOS] Chroot setup complete."
HOOK
    chmod +x "${NEBULA_BUILD_DIR}/config/hooks/normal/0100-nebula-setup.hook.chroot"

    # Desktop setup hook
    cat > "${NEBULA_BUILD_DIR}/config/hooks/normal/0200-nebula-desktop.hook.chroot" << 'HOOK'
#!/bin/bash
set -e

echo "[NebulaOS] Setting up desktop environment..."

DESKTOP_DIR="/usr/share/nebula-desktop"
mkdir -p "$DESKTOP_DIR"
mkdir -p /usr/share/xsessions
mkdir -p /usr/share/wayland-sessions

# Create Wayland session entry
cat > /usr/share/wayland-sessions/nebula.desktop << EOF
[Desktop Entry]
Name=NebulaOS Desktop
Comment=NebulaOS Modern Desktop Environment
Exec=/usr/bin/nebula-session
Type=Application
DesktopNames=NebulaOS
EOF

# Create X11 fallback session entry
cat > /usr/share/xsessions/nebula-x11.desktop << EOF
[Desktop Entry]
Name=NebulaOS Desktop (X11)
Comment=NebulaOS Desktop Environment (X11 fallback)
Exec=/usr/bin/nebula-session-x11
Type=Application
DesktopNames=NebulaOS
EOF

# Install NebulaOS desktop components
if [ -d /opt/nebula-desktop/bin ]; then
    ln -sf /opt/nebula-desktop/bin/nebula-shell /usr/bin/nebula-shell
    ln -sf /opt/nebula-desktop/bin/nebula-session /usr/bin/nebula-session
    ln -sf /opt/nebula-desktop/bin/nebula-session-x11 /usr/bin/nebula-session-x11
fi

# Set NebulaOS as default session
mkdir -p /etc/sddm.conf.d
cat > /etc/sddm.conf.d/nebula.conf << EOF
[General]
DisplayServer=wayland

[Theme]
Current=nebula

[Users]
DefaultPath=/usr/bin
MinimumUid=1000

[Wayland]
SessionDir=/usr/share/wayland-sessions
EOF

echo "[NebulaOS] Desktop setup complete."
HOOK
    chmod +x "${NEBULA_BUILD_DIR}/config/hooks/normal/0200-nebula-desktop.hook.chroot"

    ok "Build hooks configured"
}

install_nebula_desktop() {
    log "Installing NebulaOS desktop files..."
    local includes="${NEBULA_BUILD_DIR}/config/includes.chroot"
    mkdir -p "${includes}"

    # Copy desktop shell
    mkdir -p "${includes}/opt/nebula-desktop"
    cp -r "${NEBULA_ROOT}/desktop/"* "${includes}/opt/nebula-desktop/" 2>/dev/null || true

    # Copy themes
    mkdir -p "${includes}/usr/share/nebula-desktop/themes"
    cp -r "${NEBULA_ROOT}/themes/"* "${includes}/usr/share/nebula-desktop/themes/" 2>/dev/null || true

    # Copy AI assistant
    mkdir -p "${includes}/opt/nebula-ai"
    cp -r "${NEBULA_ROOT}/ai-assistant/"* "${includes}/opt/nebula-ai/" 2>/dev/null || true

    # Copy apps
    mkdir -p "${includes}/opt/nebula-apps"
    cp -r "${NEBULA_ROOT}/apps/"* "${includes}/opt/nebula-apps/" 2>/dev/null || true

    # Copy branding
    mkdir -p "${includes}/usr/share/pixmaps"
    mkdir -p "${includes}/usr/share/backgrounds/nebula"

    # Install session scripts
    mkdir -p "${includes}/usr/bin"

    cat > "${includes}/usr/bin/nebula-session" << 'SESSION'
#!/bin/bash
# NebulaOS Wayland Session Launcher
export XDG_SESSION_TYPE=wayland
export XDG_CURRENT_DESKTOP=NebulaOS
export QT_QPA_PLATFORM=wayland
export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
export MOZ_ENABLE_WAYLAND=1
export GDK_BACKEND=wayland

# Start PipeWire audio
pipewire &
pipewire-pulse &
wireplumber &

# Start the NebulaOS compositor and shell
if command -v nebula-shell &>/dev/null; then
    exec nebula-shell --wayland
else
    # Fallback to a basic Wayland compositor
    exec dbus-run-session labwc
fi
SESSION
    chmod +x "${includes}/usr/bin/nebula-session"

    cat > "${includes}/usr/bin/nebula-session-x11" << 'SESSION'
#!/bin/bash
# NebulaOS X11 Session Launcher (fallback)
export XDG_SESSION_TYPE=x11
export XDG_CURRENT_DESKTOP=NebulaOS
export QT_QPA_PLATFORM=xcb

# Start PipeWire audio
pipewire &
pipewire-pulse &
wireplumber &

# Start window manager
if command -v nebula-shell &>/dev/null; then
    exec nebula-shell --x11
else
    exec dbus-run-session openbox-session
fi
SESSION
    chmod +x "${includes}/usr/bin/nebula-session-x11"

    # OS release info
    mkdir -p "${includes}/etc"
    cat > "${includes}/etc/os-release" << RELEASE
NAME="${NEBULA_NAME}"
VERSION="${NEBULA_VERSION} (${NEBULA_CODENAME})"
ID=nebulaos
ID_LIKE=debian
VERSION_ID=${NEBULA_VERSION}
PRETTY_NAME="${NEBULA_NAME} ${NEBULA_VERSION} (${NEBULA_CODENAME})"
HOME_URL="https://github.com/nebulaos"
BUG_REPORT_URL="https://github.com/nebulaos/issues"
VERSION_CODENAME=${NEBULA_CODENAME}
RELEASE

    # NebulaOS LSB release
    mkdir -p "${includes}/etc/lsb-release.d"
    cat > "${includes}/etc/lsb_release" << LSB
DISTRIB_ID=NebulaOS
DISTRIB_RELEASE=${NEBULA_VERSION}
DISTRIB_CODENAME=${NEBULA_CODENAME}
DISTRIB_DESCRIPTION="${NEBULA_NAME} ${NEBULA_VERSION}"
LSB

    # Auto-start script
    mkdir -p "${includes}/etc/xdg/autostart"
    cat > "${includes}/etc/xdg/autostart/nebula-welcome.desktop" << DESKTOP
[Desktop Entry]
Type=Application
Name=NebulaOS Welcome
Exec=/opt/nebula-apps/welcome/welcome.py
Icon=nebula-welcome
Terminal=false
Categories=System;
StartupNotify=true
X-GNOME-Autostart-enabled=true
OnlyShowIn=NebulaOS;
DESKTOP

    ok "NebulaOS desktop files installed"
}

setup_grub_theme() {
    log "Setting up GRUB theme..."
    local includes="${NEBULA_BUILD_DIR}/config/includes.chroot"
    local grub_theme_dir="${includes}/boot/grub/themes/nebula"
    mkdir -p "$grub_theme_dir"

    cat > "${grub_theme_dir}/theme.txt" << 'THEME'
# NebulaOS GRUB Theme

# Global properties
title-text: ""
desktop-image: "background.png"
desktop-color: "#0a0a1a"
terminal-font: "DejaVu Sans Mono Regular 14"
terminal-left: "0"
terminal-top: "0"
terminal-width: "100%"
terminal-height: "100%"

# Boot menu
+ boot_menu {
    left = 30%
    top = 30%
    width = 40%
    height = 50%
    item_font = "DejaVu Sans Regular 16"
    item_color = "#cccccc"
    selected_item_font = "DejaVu Sans Bold 16"
    selected_item_color = "#ffffff"
    item_height = 40
    item_padding = 10
    item_spacing = 5
    selected_item_pixmap_style = "select_*.png"
    icon_width = 32
    icon_height = 32
    item_icon_space = 15
    scrollbar = true
    scrollbar_width = 4
    scrollbar_thumb = "scrollbar_thumb_*.png"
}

# Progress bar
+ progress_bar {
    id = "__timeout__"
    left = 30%
    top = 85%
    width = 40%
    height = 10
    show_text = true
    font = "DejaVu Sans Regular 12"
    text_color = "#ffffff"
    fg_color = "#4488ff"
    bg_color = "#1a1a2e"
    border_color = "#333355"
    text = "@TIMEOUT_NOTIFICATION_LONG@"
}

# Label
+ label {
    left = 30%
    top = 22%
    width = 40%
    align = "center"
    id = "__timeout__"
    text = "NebulaOS"
    font = "DejaVu Sans Bold 28"
    color = "#4488ff"
}
THEME

    ok "GRUB theme configured"
}

build_iso() {
    log "Starting ISO build..."
    cd "${NEBULA_BUILD_DIR}"

    set +e
    lb build 2>&1 | tee "${NEBULA_ROOT}/build.log"
    local build_rc=${PIPESTATUS[0]}
    set -e

    if [[ $build_rc -eq 0 ]]; then
        # Move ISO to output directory
        local iso_file=$(find "${NEBULA_BUILD_DIR}" -name "*.iso" -type f | head -1)
        if [[ -n "$iso_file" ]]; then
            cp "$iso_file" "${NEBULA_ISO_OUTPUT}/${NEBULA_ISO_NAME}"
            ok "ISO built successfully: ${NEBULA_ISO_OUTPUT}/${NEBULA_ISO_NAME}"

            # Generate checksums
            cd "${NEBULA_ISO_OUTPUT}"
            sha256sum "${NEBULA_ISO_NAME}" > "${NEBULA_ISO_NAME}.sha256"
            ok "Checksum generated"

            # Print ISO info
            local iso_size=$(du -h "${NEBULA_ISO_NAME}" | cut -f1)
            log "ISO size: ${iso_size}"
        else
            err "ISO file not found after build!"
            echo "=== Files in build dir ==="
            find "${NEBULA_BUILD_DIR}" -name "*.iso" -o -name "*.hybrid.iso" 2>/dev/null || true
            ls -la "${NEBULA_BUILD_DIR}/" || true
            exit 1
        fi
    else
        err "ISO build failed (exit code: $build_rc)! Check build.log for details."
        tail -50 "${NEBULA_ROOT}/build.log" || true
        exit 1
    fi
}

print_summary() {
    echo ""
    echo -e "${GREEN}============================================${NC}"
    echo -e "${GREEN}  NebulaOS Build Complete!${NC}"
    echo -e "${GREEN}============================================${NC}"
    echo ""
    echo "  ISO:      ${NEBULA_ISO_OUTPUT}/${NEBULA_ISO_NAME}"
    echo "  Checksum: ${NEBULA_ISO_OUTPUT}/${NEBULA_ISO_NAME}.sha256"
    echo "  Log:      ${NEBULA_ROOT}/build.log"
    echo ""
    echo "  To test in VirtualBox:"
    echo "    ./scripts/run-virtualbox.sh"
    echo ""
    echo "  To test in VMware:"
    echo "    ./scripts/run-vmware.sh"
    echo ""
}

# === Main ===
main() {
    banner
    check_root
    check_dependencies
    clean_build
    configure_live_build
    setup_package_lists
    setup_hooks
    install_nebula_desktop
    setup_grub_theme
    build_iso
    print_summary
}

# Parse arguments
case "${1:-build}" in
    build)
        main
        ;;
    clean)
        clean_build
        ok "Build cleaned"
        ;;
    config)
        check_root
        check_dependencies
        clean_build
        configure_live_build
        setup_package_lists
        setup_hooks
        install_nebula_desktop
        setup_grub_theme
        ok "Configuration complete. Run 'sudo ./build.sh build' to build."
        ;;
    *)
        echo "Usage: sudo ./build.sh [build|clean|config]"
        exit 1
        ;;
esac
