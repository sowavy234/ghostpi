#!/bin/bash
# Install Flipper Zero integration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Installing Flipper Zero integration..."

# Copy scripts
cp "$PROJECT_ROOT/flipper-zero/flipper-detector.sh" /usr/local/bin/
cp "$PROJECT_ROOT/flipper-zero/flipper-sync.sh" /usr/local/bin/
cp "$PROJECT_ROOT/flipper-zero/flipper-companion.sh" /usr/local/bin/
cp "$PROJECT_ROOT/flipper-zero/brute-force/brute-force-helper.sh" /usr/local/bin/
cp "$PROJECT_ROOT/flipper-zero/marauder/marauder-setup.sh" /usr/local/bin/
cp "$PROJECT_ROOT/flipper-zero/fbt/fbt-build-helper.sh" /usr/local/bin/
cp "$PROJECT_ROOT/flipper-zero/helpers/ai-coding-assistant.sh" /usr/local/bin/

# Make executable
chmod +x /usr/local/bin/flipper-* /usr/local/bin/brute-force-helper.sh \
         /usr/local/bin/marauder-setup.sh /usr/local/bin/fbt-build-helper.sh \
         /usr/local/bin/ai-coding-assistant.sh

# Install service
cp "$PROJECT_ROOT/flipper-zero/flipper-companion.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable flipper-companion.service
systemctl start flipper-companion.service

# Install dependencies
apt-get update -qq
apt-get install -y \
    usbutils \
    python3 python3-pip \
    aircrack-ng \
    hydra \
    medusa \
    >/dev/null 2>&1

echo "✓ Flipper Zero integration installed"
echo ""
echo "Services:"
echo "  - flipper-companion.service (auto-detection)"
echo ""
echo "Tools:"
echo "  - flipper-detector.sh (detect Flipper)"
echo "  - flipper-sync.sh (sync code)"
echo "  - brute-force-helper.sh (brute force tools)"
echo "  - marauder-setup.sh (Marauder support)"
echo "  - fbt-build-helper.sh (build apps)"
echo "  - ai-coding-assistant.sh (AI helper)"

