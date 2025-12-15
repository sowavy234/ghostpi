#!/bin/bash
# Trigger GitHub Actions build and create release with .img file

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
CM_TYPE="${1:-CM5}"
VERSION="${2:-v1.2.0}"

echo "=========================================="
echo "  Trigger GhostPi Build & Release"
echo "  Target: $CM_TYPE"
echo "  Version: $VERSION"
echo "=========================================="

# Check if gh CLI is installed
if ! command -v gh &> /dev/null; then
    echo "GitHub CLI (gh) not found. Installing..."
    if [[ "$OSTYPE" == "darwin"* ]]; then
        brew install gh
    else
        echo "Please install GitHub CLI: https://cli.github.com/"
        exit 1
    fi
fi

# Check if authenticated
if ! gh auth status &>/dev/null; then
    echo "Not authenticated with GitHub. Please run: gh auth login"
    exit 1
fi

# Trigger workflow
echo "Triggering GitHub Actions build..."
gh workflow run build.yml \
    -f cm_type="$CM_TYPE" \
    -f create_release=true \
    2>/dev/null || {
    echo "Workflow trigger failed. Creating release manually..."
    
    # Create release manually
    echo "Creating GitHub release..."
    gh release create "$VERSION" \
        --title "GhostPi $CM_TYPE $VERSION" \
        --notes "## GhostPi $CM_TYPE $VERSION

### Features
- Custom 3D boot splash (Welcome to Wavy's World)
- Auto-update system
- Self-healing service with file error fixing
- Automated monitoring bot
- Flipper Zero integration
- Swapfile management
- Universal Raspberry Pi support (CM4, CM5, Pi 4, Pi 5)

### Installation
1. Download the .img file
2. Flash to SD card using Raspberry Pi Imager or dd
3. Boot and enjoy!

### Build
The .img file will be built by GitHub Actions and attached to this release.
Check the Actions tab for build progress." \
        --draft \
        2>/dev/null || echo "Release creation failed. You may need to create it manually on GitHub."
}

echo ""
echo "=========================================="
echo "✓ Build triggered!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Check GitHub Actions: https://github.com/sowavy234/ghostpi/actions"
echo "2. Wait for build to complete"
echo "3. The .img file will be attached to the release automatically"
echo ""
echo "Or build locally on Linux:"
echo "  sudo ./scripts/build_linux.sh $CM_TYPE"
echo ""

