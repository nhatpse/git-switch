#!/bin/bash

# Git Profile Manager Installer
# Version: 2.0

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

print_header() {
    echo -e "${CYAN}"
    echo "╔═══════════════════════════════════════════════════════════╗"
    echo "║                Git Profile Manager v2.0                   ║"
    echo "║                    Installer Script                       ║"
    echo "╚═══════════════════════════════════════════════════════════╝"
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

# Check if Python 3 is installed
check_python() {
    if command -v python3 &> /dev/null; then
        print_success "Python 3 found"
        return 0
    else
        print_error "Python 3 is required but not installed"
        print_info "Please install Python 3 first: https://python.org"
        exit 1
    fi
}

# Check if Git is installed
check_git() {
    if command -v git &> /dev/null; then
        print_success "Git found"
        return 0
    else
        print_error "Git is required but not installed"
        print_info "Please install Git first: https://git-scm.com"
        exit 1
    fi
}

# Download files
download_files() {
    print_info "Downloading Git Profile Manager..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Download main files
    curl -fsSL "https://raw.githubusercontent.com/nhatpse/git-switch/main/git_profile_manager.py" -o git_profile_manager.py
curl -fsSL "https://raw.githubusercontent.com/nhatpse/git-switch/main/git_profiles.py" -o git_profiles.py
    
    print_success "Files downloaded successfully"
    echo "$TEMP_DIR"
}

# Install files
install_files() {
    local temp_dir="$1"
    local install_dir="$HOME/.git-profile-manager"
    
    print_info "Installing to $install_dir..."
    
    # Create installation directory
    mkdir -p "$install_dir"
    
    # Copy files
    cp "$temp_dir/git_profile_manager.py" "$install_dir/"
    cp "$temp_dir/git_profiles.py" "$install_dir/"
    
    # Make executable
    chmod +x "$install_dir/git_profiles.py"
    
    print_success "Files installed"
}

# Setup PATH and aliases
setup_commands() {
    local install_dir="$HOME/.git-profile-manager"
    
    # Create symlinks
    if [[ ":$PATH:" == *":$HOME/.local/bin:"* ]]; then
        BIN_DIR="$HOME/.local/bin"
    else
        BIN_DIR="/usr/local/bin"
    fi
    
    # Ensure bin directory exists
    mkdir -p "$BIN_DIR" 2>/dev/null || true
    
    # Create symlinks (try local first, then global)
    if ln -sf "$install_dir/git_profiles.py" "$BIN_DIR/git-profile" 2>/dev/null; then
        print_success "Command 'git-profile' installed to $BIN_DIR"
    elif sudo ln -sf "$install_dir/git_profiles.py" "/usr/local/bin/git-profile" 2>/dev/null; then
        print_success "Command 'git-profile' installed to /usr/local/bin (with sudo)"
    else
        print_warning "Could not create symlink. You can run the program with:"
        print_info "python3 $install_dir/git_profiles.py"
    fi
    
    # Create update command
    cat > "$install_dir/update.sh" << 'EOF'
#!/bin/bash
echo "🔄 Updating Git Profile Manager..."
curl -fsSL https://raw.githubusercontent.com/nhatpse/git-switch/main/install.sh | bash
EOF
    chmod +x "$install_dir/update.sh"
    
    if ln -sf "$install_dir/update.sh" "$BIN_DIR/git-profile-update" 2>/dev/null; then
        print_success "Update command 'git-profile-update' installed"
    elif sudo ln -sf "$install_dir/update.sh" "/usr/local/bin/git-profile-update" 2>/dev/null; then
        print_success "Update command 'git-profile-update' installed (with sudo)"
    fi
}

# Cleanup
cleanup() {
    local temp_dir="$1"
    rm -rf "$temp_dir"
    print_info "Cleanup completed"
}

# Main installation process
main() {
    print_header
    
    print_info "Starting installation..."
    
    # Check requirements
    check_python
    check_git
    
    # Download and install
    TEMP_DIR=$(download_files)
    install_files "$TEMP_DIR"
    setup_commands
    cleanup "$TEMP_DIR"
    
    print_success "Installation completed! 🎉"
    echo
    print_info "Usage:"
    echo "  git-profile              # Run the profile manager"
    echo "  git-profile-update       # Update to latest version"
    echo
    print_info "Or run directly with:"
    echo "  python3 ~/.git-profile-manager/git_profiles.py"
    echo
    print_warning "Note: You may need to restart your terminal or run 'source ~/.bashrc' for commands to work"
}

# Run main function
main "$@" 