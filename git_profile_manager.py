#!/usr/bin/env python3
"""
Git Profile Manager - Enhanced Version
======================================
A powerful tool to manage multiple Git profiles with SSH key automation.
Cross-platform support: Windows, macOS, Linux
"""

import json
import os
import platform
import re
import shutil
import subprocess
import sys
import webbrowser
from getpass import getpass
from pathlib import Path
from typing import Any, Dict, List, Optional, Tuple, Union

# Constants
CONFIG_FILE = Path.home() / '.git_profiles.json'
SSH_DIR = Path.home() / '.ssh'
GITHUB_SSH_URL = 'https://github.com/settings/ssh/new'
GITHUB_HOST_KEY = 'github.com'

# Validation patterns
EMAIL_PATTERN = re.compile(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
USERNAME_PATTERN = re.compile(r'^[a-zA-Z0-9]([a-zA-Z0-9-]*[a-zA-Z0-9])?$')

class Colors:
    """ANSI color codes for terminal output with Windows support."""
    
    def __init__(self) -> None:
        self._setup_colors()
    
    def _setup_colors(self) -> None:
        """Setup color codes based on platform support."""
        if platform.system() == "Windows":
            self._enable_windows_colors()
        else:
            self._enable_ansi_colors()
    
    def _enable_windows_colors(self) -> None:
        """Enable ANSI colors on Windows."""
        try:
            import ctypes
            kernel32 = ctypes.windll.kernel32
            kernel32.SetConsoleMode(kernel32.GetStdHandle(-11), 7)
            self._enable_ansi_colors()
        except (ImportError, AttributeError):
            self._disable_colors()
    
    def _enable_ansi_colors(self) -> None:
        """Enable ANSI color codes."""
        self.HEADER = '\033[95m'
        self.BLUE = '\033[94m'
        self.CYAN = '\033[96m'
        self.GREEN = '\033[92m'
        self.YELLOW = '\033[93m'
        self.RED = '\033[91m'
        self.ENDC = '\033[0m'
        self.BOLD = '\033[1m'
        self.UNDERLINE = '\033[4m'
    
    def _disable_colors(self) -> None:
        """Disable colors for compatibility."""
        self.HEADER = ''
        self.BLUE = ''
        self.CYAN = ''
        self.GREEN = ''
        self.YELLOW = ''
        self.RED = ''
        self.ENDC = ''
        self.BOLD = ''
        self.UNDERLINE = ''

# Global colors instance
colors = Colors()

class GitProfileManager:
    """Main class for managing Git profiles with cross-platform support."""
    
    def __init__(self) -> None:
        """Initialize the Git Profile Manager."""
        self.platform = platform.system()
        self._setup_environment()
    
    def _setup_environment(self) -> None:
        """Setup required environment and check dependencies."""
        self._ensure_directories()
        self._check_dependencies()
    
    def _check_dependencies(self) -> None:
        """Check if required tools are available."""
        required_tools = ['git', 'ssh-keygen']
        missing_tools = [tool for tool in required_tools if not shutil.which(tool)]
        
        if missing_tools:
            self._handle_missing_dependencies(missing_tools)
    
    def _handle_missing_dependencies(self, missing_tools: List[str]) -> None:
        """Handle missing dependencies with platform-specific advice."""
        for tool in missing_tools:
            self.print_error(f"Required tool '{tool}' not found!")
            if tool == 'git':
                self.print_info("Please install Git: https://git-scm.com/downloads")
            elif tool == 'ssh-keygen':
                self._print_ssh_install_advice()
        sys.exit(1)
    
    def _print_ssh_install_advice(self) -> None:
        """Print SSH installation advice based on platform."""
        if self.platform == "Windows":
            self.print_info("Please install OpenSSH client (Windows 10+) or Git for Windows")
        else:
            self.print_info("Please install OpenSSH client")
    
    def _ensure_directories(self) -> None:
        """Ensure required directories exist with proper permissions."""
        if not SSH_DIR.exists():
            SSH_DIR.mkdir(mode=0o700, parents=True)
        elif self.platform != "Windows":
            SSH_DIR.chmod(0o700)
    
    def load_profiles(self) -> Dict[str, Any]:
        """Load profiles from config file."""
        if not CONFIG_FILE.exists():
            return {}
        
        try:
            with open(CONFIG_FILE, 'r', encoding='utf-8') as f:
                return json.load(f)
        except (json.JSONDecodeError, IOError) as e:
            self.print_error(f"Error loading profiles: {e}")
            return {}
    
    def save_profiles(self, profiles: Dict[str, Any]) -> bool:
        """Save profiles to config file."""
        try:
            CONFIG_FILE.parent.mkdir(parents=True, exist_ok=True)
            with open(CONFIG_FILE, 'w', encoding='utf-8') as f:
                json.dump(profiles, f, indent=2, ensure_ascii=False)
            return True
        except IOError as e:
            self.print_error(f"Error saving profiles: {e}")
            return False
    
    def get_current_git_config(self) -> Optional[Dict[str, str]]:
        """Get current Git global configuration."""
        try:
            name = self._get_git_config_value('user.name')
            email = self._get_git_config_value('user.email')
            return {'name': name, 'email': email} if name and email else None
        except (subprocess.CalledProcessError, FileNotFoundError):
            return None
    
    def _get_git_config_value(self, key: str) -> Optional[str]:
        """Get a specific Git config value."""
        try:
            result = subprocess.run(
                ['git', 'config', '--global', key],
                capture_output=True,
                text=True,
                check=True
            )
            return result.stdout.strip()
        except subprocess.CalledProcessError:
            return None
    
    def set_git_config(self, name: str, email: str) -> bool:
        """Set Git global configuration."""
        try:
            subprocess.run(['git', 'config', '--global', 'user.name', name], check=True)
            subprocess.run(['git', 'config', '--global', 'user.email', email], check=True)
            return True
        except (subprocess.CalledProcessError, FileNotFoundError) as e:
            self.print_error(f"Error setting Git config: {e}")
            return False
    
    def validate_email(self, email: str) -> bool:
        """Validate email format."""
        return bool(EMAIL_PATTERN.match(email))
    
    def validate_username(self, username: str) -> bool:
        """Validate username format."""
        return (bool(username) and 
                len(username) <= 39 and 
                bool(USERNAME_PATTERN.match(username)))
    
    def generate_ssh_key(self, email: str, username: str, use_passphrase: bool = True) -> Optional[str]:
        """Generate SSH key for the profile with Windows support."""
        key_file = SSH_DIR / f"id_rsa_{username}"
        
        if key_file.exists():
            self.print_warning(f"SSH key for profile '{username}' already exists!")
            return str(key_file)
        
        self.print_info(f"Generating SSH key for profile '{username}'...")
        
        passphrase = self._get_passphrase(use_passphrase)
        return self._create_ssh_key(key_file, email, passphrase, username)
    
    def _get_passphrase(self, use_passphrase: bool) -> str:
        """Get passphrase for SSH key."""
        if not use_passphrase:
            return ""
        
        self.print_info("For security, we recommend using a passphrase for your SSH key.")
        choice = input(f"{colors.YELLOW}Use passphrase? (y/N): {colors.ENDC}").strip().lower()
        
        if choice == 'y':
            return getpass(f"{colors.CYAN}Enter passphrase (leave empty for no passphrase): {colors.ENDC}")
        
        return ""
    
    def _create_ssh_key(self, key_file: Path, email: str, passphrase: str, username: str) -> Optional[str]:
        """Create SSH key file."""
        try:
            cmd = [
                'ssh-keygen', '-t', 'rsa', '-b', '4096',
                '-C', email, '-f', str(key_file), '-N', passphrase
            ]
            
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                shell=self.platform == "Windows"
            )
            
            if result.returncode != 0:
                self.print_error(f"Failed to generate SSH key: {result.stderr}")
                return None
            
            self._set_ssh_key_permissions(key_file)
            self.update_ssh_config(username, str(key_file))
            self.print_success("SSH key generated successfully!")
            
            return str(key_file)
            
        except (subprocess.CalledProcessError, OSError) as e:
            self.print_error(f"Error generating SSH key: {e}")
            return None
    
    def _set_ssh_key_permissions(self, key_file: Path) -> None:
        """Set proper permissions for SSH keys (Unix only)."""
        if self.platform != "Windows":
            key_file.chmod(0o600)
            Path(f"{key_file}.pub").chmod(0o644)
    
    def update_ssh_config(self, username: str, key_file: str) -> bool:
        """Update SSH config for the profile with Windows path handling."""
        config_file = SSH_DIR / 'config'
        
        # Windows path handling
        if self.platform == "Windows":
            key_file = key_file.replace('\\', '/')
        
        config_content = f"""
# Git profile: {username}
Host github.com-{username}
    HostName github.com
    User git
    IdentityFile {key_file}
    IdentitiesOnly yes

"""
        
        try:
            with open(config_file, 'a', encoding='utf-8') as f:
                f.write(config_content)
            return True
        except IOError as e:
            self.print_error(f"Error updating SSH config: {e}")
            return False
    
    def copy_to_clipboard(self, text: str) -> bool:
        """Copy text to clipboard with enhanced platform support."""
        clipboard_methods = {
            'Darwin': self._copy_to_clipboard_macos,
            'Windows': self._copy_to_clipboard_windows,
            'Linux': self._copy_to_clipboard_linux
        }
        
        method = clipboard_methods.get(self.platform, self._copy_to_clipboard_linux)
        return method(text)
    
    def _copy_to_clipboard_macos(self, text: str) -> bool:
        """Copy to clipboard on macOS."""
        try:
            process = subprocess.Popen(['pbcopy'], stdin=subprocess.PIPE)
            process.communicate(text.encode('utf-8'))
            return process.returncode == 0
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False
    
    def _copy_to_clipboard_windows(self, text: str) -> bool:
        """Copy to clipboard on Windows."""
        try:
            # Try PowerShell first
            cmd = ['powershell', '-command', f'"{text}" | Set-Clipboard']
            if subprocess.run(cmd, capture_output=True, shell=True).returncode == 0:
                return True
            
            # Fallback to clip
            process = subprocess.Popen(['clip'], stdin=subprocess.PIPE, shell=True)
            process.communicate(text.encode('utf-8'))
            return process.returncode == 0
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False
    
    def _copy_to_clipboard_linux(self, text: str) -> bool:
        """Copy to clipboard on Linux."""
        clipboard_tools = [
            ['xclip', '-selection', 'clipboard'],
            ['xsel', '--clipboard', '--input'],
            ['wl-copy']  # Wayland
        ]
        
        for cmd in clipboard_tools:
            try:
                process = subprocess.Popen(cmd, stdin=subprocess.PIPE)
                process.communicate(text.encode('utf-8'))
                if process.returncode == 0:
                    return True
            except FileNotFoundError:
                continue
        
        return False
    
    def open_github_ssh_settings(self) -> bool:
        """Open GitHub SSH settings page."""
        try:
            return webbrowser.open(GITHUB_SSH_URL)
        except Exception:
            return self._open_url_fallback(GITHUB_SSH_URL)
    
    def _open_url_fallback(self, url: str) -> bool:
        """Fallback method to open URL using system commands."""
        commands = {
            'Darwin': ['open', url],
            'Windows': ['start', url],
            'Linux': ['xdg-open', url]
        }
        
        cmd = commands.get(self.platform, ['xdg-open', url])
        
        try:
            subprocess.run(cmd, shell=self.platform == "Windows")
            return True
        except (subprocess.CalledProcessError, FileNotFoundError):
            return False
    
    def show_ssh_instructions(self, key_file: str, username: str) -> bool:
        """Show instructions for setting up SSH key with GitHub."""
        self.print_header("SSH Key Setup Instructions")
        
        try:
            public_key = self._read_public_key(key_file)
            self._display_ssh_key(public_key)
            self._handle_clipboard_copy(public_key)
            self._open_github_settings()
            self._print_setup_instructions(username)
            
            return True
            
        except IOError as e:
            self.print_error(f"Error reading SSH key: {e}")
            return False
    
    def _read_public_key(self, key_file: str) -> str:
        """Read the public key from file."""
        with open(f"{key_file}.pub", 'r', encoding='utf-8') as f:
            return f.read().strip()
    
    def _display_ssh_key(self, public_key: str) -> None:
        """Display the SSH public key."""
        print(f"{colors.YELLOW}1. Your SSH public key:{colors.ENDC}")
        print(f"{colors.CYAN}{'-' * 50}{colors.ENDC}")
        print(f"{colors.GREEN}{public_key}{colors.ENDC}")
        print(f"{colors.CYAN}{'-' * 50}{colors.ENDC}")
    
    def _handle_clipboard_copy(self, public_key: str) -> None:
        """Handle copying SSH key to clipboard."""
        if self.copy_to_clipboard(public_key):
            self.print_success("SSH key copied to clipboard!")
            self._print_clipboard_instructions()
        else:
            self.print_warning("Could not copy automatically. Please copy manually.")
    
    def _print_clipboard_instructions(self) -> None:
        """Print clipboard usage instructions."""
        if self.platform == "Windows":
            print(f"{colors.YELLOW}You can paste it with Ctrl+V{colors.ENDC}")
        else:
            print(f"{colors.YELLOW}You can paste it with Ctrl+V (Linux) or Cmd+V (macOS){colors.ENDC}")
    
    def _open_github_settings(self) -> None:
        """Open GitHub SSH settings page."""
        print(f"\n{colors.BLUE}Opening GitHub SSH settings page...{colors.ENDC}")
        if self.open_github_ssh_settings():
            self.print_success("GitHub page opened successfully!")
        else:
            self.print_warning("Could not open browser automatically.")
            print(f"Please visit: {GITHUB_SSH_URL}")
    
    def _print_setup_instructions(self, username: str) -> None:
        """Print setup instructions."""
        print(f"\n{colors.BOLD}Setup Instructions:{colors.ENDC}")
        print(f"{colors.GREEN}1. Set title: '{username} - Git Profile Manager'{colors.ENDC}")
        print(f"{colors.YELLOW}2. Paste the SSH key into the 'Key' field{colors.ENDC}")
        print(f"{colors.CYAN}3. Click 'Add SSH key' to save{colors.ENDC}")
        
        print(f"\n{colors.BOLD}Repository URL format:{colors.ENDC}")
        print(f"{colors.GREEN}git@github.com-{username}:username/repository.git{colors.ENDC}")
    
    def test_github_connection(self, username: str) -> bool:
        """Test SSH connection to GitHub for a specific profile."""
        profiles = self.load_profiles()
        
        if not self._validate_profile_exists(username, profiles):
            return False
        
        profile = profiles[username]
        if not self._validate_profile_has_ssh_key(username, profile):
            return False
        
        self.print_info(f"Testing GitHub connection for profile '{username}'...")
        
        try:
            self.add_github_to_known_hosts()
            return self._perform_ssh_test(username, profile)
        except subprocess.TimeoutExpired:
            self.print_error("Connection timeout! Check your internet connection.")
            return False
        except Exception as e:
            self.print_error(f"Error testing connection: {e}")
            return False
    
    def _validate_profile_exists(self, username: str, profiles: Dict[str, Any]) -> bool:
        """Validate that the profile exists."""
        if username not in profiles:
            self.print_error(f"Profile '{username}' not found!")
            return False
        return True
    
    def _validate_profile_has_ssh_key(self, username: str, profile: Dict[str, Any]) -> bool:
        """Validate that the profile has an SSH key."""
        if 'ssh_key' not in profile:
            self.print_error(f"Profile '{username}' has no SSH key!")
            return False
        return True
    
    def _perform_ssh_test(self, username: str, profile: Dict[str, Any]) -> bool:
        """Perform the actual SSH connection test."""
        cmd = ['ssh', '-T', f'git@github.com-{username}']
        env = self._prepare_ssh_environment(profile)
        
        result = subprocess.run(
            cmd,
            capture_output=True,
            text=True,
            env=env,
            timeout=15,
            shell=self.platform == "Windows"
        )
        
        return self._handle_ssh_test_result(result, username, profile)
    
    def _prepare_ssh_environment(self, profile: Dict[str, Any]) -> Dict[str, str]:
        """Prepare environment for SSH command."""
        env = os.environ.copy()
        ssh_key = profile['ssh_key']
        
        if self.platform == "Windows":
            ssh_key = ssh_key.replace('\\', '/')
        
        env['GIT_SSH_COMMAND'] = f'ssh -i "{ssh_key}" -o StrictHostKeyChecking=no'
        return env
    
    def _handle_ssh_test_result(self, result: subprocess.CompletedProcess, username: str, profile: Dict[str, Any]) -> bool:
        """Handle SSH test result."""
        if "successfully authenticated" in result.stderr.lower():
            self.print_success("GitHub connection successful!")
            self._print_connection_success_details(username, profile)
            return True
        else:
            self.print_error("GitHub connection failed!")
            print(f"{colors.YELLOW}Error: {result.stderr}{colors.ENDC}")
            self.print_troubleshooting_tips()
            return False
    
    def _print_connection_success_details(self, username: str, profile: Dict[str, Any]) -> None:
        """Print details of successful connection."""
        print(f"{colors.BLUE}Profile: {username}{colors.ENDC}")
        print(f"{colors.GREEN}Name: {profile['name']}{colors.ENDC}")
        print(f"{colors.YELLOW}Email: {profile['email']}{colors.ENDC}")
    
    def add_github_to_known_hosts(self) -> None:
        """Add GitHub to SSH known_hosts with Windows support."""
        known_hosts = SSH_DIR / 'known_hosts'
        
        if self._is_github_in_known_hosts(known_hosts):
            return
        
        self._add_github_host_key(known_hosts)
    
    def _is_github_in_known_hosts(self, known_hosts: Path) -> bool:
        """Check if GitHub is already in known_hosts."""
        if not known_hosts.exists():
            return False
        
        try:
            with open(known_hosts, 'r', encoding='utf-8') as f:
                content = f.read()
            return GITHUB_HOST_KEY in content
        except IOError:
            return False
    
    def _add_github_host_key(self, known_hosts: Path) -> None:
        """Add GitHub host key to known_hosts."""
        try:
            cmd = ['ssh-keyscan', '-t', 'rsa', GITHUB_HOST_KEY]
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                shell=self.platform == "Windows"
            )
            
            if result.returncode == 0 and result.stdout:
                with open(known_hosts, 'a', encoding='utf-8') as f:
                    f.write(result.stdout)
        except (IOError, subprocess.CalledProcessError):
            pass
    
    def print_troubleshooting_tips(self) -> None:
        """Print troubleshooting tips with platform-specific advice."""
        print(f"\n{colors.BOLD}Troubleshooting:{colors.ENDC}")
        print(f"{colors.CYAN}1. Ensure SSH key is added to GitHub{colors.ENDC}")
        
        self._print_platform_specific_tips()
        
        print(f"{colors.CYAN}3. Verify SSH config is correct{colors.ENDC}")
        print(f"{colors.CYAN}4. Test with: ssh -T git@github.com-{{username}}{colors.ENDC}")
    
    def _print_platform_specific_tips(self) -> None:
        """Print platform-specific troubleshooting tips."""
        if self.platform == "Windows":
            print(f"{colors.CYAN}2. Ensure OpenSSH client is installed (Windows 10+){colors.ENDC}")
            print(f"{colors.CYAN}3. Try running from Git Bash if using Git for Windows{colors.ENDC}")
        else:
            print(f"{colors.CYAN}2. Check SSH key permissions (chmod 600){colors.ENDC}")
    
    # Utility methods for consistent output
    def clear_screen(self) -> None:
        """Clear the terminal screen with cross-platform support."""
        clear_cmd = 'cls' if self.platform == "Windows" else 'clear'
        os.system(clear_cmd)
    
    def print_header(self, title: str) -> None:
        """Print a formatted header."""
        print(f"\n{colors.BOLD}=== {title} ==={colors.ENDC}")
    
    def print_success(self, message: str) -> None:
        """Print success message."""
        print(f"{colors.GREEN}✅ {message}{colors.ENDC}")
    
    def print_error(self, message: str) -> None:
        """Print error message."""
        print(f"{colors.RED}❌ {message}{colors.ENDC}")
    
    def print_warning(self, message: str) -> None:
        """Print warning message."""
        print(f"{colors.YELLOW}⚠️  {message}{colors.ENDC}")
    
    def print_info(self, message: str) -> None:
        """Print info message."""
        print(f"{colors.CYAN}ℹ️  {message}{colors.ENDC}")

# Export the main class
__all__ = ['GitProfileManager', 'colors'] 