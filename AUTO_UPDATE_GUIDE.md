# GhostPi Auto-Update & Self-Healing Guide

## 🚀 Features

### Auto-Update System
- **Automatic Updates**: Updates system packages daily
- **GhostPi Updates**: Pulls latest code from GitHub
- **Health Checks**: Runs after each update
- **Backup System**: Creates backups before updates
- **Smart Scheduling**: Runs at random times to avoid conflicts

### Self-Healing System
- **Service Monitoring**: Automatically restarts failed services
- **Disk Space Management**: Cleans up when disk is full
- **Network Repair**: Fixes network connectivity issues
- **Permission Fixes**: Corrects file permission problems
- **Swapfile Management**: Ensures swapfile is always active
- **Boot Config Repair**: Fixes boot configuration issues

### Management Helper
- **Interactive Menu**: Easy-to-use management interface
- **System Status**: View all system information
- **Service Control**: Start/stop/restart services
- **Health Checks**: Run manual health checks
- **Log Viewer**: View all GhostPi logs
- **Advanced Tools**: System diagnostics and repair

## 📦 Installation

### Automatic (Recommended)

The auto-update and self-healing services are automatically installed when you run:

```bash
sudo ./scripts/quick_install.sh
```

### Manual Installation

```bash
sudo ./scripts/install_auto_update.sh
```

## 🔧 Usage

### Management Helper (Interactive)

```bash
ghostpi-helper
```

This opens an interactive menu with all management options:
- System Status
- Update System
- Health Check
- Repair System
- Service Management
- Network Tools
- Disk Management
- Boot Configuration
- View Logs
- Advanced Options

### Auto-Update Commands

```bash
# Manual update
sudo ghostpi-auto-update.sh update

# Check for updates only
sudo ghostpi-auto-update.sh check

# Force update (re-download everything)
sudo ghostpi-auto-update.sh force

# Check update status
ghostpi-auto-update.sh status
```

### Self-Healing Commands

```bash
# Run repair once
sudo ghostpi-self-heal.sh repair

# Start monitoring (runs continuously)
sudo ghostpi-self-heal.sh monitor

# Check status
ghostpi-self-heal.sh status
```

## ⚙️ Configuration

### Auto-Update Schedule

The auto-update timer runs:
- **First run**: 1 hour after boot
- **Regular runs**: Every 24 hours
- **Random delay**: Up to 1 hour to avoid conflicts

To change schedule, edit `/etc/systemd/system/auto-update.timer`:

```ini
[Timer]
OnBootSec=1h          # First run after boot
OnUnitActiveSec=24h    # Regular interval
RandomizedDelaySec=1h # Random delay
```

Then reload:
```bash
sudo systemctl daemon-reload
sudo systemctl restart auto-update.timer
```

### Self-Healing Interval

Health checks run every 5 minutes by default.

To change, edit `/usr/local/bin/ghostpi-self-heal.sh`:

```bash
HEALTH_CHECK_INTERVAL=300  # Change to desired seconds
```

Then restart:
```bash
sudo systemctl restart self-healing.service
```

## 📊 Monitoring

### View Logs

```bash
# Auto-update log
tail -f /var/log/ghostpi-auto-update.log

# Self-healing log
tail -f /var/log/ghostpi-self-heal.log

# All logs
ghostpi-helper  # Then select "View Logs"
```

### Service Status

```bash
# Check all services
systemctl status swapfile-manager auto-update self-healing

# Check timers
systemctl list-timers auto-update.timer
```

## 🔍 What Gets Updated

### System Packages
- All apt packages
- Security updates
- System dependencies

### GhostPi Components
- Boot splash theme
- Management scripts
- Service files
- Helper tools
- Documentation

### What's Backed Up
Before updates, the system backs up:
- GhostPi scripts (`/usr/local/bin/ghostpi-*`)
- Boot splash theme
- Service files
- Configuration files

Backups stored in: `/opt/ghostpi/backups/`

## 🛠️ Troubleshooting

### Auto-Update Not Running

```bash
# Check timer status
systemctl status auto-update.timer

# Check service status
systemctl status auto-update.service

# View logs
journalctl -u auto-update.service -f

# Manually trigger
sudo ghostpi-auto-update.sh update
```

### Self-Healing Not Working

```bash
# Check service
systemctl status self-healing.service

# View logs
tail -f /var/log/ghostpi-self-heal.log

# Manual repair
sudo ghostpi-self-heal.sh repair
```

### Update Fails

```bash
# Check network connectivity
ping -c 3 8.8.8.8

# Check GitHub access
curl -I https://github.com/sowavy234/ghostpi

# Force update
sudo ghostpi-auto-update.sh force
```

## 🔐 Security

- Updates are verified before installation
- Backups created before any changes
- Rollback capability if updates fail
- Logs all update activities
- Requires root/sudo for updates

## 📈 Health Monitoring

The self-healing system monitors:
- ✅ Service status
- ✅ Disk space (warns at 90%)
- ✅ Memory usage (warns at 90%)
- ✅ Network connectivity
- ✅ File permissions
- ✅ Swapfile status
- ✅ Boot configuration

## 🎯 Best Practices

1. **Let it run automatically** - The system is designed to manage itself
2. **Check logs regularly** - Review logs weekly for any issues
3. **Manual updates** - Use `ghostpi-helper` for manual control
4. **Backup before major changes** - System creates backups automatically
5. **Monitor disk space** - Self-healing cleans up, but monitor manually too

## 🚀 Quick Start

```bash
# Install everything
sudo ./scripts/quick_install.sh

# Use management helper
ghostpi-helper

# Check status
systemctl status auto-update.timer self-healing.service
```

---

**Your GhostPi system is now self-managing and self-healing!** 🎉

The system will automatically:
- Update itself daily
- Fix issues as they occur
- Maintain optimal performance
- Keep itself healthy

Just let it run! 🚀

