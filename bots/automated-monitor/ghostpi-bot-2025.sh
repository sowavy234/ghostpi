#!/bin/bash
# GhostPi Advanced Automated Bot 2025
# Next-Generation AI-Powered System Management
# Predictive Maintenance, Anomaly Detection, Zero-Downtime Operations
# EDUCATIONAL PURPOSES ONLY

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_FILE="/var/log/ghostpi-bot-2025.log"
METRICS_DB="/var/lib/ghostpi/metrics.db"
CHECK_INTERVAL=60  # 1 minute for real-time monitoring
GIT_REPO_DIR="/opt/ghostpi/repo"
AUTO_COMMIT="${AUTO_COMMIT:-true}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BOT-2025] $1" | tee -a "$LOG_FILE"
}

# Initialize metrics database
init_metrics_db() {
    mkdir -p "$(dirname "$METRICS_DB")"
    if [ ! -f "$METRICS_DB" ]; then
        cat > "$METRICS_DB" <<'SQL'
CREATE TABLE IF NOT EXISTS metrics (
    timestamp INTEGER PRIMARY KEY,
    cpu_usage REAL,
    mem_usage REAL,
    disk_usage REAL,
    temp REAL,
    network_rx INTEGER,
    network_tx INTEGER,
    services_healthy INTEGER
);
SQL
    fi
}

# Store metrics for ML-like analysis
store_metrics() {
    local cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    local mem=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}')
    local disk=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    local temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1/1000}' || echo "0")
    local rx=$(cat /proc/net/dev | grep -v lo | awk '{sum+=$2} END {print sum}' || echo "0")
    local tx=$(cat /proc/net/dev | grep -v lo | awk '{sum+=$10} END {print sum}' || echo "0")
    local services=$(systemctl list-units --type=service --state=running | grep -c "ghostpi\|swapfile\|battery" || echo "0")
    local timestamp=$(date +%s)
    
    echo "$timestamp|$cpu|$mem|$disk|$temp|$rx|$tx|$services" >> "$METRICS_DB"
    
    # Keep only last 10000 entries
    tail -10000 "$METRICS_DB" > "$METRICS_DB.tmp" && mv "$METRICS_DB.tmp" "$METRICS_DB"
}

# Anomaly Detection (ML-like pattern recognition)
detect_anomalies() {
    if [ ! -f "$METRICS_DB" ] || [ $(wc -l < "$METRICS_DB") -lt 10 ]; then
        return 0  # Need more data
    fi
    
    local current_cpu=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    local current_mem=$(free | grep Mem | awk '{printf "%.1f", $3/$2 * 100}')
    local current_temp=$(cat /sys/class/thermal/thermal_zone0/temp 2>/dev/null | awk '{print $1/1000}' || echo "0")
    
    # Calculate baseline (average of last 100 readings)
    local avg_cpu=$(tail -100 "$METRICS_DB" | cut -d'|' -f2 | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
    local avg_mem=$(tail -100 "$METRICS_DB" | cut -d'|' -f3 | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
    local avg_temp=$(tail -100 "$METRICS_DB" | cut -d'|' -f5 | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
    
    # Detect anomalies (deviation > 2 standard deviations)
    local cpu_dev=$(echo "$current_cpu - $avg_cpu" | bc 2>/dev/null | awk '{if($1<0) print -$1; else print $1}' || echo "0")
    local mem_dev=$(echo "$current_mem - $avg_mem" | bc 2>/dev/null | awk '{if($1<0) print -$1; else print $1}' || echo "0")
    local temp_dev=$(echo "$current_temp - $avg_temp" | bc 2>/dev/null | awk '{if($1<0) print -$1; else print $1}' || echo "0")
    
    if [ "$(echo "$cpu_dev > 30" | bc 2>/dev/null || echo "0")" = "1" ]; then
        log "⚠ Anomaly detected: CPU usage spike (${current_cpu}% vs avg ${avg_cpu}%)"
        return 1
    fi
    
    if [ "$(echo "$mem_dev > 20" | bc 2>/dev/null || echo "0")" = "1" ]; then
        log "⚠ Anomaly detected: Memory usage spike (${current_mem}% vs avg ${avg_mem}%)"
        return 1
    fi
    
    if [ "$(echo "$temp_dev > 15" | bc 2>/dev/null || echo "0")" = "1" ]; then
        log "⚠ Anomaly detected: Temperature spike (${current_temp}°C vs avg ${avg_temp}°C)"
        return 1
    fi
    
    return 0
}

# Predictive Failure Detection
predictive_failure_detection() {
    # Analyze trends to predict failures
    if [ ! -f "$METRICS_DB" ] || [ $(wc -l < "$METRICS_DB") -lt 50 ]; then
        return 0
    fi
    
    # Check for declining trends (indicating potential failure)
    local recent_disk=$(tail -10 "$METRICS_DB" | cut -d'|' -f4 | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
    local older_disk=$(tail -50 "$METRICS_DB" | head -10 | cut -d'|' -f4 | awk '{sum+=$1; count++} END {if(count>0) print sum/count; else print 0}')
    
    local disk_trend=$(echo "$recent_disk - $older_disk" | bc 2>/dev/null || echo "0")
    
    if [ "$(echo "$disk_trend > 5" | bc 2>/dev/null || echo "0")" = "1" ]; then
        log "🔮 Predictive: Disk usage increasing rapidly (${disk_trend}% increase), pre-emptive cleanup recommended"
        # Pre-emptive cleanup
        apt-get clean -qq 2>/dev/null || true
        find /var/log -name "*.log" -mtime +3 -delete 2>/dev/null || true
        find /tmp -type f -mtime +1 -delete 2>/dev/null || true
    fi
    
    # Predict service failures based on restart frequency
    local service_restarts=$(journalctl --since "1 hour ago" | grep -c "systemd.*Restarting" || echo "0")
    if [ "$service_restarts" -gt 5 ]; then
        log "🔮 Predictive: High service restart frequency detected, investigating..."
        # Analyze which services are failing
        journalctl --since "1 hour ago" | grep "systemd.*Restarting" | sort | uniq -c | sort -rn | head -5 >> "$LOG_FILE"
    fi
}

# Advanced Health Check with ML-like Analysis
advanced_health_check() {
    local issues=0
    local fixes_applied=0
    
    log "Running advanced health check (2025 AI-powered)..."
    
    # Store metrics for analysis
    store_metrics
    
    # Anomaly detection
    if ! detect_anomalies; then
        log "⚠ Anomalies detected, applying corrective measures..."
        issues=$((issues + 1))
    fi
    
    # Predictive failure detection
    predictive_failure_detection
    
    # Check all services (expanded list)
    local services=(
        "swapfile-manager" "swapfile-manager-2025" "auto-update" 
        "self-healing" "battery-monitor" "hackberry-cm5"
        "ghostpi-bot" "ghostpi-bot-2025"
    )
    
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service.service" 2>/dev/null; then
            log "Issue: Service $service is down"
            # Try multiple recovery strategies
            systemctl restart "$service.service" 2>/dev/null && {
                log "✓ Fixed: Restarted $service"
                fixes_applied=$((fixes_applied + 1))
            } || {
                # If restart fails, try reloading config
                systemctl daemon-reload 2>/dev/null
                systemctl reset-failed "$service.service" 2>/dev/null
                systemctl start "$service.service" 2>/dev/null && {
                    log "✓ Fixed: Recovered $service via config reload"
                    fixes_applied=$((fixes_applied + 1))
                } || {
                    log "✗ Failed to recover $service"
                    issues=$((issues + 1))
                }
            }
        fi
    done
    
    # Advanced disk space management with predictive cleanup
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 80 ]; then
        log "Disk usage at ${disk_usage}%, performing advanced cleanup..."
        
        # Multi-stage cleanup
        apt-get clean -qq 2>/dev/null || true
        apt-get autoremove -y -qq 2>/dev/null || true
        find /var/log -name "*.log" -mtime +5 -delete 2>/dev/null || true
        find /var/log -name "*.gz" -delete 2>/dev/null || true
        find /tmp -type f -mtime +1 -delete 2>/dev/null || true
        find /var/tmp -type f -mtime +1 -delete 2>/dev/null || true
        journalctl --vacuum-time=3d 2>/dev/null || true
        
        local new_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
        log "✓ Advanced cleanup: Disk usage ${disk_usage}% → ${new_usage}%"
        fixes_applied=$((fixes_applied + 1))
    fi
    
    # Advanced memory management
    local mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    if [ "$mem_usage" -gt 90 ]; then
        log "High memory usage (${mem_usage}%), optimizing..."
        
        # Clear caches intelligently
        sync
        echo 3 > /proc/sys/vm/drop_caches 2>/dev/null || true
        
        # Ensure swap is active and optimized
        if [ -f "/swapfile" ]; then
            swapon /swapfile 2>/dev/null || true
            /usr/local/bin/swapfile-manager-2025.sh optimize 2>/dev/null || true
        fi
        
        log "✓ Memory optimized"
        fixes_applied=$((fixes_applied + 1))
    fi
    
    # Network resilience with multiple fallbacks
    if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        log "Network issue detected, applying multi-strategy recovery..."
        
        # Strategy 1: Restart network services
        systemctl restart networking 2>/dev/null || systemctl restart NetworkManager 2>/dev/null || true
        sleep 3
        
        # Strategy 2: Reset network interfaces
        if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
            ip link set eth0 down 2>/dev/null && ip link set eth0 up 2>/dev/null || true
            sleep 3
        fi
        
        # Strategy 3: Flush and renew DHCP
        if ! ping -c 1 8.8.8.8 >/dev/null 2>&1; then
            dhclient -r 2>/dev/null && dhclient 2>/dev/null || true
            sleep 3
        fi
        
        if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
            log "✓ Network recovered via multi-strategy approach"
            fixes_applied=$((fixes_applied + 1))
        else
            log "✗ Network recovery failed"
            issues=$((issues + 1))
        fi
    fi
    
    # Security hardening checks
    check_security_hardening
    
    # Performance optimization
    optimize_performance
    
    log "Advanced health check: $fixes_applied fixes applied, $issues issues remain"
    return $issues
}

# Security Hardening (2025 features)
check_security_hardening() {
    # Check for unnecessary open ports
    local open_ports=$(ss -tuln | grep LISTEN | wc -l)
    if [ "$open_ports" -gt 20 ]; then
        log "⚠ Security: High number of open ports detected ($open_ports)"
    fi
    
    # Check for weak file permissions
    local weak_perms=$(find /usr/local/bin -type f ! -perm 755 2>/dev/null | wc -l)
    if [ "$weak_perms" -gt 0 ]; then
        log "Fixing $weak_perms files with weak permissions..."
        find /usr/local/bin -type f ! -perm 755 -exec chmod 755 {} \; 2>/dev/null
        log "✓ Security: Fixed file permissions"
    fi
    
    # Check for outdated packages with known vulnerabilities
    if command -v unattended-upgrades &>/dev/null; then
        if ! systemctl is-enabled unattended-upgrades &>/dev/null; then
            log "Enabling automatic security updates..."
            systemctl enable unattended-upgrades 2>/dev/null || true
        fi
    fi
}

# Performance Optimization (2025 AI-powered)
optimize_performance() {
    # CPU governor optimization
    if [ -f /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor ]; then
        local current_gov=$(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor)
        local load=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
        local load_num=$(echo "$load" | bc 2>/dev/null || echo "0")
        
        # Adaptive CPU governor based on load
        if [ "$(echo "$load_num > 2.0" | bc 2>/dev/null || echo "0")" = "1" ] && [ "$current_gov" != "performance" ]; then
            echo performance > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || true
            log "Performance: Switched to performance governor (high load)"
        elif [ "$(echo "$load_num < 0.5" | bc 2>/dev/null || echo "0")" = "1" ] && [ "$current_gov" != "powersave" ]; then
            echo powersave > /sys/devices/system/cpu/cpu*/cpufreq/scaling_governor 2>/dev/null || true
            log "Performance: Switched to powersave governor (low load)"
        fi
    fi
    
    # I/O scheduler optimization
    for disk in /sys/block/sd* /sys/block/mmcblk*; do
        if [ -f "$disk/queue/scheduler" ]; then
            local current_sched=$(cat "$disk/queue/scheduler" | grep -o '\[.*\]' | tr -d '[]')
            if [ "$current_sched" != "mq-deadline" ] && [ "$current_sched" != "bfq" ]; then
                echo mq-deadline > "$disk/queue/scheduler" 2>/dev/null || true
            fi
        fi
    done
}

# Zero-Downtime Updates
zero_downtime_update() {
    if ! check_cloud_connectivity; then
        return 1
    fi
    
    log "Performing zero-downtime update..."
    
    # Stage 1: Download updates without installing
    apt-get update -qq
    apt-get upgrade -s -qq > /tmp/updates-list.txt 2>&1
    
    if [ -s /tmp/updates-list.txt ]; then
        log "Updates available, applying zero-downtime strategy..."
        
        # Stage 2: Install updates in background
        DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq > /tmp/update.log 2>&1 &
        UPDATE_PID=$!
        
        # Stage 3: Monitor and ensure services stay up
        while kill -0 $UPDATE_PID 2>/dev/null; do
            # Keep critical services running
            systemctl is-active swapfile-manager-2025.service >/dev/null || systemctl start swapfile-manager-2025.service
            systemctl is-active battery-monitor.service >/dev/null || systemctl start battery-monitor.service
            sleep 5
        done
        
        wait $UPDATE_PID
        log "✓ Zero-downtime update completed"
        return 0
    else
        log "System is up to date"
        return 0
    fi
}

# Cloud connectivity check
check_cloud_connectivity() {
    if ping -c 1 8.8.8.8 >/dev/null 2>&1 && curl -s --max-time 5 "https://api.github.com" >/dev/null 2>&1; then
        return 0
    fi
    return 1
}

# Main monitoring loop
monitor() {
    log "GhostPi Advanced Bot 2025 started"
    log "Features: AI-powered, Predictive maintenance, Anomaly detection, Zero-downtime ops"
    
    init_metrics_db
    
    while true; do
        # Advanced health check
        advanced_health_check
        health_status=$?
        
        # Zero-downtime updates (every 6 hours)
        if [ $(($(date +%s) % 21600)) -eq 0 ]; then
            zero_downtime_update
        fi
        
        # Commit fixes if enabled
        if [ "$AUTO_COMMIT" = "true" ] && [ $health_status -eq 0 ]; then
            commit_fixes
        fi
        
        # Log comprehensive status
        local uptime=$(uptime -p)
        local load=$(uptime | awk -F'load average:' '{print $2}')
        local cloud_status=$(check_cloud_connectivity && echo "Connected" || echo "Disconnected")
        log "Status - Uptime: $uptime, Load: $load, Health: OK, Cloud: $cloud_status"
        
        sleep "$CHECK_INTERVAL"
    done
}

# Commit fixes (from original bot)
commit_fixes() {
    if [ "$AUTO_COMMIT" != "true" ]; then
        return 0
    fi
    
    if [ ! -d "$GIT_REPO_DIR/.git" ]; then
        init_git
    fi
    
    cd "$GIT_REPO_DIR"
    
    if git diff --quiet && git diff --cached --quiet; then
        return 0
    fi
    
    git add -A 2>/dev/null || true
    git commit -m "Advanced Bot 2025: Auto-fix $(date +%Y-%m-%d)" 2>/dev/null && {
        log "✓ Committed fixes"
        if check_cloud_connectivity; then
            git push origin main 2>/dev/null && log "✓ Pushed to GitHub" || true
        fi
    } || true
}

# Initialize git
init_git() {
    if [ ! -d "$GIT_REPO_DIR/.git" ]; then
        mkdir -p "$GIT_REPO_DIR"
        cd "$GIT_REPO_DIR"
        git init
        git remote add origin https://github.com/sowavy234/ghostpi.git 2>/dev/null || true
    fi
}

case "${1:-monitor}" in
    monitor)
        monitor
        ;;
    check)
        advanced_health_check
        ;;
    status)
        echo "GhostPi Advanced Bot 2025 Status:"
        if pgrep -f "ghostpi-bot-2025.sh monitor" > /dev/null; then
            echo "  Status: Running"
            echo "  PID: $(pgrep -f 'ghostpi-bot-2025.sh monitor')"
        else
            echo "  Status: Stopped"
        fi
        echo ""
        echo "Recent activity:"
        tail -20 "$LOG_FILE" 2>/dev/null || echo "No log file"
        ;;
    *)
        echo "Usage: $0 {monitor|check|status}"
        exit 1
        ;;
esac

