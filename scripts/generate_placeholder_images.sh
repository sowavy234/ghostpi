#!/bin/bash
# Generate placeholder images for boot splash
# These can be replaced with actual 3D renders later

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BOOT_SPLASH_DIR="$SCRIPT_DIR/../boot-splash"

# Check if ImageMagick is installed
if ! command -v convert &> /dev/null; then
    echo "Installing ImageMagick..."
    sudo apt-get update -qq
    sudo apt-get install -y imagemagick >/dev/null 2>&1
fi

echo "Generating placeholder images for boot splash..."

# Create character placeholder (will be replaced with 3D render)
convert -size 400x300 xc:transparent \
    -fill "#8B00FF" -draw "circle 200,150 200,50" \
    -fill "#FF00FF" -draw "text 50,200 'CHARACTER'" \
    -fill "#FF00FF" -draw "text 50,250 'WITH TATTOOS'" \
    "$BOOT_SPLASH_DIR/character.png"

# Create Glock placeholder
convert -size 200x100 xc:transparent \
    -fill "#333333" -draw "rectangle 20,30 180,80" \
    -fill "#666666" -draw "rectangle 10,50 190,60" \
    -fill "#FFD700" -draw "text 30,70 'GLOCK'" \
    "$BOOT_SPLASH_DIR/glock.png"

# Create welcome text
convert -size 600x100 xc:transparent \
    -fill "#FF00FF" -font Arial-Bold -pointsize 48 \
    -annotate +10+70 "Welcome to Wavy's World" \
    "$BOOT_SPLASH_DIR/text_welcome.png"

# Create Glock's World text
convert -size 500x80 xc:transparent \
    -fill "#FF00FF" -font Arial-Bold -pointsize 36 \
    -annotate +10+55 "Welcome to Glock's World Enjoy" \
    "$BOOT_SPLASH_DIR/text_glock.png"

# Create star sprite
convert -size 20x20 xc:transparent \
    -fill "#FFFFFF" -draw "polygon 10,2 12,8 18,8 13,12 15,18 10,14 5,18 7,12 2,8 8,8" \
    "$BOOT_SPLASH_DIR/star.png"

echo "✓ Placeholder images created in $BOOT_SPLASH_DIR"
echo ""
echo "Note: Replace these with actual 3D renders for best results!"
echo "  - character.png: 3D character with tattoos and Glock"
echo "  - glock.png: Glock with 30-round magazine"
echo "  - text_welcome.png: Stylized 'Welcome to Wavy's World'"
echo "  - text_glock.png: Stylized 'Welcome to Glock's World Enjoy'"
echo "  - star.png: Star sprite for background"

