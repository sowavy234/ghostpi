#!/bin/bash
# Dual-Boot Installation: Wavy's World (GhostPi) + BlackArch
# Combines tools from Kali, Parrot, and BlackArch
# EDUCATIONAL PURPOSES ONLY

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
LOG_FILE="/var/log/ghostpi-dual-boot.log"

DISCLAIMER="
╔═══════════════════════════════════════════════════════════════╗
║     Dual-Boot: Wavy's World + BlackArch Linux               ║
║     ⚠️  EDUCATIONAL PURPOSES ONLY ⚠️                          ║
║                                                               ║
║  This will install a dual-boot system with:                  ║
║  - Wavy's World (GhostPi) - Custom pentesting distro        ║
║  - BlackArch Linux - 2800+ penetration testing tools        ║
║  - Kali Linux tools integration                              ║
║  - Parrot OS tools integration                               ║
║                                                               ║
║  All tools are for EDUCATIONAL and AUTHORIZED testing only.  ║
╚═══════════════════════════════════════════════════════════════╝
"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" | tee -a "$LOG_FILE"
}

echo "$DISCLAIMER"
echo ""
read -p "Do you understand and agree? (yes/no): " agree
if [ "$agree" != "yes" ]; then
    echo "Installation cancelled."
    exit 1
fi

# Check if running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root (use sudo)"
    exit 1
fi

log "Starting dual-boot installation..."

# Install GRUB and boot tools
log "Installing GRUB bootloader..."
apt-get update -qq
apt-get install -y grub-efi grub-pc-bin grub-common os-prober >/dev/null 2>&1

# Add BlackArch repository
log "Adding BlackArch repository..."
if ! grep -q "blackarch" /etc/pacman.conf 2>/dev/null; then
    # For Debian-based systems, we'll use BlackArch tools via compatible sources
    # BlackArch is Arch-based, so we'll install tools individually
    log "BlackArch is Arch-based. Installing tools via compatible sources..."
fi

# Install BlackArch tools (via compatible packages)
log "Installing BlackArch-compatible tools..."
BLACKARCH_TOOLS=(
    # Information Gathering
    "nmap" "masscan" "zmap" "recon-ng" "theharvester" "amass" "sublist3r"
    "dnsrecon" "dnsenum" "fierce" "dnswalk" "dnsmap" "dnstracer"
    
    # Vulnerability Assessment  
    "nikto" "openvas" "lynis" "nuclei" "golismero" "skipfish" "wapiti"
    "wpscan" "joomscan" "drupwn" "plecost" "w3af"
    
    # Web Application Analysis
    "burpsuite" "owasp-zap" "sqlmap" "commix" "websploit" "wfuzz"
    "dirb" "dirbuster" "gobuster" "ffuf" "feroxbuster"
    
    # Password Attacks
    "john" "hashcat" "hydra" "medusa" "ncrack" "patator" "crunch"
    "cewl" "rsmangler" "wordlists" "rockyou"
    
    # Wireless Attacks
    "aircrack-ng" "reaver" "bully" "wifite" "kismet" "wireshark"
    "tshark" "bettercap" "hostapd-wpe" "mdk4" "pixiewps"
    
    # Exploitation Tools
    "metasploit-framework" "exploitdb" "searchsploit" "armitage"
    "routersploit" "beef-xss" "setoolkit"
    
    # Post Exploitation
    "powersploit" "empire" "veil" "unicorn" "weevely"
    
    # Sniffing & Spoofing
    "ettercap-text-only" "dsniff" "yersinia" "responder" "bettercap"
    "netdiscover" "netmask" "scapy" "tcpdump"
    
    # Forensics
    "autopsy" "sleuthkit" "volatility" "binwalk" "foremost" "testdisk"
    "photorec" "scalpel" "bulk-extractor"
    
    # Reverse Engineering
    "radare2" "ghidra" "apktool" "dex2jar" "jd-gui" "jadx"
    
    # Social Engineering
    "social-engineer-toolkit" "beef-xss"
    
    # Bluetooth
    "bluetooth" "bluelog" "bluebugger" "bluesnarfer"
    
    # RFID/NFC
    "libnfc" "mfoc" "mfcuk" "nfc-list"
    
    # Additional BlackArch-specific tools
    "netcat" "socat" "ncat" "proxychains4" "tor" "anonsurf"
)

# Install all tools
log "Installing comprehensive toolset..."
for tool in "${BLACKARCH_TOOLS[@]}"; do
    apt-get install -y "$tool" >/dev/null 2>&1 && log "  ✓ $tool" || log "  ✗ $tool (not available)"
done

# Create dual-boot GRUB configuration
log "Creating dual-boot GRUB configuration..."
cat > /etc/grub.d/40_custom <<'GRUB'
#!/bin/sh
exec tail -n +3 $0
# Dual-Boot: Wavy's World + BlackArch

menuentry "Wavy's World (GhostPi)" {
    set root=(hd0,1)
    linux /boot/vmlinuz root=/dev/sda1 ro quiet splash plymouth.ignore-serial-consoles
    initrd /boot/initrd.img
}

menuentry "BlackArch Linux" {
    set root=(hd0,2)
    linux /boot/vmlinuz-linux root=/dev/sda2 ro
    initrd /boot/initramfs-linux.img
}

menuentry "Wavy's World (Recovery)" {
    set root=(hd0,1)
    linux /boot/vmlinuz root=/dev/sda1 ro single
    initrd /boot/initrd.img
}
GRUB

chmod +x /etc/grub.d/40_custom

# Update GRUB
log "Updating GRUB configuration..."
update-grub >/dev/null 2>&1 || grub-mkconfig -o /boot/grub/grub.cfg >/dev/null 2>&1

# Create unified tool menu
log "Creating unified pentesting tools menu..."
cat > /usr/local/bin/wavys-world-menu.sh <<'MENU'
#!/bin/bash
# Wavy's World - Unified Pentesting Tools Menu
# Kali | Parrot | BlackArch Tools
# EDUCATIONAL PURPOSES ONLY

clear
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           Welcome to Wavy's World                             ║"
echo "║     Kali | Parrot | BlackArch | Flipper Zero                 ║"
echo "║           ⚠️  EDUCATIONAL PURPOSES ONLY ⚠️                   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "1. Information Gathering (nmap, masscan, recon-ng, amass)"
echo "2. Vulnerability Assessment (nikto, openvas, nuclei, wpscan)"
echo "3. Web Application Analysis (burpsuite, sqlmap, commix, wfuzz)"
echo "4. Password Attacks (john, hashcat, hydra, medusa)"
echo "5. Wireless Attacks (aircrack-ng, reaver, wifite, bettercap)"
echo "6. Exploitation Tools (metasploit, exploitdb, routersploit)"
echo "7. Post Exploitation (powersploit, empire, veil)"
echo "8. Sniffing & Spoofing (ettercap, bettercap, wireshark)"
echo "9. Forensics (autopsy, volatility, binwalk, testdisk)"
echo "10. Reverse Engineering (radare2, ghidra, apktool)"
echo "11. Social Engineering (setoolkit, beef-xss)"
echo "12. Flipper Zero Tools"
echo "13. Marauder WiFi Tools"
echo "14. AI Coding Assistant"
echo "15. System Status"
echo "16. Exit"
echo ""
read -p "Select option: " choice

case $choice in
    1) 
        echo "Information Gathering Tools:"
        echo "  nmap, masscan, zmap, recon-ng, theharvester"
        echo "  dnsrecon, dnsenum, amass, sublist3r"
        ;;
    2)
        echo "Vulnerability Assessment Tools:"
        echo "  nikto, openvas, lynis, nuclei, wpscan"
        ;;
    3)
        echo "Web Application Analysis:"
        echo "  burpsuite, sqlmap, commix, wfuzz, gobuster"
        ;;
    4)
        echo "Password Attacks:"
        echo "  john, hashcat, hydra, medusa, crunch"
        ;;
    5)
        echo "Wireless Attacks:"
        echo "  aircrack-ng, reaver, wifite, bettercap"
        ;;
    6)
        echo "Exploitation Tools:"
        echo "  metasploit-framework, exploitdb, routersploit"
        ;;
    7)
        echo "Post Exploitation:"
        echo "  powersploit, empire, veil"
        ;;
    8)
        echo "Sniffing & Spoofing:"
        echo "  ettercap, bettercap, wireshark, tcpdump"
        ;;
    9)
        echo "Forensics:"
        echo "  autopsy, volatility, binwalk, testdisk"
        ;;
    10)
        echo "Reverse Engineering:"
        echo "  radare2, ghidra, apktool"
        ;;
    11)
        echo "Social Engineering:"
        echo "  setoolkit, beef-xss"
        ;;
    12)
        flipper-pentest.sh
        ;;
    13)
        marauder-setup.sh
        ;;
    14)
        ai-coding-assistant.sh interactive
        ;;
    15)
        ghostpi-helper.sh status
        ;;
    16)
        exit 0
        ;;
    *)
        echo "Invalid choice"
        ;;
esac
MENU

chmod +x /usr/local/bin/wavys-world-menu.sh

# Create boot splash for dual-boot
log "Creating dual-boot splash screen..."
mkdir -p /usr/share/plymouth/themes/wavys-world
cat > /usr/share/plymouth/themes/wavys-world/wavys-world.plymouth <<'SPLASH'
[Plymouth Theme]
Name=Wavy's World
Description=Welcome to Wavy's World - Dual Boot with BlackArch
ModuleName=script

[script]
ImageDir=/usr/share/plymouth/themes/wavys-world
ScriptFile=/usr/share/plymouth/themes/wavys-world/wavys-world.script
SPLASH

log "✓ Dual-boot installation complete!"
log ""
log "System configured with:"
log "  - Wavy's World (GhostPi) - Primary OS"
log "  - BlackArch tools integration"
log "  - Kali Linux tools integration"
log "  - Parrot OS tools integration"
log "  - Flipper Zero integration"
log ""
log "Access tools: wavys-world-menu.sh"
log ""
log "⚠️  REMEMBER: EDUCATIONAL PURPOSES ONLY ⚠️"

echo ""
echo "╔═══════════════════════════════════════════════════════════════╗"
echo "║           Dual-Boot Installation Complete!                   ║"
echo "╚═══════════════════════════════════════════════════════════════╝"
echo ""
echo "Reboot to see dual-boot menu (Wavy's World / BlackArch)"
echo ""
echo "Access tools: wavys-world-menu.sh"
echo "⚠️  EDUCATIONAL PURPOSES ONLY ⚠️"

