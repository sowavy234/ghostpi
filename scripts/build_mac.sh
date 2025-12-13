#!/bin/bash
# Mac-compatible build script for GhostPi
# Uses Docker or provides instructions for Linux VM

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CM_TYPE="${1:-CM5}"

echo "=========================================="
echo "  GhostPi Image Builder for macOS"
echo "  Target: $CM_TYPE"
echo "=========================================="

# Check if Docker is available
if command -v docker &> /dev/null; then
    echo "Docker detected. Using Docker to build..."
    
    # Create Dockerfile if it doesn't exist
    if [ ! -f "$PROJECT_ROOT/Dockerfile" ]; then
        cat > "$PROJECT_ROOT/Dockerfile" <<'DOCKERFILE'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y \
    python3 python3-pip \
    device-tree-compiler \
    plymouth plymouth-themes \
    imagemagick \
    git \
    qemu-user-static \
    binfmt-support \
    dosfstools \
    fdisk \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
DOCKERFILE
        echo "✓ Created Dockerfile"
    fi
    
    # Build Docker image
    echo "Building Docker image..."
    docker build -t ghostpi-builder "$PROJECT_ROOT" || {
        echo "Docker build failed. Trying alternative method..."
        USE_DOCKER=false
    }
    
    if [ "$USE_DOCKER" != "false" ]; then
        # Run build in Docker
        echo "Running build in Docker container..."
        docker run --rm -it \
            -v "$PROJECT_ROOT:/build" \
            -v "$HOME/Downloads/ghostpi:/output" \
            -e CM_TYPE="$CM_TYPE" \
            ghostpi-builder \
            bash -c "cd /build && ./scripts/build_linux.sh $CM_TYPE"
        
        echo ""
        echo "=========================================="
        echo "✓ Build complete!"
        echo "=========================================="
        echo "Image location: $HOME/Downloads/ghostpi/"
        exit 0
    fi
fi

# Alternative: Provide instructions for Linux VM or remote build
echo ""
echo "=========================================="
echo "  Alternative Build Methods"
echo "=========================================="
echo ""
echo "Option 1: Use Linux VM (Ubuntu/Debian)"
echo "  1. Install VirtualBox or VMware"
echo "  2. Create Ubuntu 22.04 VM"
echo "  3. Copy ghostpi folder to VM"
echo "  4. Run: sudo ./scripts/build_linux.sh $CM_TYPE"
echo ""
echo "Option 2: Use Remote Linux Server"
echo "  1. Copy ghostpi folder to Linux server"
echo "  2. SSH into server"
echo "  3. Run: sudo ./scripts/build_linux.sh $CM_TYPE"
echo ""
echo "Option 3: Use Raspberry Pi Imager (Simplest)"
echo "  1. Download: https://www.raspberrypi.com/software/"
echo "  2. Install Raspberry Pi OS to SD card"
echo "  3. Boot Pi and run: sudo ./scripts/quick_install.sh"
echo ""
echo "Option 4: Use GitHub Actions (CI/CD)"
echo "  See .github/workflows/build.yml"
echo ""

# Create a script that can be run on Linux
cat > "$PROJECT_ROOT/BUILD_ON_LINUX.sh" <<'BUILDSCRIPT'
#!/bin/bash
# Run this script on a Linux system (Ubuntu/Debian)
# Copy this entire ghostpi folder to Linux and run:
#   sudo ./BUILD_ON_LINUX.sh [CM4|CM5]

CM_TYPE="${1:-CM5}"
cd "$(dirname "$0")"
sudo ./scripts/build_linux.sh "$CM_TYPE"
BUILDSCRIPT

chmod +x "$PROJECT_ROOT/BUILD_ON_LINUX.sh"

echo "Created BUILD_ON_LINUX.sh - copy to Linux and run there"
echo ""

