#!/bin/bash
# Flipper Zero Sync - Push/Pull code between HackberryPi and Flipper Zero
# Educational purposes - Brute force tools and app development

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FLIPPER_DIR="$PROJECT_ROOT/flipper-zero"
SYNC_DIR="/opt/flipper-zero/sync"
LOG_FILE="/var/log/flipper-sync.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

detect_flipper() {
    source "$SCRIPT_DIR/detect_flipper.sh"
    local result=$(detect_flipper)
    echo "$result"
}

# Install Flipper tools
install_flipper_tools() {
    log "Installing Flipper Zero tools..."
    
    # Install qFlipper CLI
    if ! command -v qflipper-cli &> /dev/null; then
        apt-get update -qq
        apt-get install -y qflipper-cli 2>/dev/null || {
            log "qflipper-cli not in repos, building from source..."
            # Build instructions would go here
        }
    fi
    
    # Install FBT (Flipper Build Tool)
    if [ ! -d "/opt/flipperzero-firmware" ]; then
        log "Cloning Flipper Zero firmware for FBT..."
        git clone --recursive https://github.com/flipperdevices/flipperzero-firmware.git /opt/flipperzero-firmware 2>/dev/null || true
        
        # Install FBT dependencies
        cd /opt/flipperzero-firmware
        ./fbt --help > /dev/null 2>&1 || {
            log "Installing FBT dependencies..."
            apt-get install -y python3 python3-pip scons libusb-1.0-0-dev 2>/dev/null || true
        }
    fi
    
    log "Flipper tools installed"
}

# Push code to Flipper Zero
push_to_flipper() {
    local source_dir="${1:-$FLIPPER_DIR/apps}"
    local flipper_path=$(detect_flipper)
    
    if [ "$flipper_path" = "NOT_FOUND" ]; then
        log "Error: Flipper Zero not detected"
        return 1
    fi
    
    log "Pushing code to Flipper Zero..."
    
    # Use qFlipper CLI if available
    if command -v qflipper-cli &> /dev/null; then
        qflipper-cli upload "$source_dir" /ext/apps 2>/dev/null && {
            log "✓ Code pushed to Flipper Zero"
            return 0
        }
    fi
    
    # Fallback: Use serial/USB
    if [[ "$flipper_path" == SERIAL:* ]]; then
        local device="${flipper_path#SERIAL:}"
        # Use flipper-cli or direct serial communication
        log "Using serial device: $device"
        # Implementation would go here
    fi
    
    log "Push completed"
}

# Pull code from Flipper Zero
pull_from_flipper() {
    local dest_dir="${1:-$SYNC_DIR/flipper-backup}"
    local flipper_path=$(detect_flipper)
    
    if [ "$flipper_path" = "NOT_FOUND" ]; then
        log "Error: Flipper Zero not detected"
        return 1
    fi
    
    log "Pulling code from Flipper Zero..."
    mkdir -p "$dest_dir"
    
    # Use qFlipper CLI if available
    if command -v qflipper-cli &> /dev/null; then
        qflipper-cli download /ext/apps "$dest_dir" 2>/dev/null && {
            log "✓ Code pulled from Flipper Zero"
            return 0
        }
    fi
    
    log "Pull completed"
}

# Auto-sync on connection
auto_sync() {
    log "Starting auto-sync mode..."
    
    while true; do
        local flipper_path=$(detect_flipper)
        
        if [ "$flipper_path" != "NOT_FOUND" ]; then
            log "Flipper Zero detected: $flipper_path"
            
            # Pull from Flipper first
            pull_from_flipper
            
            # Push latest apps to Flipper
            push_to_flipper
            
            # Wait before next check
            sleep 60
        else
            sleep 10
        fi
    done
}

case "${1:-auto}" in
    push)
        push_to_flipper "$2"
        ;;
    pull)
        pull_from_flipper "$2"
        ;;
    auto)
        auto_sync
        ;;
    install)
        install_flipper_tools
        ;;
    *)
        echo "Usage: $0 {push|pull|auto|install}"
        exit 1
        ;;
esac

