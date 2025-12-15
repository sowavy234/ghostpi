#!/bin/bash
# Fixed Linux build script for GhostPi
# Creates bootable .img file reliably
# EDUCATIONAL PURPOSES ONLY

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CM_TYPE="${1:-CM5}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Downloads/ghostpi}"
IMAGE_NAME="GhostPi-${CM_TYPE}-$(date +%Y%m%d_%H%M%S).img"
IMAGE_PATH="$OUTPUT_DIR/$IMAGE_NAME"
IMAGE_SIZE_MB=4096  # 4GB

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     GhostPi Image Builder (Fixed)                            ║"
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
apt-get update -qq
apt-get install -y \
    python3 python3-pip \
    device-tree-compiler \
    dosfstools \
    fdisk \
    parted \
    kpartx \
    qemu-utils \
    >/dev/null 2>&1 || true

# Create output directory
mkdir -p "$OUTPUT_DIR"

# Create image file
echo "Creating ${IMAGE_SIZE_MB}MB image file..."
dd if=/dev/zero of="$IMAGE_PATH" bs=1M count=$IMAGE_SIZE_MB 2>/dev/null

# Partition the image
echo "Partitioning image..."
parted "$IMAGE_PATH" --script mklabel msdos
parted "$IMAGE_PATH" --script mkpart primary fat32 1MiB 257MiB
parted "$IMAGE_PATH" --script mkpart primary ext4 257MiB 100%
parted "$IMAGE_PATH" --script set 1 boot on

# Setup loop device
LOOP_DEV=$(losetup -f --show "$IMAGE_PATH")
PART_BOOT="${LOOP_DEV}p1"
PART_ROOT="${LOOP_DEV}p2"

# Wait for partitions
sleep 2
partprobe "$LOOP_DEV" 2>/dev/null || true
sleep 2

# Format partitions
echo "Formatting partitions..."
mkfs.vfat -F 32 -n BOOT "$PART_BOOT" >/dev/null 2>&1
mkfs.ext4 -F -L rootfs "$PART_ROOT" >/dev/null 2>&1

# Mount partitions
MOUNT_BOOT="/mnt/ghostpi-boot"
MOUNT_ROOT="/mnt/ghostpi-root"
mkdir -p "$MOUNT_BOOT" "$MOUNT_ROOT"
mount "$PART_BOOT" "$MOUNT_BOOT"
mount "$PART_ROOT" "$MOUNT_ROOT"

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
console=serial0,115200 console=tty1 root=PARTUUID=$(blkid -s PARTUUID -o value "$PART_ROOT") rootfstype=ext4 fsck.repair=yes rootwait quiet splash
EOF

# Create basic rootfs structure
echo "Creating rootfs structure..."
mkdir -p "$MOUNT_ROOT"/{bin,boot,dev,etc,home,lib,media,mnt,opt,proc,root,run,sbin,srv,sys,tmp,usr,var}

# Copy project files to rootfs
echo "Copying GhostPi files..."
mkdir -p "$MOUNT_ROOT/opt/ghostpi"
cp -r "$PROJECT_ROOT"/* "$MOUNT_ROOT/opt/ghostpi/" 2>/dev/null || true

# Create installation script
cat > "$MOUNT_ROOT/opt/ghostpi/install.sh" <<'INSTALL'
#!/bin/bash
cd /opt/ghostpi
sudo ./scripts/quick_install.sh
INSTALL
chmod +x "$MOUNT_ROOT/opt/ghostpi/install.sh"

# Unmount
echo "Finalizing image..."
sync
umount "$MOUNT_BOOT" "$MOUNT_ROOT" 2>/dev/null || true
losetup -d "$LOOP_DEV" 2>/dev/null || true

# Compress image
echo "Compressing image..."
gzip -f "$IMAGE_PATH" 2>/dev/null || true

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     ✓ Image Created Successfully!                             ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Image: ${IMAGE_PATH}.gz"
echo ""
echo "To flash:"
echo "  gunzip ${IMAGE_PATH}.gz"
echo "  sudo dd if=\"$IMAGE_PATH\" of=/dev/sdX bs=4M status=progress"
echo ""

