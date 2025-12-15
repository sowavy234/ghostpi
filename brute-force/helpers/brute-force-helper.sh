#!/bin/bash
# Educational Brute Force Helper
# Interactive guide for understanding brute force attacks
# FOR EDUCATIONAL PURPOSES ONLY

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

show_warning() {
    clear
    echo "=========================================="
    echo "  ⚠️  EDUCATIONAL USE ONLY ⚠️"
    echo "=========================================="
    echo ""
    echo "This tool is for EDUCATIONAL PURPOSES ONLY."
    echo ""
    echo "WARNING:"
    echo "  - Only use on systems you own or have"
    echo "    explicit written permission to test"
    echo "  - Unauthorized access is ILLEGAL"
    echo "  - Use responsibly and ethically"
    echo ""
    echo "By continuing, you agree to use this tool"
    echo "only for legitimate educational purposes."
    echo ""
    read -p "Press Enter to continue (or Ctrl+C to exit)..."
}

show_menu() {
    clear
    echo "=========================================="
    echo "  Brute Force Helper (Educational)"
    echo "  Interactive Learning Tool"
    echo "=========================================="
    echo ""
    echo "  1) SSH Brute Force (Educational)"
    echo "  2) WiFi WPA/WPA2 (Educational)"
    echo "  3) HTTP Basic Auth (Educational)"
    echo "  4) FTP Brute Force (Educational)"
    echo "  5) Wordlist Generator"
    echo "  6) Password Analysis"
    echo "  7) Rate Limiting Info"
    echo "  8) Legal & Ethical Guide"
    echo "  0) Exit"
    echo ""
}

ssh_brute_force() {
    show_warning
    clear
    echo "SSH Brute Force - Educational Guide"
    echo "===================================="
    echo ""
    echo "This demonstrates how SSH brute force works:"
    echo ""
    read -p "Target IP (your own system only!): " target_ip
    read -p "Username: " username
    read -p "Wordlist file: " wordlist
    
    if [ ! -f "$wordlist" ]; then
        echo "Wordlist not found. Creating sample..."
        echo -e "password\n123456\nadmin\nroot\ntest" > /tmp/sample_wordlist.txt
        wordlist="/tmp/sample_wordlist.txt"
    fi
    
    echo ""
    echo "Starting educational SSH brute force..."
    echo "This will attempt common passwords."
    echo ""
    
    "$PROJECT_ROOT/brute-force/tools/ssh-brute.sh" "$target_ip" "$username" "$wordlist" || {
        echo ""
        echo "Educational demonstration complete."
        echo "Remember: Only test on systems you own!"
    }
    
    read -p "Press Enter to continue..."
}

wifi_brute_force() {
    show_warning
    clear
    echo "WiFi WPA/WPA2 Brute Force - Educational"
    echo "========================================"
    echo ""
    echo "This requires a captured handshake (.cap file)"
    echo ""
    read -p "Handshake file (.cap): " cap_file
    read -p "Wordlist file: " wordlist
    
    if [ ! -f "$cap_file" ]; then
        echo "Handshake file not found!"
        read -p "Press Enter to continue..."
        return
    fi
    
    echo ""
    echo "Starting educational WiFi brute force..."
    "$PROJECT_ROOT/brute-force/tools/wifi-brute.sh" "$cap_file" "$wordlist"
    
    read -p "Press Enter to continue..."
}

http_brute_force() {
    show_warning
    clear
    echo "HTTP Basic Auth Brute Force - Educational"
    echo "=========================================="
    echo ""
    read -p "Target URL: " target_url
    read -p "Username: " username
    read -p "Wordlist file: " wordlist
    
    echo ""
    echo "Starting educational HTTP brute force..."
    "$PROJECT_ROOT/brute-force/tools/http-brute.sh" "$target_url" "$username" "$wordlist"
    
    read -p "Press Enter to continue..."
}

ftp_brute_force() {
    show_warning
    clear
    echo "FTP Brute Force - Educational"
    echo "=============================="
    echo ""
    read -p "Target IP: " target_ip
    read -p "Username: " username
    read -p "Wordlist file: " wordlist
    
    echo ""
    echo "Starting educational FTP brute force..."
    "$PROJECT_ROOT/brute-force/tools/ftp-brute.sh" "$target_ip" "$username" "$wordlist"
    
    read -p "Press Enter to continue..."
}

wordlist_generator() {
    clear
    echo "Wordlist Generator"
    echo "=================="
    echo ""
    read -p "Output file: " output_file
    read -p "Min length: " min_len
    read -p "Max length: " max_len
    read -p "Character set (default: a-z0-9): " charset
    charset="${charset:-a-z0-9}"
    
    echo "Generating wordlist..."
    "$PROJECT_ROOT/brute-force/tools/wordlist-gen.sh" "$output_file" "$min_len" "$max_len" "$charset"
    
    read -p "Press Enter to continue..."
}

legal_guide() {
    clear
    cat <<'EOF'
Legal & Ethical Guide for Brute Force Tools
===========================================

LEGAL WARNING:
- Unauthorized access to computer systems is ILLEGAL
- Penalties include fines and imprisonment
- Laws vary by jurisdiction

ETHICAL USE:
✅ Test on your own systems
✅ Get written permission (penetration testing)
✅ Educational learning in controlled environments
✅ Security research with proper authorization

❌ DO NOT:
- Attack systems without permission
- Access unauthorized networks
- Use for malicious purposes
- Violate terms of service

BEST PRACTICES:
1. Always get written authorization
2. Use in isolated lab environments
3. Document all activities
4. Follow responsible disclosure
5. Respect privacy and data

Remember: With great power comes great responsibility!

Press Enter to continue...
EOF
    read
}

main() {
    show_warning
    
    while true; do
        show_menu
        read -p "Select option: " choice
        
        case $choice in
            1) ssh_brute_force ;;
            2) wifi_brute_force ;;
            3) http_brute_force ;;
            4) ftp_brute_force ;;
            5) wordlist_generator ;;
            6) "$PROJECT_ROOT/brute-force/tools/password-analyzer.sh" ;;
            7) "$PROJECT_ROOT/brute-force/tools/rate-limit-info.sh" ;;
            8) legal_guide ;;
            0) exit 0 ;;
            *) echo "Invalid option"; sleep 1 ;;
        esac
    done
}

main

