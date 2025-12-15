#!/bin/bash
# Flipper Zero Auto-Detection and Connection Manager
# Automatically detects Flipper Zero when connected

set -e

LOG_FILE="/var/log/flipper-zero.log"
FLIPPER_MOUNT="/mnt/flipper"
FLIPPER_DEVICE=""

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FLIPPER] $1" | tee -a "$LOG_FILE"
}

detect_flipper() {
    log "Scanning for Flipper Zero..."
    
    # Check USB devices
    local usb_devices=$(lsusb 2>/dev/null | grep -i "flipper" || true)
    
    if [ -n "$usb_devices" ]; then
        log "✓ Flipper Zero detected via USB"
        echo "$usb_devices"
        return 0
    fi
    
    # Check serial devices
    local serial_devices=$(ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null | head -1 || true)
    
    if [ -n "$serial_devices" ]; then
        log "✓ Serial device found: $serial_devices"
        # Try to identify if it's Flipper
        if dmesg | tail -20 | grep -qi "flipper\|0483:5740"; then
            log "✓ Confirmed as Flipper Zero"
            FLIPPER_DEVICE="$serial_devices"
            return 0
        fi
    fi
    
    # Check mounted storage
    if mount | grep -qi "flipper"; then
        log "✓ Flipper Zero storage mounted"
        FLIPPER_MOUNT=$(mount | grep -i flipper | awk '{print $3}' | head -1)
        return 0
    fi
    
    # Check for Flipper via qFlipper CLI
    if command -v qflipper-cli &> /dev/null; then
        if qflipper-cli info 2>/dev/null | grep -qi "flipper"; then
            log "✓ Flipper Zero detected via qFlipper CLI"
            return 0
        fi
    fi
    
    log "✗ Flipper Zero not detected"
    return 1
}

mount_flipper() {
    if [ -z "$FLIPPER_MOUNT" ] || [ "$FLIPPER_MOUNT" = "/mnt/flipper" ]; then
        mkdir -p "$FLIPPER_MOUNT"
        
        # Try to mount Flipper storage
        if mount | grep -q "/mnt/flipper"; then
            log "Flipper already mounted"
            return 0
        fi
        
        # Find Flipper storage device
        local flipper_disk=$(lsblk -o NAME,MODEL | grep -i "flipper" | awk '{print $1}' | head -1)
        
        if [ -n "$flipper_disk" ]; then
            local device="/dev/${flipper_disk}"
            mount "$device" "$FLIPPER_MOUNT" 2>/dev/null && {
                log "✓ Flipper Zero mounted at $FLIPPER_MOUNT"
                return 0
            }
        fi
    fi
    
    return 1
}

get_flipper_info() {
    log "Getting Flipper Zero information..."
    
    local info=""
    
    # Try qFlipper CLI
    if command -v qflipper-cli &> /dev/null; then
        info=$(qflipper-cli info 2>/dev/null || true)
        if [ -n "$info" ]; then
            echo "$info"
            return 0
        fi
    fi
    
    # Try serial connection
    if [ -n "$FLIPPER_DEVICE" ]; then
        # Use flipper-cli if available
        if command -v flipper-cli &> /dev/null; then
            info=$(flipper-cli -p "$FLIPPER_DEVICE" info 2>/dev/null || true)
            echo "$info"
            return 0
        fi
    fi
    
    # Check mounted storage for info
    if [ -d "$FLIPPER_MOUNT" ]; then
        if [ -f "$FLIPPER_MOUNT/.flipper" ]; then
            cat "$FLIPPER_MOUNT/.flipper" 2>/dev/null || true
        fi
    fi
    
    return 0
}

# Main detection
if detect_flipper; then
    mount_flipper || true
    get_flipper_info
    echo "FLIPPER_DETECTED=true"
    echo "FLIPPER_DEVICE=$FLIPPER_DEVICE"
    echo "FLIPPER_MOUNT=$FLIPPER_MOUNT"
else
    echo "FLIPPER_DETECTED=false"
    exit 1
fi

