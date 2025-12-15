#!/bin/bash
# HackberryPi CM5 LED Control
# Custom notification patterns and behaviors
# EDUCATIONAL PURPOSES ONLY

set -e

LED_PATH="/sys/class/leds"
LOG_FILE="/var/log/wavy-led.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

# Find available LEDs
find_leds() {
    if [ -d "$LED_PATH" ]; then
        ls "$LED_PATH" 2>/dev/null | head -1
    else
        echo ""
    fi
}

# Set LED brightness
set_led() {
    local led="$1"
    local brightness="$2"
    
    if [ -f "$LED_PATH/$led/brightness" ]; then
        echo "$brightness" > "$LED_PATH/$led/brightness" 2>/dev/null || true
    fi
}

# Heartbeat pattern
heartbeat() {
    local led=$(find_leds)
    if [ -z "$led" ]; then
        echo "No LED found"
        return 1
    fi
    
    echo "Starting heartbeat pattern..."
    
    while true; do
        # Heartbeat: quick double flash
        set_led "$led" 255
        sleep 0.1
        set_led "$led" 0
        sleep 0.1
        set_led "$led" 255
        sleep 0.1
        set_led "$led" 0
        sleep 0.8
        
        # Check if should stop
        if [ -f /tmp/wavy-led-stop ]; then
            rm -f /tmp/wavy-led-stop
            set_led "$led" 0
            break
        fi
    done
}

# Breathing pattern
breathing() {
    local led=$(find_leds)
    if [ -z "$led" ]; then
        echo "No LED found"
        return 1
    fi
    
    echo "Starting breathing pattern..."
    
    while true; do
        # Fade in
        for i in {0..255..10}; do
            set_led "$led" "$i"
            sleep 0.05
        done
        
        # Fade out
        for i in {255..0..10}; do
            set_led "$led" "$i"
            sleep 0.05
        done
        
        if [ -f /tmp/wavy-led-stop ]; then
            rm -f /tmp/wavy-led-stop
            set_led "$led" 0
            break
        fi
    done
}

# Notification flash
notify() {
    local led=$(find_leds)
    if [ -z "$led" ]; then
        echo "No LED found"
        return 1
    fi
    
    # Flash 3 times
    for i in {1..3}; do
        set_led "$led" 255
        sleep 0.2
        set_led "$led" 0
        sleep 0.2
    done
}

# Custom pattern
custom_pattern() {
    local led=$(find_leds)
    if [ -z "$led" ]; then
        echo "No LED found"
        return 1
    fi
    
    echo "Enter custom pattern (on/off times in seconds, comma-separated):"
    echo "Example: 0.5,0.3,0.5,0.3 (on 0.5s, off 0.3s, repeat)"
    read -r pattern
    
    IFS=',' read -ra TIMES <<< "$pattern"
    
    while true; do
        for time in "${TIMES[@]}"; do
            set_led "$led" 255
            sleep "$time"
            set_led "$led" 0
            sleep "$time"
        done
        
        if [ -f /tmp/wavy-led-stop ]; then
            rm -f /tmp/wavy-led-stop
            set_led "$led" 0
            break
        fi
    done
}

# Stop LED pattern
stop_pattern() {
    touch /tmp/wavy-led-stop
    sleep 0.5
    local led=$(find_leds)
    if [ -n "$led" ]; then
        set_led "$led" 0
    fi
    echo "LED pattern stopped"
}

show_menu() {
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        HackberryPi CM5 LED Control                            ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    local led=$(find_leds)
    if [ -n "$led" ]; then
        echo "LED found: $led"
    else
        echo "⚠ No LED detected"
    fi
    
    echo ""
    echo "1. Heartbeat Pattern"
    echo "2. Breathing Pattern"
    echo "3. Notification Flash"
    echo "4. Custom Pattern"
    echo "5. Stop Pattern"
    echo "6. Test LED"
    echo "7. Exit"
    echo ""
    echo -n "Select option: "
}

main() {
    while true; do
        show_menu
        read choice
        
        case $choice in
            1) heartbeat & ;;
            2) breathing & ;;
            3) notify ;;
            4) custom_pattern & ;;
            5) stop_pattern ;;
            6) 
                local led=$(find_leds)
                if [ -n "$led" ]; then
                    set_led "$led" 255
                    sleep 1
                    set_led "$led" 0
                    echo "LED test complete"
                fi
                ;;
            7) exit 0 ;;
            *) echo "Invalid option" ;;
        esac
        
        echo ""
        echo "Press Enter to continue..."
        read
    done
}

main

