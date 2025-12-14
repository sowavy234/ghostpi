#!/bin/bash
# Script to attach .img file to existing GitHub release
# Usage: ./attach_img_to_release.sh <release_tag> <image_file>

set -e

RELEASE_TAG="${1:-v1.1.0}"
IMAGE_FILE="${2}"

if [ -z "$IMAGE_FILE" ]; then
    echo "Usage: $0 <release_tag> <image_file>"
    echo "Example: $0 v1.1.0 GhostPi-CM5-20241213.img"
    exit 1
fi

if [ ! -f "$IMAGE_FILE" ]; then
    echo "Error: Image file not found: $IMAGE_FILE"
    exit 1
fi

# Check if GitHub CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI not found. Install with: brew install gh"
    echo ""
    echo "Or upload manually:"
    echo "1. Go to: https://github.com/sowavy234/ghostpi/releases/edit/$RELEASE_TAG"
    echo "2. Drag and drop $IMAGE_FILE"
    echo "3. Click 'Update release'"
    exit 1
fi

# Upload to release
echo "Uploading $IMAGE_FILE to release $RELEASE_TAG..."
gh release upload "$RELEASE_TAG" "$IMAGE_FILE" --clobber

echo "✅ Image uploaded to release $RELEASE_TAG"
echo "View at: https://github.com/sowavy234/ghostpi/releases/tag/$RELEASE_TAG"

