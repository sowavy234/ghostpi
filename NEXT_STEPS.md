# Next Steps - Get Your Flashable Image

## ✅ What's Done

- ✅ All code pushed to GitHub
- ✅ Flash guides created
- ✅ Build scripts ready
- ✅ GitHub Actions configured

## 🚀 Get Your .img File Now

### Option 1: GitHub Actions (Recommended)

**Easiest - No setup needed!**

1. **Open in browser:**
   https://github.com/sowavy234/ghostpi/actions

2. **Start build:**
   - Click **"Build GhostPi Images"** (left sidebar)
   - Click **"Run workflow"** (top right, green button)
   - Branch: `main`
   - CM Type: **`CM5`** (or `CM4`)
   - Click **"Run workflow"**

3. **Wait:**
   - Build takes 10-20 minutes
   - Watch progress in real-time
   - You'll get an email when done

4. **Download:**
   - Click the completed workflow run
   - Scroll to **"Artifacts"**
   - Download `ghostpi-images.zip`
   - Extract to get `GhostPi-CM5-*.img`

### Option 2: Docker (If Running)

```bash
# Make sure Docker Desktop is running
cd ~/Downloads/ghostpi
./scripts/build_mac.sh CM5
```

## 💾 Flash to SD Card

Once you have the `.img` file:

### On Mac:

```bash
# 1. Find SD card
diskutil list

# 2. Unmount (replace diskX with your device)
diskutil unmountDisk /dev/diskX

# 3. Flash
sudo dd if=GhostPi-CM5-*.img of=/dev/rdiskX bs=4M

# 4. Eject
diskutil eject /dev/diskX
```

### Using Raspberry Pi Imager:

1. Download: https://www.raspberrypi.com/software/
2. Open app
3. Choose OS → "Use custom image"
4. Select your `GhostPi-CM5-*.img`
5. Choose Storage → Your SD card
6. Click Write

## 📚 Documentation

All guides are in your repository:

- **COMPLETE_FLASH_GUIDE.md** - Full detailed guide
- **FLASH_GUIDE.md** - Quick reference
- **GET_IMAGE.md** - Image creation methods
- **BUILD_NOW.md** - Quick start

View on GitHub: https://github.com/sowavy234/ghostpi

## 🎯 Quick Summary

1. **Get image:** GitHub Actions → Run workflow → Download
2. **Flash:** Use `dd` command or Raspberry Pi Imager
3. **Boot:** Insert SD card → Power on → See boot splash!

---

**Ready?** Go to GitHub Actions and start the build! 🚀

https://github.com/sowavy234/ghostpi/actions

