#!/bin/bash
# GhostPi Automated Monitoring Bot
# Constantly checks for problems and auto-fixes with commit capability

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
LOG_FILE="/var/log/ghostpi-bot.log"
CHECK_INTERVAL=300  # 5 minutes
GIT_REPO_DIR="/opt/ghostpi/repo"
AUTO_COMMIT="${AUTO_COMMIT:-true}"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BOT] $1" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $1"
    return 1
}

# Initialize git if needed
init_git() {
    if [ ! -d "$GIT_REPO_DIR/.git" ]; then
        log "Initializing git repository..."
        mkdir -p "$GIT_REPO_DIR"
        cd "$GIT_REPO_DIR"
        git init
        git remote add origin https://github.com/sowavy234/ghostpi.git 2>/dev/null || true
        git fetch origin main 2>/dev/null || true
        git checkout -b main 2>/dev/null || git checkout main 2>/dev/null || true
    fi
}

# Check system health
check_system_health() {
    local issues=0
    local fixes_applied=0
    
    log "Running system health check..."
    
    # Check services
    local services=("swapfile-manager" "auto-update" "self-healing")
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service.service" 2>/dev/null; then
            log "Issue detected: Service $service is down"
            systemctl restart "$service.service" 2>/dev/null && {
                log "✓ Fixed: Restarted $service"
                fixes_applied=$((fixes_applied + 1))
            } || {
                log "✗ Failed to restart $service"
                issues=$((issues + 1))
            }
        fi
    done
    
    # Check disk space
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 85 ]; then
        log "Issue detected: Disk usage at ${disk_usage}%"
        apt-get clean -qq 2>/dev/null || true
        find /var/log -name "*.log" -mtime +7 -delete 2>/dev/null || true
        find /tmp -type f -mtime +1 -delete 2>/dev/null || true
        local new_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
        log "✓ Fixed: Disk usage reduced to ${new_usage}%"
        fixes_applied=$((fixes_applied + 1))
    fi
    
    # Check memory
    local mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    if [ "$mem_usage" -gt 90 ]; then
        log "Issue detected: Memory usage at ${mem_usage}%"
        # Trigger swap if needed
        if [ -f "/swapfile" ] && ! swapon --show | grep -q "/swapfile"; then
            swapon /swapfile 2>/dev/null && {
                log "✓ Fixed: Activated swapfile"
                fixes_applied=$((fixes_applied + 1))
            }
        fi
    fi
    
    # Check network
    if ! ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        log "Issue detected: Network connectivity lost"
        systemctl restart networking 2>/dev/null || systemctl restart NetworkManager 2>/dev/null || true
        sleep 5
        if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
            log "✓ Fixed: Network connectivity restored"
            fixes_applied=$((fixes_applied + 1))
        else
            issues=$((issues + 1))
        fi
    fi
    
    # Check critical files
    local critical_files=(
        "/boot/config.txt"
        "/usr/local/bin/ghostpi-helper.sh"
        "/usr/local/bin/swapfile-manager.sh"
    )
    
    for file in "${critical_files[@]}"; do
        if [ ! -f "$file" ]; then
            log "Issue detected: Missing critical file $file"
            issues=$((issues + 1))
        fi
    done
    
    # Check file permissions
    if [ -d "/usr/local/bin" ]; then
        local broken_perms=$(find /usr/local/bin -name "ghostpi-*.sh" ! -executable 2>/dev/null | wc -l)
        if [ "$broken_perms" -gt 0 ]; then
            log "Issue detected: $broken_perms scripts with broken permissions"
            chmod +x /usr/local/bin/ghostpi-*.sh 2>/dev/null && {
                log "✓ Fixed: Restored script permissions"
                fixes_applied=$((fixes_applied + 1))
            }
        fi
    fi
    
    # Check script syntax errors
    if [ -d "$GIT_REPO_DIR" ]; then
        local syntax_errors=0
        while IFS= read -r script; do
            if ! bash -n "$script" 2>/dev/null; then
                syntax_errors=$((syntax_errors + 1))
                log "Syntax error in: $script"
                
                # Try common fixes
                # Missing closing quote on SCRIPT_DIR
                if grep -q 'SCRIPT_DIR="$(cd.*&& pwd)$' "$script" 2>/dev/null; then
                    sed -i 's/SCRIPT_DIR="$(cd.*&& pwd)$/SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" \&\& pwd)"/' "$script" 2>/dev/null && {
                        log "✓ Fixed syntax error in $script"
                        fixes_applied=$((fixes_applied + 1))
                    }
                fi
            fi
        done < <(find "$GIT_REPO_DIR" -type f -name "*.sh" 2>/dev/null)
        
        if [ $syntax_errors -gt 0 ]; then
            log "Found $syntax_errors script syntax errors"
        fi
    fi
    
    log "Health check complete: $fixes_applied fixes applied, $issues issues remain"
    
    return $issues
}

# Check for updates
check_for_updates() {
    log "Checking for GhostPi updates..."
    
    if [ ! -d "$GIT_REPO_DIR/.git" ]; then
        init_git
    fi
    
    cd "$GIT_REPO_DIR"
    
    # Fetch latest
    git fetch origin main 2>/dev/null || {
        log "Failed to fetch updates"
        return 1
    }
    
    local local_commit=$(git rev-parse HEAD 2>/dev/null || echo "")
    local remote_commit=$(git rev-parse origin/main 2>/dev/null || echo "")
    
    if [ -n "$local_commit" ] && [ -n "$remote_commit" ] && [ "$local_commit" != "$remote_commit" ]; then
        log "Update available: $local_commit -> $remote_commit"
        
        # Backup before update
        mkdir -p /opt/ghostpi/backups
        tar -czf "/opt/ghostpi/backups/pre-update-$(date +%Y%m%d_%H%M%S).tar.gz" \
            /usr/local/bin/ghostpi-* \
            /etc/systemd/system/ghostpi-*.service \
            2>/dev/null || true
        
        # Pull updates
        git pull origin main 2>/dev/null && {
            log "✓ Updated to latest version"
            
            # Install updated components
            if [ -f "$GIT_REPO_DIR/scripts/quick_install.sh" ]; then
                "$GIT_REPO_DIR/scripts/quick_install.sh" 2>/dev/null || true
            fi
            
            return 0
        } || {
            log "✗ Update failed"
            return 1
        }
    else
        log "System is up to date"
        return 0
    fi
}

# Generate system report
generate_report() {
    local report_file="/tmp/ghostpi-bot-report-$(date +%Y%m%d_%H%M%S).txt"
    
    {
        echo "GhostPi Automated Monitor Report"
        echo "Generated: $(date)"
        echo "=========================================="
        echo ""
        echo "System Status:"
        uptime
        echo ""
        echo "Memory:"
        free -h
        echo ""
        echo "Disk:"
        df -h /
        echo ""
        echo "Services:"
        systemctl is-active swapfile-manager.service > /dev/null && echo "  ✓ swapfile-manager" || echo "  ✗ swapfile-manager"
        systemctl is-active auto-update.service > /dev/null && echo "  ✓ auto-update" || echo "  ✗ auto-update"
        systemctl is-active self-healing.service > /dev/null && echo "  ✓ self-healing" || echo "  ✗ self-healing"
        echo ""
        echo "Network:"
        ping -c 1 8.8.8.8 > /dev/null 2>&1 && echo "  ✓ Internet connected" || echo "  ✗ Internet disconnected"
        echo ""
        echo "Recent Logs:"
        tail -20 "$LOG_FILE" 2>/dev/null || echo "No logs"
    } > "$report_file"
    
    echo "$report_file"
}

# Commit and push fixes (if enabled)
commit_fixes() {
    if [ "$AUTO_COMMIT" != "true" ]; then
        return 0
    fi
    
    log "Preparing to commit fixes..."
    
    # Only commit if there are actual changes
    if [ ! -d "$GIT_REPO_DIR/.git" ]; then
        init_git
    fi
    
    cd "$GIT_REPO_DIR"
    
    # Check if there are changes
    if git diff --quiet && git diff --cached --quiet; then
        log "No changes to commit"
        return 0
    fi
    
    # Generate report
    local report=$(generate_report)
    
    # Add changes
    git add -A 2>/dev/null || true
    
    # Commit with report
    git commit -m "Automated fix: System maintenance $(date +%Y-%m-%d)

- Auto-fixed system issues
- Health check completed
- Report: $(basename $report)

[Automated by GhostPi Bot]" 2>/dev/null && {
        log "✓ Committed fixes"
        
        # Push if network available
        if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
            git push origin main 2>/dev/null && {
                log "✓ Pushed fixes to GitHub"
            } || {
                log "✗ Failed to push (may need authentication)"
            }
        else
            log "Skipping push (no network)"
        fi
    } || {
        log "No changes to commit"
    }
}

# Main monitoring loop
monitor() {
    log "GhostPi Automated Monitor Bot started"
    log "Check interval: ${CHECK_INTERVAL}s"
    log "Auto-commit: $AUTO_COMMIT"
    
    while true; do
        # Run health check
        check_system_health
        health_status=$?
        
        # Check for updates (less frequently)
        if [ $(($(date +%s) % 3600)) -eq 0 ]; then
            check_for_updates
        fi
        
        # Commit fixes if enabled
        if [ "$AUTO_COMMIT" = "true" ] && [ $health_status -eq 0 ]; then
            commit_fixes
        fi
        
        # Log status
        local uptime=$(uptime -p)
        local load=$(uptime | awk -F'load average:' '{print $2}')
        log "Status - Uptime: $uptime, Load: $load, Health: OK"
        
        sleep "$CHECK_INTERVAL"
    done
}

# Single check run
single_check() {
    log "Running single health check..."
    check_system_health
    check_for_updates
    
    if [ "$AUTO_COMMIT" = "true" ]; then
        commit_fixes
    fi
    
    log "Single check completed"
}

case "${1:-monitor}" in
    monitor)
        monitor
        ;;
    check)
        single_check
        ;;
    status)
        echo "GhostPi Bot Status:"
        if pgrep -f "ghostpi-bot.sh monitor" > /dev/null; then
            echo "  Status: Running"
            echo "  PID: $(pgrep -f 'ghostpi-bot.sh monitor')"
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

