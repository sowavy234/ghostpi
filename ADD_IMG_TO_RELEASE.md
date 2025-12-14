# How to Add .img File to GitHub Release

## Method 1: Using GitHub Actions (Automatic)

The workflow is configured to create releases with .img files attached.

### Steps:

1. **Go to GitHub Actions:**
   - https://github.com/sowavy234/ghostpi/actions

2. **Run Workflow:**
   - Click "Build GhostPi Images"
   - Click "Run workflow"
   - Choose CM Type: `CM5` (or `CM4`)
   - **Check "Create GitHub Release"** ✅
   - Click "Run workflow"

3. **Wait for Build:**
   - Build takes 10-20 minutes
   - Release will be created automatically
   - .img file will be attached

## Method 2: Manual Upload (If You Have .img File)

### Using GitHub CLI:

```bash
# Install GitHub CLI (if needed)
brew install gh
gh auth login

# Upload to release
cd ~/Downloads/ghostpi
./scripts/attach_img_to_release.sh v1.1.0 GhostPi-CM5-*.img
```

### Using GitHub Web Interface:

1. **Go to Release:**
   - https://github.com/sowavy234/ghostpi/releases

2. **Edit Release:**
   - Click "Edit" on the release
   - Or go to: https://github.com/sowavy234/ghostpi/releases/edit/v1.1.0

3. **Upload File:**
   - Scroll to "Attach binaries"
   - Drag and drop your `.img` file
   - Or click "selecting them"
   - Choose your `GhostPi-CM5-*.img` file

4. **Save:**
   - Click "Update release"

## Method 3: Build First, Then Upload

### Step 1: Build Image

**Option A: GitHub Actions**
- Run workflow (don't check create_release)
- Download artifact
- Extract .img file

**Option B: Docker**
```bash
./scripts/build_mac.sh CM5
```

**Option C: Linux**
```bash
sudo ./scripts/build_linux.sh CM5
```

### Step 2: Upload to Release

```bash
# Using script
./scripts/attach_img_to_release.sh v1.1.0 GhostPi-CM5-*.img

# Or manually via web
# Go to release edit page and upload
```

## Current Release Status

- **v1.1.0**: Tag created, ready for .img upload
- **v1.0.0**: Tag created

## Quick Command

If you have the .img file:

```bash
gh release upload v1.1.0 GhostPi-CM5-*.img --clobber
```

Or use the helper script:

```bash
./scripts/attach_img_to_release.sh v1.1.0 GhostPi-CM5-*.img
```

---

**Easiest**: Use GitHub Actions with "Create GitHub Release" checked! 🚀

