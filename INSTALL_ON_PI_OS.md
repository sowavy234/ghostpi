# Install GhostPi on Raspberry Pi OS Lite 64-bit (CM4)

## Step 1: Flash Raspberry Pi OS Lite 64-bit

### On macOS:

1. **Download Raspberry Pi Imager:**
   - https://www.raspberrypi.com/software/
   - Install it

2. **Flash Raspberry Pi OS Lite 64-bit:**
   - Open Raspberry Pi Imager
   - Click "Choose OS" → "Raspberry Pi OS (other)" → "Raspberry Pi OS Lite (64-bit)"
   - Click "Choose Storage" → Select your SD card
   - **IMPORTANT:** Click the gear icon (⚙️) to enable SSH and set password:
     - ✅ Enable SSH
     - Set username: `pi` (or your choice)
     - Set password: (choose a secure password)
   - Click "Write" and wait for completion

3. **Eject SD card** and insert into your CM4

## Step 2: Boot and Connect

1. **Power on** your CM4
2. **Find the IP address:**
   - Check your router's admin page, OR
   - Use: `ping raspberrypi.local` (if on same network)
   - Or scan network: `nmap -sn 192.168.1.0/24` (adjust IP range)

3. **SSH into the Pi:**
   ```bash
   ssh pi@<PI_IP_ADDRESS>
   # Or if hostname works:
   ssh pi@raspberrypi.local
   ```
   Enter the password you set

## Step 3: Install GhostPi

Once connected via SSH, run these commands:

```bash
# Update system
sudo apt-get update
sudo apt-get upgrade -y

# Install git if not already installed
sudo apt-get install -y git

# Clone GhostPi repository
cd ~
git clone https://github.com/sowavy234/ghostpi.git
cd ghostpi

# Make scripts executable
chmod +x scripts/*.sh

# Run the quick install script
sudo ./scripts/quick_install.sh
```

## Step 4: Install Additional Components (Optional)

After the quick install, you can add more features:

```bash
cd ~/ghostpi

# Install HackberryPi CM4 support (if using CM4)
sudo ./scripts/install_hackberry_cm5.sh

# Install pentesting tools
sudo ./scripts/install_pentest_tools.sh

# Install auto-update system
sudo ./scripts/install_auto_update.sh

# Install 2025 services
sudo ./scripts/install_2025_services.sh
```

## Step 5: Reboot

```bash
sudo reboot
```

After reboot, you should see:
- ✅ "Welcome to Wavy's World" boot splash
- ✅ All GhostPi services running
- ✅ Enhanced terminal with system info

## Step 6: Verify Installation

```bash
# Check boot splash
plymouth-set-default-theme wavys-world

# Check swapfile service
sudo systemctl status swapfile-manager.service

# Check terminal
wavy-terminal

# Check battery (if applicable)
battery-status

# Check AI companion
wavy-companion
```

## Troubleshooting

### Can't SSH into Pi
- Make sure SSH was enabled in Raspberry Pi Imager (gear icon)
- Check Pi is on same network
- Try: `ssh -v pi@<IP>` for verbose output

### Installation fails
- Make sure you're running as root: `sudo ./scripts/quick_install.sh`
- Check internet connection: `ping google.com`
- Update system first: `sudo apt-get update && sudo apt-get upgrade -y`

### Boot splash not showing
```bash
sudo plymouth-set-default-theme wavys-world
sudo update-initramfs -u
sudo reboot
```

### Services not starting
```bash
# Check service status
sudo systemctl status swapfile-manager.service

# Enable services
sudo systemctl enable swapfile-manager.service
sudo systemctl start swapfile-manager.service
```

## Quick Reference Commands

```bash
# Main installation (one command after cloning)
cd ~/ghostpi && sudo ./scripts/quick_install.sh

# Check what was installed
ls -la /usr/local/bin/ | grep -E "wavy|swapfile|battery"

# View logs
sudo journalctl -u swapfile-manager.service -f

# Update GhostPi
cd ~/ghostpi
git pull
sudo ./scripts/quick_install.sh
```

---

**Welcome to Wavy's World on CM4!** 🎮✨

