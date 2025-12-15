# Flipper Zero Integration Guide

## 🐬 Complete Flipper Zero Companion System

GhostPi now includes full Flipper Zero integration with automatic detection, code sync, brute force tools, Marauder support, and AI coding assistant.

## ✨ Features

### 🤖 Automatic Detection
- **Auto-recognizes** Flipper Zero when connected
- **Companion service** runs 24/7
- **Instant sync** when device connects
- **Service management** automatic

### 🔄 Bidirectional Code Sync
- **Push to Flipper**: Send apps, scripts, tools
- **Pull from Flipper**: Get code and apps
- **Automatic sync** on connection
- **Backup system** before changes

### 🔓 Brute Force Tools (Educational)
- **Guided walkthrough** for each attack
- **WiFi password cracking** (WPA/WPA2)
- **SSH/FTP brute force**
- **PIN brute force** (RFID/NFC/Bluetooth)
- **Custom wordlists**
- **BadUSB scripts**
- **Educational warnings**

### 📡 Marauder WiFi Dev Board
- **ESP32 detection**
- **Firmware flashing**
- **Attack automation**
- **Handshake capture**
- **Evil Twin support**

### 🔨 FBT Build System
- **Flipper Build Tool** integration
- **App templates**
- **Build automation**
- **FAP deployment**

### 🤖 AI Coding Assistant
- **Code generation** from descriptions
- **Code explanation**
- **Refactoring**
- **Bug fixing**
- **Like Copilot/Claude**

## 🚀 Installation

```bash
cd ~/Downloads/ghostpi
sudo ./scripts/install_flipper.sh
```

Or included in full install:
```bash
sudo ./scripts/quick_install.sh
```

## 📖 Usage

### Connect Flipper Zero

1. **Plug in Flipper Zero** via USB
2. **Automatic detection** - Companion recognizes it
3. **Code syncs** - Apps transfer automatically
4. **Ready!**

### Check Connection

```bash
flipper-detector.sh
```

### Sync Code

```bash
# Push to Flipper
flipper-sync.sh push

# Pull from Flipper
flipper-sync.sh pull

# Both ways
flipper-sync.sh sync
```

### Brute Force Helper

```bash
brute-force-helper.sh
```

Interactive menu with:
- WiFi attacks
- SSH/FTP brute force
- PIN cracking
- RFID/NFC
- BadUSB
- Wordlists

### Marauder Attacks

```bash
# Setup
marauder-setup.sh install

# Flash
marauder-setup.sh flash /dev/ttyUSB0

# Attack
marauder-setup.sh attack beacon
```

### Build Apps

```bash
# Install FBT
fbt-build-helper.sh install

# Create app
fbt-build-helper.sh create MyApp

# Build
fbt-build-helper.sh build MyApp

# AI generate
fbt-build-helper.sh ai "RFID reader" c
```

### AI Assistant

```bash
# Interactive
ai-coding-assistant.sh interactive

# Generate
ai-coding-assistant.sh generate "WiFi scanner" c

# Explain
ai-coding-assistant.sh explain app.c
```

## ⚠️ Educational Use

All tools are for **EDUCATIONAL PURPOSES ONLY**:
- Only on systems you own
- Explicit permission required
- Unauthorized access is illegal
- Use responsibly

## 📁 Files

All Flipper Zero tools in: `flipper-zero/`

See `flipper-zero/README.md` for complete documentation.

---

**Connect your Flipper Zero and start exploring!** 🐬

