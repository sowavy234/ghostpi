#!/bin/bash
# Marauder WiFi Dev Board Manager
# For Flipper Zero WiFi Dev Board with Marauder firmware

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
MARAUDER_DIR="/opt/marauder"

detect_marauder() {
    echo "Detecting Marauder WiFi Dev Board..."
    
    # Check for Flipper Zero first
    if ! "$PROJECT_ROOT/flipper-zero/detection/flipper-detector.sh" detect >/dev/null 2>&1; then
        echo "✗ Flipper Zero not detected"
        return 1
    fi
    
    # Check for WiFi Dev Board
    local wifi_dev=$(lsusb | grep -i "wifi\|esp32\|marauder" || true)
    if [ -n "$wifi_dev" ]; then
        echo "✓ WiFi Dev Board detected: $wifi_dev"
        return 0
    fi
    
    # Check serial connection
    local serial=$(ls /dev/ttyACM* /dev/ttyUSB* 2>/dev/null | grep -v "flipper" | head -1)
    if [ -n "$serial" ]; then
        echo "✓ Serial device found (possible Marauder): $serial"
        return 0
    fi
    
    echo "✗ Marauder WiFi Dev Board not detected"
    return 1
}

install_marauder() {
    echo "Installing Marauder tools..."
    
    apt-get update -qq
    apt-get install -y \
        python3 python3-pip \
        esptool \
        screen \
        minicom \
        >/dev/null 2>&1
    
    # Install Marauder CLI
    pip3 install marauder-cli 2>/dev/null || {
        pip3 install --user marauder-cli
    }
    
    # Clone Marauder firmware if needed
    if [ ! -d "$MARAUDER_DIR/firmware" ]; then
        mkdir -p "$MARAUDER_DIR"
        git clone https://github.com/justcallmekoko/ESP32Marauder.git "$MARAUDER_DIR/firmware" 2>/dev/null || true
    fi
    
    echo "✓ Marauder tools installed"
}

flash_marauder() {
    local port="${1:-/dev/ttyUSB0}"
    echo "Flashing Marauder firmware to $port..."
    
    if [ ! -f "$MARAUDER_DIR/firmware/firmware.bin" ]; then
        echo "Building Marauder firmware..."
        cd "$MARAUDER_DIR/firmware"
        ./build.sh || {
            echo "Build failed. Using pre-built firmware..."
        }
    fi
    
    esptool.py --port "$port" write_flash 0x1000 "$MARAUDER_DIR/firmware/firmware.bin" || {
        echo "Flash failed. Check connection and port."
    }
}

connect_marauder() {
    local port="${1:-/dev/ttyUSB0}"
    echo "Connecting to Marauder on $port..."
    echo "Press Ctrl+A then K to exit"
    
    screen "$port" 115200 || minicom -D "$port" -b 115200
}

marauder_menu() {
    while true; do
        clear
        echo "=========================================="
        echo "  Marauder WiFi Dev Board Manager"
        echo "=========================================="
        echo ""
        echo "  1) Detect Marauder"
        echo "  2) Install Marauder Tools"
        echo "  3) Flash Firmware"
        echo "  4) Connect to Marauder"
        echo "  5) Scan WiFi Networks"
        echo "  6) Deauth Attack (Educational)"
        echo "  7) Beacon Spam (Educational)"
        echo "  0) Back"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            1) detect_marauder ;;
            2) install_marauder ;;
            3)
                read -p "Serial port (default /dev/ttyUSB0): " port
                flash_marauder "${port:-/dev/ttyUSB0}"
                ;;
            4)
                read -p "Serial port (default /dev/ttyUSB0): " port
                connect_marauder "${port:-/dev/ttyUSB0}"
                ;;
            5) "$PROJECT_ROOT/marauder/scripts/wifi-scanner.sh" ;;
            6) "$PROJECT_ROOT/marauder/scripts/deauth-helper.sh" ;;
            7) "$PROJECT_ROOT/marauder/scripts/beacon-spam-helper.sh" ;;
            0) break ;;
        esac
        
        read -p "Press Enter to continue..."
    done
}

marauder_menu

