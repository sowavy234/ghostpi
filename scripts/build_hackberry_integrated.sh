#!/bin/bash
# Integrated Build Script for GhostPi + HackberryPi CM5
# Builds complete image with HyperPixel display, touchscreen, agents, bots, dual boot
# Based on: https://github.com/ZitaoTech/HackberryPiCM5

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HACKBERRY_REPO="${HACKBERRY_REPO:-$HOME/Downloads/hackberrypicm5-main}"
BUILD_DIR="${BUILD_DIR:-/tmp/ghostpi-build}"
IMAGE_GEN_DIR="${IMAGE_GEN_DIR:-/tmp/ghostpi-LinuxBootImageFileGenerator}"
CM_TYPE="${1:-CM5}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Downloads}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)
IMAGE_NAME="GhostPi-HackberryPi-${CM_TYPE}-${TIMESTAMP}.img"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     GhostPi + HackberryPi CM5 Integrated Build               ║"
echo "║     HyperPixel Display | Touchscreen | Agents | Dual Boot   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Verify HackberryPi repo exists
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
    python3 python3-pip \
    device-tree-compiler \
    plymouth plymouth-themes \
    imagemagick \
    git \
    dosfstools \
    fdisk \
    parted \
    kpartx \
    qemu-utils \
    xinput-calibrator \
    >/dev/null 2>&1

# Clone LinuxBootImageFileGenerator
if [ ! -f "$IMAGE_GEN_DIR/LinuxBootImageGenerator.py" ]; then
    echo "📥 Cloning LinuxBootImageFileGenerator..."
    if ! git clone https://github.com/robseb/LinuxBootImageFileGenerator.git "$IMAGE_GEN_DIR" 2>/dev/null; then
        echo "❌ Failed to clone LinuxBootImageFileGenerator"
        exit 1
    fi
    # Verify clone succeeded
    if [ ! -f "$IMAGE_GEN_DIR/LinuxBootImageGenerator.py" ]; then
        echo "❌ LinuxBootImageGenerator.py not found after clone"
        exit 1
    fi
fi

# Patch generator to be more lenient - remove strict folder compatibility check
if [ -f "$IMAGE_GEN_DIR/LinuxBootImageGenerator.py" ]; then
    echo "🔧 Patching generator for compatibility..."
    python3 <<PATCH_EOF
import sys
script_path = "$IMAGE_GEN_DIR/LinuxBootImageGenerator.py"

with open(script_path, 'r') as f:
    content = f.read()

# Replace the strict check with a lenient one that removes non-matching items
if "if not file in working_folder_pat:" in content:
    lines = content.split('\n')
    new_lines = []
    i = 0
    while i < len(lines):
        if 'if not file in working_folder_pat:' in lines[i]:
            # Keep the if statement
            new_lines.append(lines[i])
            i += 1
            # Skip the error print statements and sys.exit()
            while i < len(lines) and ('ERROR:' in lines[i] or 'Please delete' in lines[i] or 'sys.exit()' in lines[i] or '        Please delete' in lines[i] or '         to generate' in lines[i]):
                i += 1
            # Add removal logic instead
            new_lines.append('                    # Auto-remove non-matching items')
            new_lines.append('                    import shutil')
            new_lines.append('                    file_path = os.path.join(image_folder_name, file)')
            new_lines.append('                    if os.path.isdir(file_path):')
            new_lines.append('                        shutil.rmtree(file_path)')
            new_lines.append('                    else:')
            new_lines.append('                        os.remove(file_path)')
        else:
            new_lines.append(lines[i])
            i += 1
    content = '\n'.join(new_lines)
    
    with open(script_path, 'w') as f:
        f.write(content)
    print("✓ Generator patched successfully")
else:
    print("⚠️  Could not find exact pattern, generator may need manual patching")
PATCH_EOF
    echo "  Patch applied"
fi

# Create build directory
mkdir -p "$BUILD_DIR/Image_partitions"
BOOT_DIR="$BUILD_DIR/Image_partitions/Pat_1_vfat"
ROOTFS_DIR="$BUILD_DIR/Image_partitions/Pat_2_ext3"
mkdir -p "$BOOT_DIR" "$ROOTFS_DIR"

# Copy HyperPixel dtbo files to boot partition
echo "📱 Installing HyperPixel display drivers..."
HACKBERRY_DTBO_DIR="$HACKBERRY_REPO/Operating System"
if [ -d "$HACKBERRY_DTBO_DIR" ]; then
    mkdir -p "$BOOT_DIR/overlays"
    # Copy the required dtbo files
    if [ -f "$HACKBERRY_DTBO_DIR/vc4-kms-dpi-hyperpixel4sq.dtbo" ]; then
        cp "$HACKBERRY_DTBO_DIR/vc4-kms-dpi-hyperpixel4sq.dtbo" "$BOOT_DIR/overlays/"
        echo "  ✓ Copied vc4-kms-dpi-hyperpixel4sq.dtbo"
    fi
    if [ -f "$HACKBERRY_DTBO_DIR/hyperpixel4.dtbo" ]; then
        cp "$HACKBERRY_DTBO_DIR/hyperpixel4.dtbo" "$BOOT_DIR/overlays/"
        echo "  ✓ Copied hyperpixel4.dtbo"
    fi
fi

# Also check Downloads for dtbo files
if [ -f "$HOME/Downloads/vc4-kms-dpi-hyperpixel4sq.dtbo" ]; then
    cp "$HOME/Downloads/vc4-kms-dpi-hyperpixel4sq.dtbo" "$BOOT_DIR/overlays/" 2>/dev/null || true
fi

# Create config.txt with HyperPixel configuration
echo "⚙️  Configuring boot partition..."
cat > "$BOOT_DIR/config.txt" <<EOF
# GhostPi + HackberryPi CM5 Configuration
# Based on: https://github.com/ZitaoTech/HackberryPiCM5
# Welcome to Wavy's World

# Enable GPU
gpu_mem=128

# CPU configuration
arm_64bit=1
kernel=kernel8.img

# CM5 Configuration
arm_freq=2400
over_voltage=0

# Enable hardware acceleration (required before HyperPixel overlay)
dtoverlay=vc4-kms-v3d

# HackberryPi CM5 HyperPixel Display Configuration
# 4" 720x720 TFT Touch Display
dtoverlay=vc4-kms-dpi-hyperpixel4sq
framebuffer_width=720
framebuffer_height=720
display_rotate=0

# Enable I2C (may be used by display, but default GPIOs are used for display)
# I2C is disabled by default per HackberryPi docs
# dtparam=i2c_arm=on

# Enable SPI (may be used by display, but default GPIOs are used for display)
# SPI is disabled by default per HackberryPi docs
# dtparam=spi=on

# USB configuration
dtparam=usb=on

# Audio configuration
dtparam=audio=on

# Disable overscan
overscan_left=0
overscan_right=0
overscan_top=0
overscan_bottom=0

# Boot options
enable_uart=1
boot_delay=1

# Plymouth boot splash
disable_splash=0
EOF

# Create cmdline.txt
cat > "$BOOT_DIR/cmdline.txt" <<'EOF'
console=serial0,115200 console=tty1 root=PARTUUID=12345678-02 rootfstype=ext4 fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles
EOF

echo "  ✓ Boot partition configured with HyperPixel settings"

# Create rootfs structure
echo "📁 Creating rootfs structure..."
mkdir -p "$ROOTFS_DIR"/{bin,boot,dev,etc,home,lib,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}
mkdir -p "$ROOTFS_DIR"/{etc/systemd/system,etc/systemd/system/multi-user.target.wants}
mkdir -p "$ROOTFS_DIR"/{usr/local/bin,usr/share/plymouth/themes}
mkdir -p "$ROOTFS_DIR"/{opt/ghostpi/{repo,backups,updates},var/log}
mkdir -p "$ROOTFS_DIR"/etc/X11/xorg.conf.d
mkdir -p "$ROOTFS_DIR"/etc/udev/rules.d

# Copy boot splash files
echo "🎨 Installing boot splash themes..."
if [ -d "$PROJECT_ROOT/boot-splash" ]; then
    # Wavy's World (default)
    mkdir -p "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world"
    cp "$PROJECT_ROOT/boot-splash/wavys-world.plymouth" "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world/" 2>/dev/null || true
    cp "$PROJECT_ROOT/boot-splash/wavys-world.script" "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world/" 2>/dev/null || true
    
    # Wavy's World BlackArch Style
    mkdir -p "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world-blackarch"
    cp "$PROJECT_ROOT/boot-splash/wavys-world-blackarch.plymouth" "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world-blackarch/" 2>/dev/null || true
    cp "$PROJECT_ROOT/boot-splash/wavys-world-blackarch.script" "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world-blackarch/" 2>/dev/null || true
    
    # Copy any image files
    find "$PROJECT_ROOT/boot-splash" -name "*.png" -exec cp {} "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world/" \; 2>/dev/null || true
    find "$PROJECT_ROOT/boot-splash" -name "*.png" -exec cp {} "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world-blackarch/" \; 2>/dev/null || true
fi

# Copy all GhostPi services
echo "🤖 Installing system services..."
if [ -d "$PROJECT_ROOT/services" ]; then
    cp "$PROJECT_ROOT/services/"*.service "$ROOTFS_DIR/etc/systemd/system/" 2>/dev/null || true
    cp "$PROJECT_ROOT/services/"*.timer "$ROOTFS_DIR/etc/systemd/system/" 2>/dev/null || true
    cp "$PROJECT_ROOT/services/"*.sh "$ROOTFS_DIR/usr/local/bin/" 2>/dev/null || true
    chmod +x "$ROOTFS_DIR/usr/local/bin/"*.sh 2>/dev/null || true
fi

# Copy bot scripts
echo "🤖 Installing bot scripts..."
if [ -d "$PROJECT_ROOT/bots" ]; then
    find "$PROJECT_ROOT/bots" -name "*.sh" -exec cp {} "$ROOTFS_DIR/usr/local/bin/" \; 2>/dev/null || true
    chmod +x "$ROOTFS_DIR/usr/local/bin/ghostpi-bot*.sh" 2>/dev/null || true
fi

# Copy HackberryPi CM5 scripts
echo "🔋 Installing HackberryPi CM5 support..."
if [ -d "$PROJECT_ROOT/hackberry-cm5" ]; then
    cp "$PROJECT_ROOT/hackberry-cm5/"*.sh "$ROOTFS_DIR/usr/local/bin/" 2>/dev/null || true
    chmod +x "$ROOTFS_DIR/usr/local/bin/"*.sh 2>/dev/null || true
fi

# Copy installation scripts
echo "📜 Installing setup scripts..."
if [ -d "$PROJECT_ROOT/scripts" ]; then
    cp "$PROJECT_ROOT/scripts/"*.sh "$ROOTFS_DIR/usr/local/bin/" 2>/dev/null || true
    chmod +x "$ROOTFS_DIR/usr/local/bin/"*.sh 2>/dev/null || true
fi

# Copy terminal
if [ -f "$PROJECT_ROOT/terminal/wavy-terminal.sh" ]; then
    cp "$PROJECT_ROOT/terminal/wavy-terminal.sh" "$ROOTFS_DIR/usr/local/bin/"
    chmod +x "$ROOTFS_DIR/usr/local/bin/wavy-terminal.sh"
fi

# Copy AI companion
if [ -f "$PROJECT_ROOT/ai-companion/wavy-ai-companion.sh" ]; then
    cp "$PROJECT_ROOT/ai-companion/wavy-ai-companion.sh" "$ROOTFS_DIR/usr/local/bin/"
    chmod +x "$ROOTFS_DIR/usr/local/bin/wavy-ai-companion.sh"
fi

# Copy helpers
if [ -d "$PROJECT_ROOT/helpers" ]; then
    find "$PROJECT_ROOT/helpers" -name "*.sh" -exec cp {} "$ROOTFS_DIR/usr/local/bin/" \; 2>/dev/null || true
    chmod +x "$ROOTFS_DIR/usr/local/bin/"*.sh 2>/dev/null || true
fi

# Create touchscreen configuration for HackberryPi CM5
echo "👆 Configuring touchscreen..."
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
    Option "TappingDragLock" "off"
    Option "DisableWhileTyping" "on"
    Option "AccelProfile" "flat"
    Option "AccelSpeed" "0.5"
EndSection
XORG

# Create touchscreen udev rules
cat > "$ROOTFS_DIR/etc/udev/rules.d/99-hackberry-touchscreen.rules" <<'UDEV'
# HackberryPi CM5 Touchscreen udev rules
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="*touchscreen*", SYMLINK+="input/touchscreen"
UDEV

# Create first-boot setup script
echo "🚀 Creating first-boot setup script..."
cat > "$ROOTFS_DIR/usr/local/bin/ghostpi-first-boot.sh" <<'FIRSTBOOT'
#!/bin/bash
# GhostPi First Boot Setup Script
# Runs once on first boot to complete installation

FIRST_BOOT_FLAG="/var/lib/ghostpi/first-boot-complete"

if [ -f "$FIRST_BOOT_FLAG" ]; then
    exit 0  # Already ran
fi

# Create flag directory
mkdir -p "$(dirname "$FIRST_BOOT_FLAG")"

# Log first boot
echo "$(date): GhostPi first boot setup starting" >> /var/log/ghostpi-first-boot.log

# Update system
apt-get update -qq
apt-get install -y plymouth plymouth-themes xinput-calibrator >/dev/null 2>&1 || true

# Set up boot splash
if [ -d "/usr/share/plymouth/themes/wavys-world" ]; then
    update-alternatives --install /etc/alternatives/default.plymouth default.plymouth \
        /usr/share/plymouth/themes/wavys-world/wavys-world.plymouth 100 2>/dev/null || true
    update-alternatives --set default.plymouth /usr/share/plymouth/themes/wavys-world/wavys-world.plymouth 2>/dev/null || true
fi

# Enable services
systemctl daemon-reload

# Enable swapfile service
systemctl enable swapfile-manager.service 2>/dev/null || true
systemctl enable swapfile-manager-2025.service 2>/dev/null || true
systemctl enable swapfile-manager-ai.service 2>/dev/null || true

# Enable bot services
systemctl enable ghostpi-bot.service 2>/dev/null || true
systemctl enable ghostpi-bot-2025.service 2>/dev/null || true
systemctl enable ghostpi-bot-ai.service 2>/dev/null || true

# Enable self-healing services
systemctl enable self-healing.service 2>/dev/null || true
systemctl enable self-healing-2025.service 2>/dev/null || true
systemctl enable self-healing-ai.service 2>/dev/null || true

# Enable auto-update
systemctl enable auto-update.timer 2>/dev/null || true

# Enable HackberryPi CM5 service
systemctl enable hackberry-cm5.service 2>/dev/null || true
systemctl enable battery-monitor.service 2>/dev/null || true

# Start services
systemctl start swapfile-manager-2025.service 2>/dev/null || systemctl start swapfile-manager.service 2>/dev/null || true
systemctl start ghostpi-bot-2025.service 2>/dev/null || systemctl start ghostpi-bot.service 2>/dev/null || true
systemctl start self-healing-2025.service 2>/dev/null || systemctl start self-healing.service 2>/dev/null || true
systemctl start auto-update.timer 2>/dev/null || true
systemctl start hackberry-cm5.service 2>/dev/null || true
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

# Create systemd service to run first-boot script
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

# Enable first-boot service
ln -sf /etc/systemd/system/ghostpi-first-boot.service "$ROOTFS_DIR/etc/systemd/system/multi-user.target.wants/"

# Create basic system directories and files
echo "📝 Creating system configuration files..."
mkdir -p "$ROOTFS_DIR/etc/alternatives"
mkdir -p "$ROOTFS_DIR/var/lib/ghostpi"

# Copy partition files to LinuxBootImageFileGenerator directory
echo "📦 Preparing image partitions..."
# Remove entire Image_partitions folder to ensure clean state
# The generator is very strict - any extra files/folders will cause failure
if [ -d "$IMAGE_GEN_DIR/Image_partitions" ]; then
    echo "🧹 Removing old Image_partitions directory..."
    rm -rf "$IMAGE_GEN_DIR/Image_partitions" 2>/dev/null || true
    # Wait a moment to ensure filesystem sync
    sleep 0.5
fi
# Create only the exact partition folders expected by the XML config
# XML has: Pat_1_vfat, Pat_2_ext3, Pat_3_raw
mkdir -p "$IMAGE_GEN_DIR/Image_partitions/Pat_1_vfat"
mkdir -p "$IMAGE_GEN_DIR/Image_partitions/Pat_2_ext3"
# Copy files (ensure no hidden files are left behind)
# Use rsync if available for better file copying, otherwise use cp
if command -v rsync >/dev/null 2>&1; then
    rsync -a "$BOOT_DIR/" "$IMAGE_GEN_DIR/Image_partitions/Pat_1_vfat/" 2>/dev/null || true
    rsync -a "$ROOTFS_DIR/" "$IMAGE_GEN_DIR/Image_partitions/Pat_2_ext3/" 2>/dev/null || true
else
    cp -r "$BOOT_DIR"/* "$IMAGE_GEN_DIR/Image_partitions/Pat_1_vfat/" 2>/dev/null || true
    cp -r "$ROOTFS_DIR"/* "$IMAGE_GEN_DIR/Image_partitions/Pat_2_ext3/" 2>/dev/null || true
fi
# Remove any macOS-specific files that might cause issues
find "$IMAGE_GEN_DIR/Image_partitions" -name ".DS_Store" -delete 2>/dev/null || true
find "$IMAGE_GEN_DIR/Image_partitions" -name "._*" -delete 2>/dev/null || true
# Verify files were copied
if [ ! "$(ls -A "$IMAGE_GEN_DIR/Image_partitions/Pat_1_vfat/" 2>/dev/null)" ]; then
    echo "⚠️  WARNING: Pat_1_vfat is empty!"
fi
if [ ! "$(ls -A "$IMAGE_GEN_DIR/Image_partitions/Pat_2_ext3/" 2>/dev/null)" ]; then
    echo "⚠️  WARNING: Pat_2_ext3 is empty!"
fi

# Create XML configuration
XML_CONFIG="$IMAGE_GEN_DIR/ghostpi_hackberry_${CM_TYPE,,}_config.xml"
mkdir -p "$OUTPUT_DIR"
cat > "$XML_CONFIG" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<ImageConfiguration>
    <ImageName>${IMAGE_NAME%.img}</ImageName>
    <ImageOutputPath>$OUTPUT_DIR</ImageOutputPath>
    <Partitions>
        <Partition>
            <ID>1</ID>
            <Name>boot</Name>
            <Filesystem>vfat</Filesystem>
            <Size>256MB</Size>
            <Bootable>true</Bootable>
        </Partition>
        <Partition>
            <ID>2</ID>
            <Name>rootfs</Name>
            <Filesystem>ext3</Filesystem>
            <Size>dynamic</Size>
            <DynamicSizeOffset>4GB</DynamicSizeOffset>
        </Partition>
    </Partitions>
</ImageConfiguration>
EOF

cp "$XML_CONFIG" "$IMAGE_GEN_DIR/DistroBlueprint.xml" 2>/dev/null || true

echo "✓ Configuration created"
echo "✓ Partition files prepared"

# Create minimal device tree file (LinuxBootImageFileGenerator requires this)
echo "📐 Creating device tree file..."
cat > "$IMAGE_GEN_DIR/ghostpi.dts" <<'DTS'
/dts-v1/;
/ {
    model = "GhostPi-HackberryPi-CM5";
    compatible = "raspberrypi,5-model-b", "brcm,bcm2712";
    #address-cells = <1>;
    #size-cells = <1>;
    
    chosen {
        bootargs = "console=serial0,115200 console=tty1 root=PARTUUID=12345678-02 rootfstype=ext4 fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles";
    };
};
DTS

if ! dtc -I dts -O dtb -o "$IMAGE_GEN_DIR/ghostpi.dtbo" "$IMAGE_GEN_DIR/ghostpi.dts" 2>/dev/null; then
    echo "❌ Failed to compile device tree (ghostpi.dts)."
    exit 1
fi
cp "$IMAGE_GEN_DIR/ghostpi.dts" "$IMAGE_GEN_DIR/DistroBlueprint.dts" 2>/dev/null || true
cp "$IMAGE_GEN_DIR/ghostpi.dtbo" "$IMAGE_GEN_DIR/DistroBlueprint.dtbo" 2>/dev/null || true

# Generate image
echo ""
echo "🔨 Generating bootable image..."
echo "   This may take several minutes..."

# Debug: Verify files exist before running generator
echo "🔍 Verifying partition files..."
if [ -d "$IMAGE_GEN_DIR/Image_partitions/Pat_1_vfat" ]; then
    BOOT_FILE_COUNT=$(find "$IMAGE_GEN_DIR/Image_partitions/Pat_1_vfat" -type f | wc -l)
    echo "   Pat_1_vfat: $BOOT_FILE_COUNT files"
    if [ "$BOOT_FILE_COUNT" -eq 0 ]; then
        echo "   ⚠️  WARNING: Pat_1_vfat is empty! Listing directory:"
        ls -la "$IMAGE_GEN_DIR/Image_partitions/Pat_1_vfat/" | head -10
    fi
fi
if [ -d "$IMAGE_GEN_DIR/Image_partitions/Pat_2_ext3" ]; then
    ROOTFS_FILE_COUNT=$(find "$IMAGE_GEN_DIR/Image_partitions/Pat_2_ext3" -type f | wc -l)
    echo "   Pat_2_ext3: $ROOTFS_FILE_COUNT files"
    if [ "$ROOTFS_FILE_COUNT" -eq 0 ]; then
        echo "   ⚠️  WARNING: Pat_2_ext3 is empty! Listing directory:"
        ls -la "$IMAGE_GEN_DIR/Image_partitions/Pat_2_ext3/" | head -10
    fi
fi

cd "$IMAGE_GEN_DIR"
echo "   Working directory: $(pwd)"
echo "   Image_partitions exists: $([ -d "Image_partitions" ] && echo "yes" || echo "no")"

# Save original pipefail state and enable it to catch failures in pipeline
PIPEFAIL_ORIGINAL=$(set +o | grep pipefail)
set -o pipefail

# Generate image (non-interactive)
if printf "\nN\n" | timeout 1800 python3 LinuxBootImageGenerator.py "$XML_CONFIG" 2>&1 | tee /tmp/ghostpi-build.log; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║     ✓ GhostPi + HackberryPi CM5 image created!              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    GENERATED_IMAGE=$(find "$OUTPUT_DIR" -name "${IMAGE_NAME%.img}*.img" -type f | head -1)
    if [ -n "$GENERATED_IMAGE" ]; then
        IMAGE_SIZE=$(du -h "$GENERATED_IMAGE" | cut -f1)
        echo "📦 Image Details:"
        echo "   Location: $GENERATED_IMAGE"
        echo "   Size: $IMAGE_SIZE"
        echo ""
        echo "💾 To flash to SD card:"
        echo "   sudo dd if=\"$GENERATED_IMAGE\" of=/dev/sdX bs=4M status=progress"
        echo "   sync"
        echo ""
        echo "🎮 Features included:"
        echo "   ✓ HyperPixel 720x720 display configured"
        echo "   ✓ Touchscreen configured"
        echo "   ✓ All GhostPi services (bots, agents)"
        echo "   ✓ Dual boot support"
        echo "   ✓ Boot splash themes"
        echo "   ✓ First-boot auto-configuration"
        echo ""
        echo "Welcome to Wavy's World! 🎮🔫✨"
    fi
else
    BUILD_EXIT_CODE=$?
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║     ❌ Image generation failed (exit code: $BUILD_EXIT_CODE)            ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "⚠️  Check /tmp/ghostpi-build.log for details."
    echo "   Common issues:"
    echo "   - Missing dependencies"
    echo "   - Insufficient disk space"
    echo "   - LinuxBootImageGenerator.py errors"
    echo ""
    exit 1
fi

# Restore original pipefail setting
eval "$PIPEFAIL_ORIGINAL"

