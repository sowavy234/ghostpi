#!/bin/bash
# HackberryPi CM5 Battery Monitoring
# I2C-based battery voltage measurement and monitoring
# Based on: https://github.com/ZitaoTech/HackberryPiCM5

set -e

LOG_FILE="/var/log/battery-monitor.log"
I2C_BUS="${I2C_BUS:-1}"
BATTERY_ADDR="${BATTERY_ADDR:-0x36}"  # Common battery gauge address
BATTERY_CAPACITY_MAH=5000  # 5000mAh LiPo battery

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Read battery voltage via I2C
read_battery_voltage() {
    # Try different methods to read battery voltage
    local voltage=0
    
    # Method 1: I2C battery gauge (common for LiPo batteries)
    if command -v i2cget &> /dev/null; then
        voltage=$(i2cget -y "$I2C_BUS" "$BATTERY_ADDR" 0x04 w 2>/dev/null | awk '{printf "%.2f", $1/1000}' || echo "0")
    fi
    
    # Method 2: Check if battery info is in sysfs
    if [ "$voltage" = "0" ] && [ -f /sys/class/power_supply/BAT0/voltage_now ]; then
        voltage=$(cat /sys/class/power_supply/BAT0/voltage_now 2>/dev/null)
        voltage=$(echo "scale=2; $voltage / 1000000" | bc 2>/dev/null || echo "0")
    fi
    
    # Method 3: Check via vcgencmd (Raspberry Pi)
    if [ "$voltage" = "0" ] && command -v vcgencmd &> /dev/null; then
        voltage=$(vcgencmd get_throttled 2>/dev/null | grep -q "0x0" && echo "4.2" || echo "3.7")
    fi
    
    echo "$voltage"
}

# Calculate battery percentage
calculate_battery_percentage() {
    local voltage="$1"
    local percentage=0
    
    # LiPo battery voltage to percentage conversion
    # Full charge: 4.2V, Empty: 3.0V
    if [ -n "$voltage" ] && [ "$voltage" != "0" ]; then
        percentage=$(echo "scale=0; (($voltage - 3.0) / (4.2 - 3.0)) * 100" | bc 2>/dev/null || echo "0")
        
        # Clamp between 0 and 100
        if [ "$(echo "$percentage > 100" | bc 2>/dev/null || echo "0")" = "1" ]; then
            percentage=100
        elif [ "$(echo "$percentage < 0" | bc 2>/dev/null || echo "0")" = "1" ]; then
            percentage=0
        fi
    fi
    
    echo "$percentage"
}

# Estimate battery life
estimate_battery_life() {
    local percentage="$1"
    local current_usage="${2:-typical}"  # idle, typical, heavy
    
    local hours=0
    
    case "$current_usage" in
        idle)
            # ~5 hours at 100%
            hours=$(echo "scale=1; ($percentage / 100) * 5" | bc 2>/dev/null || echo "0")
            ;;
        typical)
            # ~3.5 hours at 100%
            hours=$(echo "scale=1; ($percentage / 100) * 3.5" | bc 2>/dev/null || echo "0")
            ;;
        heavy)
            # ~2 hours at 100%
            hours=$(echo "scale=1; ($percentage / 100) * 2" | bc 2>/dev/null || echo "0")
            ;;
    esac
    
    echo "$hours"
}

# Get battery status
get_battery_status() {
    local voltage=$(read_battery_voltage)
    local percentage=$(calculate_battery_percentage "$voltage")
    local status="Unknown"
    
    # Determine charging status
    if [ -f /sys/class/power_supply/BAT0/status ]; then
        status=$(cat /sys/class/power_supply/BAT0/status 2>/dev/null || echo "Unknown")
    elif [ -f /sys/class/power_supply/usb/online ]; then
        if [ "$(cat /sys/class/power_supply/usb/online 2>/dev/null)" = "1" ]; then
            status="Charging"
        else
            status="Discharging"
        fi
    fi
    
    # Estimate remaining time
    local remaining_hours=$(estimate_battery_life "$percentage" "typical")
    
    echo "Voltage: ${voltage}V"
    echo "Percentage: ${percentage}%"
    echo "Status: $status"
    echo "Capacity: ${BATTERY_CAPACITY_MAH}mAh"
    echo "Estimated remaining: ${remaining_hours} hours (typical usage)"
    
    # Log status
    log "Battery: ${percentage}% (${voltage}V) - $status - ${remaining_hours}h remaining"
}

# Monitor battery continuously
monitor_battery() {
    log "Starting battery monitoring..."
    
    while true; do
        get_battery_status > /tmp/battery-status.txt
        
        # Check for low battery
        local percentage=$(calculate_battery_percentage "$(read_battery_voltage)")
        
        if [ "$(echo "$percentage < 20" | bc 2>/dev/null || echo "0")" = "1" ]; then
            log "⚠ Low battery warning: ${percentage}%"
            /usr/local/bin/speaker-notifications.sh notify "Low battery: ${percentage}%" "error" 2>/dev/null || true
            /usr/local/bin/wavy-led-control.sh notify 2>/dev/null || true
        fi
        
        if [ "$(echo "$percentage < 10" | bc 2>/dev/null || echo "0")" = "1" ]; then
            log "⚠⚠ Critical battery: ${percentage}%"
            /usr/local/bin/speaker-notifications.sh notify "Critical battery: ${percentage}%" "error" 2>/dev/null || true
        fi
        
        sleep 60  # Check every minute
    done
}

# Display battery info
show_battery_info() {
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        HackberryPi CM5 Battery Status                        ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    get_battery_status
    echo ""
    echo "Press Enter to continue..."
    read
}

case "${1:-status}" in
    status)
        get_battery_status
        ;;
    monitor)
        monitor_battery
        ;;
    info)
        show_battery_info
        ;;
    *)
        echo "Usage: $0 {status|monitor|info}"
        exit 1
        ;;
esac

