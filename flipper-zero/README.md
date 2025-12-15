# Flipper Zero Integration for GhostPi

Complete Flipper Zero companion system with automatic detection, code sync, brute force tools, Marauder support, and AI coding assistant.

## 🎯 Features

### Automatic Detection
- **Auto-recognizes Flipper Zero** when connected via USB
- **Companion service** runs continuously
- **Automatic code sync** when Flipper connects
- **Service management** starts/stops tools automatically

### Bidirectional Code Sync
- **Push to Flipper**: Send apps, scripts, and tools from HackberryPi
- **Pull from Flipper**: Get code and apps from Flipper Zero
- **Automatic sync** when device connects
- **Conflict resolution** and backup system

### Brute Force Tools (Educational)
- **Guided walkthrough** for each attack type
- **WiFi password cracking** (WPA/WPA2)
- **SSH/FTP brute force** with wordlists
- **PIN brute force** for RFID/NFC/Bluetooth
- **Custom wordlist generator**
- **BadUSB script generator**
- **Educational warnings** and responsible use reminders

### Marauder WiFi Dev Board
- **Automatic detection** of ESP32 Marauder boards
- **Firmware flashing** support
- **Attack automation** (beacon spam, deauth, etc.)
- **Handshake capture** integration
- **Evil Twin** attack support

### FBT Build System
- **Flipper Build Tool** integration
- **App template generator**
- **Build automation** for Flipper Zero apps
- **FAP file generation**
- **Easy deployment** to Flipper

### AI Coding Assistant
- **Code generation** from descriptions
- **Code explanation**
- **Refactoring support**
- **Bug fixing assistance**
- **Like Copilot/Claude** for Flipper development

## 🚀 Quick Start

### Installation

```bash
cd ~/Downloads/ghostpi
sudo ./scripts/install_flipper.sh
```

This installs:
- Flipper Zero detection
- Companion service
- Brute force tools
- Marauder support
- FBT build system
- AI coding helper

### Connect Flipper Zero

1. **Connect Flipper Zero** via USB to HackberryPi
2. **Automatic detection** - Companion service recognizes it
3. **Code syncs automatically** - Apps and scripts transfer
4. **Ready to use!**

## 📖 Usage

### Check Flipper Connection

```bash
flipper-detector.sh
```

### Sync Code

```bash
# Push code to Flipper
flipper-sync.sh push

# Pull code from Flipper
flipper-sync.sh pull

# Bidirectional sync
flipper-sync.sh sync
```

### Brute Force Helper

```bash
brute-force-helper.sh
```

Interactive menu with guided walkthrough for:
- WiFi attacks
- SSH/FTP brute force
- PIN cracking
- RFID/NFC attacks
- BadUSB scripts
- Custom wordlists

### Marauder WiFi Attacks

```bash
# Setup Marauder
marauder-setup.sh install

# Flash firmware
marauder-setup.sh flash /dev/ttyUSB0

# Run attack
marauder-setup.sh attack beacon
```

### Build Flipper Apps

```bash
# Install FBT
fbt-build-helper.sh install

# Create app template
fbt-build-helper.sh create MyApp

# Build app
fbt-build-helper.sh build MyApp

# AI code generation
fbt-build-helper.sh ai "Create RFID reader app" c
```

### AI Coding Assistant

```bash
# Interactive mode
ai-coding-assistant.sh interactive

# Generate code
ai-coding-assistant.sh generate "WiFi scanner" c

# Explain code
ai-coding-assistant.sh explain myapp.c
```

## 🔧 Configuration

### Companion Service

The companion service runs automatically and:
- Monitors for Flipper Zero connection
- Syncs code when connected
- Starts brute force helper
- Manages services

Control:
```bash
sudo systemctl start flipper-companion.service
sudo systemctl stop flipper-companion.service
sudo systemctl status flipper-companion.service
```

### Auto-Sync Settings

Edit `/usr/local/bin/flipper-companion.sh` to adjust:
- Check interval (default: 10 seconds)
- Sync behavior
- Service management

## 📁 Directory Structure

```
flipper-zero/
├── flipper-detector.sh          # Auto-detection
├── flipper-sync.sh              # Code sync
├── flipper-companion.sh         # Companion service
├── brute-force/
│   └── brute-force-helper.sh   # Brute force tools
├── marauder/
│   └── marauder-setup.sh       # Marauder support
├── fbt/
│   └── fbt-build-helper.sh     # FBT build system
└── helpers/
    └── ai-coding-assistant.sh  # AI coding helper
```

## ⚠️ Educational Use Only

All brute force and attack tools are for **EDUCATIONAL PURPOSES ONLY**.

- Only use on systems you own or have explicit permission
- Unauthorized access is illegal
- You are responsible for your actions
- Use responsibly and ethically

## 🔐 Security

- All tools require explicit confirmation
- Educational warnings displayed
- Logging of all activities
- Responsible use reminders

## 📚 Documentation

- **Brute Force Guide**: See `brute-force-helper.sh --help`
- **Marauder Guide**: See `marauder-setup.sh --help`
- **FBT Guide**: See `fbt-build-helper.sh --help`
- **AI Assistant**: See `ai-coding-assistant.sh --help`

---

**Welcome to Flipper Zero integration!** Connect your Flipper and start exploring! 🐬

