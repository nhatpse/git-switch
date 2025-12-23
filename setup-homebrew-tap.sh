#!/bin/bash

# Setup Homebrew Tap for Git Profile Manager
# This script helps setup a Homebrew tap repository

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
BOLD='\033[1m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}${BOLD}"
    echo "╔══════════════════════════════════════════════════════════════╗"
    echo "║           Git Profile Manager - Homebrew Tap Setup          ║"
    echo "╚══════════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Check if GitHub CLI is available
check_gh_cli() {
    if command -v gh &> /dev/null; then
        print_success "GitHub CLI found"
        return 0
    else
        print_warning "GitHub CLI not found. Please install it first:"
        print_info "  brew install gh"
        print_info "  Then run: gh auth login"
        return 1
    fi
}

# Create Homebrew tap repository
create_tap_repository() {
    local repo_name="homebrew-gitsw"
    local username=$(gh api user --jq '.login' 2>/dev/null || echo "your-username")
    
    print_info "Creating Homebrew tap repository: ${username}/${repo_name}"
    
    # Create repository
    if gh repo create "${repo_name}" --public --description "Homebrew tap for Git Profile Manager (gitsw)" --clone; then
        print_success "Repository created successfully"
    else
        print_error "Failed to create repository. It might already exist."
        print_info "Cloning existing repository..."
        git clone "https://github.com/${username}/${repo_name}.git" || exit 1
    fi
    
    cd "${repo_name}"
    
    # Create Formula directory
    mkdir -p Formula
    
    # Copy formula file
    if [ -f "../gitsw.rb" ]; then
        cp "../gitsw.rb" "Formula/"
        print_success "Formula copied to Formula/gitsw.rb"
    else
        print_error "gitsw.rb not found in parent directory"
        exit 1
    fi
    
    # Create README for tap
    cat > README.md << 'EOF'
# Git Profile Manager Homebrew Tap

This is a Homebrew tap for [Git Profile Manager](https://github.com/nhatpse/git-switch).

## Installation

```bash
brew tap nhatpse/gitsw
brew install gitsw
```

## Usage

```bash
gitsw                   # Launch Git Profile Manager
git-profile            # Alternative command
git-profile-update     # Update to latest version
```

## About

Git Profile Manager is a powerful command-line tool for managing and switching between multiple GitHub accounts seamlessly.

For more information, visit the [main repository](https://github.com/nhatpse/git-switch).
EOF

    # Commit and push
    git add .
    git commit -m "Initial tap setup with gitsw formula" || true
    git push origin main || git push origin master
    
    print_success "Homebrew tap setup completed!"
    print_info "Users can now install with:"
    echo -e "  ${CYAN}brew tap ${username}/gitsw${NC}"
    echo -e "  ${CYAN}brew install gitsw${NC}"
    
    cd ..
}

# Update formula with correct SHA256
update_formula_sha() {
    print_info "To complete the setup, you need to:"
    echo -e "  ${YELLOW}1. Create a release on GitHub (v2.3.0)${NC}"
    echo -e "  ${YELLOW}2. Get the SHA256 of the release tarball:${NC}"
    echo -e "     ${CYAN}curl -sL https://github.com/nhatpse/git-switch/archive/refs/tags/v2.3.0.tar.gz | shasum -a 256${NC}"
    echo -e "  ${YELLOW}3. Update the sha256 in Formula/gitsw.rb${NC}"
    echo -e "  ${YELLOW}4. Commit and push the changes${NC}"
}

main() {
    print_header
    
    # Check prerequisites
    if ! check_gh_cli; then
        exit 1
    fi
    
    # Create tap repository
    create_tap_repository
    
    # Show next steps
    update_formula_sha
    
    print_success "Setup completed! 🎉"
}

# Run main function
main "$@" 