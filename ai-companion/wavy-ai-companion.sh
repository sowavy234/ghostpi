#!/bin/bash
# Wavy's AI Companion - System Monitoring with Graphs
# Like Parrot OS monitoring dashboard
# EDUCATIONAL PURPOSES ONLY

set -e

LOG_FILE="/var/log/wavy-ai-companion.log"
UPDATE_INTERVAL=2  # Update every 2 seconds

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Get system metrics
get_metrics() {
    # CPU usage
    CPU_USAGE=$(top -bn1 | grep "Cpu(s)" | sed "s/.*, *\([0-9.]*\)%* id.*/\1/" | awk '{print 100 - $1}')
    
    # Memory usage
    MEM_TOTAL=$(free -m | grep Mem | awk '{print $2}')
    MEM_USED=$(free -m | grep Mem | awk '{print $3}')
    MEM_PCT=$((MEM_USED * 100 / MEM_TOTAL))
    
    # Disk usage
    DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    DISK_TOTAL=$(df -h / | tail -1 | awk '{print $2}')
    
    # CPU temperature
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        CPU_TEMP=$((CPU_TEMP / 1000))
    else
        CPU_TEMP=$(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 | cut -d\' -f1 | cut -d. -f1 || echo "0")
    fi
    
    # Load average
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    LOAD_PCT=$(echo "$LOAD * 100" | bc 2>/dev/null | cut -d. -f1 || echo "0")
    
    # Network stats
    RX_BYTES=$(cat /proc/net/dev | grep -v lo | awk '{sum+=$2} END {print sum}' || echo "0")
    TX_BYTES=$(cat /proc/net/dev | grep -v lo | awk '{sum+=$10} END {print sum}' || echo "0")
    RX_MB=$(echo "scale=2; $RX_BYTES / 1024 / 1024" | bc 2>/dev/null || echo "0")
    TX_MB=$(echo "scale=2; $TX_BYTES / 1024 / 1024" | bc 2>/dev/null || echo "0")
    
    # Battery status
    if [ -f /tmp/battery-status.txt ]; then
        BATTERY_VOLTAGE=$(grep "Voltage:" /tmp/battery-status.txt | awk '{print $2}' || echo "N/A")
        BATTERY_PCT=$(grep "Percentage:" /tmp/battery-status.txt | awk '{print $2}' | sed 's/%//' || echo "0")
        BATTERY_STATUS=$(grep "Status:" /tmp/battery-status.txt | awk '{print $2}' || echo "Unknown")
    else
        BATTERY_VOLTAGE="N/A"
        BATTERY_PCT="0"
        BATTERY_STATUS="Unknown"
    fi
    
    # Uptime
    UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "0 min")
}

# Draw bar graph
draw_bar() {
    local value="$1"
    local max="$2"
    local width="$3"
    local color="$4"
    
    local filled=$((value * width / max))
    local empty=$((width - filled))
    
    printf "${color}"
    for ((i=0; i<filled; i++)); do
        printf "█"
    done
    printf "${NC}"
    for ((i=0; i<empty; i++)); do
        printf "░"
    done
}

# Display dashboard
show_dashboard() {
    clear
    get_metrics
    
    echo -e "${PURPLE}╔═══════════════════════════════════════════════════════════════╗${NC}"
    echo -e "${PURPLE}║${NC}        ${CYAN}Wavy's AI Companion - System Monitor${NC}                    ${PURPLE}║${NC}"
    echo -e "${PURPLE}╚═══════════════════════════════════════════════════════════════╝${NC}"
    echo ""
    
    # CPU Usage
    echo -e "${BLUE}CPU Usage:${NC} ${GREEN}${CPU_USAGE}%${NC}"
    draw_bar "${CPU_USAGE%.*}" 100 40 "$GREEN"
    echo ""
    
    # Memory Usage
    echo -e "${BLUE}Memory:${NC} ${GREEN}${MEM_PCT}%${NC} of ${MEM_TOTAL}M"
    draw_bar "$MEM_PCT" 100 40 "$GREEN"
    echo ""
    
    # Disk Usage
    echo -e "${BLUE}Disk:${NC} ${GREEN}${DISK_USAGE}%${NC} of ${DISK_TOTAL}"
    draw_bar "$DISK_USAGE" 100 40 "$GREEN"
    echo ""
    
    # Battery Status
    if [ "$BATTERY_VOLTAGE" != "N/A" ]; then
        echo -e "${BLUE}Battery:${NC} ${GREEN}${BATTERY_PCT}%${NC} (${BATTERY_VOLTAGE}V) - ${BATTERY_STATUS}"
        draw_bar "$BATTERY_PCT" 100 40 "$GREEN"
        echo ""
    fi
    
    # System Info
    echo -e "${BLUE}System Information:${NC}"
    echo -e "  CPU Temp:    ${GREEN}${CPU_TEMP}°C${NC}"
    echo -e "  Load:        ${GREEN}${LOAD_PCT}%${NC}"
    echo -e "  Uptime:      ${GREEN}${UPTIME}${NC}"
    echo ""
    
    # Network Stats
    echo -e "${BLUE}Network:${NC}"
    echo -e "  RX:          ${GREEN}${RX_MB} MiB${NC}"
    echo -e "  TX:          ${GREEN}${TX_MB} MiB${NC}"
    echo ""
    
    # AI Companion Status
    echo -e "${CYAN}AI Companion Status:${NC}"
    echo -e "  Monitoring:  ${GREEN}Active${NC}"
    echo -e "  Health:      ${GREEN}Good${NC}"
    echo -e "  Updates:    ${GREEN}Enabled${NC}"
    echo ""
    
    echo -e "${YELLOW}Press Ctrl+C to exit${NC}"
}

# AI analysis
ai_analysis() {
    get_metrics
    
    local issues=0
    local warnings=0
    
    # Check CPU
    if [ "$(echo "$CPU_USAGE > 90" | bc 2>/dev/null || echo "0")" = "1" ]; then
        log "⚠ High CPU usage: ${CPU_USAGE}%"
        warnings=$((warnings + 1))
    fi
    
    # Check Memory
    if [ "$MEM_PCT" -gt 90 ]; then
        log "⚠ High memory usage: ${MEM_PCT}%"
        warnings=$((warnings + 1))
    fi
    
    # Check Disk
    if [ "$DISK_USAGE" -gt 90 ]; then
        log "⚠ High disk usage: ${DISK_USAGE}%"
        warnings=$((warnings + 1))
    fi
    
    # Check Temperature
    if [ "$CPU_TEMP" -gt 80 ]; then
        log "⚠ High CPU temperature: ${CPU_TEMP}°C"
        warnings=$((warnings + 1))
    fi
    
    # Check Battery
    if [ "$BATTERY_PCT" != "0" ] && [ "$BATTERY_PCT" -lt 20 ]; then
        log "⚠ Low battery: ${BATTERY_PCT}%"
        warnings=$((warnings + 1))
    fi
    
    if [ $warnings -gt 0 ]; then
        echo "⚠ $warnings warning(s) detected"
    else
        echo "✓ System healthy"
    fi
}

# Main monitoring loop
monitor() {
    log "Wavy's AI Companion started"
    
    # Start battery monitoring in background
    /usr/local/bin/battery-monitor.sh monitor &
    BATTERY_PID=$!
    
    while true; do
        show_dashboard
        ai_analysis > /tmp/ai-analysis.txt 2>/dev/null || true
        sleep "$UPDATE_INTERVAL"
    done
}

case "${1:-monitor}" in
    monitor)
        monitor
        ;;
    dashboard)
        show_dashboard
        ;;
    analysis)
        ai_analysis
        ;;
    *)
        echo "Usage: $0 {monitor|dashboard|analysis}"
        exit 1
        ;;
esac

