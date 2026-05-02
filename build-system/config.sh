#!/bin/bash
# NebulaOS Build Configuration v1.1 (Aurora)
# Central configuration for the entire build system

export NEBULA_NAME="NebulaOS"
export NEBULA_VERSION="1.1"
export NEBULA_CODENAME="aurora"
export NEBULA_ARCH="amd64"
export NEBULA_ISO_NAME="NebulaOS-v1.1-Aurora.iso"
export NEBULA_ISO_LABEL="NebulaOS_v1.1"

# Base distribution
export NEBULA_BASE="debian"
export NEBULA_SUITE="bookworm"
export NEBULA_MIRROR="http://deb.debian.org/debian"

# Build paths
export NEBULA_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
export NEBULA_BUILD_DIR="${NEBULA_ROOT}/build"
export NEBULA_ISO_OUTPUT="${NEBULA_ROOT}/iso-output"
export NEBULA_CACHE_DIR="${NEBULA_ROOT}/.cache"

# Desktop configuration
export NEBULA_SHELL_DIR="${NEBULA_ROOT}/desktop/shell"
export NEBULA_THEME_DIR="${NEBULA_ROOT}/themes"
export NEBULA_APPS_DIR="${NEBULA_ROOT}/apps"

# System configuration
export NEBULA_HOSTNAME="nebulaos"
export NEBULA_DEFAULT_USER="nebula"
export NEBULA_DEFAULT_LOCALE="en_US.UTF-8"
export NEBULA_DEFAULT_TIMEZONE="UTC"

# Performance targets
export NEBULA_TARGET_RAM_MB=2048
export NEBULA_TARGET_DISK_GB=15
export NEBULA_TARGET_BOOT_SEC=15

# Display configuration
export NEBULA_DISPLAY_SERVER="wayland"  # wayland or x11
export NEBULA_COMPOSITOR="nebula-compositor"
export NEBULA_SESSION_NAME="nebula-desktop"

# Build options
export NEBULA_INCLUDE_DEV_TOOLS=true
export NEBULA_INCLUDE_AI_ASSISTANT=true
export NEBULA_INCLUDE_FLATPAK=true
export NEBULA_INCLUDE_VM_TOOLS=true
export NEBULA_COMPRESSION="xz"  # xz, gzip, or lz4
