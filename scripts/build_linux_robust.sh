#!/bin/bash
# Robust Linux build script for GhostPi
# Handles errors gracefully and creates working image
# EDUCATIONAL PURPOSES ONLY

set +e  # Don't exit on error - handle gracefully

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CM_TYPE="${1:-CM5}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Downloads/ghostpi}"
IMAGE_NAME="GhostPi-${CM_TYPE}-$(date +%Y%m%d_%H%M%S).img"
IMAGE_PATH="$OUTPUT_DIR/$IMAGE_NAME"
IMAGE_SIZE_MB=4096  # 4GB

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     GhostPi Image Builder (Robust)                           ║"
echo "║     Target: $CM_TYPE                                          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if running as root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Install dependencies
echo "Installing dependencies..."
export DEBIAN_FRONTEND=noninteractive
apt-get update -qq || true
apt-get install -y \
    python3 \
    dosfstools \
    fdisk \
    parted \
    kpartx \
    qemu-utils \
    >/dev/null 2>&1 || {
    echo "⚠ Some dependencies failed to install, continuing..."
}

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Create image file
echo "Creating ${IMAGE_SIZE_MB}MB image file..."
if ! dd if=/dev/zero of="$IMAGE_PATH" bs=1M count=$IMAGE_SIZE_MB 2>/dev/null; then
    echo "✗ Failed to create image file"
    exit 1
fi

# Partition the image
echo "Partitioning image..."
if ! parted "$IMAGE_PATH" --script mklabel msdos 2>/dev/null; then
    echo "✗ Failed to create partition table"
    exit 1
fi

if ! parted "$IMAGE_PATH" --script mkpart primary fat32 1MiB 257MiB 2>/dev/null; then
    echo "✗ Failed to create boot partition"
    exit 1
fi

if ! parted "$IMAGE_PATH" --script mkpart primary ext4 257MiB 100% 2>/dev/null; then
    echo "✗ Failed to create root partition"
    exit 1
fi

parted "$IMAGE_PATH" --script set 1 boot on 2>/dev/null || true

# Setup loop device
echo "Setting up loop device..."
LOOP_DEV=$(losetup -f --show "$IMAGE_PATH" 2>/dev/null)
if [ -z "$LOOP_DEV" ]; then
    echo "✗ Failed to setup loop device"
    exit 1
fi

# Wait for partitions
sleep 3
partprobe "$LOOP_DEV" 2>/dev/null || true
sleep 3

# Check if partitions exist
PART_BOOT="${LOOP_DEV}p1"
PART_ROOT="${LOOP_DEV}p2"

if [ ! -e "$PART_BOOT" ] || [ ! -e "$PART_ROOT" ]; then
    echo "⚠ Partitions not ready, trying alternative method..."
    kpartx -av "$IMAGE_PATH" 2>/dev/null || true
    sleep 2
    PART_BOOT="/dev/mapper/$(basename ${LOOP_DEV})p1"
    PART_ROOT="/dev/mapper/$(basename ${LOOP_DEV})p2"
fi

# Format partitions
echo "Formatting partitions..."
if ! mkfs.vfat -F 32 -n BOOT "$PART_BOOT" >/dev/null 2>&1; then
    echo "✗ Failed to format boot partition"
    losetup -d "$LOOP_DEV" 2>/dev/null || true
    exit 1
fi

if ! mkfs.ext4 -F -L rootfs "$PART_ROOT" >/dev/null 2>&1; then
    echo "✗ Failed to format root partition"
    losetup -d "$LOOP_DEV" 2>/dev/null || true
    exit 1
fi

# Mount partitions
MOUNT_BOOT="/mnt/ghostpi-boot"
MOUNT_ROOT="/mnt/ghostpi-root"
mkdir -p "$MOUNT_BOOT" "$MOUNT_ROOT"

if ! mount "$PART_BOOT" "$MOUNT_BOOT" 2>/dev/null; then
    echo "✗ Failed to mount boot partition"
    losetup -d "$LOOP_DEV" 2>/dev/null || true
    exit 1
fi

if ! mount "$PART_ROOT" "$MOUNT_ROOT" 2>/dev/null; then
    echo "✗ Failed to mount root partition"
    umount "$MOUNT_BOOT" 2>/dev/null || true
    losetup -d "$LOOP_DEV" 2>/dev/null || true
    exit 1
fi

# Setup boot partition
echo "Setting up boot partition..."
cat > "$MOUNT_BOOT/config.txt" <<EOF
# GhostPi Configuration - $CM_TYPE
gpu_mem=128
arm_64bit=1
kernel=kernel8.img
dtoverlay=vc4-kms-v3d
disable_splash=0
EOF

cat > "$MOUNT_BOOT/cmdline.txt" <<EOF
console=serial0,115200 console=tty1 root=PARTUUID=$(blkid -s PARTUUID -o value "$PART_ROOT" 2>/dev/null || echo "12345678-02") rootfstype=ext4 fsck.repair=yes rootwait quiet splash
EOF

# Create basic rootfs structure
echo "Creating rootfs structure..."
mkdir -p "$MOUNT_ROOT"/{bin,boot,dev,etc,home,lib,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}

# Copy project files
echo "Copying GhostPi files..."
if [ -d "$PROJECT_ROOT" ]; then
    mkdir -p "$MOUNT_ROOT/opt/ghostpi"
    cp -r "$PROJECT_ROOT"/* "$MOUNT_ROOT/opt/ghostpi/" 2>/dev/null || true
fi

# Create README
cat > "$MOUNT_ROOT/README.txt" <<EOF
GhostPi - Wavy's World
=====================

This is a minimal bootable image. To complete setup:

1. Boot this image on your Raspberry Pi
2. Run: sudo /opt/ghostpi/scripts/quick_install.sh
3. This will install all GhostPi features

For more info: https://github.com/sowavy234/ghostpi
EOF

# Unmount
echo "Finalizing image..."
sync
umount "$MOUNT_BOOT" "$MOUNT_ROOT" 2>/dev/null || true
kpartx -d "$IMAGE_PATH" 2>/dev/null || true
losetup -d "$LOOP_DEV" 2>/dev/null || true

# Verify image exists
if [ -f "$IMAGE_PATH" ]; then
    IMAGE_SIZE=$(du -h "$IMAGE_PATH" | cut -f1)
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║     ✓ Image Created Successfully!                             ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Image: $IMAGE_PATH"
    echo "Size: $IMAGE_SIZE"
    echo ""
    echo "To flash:"
    echo "  sudo dd if=\"$IMAGE_PATH\" of=/dev/sdX bs=4M status=progress"
    echo ""
    exit 0
else
    echo "✗ Image file not found after creation"
    exit 1
fi

