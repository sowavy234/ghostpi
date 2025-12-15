#!/bin/bash
# Install GhostPi 2025 Advanced Services
# Next-generation self-healing and monitoring
# EDUCATIONAL PURPOSES ONLY

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "  Installing GhostPi 2025 Services"
echo "  Next-Generation Self-Healing"
echo "=========================================="

# Install advanced swapfile manager
echo "Installing Advanced Swapfile Manager 2025..."
cp "$PROJECT_ROOT/services/swapfile-manager-2025.sh" /usr/local/bin/
chmod +x /usr/local/bin/swapfile-manager-2025.sh
cp "$PROJECT_ROOT/services/swapfile-manager-2025.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable swapfile-manager-2025.service
systemctl stop swapfile-manager.service 2>/dev/null || true  # Stop old service
systemctl start swapfile-manager-2025.service

# Install advanced bot
echo "Installing Advanced Bot 2025..."
cp "$PROJECT_ROOT/bots/automated-monitor/ghostpi-bot-2025.sh" /usr/local/bin/
chmod +x /usr/local/bin/ghostpi-bot-2025.sh
cp "$PROJECT_ROOT/services/ghostpi-bot-2025.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable ghostpi-bot-2025.service
systemctl stop ghostpi-bot.service 2>/dev/null || true  # Stop old service
systemctl start ghostpi-bot-2025.service

# Install advanced self-healing
echo "Installing Advanced Self-Healing 2025..."
cp "$PROJECT_ROOT/services/ghostpi-self-heal-2025.sh" /usr/local/bin/
chmod +x /usr/local/bin/ghostpi-self-heal-2025.sh
cp "$PROJECT_ROOT/services/self-healing-2025.service" /etc/systemd/system/
systemctl daemon-reload
systemctl enable self-healing-2025.service
systemctl stop self-healing.service 2>/dev/null || true  # Stop old service
systemctl start self-healing-2025.service

# Install dependencies
echo "Installing dependencies..."
apt-get update -qq
apt-get install -y jq bc sqlite3 2>/dev/null || true

# Create metrics directory
mkdir -p /var/lib/ghostpi
mkdir -p /opt/ghostpi/backups

echo ""
echo "=========================================="
echo "✓ GhostPi 2025 Services Installed!"
echo "=========================================="
echo ""
echo "Features:"
echo "  - AI-Powered Memory Management"
echo "  - Predictive Failure Detection"
echo "  - Anomaly Detection"
echo "  - Zero-Downtime Updates"
echo "  - Advanced Service Recovery"
echo "  - Network Resilience"
echo "  - Performance Optimization"
echo ""
echo "Services:"
echo "  - swapfile-manager-2025.service"
echo "  - ghostpi-bot-2025.service"
echo "  - self-healing-2025.service"
echo ""

