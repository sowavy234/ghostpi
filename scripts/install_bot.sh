#!/bin/bash
# Install GhostPi Automated Monitoring Bot

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "Installing GhostPi Automated Monitoring Bot..."

# Copy bot script
cp "$PROJECT_ROOT/bots/automated-monitor/ghostpi-bot.sh" /usr/local/bin/
chmod +x /usr/local/bin/ghostpi-bot.sh

# Copy service file
cp "$PROJECT_ROOT/services/ghostpi-bot.service" /etc/systemd/system/

# Create directories
mkdir -p /opt/ghostpi/{repo,backups}
mkdir -p /var/log

# Setup git for bot (if not exists)
if [ ! -d "/opt/ghostpi/repo/.git" ]; then
    mkdir -p /opt/ghostpi/repo
    cd /opt/ghostpi/repo
    git init
    git remote add origin https://github.com/sowavy234/ghostpi.git 2>/dev/null || true
fi

# Setup GitHub token (if provided via environment)
if [ -n "$GITHUB_TOKEN" ]; then
    cd /opt/ghostpi/repo
    git config --global credential.helper store
    echo "https://${GITHUB_TOKEN}@github.com" > ~/.git-credentials
    chmod 600 ~/.git-credentials
fi

# Reload systemd
systemctl daemon-reload

# Enable and start service
systemctl enable ghostpi-bot.service
systemctl start ghostpi-bot.service

echo "✓ GhostPi Bot installed and started"
echo ""
echo "Bot will:"
echo "  - Monitor system every 5 minutes"
echo "  - Auto-fix detected issues"
echo "  - Commit and push fixes (if enabled)"
echo ""
echo "Check status:"
echo "  systemctl status ghostpi-bot.service"
echo ""
echo "View logs:"
echo "  tail -f /var/log/ghostpi-bot.log"
echo ""
echo "Manual check:"
echo "  ghostpi-bot.sh check"

