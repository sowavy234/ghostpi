# GhostPi Build Commands

## 🍎 macOS Commands

### Build CM5 Image (Docker)
```bash
cd ~/Downloads/ghostpi
./scripts/build_mac.sh CM5
```

### Build CM4 Image (Docker)
```bash
cd ~/Downloads/ghostpi
./scripts/build_mac.sh CM4
```

### Build Using Linux VM
```bash
# Copy to VM first, then in VM:
sudo ./BUILD_ON_LINUX.sh CM5
```

### Flash Image to SD Card (macOS)
```bash
# Find your SD card
diskutil list

# Unmount SD card
diskutil unmountDisk /dev/diskX

# Flash image
sudo dd if=~/Downloads/ghostpi/GhostPi-CM5-*.img of=/dev/rdiskX bs=4M

# Eject when done
diskutil eject /dev/diskX
```

## 🐧 Linux Commands

### Build CM5 Image
```bash
cd ~/Downloads/ghostpi
sudo ./scripts/build_linux.sh CM5
```

### Build CM4 Image
```bash
cd ~/Downloads/ghostpi
sudo ./scripts/build_linux.sh CM4
```

### Flash Image to SD Card (Linux)
```bash
# Find your SD card
lsblk

# Flash image (REPLACE sdX with your device)
sudo dd if=~/Downloads/ghostpi/GhostPi-CM5-*.img of=/dev/sdX bs=4M status=progress

# Sync to ensure write completion
sync
```

## 🔧 Quick Install on Existing Pi

### Install on Running Raspberry Pi
```bash
# On your Raspberry Pi
cd ~/ghostpi
sudo ./scripts/quick_install.sh
sudo reboot
```

This installs:
- Boot splash theme
- Swapfile service
- Hardware detection
- All configurations

## 📦 Generate Placeholder Images

```bash
cd ~/Downloads/ghostpi
./scripts/generate_placeholder_images.sh
```

## 🔍 Check Swapfile Service

```bash
# Check status
sudo systemctl status swapfile-manager

# View logs
sudo journalctl -u swapfile-manager -f

# Manual control
sudo /usr/local/bin/swapfile-manager.sh status
sudo /usr/local/bin/swapfile-manager.sh start
sudo /usr/local/bin/swapfile-manager.sh stop
```

## 🎨 Customize Boot Splash

```bash
# Edit animation script
nano ~/Downloads/ghostpi/boot-splash/wavys-world.script

# Replace images
cp your_character.png ~/Downloads/ghostpi/boot-splash/character.png
cp your_glock.png ~/Downloads/ghostpi/boot-splash/glock.png

# Rebuild
sudo ./scripts/build_linux.sh CM5
```

## 🚀 GitHub Actions Build

### Trigger Manual Build
1. Go to GitHub repository
2. Click "Actions" tab
3. Select "Build GhostPi Images"
4. Click "Run workflow"
5. Choose CM4 or CM5
6. Download artifacts when complete

## 📋 Complete Build Process

### macOS with Docker
```bash
# 1. Navigate to project
cd ~/Downloads/ghostpi

# 2. Build image
./scripts/build_mac.sh CM5

# 3. Find image
ls -lh ~/Downloads/ghostpi/GhostPi-*.img

# 4. Flash to SD card
diskutil list
sudo dd if=~/Downloads/ghostpi/GhostPi-CM5-*.img of=/dev/rdiskX bs=4M
```

### Linux Direct Build
```bash
# 1. Install dependencies
sudo apt-get update
sudo apt-get install -y python3 device-tree-compiler plymouth imagemagick git

# 2. Build
cd ~/Downloads/ghostpi
sudo ./scripts/build_linux.sh CM5

# 3. Flash
sudo dd if=GhostPi-CM5-*.img of=/dev/sdX bs=4M status=progress
```

## 🐛 Troubleshooting Commands

### Check Build Dependencies
```bash
python3 --version
dtc --version
plymouth --version
convert --version
```

### Check Image File
```bash
# View partition table
fdisk -l GhostPi-CM5-*.img

# Check file size
ls -lh GhostPi-*.img
```

### Verify Boot Configuration
```bash
# Mount and check boot partition
sudo mkdir -p /mnt/boot
sudo mount -o loop,offset=$((2048*512)) GhostPi-CM5-*.img /mnt/boot
cat /mnt/boot/config.txt
sudo umount /mnt/boot
```

## 📝 Quick Reference

| Task | macOS Command | Linux Command |
|------|--------------|---------------|
| Build CM5 | `./scripts/build_mac.sh CM5` | `sudo ./scripts/build_linux.sh CM5` |
| Build CM4 | `./scripts/build_mac.sh CM4` | `sudo ./scripts/build_linux.sh CM4` |
| Flash Image | `sudo dd if=GhostPi-*.img of=/dev/rdiskX bs=4M` | `sudo dd if=GhostPi-*.img of=/dev/sdX bs=4M status=progress` |
| Quick Install | N/A | `sudo ./scripts/quick_install.sh` |
| Check Swap | N/A | `sudo systemctl status swapfile-manager` |

## 💡 Pro Tips

1. **Always verify SD card device** before flashing (use `lsblk` or `diskutil list`)
2. **Use `sync`** after flashing on Linux to ensure writes complete
3. **Check image size** before flashing (should be several GB)
4. **Backup SD card** if it has important data
5. **Use Raspberry Pi Imager** for easiest flashing experience

---

**Welcome to Wavy's World!** 🎮🔫

