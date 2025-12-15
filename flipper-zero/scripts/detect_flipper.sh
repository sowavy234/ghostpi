#!/bin/bash
# Auto-detect Flipper Zero when connected
# Supports USB and serial connections

detect_flipper() {
    local flipper_found=false
    local flipper_path=""
    
    # Check USB devices
    if command -v lsusb &> /dev/null; then
        if lsusb | grep -qi "flipper"; then
            flipper_found=true
            flipper_path=$(lsusb | grep -i flipper | head -1)
            echo "USB"
            return 0
        fi
    fi
    
    # Check serial devices
    for dev in /dev/ttyACM* /dev/ttyUSB* /dev/ttyAMA*; do
        if [ -e "$dev" ]; then
            # Try to identify Flipper Zero
            if udevadm info "$dev" 2>/dev/null | grep -qi "flipper\|0483:5740"; then
                flipper_found=true
                flipper_path="$dev"
                echo "SERIAL:$dev"
                return 0
            fi
        fi
    done
    
    # Check for Flipper Zero via qFlipper CLI
    if command -v qflipper-cli &> /dev/null; then
        if qflipper-cli info 2>/dev/null | grep -q "Flipper"; then
            flipper_found=true
            echo "QFLIPPER"
            return 0
        fi
    fi
    
    # Check for Flipper Zero via flipper-cli
    if command -v flipper-cli &> /dev/null; then
        if flipper-cli info 2>/dev/null | grep -q "Flipper"; then
            flipper_found=true
            echo "FLIPPER_CLI"
            return 0
        fi
    fi
    
    echo "NOT_FOUND"
    return 1
}

get_flipper_info() {
    local connection_type=$(detect_flipper)
    
    case "$connection_type" in
        USB|SERIAL:*|QFLIPPER|FLIPPER_CLI)
            echo "Flipper Zero detected via: $connection_type"
            
            # Try to get device info
            if command -v qflipper-cli &> /dev/null; then
                qflipper-cli info 2>/dev/null || true
            elif command -v flipper-cli &> /dev/null; then
                flipper-cli info 2>/dev/null || true
            fi
            ;;
        *)
            echo "Flipper Zero not detected"
            return 1
            ;;
    esac
}

# Main execution
if [ "${BASH_SOURCE[0]}" = "${0}" ]; then
    get_flipper_info
fi

