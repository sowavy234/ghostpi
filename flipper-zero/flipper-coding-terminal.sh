#!/bin/bash
# Flipper Zero Coding Terminal
# Interactive terminal with coding help and tool usage
# EDUCATIONAL PURPOSES ONLY

set -e

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║        Flipper Zero Connected!                                ║"
echo "║        Coding Assistant & Tool Guide                          ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""

# Show Flipper info
echo "🔍 Detecting Flipper Zero..."
if /usr/local/bin/flipper-detector.sh >/dev/null 2>&1; then
    echo "✓ Flipper Zero detected and ready!"
    echo ""
    
    # Get Flipper info
    FLIPPER_INFO=$(/usr/local/bin/flipper-detector.sh 2>/dev/null || echo "")
    if [ -n "$FLIPPER_INFO" ]; then
        echo "$FLIPPER_INFO"
        echo ""
    fi
else
    echo "⚠ Flipper Zero not detected. Connect your Flipper Zero via USB."
    echo ""
fi

# Coding help menu
show_coding_help() {
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Flipper Zero Coding Help                               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "1. Create Flipper Zero App"
    echo "2. Generate BadUSB Script"
    echo "3. Create RFID/NFC Payload"
    echo "4. WiFi Attack Scripts"
    echo "5. Bluetooth Tools"
    echo "6. Code Examples"
    echo "7. FBT Build System"
    echo "8. AI Code Generator"
    echo "9. Sync Code to/from Flipper"
    echo "10. Exit to Main Terminal"
    echo ""
    echo -n "Select option: "
}

# Tool usage guide
show_tool_guide() {
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Flipper Zero Tool Usage Guide                          ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "📱 Flipper Zero Commands:"
    echo ""
    echo "  flipper-detector.sh          - Detect Flipper Zero"
    echo "  flipper-sync.sh push          - Push code to Flipper"
    echo "  flipper-sync.sh pull          - Pull code from Flipper"
    echo "  flipper-sync.sh sync          - Bidirectional sync"
    echo ""
    echo "🔧 Build Tools:"
    echo ""
    echo "  fbt-build-helper.sh install  - Install FBT"
    echo "  fbt-build-helper.sh create    - Create app template"
    echo "  fbt-build-helper.sh build     - Build app"
    echo ""
    echo "🎯 Pentesting Tools:"
    echo ""
    echo "  brute-force-helper.sh         - Brute force tools"
    echo "  marauder-setup.sh             - Marauder WiFi tools"
    echo "  ai-coding-assistant.sh        - AI code helper"
    echo ""
    echo "📚 Code Examples:"
    echo ""
    echo "  # Create simple app"
    echo "  fbt-build-helper.sh create MyApp"
    echo ""
    echo "  # Generate BadUSB script"
    echo "  brute-force-helper.sh badusb"
    echo ""
    echo "  # AI code generation"
    echo "  ai-coding-assistant.sh generate 'WiFi scanner' c"
    echo ""
    echo "Press Enter to continue..."
    read
}

# Main menu
main_menu() {
    while true; do
        show_coding_help
        read choice
        
        case $choice in
            1)
                echo "Creating Flipper Zero app..."
                read -p "App name: " app_name
                fbt-build-helper.sh create "$app_name"
                echo "App created! Edit the code and build with: fbt-build-helper.sh build $app_name"
                ;;
            2)
                echo "Generating BadUSB script..."
                brute-force-helper.sh badusb
                ;;
            3)
                echo "Creating RFID/NFC payload..."
                echo "Use Flipper Zero's built-in RFID/NFC tools"
                echo "Or generate with: brute-force-helper.sh rfid"
                ;;
            4)
                echo "WiFi attack scripts..."
                marauder-setup.sh
                ;;
            5)
                echo "Bluetooth tools..."
                echo "Use Flipper Zero's Bluetooth features"
                ;;
            6)
                show_code_examples
                ;;
            7)
                echo "FBT Build System..."
                fbt-build-helper.sh
                ;;
            8)
                echo "AI Code Generator..."
                ai-coding-assistant.sh interactive
                ;;
            9)
                echo "Syncing code..."
                flipper-sync.sh sync
                ;;
            10)
                /usr/local/bin/wavy-terminal.sh
                exit 0
                ;;
            *)
                echo "Invalid option"
                ;;
        esac
        
        echo ""
        echo "Press Enter to continue..."
        read
    done
}

# Code examples
show_code_examples() {
    clear
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║        Flipper Zero Code Examples                              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""
    echo "Example 1: Simple Flipper App"
    echo "─────────────────────────────"
    cat <<'EXAMPLE1'
#include <furi.h>
#include <gui/gui.h>

int32_t my_app_main(void* p) {
    UNUSED(p);
    // Your code here
    return 0;
}
EXAMPLE1
    echo ""
    echo "Example 2: BadUSB Script"
    echo "────────────────────────"
    echo "DELAY 1000"
    echo "STRING Hello from Flipper Zero!"
    echo "ENTER"
    echo ""
    echo "Example 3: RFID Clone"
    echo "───────────────────"
    echo "Use Flipper Zero's RFID tools to clone cards"
    echo ""
    echo "Press Enter to continue..."
    read
}

# Start
main_menu

