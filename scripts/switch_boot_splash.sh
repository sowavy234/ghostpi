#!/bin/bash
# Switch between Wavy's World boot splash themes
# Options: wavys-world (purple) or wavys-world-blackarch (red/black)

set -e

if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "  Boot Splash Theme Switcher"
echo "=========================================="
echo ""
echo "Available themes:"
echo "1. Wavy's World (Purple/Black - Default)"
echo "2. Wavy's World BlackArch Style (Red/Black)"
echo ""
read -p "Select theme (1 or 2): " choice

case $choice in
    1)
        THEME="wavys-world"
        THEME_NAME="Wavy's World"
        ;;
    2)
        THEME="wavys-world-blackarch"
        THEME_NAME="Wavy's World BlackArch Style"
        ;;
    *)
        echo "Invalid choice. Using default (Wavy's World)"
        THEME="wavys-world"
        THEME_NAME="Wavy's World"
        ;;
esac

echo ""
echo "Installing $THEME_NAME theme..."

# Copy theme files
mkdir -p /usr/share/plymouth/themes/$THEME
if [ -d "$PROJECT_ROOT/boot-splash" ]; then
    # Copy base files
    cp "$PROJECT_ROOT/boot-splash/$THEME.plymouth" /usr/share/plymouth/themes/$THEME/ 2>/dev/null || true
    cp "$PROJECT_ROOT/boot-splash/$THEME.script" /usr/share/plymouth/themes/$THEME/ 2>/dev/null || true
    
    # Copy image files (shared between themes)
    cp "$PROJECT_ROOT/boot-splash/"*.png /usr/share/plymouth/themes/$THEME/ 2>/dev/null || true
fi

# Set as default theme
update-alternatives --install /etc/alternatives/default.plymouth default.plymouth \
    /usr/share/plymouth/themes/$THEME/$THEME.plymouth 100 2>/dev/null || true

update-alternatives --set default.plymouth /usr/share/plymouth/themes/$THEME/$THEME.plymouth 2>/dev/null || true

# Update initramfs
echo "Updating initramfs..."
update-initramfs -u 2>/dev/null || true

echo ""
echo "=========================================="
echo "✓ Theme switched to: $THEME_NAME"
echo "=========================================="
echo ""
echo "Reboot to see the new boot splash:"
echo "  sudo reboot"
echo ""

