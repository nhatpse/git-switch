# Homebrew Setup Guide

This guide explains how to set up and maintain the Homebrew tap for Git Profile Manager.

## 🍺 Quick Installation for Users

```bash
brew tap nhatpse/gitsw
brew install gitsw
```

## 🔧 Developer Setup (First Time)

### Prerequisites

1. **GitHub CLI** (for repository management)
   ```bash
   brew install gh
   gh auth login
   ```

2. **Git and GitHub account** with appropriate permissions

### Step 1: Run the Setup Script

```bash
./setup-homebrew-tap.sh
```

This script will:
- Create the `homebrew-gitsw` repository
- Set up the Formula directory structure
- Copy the formula file
- Create initial documentation

### Step 2: Create a GitHub Release

1. Create a new release on GitHub:
   ```bash
   gh release create v2.3.0 --title "v2.3.0" --notes "Release notes here"
   ```

2. Get the SHA256 hash of the release tarball:
   ```bash
   curl -sL https://github.com/nhatpse/git-switch/archive/refs/tags/v2.3.0.tar.gz | shasum -a 256
   ```

### Step 3: Update the Formula

1. Navigate to the tap repository:
   ```bash
   cd homebrew-gitsw
   ```

2. Edit `Formula/gitsw.rb` and replace `REPLACE_WITH_ACTUAL_SHA256` with the actual SHA256 hash

3. Update the version if needed

4. Commit and push:
   ```bash
   git add Formula/gitsw.rb
   git commit -m "Update gitsw formula with correct SHA256"
   git push origin main
   ```

## 🔄 Updating the Formula (New Releases)

### For each new release:

1. **Create a new release** on the main repository
2. **Get the new SHA256**:
   ```bash
   curl -sL https://github.com/nhatpse/git-switch/archive/refs/tags/vX.Y.Z.tar.gz | shasum -a 256
   ```

3. **Update the formula**:
   ```ruby
   class Gitsw < Formula
     desc "Git Profile Manager - Switch between multiple GitHub accounts seamlessly"
     homepage "https://github.com/nhatpse/git-switch"
     url "https://github.com/nhatpse/git-switch/archive/refs/tags/vX.Y.Z.tar.gz"
     sha256 "NEW_SHA256_HERE"
     license "MIT"
     version "X.Y.Z"
     # ... rest of formula
   end
   ```

4. **Test the formula locally**:
   ```bash
   brew install --build-from-source ./Formula/gitsw.rb
   ```

5. **Commit and push**:
   ```bash
   git add Formula/gitsw.rb
   git commit -m "Update gitsw to vX.Y.Z"
   git push origin main
   ```

## 📋 Formula Structure

The `gitsw.rb` formula includes:

- **Basic metadata**: Description, homepage, license
- **Dependencies**: Python 3.8+, Git
- **Installation logic**: 
  - Installs to `libexec`
  - Creates `gitsw` executable
  - Creates `git-profile` symlink
  - Creates `git-profile-update` command
- **Test**: Basic functionality test
- **Caveats**: Usage instructions for users

## 🧪 Testing

### Local Testing

```bash
# Install from local formula
brew install --build-from-source ./Formula/gitsw.rb

# Test the installation
gitsw --help
git-profile --help

# Uninstall for testing
brew uninstall gitsw
```

### Formula Validation

```bash
# Check formula syntax
brew audit --strict Formula/gitsw.rb

# Test formula
brew test gitsw
```

## 📦 Directory Structure

```
homebrew-gitsw/
├── Formula/
│   └── gitsw.rb          # Main formula file
├── README.md             # Tap documentation
└── .github/              # Optional: GitHub workflows
```

## 🔍 Troubleshooting

### Common Issues

1. **SHA256 Mismatch**
   - Always get SHA256 from the actual GitHub release tarball
   - Use: `curl -sL <tarball_url> | shasum -a 256`

2. **Formula Syntax Errors**
   - Test with: `brew audit --strict Formula/gitsw.rb`
   - Validate Ruby syntax

3. **Installation Failures**
   - Check Python path in formula
   - Verify all dependencies are available

### Useful Commands

```bash
# Check formula info
brew info gitsw

# Check installation location
brew --prefix gitsw

# View installation logs
brew install --verbose gitsw

# Uninstall completely
brew uninstall --force gitsw
brew untap nhatpse/gitsw
```

## 🚀 Automation Ideas

Consider creating GitHub Actions workflows for:
- Automatic formula updates when new releases are created
- Formula testing and validation
- Automated SHA256 generation

## 📞 Support

For issues with the Homebrew formula:
1. Check the [main repository](https://github.com/nhatpse/git-switch)
2. Open an issue in the tap repository
3. Verify you're using the latest formula version

---

**Note**: This tap is maintained separately from the main Git Profile Manager repository. Always ensure the formula is updated when new versions are released. 