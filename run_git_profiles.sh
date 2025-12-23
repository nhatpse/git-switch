#!/bin/bash

# Git Profile Manager - Direct Run Script
# Version: 2.3
# Run directly from GitHub without installation

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
    echo "║               Git Profile Manager v2.3                      ║"
    echo "║               Direct Run from GitHub                        ║"
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

# Check if Python 3 is installed
check_python() {
    if command -v python3 &> /dev/null; then
        print_success "Python 3 found"
        return 0
    elif command -v python &> /dev/null; then
        # Check if python is actually Python 3
        if python -c "import sys; exit(0 if sys.version_info >= (3,6) else 1)" 2>/dev/null; then
            print_success "Python 3 found (as 'python')"
            PYTHON_CMD="python"
            return 0
        fi
    fi
    
    print_error "Python 3.6+ is required but not found"
    print_info "Please install Python 3: https://python.org"
    exit 1
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

# Check if ssh-keygen is available
check_ssh() {
    if command -v ssh-keygen &> /dev/null; then
        print_success "SSH tools found"
        return 0
    else
        print_warning "ssh-keygen not found"
        print_info "Some features may not work. Please install OpenSSH client."
        return 1
    fi
}

# Download and run the Git Profile Manager
run_git_profiles() {
    print_info "Downloading Git Profile Manager..."
    
    # Create temporary directory
    TEMP_DIR=$(mktemp -d)
    cd "$TEMP_DIR"
    
    # Set Python command
    PYTHON_CMD=${PYTHON_CMD:-python3}
    
    # Download main files
    print_info "Downloading git_profile_manager.py..."
    if ! curl -fsSL "https://raw.githubusercontent.com/nhatpse/git-switch/main/git_profile_manager.py" -o git_profile_manager.py; then
        print_error "Failed to download git_profile_manager.py"
        cleanup_and_exit 1
    fi
    
    print_info "Downloading git_profiles.py..."
    if ! curl -fsSL "https://raw.githubusercontent.com/nhatpse/git-switch/main/git_profiles.py" -o git_profiles.py; then
        print_error "Failed to download git_profiles.py"
        cleanup_and_exit 1
    fi
    
    print_success "Files downloaded successfully"
    
    # Make executable
    chmod +x git_profiles.py
    
    print_info "Starting Git Profile Manager..."
    echo -e "${CYAN}${BOLD}Note: This is running from temporary directory. No files will be installed.${NC}"
    echo -e "${YELLOW}Your profiles and SSH keys will be saved to your home directory as usual.${NC}"
    echo ""
    
    # Run the application
    $PYTHON_CMD git_profiles.py
    
    # Cleanup
    cleanup_and_exit 0
}

# Cleanup function
cleanup_and_exit() {
    local exit_code=${1:-0}
    if [[ -n "$TEMP_DIR" && -d "$TEMP_DIR" ]]; then
        cd /
        rm -rf "$TEMP_DIR"
        print_info "Temporary files cleaned up"
    fi
    exit $exit_code
}

# Handle interrupts
trap 'cleanup_and_exit 130' INT TERM

# Show help
show_help() {
    echo -e "${BOLD}Git Profile Manager - Direct Run Script${NC}"
    echo ""
    echo "This script downloads and runs Git Profile Manager directly from GitHub"
    echo "without installing it permanently on your system."
    echo ""
    echo -e "${BOLD}Usage:${NC}"
    echo "  bash <(curl -fsSL https://raw.githubusercontent.com/nhatpse/git-switch/main/run_git_profiles.sh)"
    echo ""
    echo -e "${BOLD}Options:${NC}"
    echo "  -h, --help     Show this help message"
    echo "  -i, --install  Run the installer instead"
    echo ""
    echo -e "${BOLD}Features:${NC}"
    echo "  • No permanent installation required"
    echo "  • Automatic cleanup after use"
    echo "  • Cross-platform support (Linux, macOS, Windows with Git Bash)"
    echo "  • All profile data saved to your home directory"
    echo ""
    echo -e "${BOLD}Requirements:${NC}"
    echo "  • Python 3.6+"
    echo "  • Git"
    echo "  • Internet connection"
    echo "  • ssh-keygen (for SSH key generation)"
}

# Check for help flag
if [[ "$1" == "-h" || "$1" == "--help" ]]; then
    show_help
    exit 0
fi

# Check for install flag
if [[ "$1" == "-i" || "$1" == "--install" ]]; then
    print_info "Running installer instead..."
    curl -fsSL https://raw.githubusercontent.com/nhatpse/git-switch/main/install.sh | bash
    exit $?
fi

# Main execution
main() {
    print_header
    
    print_info "Checking system requirements..."
    
    # Check requirements
    check_python
    check_git
    check_ssh
    
    echo ""
    print_info "All requirements met! Starting direct run..."
    echo ""
    
    # Download and run
    run_git_profiles
}

# Run main function
main "$@" # Cache update Sat Jul 12 11:28:37 +07 2025
