#!/bin/bash
# Flipper Zero Auto-Detection and Connection Manager
# Automatically detects Flipper Zero when connected

set -e

LOG_FILE="/var/log/flipper-detector.log"
FLIPPER_MOUNT="/mnt/flipper"
FLIPPER_DEVICE=""

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

detect_flipper() {
    log "Scanning for Flipper Zero..."
    
    # Check USB devices
    local usb_devices=$(lsusb 2>/dev/null | grep -i "flipper" || true)
    if [ -n "$usb_devices" ]; then
        log "✓ Flipper Zero detected via USB: $usb_devices"
        return 0
    fi
    
    # Check serial devices
    local serial_devices=$(ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null | head -1)
    if [ -n "$serial_devices" ]; then
        log "✓ Serial device found: $serial_devices"
        FLIPPER_DEVICE="$serial_devices"
        return 0
    fi
    
    # Check for Flipper storage
    local storage=$(lsblk -o NAME,LABEL | grep -i "flipper" || true)
    if [ -n "$storage" ]; then
        log "✓ Flipper storage detected: $storage"
        return 0
    fi
    
    return 1
}

mount_flipper() {
    if [ -z "$FLIPPER_DEVICE" ]; then
        # Try to find Flipper storage
        local flipper_part=$(lsblk -o NAME,LABEL | grep -i "flipper" | awk '{print $1}' | head -1)
        if [ -n "$flipper_part" ]; then
            FLIPPER_DEVICE="/dev/$flipper_part"
        else
            # Try common mount points
            if mountpoint -q /media/*/FLIPPER 2>/dev/null; then
                FLIPPER_MOUNT=$(mountpoint -d /media/*/FLIPPER 2>/dev/null | head -1)
                log "✓ Flipper already mounted at: $FLIPPER_MOUNT"
                return 0
            fi
        fi
    fi
    
    if [ -n "$FLIPPER_DEVICE" ]; then
        mkdir -p "$FLIPPER_MOUNT"
        mount "$FLIPPER_DEVICE" "$FLIPPER_MOUNT" 2>/dev/null && {
            log "✓ Flipper mounted at: $FLIPPER_MOUNT"
            return 0
        }
    fi
    
    return 1
}

sync_to_flipper() {
    local source_dir="$1"
    local target_dir="${2:-$FLIPPER_MOUNT}"
    
    if [ ! -d "$target_dir" ]; then
        log "Error: Flipper not mounted"
        return 1
    fi
    
    log "Syncing $source_dir to Flipper..."
    rsync -av --progress "$source_dir/" "$target_dir/" || {
        log "Sync failed, trying manual copy..."
        cp -r "$source_dir"/* "$target_dir/" 2>/dev/null || true
    }
    
    log "✓ Sync completed"
}

sync_from_flipper() {
    local source_dir="${1:-$FLIPPER_MOUNT}"
    local target_dir="$2"
    
    if [ ! -d "$source_dir" ]; then
        log "Error: Flipper not mounted"
        return 1
    fi
    
    if [ -z "$target_dir" ]; then
        target_dir="/opt/flipper/backup/$(date +%Y%m%d_%H%M%S)"
    fi
    
    mkdir -p "$target_dir"
    log "Backing up from Flipper to $target_dir..."
    rsync -av --progress "$source_dir/" "$target_dir/" || {
        cp -r "$source_dir"/* "$target_dir/" 2>/dev/null || true
    }
    
    log "✓ Backup completed"
}

case "${1:-detect}" in
    detect)
        if detect_flipper; then
            echo "Flipper Zero detected!"
            mount_flipper && echo "Mounted at: $FLIPPER_MOUNT"
        else
            echo "Flipper Zero not detected"
            exit 1
        fi
        ;;
    mount)
        mount_flipper
        ;;
    sync-to)
        sync_to_flipper "${2:-/opt/flipper/apps}" "${3:-$FLIPPER_MOUNT}"
        ;;
    sync-from)
        sync_from_flipper "${2:-$FLIPPER_MOUNT}" "${3:-}"
        ;;
    status)
        if detect_flipper; then
            echo "Status: Connected"
            if mount_flipper; then
                echo "Mounted: Yes"
                echo "Mount point: $FLIPPER_MOUNT"
                echo "Available space: $(df -h $FLIPPER_MOUNT | tail -1 | awk '{print $4}')"
            else
                echo "Mounted: No"
            fi
        else
            echo "Status: Not connected"
        fi
        ;;
    *)
        echo "Usage: $0 {detect|mount|sync-to [source] [target]|sync-from [source] [target]|status}"
        exit 1
        ;;
esac

