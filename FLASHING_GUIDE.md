# Flashing Guide - GhostPi to SD Card

## Quick Flash Guide

### Method 1: Raspberry Pi Imager (Easiest)

1. **Download Raspberry Pi Imager**
   - https://www.raspberrypi.com/software/
   - Install on your computer

2. **Download GhostPi Image**
   - Go to: https://github.com/sowavy234/ghostpi/releases
   - Download the latest `GhostPi-*.img` file

3. **Flash Image**
   - Open Raspberry Pi Imager
   - Click "Choose OS" → "Use custom image"
   - Select the downloaded `GhostPi-*.img` file
   - Click "Choose Storage" → Select your SD card
   - Click "Write" and wait for completion

4. **Insert and Boot**
   - Insert SD card into HackberryPi CM5
   - Power on with **Call button** (top left)
   - First boot will auto-configure everything

### Method 2: Using dd (Linux/macOS)

1. **Download Image**
   ```bash
   # Download from releases
   wget https://github.com/sowavy234/ghostpi/releases/download/v1.2.0/GhostPi-CM5-*.img
   ```

2. **Find SD Card**
   ```bash
   # Linux
   lsblk
   
   # macOS
   diskutil list
   ```
   
   **⚠️ IMPORTANT**: Identify your SD card (usually `/dev/sdX` or `/dev/diskX`)

3. **Unmount SD Card**
   ```bash
   # Linux
   sudo umount /dev/sdX*
   
   # macOS
   diskutil unmountDisk /dev/diskX
   ```

4. **Flash Image**
   ```bash
   # Linux
   sudo dd if=GhostPi-CM5-*.img of=/dev/sdX bs=4M status=progress
   sync
   
   # macOS
   sudo dd if=GhostPi-CM5-*.img of=/dev/rdiskX bs=4M
   sync
   ```
   
   **⚠️ WARNING**: Replace `sdX` or `diskX` with your actual SD card device. Double-check to avoid erasing the wrong drive!

5. **Eject SD Card**
   ```bash
   # Linux
   sudo eject /dev/sdX
   
   # macOS
   diskutil eject /dev/diskX
   ```

### Method 3: Build from Source

If you want to build the image yourself:

```bash
# On Linux (Ubuntu/Debian)
git clone https://github.com/sowavy234/ghostpi.git
cd ghostpi
sudo ./scripts/build_linux.sh CM5

# Image will be in: ~/Downloads/ghostpi/GhostPi-*.img
```

## After Flashing

### First Boot

1. **Insert SD card** into HackberryPi CM5
2. **Power on** using **Call button** (top left on keyboard)
3. **Wait for first boot** - system will auto-configure:
   - Touchscreen (720x720)
   - Power management
   - Battery monitoring
   - Pentesting tools
   - Flipper Zero integration

### Verify Installation

```bash
# Check system info
wavy-terminal

# Check battery
battery-status

# Check AI companion
wavy-companion

# Check Flipper Zero (connect device)
flipper-detector.sh
```

### Power Management

- **Power On**: Press **Call button**
- **Sleep**: Brief press **Call End button**
- **Shutdown**: Hold **Call End button** for 3 seconds

## Troubleshooting

### Image Won't Boot

1. **Verify image integrity**
   ```bash
   # Check file size (should be several GB)
   ls -lh GhostPi-*.img
   ```

2. **Re-flash the image**
   - Use Raspberry Pi Imager (most reliable)
   - Ensure SD card is properly formatted

3. **Check SD card**
   - Use a quality SD card (Class 10 or better)
   - Minimum 16GB recommended
   - Try a different SD card

### Touchscreen Not Working

```bash
# Recalibrate touchscreen
sudo calibrate-touchscreen.sh

# Check configuration
cat /boot/config.txt | grep -i display
```

### Battery Not Detected

```bash
# Check I2C connection
i2cdetect -y 1

# Check battery service
sudo systemctl status battery-monitor.service

# Manual check
battery-status
```

### Flipper Zero Not Detected

```bash
# Check USB connection
lsusb | grep -i flipper

# Check detection script
flipper-detector.sh

# Manual launch
flipper-coding-terminal.sh
```

## Support

- **Issues**: https://github.com/sowavy234/ghostpi/issues
- **Releases**: https://github.com/sowavy234/ghostpi/releases
- **Hardware Reference**: https://github.com/ZitaoTech/HackberryPiCM5

---

**⚠️ EDUCATIONAL PURPOSES ONLY**

