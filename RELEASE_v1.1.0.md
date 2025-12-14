# GhostPi v1.1.0 Release Notes

## 🎉 Major Update: Auto-Update & Self-Healing

### 🆕 New Features

#### Auto-Update System
- **Automatic Daily Updates**: System packages updated automatically
- **GhostPi Updates**: Pulls latest code from GitHub repository
- **Smart Scheduling**: Runs at random times to avoid conflicts
- **Backup System**: Creates backups before any updates
- **Health Checks**: Runs after each update to ensure stability

#### Self-Healing System
- **Service Monitoring**: Automatically detects and restarts failed services
- **Disk Management**: Cleans up when disk space is low
- **Network Repair**: Fixes network connectivity issues automatically
- **Permission Fixes**: Corrects file permission problems
- **Swapfile Management**: Ensures swapfile is always active
- **Boot Config Repair**: Fixes boot configuration issues
- **Continuous Monitoring**: Runs health checks every 5 minutes

#### Management Helper
- **Interactive Menu**: Easy-to-use management interface
- **System Status**: View all system information at a glance
- **Service Control**: Start/stop/restart any service
- **Health Checks**: Run manual health checks
- **Network Tools**: Test connectivity, view interfaces
- **Disk Management**: Clean cache, logs, temp files
- **Boot Configuration**: View and edit config.txt
- **Log Viewer**: View all GhostPi logs
- **Advanced Tools**: System diagnostics and repair

### 📦 What's Included

**Services:**
- `auto-update.service` - Update service
- `auto-update.timer` - Daily update schedule
- `self-healing.service` - Continuous monitoring
- `swapfile-manager.service` - Swap management (existing)

**Scripts:**
- `ghostpi-auto-update.sh` - Update commands
- `ghostpi-self-heal.sh` - Repair commands
- `ghostpi-helper.sh` - Interactive management tool
- `install_auto_update.sh` - Installation script

**Documentation:**
- `AUTO_UPDATE_GUIDE.md` - Complete guide
- Updated `quick_install.sh` - Includes auto-update

### 🚀 Quick Start

```bash
# Install everything (includes auto-update)
sudo ./scripts/quick_install.sh

# Use management helper
ghostpi-helper

# Manual update
sudo ghostpi-auto-update.sh update

# Manual repair
sudo ghostpi-self-heal.sh repair
```

### 📊 What Gets Monitored

- ✅ Service status (auto-restart if down)
- ✅ Disk space (cleanup at 90%)
- ✅ Memory usage (warnings at 90%)
- ✅ Network connectivity (auto-repair)
- ✅ File permissions (auto-fix)
- ✅ Swapfile status (ensure active)
- ✅ Boot configuration (repair if needed)

### 🔄 Update Schedule

- **First Update**: 1 hour after boot
- **Regular Updates**: Every 24 hours
- **Random Delay**: Up to 1 hour to avoid conflicts
- **Health Checks**: Every 5 minutes

### 📝 Logs

All activities are logged:
- `/var/log/ghostpi-auto-update.log` - Update activities
- `/var/log/ghostpi-self-heal.log` - Repair activities
- `/var/log/swapfile-manager.log` - Swap management

View logs:
```bash
ghostpi-helper  # Then select "View Logs"
```

### 🛡️ Safety Features

- Backups created before updates
- Rollback capability if updates fail
- Verification before installation
- Logging of all activities
- Requires root/sudo for updates

### 📈 Improvements

- Better error handling
- More comprehensive health checks
- Enhanced logging
- Improved service management
- Complete documentation

### 🔧 Configuration

All services are enabled by default. To disable:

```bash
sudo systemctl disable auto-update.timer
sudo systemctl disable self-healing.service
```

To customize schedules, edit:
- `/etc/systemd/system/auto-update.timer`
- `/usr/local/bin/ghostpi-self-heal.sh`

### 📚 Documentation

See `AUTO_UPDATE_GUIDE.md` for complete documentation.

---

## Installation

### New Installation

```bash
git clone https://github.com/sowavy234/ghostpi.git
cd ghostpi
sudo ./scripts/quick_install.sh
```

### Update Existing Installation

```bash
cd ~/ghostpi
git pull origin main
sudo ./scripts/install_auto_update.sh
```

---

**Your GhostPi system is now fully self-managing!** 🎉

The system will:
- ✅ Update itself daily
- ✅ Fix issues automatically
- ✅ Maintain optimal performance
- ✅ Keep itself healthy
- ✅ Provide easy management tools

Just install and let it run! 🚀

