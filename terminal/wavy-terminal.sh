#!/bin/bash
# Wavy's World Enhanced Terminal
# With AI Coding Assistant and System Info Banner
# EDUCATIONAL PURPOSES ONLY

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# System info functions
get_system_info() {
    # Get kernel version
    KERNEL=$(uname -r)
    
    # Get firmware version
    FIRMWARE=$(cat /proc/version 2>/dev/null | awk '{print $3}' || echo "Unknown")
    
    # Get uptime
    UPTIME=$(uptime -p 2>/dev/null | sed 's/up //' || echo "0 min")
    
    # Get load average
    LOAD=$(uptime | awk -F'load average:' '{print $2}' | awk '{print $1}' | sed 's/,//')
    LOAD_PCT=$(echo "$LOAD * 100" | bc 2>/dev/null | cut -d. -f1 || echo "0")
    
    # Get memory usage
    MEM_TOTAL=$(free -m | grep Mem | awk '{print $2}')
    MEM_USED=$(free -m | grep Mem | awk '{print $3}')
    MEM_PCT=$((MEM_USED * 100 / MEM_TOTAL))
    
    # Get CPU temperature
    if [ -f /sys/class/thermal/thermal_zone0/temp ]; then
        CPU_TEMP=$(cat /sys/class/thermal/thermal_zone0/temp)
        CPU_TEMP=$((CPU_TEMP / 1000))
    else
        CPU_TEMP=$(vcgencmd measure_temp 2>/dev/null | cut -d= -f2 | cut -d\' -f1 | cut -d. -f1 || echo "0")
    fi
    
    # Get disk usage
    DISK_USAGE=$(df -h / | tail -1 | awk '{print $5}' | sed 's/%//')
    DISK_TOTAL=$(df -h / | tail -1 | awk '{print $2}')
    
    # Get network stats
    RX_TODAY=$(cat /proc/net/dev | grep -v lo | awk '{sum+=$2} END {printf "%.0f", sum/1024/1024}' || echo "0")
    
    # Get IP addresses
    IP_LAN=$(ip -4 addr show | grep -oP '(?<=inet\s)\d+(\.\d+){3}' | grep -v 127.0.0.1 | head -1 || echo "N/A")
    IP_WAN=$(curl -s ifconfig.me 2>/dev/null || echo "N/A")
    
    # Get hostname
    HOSTNAME=$(hostname)
    
    # Get date
    DATE=$(date '+%a %b %d %H:%M:%S %Y')
    
    # Get battery status
    if [ -f /tmp/battery-status.txt ]; then
        BATTERY_PCT=$(grep "Percentage:" /tmp/battery-status.txt | awk '{print $2}' || echo "N/A")
        BATTERY_VOLTAGE=$(grep "Voltage:" /tmp/battery-status.txt | awk '{print $2}' || echo "N/A")
        BATTERY_STATUS=$(grep "Status:" /tmp/battery-status.txt | awk '{print $2}' || echo "Unknown")
    else
        BATTERY_PCT="N/A"
        BATTERY_VOLTAGE="N/A"
        BATTERY_STATUS="Unknown"
    fi
}

# Display banner
show_banner() {
    clear
    echo -e "${PURPLE}"
    cat <<'BANNER'
  ___ ___ ___ _____ ___ ___ ___ _____ ___ ___ _  _      ___ ___ _ 
 | _ )_ _/ __|_   _| _ \ __| __|_   _| __/ __| || |___ / __| _ ) |
 | _ \| | (_ | | | |   / _|| _|  | | | _| (__| __ |___| (__| _ \ |
 |___/___\___| |_| |_|_\___|___| |_| |___\___|_||_|    \___|___/_|
                                                                  
BANNER
    echo -e "${NC}"
    
    get_system_info
    
    echo -e "${CYAN}Welcome to Wavy's World${NC}"
    echo -e "${YELLOW}GhostPi v1.2.0 - HackberryPi CM5 Edition${NC}"
    echo ""
    echo -e "${BLUE}System Information:${NC}"
    echo -e "  Kernel:     ${GREEN}$KERNEL${NC}"
    echo -e "  Firmware:   ${GREEN}$FIRMWARE${NC}"
    echo -e "  Date:       ${GREEN}$DATE${NC}"
    echo -e "  Hostname:   ${GREEN}$HOSTNAME${NC}"
    echo ""
    echo -e "${BLUE}Network:${NC}"
    echo -e "  LAN IP:     ${GREEN}$IP_LAN${NC}"
    echo -e "  WAN IP:     ${GREEN}$IP_WAN${NC}"
    echo ""
    echo -e "${BLUE}Performance:${NC}"
    printf "  Load:       %-15s Up time:     %s\n" "${GREEN}${LOAD_PCT}%${NC}" "${GREEN}${UPTIME}${NC}"
    printf "  Memory:     %-15s CPU temp:    %s\n" "${GREEN}${MEM_PCT}% of ${MEM_TOTAL}M${NC}" "${GREEN}${CPU_TEMP}°C${NC}"
    printf "  Disk:       %-15s RX today:     %s\n" "${GREEN}${DISK_USAGE}% of ${DISK_TOTAL}${NC}" "${GREEN}${RX_TODAY} MiB${NC}"
    if [ "$BATTERY_PCT" != "N/A" ]; then
        printf "  Battery:    %-15s Status:      %s\n" "${GREEN}${BATTERY_PCT} (${BATTERY_VOLTAGE}V)${NC}" "${GREEN}${BATTERY_STATUS}${NC}"
    fi
    echo ""
    echo -e "${BLUE}Commands:${NC}"
    echo -e "  ${GREEN}wavy-update${NC}     - Update system, tools, kernel, firmware"
    echo -e "  ${GREEN}wavy-ai${NC}         - AI coding assistant"
    echo -e "  ${GREEN}wavy-companion${NC}  - AI companion with system graphs"
    echo -e "  ${GREEN}wavy-menu${NC}       - Pentesting tools menu"
    echo -e "  ${GREEN}wavy-led${NC}        - LED control and notifications"
    echo -e "  ${GREEN}battery-status${NC}  - Battery monitoring"
    echo -e "  ${GREEN}wavy-help${NC}       - Show all commands"
    echo ""
    echo -e "${YELLOW}⚠️  EDUCATIONAL PURPOSES ONLY ⚠️${NC}"
    echo ""
}

# AI Coding Assistant
ai_assistant() {
    echo -e "${CYAN}Wavy's AI Coding Assistant${NC}"
    echo -e "${YELLOW}Type 'exit' to return to terminal${NC}"
    echo ""
    
    while true; do
        echo -ne "${GREEN}wavy-ai> ${NC}"
        read -e input
        
        if [ "$input" = "exit" ] || [ "$input" = "quit" ]; then
            break
        fi
        
        if [ -z "$input" ]; then
            continue
        fi
        
        # Check if it's a code request
        if echo "$input" | grep -qi "create\|write\|generate\|code\|function\|script"; then
            echo -e "${BLUE}Generating code suggestion...${NC}"
            # Call AI coding helper
            /usr/local/bin/ai-coding-assistant.sh generate "$input" 2>/dev/null || {
                echo -e "${YELLOW}AI assistant processing...${NC}"
                echo -e "${GREEN}Code suggestion:${NC}"
                echo "# $input"
                echo "# TODO: Implement based on your requirements"
            }
        elif echo "$input" | grep -qi "explain\|what\|how"; then
            echo -e "${BLUE}Explaining...${NC}"
            /usr/local/bin/ai-coding-assistant.sh explain "$input" 2>/dev/null || {
                echo -e "${YELLOW}AI explanation:${NC}"
                echo "This is a coding assistant. Use it to generate, explain, or refactor code."
            }
        else
            # Auto-complete suggestions
            echo -e "${BLUE}Suggestions:${NC}"
            echo "  - Try: 'create a function to $input'"
            echo "  - Try: 'explain $input'"
            echo "  - Try: 'generate code for $input'"
        fi
        echo ""
    done
}

# Enhanced prompt with auto-complete
setup_prompt() {
    # Enable history
    history -a
    
    # Set up auto-complete
    complete -W "wavy-update wavy-ai wavy-menu wavy-led wavy-help ls cd pwd" wavy-command 2>/dev/null || true
}

# Main terminal loop
main_terminal() {
    show_banner
    
    while true; do
        echo -ne "${GREEN}wavy@${HOSTNAME}:~$ ${NC}"
        read -e command
        
        case "$command" in
            wavy-update)
                /usr/local/bin/wavy-update.sh
                ;;
            wavy-ai|ai)
                ai_assistant
                ;;
            wavy-menu|menu)
                /usr/local/bin/wavys-world-menu.sh
                ;;
            wavy-led|led)
                /usr/local/bin/wavy-led-control.sh
                ;;
            wavy-companion|companion)
                /usr/local/bin/wavy-ai-companion.sh monitor
                ;;
            battery-status|battery)
                /usr/local/bin/battery-monitor.sh info
                ;;
            wavy-help|help)
                show_banner
                ;;
            exit|quit)
                echo "Goodbye from Wavy's World!"
                exit 0
                ;;
            *)
                if [ -n "$command" ]; then
                    eval "$command" 2>/dev/null || {
                        echo -e "${RED}Command not found: $command${NC}"
                        echo -e "${YELLOW}Type 'wavy-help' for available commands${NC}"
                    }
                fi
                ;;
        esac
    done
}

# Initialize
setup_prompt
main_terminal

