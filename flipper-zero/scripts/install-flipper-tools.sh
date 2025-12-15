#!/bin/bash
# Install Flipper Zero development tools
# Includes qFlipper, FBT, and development dependencies

set -e

echo "Installing Flipper Zero development tools..."

# Install dependencies
apt-get update -qq
apt-get install -y \
    python3 python3-pip \
    git \
    build-essential \
    cmake \
    libusb-1.0-0-dev \
    libftdi1-dev \
    pkg-config \
    >/dev/null 2>&1

# Install FBT (Flipper Build Tool)
echo "Installing FBT..."
if [ ! -d "/opt/flipper/fbt" ]; then
    mkdir -p /opt/flipper
    git clone https://github.com/flipperdevices/flipperzero-firmware.git /opt/flipper/firmware 2>/dev/null || true
    
    # Install FBT dependencies
    cd /opt/flipper/firmware
    python3 -m pip install -r scripts/requirements.txt 2>/dev/null || true
fi

# Install qFlipper CLI tools
echo "Installing qFlipper tools..."
if ! command -v qflipper &> /dev/null; then
    # Download qFlipper CLI
    wget -q https://update.flipperzero.one/builds/qFlipper/linux/qFlipper-x86_64.AppImage -O /usr/local/bin/qflipper || true
    chmod +x /usr/local/bin/qflipper 2>/dev/null || true
fi

# Install Flipper CLI
echo "Installing Flipper CLI..."
pip3 install flipperzero-cli 2>/dev/null || {
    pip3 install --user flipperzero-cli
}

# Create symlinks
ln -sf /opt/flipper/firmware/scripts/fbt /usr/local/bin/fbt 2>/dev/null || true

echo "✓ Flipper Zero tools installed"
echo ""
echo "Tools available:"
echo "  - fbt: Flipper Build Tool"
echo "  - qflipper: qFlipper CLI"
echo "  - flipperzero-cli: Flipper CLI"
echo ""

