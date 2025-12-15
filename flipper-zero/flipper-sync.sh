#!/bin/bash
# Flipper Zero Bidirectional Code Sync
# Pushes code from HackberryPi to Flipper or vice versa

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
FLIPPER_MOUNT="/mnt/flipper"
SYNC_DIR="$PROJECT_ROOT/flipper-zero"
LOG_FILE="/var/log/flipper-sync.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [SYNC] $1" | tee -a "$LOG_FILE"
}

detect_flipper() {
    source "$SCRIPT_DIR/flipper-detector.sh" 2>/dev/null || {
        log "Flipper Zero not detected"
        return 1
    }
    return 0
}

push_to_flipper() {
    log "Pushing code to Flipper Zero..."
    
    if ! detect_flipper; then
        log "Error: Flipper Zero not connected"
        return 1
    fi
    
    # Push apps
    if [ -d "$SYNC_DIR/apps" ]; then
        log "Pushing apps..."
        cp -r "$SYNC_DIR/apps/"* "$FLIPPER_MOUNT/apps/" 2>/dev/null || {
            mkdir -p "$FLIPPER_MOUNT/apps"
            cp -r "$SYNC_DIR/apps/"* "$FLIPPER_MOUNT/apps/"
        }
        log "✓ Apps pushed"
    fi
    
    # Push scripts
    if [ -d "$SYNC_DIR/scripts" ]; then
        log "Pushing scripts..."
        mkdir -p "$FLIPPER_MOUNT/scripts"
        cp -r "$SYNC_DIR/scripts/"* "$FLIPPER_MOUNT/scripts/"
        log "✓ Scripts pushed"
    fi
    
    # Push brute force tools
    if [ -d "$SYNC_DIR/brute-force" ]; then
        log "Pushing brute force tools..."
        mkdir -p "$FLIPPER_MOUNT/brute_force"
        cp -r "$SYNC_DIR/brute-force/"* "$FLIPPER_MOUNT/brute_force/"
        log "✓ Brute force tools pushed"
    fi
    
    log "✓ Code push completed"
}

pull_from_flipper() {
    log "Pulling code from Flipper Zero..."
    
    if ! detect_flipper; then
        log "Error: Flipper Zero not connected"
        return 1
    fi
    
    # Pull apps
    if [ -d "$FLIPPER_MOUNT/apps" ]; then
        log "Pulling apps..."
        mkdir -p "$SYNC_DIR/apps"
        cp -r "$FLIPPER_MOUNT/apps/"* "$SYNC_DIR/apps/" 2>/dev/null || true
        log "✓ Apps pulled"
    fi
    
    # Pull scripts
    if [ -d "$FLIPPER_MOUNT/scripts" ]; then
        log "Pulling scripts..."
        mkdir -p "$SYNC_DIR/scripts"
        cp -r "$FLIPPER_MOUNT/scripts/"* "$SYNC_DIR/scripts/" 2>/dev/null || true
        log "✓ Scripts pulled"
    fi
    
    # Pull custom code
    if [ -d "$FLIPPER_MOUNT/custom" ]; then
        log "Pulling custom code..."
        mkdir -p "$SYNC_DIR/custom"
        cp -r "$FLIPPER_MOUNT/custom/"* "$SYNC_DIR/custom/" 2>/dev/null || true
        log "✓ Custom code pulled"
    fi
    
    log "✓ Code pull completed"
}

sync_bidirectional() {
    log "Starting bidirectional sync..."
    
    # Pull first (get latest from Flipper)
    pull_from_flipper || true
    
    # Then push (send updates to Flipper)
    push_to_flipper || true
    
    log "✓ Bidirectional sync completed"
}

case "${1:-sync}" in
    push)
        push_to_flipper
        ;;
    pull)
        pull_from_flipper
        ;;
    sync)
        sync_bidirectional
        ;;
    *)
        echo "Usage: $0 {push|pull|sync}"
        exit 1
        ;;
esac

