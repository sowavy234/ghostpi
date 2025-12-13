# GitHub Setup Guide

## Quick Setup

Your code is already committed! Now you just need to create the GitHub repository and push.

### Option 1: Use Setup Script (Easiest)

```bash
cd ~/Downloads/ghostpi
./setup_github.sh
```

This will guide you through:
- Creating the repository (if you have GitHub CLI)
- Setting up the remote URL
- Pushing your code

### Option 2: Manual Setup

#### Step 1: Create Repository on GitHub

1. Go to: https://github.com/new
2. Repository name: `ghostpi`
3. Description: "GhostPi - Wavy's World Bootable Raspberry Pi Image"
4. Choose Public or Private
5. **Don't** initialize with README (you already have one)
6. Click "Create repository"

#### Step 2: Update Remote and Push

```bash
cd ~/Downloads/Downloads/ghostpi

# Set your GitHub username
GITHUB_USER="your_github_username"

# Update remote URL
git remote set-url origin "https://github.com/$GITHUB_USER/ghostpi.git"

# Or if remote doesn't exist:
git remote add origin "https://github.com/$GITHUB_USER/ghostpi.git"

# Push to GitHub
git push -u origin main
```

### Option 3: Using GitHub CLI

If you have GitHub CLI installed:

```bash
# Install GitHub CLI (if needed)
brew install gh

# Authenticate
gh auth login

# Create repository and push
cd ~/Downloads/ghostpi
gh repo create ghostpi --public --source=. --remote=origin --push
```

## Verify Push

After pushing, verify:

```bash
# Check remote
git remote -v

# Check status
git status

# View commits
git log --oneline
```

## Update README for Your Repository

After creating the repository, update the README.md to replace:
- `yourusername` with your actual GitHub username
- Any placeholder URLs

## Next Steps

1. ✅ Code is committed locally
2. ⏳ Create GitHub repository
3. ⏳ Push to GitHub
4. ⏳ Enable GitHub Actions (if using CI/CD)
5. ⏳ Add topics/tags to repository

## Repository Settings

After creating, consider:
- Adding description: "Custom Raspberry Pi image with 3D boot splash and pentesting tools"
- Adding topics: `raspberry-pi`, `boot-splash`, `plymouth`, `pentesting`, `cm4`, `cm5`
- Enabling GitHub Actions
- Setting up branch protection (optional)

## Troubleshooting

### "Repository not found"
- Make sure the repository exists on GitHub
- Check the URL is correct
- Verify you have access

### "Authentication failed"
```bash
# Set git credentials
git config --global user.name "Your Name"
git config --global user.email "your.email@example.com"

# For HTTPS, you may need a Personal Access Token
# Go to: https://github.com/settings/tokens
```

### "Permission denied"
- Check you have write access to the repository
- Verify your GitHub authentication

---

**Your code is ready! Just create the repository and push!** 🚀

