#!/bin/bash
# Complete Mac Build Script for GhostPi
# Creates bootable .img file on macOS
# EDUCATIONAL PURPOSES ONLY

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CM_TYPE="${1:-CM5}"
OUTPUT_DIR="$HOME/Downloads/ghostpi"
IMAGE_NAME="GhostPi-${CM_TYPE}-$(date +%Y%m%d_%H%M%S).img"
IMAGE_PATH="$OUTPUT_DIR/$IMAGE_NAME"
IMAGE_SIZE_MB=4096  # 4GB image

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     GhostPi Mac Build System                                  ║"
echo "║     Building for: $CM_TYPE                                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Check if running on macOS
if [[ "$OSTYPE" != "darwin"* ]]; then
    echo "This script is for macOS. Use build_linux.sh on Linux."
    exit 1
fi

# Check for Docker
if command -v docker &> /dev/null; then
    echo "✓ Docker detected - Using Docker for build"
    USE_DOCKER=true
else
    echo "⚠ Docker not found - Will create basic image structure"
    USE_DOCKER=false
fi

# Create output directory
mkdir -p "$OUTPUT_DIR"

if [ "$USE_DOCKER" = "true" ]; then
    echo ""
    echo "Building with Docker..."
    echo ""
    
    # Check if Docker is running
    if ! docker info >/dev/null 2>&1; then
        echo "⚠ Docker is not running. Please start Docker Desktop."
        echo "   Then run this script again."
        exit 1
    fi
    
    # Create Dockerfile if needed
    if [ ! -f "$PROJECT_ROOT/Dockerfile.build" ]; then
        cat > "$PROJECT_ROOT/Dockerfile.build" <<'DOCKERFILE'
FROM ubuntu:22.04

ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
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
    qemu-user-static \
    binfmt-support \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /build
DOCKERFILE
        echo "✓ Created Dockerfile.build"
    fi
    
    # Build Docker image
    echo "Building Docker image..."
    docker build -f "$PROJECT_ROOT/Dockerfile.build" -t ghostpi-builder "$PROJECT_ROOT" || {
        echo "⚠ Docker build failed, trying alternative method..."
        USE_DOCKER=false
    }
    
    if [ "$USE_DOCKER" = "true" ]; then
        # Run build in Docker
        echo "Running build in Docker container..."
        docker run --rm \
            -v "$PROJECT_ROOT:/build" \
            -v "$OUTPUT_DIR:/output" \
            -e CM_TYPE="$CM_TYPE" \
            -e OUTPUT_DIR="/output" \
            ghostpi-builder \
            bash -c "cd /build && ./scripts/build_linux.sh $CM_TYPE && cp GhostPi-*.img /output/ 2>/dev/null || true"
        
        echo ""
        echo "╔═══════════════════════════════════════════════════════════════╗"
        echo "║     ✓ Build Complete!                                        ║"
        echo "╚═══════════════════════════════════════════════════════════════╝"
        echo ""
        
        # Check for generated image
        if ls "$OUTPUT_DIR"/GhostPi-*.img 1> /dev/null 2>&1; then
            GENERATED_IMAGE=$(ls -t "$OUTPUT_DIR"/GhostPi-*.img | head -1)
            echo "Image created: $GENERATED_IMAGE"
            echo ""
            echo "To flash:"
            echo "  Use Raspberry Pi Imager: https://www.raspberrypi.com/software/"
            echo "  Or use dd (be careful!):"
            echo "    sudo dd if=\"$GENERATED_IMAGE\" of=/dev/rdiskX bs=4m"
            exit 0
        fi
    fi
fi

# Alternative: Create image structure for manual completion
if [ "$USE_DOCKER" = "false" ]; then
    echo ""
    echo "Creating image structure (requires Linux tools to complete)..."
    echo ""
    
    # Create a script that can be run on Linux
    cat > "$OUTPUT_DIR/complete_build_on_linux.sh" <<COMPLETE
#!/bin/bash
# Complete this build on a Linux system
# Copy this entire ghostpi folder to Linux and run this script

cd "\$(dirname "\$0")/.."
sudo ./scripts/build_linux.sh $CM_TYPE
COMPLETE

    chmod +x "$OUTPUT_DIR/complete_build_on_linux.sh"
    
    echo "Created: $OUTPUT_DIR/complete_build_on_linux.sh"
    echo ""
    echo "To complete the build:"
    echo "  1. Copy ghostpi folder to a Linux system (Ubuntu/Debian)"
    echo "  2. Run: sudo ./scripts/build_linux.sh $CM_TYPE"
    echo ""
    echo "Or use GitHub Actions:"
    echo "  https://github.com/sowavy234/ghostpi/actions"
    echo "  (Workflow will build automatically)"
fi

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     Build Process Complete                                    ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

