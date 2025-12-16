#!/bin/bash
# Flash GhostPi image to SD card on macOS
# Usage: ./scripts/flash_to_sd_mac.sh [image_file.img]

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

# Find image file
if [ -n "$1" ]; then
    IMAGE_FILE="$1"
else
    # Look for image in Downloads
    IMAGE_FILE=$(find ~/Downloads/ghostpi -name "GhostPi-*.img" -type f 2>/dev/null | head -1)
    if [ -z "$IMAGE_FILE" ]; then
        IMAGE_FILE=$(find ~/Downloads -name "GhostPi-*.img" -type f 2>/dev/null | head -1)
    fi
fi

if [ -z "$IMAGE_FILE" ] || [ ! -f "$IMAGE_FILE" ]; then
    echo "❌ Error: GhostPi image file not found!"
    echo ""
    echo "Please provide the image file path:"
    echo "  ./scripts/flash_to_sd_mac.sh /path/to/GhostPi-*.img"
    echo ""
    echo "Or build the image first:"
    echo "  ./scripts/build_mac.sh CM5"
    exit 1
fi

echo "=========================================="
echo "  GhostPi SD Card Flasher for macOS"
echo "=========================================="
echo ""
echo "Image: $IMAGE_FILE"
echo "Size: $(du -h "$IMAGE_FILE" | cut -f1)"
echo ""

# List available disks
echo "Available disks:"
diskutil list | grep -E "^/dev/disk" | head -10
echo ""

# Get SD card device
echo "⚠️  WARNING: This will ERASE all data on the selected disk!"
echo ""
read -p "Enter SD card device (e.g., disk2): " SD_DEVICE

if [ -z "$SD_DEVICE" ]; then
    echo "❌ No device specified. Aborting."
    exit 1
fi

# Validate device exists
if ! diskutil list | grep -q "^/dev/$SD_DEVICE"; then
    echo "❌ Device /dev/$SD_DEVICE not found!"
    exit 1
fi

# Confirm
echo ""
echo "⚠️  You are about to flash:"
echo "   Image: $IMAGE_FILE"
echo "   To: /dev/$SD_DEVICE"
echo ""
read -p "Type 'YES' to confirm: " CONFIRM

if [ "$CONFIRM" != "YES" ]; then
    echo "Aborted."
    exit 1
fi

# Unmount the disk
echo ""
echo "Unmounting /dev/$SD_DEVICE..."
diskutil unmountDisk /dev/$SD_DEVICE

# Flash the image
echo ""
echo "Flashing image to SD card..."
echo "This may take several minutes. Please wait..."
echo ""

sudo dd if="$IMAGE_FILE" of=/dev/r"$SD_DEVICE" bs=4m status=progress

# Sync
echo ""
echo "Syncing..."
sync

# Eject
echo ""
echo "Ejecting SD card..."
diskutil eject /dev/$SD_DEVICE

echo ""
echo "=========================================="
echo "✅ Flash complete!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Remove SD card from computer"
echo "2. Insert into HackberryPi CM5"
echo "3. Power on using Call button (top left)"
echo "4. Wait for first boot configuration"
echo ""
echo "Welcome to Wavy's World! 🎮"

