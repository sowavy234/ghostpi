#!/bin/bash
# Simple, reliable build script for GhostPi
# Creates minimal bootable image that can be expanded
# EDUCATIONAL PURPOSES ONLY

set +e  # Handle errors gracefully

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CM_TYPE="${1:-CM5}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Downloads/ghostpi}"
IMAGE_NAME="GhostPi-${CM_TYPE}-$(date +%Y%m%d_%H%M%S).img"
IMAGE_PATH="$OUTPUT_DIR/$IMAGE_NAME"
IMAGE_SIZE_MB=2048  # 2GB minimal

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     GhostPi Simple Builder                                   ║"
echo "║     Target: $CM_TYPE                                          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check root
if [ "$EUID" -ne 0 ]; then 
    echo "Please run as root (use sudo)"
    exit 1
fi

# Install minimal deps
apt-get update -qq || true
apt-get install -y dosfstools fdisk parted >/dev/null 2>&1 || true

# Create output
mkdir -p "$OUTPUT_DIR"

# Create image
echo "Creating ${IMAGE_SIZE_MB}MB image..."
dd if=/dev/zero of="$IMAGE_PATH" bs=1M count=$IMAGE_SIZE_MB 2>/dev/null || exit 1

# Partition
echo "Partitioning..."
parted "$IMAGE_PATH" --script mklabel msdos 2>/dev/null || exit 1
parted "$IMAGE_PATH" --script mkpart primary fat32 1MiB 257MiB 2>/dev/null || exit 1
parted "$IMAGE_PATH" --script mkpart primary ext4 257MiB 100% 2>/dev/null || exit 1
parted "$IMAGE_PATH" --script set 1 boot on 2>/dev/null || true

# Setup loop
LOOP_DEV=$(losetup -f --show "$IMAGE_PATH" 2>/dev/null)
[ -z "$LOOP_DEV" ] && exit 1

sleep 3
kpartx -av "$IMAGE_PATH" 2>/dev/null || true
sleep 2

# Find partitions
PART_BOOT=$(lsblk -ln -o NAME "$LOOP_DEV" | grep -E "p1$|1$" | head -1)
PART_ROOT=$(lsblk -ln -o NAME "$LOOP_DEV" | grep -E "p2$|2$" | head -1)

if [ -n "$PART_BOOT" ] && [ -n "$PART_ROOT" ]; then
    PART_BOOT="/dev/mapper/$PART_BOOT"
    PART_ROOT="/dev/mapper/$PART_ROOT"
else
    PART_BOOT="${LOOP_DEV}p1"
    PART_ROOT="${LOOP_DEV}p2"
fi

# Format
echo "Formatting..."
mkfs.vfat -F 32 -n BOOT "$PART_BOOT" >/dev/null 2>&1 || exit 1
mkfs.ext4 -F -L rootfs "$PART_ROOT" >/dev/null 2>&1 || exit 1

# Mount
MOUNT_BOOT="/mnt/ghostpi-boot"
MOUNT_ROOT="/mnt/ghostpi-root"
mkdir -p "$MOUNT_BOOT" "$MOUNT_ROOT"
mount "$PART_BOOT" "$MOUNT_BOOT" 2>/dev/null || exit 1
mount "$PART_ROOT" "$MOUNT_ROOT" 2>/dev/null || exit 1

# Setup boot
echo "Setting up boot..."
cat > "$MOUNT_BOOT/config.txt" <<EOF
# GhostPi - $CM_TYPE
gpu_mem=128
arm_64bit=1
kernel=kernel8.img
dtoverlay=vc4-kms-v3d
disable_splash=0
EOF

cat > "$MOUNT_BOOT/cmdline.txt" <<EOF
console=serial0,115200 console=tty1 root=PARTUUID=$(blkid -s PARTUUID -o value "$PART_ROOT" 2>/dev/null || echo "12345678-02") rootfstype=ext4 fsck.repair=yes rootwait quiet splash
EOF

# Create structure
mkdir -p "$MOUNT_ROOT"/{bin,boot,dev,etc,home,lib,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}

# Copy files
mkdir -p "$MOUNT_ROOT/opt/ghostpi"
cp -r "$PROJECT_ROOT"/* "$MOUNT_ROOT/opt/ghostpi/" 2>/dev/null || true

# README
cat > "$MOUNT_ROOT/README.txt" <<EOF
GhostPi - Wavy's World
Boot this image and run: sudo /opt/ghostpi/scripts/quick_install.sh
EOF

# Cleanup
sync
umount "$MOUNT_BOOT" "$MOUNT_ROOT" 2>/dev/null || true
kpartx -d "$IMAGE_PATH" 2>/dev/null || true
losetup -d "$LOOP_DEV" 2>/dev/null || true

if [ -f "$IMAGE_PATH" ]; then
    echo ""
    echo "✓ Image created: $IMAGE_PATH"
    echo "Size: $(du -h "$IMAGE_PATH" | cut -f1)"
    exit 0
else
    exit 1
fi

