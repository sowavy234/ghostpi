# Quick Start Guide - GhostPi + HackberryPi CM5

## ✅ Integration Complete!

Your GhostPi project has been fully integrated with HackberryPi CM5 support. Everything is configured and ready to build.

## 🚀 Quick Build (Choose Your Method)

### Option 1: macOS with Docker (Recommended)

1. **Install Docker Desktop** (if not already installed)
   - Download: https://www.docker.com/products/docker-desktop
   - Install and start Docker Desktop

2. **Run Build Script**
   ```bash
   cd ~/Downloads/ghostpi-1
   sudo ./scripts/build_complete.sh CM5
   ```

3. **Flash to SD Card**
   ```bash
   # Find your SD card
   diskutil list
   
   # Unmount and flash (replace diskX with your device)
   diskutil unmountDisk /dev/diskX
   sudo dd if=~/Downloads/GhostPi-HackberryPi-CM5-*.img of=/dev/rdiskX bs=4m
   sync
   diskutil eject /dev/diskX
   ```

### Option 2: Build from Base Image (Best Results)

1. **Download Raspberry Pi OS Lite (64-bit)**
   - Go to: https://www.raspberrypi.com/software/
   - Download "Raspberry Pi OS Lite (64-bit)"
   - Save to: `~/Downloads/raspios_lite_arm64.img`

2. **Build on Linux System** (VM or remote)
   ```bash
   # Copy ghostpi-1 folder to Linux system
   # Then on Linux:
   cd ~/ghostpi-1
   sudo ./scripts/build_from_base_image.sh ~/Downloads/raspios_lite_arm64.img CM5
   ```

3. **Transfer image back to macOS** (if built remotely)

4. **Flash to SD Card** (same as Option 1)

### Option 3: Use GitHub Actions (Easiest, No Local Build)

1. **Push to GitHub** (if not already)
   ```bash
   cd ~/Downloads/ghostpi-1
   git add .
   git commit -m "Integrated HackberryPi CM5 support"
   git push
   ```

2. **Build on GitHub**
   - Go to: https://github.com/sowavy234/ghostpi/actions
   - Click "Build GhostPi Images"
   - Click "Run workflow" → Select CM5
   - Wait for build to complete
   - Download the .img file from artifacts

3. **Flash to SD Card** (same as Option 1)

## 📱 What's Included

✅ **HyperPixel 720x720 Display** - Fully configured  
✅ **Touchscreen** - Pre-configured with calibration  
✅ **All GhostPi Services** - Bots, agents, self-healing  
✅ **Dual Boot Support** - BlackArch integration ready  
✅ **Boot Splash Themes** - Wavy's World included  
✅ **Power Management** - HackberryPi CM5 buttons  
✅ **First-Boot Setup** - Automatic configuration  

## 🎮 After Booting

1. **First boot** will automatically configure everything (~2-5 minutes)
2. **Display** will show at 720x720 resolution
3. **Touchscreen** will be ready to use
4. **Services** will start automatically
5. **Ready to use!**

### Power Controls (HackberryPi CM5)
- **Call Button**: Power on / Wake
- **Call End (brief)**: Sleep
- **Call End (hold 3s)**: Shutdown

### Useful Commands
```bash
wavy-terminal          # Enhanced terminal
wavy-companion         # AI companion dashboard
calibrate-touchscreen  # Calibrate touchscreen
switch_boot_splash.sh  # Change boot theme
```

## 📚 Documentation

- **`BUILD_HACKBERRY.md`** - Complete build guide with troubleshooting
- **`INTEGRATION_SUMMARY.md`** - What was integrated and how
- **`QUICK_START.md`** - This file (quick reference)

## 🎉 Ready to Build!

All files are in place. Choose your build method above and you'll have a fully functional GhostPi + HackberryPi CM5 image in no time!

**Welcome to Wavy's World!** 🎮🔫✨

