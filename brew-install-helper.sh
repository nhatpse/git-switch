#!/bin/bash

# Git Profile Manager - Homebrew Installation Helper
# Automates the installation process via Homebrew

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
    echo "║         Git Profile Manager - Homebrew Installer           ║"
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

# Check if Homebrew is installed
check_homebrew() {
    if command -v brew &> /dev/null; then
        print_success "Homebrew found"
        return 0
    else
        print_error "Homebrew not found!"
        print_info "Installing Homebrew first..."
        
        # Install Homebrew
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        
        # Add to PATH for current session
        if [[ "$OSTYPE" == "linux-gnu"* ]]; then
            eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
        elif [[ "$OSTYPE" == "darwin"* ]]; then
            eval "$(/opt/homebrew/bin/brew shellenv)"
        fi
        
        if command -v brew &> /dev/null; then
            print_success "Homebrew installed successfully"
        else
            print_error "Failed to install Homebrew"
            exit 1
        fi
    fi
}

# Install Git Profile Manager
install_gitsw() {
    print_info "Adding Git Profile Manager tap..."
    
    if brew tap nhatpse/gitsw; then
        print_success "Tap added successfully"
    else
        print_error "Failed to add tap"
        exit 1
    fi
    
    print_info "Installing Git Profile Manager..."
    
    if brew install gitsw; then
        print_success "Git Profile Manager installed successfully!"
    else
        print_error "Failed to install Git Profile Manager"
        exit 1
    fi
}

# Show usage instructions
show_usage() {
    echo
    print_info "Installation completed! Here's how to use Git Profile Manager:"
    echo
    echo -e "  ${CYAN}gitsw${NC}                   # Launch Git Profile Manager"
    echo -e "  ${CYAN}git-profile${NC}            # Alternative command name"
    echo -e "  ${CYAN}git-profile-update${NC}     # Update to latest version"
    echo
    print_info "To get started, run: ${CYAN}gitsw${NC}"
    echo
    print_info "For help and documentation, visit:"
    echo -e "  ${CYAN}https://github.com/nhatpse/git-switch${NC}"
}

# Check if already installed
check_existing_installation() {
    if command -v gitsw &> /dev/null; then
        print_warning "Git Profile Manager is already installed!"
        echo -e "  Current version: ${CYAN}$(gitsw --version 2>/dev/null || echo "unknown")${NC}"
        echo
        read -p "Do you want to update to the latest version? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            print_info "Updating Git Profile Manager..."
            brew upgrade gitsw
            print_success "Update completed!"
            return 1
        else
            print_info "Installation cancelled"
            return 1
        fi
    fi
    return 0
}

# Main installation function
main() {
    print_header
    
    # Check OS compatibility
    if [[ "$OSTYPE" != "darwin"* ]] && [[ "$OSTYPE" != "linux-gnu"* ]]; then
        print_error "This installer only supports macOS and Linux"
        print_info "For Windows, please use the PowerShell script or manual installation"
        exit 1
    fi
    
    # Check if already installed
    if ! check_existing_installation; then
        exit 0
    fi
    
    # Check and install Homebrew if needed
    check_homebrew
    
    # Install Git Profile Manager
    install_gitsw
    
    # Show usage instructions
    show_usage
    
    print_success "🎉 Installation completed successfully!"
}

# Run main function
main "$@" 