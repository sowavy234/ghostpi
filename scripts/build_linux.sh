#!/bin/bash
# Linux build script for GhostPi
# Works on Ubuntu/Debian systems

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-/tmp/ghostpi-build}"
IMAGE_GEN_DIR="/tmp/LinuxBootImageFileGenerator"
CM_TYPE="${1:-CM5}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Downloads/ghostpi}"

echo "=========================================="
echo "  GhostPi Image Builder"
echo "  Target: $CM_TYPE"
echo "  Welcome to Wavy's World"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
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
    >/dev/null 2>&1

# Clone LinuxBootImageFileGenerator
if [ ! -f "$IMAGE_GEN_DIR/LinuxBootImageGenerator.py" ]; then
    echo "Cloning LinuxBootImageFileGenerator..."
    git clone https://github.com/robseb/LinuxBootImageFileGenerator.git "$IMAGE_GEN_DIR" 2>/dev/null || true
fi

# Create build directory
mkdir -p "$BUILD_DIR/Image_partitions"
BOOT_DIR="$BUILD_DIR/Image_partitions/Pat_1_vfat"
ROOTFS_DIR="$BUILD_DIR/Image_partitions/Pat_2_ext4"
mkdir -p "$BOOT_DIR" "$ROOTFS_DIR"

# Set up boot partition
echo "Setting up boot partition for $CM_TYPE..."

# Create config.txt with CM-specific settings
cat > "$BOOT_DIR/config.txt" <<EOF
# GhostPi Configuration - $CM_TYPE
# Welcome to Wavy's World

# Enable GPU
gpu_mem=128

# CPU configuration
arm_64bit=1
kernel=kernel8.img

# CM-specific settings
EOF

if [ "$CM_TYPE" = "CM4" ]; then
    cat >> "$BOOT_DIR/config.txt" <<EOF
# CM4 Configuration
arm_freq=1800
over_voltage=2
EOF
else
    cat >> "$BOOT_DIR/config.txt" <<EOF
# CM5 Configuration
arm_freq=2400
over_voltage=0
EOF
fi

cat >> "$BOOT_DIR/config.txt" <<EOF

# Enable I2C
dtparam=i2c_arm=on
dtparam=i2c1=on

# Enable SPI
dtparam=spi=on

# USB configuration
dtparam=usb=on

# Audio configuration
dtparam=audio=on

# Disable overscan
overscan_left=0
overscan_right=0
overscan_top=0
overscan_bottom=0

# Enable hardware acceleration
dtoverlay=vc4-kms-v3d

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

echo "✓ Boot partition configured"

# Create minimal rootfs structure
echo "Creating rootfs structure..."
mkdir -p "$ROOTFS_DIR"/{bin,boot,dev,etc,home,lib,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}

# Copy boot splash files
echo "Installing boot splash..."
mkdir -p "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world"
if [ -d "$PROJECT_ROOT/boot-splash" ]; then
    cp -r "$PROJECT_ROOT/boot-splash/"* "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world/" 2>/dev/null || true
fi

# Copy swapfile service
echo "Installing swapfile service..."
mkdir -p "$ROOTFS_DIR/etc/systemd/system"
if [ -f "$PROJECT_ROOT/services/swapfile-manager.service" ]; then
    cp "$PROJECT_ROOT/services/swapfile-manager.service" "$ROOTFS_DIR/etc/systemd/system/" 2>/dev/null || true
fi
mkdir -p "$ROOTFS_DIR/usr/local/bin"
if [ -f "$PROJECT_ROOT/services/swapfile-manager.sh" ]; then
    cp "$PROJECT_ROOT/services/swapfile-manager.sh" "$ROOTFS_DIR/usr/local/bin/" 2>/dev/null || true
    chmod +x "$ROOTFS_DIR/usr/local/bin/swapfile-manager.sh" 2>/dev/null || true
fi

# Copy partition files to LinuxBootImageFileGenerator directory (it expects files there)
echo "Copying partition files to image generator..."
mkdir -p "$IMAGE_GEN_DIR/Image_partitions"
rm -rf "$IMAGE_GEN_DIR/Image_partitions/Pat_1_vfat" "$IMAGE_GEN_DIR/Image_partitions/Pat_2_ext3" "$IMAGE_GEN_DIR/Image_partitions/Pat_2_ext4" 2>/dev/null || true
cp -r "$BOOT_DIR" "$IMAGE_GEN_DIR/Image_partitions/Pat_1_vfat" 2>/dev/null || true
cp -r "$ROOTFS_DIR" "$IMAGE_GEN_DIR/Image_partitions/Pat_2_ext3" 2>/dev/null || true

# Create minimal device tree file (LinuxBootImageFileGenerator requires this)
echo "Creating device tree file..."
cat > "$IMAGE_GEN_DIR/ghostpi.dts" <<'DTS'
/dts-v1/;
/ {
    model = "GhostPi";
    compatible = "raspberrypi,4-model-b", "brcm,bcm2711";
    #address-cells = <1>;
    #size-cells = <1>;
    
    chosen {
        bootargs = "console=serial0,115200 console=tty1 root=PARTUUID=12345678-02 rootfstype=ext4 fsck.repair=yes rootwait quiet splash";
    };
};
DTS

# Create XML configuration
XML_CONFIG="$IMAGE_GEN_DIR/ghostpi_${CM_TYPE,,}_config.xml"
cat > "$XML_CONFIG" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<ImageConfiguration>
    <ImageName>GhostPi-${CM_TYPE}-WavysWorld-$(date +%Y%m%d_%H%M%S)</ImageName>
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
            <DynamicSizeOffset>2GB</DynamicSizeOffset>
        </Partition>
    </Partitions>
</ImageConfiguration>
EOF

echo "✓ Configuration created"
echo "✓ Partition files copied to image generator"

# Generate image
echo "Generating bootable image..."
cd "$IMAGE_GEN_DIR"

# The LinuxBootImageFileGenerator is interactive, so we need to provide input
# Use printf to provide all inputs at once (press Enter to continue, then 'N' for no compression)
if printf "\nN\n" | python3 LinuxBootImageGenerator.py "$XML_CONFIG" 2>&1; then
    echo ""
    echo "=========================================="
    echo "✓ GhostPi image created successfully!"
    echo "=========================================="
    
    GENERATED_IMAGE=$(find "$OUTPUT_DIR" -name "GhostPi-${CM_TYPE}-*.img" -type f | head -1)
    if [ -n "$GENERATED_IMAGE" ]; then
        IMAGE_SIZE=$(du -h "$GENERATED_IMAGE" | cut -f1)
        echo ""
        echo "Image: $GENERATED_IMAGE"
        echo "Size: $IMAGE_SIZE"
        echo ""
        echo "To flash:"
        echo "  sudo dd if=\"$GENERATED_IMAGE\" of=/dev/sdX bs=4M status=progress"
    fi
else
    echo "Image generation completed. Check output above."
fi

echo ""
echo "Welcome to Wavy's World!"
echo ""

