# GhostPi Installation Guide

## Complete Setup Instructions

### Prerequisites

- Linux system (Ubuntu/Debian recommended)
- Root/sudo access
- At least 10GB free disk space
- SD card (16GB+ recommended)

### Step-by-Step Installation

#### 1. Navigate to GhostPi Directory

```bash
cd ~/Downloads/ghostpi
```

#### 2. Generate Placeholder Images (First Time Only)

```bash
./scripts/generate_placeholder_images.sh
```

This creates placeholder images. **Replace them with your actual 3D renders** for the best boot splash experience.

#### 3. Create the Bootable Image

```bash
sudo ./scripts/create_ghostpi_image.sh
```

This process will:
- Install required dependencies
- Clone LinuxBootImageFileGenerator
- Create boot partition with proper configuration
- Set up rootfs structure
- Install boot splash theme
- Install swapfile service
- Generate bootable .img file

**Time**: 10-30 minutes depending on your system

#### 4. Locate Your Image

The image will be saved in:
```
~/Downloads/ghostpi/GhostPi-WavysWorld-YYYYMMDD_HHMMSS.img
```

#### 5. Flash to SD Card

**Option A: Using dd (Command Line)**

```bash
# Find your SD card device
lsblk

# Flash (REPLACE sdX with your actual device, e.g., sdb)
sudo dd if=~/Downloads/ghostpi/GhostPi-*.img of=/dev/sdX bs=4M status=progress

# Sync to ensure write completion
sync
```

**Option B: Using Raspberry Pi Imager (Recommended)**

1. Download: https://www.raspberrypi.com/software/
2. Install and open Raspberry Pi Imager
3. Click "Choose OS" → "Use custom image"
4. Select your `GhostPi-*.img` file
5. Click "Choose Storage" → Select your SD card
6. Click "Write" and wait for completion

#### 6. Boot Your Raspberry Pi

1. Insert SD card into your Raspberry Pi
2. Connect power supply
3. Power on
4. Watch the **"Welcome to Wavy's World"** boot splash!

## What's Included

### Boot Splash Features
- 3D black and purple space background
- Animated stars
- 3D character with tattoos and Glock
- "Welcome to Wavy's World" text
- "Welcome to Glock's World Enjoy" text

### System Features
- Universal Raspberry Pi support (CM4, CM5, Pi 4, Pi 5)
- Automatic hardware detection
- Swapfile management service
- Pre-configured for optimal performance

### Swapfile Service

The swapfile service:
- Creates 2GB swapfile automatically
- Monitors memory usage every 30 seconds
- Increases swap size if memory is low
- Prevents out-of-memory crashes
- Logs activity to `/var/log/swapfile-manager.log`

## Customization

### Replace Boot Splash Images

1. Create your 3D renders:
   - `character.png` - Character with tattoos and Glock
   - `glock.png` - Glock with 30-round magazine
   - `text_welcome.png` - "Welcome to Wavy's World"
   - `text_glock.png` - "Welcome to Glock's World Enjoy"
   - `star.png` - Star sprite

2. Copy to boot-splash directory:
   ```bash
   cp your_images/* ~/Downloads/ghostpi/boot-splash/
   ```

3. Rebuild the image:
   ```bash
   sudo ./scripts/create_ghostpi_image.sh
   ```

### Adjust Swapfile Settings

Edit `services/swapfile-manager.sh`:
- `SWAP_SIZE` - Initial swap size (default: 2048MB)
- `MIN_FREE_MEM` - Minimum free memory before increasing swap (default: 512MB)
- `MONITOR_INTERVAL` - Check interval in seconds (default: 30)

## Troubleshooting

### Image Creation Fails

**Error: Python not found**
```bash
sudo apt-get install python3 python3-pip
```

**Error: device-tree-compiler not found**
```bash
sudo apt-get install device-tree-compiler
```

**Error: Not enough disk space**
- Free up space in `/tmp` (needs ~10GB)
- Or set `BUILD_DIR` to a different location:
  ```bash
  sudo BUILD_DIR=/path/to/large/disk ./scripts/create_ghostpi_image.sh
  ```

### Boot Splash Not Showing

1. Check Plymouth is installed:
   ```bash
   plymouth --version
   ```

2. Verify theme files exist:
   ```bash
   ls -la /usr/share/plymouth/themes/wavys-world/
   ```

3. Set as default theme:
   ```bash
   sudo update-alternatives --install /etc/alternatives/default.plymouth default.plymouth /usr/share/plymouth/themes/wavys-world/wavys-world.plymouth 100
   sudo update-initramfs -u
   ```

### Swapfile Service Issues

**Check service status:**
```bash
sudo systemctl status swapfile-manager
```

**View logs:**
```bash
sudo journalctl -u swapfile-manager -f
```

**Manual start:**
```bash
sudo /usr/local/bin/swapfile-manager.sh start
```

**Check swap:**
```bash
free -h
swapon --show
```

## Support

For issues or questions:
1. Check the logs in `/var/log/swapfile-manager.log`
2. Review boot messages: `dmesg | tail -50`
3. Check system status: `systemctl status`

## Next Steps

1. Customize your boot splash with 3D renders
2. Add additional services or tools
3. Configure for your specific use case
4. Share your GhostPi creation!

**Welcome to Wavy's World!** 🎮🔫✨

