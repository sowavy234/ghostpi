#!/bin/bash
# Install HackberryPi CM5 Support
# Power management, touchscreen, and hardware configuration

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "  HackberryPi CM5 Support Installation"
echo "  https://github.com/ZitaoTech/HackberryPiCM5"
echo "=========================================="

# Install power management
echo "Installing power management..."
cp "$PROJECT_ROOT/hackberry-cm5/power-management.sh" /usr/local/bin/
chmod +x /usr/local/bin/power-management.sh

# Install touchscreen configuration
echo "Installing touchscreen configuration..."
cp "$PROJECT_ROOT/hackberry-cm5/touchscreen-config.sh" /usr/local/bin/
chmod +x /usr/local/bin/touchscreen-config.sh

# Install systemd service
echo "Installing power management service..."
cp "$PROJECT_ROOT/hackberry-cm5/hackberry-cm5.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable hackberry-cm5.service
systemctl start hackberry-cm5.service

# Configure touchscreen
echo "Configuring touchscreen..."
/usr/local/bin/touchscreen-config.sh install

echo ""
echo "=========================================="
echo "✓ HackberryPi CM5 support installed!"
echo "=========================================="
echo ""
echo "Power Management:"
echo "  - Call button: Power on / Wake"
echo "  - Call End (brief): Sleep"
echo "  - Call End (hold 3s): Shutdown"
echo ""
echo "Touchscreen:"
echo "  - Auto-configured for 720x720"
echo "  - Calibrate: sudo calibrate-touchscreen.sh"
echo ""
echo "Hardware Reference:"
echo "  https://github.com/ZitaoTech/HackberryPiCM5"
echo ""

