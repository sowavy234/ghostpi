# Building GhostPi on macOS

Since the build process requires Linux tools, here are several methods to build on macOS:

## Method 1: Docker (Recommended) 🐳

### Prerequisites
```bash
# Install Docker Desktop for Mac
# Download from: https://www.docker.com/products/docker-desktop
```

### Build
```bash
cd ~/Downloads/ghostpi
./scripts/build_mac.sh CM5
```

This will:
- Build a Docker image with all dependencies
- Run the build process in the container
- Output the .img file to `~/Downloads/ghostpi/`

## Method 2: Linux VM (VirtualBox/VMware)

### Setup
1. Install VirtualBox: https://www.virtualbox.org/
2. Download Ubuntu 22.04 ISO
3. Create VM with 20GB+ disk space
4. Install Ubuntu in VM

### Build
```bash
# In macOS, copy folder to VM
scp -r ~/Downloads/ghostpi user@vm-ip:~/

# SSH into VM
ssh user@vm-ip

# In VM, run:
cd ~/ghostpi
sudo ./BUILD_ON_LINUX.sh CM5
```

## Method 3: Remote Linux Server

### Build on Remote Server
```bash
# Copy to server
scp -r ~/Downloads/ghostpi user@server:~/

# SSH into server
ssh user@server

# Build
cd ~/ghostpi
sudo ./BUILD_ON_LINUX.sh CM5

# Download image
scp user@server:~/Downloads/ghostpi/GhostPi-*.img ~/Downloads/
```

## Method 4: GitHub Actions (CI/CD)

### Setup
1. Push code to GitHub
2. Go to Actions tab
3. Run workflow manually
4. Download artifacts

### Workflow
The `.github/workflows/build.yml` file will:
- Build both CM4 and CM5 images
- Upload as artifacts
- Available for 7 days

## Method 5: Raspberry Pi Imager (Simplest)

### Steps
1. Download Raspberry Pi Imager for Mac
2. Install Raspberry Pi OS to SD card
3. Boot Pi and SSH in
4. Copy ghostpi folder to Pi
5. Run: `sudo ./scripts/quick_install.sh`

This installs everything on an existing Pi without building an image.

## Method 6: Wine (Not Recommended)

Wine doesn't work well for Linux build tools. Use one of the methods above instead.

## Quick Commands

### Build CM5 Image
```bash
# Docker
./scripts/build_mac.sh CM5

# Linux VM/Server
sudo ./BUILD_ON_LINUX.sh CM5
```

### Build CM4 Image
```bash
# Docker
./scripts/build_mac.sh CM4

# Linux VM/Server
sudo ./BUILD_ON_LINUX.sh CM4
```

## Troubleshooting

### Docker Issues
```bash
# Check Docker is running
docker ps

# Rebuild Docker image
docker build -t ghostpi-builder .
```

### VM Issues
- Ensure VM has enough disk space (20GB+)
- Allocate at least 4GB RAM
- Enable virtualization in BIOS

### Network Issues
- Check firewall settings
- Ensure SSH is enabled on remote server

## Recommended Approach

**For Mac users, I recommend:**
1. **Docker** (if you have it) - Easiest and fastest
2. **GitHub Actions** - No local setup needed
3. **Linux VM** - Full control, works offline
4. **Raspberry Pi Imager** - Simplest, but requires a Pi

Choose the method that works best for your setup!

