#!/bin/bash
# Build GhostPi + HackberryPi CM5 from base Raspberry Pi OS image
# This approach uses a base image and customizes it for full functionality
# Requires: Raspberry Pi OS Lite image (recommended)

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HACKBERRY_REPO="${HACKBERRY_REPO:-$HOME/Downloads/hackberrypicm5-main}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Downloads}"
BASE_IMAGE="${1:-}"
CM_TYPE="${2:-CM5}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     GhostPi + HackberryPi CM5 Custom Image Builder           ║"
echo "║     Building from base Raspberry Pi OS image                 ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Check for base image
if [ -z "$BASE_IMAGE" ]; then
    echo "Usage: $0 <base_raspberry_pi_os_image.img> [CM5|CM4]"
    echo ""
    echo "You can download Raspberry Pi OS from:"
    echo "  https://www.raspberrypi.com/software/operating-systems/"
    echo ""
    echo "Recommended: Raspberry Pi OS Lite (64-bit)"
    exit 1
fi

if [ ! -f "$BASE_IMAGE" ]; then
    echo "❌ Base image not found: $BASE_IMAGE"
    exit 1
fi

# Verify HackberryPi repo
if [ ! -d "$HACKBERRY_REPO" ]; then
    echo "⚠️  HackberryPi repo not found at: $HACKBERRY_REPO"
    echo "   Cloning from GitHub..."
    mkdir -p "$(dirname "$HACKBERRY_REPO")"
    git clone https://github.com/ZitaoTech/HackberryPiCM5.git "$HACKBERRY_REPO" || {
        echo "❌ Failed to clone HackberryPi repo"
        exit 1
    }
fi

# Install dependencies
echo "📦 Installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq
apt-get install -y \
    kpartx \
    qemu-user-static \
    binfmt-support \
    dosfstools \
    parted \
    device-tree-compiler \
    xinput-calibrator \
    >/dev/null 2>&1

# Create working copy of base image
WORK_IMAGE="$OUTPUT_DIR/ghostpi-work-${TIMESTAMP}.img"
echo "📋 Creating working copy of base image..."
cp "$BASE_IMAGE" "$WORK_IMAGE"
chmod 666 "$WORK_IMAGE"

# Get loop device
echo "🔗 Setting up loop device..."
LOOP_DEV=$(losetup -fP --show "$WORK_IMAGE")
BOOT_PART="${LOOP_DEV}p1"
ROOTFS_PART="${LOOP_DEV}p2"

# Wait for partitions to be available
sleep 2

# Mount partitions
MOUNT_DIR="/tmp/ghostpi-mount-$$"
BOOT_DIR="$MOUNT_DIR/boot"
ROOTFS_DIR="$MOUNT_DIR/rootfs"
mkdir -p "$BOOT_DIR" "$ROOTFS_DIR"

echo "📂 Mounting partitions..."
mount "$BOOT_PART" "$BOOT_DIR"
mount "$ROOTFS_PART" "$ROOTFS_DIR"

# Copy qemu for chroot
if [ -f /usr/bin/qemu-aarch64-static ]; then
    cp /usr/bin/qemu-aarch64-static "$ROOTFS_DIR/usr/bin/"
fi

# Copy HyperPixel dtbo files
echo "📱 Installing HyperPixel display drivers..."
HACKBERRY_DTBO_DIR="$HACKBERRY_REPO/Operating System"
if [ -d "$HACKBERRY_DTBO_DIR" ]; then
    mkdir -p "$BOOT_DIR/overlays"
    if [ -f "$HACKBERRY_DTBO_DIR/vc4-kms-dpi-hyperpixel4sq.dtbo" ]; then
        cp "$HACKBERRY_DTBO_DIR/vc4-kms-dpi-hyperpixel4sq.dtbo" "$BOOT_DIR/overlays/"
        echo "  ✓ Copied vc4-kms-dpi-hyperpixel4sq.dtbo"
    fi
    if [ -f "$HACKBERRY_DTBO_DIR/hyperpixel4.dtbo" ]; then
        cp "$HACKBERRY_DTBO_DIR/hyperpixel4.dtbo" "$BOOT_DIR/overlays/"
        echo "  ✓ Copied hyperpixel4.dtbo"
    fi
fi

# Also check Downloads
if [ -f "$HOME/Downloads/vc4-kms-dpi-hyperpixel4sq.dtbo" ]; then
    cp "$HOME/Downloads/vc4-kms-dpi-hyperpixel4sq.dtbo" "$BOOT_DIR/overlays/" 2>/dev/null || true
fi

# Configure config.txt for HyperPixel
echo "⚙️  Configuring boot settings..."
if [ -f "$BOOT_DIR/config.txt" ]; then
    # Backup original
    cp "$BOOT_DIR/config.txt" "$BOOT_DIR/config.txt.original"
    
    # Add HyperPixel configuration if not present
    if ! grep -q "vc4-kms-dpi-hyperpixel4sq" "$BOOT_DIR/config.txt"; then
        cat >> "$BOOT_DIR/config.txt" <<'CONFIG'

# HackberryPi CM5 HyperPixel Display Configuration
# 4" 720x720 TFT Touch Display
# Based on: https://github.com/ZitaoTech/HackberryPiCM5
dtoverlay=vc4-kms-v3d
dtoverlay=vc4-kms-dpi-hyperpixel4sq
framebuffer_width=720
framebuffer_height=720
display_rotate=0
CONFIG
        echo "  ✓ Added HyperPixel configuration"
    fi
fi

# Create installation script to run in chroot
echo "📜 Creating installation script..."
cat > "$ROOTFS_DIR/tmp/install-ghostpi.sh" <<'INSTALL'
#!/bin/bash
set -e

export DEBIAN_FRONTEND=noninteractive

# Update system
apt-get update -qq

# Install dependencies (git is critical for auto-update)
apt-get install -y -qq \
    plymouth plymouth-themes \
    device-tree-compiler \
    xinput-calibrator \
    git \
    >/dev/null 2>&1

# Create directories (critical for auto-update)
mkdir -p /opt/ghostpi/{repo,backups,updates}
mkdir -p /var/lib/ghostpi
mkdir -p /var/log
mkdir -p /etc/X11/xorg.conf.d
mkdir -p /etc/udev/rules.d

# Copy all GhostPi files (will be done from host)
# This script will be run in chroot after files are copied

exit 0
INSTALL

chmod +x "$ROOTFS_DIR/tmp/install-ghostpi.sh"

# Copy all GhostPi files to rootfs
echo "📦 Copying GhostPi files..."
if [ -d "$PROJECT_ROOT/boot-splash" ]; then
    mkdir -p "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world"
    cp -r "$PROJECT_ROOT/boot-splash/"* "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world/" 2>/dev/null || true
    
    mkdir -p "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world-blackarch"
    cp "$PROJECT_ROOT/boot-splash/wavys-world-blackarch.plymouth" "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world-blackarch/" 2>/dev/null || true
    cp "$PROJECT_ROOT/boot-splash/wavys-world-blackarch.script" "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world-blackarch/" 2>/dev/null || true
fi

# Copy services
if [ -d "$PROJECT_ROOT/services" ]; then
    mkdir -p "$ROOTFS_DIR/etc/systemd/system"
    cp "$PROJECT_ROOT/services/"*.service "$ROOTFS_DIR/etc/systemd/system/" 2>/dev/null || true
    cp "$PROJECT_ROOT/services/"*.timer "$ROOTFS_DIR/etc/systemd/system/" 2>/dev/null || true
    cp "$PROJECT_ROOT/services/"*.sh "$ROOTFS_DIR/usr/local/bin/" 2>/dev/null || true
    chmod +x "$ROOTFS_DIR/usr/local/bin/"*.sh 2>/dev/null || true
fi

# Copy bots
if [ -d "$PROJECT_ROOT/bots" ]; then
    find "$PROJECT_ROOT/bots" -name "*.sh" -exec cp {} "$ROOTFS_DIR/usr/local/bin/" \; 2>/dev/null || true
fi

# Copy HackberryPi CM5 scripts
if [ -d "$PROJECT_ROOT/hackberry-cm5" ]; then
    cp "$PROJECT_ROOT/hackberry-cm5/"*.sh "$ROOTFS_DIR/usr/local/bin/" 2>/dev/null || true
    chmod +x "$ROOTFS_DIR/usr/local/bin/"*.sh 2>/dev/null || true
fi

# Copy scripts
if [ -d "$PROJECT_ROOT/scripts" ]; then
    find "$PROJECT_ROOT/scripts" -name "*.sh" -exec cp {} "$ROOTFS_DIR/usr/local/bin/" \; 2>/dev/null || true
    chmod +x "$ROOTFS_DIR/usr/local/bin/"*.sh 2>/dev/null || true
fi

# Copy terminal and AI companion
cp "$PROJECT_ROOT/terminal/wavy-terminal.sh" "$ROOTFS_DIR/usr/local/bin/" 2>/dev/null || true
cp "$PROJECT_ROOT/ai-companion/wavy-ai-companion.sh" "$ROOTFS_DIR/usr/local/bin/" 2>/dev/null || true
chmod +x "$ROOTFS_DIR/usr/local/bin/wavy-terminal.sh" 2>/dev/null || true
chmod +x "$ROOTFS_DIR/usr/local/bin/wavy-ai-companion.sh" 2>/dev/null || true

# Create touchscreen configuration
cat > "$ROOTFS_DIR/etc/X11/xorg.conf.d/99-hackberry-touchscreen.conf" <<'XORG'
Section "InputClass"
    Identifier "HackberryPi CM5 Touchscreen"
    MatchIsTouchscreen "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "CalibrationMatrix" "1 0 0 0 1 0 0 0 1"
    Option "TransformationMatrix" "1 0 0 0 1 0 0 0 1"
    Option "Tapping" "on"
    Option "TappingDrag" "on"
    Option "AccelProfile" "flat"
    Option "AccelSpeed" "0.5"
EndSection
XORG

cat > "$ROOTFS_DIR/etc/udev/rules.d/99-hackberry-touchscreen.rules" <<'UDEV'
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="*touchscreen*", SYMLINK+="input/touchscreen"
UDEV

# Create first-boot script
cat > "$ROOTFS_DIR/usr/local/bin/ghostpi-first-boot.sh" <<'FIRSTBOOT'
#!/bin/bash
FIRST_BOOT_FLAG="/var/lib/ghostpi/first-boot-complete"
[ -f "$FIRST_BOOT_FLAG" ] && exit 0
mkdir -p "$(dirname "$FIRST_BOOT_FLAG")"

# Create log file
mkdir -p /var/log
echo "$(date): GhostPi first boot setup starting" >> /var/log/ghostpi-first-boot.log

# Update system
apt-get update -qq >/dev/null 2>&1

# Install git if needed (for auto-update)
apt-get install -y git >/dev/null 2>&1 || true

# Set boot splash
if [ -d "/usr/share/plymouth/themes/wavys-world" ]; then
    update-alternatives --install /etc/alternatives/default.plymouth default.plymouth \
        /usr/share/plymouth/themes/wavys-world/wavys-world.plymouth 100 2>/dev/null || true
    update-alternatives --set default.plymouth /usr/share/plymouth/themes/wavys-world/wavys-world.plymouth 2>/dev/null || true
fi

# Create directories for auto-update
mkdir -p /opt/ghostpi/{updates,backups,repo}
mkdir -p /var/log

# Enable services
systemctl daemon-reload

# Enable and start swapfile service
systemctl enable swapfile-manager-2025.service 2>/dev/null || systemctl enable swapfile-manager.service 2>/dev/null || true
systemctl start swapfile-manager-2025.service 2>/dev/null || systemctl start swapfile-manager.service 2>/dev/null || true

# Enable and start bot service
systemctl enable ghostpi-bot-2025.service 2>/dev/null || systemctl enable ghostpi-bot.service 2>/dev/null || true
systemctl start ghostpi-bot-2025.service 2>/dev/null || systemctl start ghostpi-bot.service 2>/dev/null || true

# Enable and start self-healing service
systemctl enable self-healing-2025.service 2>/dev/null || systemctl enable self-healing.service 2>/dev/null || true
systemctl start self-healing-2025.service 2>/dev/null || systemctl start self-healing.service 2>/dev/null || true

# Enable and start auto-update timer (critical!)
systemctl enable auto-update.timer 2>/dev/null || true
systemctl start auto-update.timer 2>/dev/null || true

# Enable HackberryPi CM5 services
systemctl enable hackberry-cm5.service 2>/dev/null || true
systemctl start hackberry-cm5.service 2>/dev/null || true
systemctl enable battery-monitor.service 2>/dev/null || true
systemctl start battery-monitor.service 2>/dev/null || true

# Configure touchscreen
if [ -f "/usr/local/bin/touchscreen-config.sh" ]; then
    /usr/local/bin/touchscreen-config.sh install 2>/dev/null || true
fi

# Update initramfs
update-initramfs -u 2>/dev/null || true

# Mark first boot as complete
touch "$FIRST_BOOT_FLAG"
echo "$(date): GhostPi first boot setup complete" >> /var/log/ghostpi-first-boot.log
FIRSTBOOT

chmod +x "$ROOTFS_DIR/usr/local/bin/ghostpi-first-boot.sh"

# Create first-boot service
cat > "$ROOTFS_DIR/etc/systemd/system/ghostpi-first-boot.service" <<'FIRSTBOOTSVC'
[Unit]
Description=GhostPi First Boot Setup
After=network-online.target
Wants=network-online.target

[Service]
Type=oneshot
ExecStart=/usr/local/bin/ghostpi-first-boot.sh
RemainAfterExit=yes

[Install]
WantedBy=multi-user.target
FIRSTBOOTSVC

mkdir -p "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants"
ln -sf /etc/systemd/system/ghostpi-first-boot.service "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/"

# Mount virtual filesystems required for chroot (apt-get needs these)
echo "🔧 Mounting virtual filesystems for chroot..."
mount --bind /dev "$ROOTFS_DIR/dev"
mount --bind /proc "$ROOTFS_DIR/proc"
mount --bind /sys "$ROOTFS_DIR/sys"
mount --bind /dev/pts "$ROOTFS_DIR/dev/pts" 2>/dev/null || true

# Run installation in chroot
echo "🔧 Running installation in chroot..."
if chroot "$ROOTFS_DIR" /tmp/install-ghostpi.sh; then
    echo "  ✓ Installation completed successfully"
else
    echo "  ❌ Installation failed in chroot"
    echo "  Cleaning up resources..."
    
    # Unmount virtual filesystems
    umount "$ROOTFS_DIR/dev/pts" 2>/dev/null || true
    umount "$ROOTFS_DIR/sys" 2>/dev/null || true
    umount "$ROOTFS_DIR/proc" 2>/dev/null || true
    umount "$ROOTFS_DIR/dev" 2>/dev/null || true
    
    # Unmount partitions
    umount "$BOOT_DIR" 2>/dev/null || true
    umount "$ROOTFS_DIR" 2>/dev/null || true
    
    # Detach loop device
    losetup -d "$LOOP_DEV" 2>/dev/null || true
    
    # Clean up working image file
    rm -f "$WORK_IMAGE" 2>/dev/null || true
    
    exit 1
fi

# Unmount virtual filesystems
echo "🔓 Unmounting virtual filesystems..."
umount "$ROOTFS_DIR/dev/pts" 2>/dev/null || true
umount "$ROOTFS_DIR/sys" 2>/dev/null || true
umount "$ROOTFS_DIR/proc" 2>/dev/null || true
umount "$ROOTFS_DIR/dev" 2>/dev/null || true

# Cleanup
rm -f "$ROOTFS_DIR/tmp/install-ghostpi.sh"
rm -f "$ROOTFS_DIR/usr/bin/qemu-aarch64-static" 2>/dev/null || true

# Unmount partitions (ensure virtual filesystems are already unmounted)
echo "🔓 Unmounting partitions..."
umount "$BOOT_DIR" 2>/dev/null || true
umount "$ROOTFS_DIR" 2>/dev/null || true
losetup -d "$LOOP_DEV" 2>/dev/null || true

# Rename final image
FINAL_IMAGE="$OUTPUT_DIR/GhostPi-HackberryPi-${CM_TYPE}-${TIMESTAMP}.img"
mv "$WORK_IMAGE" "$FINAL_IMAGE"

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     ✓ GhostPi + HackberryPi CM5 image created!              ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "📦 Image: $FINAL_IMAGE"
echo "💾 To flash: sudo dd if=\"$FINAL_IMAGE\" of=/dev/sdX bs=4M status=progress"
echo ""
echo "🎮 Features:"
echo "   ✓ HyperPixel 720x720 display"
echo "   ✓ Touchscreen configured"
echo "   ✓ All services enabled"
echo "   ✓ Boot splash themes"
echo ""

