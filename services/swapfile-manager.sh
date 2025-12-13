#!/bin/bash
# GhostPi Swapfile Manager
# Constantly watches and manages swapfile

SWAPFILE="/swapfile"
SWAP_SIZE="${SWAP_SIZE:-2048}"  # Default 2GB
MIN_FREE_MEM="${MIN_FREE_MEM:-512}"  # Minimum free memory in MB before increasing swap
MONITOR_INTERVAL=30  # Check every 30 seconds

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a /var/log/swapfile-manager.log
}

create_swapfile() {
    local size=$1
    log "Creating ${size}MB swapfile..."
    
    # Check if swapfile exists
    if [ -f "$SWAPFILE" ]; then
        log "Swapfile already exists, removing old one..."
        swapoff "$SWAPFILE" 2>/dev/null || true
        rm -f "$SWAPFILE"
    fi
    
    # Create swapfile
    fallocate -l ${size}M "$SWAPFILE" || dd if=/dev/zero of="$SWAPFILE" bs=1M count=$size
    chmod 600 "$SWAPFILE"
    mkswap "$SWAPFILE"
    swapon "$SWAPFILE"
    
    # Add to fstab if not present
    if ! grep -q "$SWAPFILE" /etc/fstab; then
        echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab
    fi
    
    log "Swapfile created and activated (${size}MB)"
}

get_free_memory() {
    free -m | awk '/^Mem:/ {print $7}'
}

get_swap_usage() {
    free -m | awk '/^Swap:/ {print $3}'
}

get_swap_total() {
    free -m | awk '/^Swap:/ {print $2}'
}

monitor_swap() {
    log "Starting swapfile monitoring service..."
    
    while true; do
        free_mem=$(get_free_memory)
        swap_used=$(get_swap_usage)
        swap_total=$(get_swap_total)
        
        # If free memory is low and swap is heavily used, increase swap
        if [ "$free_mem" -lt "$MIN_FREE_MEM" ] && [ "$swap_used" -gt $((swap_total * 80 / 100)) ]; then
            new_size=$((swap_total + 1024))  # Add 1GB
            log "Low memory detected (${free_mem}MB free, ${swap_used}MB swap used). Increasing swap to ${new_size}MB..."
            create_swapfile "$new_size"
        fi
        
        # Log status every 5 minutes
        if [ $(($(date +%s) % 300)) -eq 0 ]; then
            log "Status: ${free_mem}MB free memory, ${swap_used}MB/${swap_total}MB swap used"
        fi
        
        sleep "$MONITOR_INTERVAL"
    done
}

case "${1:-start}" in
    start)
        # Create initial swapfile if it doesn't exist
        if [ ! -f "$SWAPFILE" ] || ! swapon --show | grep -q "$SWAPFILE"; then
            create_swapfile "$SWAP_SIZE"
        fi
        
        # Start monitoring in background
        monitor_swap &
        echo $! > /var/run/swapfile-manager.pid
        log "Swapfile manager started (PID: $(cat /var/run/swapfile-manager.pid))"
        ;;
    stop)
        if [ -f /var/run/swapfile-manager.pid ]; then
            kill $(cat /var/run/swapfile-manager.pid) 2>/dev/null || true
            rm -f /var/run/swapfile-manager.pid
            log "Swapfile manager stopped"
        fi
        ;;
    status)
        free_mem=$(get_free_memory)
        swap_used=$(get_swap_usage)
        swap_total=$(get_swap_total)
        echo "Free Memory: ${free_mem}MB"
        echo "Swap Used: ${swap_used}MB / ${swap_total}MB"
        if [ -f /var/run/swapfile-manager.pid ]; then
            echo "Service: Running (PID: $(cat /var/run/swapfile-manager.pid))"
        else
            echo "Service: Stopped"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac

