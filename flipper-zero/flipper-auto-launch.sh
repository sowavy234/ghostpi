#!/bin/bash
# Flipper Zero Auto-Launch Terminal
# Automatically opens terminal with coding help when Flipper connects
# EDUCATIONAL PURPOSES ONLY

set -e

LOG_FILE="/var/log/flipper-auto-launch.log"
FLIPPER_MOUNT="/mnt/flipper"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

detect_flipper() {
    # Check USB devices
    if lsusb 2>/dev/null | grep -qi "flipper\|0483:5740"; then
        return 0
    fi
    
    # Check serial devices
    if ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null | head -1 | grep -q .; then
        if dmesg | tail -20 | grep -qi "flipper\|0483:5740"; then
            return 0
        fi
    fi
    
    # Check mounted storage
    if mount | grep -qi "flipper"; then
        return 0
    fi
    
    return 1
}

launch_flipper_terminal() {
    log "Flipper Zero detected - Launching terminal with coding help..."
    
    # Play notification
    /usr/local/bin/speaker-notifications.sh notify "Flipper Zero Connected" "notification" 2>/dev/null || true
    
    # Show LED notification
    /usr/local/bin/wavy-led-control.sh notify 2>/dev/null || true
    
    # Launch terminal with Flipper help
    if [ -t 0 ]; then
        # Interactive terminal
        /usr/local/bin/flipper-coding-terminal.sh
    else
        # Background - open in new terminal or display message
        echo "Flipper Zero detected! Run: flipper-coding-terminal.sh"
        DISPLAY=:0 xterm -e "/usr/local/bin/flipper-coding-terminal.sh" 2>/dev/null || \
        gnome-terminal -- "/usr/local/bin/flipper-coding-terminal.sh" 2>/dev/null || \
        x-terminal-emulator -e "/usr/local/bin/flipper-coding-terminal.sh" 2>/dev/null || true
    fi
}

# Monitor for Flipper connection
monitor() {
    log "Flipper Zero auto-launch monitor started"
    local last_state=false
    
    while true; do
        if detect_flipper; then
            if [ "$last_state" = "false" ]; then
                log "Flipper Zero connected!"
                launch_flipper_terminal
                last_state=true
            fi
        else
            if [ "$last_state" = "true" ]; then
                log "Flipper Zero disconnected"
                last_state=false
            fi
        fi
        
        sleep 2
    done
}

case "${1:-monitor}" in
    monitor)
        monitor
        ;;
    detect)
        if detect_flipper; then
            echo "Flipper Zero detected"
            launch_flipper_terminal
        else
            echo "Flipper Zero not detected"
        fi
        ;;
    *)
        echo "Usage: $0 {monitor|detect}"
        exit 1
        ;;
esac

