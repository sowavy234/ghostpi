#!/bin/bash
# FBT Builder - Build Flipper Zero apps with .fbt
# Integrated with coding assistant

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
FIRMWARE_DIR="/opt/flipper/firmware"
APP_DIR="${1:-$PROJECT_ROOT/flipper-zero/apps}"

echo "=========================================="
echo "  FBT Builder - Flipper Zero App Builder"
echo "=========================================="

# Check if FBT is installed
if [ ! -f "$FIRMWARE_DIR/scripts/fbt" ]; then
    echo "FBT not found. Installing..."
    "$PROJECT_ROOT/flipper-zero/scripts/install-flipper-tools.sh"
fi

# Check if app directory exists
if [ ! -d "$APP_DIR" ]; then
    echo "Creating app directory: $APP_DIR"
    mkdir -p "$APP_DIR"
fi

# Show available apps
echo ""
echo "Available apps in $APP_DIR:"
ls -1 "$APP_DIR" 2>/dev/null | head -10 || echo "No apps found"

echo ""
read -p "Enter app name to build (or 'new' to create): " app_name

if [ "$app_name" = "new" ]; then
    # Create new app with coding assistant
    "$PROJECT_ROOT/flipper-zero/helpers/coding-assistant.sh" create-app
else
    # Build existing app
    if [ -d "$APP_DIR/$app_name" ]; then
        echo "Building app: $app_name"
        cd "$FIRMWARE_DIR"
        ./scripts/fbt fap_$app_name || {
            echo "Build failed. Using coding assistant to help..."
            "$PROJECT_ROOT/flipper-zero/helpers/coding-assistant.sh" fix-build "$app_name"
        }
    else
        echo "App not found: $app_name"
        exit 1
    fi
fi

