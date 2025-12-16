# Build and Flash GhostPi - Quick Guide

## ✅ Repository Status
All files have been verified and are ready:
- ✅ Build scripts are executable
- ✅ YAML files are valid
- ✅ All key components present
- ✅ Dockerfile updated with dependencies

## Step 1: Build the Image

### Option A: Using Docker (Recommended - You have Docker installed)

1. **Start Docker Desktop** (if not already running)

2. **Build the image:**
   ```bash
   cd /Users/burberry/ghostpi
   ./scripts/build_mac.sh CM5
   ```
   
   This will:
   - Build a Docker container with all dependencies
   - Create the GhostPi image
   - Save it to `~/Downloads/ghostpi/GhostPi-*.img`

3. **Wait for completion** (this may take 10-30 minutes)

### Option B: Using GitHub Actions (No local build needed)

1. Push your code to GitHub
2. Go to Actions tab in your repository
3. Run the "Build GhostPi Images" workflow
4. Download the artifact (available for 7 days)

### Option C: Build on Linux VM/Server

If you have a Linux system available:
```bash
# Copy the repository to Linux
scp -r /Users/burberry/ghostpi user@linux-server:~/

# SSH into Linux
ssh user@linux-server

# Build
cd ~/ghostpi
sudo ./scripts/build_linux.sh CM5
```

## Step 2: Flash to SD Card

### Prerequisites
- SD card (16GB or larger, Class 10 recommended)
- SD card reader/adapter

### Method 1: Using the Helper Script (Easiest)

1. **Insert SD card** into your Mac

2. **Run the flash script:**
   ```bash
   cd /Users/burberry/ghostpi
   ./scripts/flash_to_sd_mac.sh
   ```
   
   Or specify the image path:
   ```bash
   ./scripts/flash_to_sd_mac.sh ~/Downloads/ghostpi/GhostPi-CM5-*.img
   ```

3. **Follow the prompts:**
   - Select your SD card device (e.g., `disk2`)
   - Type `YES` to confirm
   - Wait for flash to complete

### Method 2: Using Raspberry Pi Imager (Alternative)

1. **Download Raspberry Pi Imager:**
   - https://www.raspberrypi.com/software/

2. **Open Raspberry Pi Imager:**
   - Click "Choose OS" → "Use custom image"
   - Select your `GhostPi-*.img` file
   - Click "Choose Storage" → Select your SD card
   - Click "Write"

### Method 3: Manual dd Command

1. **Find your SD card:**
   ```bash
   diskutil list
   ```
   Look for your SD card (usually shows as external disk, e.g., `/dev/disk2`)

2. **Unmount the SD card:**
   ```bash
   diskutil unmountDisk /dev/diskX
   ```
   (Replace `diskX` with your actual device, e.g., `disk2`)

3. **Flash the image:**
   ```bash
   sudo dd if=~/Downloads/ghostpi/GhostPi-CM5-*.img of=/dev/rdiskX bs=4m
   ```
   ⚠️ **WARNING**: Double-check the device name! Using the wrong device will erase your data!

4. **Wait for completion** (may take 5-15 minutes)

5. **Sync and eject:**
   ```bash
   sync
   diskutil eject /dev/diskX
   ```

## Step 3: Boot and Test

1. **Insert SD card** into HackberryPi CM5

2. **Power on** using the **Call button** (top left on keyboard)

3. **First boot** will automatically:
   - Configure touchscreen (720x720)
   - Set up power management
   - Install pentesting tools
   - Configure Flipper Zero integration

4. **Wait for boot** - you should see the "Welcome to Wavy's World" boot splash

5. **Verify installation:**
   ```bash
   # Check system info
   wavy-terminal
   
   # Check battery
   battery-status
   
   # Check AI companion
   wavy-companion
   ```

## Troubleshooting

### Build Issues

**Docker not running:**
- Open Docker Desktop and wait for it to start
- Check: `docker ps` should work

**Build fails:**
- Ensure you have enough disk space (20GB+ free)
- Check Docker has enough resources allocated (Settings → Resources)

### Flash Issues

**SD card not detected:**
- Try a different USB port
- Check SD card adapter is working
- Try a different SD card

**Flash fails:**
- Ensure SD card is properly unmounted first
- Try using Raspberry Pi Imager instead
- Check SD card isn't write-protected

**Image won't boot:**
- Verify image file isn't corrupted (check file size)
- Try re-flashing
- Use a quality SD card (Class 10 or better)
- Minimum 16GB recommended

## Quick Reference

```bash
# Build image
./scripts/build_mac.sh CM5

# Flash to SD card
./scripts/flash_to_sd_mac.sh

# Check SD card devices
diskutil list

# Manual flash (if needed)
sudo dd if=~/Downloads/ghostpi/GhostPi-*.img of=/dev/rdiskX bs=4m
```

## Support

- **Issues**: Check repository issues
- **Hardware Reference**: https://github.com/ZitaoTech/HackberryPiCM5

---

**⚠️ EDUCATIONAL PURPOSES ONLY**

Welcome to Wavy's World! 🎮✨

