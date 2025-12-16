# GhostPi - Wavy's World Bootable Image

A custom bootable Raspberry Pi image with dual boot splash themes, pentesting tools, and automatic swapfile management. Works on **CM4, CM5, Pi 4, and Pi 5**.

**Optimized for HackberryPi CM5** - Ultra portable handheld Linux device with 4" 720x720 TFT touch display and BlackBerry keyboard. See [HackberryPi CM5 Repository](https://github.com/ZitaoTech/HackberryPiCM5) for hardware details.

![GhostPi](https://img.shields.io/badge/GhostPi-Wavy's%20World-purple)
![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-CM4%20%7C%20CM5-red)
![License](https://img.shields.io/badge/License-MIT-green)

## 🎮 Features

- **Dual Boot Splash Themes**: 
  - **Wavy's World** (Purple/Black) - Default theme
  - **Wavy's World BlackArch Style** (Red/Black) - BlackArch-inspired theme
- **Universal Compatibility**: Works on CM4, CM5, Pi 4, Pi 5
- **HackberryPi CM5 Optimized**: Full support for HackberryPi CM5 hardware
- **AI Companion**: System monitoring with graphs (like Parrot OS)
- **Enhanced Terminal**: System info banner with kernel, firmware, battery, network stats
- **Pentesting Tools**: Pre-installed security testing suite (Kali, Parrot, BlackArch tools)
- **Swapfile Service**: Automatic swap management and monitoring
- **Flipper Zero Integration**: Auto-detection and auto-launch terminal
- **Update System**: Simple menu-driven updates (`wavy-update`)
- **Auto-Update & Self-Healing**: Fully automated system maintenance

## 🚀 Quick Start by Platform

### 📱 For Raspberry Pi / Debian (On Device)

**Method 1: Quick Install on Existing Raspberry Pi OS**

```bash
# SSH into your Pi
ssh pi@<PI_IP_ADDRESS>

# Install GhostPi
sudo apt-get update && \
sudo apt-get upgrade -y && \
sudo apt-get install -y git && \
cd ~ && \
git clone https://github.com/sowavy234/ghostpi.git && \
cd ghostpi && \
chmod +x scripts/*.sh && \
sudo ./scripts/quick_install.sh

# Reboot
sudo reboot
```

**Method 2: Build Image on Debian/Ubuntu Linux**

```bash
# Clone repository
git clone https://github.com/sowavy234/ghostpi.git
cd ghostpi

# Install dependencies
sudo apt-get update
sudo apt-get install -y python3 device-tree-compiler plymouth imagemagick git \
    dosfstools fdisk parted kpartx

# Build for CM5 (default)
sudo ./scripts/build_linux.sh CM5

# Or build for CM4
sudo ./scripts/build_linux.sh CM4

# Image will be in: ~/Downloads/ghostpi/GhostPi-*.img
```

**Method 3: Flash Pre-built Image**

1. Download from [Releases](https://github.com/sowavy234/ghostpi/releases)
2. Flash to SD card using Raspberry Pi Imager or dd
3. Insert into Pi and boot

### 🍎 For macOS

**Method 1: Use Docker (Recommended)**

```bash
# Prerequisites: Install Docker Desktop
# Download from: https://www.docker.com/products/docker-desktop

# Start Docker Desktop, then:
cd ~/Downloads/ghostpi
./scripts/build_mac.sh CM5

# Image will be in: ~/Downloads/ghostpi/GhostPi-*.img

# Flash to SD card
./scripts/flash_to_sd_mac.sh
```

**Method 2: Use GitHub Actions (No Local Build)**

1. Push code to GitHub (if not already)
2. Go to Actions tab → "Build GhostPi Images"
3. Click "Run workflow" → Select CM5
4. Download the .img file from artifacts
5. Flash using Raspberry Pi Imager

**Method 3: Use Linux VM**

```bash
# Copy repository to Linux VM
scp -r ~/Downloads/ghostpi user@vm-ip:~/

# SSH into VM and build
ssh user@vm-ip
cd ~/ghostpi
sudo ./scripts/build_linux.sh CM5

# Download image back to Mac
scp user@vm-ip:~/Downloads/ghostpi/GhostPi-*.img ~/Downloads/
```

**Method 4: Flash Existing Raspberry Pi OS and Install**

1. Use Raspberry Pi Imager to flash Raspberry Pi OS Lite 64-bit
2. Enable SSH in settings (gear icon)
3. SSH into Pi and run quick install (see Debian section above)

### 🐧 For Linux (Ubuntu/Debian)

**Build from Source:**

```bash
# Clone repository
git clone https://github.com/sowavy234/ghostpi.git
cd ghostpi

# Install dependencies
sudo apt-get update
sudo apt-get install -y \
    python3 python3-pip \
    device-tree-compiler \
    plymouth plymouth-themes \
    imagemagick \
    git \
    dosfstools \
    fdisk \
    parted \
    kpartx

# Build image
sudo ./scripts/build_linux.sh CM5

# Flash to SD card
sudo dd if=~/Downloads/ghostpi/GhostPi-*.img of=/dev/sdX bs=4M status=progress
sync
```

**Quick Install on Existing Pi:**

```bash
# On your Raspberry Pi
cd ~
git clone https://github.com/sowavy234/ghostpi.git
cd ghostpi
chmod +x scripts/*.sh
sudo ./scripts/quick_install.sh
sudo reboot
```

## 🎨 Dual Boot Splash Themes

GhostPi includes two boot splash themes that you can switch between:

### 1. Wavy's World (Default - Purple/Black)
- **Colors**: Dark purple and black space background
- **Style**: Animated character with purple/black theme
- **Theme**: Classic Wavy's World aesthetic

### 2. Wavy's World BlackArch Style (Red/Black)
- **Colors**: Dark red and black background (BlackArch-inspired)
- **Style**: Red-tinted character and animations
- **Theme**: Aggressive BlackArch Linux aesthetic

### Switch Between Themes

```bash
# On your Raspberry Pi
sudo ./scripts/switch_boot_splash.sh

# Select theme:
# 1. Wavy's World (Purple/Black)
# 2. Wavy's World BlackArch Style (Red/Black)

# Reboot to see new theme
sudo reboot
```

## 💾 Flashing the Image

### Using Raspberry Pi Imager (Easiest - All Platforms)

1. **Download Raspberry Pi Imager**: https://www.raspberrypi.com/software/
2. **Open Imager** → "Choose OS" → "Use custom image"
3. **Select** your `GhostPi-*.img` file
4. **Choose Storage** → Select your SD card
5. **Click Write** and wait for completion

### Using dd (Linux/macOS)

**Linux:**
```bash
# Find SD card
lsblk

# Unmount
sudo umount /dev/sdX*

# Flash
sudo dd if=GhostPi-*.img of=/dev/sdX bs=4M status=progress
sync
```

**macOS:**
```bash
# Find SD card
diskutil list

# Unmount
diskutil unmountDisk /dev/diskX

# Flash
sudo dd if=GhostPi-*.img of=/dev/rdiskX bs=4m
sync

# Eject
diskutil eject /dev/diskX
```

**Or use the helper script:**
```bash
./scripts/flash_to_sd_mac.sh
```

## 🔧 Dual Boot Configuration

GhostPi supports dual boot configuration with BlackArch tools integration:

```bash
# Install dual boot setup
sudo ./scripts/install_dual_boot.sh

# This will:
# - Install BlackArch-compatible tools
# - Create GRUB boot menu
# - Set up unified pentesting tools menu
# - Configure boot splash themes
```

After installation, you'll have:
- **Wavy's World** boot option (default)
- **BlackArch tools** integrated
- **Unified menu**: `wavys-world-menu.sh`

## 📦 What's Included

### Boot Splash Themes
- **Wavy's World**: Purple/black space theme with animated character
- **Wavy's World BlackArch**: Red/black theme inspired by BlackArch Linux
- Both themes include:
  - Animated 3D character with tattoos and Glock
  - Animated stars background
  - Pulsing text effects
  - Smooth animations

### Pentesting Tools
- **Information Gathering**: nmap, masscan, recon-ng, amass, theharvester
- **Vulnerability Assessment**: nikto, openvas, nuclei, wpscan, lynis
- **Web Application Analysis**: burpsuite, sqlmap, commix, wfuzz, gobuster
- **Password Attacks**: john, hashcat, hydra, medusa, crunch
- **Wireless Attacks**: aircrack-ng, reaver, wifite, bettercap
- **Exploitation Tools**: metasploit, exploitdb, routersploit
- **Post Exploitation**: powersploit, empire, veil
- **Forensics**: autopsy, volatility, binwalk, testdisk
- **Reverse Engineering**: radare2, ghidra, apktool

### System Services
- **Swapfile Manager**: Auto-creates and manages swapfile
- **Battery Monitor**: Real-time battery status (HackberryPi CM5)
- **AI Companion**: System monitoring with graphs
- **Auto-Update**: Automated system maintenance
- **Self-Healing**: Automatic service recovery

## 🎯 Platform-Specific Guides

### Debian/Raspberry Pi OS
- See `INSTALL_ON_PI_OS.md` for detailed installation guide
- See `QUICK_INSTALL_COMMANDS.txt` for quick reference

### macOS
- See `MAC_BUILD.md` for macOS build options
- See `BUILD_AND_FLASH.md` for complete build and flash guide
- Use `scripts/flash_to_sd_mac.sh` for easy SD card flashing

### Linux (Ubuntu/Debian)
- See `BUILD_NOW.md` for build instructions
- See `FLASHING_GUIDE.md` for flashing instructions

## 🔍 System Services

### Swapfile Service
```bash
# Check status
sudo systemctl status swapfile-manager.service

# Manual control
sudo /usr/local/bin/swapfile-manager.sh start
sudo /usr/local/bin/swapfile-manager.sh stop
sudo /usr/local/bin/swapfile-manager.sh status
```

### Battery Monitor (HackberryPi CM5)
```bash
# Check battery
battery-status

# View in terminal
wavy-terminal  # Shows battery in banner
```

### AI Companion
```bash
# Launch dashboard
wavy-companion

# Shows real-time graphs for:
# - CPU, Memory, Disk usage
# - Battery status
# - Network statistics
# - System health
```

## 🐛 Troubleshooting

### Build Issues

**Missing dependencies (Debian/Linux):**
```bash
sudo apt-get install python3 device-tree-compiler plymouth imagemagick git \
    dosfstools fdisk parted kpartx
```

**Docker not running (macOS):**
- Open Docker Desktop and wait for it to start
- Check: `docker ps` should work

**Not enough disk space:**
```bash
export BUILD_DIR=/path/to/large/disk
sudo ./scripts/build_linux.sh CM5
```

### Boot Splash Not Showing

```bash
# Switch theme
sudo ./scripts/switch_boot_splash.sh

# Update initramfs
sudo update-initramfs -u
sudo reboot
```

### Flash Issues

**SD card not detected:**
- Try different USB port
- Check SD card adapter
- Use Raspberry Pi Imager (most reliable)

**Image won't boot:**
- Verify image file isn't corrupted
- Use quality SD card (Class 10 or better)
- Minimum 16GB recommended
- Try re-flashing

## 📁 Project Structure

```
ghostpi/
├── README.md                    # This file
├── INSTALL_ON_PI_OS.md         # Debian/Pi installation guide
├── MAC_BUILD.md                # macOS build guide
├── BUILD_AND_FLASH.md          # Complete build/flash guide
├── QUICK_INSTALL_COMMANDS.txt  # Quick reference
├── scripts/
│   ├── build_linux.sh         # Linux build script
│   ├── build_mac.sh           # macOS build script (Docker)
│   ├── flash_to_sd_mac.sh     # macOS SD card flasher
│   ├── quick_install.sh       # Quick install on Pi
│   ├── switch_boot_splash.sh  # Switch boot themes
│   ├── install_dual_boot.sh   # Dual boot setup
│   └── wavy-update.sh         # Update system menu
├── boot-splash/
│   ├── wavys-world.plymouth   # Default theme (purple)
│   ├── wavys-world.script     # Default theme script
│   ├── wavys-world-blackarch.plymouth  # BlackArch theme
│   └── wavys-world-blackarch.script    # BlackArch theme script
├── terminal/                   # Enhanced terminal
├── ai-companion/              # AI companion
├── hackberry-cm5/             # HackberryPi CM5 support
├── flipper-zero/              # Flipper Zero integration
└── services/                  # System services
```

## 🤝 Contributing

Contributions welcome! Please:
1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## 📝 License

MIT License - see LICENSE file for details

## 🙏 Credits

- **HackberryPi CM5**: https://github.com/ZitaoTech/HackberryPiCM5
- **LinuxBootImageFileGenerator**: https://github.com/robseb/LinuxBootImageFileGenerator
- **Plymouth**: Boot splash system
- **Raspberry Pi Foundation**: Hardware support
- **Kali Linux, Parrot OS, BlackArch**: Pentesting tools

## 📧 Support

- **Issues**: https://github.com/sowavy234/ghostpi/issues
- **Discussions**: https://github.com/sowavy234/ghostpi/discussions
- **Releases**: https://github.com/sowavy234/ghostpi/releases

---

**Welcome to Wavy's World!** 🎮🔫✨

Made with ❤️ for the Raspberry Pi community
