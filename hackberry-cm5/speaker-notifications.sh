#!/bin/bash
# HackberryPi CM5 Speaker Notifications
# Use built-in speakers for system notifications
# EDUCATIONAL PURPOSES ONLY

set -e

# Audio device (adjust based on HackberryPi CM5 audio setup)
AUDIO_DEVICE="${AUDIO_DEVICE:-default}"

# Play notification sound
play_sound() {
    local sound_type="$1"
    
    case "$sound_type" in
        startup)
            # Startup beep sequence
            aplay /usr/share/sounds/alsa/Front_Left.wav 2>/dev/null || \
            speaker-test -t sine -f 800 -l 1 -s 1 >/dev/null 2>&1 || \
            echo -e "\a"
            ;;
        shutdown)
            # Shutdown beep
            aplay /usr/share/sounds/alsa/Front_Right.wav 2>/dev/null || \
            speaker-test -t sine -f 400 -l 1 -s 1 >/dev/null 2>&1 || \
            echo -e "\a"
            ;;
        notification)
            # Notification beep
            aplay /usr/share/sounds/alsa/Front_Center.wav 2>/dev/null || \
            speaker-test -t sine -f 1000 -l 1 -s 1 >/dev/null 2>&1 || \
            echo -e "\a"
            ;;
        error)
            # Error beep (low tone)
            aplay /usr/share/sounds/alsa/Rear_Left.wav 2>/dev/null || \
            speaker-test -t sine -f 200 -l 1 -s 1 >/dev/null 2>&1 || \
            echo -e "\a"
            ;;
        success)
            # Success beep (high tone)
            aplay /usr/share/sounds/alsa/Rear_Right.wav 2>/dev/null || \
            speaker-test -t sine -f 1200 -l 1 -s 1 >/dev/null 2>&1 || \
            echo -e "\a"
            ;;
        *)
            # Default beep
            echo -e "\a"
            ;;
    esac
}

# System notification with sound
notify() {
    local message="$1"
    local sound_type="${2:-notification}"
    
    # Play sound
    play_sound "$sound_type"
    
    # Show notification (if notify-send available)
    if command -v notify-send &> /dev/null; then
        notify-send "Wavy's World" "$message" 2>/dev/null || true
    fi
    
    # Also log
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Notification: $message" >> /var/log/wavy-notifications.log
}

# Startup notification
startup_notify() {
    notify "Welcome to Wavy's World" "startup"
}

# Shutdown notification
shutdown_notify() {
    notify "Shutting down Wavy's World" "shutdown"
}

# Update notification
update_notify() {
    notify "System update available" "notification"
}

# Error notification
error_notify() {
    notify "Error occurred" "error"
}

# Success notification
success_notify() {
    notify "Operation successful" "success"
}

case "${1:-notify}" in
    startup)
        startup_notify
        ;;
    shutdown)
        shutdown_notify
        ;;
    update)
        update_notify
        ;;
    error)
        error_notify
        ;;
    success)
        success_notify
        ;;
    notify)
        notify "${2:-Notification}" "${3:-notification}"
        ;;
    *)
        echo "Usage: $0 {startup|shutdown|update|error|success|notify} [message] [sound_type]"
        exit 1
        ;;
esac

