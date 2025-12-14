#!/bin/bash
# Quick install script for existing Raspberry Pi OS
# Adds GhostPi boot splash, swapfile service, and pentesting tools

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "  GhostPi Quick Installer"
echo "  Welcome to Wavy's World"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Detect hardware
if [ -f "$SCRIPT_DIR/../HackberryPi5/distro-build/scripts/detect_hardware.sh" ]; then
    source "$SCRIPT_DIR/../HackberryPi5/distro-build/scripts/detect_hardware.sh" 2>/dev/null || true
    CM_TYPE=$(detect_compute_module 2>/dev/null || echo "CM5")
else
    CM_TYPE="CM5"
fi

echo "Detected: $CM_TYPE"

# Update system
echo "Updating system..."
apt-get update -qq
apt-get upgrade -y -qq

# Install dependencies
echo "Installing dependencies..."
apt-get install -y \
    plymouth plymouth-themes \
    device-tree-compiler \
    imagemagick \
    >/dev/null 2>&1

# Install boot splash
echo "Installing boot splash..."
mkdir -p /usr/share/plymouth/themes/wavys-world
if [ -d "$PROJECT_ROOT/boot-splash" ]; then
    cp -r "$PROJECT_ROOT/boot-splash/"* /usr/share/plymouth/themes/wavys-world/ 2>/dev/null || true
fi

# Set as default theme
update-alternatives --install /etc/alternatives/default.plymouth default.plymouth \
    /usr/share/plymouth/themes/wavys-world/wavys-world.plymouth 100 2>/dev/null || true

# Install swapfile service
echo "Installing swapfile service..."
if [ -f "$PROJECT_ROOT/services/swapfile-manager.service" ]; then
    cp "$PROJECT_ROOT/services/swapfile-manager.service" /etc/systemd/system/
    systemctl daemon-reload
    systemctl enable swapfile-manager
    systemctl start swapfile-manager
fi

if [ -f "$PROJECT_ROOT/services/swapfile-manager.sh" ]; then
    cp "$PROJECT_ROOT/services/swapfile-manager.sh" /usr/local/bin/
    chmod +x /usr/local/bin/swapfile-manager.sh
fi

# Install auto-update and self-healing services
echo "Installing auto-update and self-healing services..."
if [ -f "$PROJECT_ROOT/scripts/install_auto_update.sh" ]; then
    "$PROJECT_ROOT/scripts/install_auto_update.sh"
fi

# Install automated monitoring bot
echo "Installing automated monitoring bot..."
if [ -f "$PROJECT_ROOT/scripts/install_bot.sh" ]; then
    "$PROJECT_ROOT/scripts/install_bot.sh"
fi

# Update initramfs
echo "Updating initramfs..."
update-initramfs -u 2>/dev/null || true

echo ""
echo "=========================================="
echo "Installation complete!"
echo "=========================================="
echo ""
echo "Reboot to see the boot splash:"
echo "  sudo reboot"
echo ""

