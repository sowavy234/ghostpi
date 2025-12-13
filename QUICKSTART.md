# GhostPi Quick Start Guide

## Create Your Bootable Image

### Step 1: Generate Placeholder Images (Optional)

If you don't have 3D renders yet, create placeholders:

```bash
cd ~/Downloads/ghostpi
./scripts/generate_placeholder_images.sh
```

**Note**: Replace these with actual 3D renders later:
- `boot-splash/character.png` - Your 3D character with tattoos and Glock
- `boot-splash/glock.png` - Glock with 30-round magazine
- `boot-splash/text_welcome.png` - "Welcome to Wavy's World" text
- `boot-splash/text_glock.png` - "Welcome to Glock's World Enjoy" text
- `boot-splash/star.png` - Star sprite

### Step 2: Create the Bootable Image

```bash
cd ~/Downloads/ghostpi
sudo ./scripts/create_ghostpi_image.sh
```

This will:
- Create bootable .img file
- Install custom boot splash
- Set up swapfile service
- Configure for CM4/CM5/Pi 4/Pi 5

### Step 3: Flash to SD Card

```bash
# Find your SD card
lsblk

# Flash the image (replace sdX with your device)
sudo dd if=~/Downloads/ghostpi/GhostPi-*.img of=/dev/sdX bs=4M status=progress
```

Or use **Raspberry Pi Imager**:
1. Download: https://www.raspberrypi.com/software/
2. Select "Use custom image"
3. Choose your GhostPi .img file

### Step 4: Boot Your Pi!

Insert SD card and power on. You'll see:
- **"Welcome to Wavy's World"** boot splash
- 3D space background with stars
- Animated character with tattoos and Glock
- **"Welcome to Glock's World Enjoy"** text

## Features Included

✅ **Custom Boot Splash** - 3D animated "Wavy's World" theme  
✅ **Universal Support** - Works on CM4, CM5, Pi 4, Pi 5  
✅ **Swapfile Service** - Automatic swap management  
✅ **Hardware Detection** - Auto-configures for your Pi model  
✅ **Pentesting Tools** - Pre-installed security tools  

## Swapfile Service

The swapfile service automatically:
- Creates 2GB swapfile on first boot
- Monitors memory usage
- Increases swap if needed
- Prevents out-of-memory crashes

Check status:
```bash
sudo systemctl status swapfile-manager
```

## Customizing the Boot Splash

Edit `boot-splash/wavys-world.script` to:
- Adjust animation speed
- Change character position
- Modify text effects
- Add more effects

Then rebuild the image.

## Troubleshooting

### Boot Splash Not Showing

1. Check Plymouth is installed:
   ```bash
   plymouth --version
   ```

2. Verify theme is installed:
   ```bash
   ls /usr/share/plymouth/themes/wavys-world/
   ```

3. Update initramfs:
   ```bash
   sudo update-initramfs -u
   ```

### Swapfile Service Not Working

1. Check service status:
   ```bash
   sudo systemctl status swapfile-manager
   ```

2. Check logs:
   ```bash
   sudo journalctl -u swapfile-manager
   ```

3. Manually start:
   ```bash
   sudo /usr/local/bin/swapfile-manager.sh start
   ```

## Next Steps

1. **Replace placeholder images** with your 3D renders
2. **Customize the theme** in `boot-splash/wavys-world.script`
3. **Add more features** as needed
4. **Share your creation!**

Welcome to Wavy's World! 🎮🔫

