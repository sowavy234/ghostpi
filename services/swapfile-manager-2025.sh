#!/bin/bash
# GhostPi Advanced Swapfile Manager 2025
# AI-Powered Memory Management with Predictive Optimization
# EDUCATIONAL PURPOSES ONLY

set -e

SWAPFILE="/swapfile"
LOG_FILE="/var/log/swapfile-manager-2025.log"
METRICS_FILE="/var/log/swapfile-metrics.json"
MONITOR_INTERVAL=10  # Check every 10 seconds for responsiveness
ADAPTIVE_MODE=true
PREDICTIVE_SCALING=true

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# AI-Powered Memory Pattern Analysis
analyze_memory_patterns() {
    local current_mem=$(free -m | awk '/^Mem:/ {print $3}')
    local current_swap=$(free -m | awk '/^Swap:/ {print $3}')
    local timestamp=$(date +%s)
    
    # Store metrics for pattern analysis
    echo "{\"timestamp\":$timestamp,\"mem_used\":$current_mem,\"swap_used\":$current_swap}" >> "$METRICS_FILE"
    
    # Keep only last 1000 entries for analysis
    tail -1000 "$METRICS_FILE" > "$METRICS_FILE.tmp" && mv "$METRICS_FILE.tmp" "$METRICS_FILE"
    
    # Predict future memory needs based on trends
    if [ "$PREDICTIVE_SCALING" = "true" ] && [ -f "$METRICS_FILE" ]; then
        local trend=$(tail -10 "$METRICS_FILE" | jq -r '.mem_used' 2>/dev/null | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}' || echo "0")
        echo "$trend"
    else
        echo "0"
    fi
}

# Intelligent Swap Size Calculation
calculate_optimal_swap() {
    local mem_total=$(free -m | awk '/^Mem:/ {print $2}')
    local mem_used=$(free -m | awk '/^Mem:/ {print $3}')
    local swap_used=$(free -m | awk '/^Swap:/ {print $3}')
    local swap_total=$(free -m | awk '/^Swap:/ {print $2}')
    local mem_usage_pct=$((mem_used * 100 / mem_total))
    
    # AI-based calculation: optimal swap = 1.5x to 2x RAM for heavy workloads
    local optimal_swap=$((mem_total * 2))
    
    # Adjust based on current usage patterns
    if [ "$mem_usage_pct" -gt 80 ]; then
        optimal_swap=$((mem_total * 3))  # Increase for high usage
    elif [ "$mem_usage_pct" -lt 40 ]; then
        optimal_swap=$((mem_total * 1))  # Reduce for low usage
    fi
    
    # Minimum 2GB, maximum 16GB
    if [ "$optimal_swap" -lt 2048 ]; then
        optimal_swap=2048
    elif [ "$optimal_swap" -gt 16384 ]; then
        optimal_swap=16384
    fi
    
    echo "$optimal_swap"
}

# Advanced Swap Creation with ZRAM support
create_advanced_swapfile() {
    local size=$1
    local use_zram="${2:-false}"
    
    log "Creating advanced swapfile (${size}MB, ZRAM: $use_zram)..."
    
    # Try ZRAM first for better performance (2025 feature)
    if [ "$use_zram" = "true" ] && modprobe zram 2>/dev/null; then
        local zram_dev=$(ls /sys/class/block/ | grep zram | head -1)
        if [ -n "$zram_dev" ]; then
            echo "$((size * 1024 * 1024))" > "/sys/block/$zram_dev/disksize" 2>/dev/null
            mkswap "/dev/$zram_dev" 2>/dev/null
            swapon "/dev/$zram_dev" 2>/dev/null && {
                log "✓ ZRAM swap created (${size}MB) - Better performance"
                return 0
            }
        fi
    fi
    
    # Fallback to traditional swapfile
    if [ -f "$SWAPFILE" ]; then
        swapoff "$SWAPFILE" 2>/dev/null || true
        rm -f "$SWAPFILE"
    fi
    
    # Use fallocate for faster creation (2025 optimization)
    if ! fallocate -l ${size}M "$SWAPFILE" 2>/dev/null; then
        dd if=/dev/zero of="$SWAPFILE" bs=1M count=$size status=progress 2>/dev/null
    fi
    
    chmod 600 "$SWAPFILE"
    mkswap "$SWAPFILE"
    swapon "$SWAPFILE"
    
    # Optimize swapiness (2025 tuning)
    echo 60 > /proc/sys/vm/swappiness  # Balanced approach
    
    # Add to fstab
    if ! grep -q "$SWAPFILE" /etc/fstab; then
        echo "$SWAPFILE none swap sw,pri=100 0 0" >> /etc/fstab
    fi
    
    log "✓ Advanced swapfile created and optimized (${size}MB)"
}

# Predictive Memory Management
predictive_memory_management() {
    local mem_total=$(free -m | awk '/^Mem:/ {print $2}')
    local mem_free=$(free -m | awk '/^Mem:/ {print $7}')
    local mem_used=$(free -m | awk '/^Mem:/ {print $3}')
    local swap_used=$(free -m | awk '/^Swap:/ {print $3}')
    local swap_total=$(free -m | awk '/^Swap:/ {print $2}')
    
    # Analyze patterns
    local trend=$(analyze_memory_patterns)
    
    # Predictive scaling: if trend shows increasing memory usage, pre-emptively increase swap
    if [ "$PREDICTIVE_SCALING" = "true" ] && [ -n "$trend" ] && [ "$trend" != "0" ]; then
        local predicted_need=$(echo "$trend * 1.2" | bc 2>/dev/null | cut -d. -f1 || echo "0")
        local current_swap_mb=$((swap_total))
        
        if [ "$predicted_need" -gt "$current_swap_mb" ]; then
            local increase_needed=$((predicted_need - current_swap_mb))
            if [ "$increase_needed" -gt 512 ]; then  # Only if significant increase needed
                log "Predictive scaling: Increasing swap by ${increase_needed}MB (trend: ${trend}MB)"
                create_advanced_swapfile "$predicted_need" "false"
            fi
        fi
    fi
    
    # Adaptive response to current conditions
    if [ "$ADAPTIVE_MODE" = "true" ]; then
        local mem_pct=$((mem_used * 100 / mem_total))
        local swap_pct=$((swap_used * 100 / swap_total)) if [ "$swap_total" -gt 0 ]; then 0; fi
        
        # If memory usage is high and swap is filling up, increase swap
        if [ "$mem_pct" -gt 75 ] && [ "$swap_pct" -gt 80 ]; then
            local optimal_size=$(calculate_optimal_swap)
            if [ "$optimal_size" -gt "$swap_total" ]; then
                log "Adaptive scaling: Increasing swap to ${optimal_size}MB (mem: ${mem_pct}%, swap: ${swap_pct}%)"
                create_advanced_swapfile "$optimal_size" "false"
            fi
        fi
        
        # If swap usage is low and memory is stable, optimize swap size
        if [ "$swap_pct" -lt 20 ] && [ "$mem_pct" -lt 60 ] && [ "$swap_total" -gt 4096 ]; then
            local reduced_size=$((mem_total * 1))
            if [ "$reduced_size" -lt "$swap_total" ]; then
                log "Optimization: Reducing swap to ${reduced_size}MB (low usage detected)"
                create_advanced_swapfile "$reduced_size" "false"
            fi
        fi
    fi
}

# Real-time Performance Monitoring
monitor_performance() {
    while true; do
        local mem_total=$(free -m | awk '/^Mem:/ {print $2}')
        local mem_free=$(free -m | awk '/^Mem:/ {print $7}')
        local mem_used=$(free -m | awk '/^Mem:/ {print $3}')
        local swap_used=$(free -m | awk '/^Swap:/ {print $3}')
        local swap_total=$(free -m | awk '/^Swap:/ {print $2}')
        local mem_pct=$((mem_used * 100 / mem_total))
        local swap_pct=$((swap_used * 100 / swap_total)) if [ "$swap_total" -gt 0 ]; then 0; fi
        
        # Critical alerts
        if [ "$mem_pct" -gt 95 ]; then
            log "⚠ CRITICAL: Memory usage at ${mem_pct}%"
            /usr/local/bin/speaker-notifications.sh notify "Critical memory usage" "error" 2>/dev/null || true
        fi
        
        if [ "$swap_pct" -gt 90 ]; then
            log "⚠ CRITICAL: Swap usage at ${swap_pct}%"
            /usr/local/bin/speaker-notifications.sh notify "Critical swap usage" "error" 2>/dev/null || true
        fi
        
        # Predictive management
        predictive_memory_management
        
        # Log metrics every minute
        if [ $(($(date +%s) % 60)) -eq 0 ]; then
            log "Metrics: Mem ${mem_pct}% (${mem_free}MB free), Swap ${swap_pct}% (${swap_used}MB/${swap_total}MB)"
        fi
        
        sleep "$MONITOR_INTERVAL"
    done
}

# Initialize advanced swapfile
init_swapfile() {
    if [ ! -f "$SWAPFILE" ] || ! swapon --show | grep -q "$SWAPFILE"; then
        local mem_total=$(free -m | awk '/^Mem:/ {print $2}')
        local initial_size=$(calculate_optimal_swap)
        create_advanced_swapfile "$initial_size" "true"  # Try ZRAM first
    fi
}

case "${1:-start}" in
    start)
        init_swapfile
        monitor_performance &
        echo $! > /var/run/swapfile-manager-2025.pid
        log "Advanced Swapfile Manager 2025 started (PID: $(cat /var/run/swapfile-manager-2025.pid))"
        log "Features: AI-powered, Predictive scaling, ZRAM support, Adaptive optimization"
        ;;
    stop)
        if [ -f /var/run/swapfile-manager-2025.pid ]; then
            kill $(cat /var/run/swapfile-manager-2025.pid) 2>/dev/null || true
            rm -f /var/run/swapfile-manager-2025.pid
            log "Advanced Swapfile Manager stopped"
        fi
        ;;
    status)
        local mem_total=$(free -m | awk '/^Mem:/ {print $2}')
        local mem_used=$(free -m | awk '/^Mem:/ {print $3}')
        local swap_used=$(free -m | awk '/^Swap:/ {print $3}')
        local swap_total=$(free -m | awk '/^Swap:/ {print $2}')
        echo "Advanced Swapfile Manager 2025 Status:"
        echo "  Memory: ${mem_used}MB / ${mem_total}MB ($((mem_used * 100 / mem_total))%)"
        echo "  Swap: ${swap_used}MB / ${swap_total}MB ($((swap_used * 100 / swap_total))%)"
        echo "  Predictive Scaling: $PREDICTIVE_SCALING"
        echo "  Adaptive Mode: $ADAPTIVE_MODE"
        if [ -f /var/run/swapfile-manager-2025.pid ]; then
            echo "  Service: Running (PID: $(cat /var/run/swapfile-manager-2025.pid))"
        else
            echo "  Service: Stopped"
        fi
        ;;
    optimize)
        local optimal=$(calculate_optimal_swap)
        log "Optimizing swap to ${optimal}MB..."
        create_advanced_swapfile "$optimal" "true"
        ;;
    *)
        echo "Usage: $0 {start|stop|status|optimize}"
        exit 1
        ;;
esac

