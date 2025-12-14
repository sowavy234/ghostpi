# GhostPi Automated Monitoring Bot Guide

## 🤖 Overview

The GhostPi Automated Monitoring Bot is a fully automated system that:
- **Constantly monitors** system health (every 5 minutes)
- **Auto-detects problems** (services, disk, memory, network, files)
- **Auto-fixes issues** immediately when detected
- **Commits and pushes fixes** to GitHub automatically
- **Runs 24/7** without human intervention

## 🚀 Features

### Constant Monitoring
- Service status (swapfile-manager, auto-update, self-healing)
- Disk space usage
- Memory usage
- Network connectivity
- Critical file existence
- File permissions
- System updates availability

### Auto-Fix Capabilities
- Restart failed services
- Clean disk space when full
- Activate swapfile when needed
- Restore network connectivity
- Fix file permissions
- Update system components

### Automated Commits
- Commits fixes automatically
- Pushes to GitHub
- Generates reports
- Creates backup before changes

## 📦 Installation

### Automatic (Recommended)

Included in quick install:

```bash
sudo ./scripts/quick_install.sh
```

### Manual Installation

```bash
sudo ./scripts/install_bot.sh
```

## ⚙️ Configuration

### Enable/Disable Auto-Commit

Edit service file:

```bash
sudo nano /etc/systemd/system/ghostpi-bot.service
```

Change:
```ini
Environment="AUTO_COMMIT=true"   # Enable
Environment="AUTO_COMMIT=false"  # Disable
```

Then restart:
```bash
sudo systemctl daemon-reload
sudo systemctl restart ghostpi-bot.service
```

### Change Check Interval

Edit bot script:

```bash
sudo nano /usr/local/bin/ghostpi-bot.sh
```

Change:
```bash
CHECK_INTERVAL=300  # 5 minutes (default)
CHECK_INTERVAL=600  # 10 minutes
CHECK_INTERVAL=60   # 1 minute
```

Then restart:
```bash
sudo systemctl restart ghostpi-bot.service
```

## 🔐 GitHub Authentication

For automated commits to work, you need to set up authentication:

### Option 1: Personal Access Token

1. **Create Token:**
   - Go to: https://github.com/settings/tokens
   - Click "Generate new token (classic)"
   - Name: "GhostPi Bot"
   - Scopes: `repo` (full control)
   - Generate and copy token

2. **Set on System:**
   ```bash
   export GITHUB_TOKEN="your_token_here"
   sudo -E ./scripts/install_bot.sh
   ```

### Option 2: SSH Keys

```bash
# Generate SSH key for bot
ssh-keygen -t ed25519 -f ~/.ssh/ghostpi_bot -N ""

# Add to GitHub
cat ~/.ssh/ghostpi_bot.pub
# Add to: https://github.com/settings/keys

# Configure git to use SSH
cd /opt/ghostpi/repo
git remote set-url origin git@github.com:sowavy234/ghostpi.git
```

### Option 3: GitHub Actions (Recommended)

The bot runs automatically via GitHub Actions:
- No authentication needed
- Runs every 6 hours
- Checks repository health
- Auto-fixes issues
- Commits and pushes

## 📊 Usage

### Check Bot Status

```bash
# Service status
systemctl status ghostpi-bot.service

# Bot status
ghostpi-bot.sh status

# View logs
tail -f /var/log/ghostpi-bot.log
```

### Manual Operations

```bash
# Run single check
sudo ghostpi-bot.sh check

# Start monitoring
sudo ghostpi-bot.sh monitor

# View status
ghostpi-bot.sh status
```

### Service Control

```bash
# Start bot
sudo systemctl start ghostpi-bot.service

# Stop bot
sudo systemctl stop ghostpi-bot.service

# Restart bot
sudo systemctl restart ghostpi-bot.service

# Enable on boot
sudo systemctl enable ghostpi-bot.service

# Disable on boot
sudo systemctl disable ghostpi-bot.service
```

## 🔍 What Gets Monitored

### Services
- `swapfile-manager.service`
- `auto-update.service`
- `self-healing.service`

### System Resources
- Disk usage (warns at 85%, cleans at 90%)
- Memory usage (warns at 90%)
- Network connectivity

### Files
- `/boot/config.txt`
- `/usr/local/bin/ghostpi-*.sh`
- Script permissions

### Updates
- Checks GitHub for new commits
- Pulls and installs updates automatically

## 📝 Automated Commits

### What Gets Committed

The bot commits:
- Fixed file permissions
- System health reports
- Configuration fixes
- Service restarts (logged)

### Commit Format

```
Automated fix: System maintenance YYYY-MM-DD

- Auto-fixed system issues
- Health check completed
- Report: ghostpi-bot-report-TIMESTAMP.txt

[Automated by GhostPi Bot]
```

### When Commits Happen

- After health check finds and fixes issues
- Only if there are actual changes
- Only if network is available
- Respects AUTO_COMMIT setting

## 🛡️ Safety Features

- **Backups**: Creates backups before updates
- **Verification**: Checks network before push
- **Logging**: All actions logged
- **Error Handling**: Continues on errors
- **Rate Limiting**: Respects GitHub rate limits

## 📈 GitHub Actions Integration

The bot also runs via GitHub Actions:

- **Schedule**: Every 6 hours
- **Manual**: Can be triggered manually
- **Checks**: Repository health
- **Fixes**: Auto-fixes issues
- **Commits**: Pushes fixes automatically

View at: https://github.com/sowavy234/ghostpi/actions

## 🔧 Troubleshooting

### Bot Not Running

```bash
# Check service
systemctl status ghostpi-bot.service

# Check logs
journalctl -u ghostpi-bot.service -f

# Restart
sudo systemctl restart ghostpi-bot.service
```

### Commits Not Pushing

```bash
# Check authentication
cd /opt/ghostpi/repo
git remote -v

# Test push
git push origin main

# Check token
echo $GITHUB_TOKEN
```

### Too Many Commits

```bash
# Disable auto-commit
sudo systemctl edit ghostpi-bot.service
# Add: Environment="AUTO_COMMIT=false"
sudo systemctl daemon-reload
sudo systemctl restart ghostpi-bot.service
```

## 📋 Logs

All bot activity is logged:

```bash
# View live logs
tail -f /var/log/ghostpi-bot.log

# View recent activity
tail -50 /var/log/ghostpi-bot.log

# Search for errors
grep ERROR /var/log/ghostpi-bot.log
```

## 🎯 Best Practices

1. **Let it run** - The bot is designed to be fully automated
2. **Monitor logs** - Check logs weekly for any issues
3. **Set up authentication** - For automated commits to work
4. **Review commits** - Check automated commits periodically
5. **Adjust intervals** - Tune check interval for your needs

## 🚀 Quick Start

```bash
# Install everything (includes bot)
sudo ./scripts/quick_install.sh

# Check bot status
systemctl status ghostpi-bot.service

# View logs
tail -f /var/log/ghostpi-bot.log
```

---

**Your GhostPi system is now fully automated!** 🤖

The bot will:
- ✅ Monitor constantly
- ✅ Fix issues automatically
- ✅ Commit and push fixes
- ✅ Keep system healthy
- ✅ Run 24/7

Just install and forget! 🎉

