#!/bin/bash
# Main Build Script for GhostPi + HackberryPi CM5
# Automatically selects best build method based on available resources
# Outputs to: ~/Downloads/GhostPi-HackberryPi-CM5-*.img

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CM_TYPE="${1:-CM5}"
OUTPUT_DIR="${OUTPUT_DIR:-$HOME/Downloads}"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     GhostPi + HackberryPi CM5 Complete Build System          ║"
echo "║     HyperPixel Display | Touchscreen | Agents | Dual Boot    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Detect OS
if [[ "$OSTYPE" == "darwin"* ]]; then
    OS_TYPE="macos"
elif [[ "$OSTYPE" == "linux-gnu"* ]]; then
    OS_TYPE="linux"
else
    echo "❌ Unsupported OS: $OSTYPE"
    exit 1
fi

echo "🖥️  Detected OS: $OS_TYPE"
echo "🎯 Target: $CM_TYPE"
echo ""

# Check if running as root (required for Linux, optional for macOS with Docker)
if [[ "$OS_TYPE" == "linux" && "$EUID" -ne 0 ]]; then
    echo "⚠️  On Linux, this script needs root privileges"
    echo "   Please run: sudo $0 $CM_TYPE"
    exit 1
fi

# Check for base image (preferred method)
BASE_IMAGE_CANDIDATES=(
    "$HOME/Downloads/raspios_lite_arm64.img"
    "$HOME/Downloads/raspios_lite_armhf.img"
    "$HOME/Downloads/*raspberry*pi*os*.img"
    "$HOME/Downloads/*raspios*.img"
)

BASE_IMAGE=""
for candidate in "${BASE_IMAGE_CANDIDATES[@]}"; do
    # Use test -f for single file or proper glob matching
    if [[ "$candidate" == *\** ]]; then
        # Handle glob patterns - use bash array expansion to check for matches
        # This properly handles globs and returns empty if no matches
        shopt -s nullglob  # Return empty array if no matches
        matches=($candidate)
        shopt -u nullglob  # Restore default behavior
        if [ ${#matches[@]} -gt 0 ] && [ -f "${matches[0]}" ]; then
            BASE_IMAGE="${matches[0]}"
            break
        fi
    else
        # Handle specific file paths - use test -f for proper existence check
        if [ -f "$candidate" ]; then
            BASE_IMAGE="$candidate"
            break
        fi
    fi
done

if [ -n "$BASE_IMAGE" ]; then
    echo "✓ Found base image: $BASE_IMAGE"
    echo ""
    echo "🔨 Building from base image (recommended method)..."
    echo ""
    
    if [[ "$OS_TYPE" == "linux" ]]; then
        "$SCRIPT_DIR/build_from_base_image.sh" "$BASE_IMAGE" "$CM_TYPE"
    else
        echo "⚠️  Building from base image requires Linux"
        echo ""
        # Check for Docker
        if command -v docker &> /dev/null && docker info &> /dev/null 2>&1; then
            echo "🐳 Docker detected. Building in Docker container..."
            echo ""
            # Use build_mac.sh which properly handles Docker
            "$SCRIPT_DIR/build_mac.sh" "$CM_TYPE" || {
                echo ""
                echo "⚠️  Docker build failed. Please:"
                echo "   1. Copy project to a Linux system and run:"
                echo "      sudo ./scripts/build_from_base_image.sh \"$BASE_IMAGE\" $CM_TYPE"
                echo "   2. Or use GitHub Actions to build"
                exit 1
            }
        else
            echo "❌ Docker not available. Please:"
            echo "   1. Install Docker Desktop and try again, OR"
            echo "   2. Copy project to a Linux system (VM or remote) and run:"
            echo "      sudo ./scripts/build_from_base_image.sh \"$BASE_IMAGE\" $CM_TYPE"
            echo "   3. Or use GitHub Actions to build"
            exit 1
        fi
    fi
else
    echo "⚠️  No base Raspberry Pi OS image found"
    echo "   Building from scratch using LinuxBootImageFileGenerator..."
    echo ""
    echo "   Note: This creates a minimal image. For full functionality,"
    echo "   download Raspberry Pi OS from:"
    echo "   https://www.raspberrypi.com/software/operating-systems/"
    echo ""
    
    if [[ "$OS_TYPE" == "macos" ]]; then
        # On macOS, check for Docker
        if command -v docker &> /dev/null && docker info &> /dev/null 2>&1; then
            echo "🐳 Docker detected. Building in Docker container..."
            echo ""
            # Use build_mac.sh which properly handles Docker builds
            "$SCRIPT_DIR/build_mac.sh" "$CM_TYPE" || {
                echo ""
                echo "⚠️  Docker build failed. Please:"
                echo "   1. Copy project to a Linux system (VM or remote) and run:"
                echo "      sudo ./scripts/build_hackberry_integrated.sh $CM_TYPE"
                echo "   2. Or use GitHub Actions to build"
                exit 1
            }
        else
            echo "❌ Docker not available. Please:"
            echo "   1. Install Docker Desktop and try again, OR"
            echo "   2. Copy project to a Linux system (VM or remote) and run:"
            echo "      sudo ./scripts/build_hackberry_integrated.sh $CM_TYPE"
            echo "   3. Or use GitHub Actions to build"
            exit 1
        fi
    else
        # On Linux, use the integrated build
        "$SCRIPT_DIR/build_hackberry_integrated.sh" "$CM_TYPE"
    fi
fi

# Check for generated image
GENERATED_IMAGE=$(find "$OUTPUT_DIR" -name "GhostPi-HackberryPi-${CM_TYPE}-*.img" -type f -mtime -1 | head -1)

if [ -n "$GENERATED_IMAGE" ]; then
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    ✓ Build Complete!                         ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    IMAGE_SIZE=$(du -h "$GENERATED_IMAGE" | cut -f1)
    echo "📦 Image: $GENERATED_IMAGE"
    echo "📊 Size: $IMAGE_SIZE"
    echo ""
    echo "💾 To flash to SD card:"
    if [[ "$OS_TYPE" == "macos" ]]; then
        echo "   diskutil list  # Find your SD card (e.g., disk2)"
        echo "   diskutil unmountDisk /dev/diskX"
        echo "   sudo dd if=\"$GENERATED_IMAGE\" of=/dev/rdiskX bs=4m"
        echo "   sync"
        echo "   diskutil eject /dev/diskX"
    else
        echo "   lsblk  # Find your SD card (e.g., /dev/sdb)"
        echo "   sudo dd if=\"$GENERATED_IMAGE\" of=/dev/sdX bs=4M status=progress"
        echo "   sync"
    fi
    echo ""
    echo "🎮 Features included:"
    echo "   ✓ HyperPixel 720x720 display configured"
    echo "   ✓ Touchscreen configured with calibration"
    echo "   ✓ All GhostPi services (bots, agents, self-healing)"
    echo "   ✓ Dual boot support"
    echo "   ✓ Boot splash themes (Wavy's World)"
    echo "   ✓ First-boot auto-configuration"
    echo "   ✓ HackberryPi CM5 power management"
    echo ""
    echo "🚀 After flashing and booting:"
    echo "   - First boot will automatically configure everything"
    echo "   - Touchscreen will be ready to use"
    echo "   - All services will start automatically"
    echo ""
    echo "Welcome to Wavy's World! 🎮🔫✨"
else
    echo ""
    echo "⚠️  Build completed, but image not found in expected location"
    echo "   Check $OUTPUT_DIR for generated images"
fi

