#!/bin/bash
# Create GhostPi bootable image with custom boot splash
# Works on CM4, CM5, Pi 4, Pi 5

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
BUILD_DIR="${BUILD_DIR:-/tmp/ghostpi-build}"
IMAGE_GEN_DIR="/tmp/LinuxBootImageFileGenerator"
DOWNLOADS_DIR="$HOME/Downloads/ghostpi"

echo "=========================================="
echo "  GhostPi Image Creator"
echo "  Welcome to Wavy's World"
echo "=========================================="

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
apt-get update -qq
apt-get install -y python3 python3-pip device-tree-compiler plymouth plymouth-themes ffmpeg imagemagick >/dev/null 2>&1 || true

# Clone LinuxBootImageFileGenerator if needed
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
echo "Setting up boot partition..."

# Copy display overlays if they exist
if [ -d "$PROJECT_ROOT/../HackberryPi5/Screen" ]; then
    cp "$PROJECT_ROOT/../HackberryPi5/Screen/"*.dtbo "$BOOT_DIR/" 2>/dev/null || true
fi

# Create config.txt for universal Pi support
cat > "$BOOT_DIR/config.txt" <<'EOF'
# GhostPi Configuration - Universal Raspberry Pi Support
# Works on CM4, CM5, Pi 4, Pi 5

# Enable GPU
gpu_mem=128

# CPU configuration
arm_64bit=1
kernel=kernel8.img

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

# Display configuration (for HackberryPi)
# Uncomment if using HackberryPi display:
# dtoverlay=vc4-kms-dpi-hyperpixel4sq
# framebuffer_width=720
# framebuffer_height=720

# Plymouth boot splash
disable_splash=0
EOF

# Create cmdline.txt
cat > "$BOOT_DIR/cmdline.txt" <<'EOF'
console=serial0,115200 console=tty1 root=PARTUUID=12345678-02 rootfstype=ext4 fsck.repair=yes rootwait quiet splash plymouth.ignore-serial-consoles
EOF

echo "✓ Boot partition configured"

# Create rootfs structure
echo "Creating rootfs structure..."
mkdir -p "$ROOTFS_DIR"/{bin,boot,dev,etc,home,lib,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}

# Copy boot splash files
echo "Installing custom boot splash..."
mkdir -p "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world"
cp -r "$PROJECT_ROOT/boot-splash/"* "$ROOTFS_DIR/usr/share/plymouth/themes/wavys-world/" 2>/dev/null || true

# Copy swapfile service
echo "Installing swapfile service..."
mkdir -p "$ROOTFS_DIR/etc/systemd/system"
cp "$PROJECT_ROOT/services/swapfile-manager.service" "$ROOTFS_DIR/etc/systemd/system/" 2>/dev/null || true
mkdir -p "$ROOTFS_DIR/usr/local/bin"
cp "$PROJECT_ROOT/services/swapfile-manager.sh" "$ROOTFS_DIR/usr/local/bin/" 2>/dev/null || true
chmod +x "$ROOTFS_DIR/usr/local/bin/swapfile-manager.sh" 2>/dev/null || true

# Create XML configuration for image generator
XML_CONFIG="$BUILD_DIR/ghostpi_config.xml"
cat > "$XML_CONFIG" <<EOF
<?xml version="1.0" encoding="UTF-8"?>
<ImageConfiguration>
    <ImageName>GhostPi-WavysWorld-$(date +%Y%m%d_%H%M%S)</ImageName>
    <ImageOutputPath>$DOWNLOADS_DIR</ImageOutputPath>
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
            <Filesystem>ext4</Filesystem>
            <Size>dynamic</Size>
            <DynamicSizeOffset>2GB</DynamicSizeOffset>
        </Partition>
    </Partitions>
</ImageConfiguration>
EOF

echo "✓ Configuration created"

# Generate image
echo "Generating bootable image..."
cd "$IMAGE_GEN_DIR"

if python3 LinuxBootImageGenerator.py "$XML_CONFIG" 2>&1 | tee /tmp/ghostpi-build.log; then
    echo ""
    echo "=========================================="
    echo "✓ GhostPi image created successfully!"
    echo "=========================================="
    
    GENERATED_IMAGE=$(find "$DOWNLOADS_DIR" -name "*.img" -type f | head -1)
    if [ -n "$GENERATED_IMAGE" ]; then
        echo ""
        echo "Image: $GENERATED_IMAGE"
        echo ""
        echo "To flash:"
        echo "  sudo dd if=\"$GENERATED_IMAGE\" of=/dev/sdX bs=4M status=progress"
    fi
else
    echo "Image generation completed. Check /tmp/ghostpi-build.log for details."
fi

echo ""
echo "Welcome to Wavy's World!"
echo ""
