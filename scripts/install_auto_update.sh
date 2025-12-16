#!/bin/bash
# Install auto-update and self-healing services

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Installing GhostPi auto-update and self-healing services..."

# Copy service files
cp "$PROJECT_ROOT/services/auto-update.service" /etc/systemd/system/
cp "$PROJECT_ROOT/services/auto-update.timer" /etc/systemd/system/
cp "$PROJECT_ROOT/services/self-healing.service" /etc/systemd/system/

# Copy scripts
cp "$PROJECT_ROOT/services/ghostpi-auto-update.sh" /usr/local/bin/
cp "$PROJECT_ROOT/services/ghostpi-self-heal.sh" /usr/local/bin/
cp "$PROJECT_ROOT/helpers/ghostpi-helper.sh" /usr/local/bin/

# Make executable
chmod +x /usr/local/bin/ghostpi-*.sh

# Create directories
mkdir -p /opt/ghostpi/{updates,backups,repo}
mkdir -p /var/log

# Reload systemd
systemctl daemon-reload

# Enable services
systemctl enable auto-update.timer
systemctl enable self-healing.service

# Start services
systemctl start auto-update.timer
systemctl start self-healing.service

echo "✓ Auto-update and self-healing services installed and started"
echo ""
echo "Services:"
echo "  - auto-update.timer (runs daily)"
echo "  - self-healing.service (monitors continuously)"
echo ""
echo "Management:"
echo "  - ghostpi-helper (interactive management tool)"
echo "  - ghostpi-auto-update.sh (update commands)"
echo "  - ghostpi-self-heal.sh (repair commands)"

