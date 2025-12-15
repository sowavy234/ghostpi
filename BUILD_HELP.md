# Building GhostPi on Mac - Quick Guide

## Option 1: Use Docker (Recommended if you have Docker Desktop)

1. **Start Docker Desktop**
   - Open Docker Desktop application
   - Wait for it to fully start (whale icon in menu bar)
   
2. **Run the build script**
   ```bash
   cd ~/Downloads/ghostpi
   ./scripts/build_mac_complete.sh CM5
   ```

3. **Wait for build to complete**
   - This will take 10-15 minutes
   - Image will be in: `~/Downloads/ghostpi/GhostPi-*.img`

## Option 2: Use GitHub Actions (Easiest - No Docker needed)

1. **The build will run automatically** when you push to GitHub
   - Already pushed! Check: https://github.com/sowavy234/ghostpi/actions

2. **Download the .img file**
   - Go to Actions tab
   - Click on the latest workflow run
   - Download the artifact (GhostPi-*.img)

3. **Or wait for release**
   - GitHub Actions will create a release automatically
   - Download from: https://github.com/sowavy234/ghostpi/releases

## Option 3: Manual Trigger (GitHub Actions)

If you want to trigger a build now:

1. Go to: https://github.com/sowavy234/ghostpi/actions
2. Click "Build GhostPi Images"
3. Click "Run workflow"
4. Select CM5 (or CM4)
5. Click "Run workflow"
6. Wait for build to complete
7. Download the .img file from artifacts

## Option 4: Use Raspberry Pi Imager (Simplest for end users)

1. **Download Raspberry Pi Imager**
   - https://www.raspberrypi.com/software/
   
2. **Install Raspberry Pi OS**
   - Use Raspberry Pi Imager to flash Raspberry Pi OS to SD card
   
3. **Boot and install GhostPi**
   - Boot the Pi
   - Clone repository: `git clone https://github.com/sowavy234/ghostpi.git`
   - Run: `sudo ./ghostpi/scripts/quick_install.sh`

## Current Status

✅ All code is on GitHub
✅ GitHub Actions will build automatically
✅ Mac build script ready (needs Docker running)

## Quick Start

**Easiest method right now:**
1. Go to: https://github.com/sowavy234/ghostpi/actions
2. Wait for build to complete (or trigger manually)
3. Download .img file
4. Flash to SD card using Raspberry Pi Imager

