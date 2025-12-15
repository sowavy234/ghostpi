#!/bin/bash
# Flipper Zero Management Tool
# Complete Flipper Zero companion for HackberryPi CM5

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FLIPPER_DIR="/opt/flipper"
FLIPPER_APPS="$FLIPPER_DIR/apps"
FLIPPER_BACKUP="$FLIPPER_DIR/backup"

show_menu() {
    clear
    echo "=========================================="
    echo "  Flipper Zero Manager"
    echo "  HackberryPi CM5 Companion"
    echo "=========================================="
    echo ""
    echo "  1) Detect Flipper Zero"
    echo "  2) Sync Apps to Flipper"
    echo "  3) Backup from Flipper"
    echo "  4) Build Flipper App (.fbt)"
    echo "  5) Install Flipper Tools"
    echo "  6) WiFi Dev Board (Marauder)"
    echo "  7) Brute Force Tools"
    echo "  8) Coding Helper"
    echo "  9) View Flipper Files"
    echo "  0) Exit"
    echo ""
}

detect_flipper() {
    echo "Detecting Flipper Zero..."
    "$PROJECT_ROOT/flipper-zero/detection/flipper-detector.sh" detect && {
        echo "✓ Flipper Zero connected!"
    } || {
        echo "✗ Flipper Zero not detected"
        echo "Make sure it's connected via USB"
    }
    read -p "Press Enter to continue..."
}

sync_apps() {
    echo "Syncing apps to Flipper Zero..."
    "$PROJECT_ROOT/flipper-zero/detection/flipper-detector.sh" sync-to "$FLIPPER_APPS"
    echo "✓ Apps synced!"
    read -p "Press Enter to continue..."
}

backup_flipper() {
    echo "Backing up from Flipper Zero..."
    "$PROJECT_ROOT/flipper-zero/detection/flipper-detector.sh" sync-from
    echo "✓ Backup completed!"
    read -p "Press Enter to continue..."
}

build_app() {
    echo "Building Flipper App with FBT..."
    "$PROJECT_ROOT/flipper-zero/scripts/fbt-builder.sh" "$@"
}

install_tools() {
    echo "Installing Flipper Zero tools..."
    "$PROJECT_ROOT/flipper-zero/scripts/install-flipper-tools.sh"
}

marauder_menu() {
    "$PROJECT_ROOT/marauder/scripts/marauder-manager.sh"
}

brute_force_menu() {
    "$PROJECT_ROOT/brute-force/helpers/brute-force-helper.sh"
}

coding_helper() {
    "$PROJECT_ROOT/flipper-zero/helpers/coding-assistant.sh"
}

view_files() {
    local mount_point=$("$PROJECT_ROOT/flipper-zero/detection/flipper-detector.sh" status | grep "Mount point" | awk '{print $3}')
    if [ -n "$mount_point" ] && [ -d "$mount_point" ]; then
        tree "$mount_point" 2>/dev/null || ls -laR "$mount_point" | head -50
    else
        echo "Flipper Zero not mounted"
    fi
    read -p "Press Enter to continue..."
}

main() {
    while true; do
        show_menu
        read -p "Select option: " choice
        
        case $choice in
            1) detect_flipper ;;
            2) sync_apps ;;
            3) backup_flipper ;;
            4) build_app ;;
            5) install_tools ;;
            6) marauder_menu ;;
            7) brute_force_menu ;;
            8) coding_helper ;;
            9) view_files ;;
            0) exit 0 ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    done
}

main

