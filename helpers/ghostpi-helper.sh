#!/bin/bash
# GhostPi Management Helper
# Complete system management tool

set -e

VERSION="1.0.0"
LOG_FILE="/var/log/ghostpi-helper.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

show_header() {
    clear
    echo "=========================================="
    echo "  GhostPi Management Helper v$VERSION"
    echo "  Welcome to Wavy's World"
    echo "=========================================="
    echo ""
}

show_menu() {
    echo "Main Menu:"
    echo "  1) System Status"
    echo "  2) Update System"
    echo "  3) Run Health Check"
    echo "  4) Repair System"
    echo "  5) Service Management"
    echo "  6) Network Tools"
    echo "  7) Disk Management"
    echo "  8) Boot Configuration"
    echo "  9) View Logs"
    echo " 10) Advanced Options"
    echo "  0) Exit"
    echo ""
}

system_status() {
    show_header
    echo "System Status:"
    echo ""
    
    # Uptime
    echo "Uptime: $(uptime -p)"
    echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
    echo ""
    
    # Memory
    echo "Memory:"
    free -h
    echo ""
    
    # Disk
    echo "Disk Usage:"
    df -h / | tail -1
    echo ""
    
    # Services
    echo "GhostPi Services:"
    systemctl is-active swapfile-manager.service > /dev/null && echo "  ✓ Swapfile Manager: Running" || echo "  ✗ Swapfile Manager: Stopped"
    systemctl is-active auto-update.service > /dev/null && echo "  ✓ Auto-Update: Running" || echo "  ✗ Auto-Update: Stopped"
    systemctl is-active self-healing.service > /dev/null && echo "  ✓ Self-Healing: Running" || echo "  ✗ Self-Healing: Stopped"
    echo ""
    
    # Network
    echo "Network:"
    if ping -c 1 8.8.8.8 > /dev/null 2>&1; then
        echo "  ✓ Internet: Connected"
    else
        echo "  ✗ Internet: Disconnected"
    fi
    echo ""
    
    read -p "Press Enter to continue..."
}

update_system() {
    show_header
    echo "Updating System..."
    echo ""
    
    /usr/local/bin/ghostpi-auto-update.sh update
    
    echo ""
    read -p "Press Enter to continue..."
}

health_check() {
    show_header
    echo "Running Health Check..."
    echo ""
    
    /usr/local/bin/ghostpi-self-heal.sh repair
    
    echo ""
    read -p "Press Enter to continue..."
}

repair_system() {
    show_header
    echo "Repairing System..."
    echo ""
    echo "This will attempt to fix all detected issues."
    read -p "Continue? (y/n) " -n 1 -r
    echo
    
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        /usr/local/bin/ghostpi-self-heal.sh repair
        echo ""
        echo "Repair completed!"
    fi
    
    echo ""
    read -p "Press Enter to continue..."
}

service_management() {
    while true; do
        show_header
        echo "Service Management:"
        echo ""
        echo "  1) Start Service"
        echo "  2) Stop Service"
        echo "  3) Restart Service"
        echo "  4) View Service Status"
        echo "  5) Enable Service"
        echo "  6) Disable Service"
        echo "  0) Back"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            1|2|3|4|5|6)
                echo ""
                echo "Available services:"
                echo "  a) swapfile-manager"
                echo "  b) auto-update"
                echo "  c) self-healing"
                echo ""
                read -p "Select service: " svc
                
                case $svc in
                    a) service="swapfile-manager" ;;
                    b) service="auto-update" ;;
                    c) service="self-healing" ;;
                    *) continue ;;
                esac
                
                case $choice in
                    1) sudo systemctl start "$service.service" ;;
                    2) sudo systemctl stop "$service.service" ;;
                    3) sudo systemctl restart "$service.service" ;;
                    4) systemctl status "$service.service" --no-pager ;;
                    5) sudo systemctl enable "$service.service" ;;
                    6) sudo systemctl disable "$service.service" ;;
                esac
                ;;
            0) break ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

network_tools() {
    show_header
    echo "Network Tools:"
    echo ""
    echo "  1) Test Connectivity"
    echo "  2) View Network Interfaces"
    echo "  3) Restart Network"
    echo "  4) View IP Address"
    echo "  0) Back"
    echo ""
    read -p "Select option: " choice
    
    case $choice in
        1)
            echo "Testing connectivity..."
            ping -c 3 8.8.8.8
            ;;
        2)
            ip addr show
            ;;
        3)
            echo "Restarting network..."
            sudo systemctl restart networking 2>/dev/null || sudo systemctl restart NetworkManager
            ;;
        4)
            hostname -I
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

disk_management() {
    show_header
    echo "Disk Management:"
    echo ""
    echo "  1) View Disk Usage"
    echo "  2) Clean Package Cache"
    echo "  3) Clean Logs"
    echo "  4) Clean Temp Files"
    echo "  0) Back"
    echo ""
    read -p "Select option: " choice
    
    case $choice in
        1)
            df -h
            ;;
        2)
            echo "Cleaning package cache..."
            sudo apt-get clean
            echo "Done!"
            ;;
        3)
            echo "Cleaning old logs..."
            sudo find /var/log -name "*.log" -mtime +7 -delete
            sudo find /var/log -name "*.gz" -delete
            echo "Done!"
            ;;
        4)
            echo "Cleaning temp files..."
            sudo find /tmp -type f -mtime +1 -delete
            echo "Done!"
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

boot_config() {
    show_header
    echo "Boot Configuration:"
    echo ""
    echo "  1) View config.txt"
    echo "  2) Edit config.txt"
    echo "  3) Backup config.txt"
    echo "  4) Restore config.txt"
    echo "  0) Back"
    echo ""
    read -p "Select option: " choice
    
    case $choice in
        1)
            if [ -f "/boot/config.txt" ]; then
                cat /boot/config.txt
            else
                echo "config.txt not found"
            fi
            ;;
        2)
            if [ -f "/boot/config.txt" ]; then
                sudo nano /boot/config.txt
            else
                echo "config.txt not found"
            fi
            ;;
        3)
            if [ -f "/boot/config.txt" ]; then
                sudo cp /boot/config.txt /boot/config.txt.backup.$(date +%Y%m%d_%H%M%S)
                echo "Backup created"
            fi
            ;;
        4)
            backup=$(ls -t /boot/config.txt.backup.* 2>/dev/null | head -1)
            if [ -n "$backup" ]; then
                sudo cp "$backup" /boot/config.txt
                echo "Restored from $backup"
            else
                echo "No backup found"
            fi
            ;;
    esac
    
    echo ""
    read -p "Press Enter to continue..."
}

view_logs() {
    while true; do
        show_header
        echo "View Logs:"
        echo ""
        echo "  1) Auto-Update Log"
        echo "  2) Self-Healing Log"
        echo "  3) Swapfile Manager Log"
        echo "  4) System Log"
        echo "  5) All GhostPi Logs"
        echo "  0) Back"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            1) less /var/log/ghostpi-auto-update.log 2>/dev/null || echo "Log file not found" ;;
            2) less /var/log/ghostpi-self-heal.log 2>/dev/null || echo "Log file not found" ;;
            3) less /var/log/swapfile-manager.log 2>/dev/null || echo "Log file not found" ;;
            4) journalctl -n 50 --no-pager ;;
            5) tail -50 /var/log/ghostpi-*.log 2>/dev/null || echo "No log files found" ;;
            0) break ;;
        esac
    done
}

advanced_options() {
    while true; do
        show_header
        echo "Advanced Options:"
        echo ""
        echo "  1) Force Update"
        echo "  2) Rebuild Initramfs"
        echo "  3) Check System Integrity"
        echo "  4) View System Info"
        echo "  5) Export Diagnostics"
        echo "  0) Back"
        echo ""
        read -p "Select option: " choice
        
        case $choice in
            1)
                echo "Forcing update..."
                sudo /usr/local/bin/ghostpi-auto-update.sh force
                ;;
            2)
                echo "Rebuilding initramfs..."
                sudo update-initramfs -u
                ;;
            3)
                echo "Checking system integrity..."
                sudo dpkg --audit
                sudo fsck -n / 2>/dev/null || echo "Cannot check root filesystem (mounted)"
                ;;
            4)
                echo "System Information:"
                uname -a
                echo ""
                cat /etc/os-release
                echo ""
                echo "Hardware:"
                cat /proc/cpuinfo | grep "model name" | head -1
                free -h
                ;;
            5)
                echo "Exporting diagnostics..."
                sudo mkdir -p /tmp/ghostpi-diagnostics
                systemctl status > /tmp/ghostpi-diagnostics/services.txt
                df -h > /tmp/ghostpi-diagnostics/disk.txt
                free -h > /tmp/ghostpi-diagnostics/memory.txt
                journalctl -n 100 > /tmp/ghostpi-diagnostics/journal.txt
                tar -czf /tmp/ghostpi-diagnostics.tar.gz /tmp/ghostpi-diagnostics
                echo "Diagnostics exported to: /tmp/ghostpi-diagnostics.tar.gz"
                ;;
            0) break ;;
        esac
        
        echo ""
        read -p "Press Enter to continue..."
    done
}

# Main menu loop
main() {
    while true; do
        show_header
        show_menu
        read -p "Select option: " choice
        
        case $choice in
            1) system_status ;;
            2) update_system ;;
            3) health_check ;;
            4) repair_system ;;
            5) service_management ;;
            6) network_tools ;;
            7) disk_management ;;
            8) boot_config ;;
            9) view_logs ;;
            10) advanced_options ;;
            0)
                echo "Goodbye!"
                exit 0
                ;;
            *)
                echo "Invalid option"
                sleep 1
                ;;
        esac
    done
}

# Run main menu
main

