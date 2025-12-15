#!/bin/bash
# HackberryPi CM5 Power Management
# Call button = Power On
# Call End button = Power Off/Shutdown
# EDUCATIONAL PURPOSES ONLY

set -e

LOG_FILE="/var/log/hackberry-power.log"
GPIO_CALL_BUTTON=17      # GPIO pin for call button (adjust based on hardware)
GPIO_CALL_END_BUTTON=27  # GPIO pin for call end button (adjust based on hardware)

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Initialize GPIO pins
init_gpio() {
    log "Initializing GPIO pins for power management..."
    
    # Export GPIO pins
    echo "$GPIO_CALL_BUTTON" > /sys/class/gpio/export 2>/dev/null || true
    echo "$GPIO_CALL_END_BUTTON" > /sys/class/gpio/export 2>/dev/null || true
    
    # Set as input with pull-up
    echo "in" > /sys/class/gpio/gpio${GPIO_CALL_BUTTON}/direction 2>/dev/null || true
    echo "in" > /sys/class/gpio/gpio${GPIO_CALL_END_BUTTON}/direction 2>/dev/null || true
    echo "up" > /sys/class/gpio/gpio${GPIO_CALL_BUTTON}/direction 2>/dev/null || true
    echo "up" > /sys/class/gpio/gpio${GPIO_CALL_END_BUTTON}/direction 2>/dev/null || true
    
    log "✓ GPIO pins initialized"
}

# Monitor call button (power on)
monitor_call_button() {
    log "Monitoring call button for power on..."
    
    while true; do
        local call_state=$(cat /sys/class/gpio/gpio${GPIO_CALL_BUTTON}/value 2>/dev/null || echo "1")
        
        if [ "$call_state" = "0" ]; then
            log "Call button pressed - Power on sequence"
            
            # Wake from sleep or power on
            if [ -f /sys/power/state ]; then
                echo "on" > /sys/power/state 2>/dev/null || true
            fi
            
            # Wake display
            if command -v vcgencmd &> /dev/null; then
                vcgencmd display_power 1 >/dev/null 2>&1 || true
            fi
            
            # Resume system
            systemctl resume 2>/dev/null || true
            
            sleep 1
        fi
        
        sleep 0.1
    done
}

# Monitor call end button (power off/shutdown)
monitor_call_end_button() {
    log "Monitoring call end button for power off..."
    
    local press_duration=0
    local shutdown_threshold=3  # Hold for 3 seconds to shutdown
    
    while true; do
        local call_end_state=$(cat /sys/class/gpio/gpio${GPIO_CALL_END_BUTTON}/value 2>/dev/null || echo "1")
        
        if [ "$call_end_state" = "0" ]; then
            press_duration=$((press_duration + 1))
            
            if [ $press_duration -ge $shutdown_threshold ]; then
                log "Call end button held for ${shutdown_threshold}s - Shutting down..."
                
                # Show shutdown message
                if command -v wall &> /dev/null; then
                    wall "HackberryPi CM5: Shutting down..." 2>/dev/null || true
                fi
                
                # Graceful shutdown
                shutdown -h now "HackberryPi CM5 power button shutdown"
            fi
        else
            if [ $press_duration -gt 0 ] && [ $press_duration -lt $shutdown_threshold ]; then
                log "Call end button pressed briefly - Sleep mode"
                
                # Put display to sleep
                if command -v vcgencmd &> /dev/null; then
                    vcgencmd display_power 0 >/dev/null 2>&1 || true
                fi
                
                # Suspend system
                systemctl suspend 2>/dev/null || true
            fi
            press_duration=0
        fi
        
        sleep 0.1
    done
}

# Main function
main() {
    log "HackberryPi CM5 Power Management starting..."
    
    init_gpio
    
    # Start monitoring in background
    monitor_call_button &
    CALL_PID=$!
    
    monitor_call_end_button &
    CALL_END_PID=$!
    
    log "Power management active:"
    log "  - Call button: Power on / Wake"
    log "  - Call end (brief): Sleep"
    log "  - Call end (hold 3s): Shutdown"
    
    # Wait for processes
    wait $CALL_PID $CALL_END_PID
}

case "${1:-start}" in
    start)
        main
        ;;
    stop)
        pkill -f "power-management.sh" || true
        log "Power management stopped"
        ;;
    status)
        if pgrep -f "power-management.sh" > /dev/null; then
            echo "Power management: Running"
            echo "  Call button: GPIO $GPIO_CALL_BUTTON"
            echo "  Call end button: GPIO $GPIO_CALL_END_BUTTON"
        else
            echo "Power management: Stopped"
        fi
        ;;
    *)
        echo "Usage: $0 {start|stop|status}"
        exit 1
        ;;
esac

