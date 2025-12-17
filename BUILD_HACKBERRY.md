# GhostPi + HackberryPi CM5 Build Guide

Complete build guide for creating a fully integrated GhostPi image with HackberryPi CM5 support, including HyperPixel display, touchscreen, agents, bots, and dual boot.

## 🎯 Features

- **HyperPixel Display**: 4" 720x720 TFT touch display properly configured
- **Touchscreen**: Fully configured with calibration support
- **GhostPi Services**: All bots, agents, and monitoring services
- **Dual Boot**: Support for BlackArch integration
- **Boot Splash**: Wavy's World themes included
- **Power Management**: HackberryPi CM5 button controls
- **First-Boot Setup**: Automatic configuration on first boot

## 📋 Prerequisites

### Option 1: Build from Base Image (Recommended)

**Best for:** Full functionality, easiest method

1. Download Raspberry Pi OS Lite (64-bit) from:
   - https://www.raspberrypi.com/software/operating-systems/
   - Save to: `~/Downloads/`

2. Required tools (Linux):
   - `kpartx`, `qemu-user-static`, `parted`, `dosfstools`
   - Install: `sudo apt-get install kpartx qemu-user-static parted dosfstools device-tree-compiler`

3. Required tools (macOS):
   - Docker Desktop (recommended)
   - Or build on Linux VM/remote system

### Option 2: Build from Scratch

**Best for:** Minimal image, custom builds

Uses LinuxBootImageFileGenerator to create a minimal bootable image.

## 🔨 Building the Image

### Quick Build (Automated)

The build script automatically detects the best method:

```bash
cd ~/Downloads/ghostpi-1
sudo ./scripts/build_complete.sh CM5
```

This will:
1. Detect your OS and available resources
2. Choose the best build method
3. Create the complete image
4. Output to: `~/Downloads/GhostPi-HackberryPi-CM5-*.img`

### Method 1: Build from Base Image (Linux)

**Recommended** - Creates a fully functional image:

```bash
cd ~/Downloads/ghostpi-1

# Download Raspberry Pi OS Lite 64-bit to ~/Downloads/ first
# Then:
sudo ./scripts/build_from_base_image.sh ~/Downloads/raspios_lite_arm64.img CM5
```

### Method 2: Build from Scratch (Linux)

Creates a minimal bootable image:

```bash
cd ~/Downloads/ghostpi-1
sudo ./scripts/build_hackberry_integrated.sh CM5
```

### Method 3: Build on macOS

**Using Docker:**

1. Install Docker Desktop
2. Start Docker Desktop
3. Run build script (it will use Docker if available)

**Or build on Linux system:**

Copy the project to a Linux VM/server and build there.

## 📱 HyperPixel Display Configuration

The build automatically configures:

1. **DTBO Files**: Copied to `/boot/overlays/`
   - `vc4-kms-dpi-hyperpixel4sq.dtbo`
   - `hyperpixel4.dtbo`

2. **config.txt Settings**:
   ```
   dtoverlay=vc4-kms-v3d
   dtoverlay=vc4-kms-dpi-hyperpixel4sq
   framebuffer_width=720
   framebuffer_height=720
   display_rotate=0
   ```

3. **Touchscreen Configuration**:
   - X11 configuration: `/etc/X11/xorg.conf.d/99-hackberry-touchscreen.conf`
   - udev rules: `/etc/udev/rules.d/99-hackberry-touchscreen.rules`
   - Calibration tool: `calibrate-touchscreen.sh`

## 🤖 Services Included

All services are installed and enabled to start on boot:

- **swapfile-manager-2025.service**: Advanced swapfile management
- **ghostpi-bot-2025.service**: Automated monitoring bot
- **self-healing-2025.service**: Automatic service recovery
- **auto-update.timer**: Daily system updates
- **hackberry-cm5.service**: Power management (Call/Call End buttons)
- **battery-monitor.service**: Battery status monitoring
- **ghostpi-first-boot.service**: First-boot configuration (runs once)

## 🚀 First Boot

On first boot, the system automatically:

1. Updates package lists
2. Installs required dependencies (plymouth, xinput-calibrator)
3. Configures boot splash theme
4. Enables all services
5. Configures touchscreen
6. Updates initramfs

After first boot completes (~2-5 minutes), the system is ready to use.

## 💾 Flashing to SD Card

### On macOS

```bash
# Find SD card
diskutil list

# Unmount SD card (replace diskX with your device)
diskutil unmountDisk /dev/diskX

# Flash image (replace diskX)
sudo dd if=~/Downloads/GhostPi-HackberryPi-CM5-*.img of=/dev/rdiskX bs=4m

# Wait for completion, then:
sync
diskutil eject /dev/diskX
```

### On Linux

```bash
# Find SD card
lsblk

# Flash image (replace sdX with your device)
sudo dd if=~/Downloads/GhostPi-HackberryPi-CM5-*.img of=/dev/sdX bs=4M status=progress

# Wait for completion, then:
sync
```

### Using Raspberry Pi Imager (All Platforms)

1. Download Raspberry Pi Imager
2. Choose "Use custom image"
3. Select your `GhostPi-HackberryPi-CM5-*.img` file
4. Select SD card
5. Click "Write"

## 🎮 Using the System

### Power Controls (HackberryPi CM5)

- **Call Button**: Power on / Wake from sleep
- **Call End (brief)**: Enter sleep mode
- **Call End (hold 3s)**: Shutdown

### Touchscreen

- Touchscreen is pre-configured for 720x720 display
- To calibrate: `sudo calibrate-touchscreen.sh`

### Terminal

Launch enhanced terminal:
```bash
wavy-terminal
```

### AI Companion

Launch monitoring dashboard:
```bash
wavy-companion
```

### Services

Check service status:
```bash
systemctl status ghostpi-bot-2025.service
systemctl status swapfile-manager-2025.service
systemctl status self-healing-2025.service
```

## 🔧 Customization

### Change Boot Splash Theme

```bash
sudo /usr/local/bin/switch_boot_splash.sh
# Select: 1 (Wavy's World) or 2 (BlackArch Style)
sudo reboot
```

### Install Dual Boot

```bash
sudo /usr/local/bin/install_dual_boot.sh
```

### Install Pentesting Tools

```bash
sudo /usr/local/bin/install_pentest_tools.sh
```

## 📁 Project Structure

```
ghostpi-1/
├── scripts/
│   ├── build_complete.sh              # Main build script (auto-detects method)
│   ├── build_from_base_image.sh       # Build from Raspberry Pi OS image
│   ├── build_hackberry_integrated.sh  # Build from scratch
│   └── ...
├── hackberry-cm5/                     # HackberryPi CM5 support scripts
├── boot-splash/                       # Boot splash themes
├── services/                          # Systemd services
├── bots/                              # Bot scripts
└── ...
```

## 🐛 Troubleshooting

### Display Not Working

1. Verify dtbo files are in `/boot/overlays/`
2. Check `config.txt` has HyperPixel configuration
3. Verify framebuffer settings: `fbset`

### Touchscreen Not Working

1. Check if device detected: `ls /dev/input/event*`
2. Run calibration: `sudo calibrate-touchscreen.sh`
3. Check X11 config: `/etc/X11/xorg.conf.d/99-hackberry-touchscreen.conf`

### Services Not Starting

1. Check service status: `systemctl status <service-name>`
2. View logs: `journalctl -u <service-name> -f`
3. Check first-boot completed: `ls /var/lib/ghostpi/first-boot-complete`

### Build Fails

1. Ensure you have enough disk space (8GB+ free)
2. Check all dependencies installed
3. Verify HackberryPi repo cloned: `~/Downloads/hackberrypicm5-main`
4. Check dtbo files exist in HackberryPi repo

## 📚 References

- **HackberryPi CM5**: https://github.com/ZitaoTech/HackberryPiCM5
- **GhostPi Repository**: https://github.com/sowavy234/ghostpi
- **Raspberry Pi OS**: https://www.raspberrypi.com/software/

## ✅ Verification Checklist

After building, verify:

- [ ] Image file created in `~/Downloads/`
- [ ] Image size is reasonable (2-8GB)
- [ ] Can be mounted/flashed successfully
- [ ] After boot, display works
- [ ] Touchscreen responds
- [ ] Services are running
- [ ] First-boot script completed

## 🎉 Success!

Once the image is built and flashed, you'll have a fully functional GhostPi system with:

- ✅ HyperPixel 720x720 display
- ✅ Touchscreen support
- ✅ All GhostPi features
- ✅ Automated monitoring
- ✅ Self-healing services
- ✅ Dual boot support
- ✅ Beautiful boot splash

**Welcome to Wavy's World!** 🎮🔫✨

