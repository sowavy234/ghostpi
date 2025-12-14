#!/bin/bash
# GhostPi Self-Healing System
# Automatically detects and fixes common issues

set -e

LOG_FILE="/var/log/ghostpi-self-heal.log"
HEALTH_CHECK_INTERVAL=300  # 5 minutes
MAX_RETRIES=3

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Check and fix service issues
fix_services() {
    local services=("swapfile-manager" "auto-update" "self-healing")
    local fixed=0
    
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service.service" 2>/dev/null; then
            log "Service $service is down, attempting to restart..."
            systemctl restart "$service.service" 2>/dev/null && {
                log "✓ Service $service restarted successfully"
                fixed=$((fixed + 1))
            } || {
                log "✗ Failed to restart $service"
            }
        fi
    done
    
    return $fixed
}

# Check and fix disk space
fix_disk_space() {
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$disk_usage" -gt 90 ]; then
        log "Disk usage critical (${disk_usage}%), cleaning up..."
        
        # Clean package cache
        apt-get clean -qq 2>/dev/null || true
        
        # Remove old logs
        find /var/log -name "*.log" -mtime +7 -delete 2>/dev/null || true
        find /var/log -name "*.gz" -delete 2>/dev/null || true
        
        # Clean tmp files
        find /tmp -type f -mtime +1 -delete 2>/dev/null || true
        
        local new_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
        log "Disk usage reduced to ${new_usage}%"
        return 0
    fi
    
    return 1
}

# Check and fix network connectivity
fix_network() {
    if ! ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        log "Network connectivity issue detected..."
        
        # Restart network service
        systemctl restart networking 2>/dev/null || true
        systemctl restart NetworkManager 2>/dev/null || true
        
        sleep 5
        
        if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
            log "✓ Network connectivity restored"
            return 0
        else
            log "✗ Network issue persists"
            return 1
        fi
    fi
    
    return 0
}

# Check and fix file permissions
fix_permissions() {
    local fixed=0
    
    # Fix GhostPi scripts
    if [ -d "/usr/local/bin" ]; then
        chmod +x /usr/local/bin/ghostpi-* 2>/dev/null && fixed=$((fixed + 1))
    fi
    
    # Fix boot splash theme
    if [ -d "/usr/share/plymouth/themes/wavys-world" ]; then
        chmod -R 755 /usr/share/plymouth/themes/wavys-world 2>/dev/null && fixed=$((fixed + 1))
    fi
    
    if [ $fixed -gt 0 ]; then
        log "✓ Fixed $fixed permission issues"
        return 0
    fi
    
    return 1
}

# Check and fix swapfile
fix_swapfile() {
    if ! swapon --show | grep -q "/swapfile"; then
        log "Swapfile not active, attempting to fix..."
        
        if [ -f "/swapfile" ]; then
            swapon /swapfile 2>/dev/null && {
                log "✓ Swapfile activated"
                return 0
            }
        else
            # Create swapfile if missing
            /usr/local/bin/swapfile-manager.sh start 2>/dev/null && {
                log "✓ Swapfile created and activated"
                return 0
            }
        fi
        
        log "✗ Failed to fix swapfile"
        return 1
    fi
    
    return 0
}

# Check and fix boot configuration
fix_boot_config() {
    local config_file="/boot/config.txt"
    local needs_fix=0
    
    if [ ! -f "$config_file" ]; then
        log "Boot config missing, creating default..."
        mkdir -p /boot
        cat > "$config_file" <<'EOF'
# GhostPi Boot Configuration
gpu_mem=128
arm_64bit=1
kernel=kernel8.img
dtoverlay=vc4-kms-v3d
disable_splash=0
EOF
        needs_fix=1
    fi
    
    # Check for critical settings
    if ! grep -q "disable_splash=0" "$config_file" 2>/dev/null; then
        echo "disable_splash=0" >> "$config_file"
        needs_fix=1
    fi
    
    if [ $needs_fix -gt 0 ]; then
        log "✓ Boot configuration fixed"
        return 0
    fi
    
    return 1
}

# Comprehensive health check
health_check() {
    local issues=0
    local fixed=0
    
    log "Running comprehensive health check..."
    
    # Check services
    fix_services && fixed=$((fixed + 1)) || issues=$((issues + 1))
    
    # Check disk space
    fix_disk_space && fixed=$((fixed + 1)) || true
    
    # Check network
    fix_network || issues=$((issues + 1))
    
    # Check permissions
    fix_permissions && fixed=$((fixed + 1)) || true
    
    # Check swapfile
    fix_swapfile && fixed=$((fixed + 1)) || issues=$((issues + 1))
    
    # Check boot config
    fix_boot_config && fixed=$((fixed + 1)) || true
    
    log "Health check complete: $fixed issues fixed, $issues issues remain"
    
    return $issues
}

# Monitor mode - runs continuously
monitor() {
    log "Self-healing monitor started"
    
    while true; do
        health_check
        
        # Log system status
        local uptime=$(uptime -p)
        local load=$(uptime | awk -F'load average:' '{print $2}')
        log "System status - Uptime: $uptime, Load: $load"
        
        sleep "$HEALTH_CHECK_INTERVAL"
    done
}

# Single repair run
repair() {
    log "Starting repair run..."
    health_check
    log "Repair run completed"
}

case "${1:-monitor}" in
    monitor)
        monitor
        ;;
    repair)
        repair
        ;;
    status)
        echo "Self-healing service status:"
        systemctl status self-healing.service --no-pager -l
        echo ""
        echo "Recent activity:"
        tail -20 "$LOG_FILE" 2>/dev/null || echo "No log file"
        ;;
    *)
        echo "Usage: $0 {monitor|repair|status}"
        exit 1
        ;;
esac

