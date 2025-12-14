# Complete Flash Guide & Image Creation

## 📦 Creating the Bootable .img File

### Method 1: GitHub Actions (Recommended - Easiest)

**Best for:** Mac users, no setup needed

1. **Go to GitHub Actions:**
   - https://github.com/sowavy234/ghostpi/actions

2. **Run Workflow:**
   - Click "Build GhostPi Images" in sidebar
   - Click "Run workflow" (top right)
   - Branch: `main`
   - CM Type: `CM5` (or `CM4`)
   - Click "Run workflow"

3. **Wait for Build:**
   - Takes 10-20 minutes
   - Watch progress in real-time
   - Get email notification when done

4. **Download Image:**
   - Click completed workflow run
   - Scroll to "Artifacts"
   - Download `ghostpi-images.zip`
   - Extract to get `.img` file

**Result:** `GhostPi-CM5-YYYYMMDD_HHMMSS.img` (~4-8GB)

### Method 2: Docker on Mac

**Best for:** Local builds, faster iteration

**Prerequisites:**
- Docker Desktop installed and running

**Steps:**
```bash
# 1. Start Docker Desktop app
# 2. Build image
cd ~/Downloads/ghostpi
./scripts/build_mac.sh CM5

# Image will be in: ~/Downloads/ghostpi/
```

### Method 3: Build on Linux System

**Best for:** Full control, direct access

**On Ubuntu/Debian:**
```bash
# Copy ghostpi folder to Linux
cd ~/ghostpi

# Install dependencies
sudo apt-get update
sudo apt-get install -y python3 device-tree-compiler plymouth imagemagick git

# Build image
sudo ./scripts/build_linux.sh CM5

# Image location: ~/Downloads/ghostpi/GhostPi-CM5-*.img
```

### Method 4: Quick Install (No Image Build)

**Best for:** Existing Raspberry Pi

1. **Install Raspberry Pi OS:**
   - Use Raspberry Pi Imager
   - Flash Raspberry Pi OS to SD card
   - Boot the Pi

2. **Install GhostPi:**
   ```bash
   git clone https://github.com/sowavy234/ghostpi.git
   cd ghostpi
   sudo ./scripts/quick_install.sh
   sudo reboot
   ```

This installs GhostPi on existing OS - no image build needed!

## 💾 Flashing the Image to SD Card

### On macOS

```bash
# Step 1: Find your SD card
diskutil list

# Look for your SD card (usually /dev/disk2 or similar)
# Note the disk number (e.g., disk2)

# Step 2: Unmount the SD card
diskutil unmountDisk /dev/diskX
# Replace diskX with your actual disk (e.g., disk2)

# Step 3: Flash the image
sudo dd if=GhostPi-CM5-*.img of=/dev/rdiskX bs=4M
# Use rdiskX (with 'r') for faster writes
# Replace diskX with your actual disk

# Step 4: Wait for completion
# This can take 5-15 minutes depending on image size
# You'll see progress in the terminal

# Step 5: Eject when done
diskutil eject /dev/diskX
```

**Example:**
```bash
diskutil list                    # Find disk2
diskutil unmountDisk /dev/disk2
sudo dd if=GhostPi-CM5-20241213.img of=/dev/rdisk2 bs=4M
diskutil eject /dev/disk2
```

### On Linux

```bash
# Step 1: Find your SD card
lsblk

# Step 2: Unmount if mounted
sudo umount /dev/sdX1 /dev/sdX2  # Replace sdX with your device

# Step 3: Flash the image
sudo dd if=GhostPi-CM5-*.img of=/dev/sdX bs=4M status=progress
# Replace sdX with your actual device (e.g., sdb)

# Step 4: Sync to ensure writes complete
sync

# Step 5: Safely remove
sudo eject /dev/sdX
```

**Example:**
```bash
lsblk                           # Find sdb
sudo umount /dev/sdb1 /dev/sdb2
sudo dd if=GhostPi-CM5-20241213.img of=/dev/sdb bs=4M status=progress
sync
```

### Using Raspberry Pi Imager (Easiest)

1. **Download Raspberry Pi Imager:**
   - macOS: https://www.raspberrypi.com/software/
   - Install the app

2. **Flash Image:**
   - Open Raspberry Pi Imager
   - Click "Choose OS" → "Use custom image"
   - Select your `GhostPi-CM5-*.img` file
   - Click "Choose Storage" → Select your SD card
   - Click "Write"
   - Wait for completion

3. **Done!** SD card is ready to boot

## ✅ Verifying the Image

### Before Flashing

```bash
# Check image file exists
ls -lh GhostPi-*.img

# Should show several GB file
# Example: -rw-r--r--  1 user  staff   4.2G Dec 13 12:00 GhostPi-CM5-20241213.img

# On Linux, check partition table
fdisk -l GhostPi-*.img

# Should show:
# - Boot partition (FAT32, ~256MB)
# - Root partition (ext4, rest of space)
```

### After Flashing

```bash
# On Mac - Check SD card
diskutil list

# Should show two partitions:
# - BOOT (FAT32)
# - Root filesystem (Linux)

# On Linux
lsblk
# Should show partitions on your SD card device
```

## 🚀 Booting Your Raspberry Pi

1. **Insert SD card** into Raspberry Pi
2. **Connect power supply**
3. **Power on**
4. **Watch for boot splash:**
   - "Welcome to Wavy's World"
   - 3D space background
   - Animated character with Glock
   - "Welcome to Glock's World Enjoy"

## 🔧 Troubleshooting

### Image Creation Issues

**"Docker daemon not running"**
```bash
# Start Docker Desktop app
# Then retry build
```

**"Not enough disk space"**
```bash
# Free up space in /tmp (needs ~10GB)
# Or set custom build directory:
export BUILD_DIR=/path/to/large/disk
sudo ./scripts/build_linux.sh CM5
```

**"Permission denied"**
```bash
# Use sudo for build scripts
sudo ./scripts/build_linux.sh CM5
```

### Flashing Issues

**"Resource busy"**
```bash
# Make sure SD card is fully unmounted
diskutil unmountDisk /dev/diskX  # Mac
sudo umount /dev/sdX*            # Linux
```

**"No space left on device"**
- SD card too small (need 16GB+)
- Image file corrupted (re-download)

**"Permission denied"**
```bash
# Use sudo for dd command
sudo dd if=image.img of=/dev/diskX bs=4M
```

### Boot Issues

**"No boot partition"**
- Image may be corrupted
- Re-download or rebuild

**"Kernel panic"**
- Wrong CM type (CM4 vs CM5)
- Rebuild with correct type

**"Display not working"**
- Check config.txt has correct display settings
- Verify display connections

## 📋 Image Specifications

- **Format:** Bootable Raspberry Pi image (.img)
- **Size:** 4-8GB (depending on content)
- **Partitions:**
  - Boot: FAT32, 256MB
  - Root: ext4, dynamic size
- **Compatibility:**
  - Raspberry Pi CM4
  - Raspberry Pi CM5
  - Raspberry Pi 4 Model B
  - Raspberry Pi 5

## 🎯 Quick Reference

| Task | Command |
|------|---------|
| Build CM5 (GitHub) | Go to Actions → Run workflow |
| Build CM5 (Docker) | `./scripts/build_mac.sh CM5` |
| Build CM5 (Linux) | `sudo ./scripts/build_linux.sh CM5` |
| Flash (Mac) | `sudo dd if=image.img of=/dev/rdiskX bs=4M` |
| Flash (Linux) | `sudo dd if=image.img of=/dev/sdX bs=4M status=progress` |
| Flash (Imager) | Use Raspberry Pi Imager app |

## 📚 Additional Resources

- **GitHub Repository:** https://github.com/sowavy234/ghostpi
- **Issues:** https://github.com/sowavy234/ghostpi/issues
- **Raspberry Pi Docs:** https://www.raspberrypi.com/documentation/

---

**Ready to flash?** Get your image from GitHub Actions or build locally, then follow the flashing steps above! 🚀

