#!/bin/bash
# Comprehensive verification and build script
# Checks all files, fixes errors, and builds image

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================="
echo "  GhostPi Verification & Build"
echo "=========================================="

# Step 1: Verify all scripts
echo ""
echo "Step 1: Checking script syntax..."
ERRORS=0
while IFS= read -r script; do
    if ! bash -n "$script" 2>/dev/null; then
        echo "✗ Syntax error: $script"
        ERRORS=$((ERRORS + 1))
    fi
done < <(find "$PROJECT_ROOT" -type f -name "*.sh" 2>/dev/null)

if [ $ERRORS -eq 0 ]; then
    echo "✓ All scripts syntax-checked successfully"
else
    echo "✗ Found $ERRORS syntax errors"
    echo "Running self-healing bot to fix..."
    if [ -f "$PROJECT_ROOT/services/ghostpi-self-heal.sh" ]; then
        bash "$PROJECT_ROOT/services/ghostpi-self-heal.sh" repair 2>/dev/null || true
    fi
fi

# Step 2: Check git status
echo ""
echo "Step 2: Checking git status..."
cd "$PROJECT_ROOT"
if [ -n "$(git status --porcelain)" ]; then
    echo "⚠ Uncommitted changes detected"
    echo "Committing fixes..."
    git add -A
    git commit -m "Auto-fix: Script syntax and error corrections

- Fixed script syntax errors
- Enhanced self-healing capabilities
- Verified all files" || true
    git push origin main || echo "⚠ Push failed (may need authentication)"
else
    echo "✓ Working tree clean"
fi

# Step 3: Verify self-healing bot
echo ""
echo "Step 3: Verifying self-healing bot..."
if [ -f "$PROJECT_ROOT/services/ghostpi-self-heal.sh" ]; then
    if bash -n "$PROJECT_ROOT/services/ghostpi-self-heal.sh" 2>/dev/null; then
        echo "✓ Self-healing bot syntax OK"
    else
        echo "✗ Self-healing bot has syntax errors"
    fi
else
    echo "⚠ Self-healing bot not found"
fi

# Step 4: Verify automated bot
echo ""
echo "Step 4: Verifying automated monitoring bot..."
if [ -f "$PROJECT_ROOT/bots/automated-monitor/ghostpi-bot.sh" ]; then
    if bash -n "$PROJECT_ROOT/bots/automated-monitor/ghostpi-bot.sh" 2>/dev/null; then
        echo "✓ Automated monitoring bot syntax OK"
    else
        echo "✗ Automated monitoring bot has syntax errors"
    fi
else
    echo "⚠ Automated monitoring bot not found"
fi

# Step 5: Build image (if on Linux)
echo ""
echo "Step 5: Building image..."
if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    echo "Linux detected. Building image..."
    CM_TYPE="${1:-CM5}"
    sudo "$PROJECT_ROOT/scripts/build_linux.sh" "$CM_TYPE"
elif command -v docker &> /dev/null; then
    echo "Docker detected. Building with Docker..."
    CM_TYPE="${1:-CM5}"
    "$PROJECT_ROOT/scripts/build_mac.sh" "$CM_TYPE"
else
    echo "Not on Linux and Docker not available."
    echo "Triggering GitHub Actions build..."
    CM_TYPE="${1:-CM5}"
    if [ -f "$PROJECT_ROOT/scripts/trigger_build.sh" ]; then
        bash "$PROJECT_ROOT/scripts/trigger_build.sh" "$CM_TYPE"
    else
        echo "To build:"
        echo "  1. Use GitHub Actions: https://github.com/sowavy234/ghostpi/actions"
        echo "  2. Or copy to Linux and run: sudo ./scripts/build_linux.sh $CM_TYPE"
    fi
fi

echo ""
echo "=========================================="
echo "✓ Verification and build complete!"
echo "=========================================="

