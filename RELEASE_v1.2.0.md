# GhostPi v1.2.0 - HackberryPi CM5 Edition

## 🎉 New Release: HackberryPi CM5 Support

This release adds full support for the **HackberryPi CM5** ultra-portable handheld Linux device.

## ✨ New Features

### HackberryPi CM5 Integration
- **Power Management**: 
  - Call button = Power On / Wake from sleep
  - Call End button (brief) = Sleep mode
  - Call End button (hold 3s) = Shutdown
- **Touchscreen Configuration**: 
  - Auto-configured for 4" 720x720 TFT touch display
  - Calibration tool included
  - X11 and framebuffer support
- **Hardware Optimization**: 
  - Optimized for HackberryPi CM5 specifications
  - BlackBerry keyboard support
  - Display overlay configuration

### Comprehensive Pentesting Tools
- **Kali Linux Tools**: Full suite of information gathering, vulnerability assessment, and exploitation tools
- **Parrot OS Tools**: Privacy and anonymity tools integrated
- **BlackArch Tools**: 2800+ penetration testing tools (ARM compatible)
- **Unified Menu**: Single interface for all pentesting tools

### Flipper Zero Integration
- **Flipper Buddy App**: New companion app for Flipper Zero
- **Auto-detection**: Automatically recognizes Flipper Zero when connected
- **Code Sync**: Bidirectional code synchronization
- **Marauder WiFi**: ESP32 Marauder board support
- **Brute Force Tools**: Educational pentesting tools with guided walkthrough

## 📋 Installation Sequence for HackberryPi CM5

1. **Flash the image** to SD card
2. **Insert SD card** into HackberryPi CM5
3. **Power on** using the **Call button** (top left on keyboard)
4. **First boot** will automatically:
   - Configure touchscreen (720x720)
   - Set up power management service
   - Install pentesting tools
   - Configure Flipper Zero integration
5. **Calibrate touchscreen** (if needed):
   ```bash
   sudo calibrate-touchscreen.sh
   ```
6. **Power off** by holding **Call End button** for 3 seconds

## 🔧 Hardware Reference

For complete hardware information, see:
- **HackberryPi CM5 Repository**: https://github.com/ZitaoTech/HackberryPiCM5
- **Specifications**: 4" 720x720 TFT, BlackBerry keyboard, 5000mAh battery
- **Dimensions**: 143.5x91.8x17.6mm, 306g

## 🛠️ Power Management

### Power On
- Press **Call button** (top left on keyboard)
- System wakes from sleep or powers on

### Sleep Mode
- Brief press **Call End button**
- Display turns off, system suspends

### Shutdown
- Hold **Call End button** for 3 seconds
- Graceful system shutdown

## 📱 Touchscreen

- **Resolution**: 720x720 pixels
- **Size**: 4" TFT touch display
- **Auto-configuration**: Configured on first boot
- **Calibration**: Run `sudo calibrate-touchscreen.sh` if needed

## 🎮 Features Included

- Custom 3D boot splash ("Welcome to Wavy's World")
- Comprehensive pentesting tools (Kali, Parrot, BlackArch)
- Flipper Zero integration with Flipper Buddy app
- Auto-update and self-healing system
- AI coding assistant
- Swapfile management
- Hardware detection and auto-configuration

## ⚠️ Educational Disclaimer

**EDUCATIONAL PURPOSES ONLY**

All tools are for authorized testing and educational purposes only.
Unauthorized access to computer systems is illegal.
Use only on systems you own or have explicit permission to test.

## 📦 What's New

- HackberryPi CM5 power management service
- Touchscreen auto-configuration
- Comprehensive pentesting tools installer
- Flipper Buddy app for Flipper Zero
- Unified pentesting tools menu
- Enhanced self-healing with file error detection
- Improved Flipper Zero detection and sync

## 🐛 Bug Fixes

- Fixed syntax errors in build scripts
- Enhanced self-healing bot to fix script errors
- Improved Flipper Zero detection reliability
- Fixed touchscreen calibration issues

## 📚 Documentation

- Updated README with HackberryPi CM5 information
- Installation sequence documented
- Power management guide included
- Touchscreen configuration guide

## 🔗 Links

- **Repository**: https://github.com/sowavy234/ghostpi
- **HackberryPi CM5**: https://github.com/ZitaoTech/HackberryPiCM5
- **Issues**: https://github.com/sowavy234/ghostpi/issues

---

**Welcome to Wavy's World on HackberryPi CM5!** 🎮🔫✨

