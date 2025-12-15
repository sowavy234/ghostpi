#!/bin/bash
# Wavy's World Update System
# Simple menu-driven updates for everything
# EDUCATIONAL PURPOSES ONLY

set -e

LOG_FILE="/var/log/wavy-update.log"
CLOUD_CHECK_URL="https://api.github.com"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

check_cloud_connection() {
    log "Checking cloud connectivity..."
    
    if ping -c 1 8.8.8.8 >/dev/null 2>&1; then
        if curl -s --max-time 5 "$CLOUD_CHECK_URL" >/dev/null 2>&1; then
            echo "✓ Cloud connected"
            return 0
        fi
    fi
    
    echo "✗ No cloud connection"
    echo "Please connect to WiFi or Ethernet for updates"
    return 1
}

update_pentesting_tools() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Update Pentesting Tools                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    if ! check_cloud_connection; then
        return 1
    fi
    
    log "Updating pentesting tools..."
    
    # Update Kali tools
    echo "Updating Kali Linux tools..."
    apt-get update -qq
    apt-get upgrade -y kali-linux-default 2>/dev/null || apt-get upgrade -y 2>/dev/null
    
    # Update Parrot tools
    echo "Updating Parrot OS tools..."
    apt-get upgrade -y parrot-tools 2>/dev/null || true
    
    # Update individual tools
    echo "Updating individual tools..."
    apt-get upgrade -y \
        nmap masscan sqlmap metasploit-framework \
        aircrack-ng hashcat john hydra \
        burpsuite wireshark bettercap \
        2>/dev/null || true
    
    echo "✓ Pentesting tools updated"
    log "Pentesting tools update complete"
}

update_wireless_tools() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Update Wireless Tools                                  ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    if ! check_cloud_connection; then
        return 1
    fi
    
    log "Updating wireless tools..."
    
    apt-get update -qq
    apt-get upgrade -y \
        aircrack-ng reaver bully wifite \
        kismet wireshark tshark bettercap \
        hostapd-wpe mdk4 pixiewps \
        2>/dev/null || true
    
    echo "✓ Wireless tools updated"
    log "Wireless tools update complete"
}

update_kernel() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Update Kernel                                          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    if ! check_cloud_connection; then
        return 1
    fi
    
    log "Updating kernel..."
    
    CURRENT_KERNEL=$(uname -r)
    echo "Current kernel: $CURRENT_KERNEL"
    
    # Update kernel
    apt-get update -qq
    apt-get upgrade -y linux-image-* linux-headers-* 2>/dev/null || {
        # For Raspberry Pi, use rpi-update
        if command -v rpi-update &> /dev/null; then
            echo "Using rpi-update for kernel update..."
            rpi-update 2>/dev/null || true
        else
            echo "Kernel update via apt..."
            apt-get upgrade -y 2>/dev/null || true
        fi
    }
    
    NEW_KERNEL=$(uname -r)
    if [ "$CURRENT_KERNEL" != "$NEW_KERNEL" ]; then
        echo "⚠ Kernel updated. Reboot required."
        echo "New kernel: $NEW_KERNEL"
    else
        echo "✓ Kernel is up to date"
    fi
    
    log "Kernel update complete"
}

update_firmware() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Update Firmware                                        ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    if ! check_cloud_connection; then
        return 1
    fi
    
    log "Updating firmware..."
    
    CURRENT_FIRMWARE=$(cat /proc/version 2>/dev/null | awk '{print $3}' || echo "Unknown")
    echo "Current firmware: $CURRENT_FIRMWARE"
    
    # Update firmware
    if command -v rpi-update &> /dev/null; then
        echo "Updating Raspberry Pi firmware..."
        rpi-update 2>/dev/null || true
    elif [ -f /usr/bin/raspi-config ]; then
        echo "Updating via raspi-config..."
        apt-get update -qq
        apt-get upgrade -y raspberrypi-kernel raspberrypi-bootloader 2>/dev/null || true
    else
        echo "Updating system firmware..."
        apt-get update -qq
        apt-get upgrade -y firmware-* 2>/dev/null || true
    fi
    
    echo "✓ Firmware update complete"
    echo "⚠ Reboot recommended after firmware update"
    log "Firmware update complete"
}

update_system() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Update System                                          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    if ! check_cloud_connection; then
        return 1
    fi
    
    log "Updating system..."
    
    echo "Updating package lists..."
    apt-get update -qq
    
    echo "Upgrading all packages..."
    apt-get upgrade -y
    
    echo "Cleaning up..."
    apt-get autoremove -y
    apt-get autoclean
    
    echo "✓ System updated"
    log "System update complete"
}

update_ghostpi() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Update GhostPi Components                              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    if ! check_cloud_connection; then
        return 1
    fi
    
    log "Updating GhostPi components..."
    
    GHOSTPI_DIR="/opt/ghostpi/repo"
    
    if [ -d "$GHOSTPI_DIR/.git" ]; then
        cd "$GHOSTPI_DIR"
        echo "Pulling latest GhostPi updates..."
        git pull origin main 2>/dev/null || true
        
        # Reinstall components
        if [ -f "$GHOSTPI_DIR/scripts/quick_install.sh" ]; then
            echo "Reinstalling GhostPi components..."
            "$GHOSTPI_DIR/scripts/quick_install.sh" 2>/dev/null || true
        fi
    else
        echo "GhostPi repository not found. Cloning..."
        mkdir -p "$GHOSTPI_DIR"
        git clone https://github.com/sowavy234/ghostpi.git "$GHOSTPI_DIR" 2>/dev/null || true
    fi
    
    echo "✓ GhostPi components updated"
    log "GhostPi update complete"
}

update_all() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Update Everything                                       ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    
    if ! check_cloud_connection; then
        return 1
    fi
    
    log "Starting full system update..."
    
    update_system
    update_kernel
    update_firmware
    update_pentesting_tools
    update_wireless_tools
    update_ghostpi
    
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        All Updates Complete!                                  ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "⚠ Reboot recommended after updates"
    log "Full system update complete"
}

show_menu() {
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Wavy's World Update System                             ║"
    echo "║        ⚠️  EDUCATIONAL PURPOSES ONLY ⚠️                        ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "1. Update Pentesting Tools"
    echo "2. Update Wireless Tools"
    echo "3. Update Kernel"
    echo "4. Update Firmware"
    echo "5. Update System"
    echo "6. Update GhostPi Components"
    echo "7. Update Everything"
    echo "8. Check Cloud Connection"
    echo "9. Exit"
    echo ""
    echo -n "Select option: "
}

main() {
    while true; do
        show_menu
        read choice
        
        case $choice in
            1) update_pentesting_tools ;;
            2) update_wireless_tools ;;
            3) update_kernel ;;
            4) update_firmware ;;
            5) update_system ;;
            6) update_ghostpi ;;
            7) update_all ;;
            8) check_cloud_connection ;;
            9) exit 0 ;;
            *) echo "Invalid option" ;;
        esac
        
        echo ""
        echo "Press Enter to continue..."
        read
    done
}

main

