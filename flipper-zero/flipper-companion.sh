#!/bin/bash
# Flipper Zero Companion Service
# Automatically detects Flipper Zero and manages connection

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="/var/log/flipper-companion.log"
CHECK_INTERVAL=10  # Check every 10 seconds
LAST_STATE="disconnected"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [COMPANION] $1" | tee -a "$LOG_FILE"
}

detect_flipper() {
    source "$SCRIPT_DIR/flipper-detector.sh" > /tmp/flipper-status.txt 2>/dev/null
    if grep -q "FLIPPER_DETECTED=true" /tmp/flipper-status.txt 2>/dev/null; then
        return 0
    fi
    return 1
}

on_connect() {
    log "🎉 Flipper Zero connected!"
    
    # Get Flipper info
    source /tmp/flipper-status.txt 2>/dev/null || true
    
    # Sync code
    "$SCRIPT_DIR/flipper-sync.sh" sync || true
    
    # Start services
    systemctl start flipper-brute-helper.service 2>/dev/null || true
    
    # Notify user
    log "✓ Flipper Zero ready for use"
    log "✓ Code synced"
    log "✓ Brute force helper available"
    
    # Show connection info
    if [ -n "$FLIPPER_DEVICE" ]; then
        log "Device: $FLIPPER_DEVICE"
    fi
    if [ -n "$FLIPPER_MOUNT" ]; then
        log "Mount: $FLIPPER_MOUNT"
    fi
}

on_disconnect() {
    log "⚠️ Flipper Zero disconnected"
    
    # Stop services
    systemctl stop flipper-brute-helper.service 2>/dev/null || true
    
    log "Waiting for reconnection..."
}

monitor() {
    log "Flipper Zero Companion started"
    log "Monitoring for Flipper Zero connection..."
    
    while true; do
        if detect_flipper; then
            if [ "$LAST_STATE" != "connected" ]; then
                LAST_STATE="connected"
                on_connect
            fi
        else
            if [ "$LAST_STATE" != "disconnected" ]; then
                LAST_STATE="disconnected"
                on_disconnect
            fi
        fi
        
        sleep "$CHECK_INTERVAL"
    done
}

case "${1:-monitor}" in
    monitor)
        monitor
        ;;
    check)
        if detect_flipper; then
            echo "Flipper Zero: Connected"
            on_connect
        else
            echo "Flipper Zero: Not connected"
        fi
        ;;
    *)
        echo "Usage: $0 {monitor|check}"
        exit 1
        ;;
esac

