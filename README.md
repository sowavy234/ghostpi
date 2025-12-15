# GhostPi - Wavy's World Bootable Image

A custom bootable Raspberry Pi image with 3D boot splash, pentesting tools, and automatic swapfile management. Works on **CM4, CM5, Pi 4, and Pi 5**.

**Optimized for HackberryPi CM5** - Ultra portable handheld Linux device with 4" 720x720 TFT touch display and BlackBerry keyboard. See [HackberryPi CM5 Repository](https://github.com/ZitaoTech/HackberryPiCM5) for hardware details.

![GhostPi](https://img.shields.io/badge/GhostPi-Wavy's%20World-purple)
![Raspberry Pi](https://img.shields.io/badge/Raspberry%20Pi-CM4%20%7C%20CM5-red)
![License](https://img.shields.io/badge/License-MIT-green)

## 🎮 Features

- **Custom 3D Boot Splash**: "Welcome to Wavy's World" with animated character, tattoos, and Glock
- **Universal Compatibility**: Works on CM4, CM5, Pi 4, Pi 5
- **HackberryPi CM5 Optimized**: Full support for HackberryPi CM5 hardware
  - **Power Management**: Call button = Power On, Call End button = Power Off/Shutdown
  - **Touchscreen**: 4" 720x720 TFT touch display fully configured
  - **Keyboard**: BlackBerry Q10/Q20/9900 keyboard support
  - **Battery Monitoring**: I2C-based voltage measurement with real-time status
  - **LED Control**: Custom notification patterns (heartbeat, breathing, etc.)
  - **Speaker Notifications**: Audio alerts for system events
- **AI Companion**: System monitoring with graphs (like Parrot OS)
  - Real-time CPU, Memory, Disk usage visualization
  - Battery status integration
  - Network statistics
  - Health analysis and warnings
- **Enhanced Terminal**: System info banner with kernel, firmware, battery, network stats
- **Pentesting Tools**: Pre-installed security testing suite (Kali, Parrot, BlackArch tools)
- **Swapfile Service**: Automatic swap management and monitoring
- **Hardware Detection**: Auto-detects and configures for your Pi model
- **Flipper Zero Integration**: 
  - Auto-detection and auto-launch terminal when connected
  - Coding help and tool usage guides
  - Code sync, brute force tools, Marauder support
  - Flipper Buddy app
- **Update System**: Simple menu-driven updates (`wavy-update`)
- **Auto-Update & Self-Healing**: Fully automated system maintenance
- **AI Coding Assistant**: Like Copilot/Claude for Flipper development

## 🚀 Quick Start

### Installation Sequence for HackberryPi CM5

1. **Flash the image** to SD card (see Flashing section below)
2. **Insert SD card** into HackberryPi CM5
3. **Power on** using the **Call button** (top left)
4. **First boot** will:
   - Configure touchscreen (720x720)
   - Set up power management
   - Install pentesting tools
   - Configure Flipper Zero integration
5. **Calibrate touchscreen** (if needed):
   ```bash
   sudo calibrate-touchscreen.sh
   ```
6. **Power off** by holding **Call End button** for 3 seconds

### On Linux (Ubuntu/Debian)

```bash
# Clone repository
git clone https://github.com/sowavy234/ghostpi.git
cd ghostpi

# Build for CM5 (default) - Optimized for HackberryPi CM5
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

### HackberryPi CM5 Specific
- **Hardware**: HackberryPi CM5 device (see [HackberryPi CM5 Repository](https://github.com/ZitaoTech/HackberryPiCM5))
- **Display**: 4" 720x720 TFT touch display (included)
- **Keyboard**: BlackBerry Q10, Q20, or 9900 keyboard
- **Power**: 5000mAh LiPo battery (included)
- **Buttons**: Call button (power on), Call End button (power off)

## 🔧 Installation

### HackberryPi CM5 Installation Sequence

1. **Download/Clone** this repository
2. **Build the image**:
   ```bash
   sudo ./scripts/build_linux.sh CM5
   ```
3. **Flash to SD card** (see Flashing section)
4. **Insert SD card** into HackberryPi CM5
5. **Power on** using **Call button** (top left on keyboard)
6. **First boot setup**:
   - Touchscreen will auto-configure
   - Power management service starts automatically
   - Pentesting tools install in background
7. **Calibrate touchscreen** (optional):
   ```bash
   sudo calibrate-touchscreen.sh
   ```
8. **Power off**: Hold **Call End button** for 3 seconds

### Power Management (HackberryPi CM5)

- **Power On**: Press **Call button** (top left)
- **Sleep**: Brief press **Call End button**
- **Shutdown**: Hold **Call End button** for 3 seconds

### Touchscreen Configuration

The 720x720 touchscreen is automatically configured. To recalibrate:
```bash
sudo calibrate-touchscreen.sh
```

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

### Download Pre-built Image

1. Go to [Releases](https://github.com/sowavy234/ghostpi/releases)
2. Download the latest `GhostPi-*.img` file
3. Flash to SD card using one of the methods below

### Using dd (Linux/macOS)

```bash
# Find your SD card
lsblk  # or diskutil list (macOS)

# Flash image (REPLACE sdX with your device - be careful!)
sudo dd if=GhostPi-CM5-*.img of=/dev/sdX bs=4M status=progress
sync
```

### Using Raspberry Pi Imager

1. Download: https://www.raspberrypi.com/software/
2. Select "Use custom image"
3. Choose your `GhostPi-*.img` file
4. Select SD card and write
5. Wait for completion

### After Flashing

1. **Insert SD card** into HackberryPi CM5
2. **Power on** using **Call button** (top left on keyboard)
3. **First boot** will automatically configure everything
4. **Flipper Zero**: Connect via USB - terminal auto-launches
5. **Battery**: Monitor with `battery-status` or in terminal banner
6. **System Monitor**: Run `wavy-companion` for graphs

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

## 🔍 System Services

### Swapfile Service

The swapfile service automatically:
- Creates 2GB swapfile on first boot
- Monitors memory usage every 30 seconds
- Increases swap if memory is low
- Prevents out-of-memory crashes

### Battery Monitor Service

Monitors HackberryPi CM5 battery:
- I2C-based voltage measurement
- Real-time percentage calculation
- Estimated remaining time
- Low battery warnings

```bash
# Check battery status
battery-status

# View in terminal
wavy-terminal  # Shows battery in banner
```

### AI Companion Service

System monitoring with graphs:
```bash
# Launch AI companion dashboard
wavy-companion

# Shows real-time graphs for:
# - CPU, Memory, Disk usage
# - Battery status
# - Network statistics
# - System health
```

### Flipper Zero Auto-Launch

Automatically detects and launches terminal when Flipper Zero connects:
- Opens coding help terminal
- Shows tool usage guides
- Provides code examples
- Interactive coding assistant

## 📁 Project Structure

```
ghostpi/
├── README.md                    # This file
├── FEATURES_SUMMARY.md         # Complete features list
├── RELEASE_v1.2.0.md          # Release notes
├── scripts/                    # Build scripts
│   ├── build_linux.sh         # Linux build script
│   ├── build_mac.sh           # macOS build script
│   ├── quick_install.sh       # Quick install on Pi
│   ├── wavy-update.sh         # Update system menu
│   └── install_hackberry_cm5.sh # HackberryPi CM5 setup
├── terminal/                   # Enhanced terminal
│   └── wavy-terminal.sh       # System info terminal
├── ai-companion/              # AI companion
│   └── wavy-ai-companion.sh   # System monitoring with graphs
├── hackberry-cm5/             # HackberryPi CM5 support
│   ├── power-management.sh    # Power button handling
│   ├── touchscreen-config.sh  # Touchscreen setup
│   ├── battery-monitor.sh     # Battery monitoring
│   ├── wavy-led-control.sh    # LED control
│   └── speaker-notifications.sh # Audio alerts
├── flipper-zero/              # Flipper Zero integration
│   ├── flipper-auto-launch.sh # Auto-launch on connect
│   ├── flipper-coding-terminal.sh # Coding help
│   └── apps/flipper_buddy/    # Flipper Buddy app
├── boot-splash/               # Boot splash theme
│   ├── wavys-world.plymouth  # Plymouth config
│   └── wavys-world.script    # Animation script
└── services/                  # System services
    ├── swapfile-manager.service
    ├── battery-monitor.service
    └── hackberry-cm5.service
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

- **HackberryPi CM5**: https://github.com/ZitaoTech/HackberryPiCM5 - Hardware reference and inspiration
- **LinuxBootImageFileGenerator**: https://github.com/robseb/LinuxBootImageFileGenerator
- **Plymouth**: Boot splash system
- **Raspberry Pi Foundation**: Hardware support
- **Kali Linux, Parrot OS, BlackArch**: Pentesting tools

## 📧 Support

- **Issues**: https://github.com/sowavy234/ghostpi/issues
- **Discussions**: https://github.com/sowavy234/ghostpi/discussions

---

**Welcome to Wavy's World!** 🎮🔫✨

Made with ❤️ for the Raspberry Pi community
