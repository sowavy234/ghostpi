#!/bin/bash
# Setup script for GitHub repository

set -e

REPO_NAME="ghostpi"
GITHUB_USER="${GITHUB_USER:-yourusername}"

echo "=========================================="
echo "  GitHub Repository Setup"
echo "=========================================="
echo ""

# Check if git is initialized
if [ ! -d .git ]; then
    echo "Initializing git repository..."
    git init
    git add .
    git commit -m "Initial commit: GhostPi with Wavy's World boot splash"
fi

# Check current remote
CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")

if [ -n "$CURRENT_REMOTE" ]; then
    echo "Current remote: $CURRENT_REMOTE"
    read -p "Do you want to update it? (y/n) " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git remote remove origin
    else
        echo "Keeping existing remote."
        exit 0
    fi
fi

echo ""
echo "Choose an option:"
echo "1. Create new repository on GitHub (requires GitHub CLI)"
echo "2. Use existing repository URL"
echo "3. Skip remote setup (you'll do it manually)"
echo ""
read -p "Enter choice (1-3): " choice

case $choice in
    1)
        # Check if GitHub CLI is installed
        if command -v gh &> /dev/null; then
            echo "Creating repository on GitHub..."
            gh repo create "$REPO_NAME" --public --source=. --remote=origin --push || {
                echo "Failed to create repository. You may need to:"
                echo "  1. Install GitHub CLI: brew install gh"
                echo "  2. Authenticate: gh auth login"
                echo "  3. Or create repository manually on GitHub.com"
                exit 1
            }
            echo "✓ Repository created and pushed!"
        else
            echo "GitHub CLI not found. Install it with:"
            echo "  brew install gh"
            echo "  gh auth login"
            echo ""
            echo "Or create the repository manually:"
            echo "  1. Go to https://github.com/new"
            echo "  2. Create repository named: $REPO_NAME"
            echo "  3. Run: git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
            echo "  4. Run: git push -u origin main"
        fi
        ;;
    2)
        read -p "Enter your GitHub username: " GITHUB_USER
        read -p "Enter repository name (default: $REPO_NAME): " REPO_NAME_INPUT
        REPO_NAME="${REPO_NAME_INPUT:-$REPO_NAME}"
        
        echo ""
        echo "Adding remote: https://github.com/$GITHUB_USER/$REPO_NAME.git"
        git remote add origin "https://github.com/$GITHUB_USER/$REPO_NAME.git" 2>/dev/null || \
        git remote set-url origin "https://github.com/$GITHUB_USER/$REPO_NAME.git"
        
        echo ""
        echo "Pushing to GitHub..."
        git push -u origin main || {
            echo ""
            echo "Push failed. Make sure:"
            echo "  1. Repository exists at: https://github.com/$GITHUB_USER/$REPO_NAME"
            echo "  2. You have push access"
            echo "  3. You're authenticated (git config --global user.name and user.email)"
            echo ""
            echo "To create the repository:"
            echo "  Go to: https://github.com/new"
            echo "  Name: $REPO_NAME"
            echo "  Then run: git push -u origin main"
        }
        ;;
    3)
        echo "Skipping remote setup."
        echo ""
        echo "To set up manually:"
        echo "  1. Create repository on GitHub: https://github.com/new"
        echo "  2. Run: git remote add origin https://github.com/YOUR_USERNAME/$REPO_NAME.git"
        echo "  3. Run: git push -u origin main"
        ;;
    *)
        echo "Invalid choice"
        exit 1
        ;;
esac

echo ""
echo "=========================================="
echo "Setup complete!"
echo "=========================================="

