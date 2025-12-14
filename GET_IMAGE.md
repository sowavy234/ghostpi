# How to Get Your Flashable .img File

## 🚀 Easiest Method: GitHub Actions (Recommended)

Your repository is already set up with GitHub Actions! This is the easiest way:

### Steps:

1. **Go to GitHub Actions:**
   - https://github.com/sowavy234/ghostpi/actions

2. **Run the workflow:**
   - Click "Build GhostPi Images" in the left sidebar
   - Click "Run workflow" button (top right)
   - Select branch: `main`
   - Choose: `CM5` (or `CM4` if you need that)
   - Click "Run workflow"

3. **Wait for build:**
   - The build will take 10-20 minutes
   - You can watch the progress

4. **Download the image:**
   - When complete, click on the workflow run
   - Scroll down to "Artifacts"
   - Download `ghostpi-images`
   - Extract the `.img` file

5. **Flash to SD card:**
   ```bash
   # On Mac
   diskutil list
   diskutil unmountDisk /dev/diskX
   sudo dd if=GhostPi-CM5-*.img of=/dev/rdiskX bs=4M
   diskutil eject /dev/diskX
   ```

## 🐳 Alternative: Docker on Mac

If you have Docker installed:

```bash
cd ~/Downloads/ghostpi
./scripts/build_mac.sh CM5
```

This will create the image in `~/Downloads/ghostpi/`

## 🐧 Alternative: Build on Linux

If you have access to a Linux system:

```bash
# Copy folder to Linux
cd ~/ghostpi
sudo ./scripts/build_linux.sh CM5
```

## ⚡ Quick Install (No Image Needed)

If you already have a Raspberry Pi running:

1. Install Raspberry Pi OS using Raspberry Pi Imager
2. Boot the Pi
3. Run:
   ```bash
   git clone https://github.com/sowavy234/ghostpi.git
   cd ghostpi
   sudo ./scripts/quick_install.sh
   sudo reboot
   ```

This installs GhostPi on your existing Pi without needing to build an image.

## 📋 Image Requirements

- **Size**: ~4-8GB (depending on content)
- **Format**: Bootable Raspberry Pi image (.img)
- **Partitions**: 
  - Boot partition (FAT32, ~256MB)
  - Root partition (ext4, rest of space)

## ✅ Verification

After getting the image, verify it:

```bash
# Check file exists and size
ls -lh GhostPi-*.img

# Should be several GB
# On Linux, check partitions:
fdisk -l GhostPi-*.img
```

## 🎯 Recommended: Use GitHub Actions

**It's the easiest and most reliable method!**

1. Go to: https://github.com/sowavy234/ghostpi/actions
2. Run workflow
3. Download artifact
4. Flash to SD card

That's it! 🎉

