# 🚀 Build Your .img File NOW

## ✅ Easiest Method: GitHub Actions

Your repository is ready! Here's how to get your flashable .img file:

### Step 1: Go to GitHub Actions

**Open in browser:** https://github.com/sowavy234/ghostpi/actions

### Step 2: Run the Workflow

1. Click **"Build GhostPi Images"** in the left sidebar
2. Click the **"Run workflow"** button (top right, green button)
3. Select branch: **`main`**
4. Choose: **`CM5`** (or `CM4` if you need that)
5. Click **"Run workflow"**

### Step 3: Wait for Build

- Build takes 10-20 minutes
- You can watch progress in real-time
- GitHub will email you when done (if enabled)

### Step 4: Download Your Image

1. When build completes, click on the workflow run
2. Scroll down to **"Artifacts"** section
3. Click **"ghostpi-images"**
4. Download the zip file
5. Extract to get your `.img` file

### Step 5: Flash to SD Card

```bash
# On Mac - Find your SD card
diskutil list

# Unmount SD card (replace diskX with your device)
diskutil unmountDisk /dev/diskX

# Flash image (replace diskX)
sudo dd if=GhostPi-CM5-*.img of=/dev/rdiskX bs=4M

# Eject when done
diskutil eject /dev/diskX
```

## 🎯 That's It!

Your image will be at: `GhostPi-CM5-YYYYMMDD_HHMMSS.img`

**Size:** ~4-8GB (depending on content)

## 🔄 Alternative: Start Docker

If you want to build locally with Docker:

```bash
# Start Docker Desktop app first
# Then run:
cd ~/Downloads/ghostpi
./scripts/build_mac.sh CM5
```

## 📋 What's in the Image?

- ✅ Boot partition with proper config.txt
- ✅ Root filesystem structure
- ✅ Boot splash theme files
- ✅ Swapfile service
- ✅ Hardware detection scripts
- ✅ Ready to boot on CM4/CM5/Pi 4/Pi 5

---

**Go to GitHub Actions now:** https://github.com/sowavy234/ghostpi/actions

Click "Run workflow" → Choose CM5 → Wait → Download! 🎉

