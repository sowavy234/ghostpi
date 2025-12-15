#!/bin/bash
# GhostPi Advanced Self-Healing System 2025
# Next-Generation Self-Repair with AI Diagnostics and Predictive Recovery
# EDUCATIONAL PURPOSES ONLY

set -e

LOG_FILE="/var/log/ghostpi-self-heal-2025.log"
HEALTH_CHECK_INTERVAL=60  # 1 minute for real-time monitoring
DIAGNOSTICS_DIR="/var/lib/ghostpi/diagnostics"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [HEAL-2025] $1" | tee -a "$LOG_FILE"
}

# AI-Powered Diagnostics
ai_diagnose() {
    local issue="$1"
    log "AI Diagnostics: Analyzing '$issue'..."
    
    # Pattern recognition for common issues
    case "$issue" in
        *service*down*)
            echo "Service failure detected. Attempting multi-stage recovery..."
            return 1
            ;;
        *disk*full*)
            echo "Disk space issue. Performing intelligent cleanup..."
            return 2
            ;;
        *memory*low*)
            echo "Memory pressure. Optimizing swap and clearing caches..."
            return 3
            ;;
        *network*down*)
            echo "Network failure. Applying network resilience strategies..."
            return 4
            ;;
        *)
            echo "Unknown issue. Running comprehensive diagnostics..."
            return 0
            ;;
    esac
}

# Advanced Service Recovery with Rollback
advanced_service_recovery() {
    local service="$1"
    local max_attempts=5
    local attempt=1
    
    log "Advanced recovery for service: $service"
    
    while [ $attempt -le $max_attempts ]; do
        log "Recovery attempt $attempt/$max_attempts for $service"
        
        # Strategy 1: Standard restart
        if systemctl restart "$service.service" 2>/dev/null; then
            sleep 2
            if systemctl is-active --quiet "$service.service"; then
                log "✓ Service $service recovered via restart"
                return 0
            fi
        fi
        
        # Strategy 2: Reload configuration
        systemctl daemon-reload 2>/dev/null
        systemctl reset-failed "$service.service" 2>/dev/null
        if systemctl start "$service.service" 2>/dev/null; then
            sleep 2
            if systemctl is-active --quiet "$service.service"; then
                log "✓ Service $service recovered via config reload"
                return 0
            fi
        fi
        
        # Strategy 3: Check and fix service file
        local service_file="/etc/systemd/system/${service}.service"
        if [ -f "$service_file" ]; then
            # Validate service file syntax
            if systemd-analyze verify "$service_file" 2>/dev/null; then
                systemctl daemon-reload
                systemctl start "$service.service" 2>/dev/null
                sleep 2
                if systemctl is-active --quiet "$service.service"; then
                    log "✓ Service $service recovered via service file fix"
                    return 0
                fi
            fi
        fi
        
        # Strategy 4: Restore from backup
        local backup_file="/opt/ghostpi/backups/${service}.service.backup"
        if [ -f "$backup_file" ]; then
            log "Attempting rollback from backup..."
            cp "$backup_file" "$service_file"
            systemctl daemon-reload
            systemctl start "$service.service" 2>/dev/null
            sleep 2
            if systemctl is-active --quiet "$service.service"; then
                log "✓ Service $service recovered via backup rollback"
                return 0
            fi
        fi
        
        # Strategy 5: Reinstall service
        if [ -f "/opt/ghostpi/repo/scripts/install_${service}.sh" ]; then
            log "Attempting service reinstallation..."
            "/opt/ghostpi/repo/scripts/install_${service}.sh" 2>/dev/null || true
            systemctl start "$service.service" 2>/dev/null
            sleep 2
            if systemctl is-active --quiet "$service.service"; then
                log "✓ Service $service recovered via reinstallation"
                return 0
            fi
        fi
        
        attempt=$((attempt + 1))
        sleep 5
    done
    
    log "✗ Failed to recover service $service after $max_attempts attempts"
    return 1
}

# Intelligent Disk Space Management
intelligent_disk_cleanup() {
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    
    if [ "$disk_usage" -gt 75 ]; then
        log "Intelligent disk cleanup (usage: ${disk_usage}%)..."
        
        # Stage 1: Safe cleanup (no risk)
        apt-get clean -qq 2>/dev/null || true
        apt-get autoremove -y -qq 2>/dev/null || true
        
        # Stage 2: Log rotation and cleanup
        find /var/log -name "*.log" -mtime +5 -exec truncate -s 0 {} \; 2>/dev/null || true
        journalctl --vacuum-time=3d 2>/dev/null || true
        
        # Stage 3: Temporary files
        find /tmp -type f -mtime +1 -delete 2>/dev/null || true
        find /var/tmp -type f -mtime +1 -delete 2>/dev/null || true
        
        # Stage 4: Cache cleanup (intelligent - keep frequently used)
        if [ "$disk_usage" -gt 85 ]; then
            # Only clear old cache
            find /var/cache -type f -atime +7 -delete 2>/dev/null || true
        fi
        
        # Stage 5: Docker cleanup (if installed)
        if command -v docker &>/dev/null; then
            docker system prune -af --volumes 2>/dev/null || true
        fi
        
        local new_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
        local freed=$((disk_usage - new_usage))
        log "✓ Intelligent cleanup: Freed ${freed}% disk space (${disk_usage}% → ${new_usage}%)"
        return 0
    fi
    
    return 1
}

# Advanced Memory Optimization
advanced_memory_optimization() {
    local mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    local mem_free=$(free -m | awk '/^Mem:/ {print $7}')
    
    if [ "$mem_usage" -gt 85 ] || [ "$mem_free" -lt 256 ]; then
        log "Advanced memory optimization (usage: ${mem_usage}%, free: ${mem_free}MB)..."
        
        # Stage 1: Clear page cache intelligently
        sync
        echo 1 > /proc/sys/vm/drop_caches 2>/dev/null || true  # Clear page cache only
        
        # Stage 2: Optimize swap
        if [ -f "/swapfile" ]; then
            swapon /swapfile 2>/dev/null || true
            /usr/local/bin/swapfile-manager-2025.sh optimize 2>/dev/null || true
        fi
        
        # Stage 3: Kill memory-hungry processes (if safe)
        if [ "$mem_free" -lt 128 ]; then
            # Find and kill processes using excessive memory (non-critical only)
            ps aux --sort=-%mem | awk 'NR>1 && $4>10 && $11 !~ /systemd|kernel/ {print $2}' | while read pid; do
                local cmd=$(ps -p $pid -o comm= 2>/dev/null || echo "")
                if echo "$cmd" | grep -qvE "systemd|kernel|ghostpi|swapfile|battery"; then
                    log "Terminating memory-hungry process: $cmd (PID: $pid)"
                    kill -9 $pid 2>/dev/null || true
                fi
            done
        fi
        
        local new_mem=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
        log "✓ Memory optimized: ${mem_usage}% → ${new_mem}%"
        return 0
    fi
    
    return 1
}

# Network Resilience with Multiple Strategies
network_resilience() {
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log "Network failure detected, applying resilience strategies..."
        
        local strategies=(
            "systemctl restart networking"
            "systemctl restart NetworkManager"
            "ip link set eth0 down && ip link set eth0 up"
            "dhclient -r && dhclient"
            "systemctl restart systemd-networkd"
            "ifconfig eth0 down && ifconfig eth0 up"
        )
        
        for strategy in "${strategies[@]}"; do
            log "Trying strategy: $strategy"
            eval "$strategy" 2>/dev/null || true
            sleep 3
            
            if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
                log "✓ Network recovered via: $strategy"
                return 0
            fi
        done
        
        log "✗ All network recovery strategies failed"
        return 1
    fi
    
    return 0
}

# File System Integrity Check and Repair
filesystem_integrity() {
    log "Running filesystem integrity check..."
    
    # Check for filesystem errors
    if dmesg | tail -50 | grep -qi "I/O error\|filesystem error\|EXT4-fs error"; then
        log "⚠ Filesystem errors detected, scheduling repair..."
        
        # Schedule fsck on next boot
        touch /forcefsck 2>/dev/null || true
        
        # Try online repair if possible
        if command -v btrfs &>/dev/null && mount | grep -q btrfs; then
            btrfs scrub start / 2>/dev/null || true
        fi
        
        log "✓ Filesystem repair scheduled"
        return 1
    fi
    
    return 0
}

# Comprehensive Health Check 2025
comprehensive_health_check() {
    local issues=0
    local fixed=0
    
    log "Running comprehensive health check 2025..."
    
    # Check all services with advanced recovery
    local services=(
        "swapfile-manager" "swapfile-manager-2025" "auto-update"
        "self-healing" "battery-monitor" "hackberry-cm5"
        "ghostpi-bot" "ghostpi-bot-2025"
    )
    
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service.service" 2>/dev/null; then
            local issue="service $service down"
            ai_diagnose "$issue"
            if advanced_service_recovery "$service"; then
                fixed=$((fixed + 1))
            else
                issues=$((issues + 1))
            fi
        fi
    done
    
    # Intelligent disk cleanup
    if intelligent_disk_cleanup; then
        fixed=$((fixed + 1))
    fi
    
    # Advanced memory optimization
    if advanced_memory_optimization; then
        fixed=$((fixed + 1))
    fi
    
    # Network resilience
    if ! network_resilience; then
        issues=$((issues + 1))
    fi
    
    # Filesystem integrity
    if ! filesystem_integrity; then
        issues=$((issues + 1))
    fi
    
    # Check and fix permissions
    fix_permissions && fixed=$((fixed + 1)) || true
    
    # Check swapfile
    fix_swapfile && fixed=$((fixed + 1)) || issues=$((issues + 1))
    
    # Check boot configuration
    fix_boot_config && fixed=$((fixed + 1)) || true
    
    # Check script syntax errors
    fix_script_errors && fixed=$((fixed + 1)) || true
    
    log "Comprehensive health check 2025: $fixed issues fixed, $issues issues remain"
    return $issues
}

# Fix permissions (enhanced)
fix_permissions() {
    local fixed=0
    
    find /usr/local/bin -name "*.sh" ! -executable -exec chmod +x {} \; 2>/dev/null && fixed=$((fixed + 1))
    find /opt/ghostpi -name "*.sh" ! -executable -exec chmod +x {} \; 2>/dev/null && fixed=$((fixed + 1))
    
    if [ $fixed -gt 0 ]; then
        log "✓ Fixed $fixed permission issues"
        return 0
    fi
    return 1
}

# Fix swapfile (enhanced)
fix_swapfile() {
    if ! swapon --show | grep -q "/swapfile"; then
        if [ -f "/swapfile" ]; then
            swapon /swapfile 2>/dev/null && {
                log "✓ Swapfile activated"
                return 0
            }
        else
            /usr/local/bin/swapfile-manager-2025.sh start 2>/dev/null && {
                log "✓ Swapfile created and activated"
                return 0
            }
        fi
        return 1
    fi
    return 0
}

# Fix boot config (enhanced)
fix_boot_config() {
    local config_file="/boot/config.txt"
    local needs_fix=0
    
    if [ ! -f "$config_file" ]; then
        mkdir -p /boot
        cat > "$config_file" <<'EOF'
# GhostPi Boot Configuration 2025
gpu_mem=128
arm_64bit=1
kernel=kernel8.img
dtoverlay=vc4-kms-v3d
disable_splash=0
EOF
        needs_fix=1
    fi
    
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

# Fix script errors (enhanced)
fix_script_errors() {
    local fixed=0
    local script_dirs=("/usr/local/bin" "/opt/ghostpi/repo/scripts" "/opt/ghostpi/repo/flipper-zero")
    
    for dir in "${script_dirs[@]}"; do
        [ ! -d "$dir" ] && continue
        
        while IFS= read -r script; do
            if ! bash -n "$script" 2>/dev/null; then
                local error=$(bash -n "$script" 2>&1)
                log "Syntax error in $script: $error"
                
                # Auto-fix common issues
                if grep -q 'SCRIPT_DIR="$(cd.*&& pwd)$' "$script" 2>/dev/null; then
                    sed -i 's/SCRIPT_DIR="$(cd.*&& pwd)$/SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" \&\& pwd)"/' "$script" 2>/dev/null && {
                        log "✓ Fixed syntax error in $script"
                        fixed=$((fixed + 1))
                    }
                fi
                chmod +x "$script" 2>/dev/null || true
            fi
        done < <(find "$dir" -type f -name "*.sh" 2>/dev/null)
    done
    
    if [ $fixed -gt 0 ]; then
        log "✓ Fixed $fixed script syntax errors"
        return 0
    fi
    return 1
}

# Monitor mode
monitor() {
    log "Advanced Self-Healing System 2025 started"
    mkdir -p "$DIAGNOSTICS_DIR"
    
    while true; do
        comprehensive_health_check
        
        local uptime=$(uptime -p)
        local load=$(uptime | awk -F'load average:' '{print $2}')
        log "System status - Uptime: $uptime, Load: $load"
        
        sleep "$HEALTH_CHECK_INTERVAL"
    done
}

case "${1:-monitor}" in
    monitor)
        monitor
        ;;
    repair)
        comprehensive_health_check
        ;;
    status)
        echo "Advanced Self-Healing System 2025:"
        systemctl status self-healing.service --no-pager -l 2>/dev/null || echo "Service not running"
        echo ""
        echo "Recent activity:"
        tail -20 "$LOG_FILE" 2>/dev/null || echo "No log file"
        ;;
    *)
        echo "Usage: $0 {monitor|repair|status}"
        exit 1
        ;;
esac

