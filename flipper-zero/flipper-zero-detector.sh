#!/bin/bash
# Flipper Zero Auto-Detection and Companion Service
# Automatically detects Flipper Zero and enables two-way sync

set -e

LOG_FILE="/var/log/flipper-zero-detector.log"
FLIPPER_MOUNT="/mnt/flipper-zero"
FLIPPER_APPS_DIR="$FLIPPER_MOUNT/apps"
HACKBERRY_APPS_DIR="/opt/flipper-zero/apps"
SYNC_DIR="/opt/flipper-zero/sync"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [FLIPPER] $1" | tee -a "$LOG_FILE"
}

detect_flipper() {
    # Check for Flipper Zero via USB
    local flipper_device=$(lsusb | grep -i "flipper" || dmesg | grep -i "flipper" | tail -1)
    
    if [ -n "$flipper_device" ]; then
        # Check for mass storage device
        local usb_device=$(lsblk -o NAME,TYPE | grep disk | tail -1 | awk '{print $1}')
        
        if [ -n "$usb_device" ] && [ -b "/dev/$usb_device" ]; then
            # Try to mount
            if ! mountpoint -q "$FLIPPER_MOUNT" 2>/dev/null; then
                mkdir -p "$FLIPPER_MOUNT"
                mount "/dev/$usb_device" "$FLIPPER_MOUNT" 2>/dev/null && {
                    log "✓ Flipper Zero detected and mounted at $FLIPPER_MOUNT"
                    return 0
                }
            else
                log "Flipper Zero already mounted"
                return 0
            fi
        fi
    fi
    
    # Check for Flipper via serial/USB
    if [ -c "/dev/ttyACM0" ] || [ -c "/dev/ttyUSB0" ]; then
        log "Flipper Zero detected via serial"
        return 0
    fi
    
    return 1
}

sync_to_flipper() {
    if [ ! -d "$FLIPPER_MOUNT" ] || ! mountpoint -q "$FLIPPER_MOUNT" 2>/dev/null; then
        return 1
    fi
    
    log "Syncing apps to Flipper Zero..."
    
    # Sync apps
    if [ -d "$HACKBERRY_APPS_DIR" ]; then
        mkdir -p "$FLIPPER_APPS_DIR"
        rsync -av --delete "$HACKBERRY_APPS_DIR/" "$FLIPPER_APPS_DIR/" 2>/dev/null && {
            log "✓ Apps synced to Flipper Zero"
        }
    fi
    
    # Sync scripts
    if [ -d "$SYNC_DIR" ]; then
        mkdir -p "$FLIPPER_MOUNT/scripts"
        rsync -av "$SYNC_DIR/" "$FLIPPER_MOUNT/scripts/" 2>/dev/null && {
            log "✓ Scripts synced to Flipper Zero"
        }
    fi
    
    return 0
}

sync_from_flipper() {
    if [ ! -d "$FLIPPER_MOUNT" ] || ! mountpoint -q "$FLIPPER_MOUNT" 2>/dev/null; then
        return 1
    fi
    
    log "Syncing apps from Flipper Zero..."
    
    # Sync apps from Flipper
    if [ -d "$FLIPPER_APPS_DIR" ]; then
        mkdir -p "$HACKBERRY_APPS_DIR"
        rsync -av "$FLIPPER_APPS_DIR/" "$HACKBERRY_APPS_DIR/" 2>/dev/null && {
            log "✓ Apps synced from Flipper Zero"
        }
    fi
    
    # Sync scripts from Flipper
    if [ -d "$FLIPPER_MOUNT/scripts" ]; then
        mkdir -p "$SYNC_DIR"
        rsync -av "$FLIPPER_MOUNT/scripts/" "$SYNC_DIR/" 2>/dev/null && {
            log "✓ Scripts synced from Flipper Zero"
        }
    fi
    
    return 0
}

monitor() {
    log "Flipper Zero detector started"
    
    while true; do
        if detect_flipper; then
            # Two-way sync
            sync_to_flipper
            sync_from_flipper
            
            # Wait before next check
            sleep 30
        else
            # Unmount if was mounted
            if mountpoint -q "$FLIPPER_MOUNT" 2>/dev/null; then
                umount "$FLIPPER_MOUNT" 2>/dev/null || true
                log "Flipper Zero disconnected"
            fi
            
            sleep 10
        fi
    done
}

case "${1:-monitor}" in
    monitor)
        monitor
        ;;
    detect)
        detect_flipper && echo "Flipper Zero detected" || echo "Flipper Zero not found"
        ;;
    sync-to)
        sync_to_flipper
        ;;
    sync-from)
        sync_from_flipper
        ;;
    *)
        echo "Usage: $0 {monitor|detect|sync-to|sync-from}"
        exit 1
        ;;
esac

