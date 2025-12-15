#!/bin/bash
# HackberryPi CM5 Touchscreen Configuration
# 4" 720x720 TFT Touch Display
# Based on: https://github.com/ZitaoTech/HackberryPiCM5

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/hackberry-touchscreen.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Configure touchscreen for 720x720 display
configure_touchscreen() {
    log "Configuring HackberryPi CM5 touchscreen (720x720)..."
    
    # Create X11 touchscreen configuration
    mkdir -p /etc/X11/xorg.conf.d
    cat > /etc/X11/xorg.conf.d/99-hackberry-touchscreen.conf <<'XORG'
Section "InputClass"
    Identifier "HackberryPi CM5 Touchscreen"
    MatchIsTouchscreen "on"
    MatchDevicePath "/dev/input/event*"
    Driver "libinput"
    Option "CalibrationMatrix" "1 0 0 0 1 0 0 0 1"
    Option "TransformationMatrix" "1 0 0 0 1 0 0 0 1"
    Option "Tapping" "on"
    Option "TappingDrag" "on"
    Option "TappingDragLock" "off"
    Option "DisableWhileTyping" "on"
    Option "AccelProfile" "flat"
    Option "AccelSpeed" "0.5"
EndSection
XORG

    log "✓ X11 touchscreen configuration created"
    
    # Configure framebuffer for 720x720
    if [ -f /boot/config.txt ]; then
        # Add display configuration if not present
        if ! grep -q "dtoverlay=vc4-kms-dpi-hyperpixel4sq" /boot/config.txt; then
            log "Adding display overlay to config.txt..."
            cat >> /boot/config.txt <<'CONFIG'

# HackberryPi CM5 Display Configuration
# 4" 720x720 TFT Touch Display
dtoverlay=vc4-kms-dpi-hyperpixel4sq
framebuffer_width=720
framebuffer_height=720
display_rotate=0
CONFIG
            log "✓ Display configuration added to config.txt"
        fi
    fi
    
    # Configure touchscreen calibration
    log "Setting up touchscreen calibration..."
    mkdir -p /etc/udev/rules.d
    cat > /etc/udev/rules.d/99-hackberry-touchscreen.rules <<'UDEV'
# HackberryPi CM5 Touchscreen udev rules
SUBSYSTEM=="input", KERNEL=="event*", ATTRS{name}=="*touchscreen*", SYMLINK+="input/touchscreen"
UDEV

    log "✓ Touchscreen udev rules created"
    
    # Calibrate touchscreen (if xinput-calibrator is available)
    if command -v xinput-calibrator &> /dev/null; then
        log "Touchscreen calibrator available"
        log "Run 'xinput-calibrator' to calibrate if needed"
    else
        log "Installing touchscreen calibration tool..."
        apt-get update -qq
        apt-get install -y xinput-calibrator >/dev/null 2>&1 || true
    fi
    
    # Create calibration script
    cat > /usr/local/bin/calibrate-touchscreen.sh <<'CALIB'
#!/bin/bash
# Calibrate HackberryPi CM5 touchscreen

echo "HackberryPi CM5 Touchscreen Calibration"
echo "Follow the on-screen instructions to calibrate"
echo ""

if command -v xinput-calibrator &> /dev/null; then
    xinput-calibrator
else
    echo "xinput-calibrator not found. Installing..."
    sudo apt-get update
    sudo apt-get install -y xinput-calibrator
    xinput-calibrator
fi
CALIB

    chmod +x /usr/local/bin/calibrate-touchscreen.sh
    log "✓ Calibration script created: calibrate-touchscreen.sh"
}

# Test touchscreen
test_touchscreen() {
    log "Testing touchscreen..."
    
    if [ -d /sys/class/input ]; then
        local touch_devices=$(find /sys/class/input -name "event*" -exec grep -l "touchscreen\|Touch" {} \; 2>/dev/null | head -1)
        
        if [ -n "$touch_devices" ]; then
            log "✓ Touchscreen device found: $touch_devices"
            return 0
        else
            log "⚠ Touchscreen device not detected"
            return 1
        fi
    fi
    
    return 1
}

# Main installation
main() {
    log "HackberryPi CM5 Touchscreen Configuration"
    log "Display: 4\" 720x720 TFT Touch"
    
    configure_touchscreen
    test_touchscreen
    
    log "✓ Touchscreen configuration complete"
    log ""
    log "To calibrate: sudo calibrate-touchscreen.sh"
    log "Reboot required for changes to take effect"
}

case "${1:-install}" in
    install)
        main
        ;;
    test)
        test_touchscreen
        ;;
    calibrate)
        /usr/local/bin/calibrate-touchscreen.sh
        ;;
    *)
        echo "Usage: $0 {install|test|calibrate}"
        exit 1
        ;;
esac

