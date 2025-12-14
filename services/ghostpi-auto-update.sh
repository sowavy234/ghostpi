#!/bin/bash
# GhostPi Auto-Update Service
# Automatically updates system packages and GhostPi components

set -e

LOG_FILE="/var/log/ghostpi-auto-update.log"
LOCK_FILE="/var/run/ghostpi-auto-update.lock"
UPDATE_DIR="/opt/ghostpi/updates"
BACKUP_DIR="/opt/ghostpi/backups"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

error() {
    log "ERROR: $1"
    exit 1
}

# Create lock file
lock() {
    if [ -f "$LOCK_FILE" ]; then
        local pid=$(cat "$LOCK_FILE")
        if ps -p "$pid" > /dev/null 2>&1; then
            log "Update already running (PID: $pid)"
            exit 0
        else
            rm -f "$LOCK_FILE"
        fi
    fi
    echo $$ > "$LOCK_FILE"
}

unlock() {
    rm -f "$LOCK_FILE"
}

# Cleanup on exit
trap unlock EXIT

update_system_packages() {
    log "Updating system packages..."
    
    # Update package lists
    apt-get update -qq || {
        log "Failed to update package lists"
        return 1
    }
    
    # Upgrade packages
    DEBIAN_FRONTEND=noninteractive apt-get upgrade -y -qq || {
        log "Failed to upgrade packages"
        return 1
    }
    
    # Clean up
    apt-get autoremove -y -qq
    apt-get autoclean -qq
    
    log "System packages updated successfully"
    return 0
}

update_ghostpi_components() {
    log "Updating GhostPi components..."
    
    local repo_dir="/opt/ghostpi/repo"
    local current_dir=$(pwd)
    
    # Clone or update repository
    if [ -d "$repo_dir" ]; then
        cd "$repo_dir"
        git fetch origin main || {
            log "Failed to fetch updates"
            return 1
        }
        
        local local_commit=$(git rev-parse HEAD)
        local remote_commit=$(git rev-parse origin/main)
        
        if [ "$local_commit" != "$remote_commit" ]; then
            log "New GhostPi updates available"
            
            # Backup current version
            mkdir -p "$BACKUP_DIR"
            tar -czf "$BACKUP_DIR/ghostpi-$(date +%Y%m%d_%H%M%S).tar.gz" \
                /usr/local/bin/ghostpi-* \
                /usr/share/plymouth/themes/wavys-world \
                /etc/systemd/system/ghostpi-*.service \
                2>/dev/null || true
            
            # Pull updates
            git pull origin main || {
                log "Failed to pull updates"
                return 1
            }
            
            # Install updated components
            if [ -f "$repo_dir/scripts/quick_install.sh" ]; then
                "$repo_dir/scripts/quick_install.sh" || {
                    log "Failed to install updates"
                    return 1
                }
            fi
            
            log "GhostPi components updated successfully"
        else
            log "GhostPi is up to date"
        fi
    else
        # First time setup
        mkdir -p "$(dirname $repo_dir)"
        git clone https://github.com/sowavy234/ghostpi.git "$repo_dir" || {
            log "Failed to clone repository"
            return 1
        }
    fi
    
    cd "$current_dir"
    return 0
}

check_health() {
    log "Running health check..."
    
    # Check critical services
    local services=("swapfile-manager" "auto-update")
    for service in "${services[@]}"; do
        if ! systemctl is-active --quiet "$service.service" 2>/dev/null; then
            log "WARNING: Service $service is not running"
            systemctl restart "$service.service" 2>/dev/null || true
        fi
    done
    
    # Check disk space
    local disk_usage=$(df / | tail -1 | awk '{print $5}' | sed 's/%//')
    if [ "$disk_usage" -gt 90 ]; then
        log "WARNING: Disk usage is ${disk_usage}%"
    fi
    
    # Check memory
    local mem_usage=$(free | grep Mem | awk '{printf "%.0f", $3/$2 * 100}')
    if [ "$mem_usage" -gt 90 ]; then
        log "WARNING: Memory usage is ${mem_usage}%"
    fi
    
    log "Health check completed"
}

case "${1:-update}" in
    update)
        lock
        log "Starting auto-update..."
        
        update_system_packages
        update_ghostpi_components
        
        log "Auto-update completed successfully"
        ;;
    check)
        check_health
        ;;
    force)
        lock
        log "Force update requested..."
        rm -rf /opt/ghostpi/repo
        update_ghostpi_components
        ;;
    status)
        if [ -f "$LOCK_FILE" ]; then
            echo "Update in progress (PID: $(cat $LOCK_FILE))"
        else
            echo "No update in progress"
        fi
        echo ""
        echo "Last update: $(tail -1 $LOG_FILE 2>/dev/null || echo 'Never')"
        ;;
    *)
        echo "Usage: $0 {update|check|force|status}"
        exit 1
        ;;
esac

