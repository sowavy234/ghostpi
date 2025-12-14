# How to Flash GhostPi Image

## ⚠️ Important: Image Creation

The `.img` file needs to be created on a **Linux system** because it requires Linux-specific tools (parted, mkfs, etc.) that aren't available on macOS.

## Option 1: Build on Linux (Recommended)

### On a Linux System (Ubuntu/Debian):

```bash
# Copy ghostpi folder to Linux
# Then run:
cd ~/ghostpi
sudo ./scripts/build_linux.sh CM5
```

This creates: `GhostPi-CM5-YYYYMMDD_HHMMSS.img`

### Then Flash:

```bash
# Find your SD card
lsblk

# Flash (replace sdX with your device)
sudo dd if=GhostPi-CM5-*.img of=/dev/sdX bs=4M status=progress
sync
```

## Option 2: Use Raspberry Pi Imager (Easiest for Mac)

### Steps:

1. **Download Raspberry Pi Imager for Mac:**
   - https://www.raspberrypi.com/software/
   - Install the app

2. **Install Raspberry Pi OS:**
   - Open Raspberry Pi Imager
   - Choose OS → Raspberry Pi OS (64-bit)
   - Choose Storage → Your SD card
   - Click Write

3. **Boot Pi and Install GhostPi:**
   ```bash
   # On your Raspberry Pi
   git clone https://github.com/sowavy234/ghostpi.git
   cd ghostpi
   sudo ./scripts/quick_install.sh
   sudo reboot
   ```

This installs GhostPi on an existing Raspberry Pi OS.

## Option 3: Use Docker on Mac

```bash
cd ~/Downloads/ghostpi
./scripts/build_mac.sh CM5
```

This uses Docker to build the image on Mac.

## Option 4: GitHub Actions (Automatic)

Your repository has GitHub Actions set up! 

1. Go to: https://github.com/sowavy234/ghostpi/actions
2. Click "Build GhostPi Images"
3. Click "Run workflow"
4. Choose CM4 or CM5
5. Download the artifact when complete

## Flashing on macOS

Once you have the `.img` file:

```bash
# Find your SD card
diskutil list

# Unmount SD card
diskutil unmountDisk /dev/diskX

# Flash image
sudo dd if=GhostPi-CM5-*.img of=/dev/rdiskX bs=4M

# Eject when done
diskutil eject /dev/diskX
```

## Verify Image Before Flashing

```bash
# Check image file
ls -lh GhostPi-*.img

# Should be several GB in size
# Check partition table (on Linux)
fdisk -l GhostPi-*.img
```

## Troubleshooting

### "Image file not found"
- Make sure you built the image first
- Check the file location

### "Permission denied"
- Use `sudo` for dd command
- Check SD card permissions

### "No space left on device"
- SD card too small (need 16GB+)
- Image file too large

---

**Quick Start**: Use Raspberry Pi Imager + quick_install.sh (Option 2) - it's the easiest!

