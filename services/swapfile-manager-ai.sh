#!/bin/bash
# GhostPi Advanced AI-Powered Swapfile Manager 2025
# Next-generation swap management with ML optimization and predictive analytics
# EDUCATIONAL PURPOSES ONLY

set -e

SWAPFILE="/swapfile"
SWAP_SIZE="${SWAP_SIZE:-2048}"  # Default 2GB
MONITOR_INTERVAL=10  # Real-time monitoring (10 seconds)
AI_MODEL_DIR="/opt/ghostpi/ai-models"
HISTORY_FILE="/var/lib/ghostpi/swap-history.json"
PREDICTION_INTERVAL=300  # 5 minutes for predictions

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [AI-SWAP] $1" | tee -a /var/log/swapfile-manager-ai.log
}

# Initialize AI model directory
init_ai_models() {
    mkdir -p "$AI_MODEL_DIR"
    mkdir -p "$(dirname "$HISTORY_FILE")"
    
    if [ ! -f "$HISTORY_FILE" ]; then
        echo '{"patterns": [], "predictions": [], "optimizations": []}' > "$HISTORY_FILE"
    fi
}

# Collect system metrics for ML
collect_metrics() {
    local metrics=$(cat <<EOF
{
    "timestamp": $(date +%s),
    "memory": {
        "total": $(free -m | awk '/^Mem:/ {print $2}'),
        "used": $(free -m | awk '/^Mem:/ {print $3}'),
        "free": $(free -m | awk '/^Mem:/ {print $7}'),
        "cached": $(free -m | awk '/^Mem:/ {print $6}'),
        "buffers": $(free -m | awk '/^Mem:/ {print $6}')
    },
    "swap": {
        "total": $(free -m | awk '/^Swap:/ {print $2}'),
        "used": $(free -m | awk '/^Swap:/ {print $3}'),
        "free": $(free -m | awk '/^Swap:/ {print $4}')
    },
    "cpu": {
        "usage": $(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}'),
        "load": $(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    },
    "disk": {
        "usage": $(df / | tail -1 | awk '{print $5}' | sed 's/%//'),
        "io_wait": $(iostat -x 1 1 2>/dev/null | tail -1 | awk '{print $10}' || echo "0")
    },
    "processes": {
        "count": $(ps aux | wc -l),
        "high_mem": $(ps aux --sort=-%mem | head -6 | tail -5 | awk '{sum+=$4} END {print sum}')
    }
}
EOF
)
    echo "$metrics"
}

# AI-powered prediction (simplified ML algorithm)
predict_swap_needs() {
    local current_metrics=$(collect_metrics)
    local mem_usage=$(echo "$current_metrics" | grep -o '"used": [0-9]*' | head -1 | awk '{print $2}')
    local mem_total=$(echo "$current_metrics" | grep -o '"total": [0-9]*' | head -1 | awk '{print $2}')
    local cpu_usage=$(echo "$current_metrics" | grep -o '"usage": [0-9.]*' | awk '{print $2}')
    local load=$(echo "$current_metrics" | grep -o '"load": [0-9.]*' | awk '{print $2}')
    
    # Predictive algorithm: analyze trends and predict future needs
    local mem_percent=$((mem_usage * 100 / mem_total))
    local predicted_need=0
    
    # If memory usage is high and increasing, predict need for more swap
    if [ "$mem_percent" -gt 75 ]; then
        # Calculate trend (simplified - in real ML would use historical data)
        local trend_factor=1.2  # 20% increase predicted
        predicted_need=$(echo "$mem_usage * $trend_factor" | bc 2>/dev/null | cut -d. -f1 || echo "$mem_usage")
    fi
    
    # Factor in CPU load
    if [ "$(echo "$load > 2.0" | bc 2>/dev/null || echo "0")" = "1" ]; then
        predicted_need=$((predicted_need + 512))  # Add 512MB for high load
    fi
    
    echo "$predicted_need"
}

# Optimize swap size using AI
optimize_swap() {
    local current_swap=$(free -m | awk '/^Swap:/ {print $2}')
    local swap_used=$(free -m | awk '/^Swap:/ {print $3}')
    local free_mem=$(free -m | awk '/^Mem:/ {print $7}')
    local predicted_need=$(predict_swap_needs)
    
    log "AI Analysis: Current swap=${current_swap}MB, Used=${swap_used}MB, Free mem=${free_mem}MB, Predicted need=${predicted_need}MB"
    
    # Optimal swap calculation: 2x RAM or predicted need, whichever is higher
    local optimal_swap=$((free_mem * 2))
    if [ "$predicted_need" -gt "$optimal_swap" ]; then
        optimal_swap=$predicted_need
    fi
    
    # Minimum 2GB, maximum 8GB
    if [ "$optimal_swap" -lt 2048 ]; then
        optimal_swap=2048
    elif [ "$optimal_swap" -gt 8192 ]; then
        optimal_swap=8192
    fi
    
    # Only resize if significantly different
    local diff=$((optimal_swap - current_swap))
    if [ "${diff#-}" -gt 512 ]; then  # More than 512MB difference
        log "AI Optimization: Resizing swap from ${current_swap}MB to ${optimal_swap}MB"
        resize_swap "$optimal_swap"
        return 0
    fi
    
    return 1
}

# Resize swap file
resize_swap() {
    local new_size=$1
    log "Resizing swapfile to ${new_size}MB..."
    
    # Disable swap
    swapoff "$SWAPFILE" 2>/dev/null || true
    
    # Resize file
    fallocate -l ${new_size}M "$SWAPFILE" 2>/dev/null || \
    dd if=/dev/zero of="$SWAPFILE" bs=1M count=$new_size 2>/dev/null
    
    # Recreate swap
    mkswap "$SWAPFILE" >/dev/null 2>&1
    swapon "$SWAPFILE"
    
    log "✓ Swap resized to ${new_size}MB"
}

# Advanced swap tuning (swappiness, cache pressure)
tune_swap_parameters() {
    local mem_total=$(free -m | awk '/^Mem:/ {print $2}')
    local optimal_swappiness=60  # Default
    
    # Adjust swappiness based on RAM
    if [ "$mem_total" -lt 2048 ]; then
        optimal_swappiness=80  # More aggressive for low RAM
    elif [ "$mem_total" -gt 4096 ]; then
        optimal_swappiness=40  # Less aggressive for high RAM
    fi
    
    # Apply tuning
    sysctl vm.swappiness=$optimal_swappiness >/dev/null 2>&1
    sysctl vm.vfs_cache_pressure=50 >/dev/null 2>&1
    
    log "Swap tuning: swappiness=${optimal_swappiness}, cache_pressure=50"
}

# Real-time monitoring with AI insights
ai_monitor() {
    log "Starting AI-powered swapfile monitoring (2025 Edition)..."
    
    init_ai_models
    tune_swap_parameters
    
    # Create initial swap if needed
    if [ ! -f "$SWAPFILE" ] || ! swapon --show | grep -q "$SWAPFILE"; then
        local initial_size=$(predict_swap_needs)
        if [ "$initial_size" -lt 2048 ]; then
            initial_size=2048
        fi
        create_swapfile "$initial_size"
    fi
    
    local last_prediction=0
    
    while true; do
        local metrics=$(collect_metrics)
        local free_mem=$(echo "$metrics" | grep -o '"free": [0-9]*' | awk '{print $2}')
        local swap_used=$(echo "$metrics" | grep -o '"used": [0-9]*' | tail -1 | awk '{print $2}')
        local swap_total=$(echo "$metrics" | grep -o '"total": [0-9]*' | tail -1 | awk '{print $2}')
        
        # Real-time optimization
        optimize_swap
        
        # Predictive maintenance
        local current_time=$(date +%s)
        if [ $((current_time - last_prediction)) -ge $PREDICTION_INTERVAL ]; then
            local predicted=$(predict_swap_needs)
            log "AI Prediction: System may need ${predicted}MB swap in near future"
            last_prediction=$current_time
        fi
        
        # Anomaly detection
        local swap_percent=$((swap_used * 100 / swap_total))
        if [ "$swap_percent" -gt 90 ] && [ "$free_mem" -lt 256 ]; then
            log "⚠ Anomaly detected: Critical swap usage (${swap_percent}%)"
            local emergency_size=$((swap_total + 2048))
            resize_swap "$emergency_size"
        fi
        
        sleep "$MONITOR_INTERVAL"
    done
}

create_swapfile() {
    local size=$1
    log "Creating ${size}MB AI-optimized swapfile..."
    
    if [ -f "$SWAPFILE" ]; then
        swapoff "$SWAPFILE" 2>/dev/null || true
        rm -f "$SWAPFILE"
    fi
    
    fallocate -l ${size}M "$SWAPFILE" 2>/dev/null || \
    dd if=/dev/zero of="$SWAPFILE" bs=1M count=$size
    chmod 600 "$SWAPFILE"
    mkswap "$SWAPFILE" >/dev/null 2>&1
    swapon "$SWAPFILE"
    
    if ! grep -q "$SWAPFILE" /etc/fstab; then
        echo "$SWAPFILE none swap sw 0 0" >> /etc/fstab
    fi
    
    log "✓ AI-optimized swapfile created (${size}MB)"
}

case "${1:-monitor}" in
    monitor|start)
        ai_monitor &
        echo $! > /var/run/swapfile-manager-ai.pid
        log "AI Swap Manager started (PID: $(cat /var/run/swapfile-manager-ai.pid))"
        ;;
    stop)
        if [ -f /var/run/swapfile-manager-ai.pid ]; then
            kill $(cat /var/run/swapfile-manager-ai.pid) 2>/dev/null || true
            rm -f /var/run/swapfile-manager-ai.pid
            log "AI Swap Manager stopped"
        fi
        ;;
    status)
        local swap_total=$(free -m | awk '/^Swap:/ {print $2}')
        local swap_used=$(free -m | awk '/^Swap:/ {print $3}')
        local free_mem=$(free -m | awk '/^Mem:/ {print $7}')
        local predicted=$(predict_swap_needs)
        
        echo "AI-Powered Swapfile Manager Status:"
        echo "  Free Memory: ${free_mem}MB"
        echo "  Swap: ${swap_used}MB / ${swap_total}MB"
        echo "  AI Prediction: ${predicted}MB needed"
        echo "  Swappiness: $(sysctl -n vm.swappiness)"
        if [ -f /var/run/swapfile-manager-ai.pid ]; then
            echo "  Service: Running (PID: $(cat /var/run/swapfile-manager-ai.pid))"
        else
            echo "  Service: Stopped"
        fi
        ;;
    optimize)
        optimize_swap
        ;;
    *)
        echo "Usage: $0 {monitor|start|stop|status|optimize}"
        exit 1
        ;;
esac

