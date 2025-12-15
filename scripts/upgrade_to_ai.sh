#!/bin/bash
# Upgrade to AI-Powered Services 2025
# Migrates from standard services to next-generation AI versions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     Upgrading to AI-Powered Services 2025                     ║"
echo "║     Next-Generation Self-Healing & Monitoring                ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Install AI services
echo "Installing AI-powered services..."

# Copy AI scripts
cp "$PROJECT_ROOT/services/swapfile-manager-ai.sh" /usr/local/bin/
cp "$PROJECT_ROOT/services/ghostpi-self-heal-ai.sh" /usr/local/bin/
cp "$PROJECT_ROOT/bots/automated-monitor/ghostpi-bot-ai.sh" /usr/local/bin/
chmod +x /usr/local/bin/*-ai.sh

# Install systemd services
cp "$PROJECT_ROOT/services/swapfile-manager-ai.service" /etc/systemd/system/
cp "$PROJECT_ROOT/services/self-healing-ai.service" /etc/systemd/system/
cp "$PROJECT_ROOT/services/ghostpi-bot-ai.service" /etc/systemd/system/

# Stop old services
systemctl stop swapfile-manager.service 2>/dev/null || true
systemctl stop self-healing.service 2>/dev/null || true
systemctl stop ghostpi-bot.service 2>/dev/null || true

# Disable old services
systemctl disable swapfile-manager.service 2>/dev/null || true
systemctl disable self-healing.service 2>/dev/null || true
systemctl disable ghostpi-bot.service 2>/dev/null || true

# Enable AI services
systemctl daemon-reload
systemctl enable swapfile-manager-ai.service
systemctl enable self-healing-ai.service
systemctl enable ghostpi-bot-ai.service

# Start AI services
systemctl start swapfile-manager-ai.service
systemctl start self-healing-ai.service
systemctl start ghostpi-bot-ai.service

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║     ✓ Upgrade Complete!                                       ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "AI-Powered Services Active:"
echo "  ✓ AI Swapfile Manager (ML optimization)"
echo "  ✓ AI Self-Healing System (predictive maintenance)"
echo "  ✓ AI Monitoring Bot (anomaly detection)"
echo ""
echo "Features:"
echo "  - Machine Learning-powered optimization"
echo "  - Predictive failure prevention"
echo "  - Real-time anomaly detection"
echo "  - Quantum-inspired optimization"
echo "  - Advanced dependency resolution"
echo ""

