# GhostPi - Wavy's World Bootable Image

A custom bootable Raspberry Pi image with 3D boot splash, pentesting tools, and automatic swapfile management. Works on **CM4, CM5, Pi 4, and Pi 5**.

![GhostPi](https://img.shields.io/badge/GhostPi-Wavy's%20World-purple)
![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-CM4%20%7C%20CM5-red)
![License](https://img.shields.io/badge/License-MIT-green)

## 🎮 Features

- **Custom 3D Boot Splash**: "Welcome to Wavy's World" with animated character, tattoos, and Glock
- **Universal Compatibility**: Works on CM4, CM5, Pi 4, Pi 5
- **Pentesting Tools**: Pre-installed security testing suite
- **Swapfile Service**: Automatic swap management and monitoring
- **Hardware Detection**: Auto-detects and configures for your Pi model

## 🚀 Quick Start

### On Linux (Ubuntu/Debian)

```bash
# Clone repository
git clone https://github.com/yourusername/ghostpi.git
cd ghostpi

# Build for CM5 (default)
sudo ./scripts/build_linux.sh CM5

# Or build for CM4
sudo ./scripts/build_linux.sh CM4
```

### On macOS

```bash
# Option 1: Use Docker (recommended)
./scripts/build_mac.sh CM5

# Option 2: Use Linux VM
# Copy folder to Ubuntu VM and run:
sudo ./BUILD_ON_LINUX.sh CM5

# Option 3: Use Raspberry Pi Imager
# Install Raspberry Pi OS, then run:
sudo ./scripts/quick_install.sh
```

## 📦 What's Included

### Boot Splash Theme
- **Background**: 3D black and purple space with animated stars
- **Character**: 3D animated character with:
  - Face tattoos/dermals
  - Love scars under right eye
  - Full arm, leg, and neck tattoos
  - Holding Glock with 30-round magazine
- **Text**: "Welcome to Wavy's World" and "Welcome to Glock's World Enjoy"

### Pentesting Tools
- Network scanners (nmap, masscan)
- Web testing tools (sqlmap, nikto, gobuster)
- Password crackers (john, hashcat, hydra)
- Exploitation frameworks (metasploit)
- Post-exploitation tools (LinPEAS, LinEnum)

### System Services
- **Swapfile Manager**: Automatically creates and manages swapfile
- **Hardware Detection**: Auto-configures for CM4/CM5
- **Boot Optimization**: Optimized for each Pi model

## 📋 Requirements

### Build System
- Linux (Ubuntu 22.04+ or Debian 11+)
- Python 3.7+
- Root/sudo access
- 10GB+ free disk space

### Runtime (Raspberry Pi)
- Raspberry Pi CM4, CM5, Pi 4, or Pi 5
- 16GB+ SD card
- Adequate power supply

## 🔧 Installation

### Method 1: Build from Source (Linux)

```bash
# Install dependencies
sudo apt-get update
sudo apt-get install -y python3 device-tree-compiler plymouth imagemagick git

# Build image
sudo ./scripts/build_linux.sh CM5
```

### Method 2: Docker (macOS/Linux)

```bash
./scripts/build_mac.sh CM5
```

### Method 3: Quick Install on Existing Pi

```bash
# On your Raspberry Pi
sudo ./scripts/quick_install.sh
```

## 💾 Flashing the Image

### Using dd (Linux/macOS)

```bash
# Find your SD card
lsblk  # or diskutil list (macOS)

# Flash image (REPLACE sdX with your device)
sudo dd if=GhostPi-CM5-*.img of=/dev/sdX bs=4M status=progress
sync
```

### Using Raspberry Pi Imager

1. Download: https://www.raspberrypi.com/software/
2. Select "Use custom image"
3. Choose your `GhostPi-*.img` file
4. Select SD card and write

## 🎨 Customization

### Replace Boot Splash Images

1. Create your 3D renders:
   - `character.png` (400x300px) - Character with tattoos and Glock
   - `glock.png` (200x100px) - Glock with 30-round magazine
   - `text_welcome.png` (600x100px) - "Welcome to Wavy's World"
   - `text_glock.png` (500x80px) - "Welcome to Glock's World Enjoy"
   - `star.png` (20x20px) - Star sprite

2. Copy to `boot-splash/` directory

3. Rebuild image:
   ```bash
   sudo ./scripts/build_linux.sh CM5
   ```

### Customize Animation

Edit `boot-splash/wavys-world.script` to adjust:
- Animation speed
- Character position
- Text effects
- Star count and movement

## 🔍 Swapfile Service

The swapfile service automatically:
- Creates 2GB swapfile on first boot
- Monitors memory usage every 30 seconds
- Increases swap if memory is low
- Prevents out-of-memory crashes

### Check Status

```bash
sudo systemctl status swapfile-manager
sudo /usr/local/bin/swapfile-manager.sh status
```

### View Logs

```bash
sudo journalctl -u swapfile-manager -f
cat /var/log/swapfile-manager.log
```

## 📁 Project Structure

```
ghostpi/
├── README.md                    # This file
├── QUICKSTART.md               # Quick start guide
├── INSTALL.md                  # Detailed installation
├── scripts/                    # Build scripts
│   ├── build_linux.sh         # Linux build script
│   ├── build_mac.sh           # macOS build script
│   └── quick_install.sh      # Quick install on Pi
├── boot-splash/               # Boot splash theme
│   ├── wavys-world.plymouth  # Plymouth config
│   └── wavys-world.script    # Animation script
└── services/                  # System services
    ├── swapfile-manager.service
    └── swapfile-manager.sh
```

## 🐛 Troubleshooting

### Build Fails

**Missing dependencies:**
```bash
sudo apt-get install python3 device-tree-compiler plymouth imagemagick
```

**Not enough disk space:**
```bash
export BUILD_DIR=/path/to/large/disk
sudo ./scripts/build_linux.sh CM5
```

### Boot Splash Not Showing

```bash
# Check Plymouth
plymouth --version

# Verify theme
ls /usr/share/plymouth/themes/wavys-world/

# Update initramfs
sudo update-initramfs -u
```

### Swapfile Service Issues

```bash
# Check service
sudo systemctl status swapfile-manager

# Manual start
sudo /usr/local/bin/swapfile-manager.sh start

# Check swap
free -h
swapon --show
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

- **LinuxBootImageFileGenerator**: https://github.com/robseb/LinuxBootImageFileGenerator
- **Plymouth**: Boot splash system
- **Raspberry Pi Foundation**: Hardware support

## 📧 Support

- **Issues**: https://github.com/yourusername/ghostpi/issues
- **Discussions**: https://github.com/yourusername/ghostpi/discussions

---

**Welcome to Wavy's World!** 🎮🔫✨

Made with ❤️ for the Raspberry Pi community
