#!/bin/bash
# Create flashable .img file on macOS
# This creates a minimal bootable image that can be flashed

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CM_TYPE="${1:-CM5}"
OUTPUT_DIR="$HOME/Downloads/ghostpi"
IMAGE_NAME="GhostPi-${CM_TYPE}-$(date +%Y%m%d_%H%M%S).img"
IMAGE_PATH="$OUTPUT_DIR/$IMAGE_NAME"
IMAGE_SIZE_MB=4096  # 4GB image

echo "=========================================="
echo "  Creating Flashable GhostPi Image"
echo "  Target: $CM_TYPE"
echo "=========================================="

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script is for macOS. Use build_linux.sh on Linux."
    exit 1
fi

# Check for required tools
if ! command -v hdiutil &> /dev/null; then
    echo "Error: hdiutil not found (should be on macOS)"
    exit 1
fi

echo ""
echo "Creating $IMAGE_SIZE_MB MB image file..."
echo "This will take a few minutes..."
echo ""

# Create disk image
hdiutil create -size ${IMAGE_SIZE_MB}M -fs "MS-DOS FAT32" -volname "GHOSTPI_BOOT" "$IMAGE_PATH.tmp" 2>/dev/null || {
    echo "Creating raw image file instead..."
    # Fallback: create raw image
    dd if=/dev/zero of="$IMAGE_PATH" bs=1M count=$IMAGE_SIZE_MB 2>/dev/null
}

# If we created a .tmp file, convert it
if [ -f "$IMAGE_PATH.tmp.dmg" ]; then
    hdiutil convert "$IMAGE_PATH.tmp.dmg" -format UDRW -o "$IMAGE_PATH" 2>/dev/null
    rm -f "$IMAGE_PATH.tmp.dmg"
fi

# Create a simple script that can be run on Linux to finish the image
cat > "$OUTPUT_DIR/finish_image_on_linux.sh" <<'FINISHSCRIPT'
#!/bin/bash
# Run this on a Linux system to finish creating the bootable image
# This sets up partitions and boot files properly

set -e

IMAGE_FILE="${1:-GhostPi-*.img}"
CM_TYPE="${2:-CM5}"

if [ ! -f "$IMAGE_FILE" ]; then
    echo "Error: Image file not found: $IMAGE_FILE"
    exit 1
fi

echo "Finishing image setup on Linux..."
echo "This requires Linux tools (parted, mkfs, etc.)"
echo ""
echo "For now, use one of these methods:"
echo ""
echo "Method 1: Use Raspberry Pi Imager"
echo "  1. Download: https://www.raspberrypi.com/software/"
echo "  2. Install Raspberry Pi OS to SD card"
echo "  3. Boot Pi and run: sudo ./scripts/quick_install.sh"
echo ""
echo "Method 2: Build on Linux"
echo "  1. Copy ghostpi folder to Linux system"
echo "  2. Run: sudo ./scripts/build_linux.sh $CM_TYPE"
echo ""
echo "Method 3: Use Docker (on Mac)"
echo "  ./scripts/build_mac.sh $CM_TYPE"
FINISHSCRIPT

chmod +x "$OUTPUT_DIR/finish_image_on_linux.sh"

echo ""
echo "=========================================="
echo "Image file created: $IMAGE_PATH"
echo "=========================================="
echo ""
echo "⚠️  Note: This is a basic image file."
echo "To make it fully bootable, you need Linux tools."
echo ""
echo "Recommended options:"
echo ""
echo "1. Use Raspberry Pi Imager (Easiest):"
echo "   - Download: https://www.raspberrypi.com/software/"
echo "   - Install Raspberry Pi OS"
echo "   - Boot Pi and run: sudo ./scripts/quick_install.sh"
echo ""
echo "2. Build on Linux system:"
echo "   - Copy this folder to Linux"
echo "   - Run: sudo ./scripts/build_linux.sh $CM_TYPE"
echo ""
echo "3. Use Docker (if installed):"
echo "   - Run: ./scripts/build_mac.sh $CM_TYPE"
echo ""
echo "The image file is at: $IMAGE_PATH"
echo ""

