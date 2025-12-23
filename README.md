# Git Profile Manager

> A sophisticated command-line utility for seamless management and switching between multiple GitHub accounts with enterprise-grade features and cross-platform support.

## Version 2.3 Release Highlights

**Architecture Enhancements**
- Centralized settings management through dedicated configuration menu
- Integrated automatic version validation against GitHub repository
- Streamlined core interface with focused four-option navigation
- Hierarchical menu structure with intuitive return-path navigation
- Consolidated connection diagnostics and URL management within settings framework

## Core Capabilities

**Profile Management**
- Instantaneous context switching between multiple GitHub identities
- Zero-configuration profile transitions with automatic credential rotation

**Security Infrastructure**
- Automated generation and lifecycle management of 4096-bit RSA keypairs
- Intelligent SSH configuration with per-profile host isolation
- Secure passphrase support with encrypted credential storage

**Integration Layer**
- Universal clipboard integration across all major operating systems
- Direct GitHub SSH settings page invocation from command line
- Real-time connectivity validation with diagnostic troubleshooting
- Automatic repository URL transformation on profile switch

**User Interface**
- Terminal-native interface with ANSI color coding
- Context-aware operation modes (repository vs system-wide)
- Comprehensive input validation and error recovery
- Progressive disclosure design for advanced features

## Installation

### Package Manager Installation

#### Homebrew (macOS and Linux)

```bash
brew tap nhatpse/gitsw
brew install gitsw
```

**Available Commands Post-Installation**
```bash
gitsw                   # Primary application launcher
git-profile            # Alternative invocation method
git-profile-update     # Version update utility
```

### Zero-Installation Execution

#### Unix-Based Systems (Linux / macOS)
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nhatpse/git-switch/main/run_git_profiles.sh)
```

#### Windows Environments

**PowerShell**
```powershell
iwr -useb https://raw.githubusercontent.com/nhatpse/git-switch/main/run_git_profiles.ps1 | iex
```

**Git Bash**
```bash
bash <(curl -fsSL https://raw.githubusercontent.com/nhatpse/git-switch/main/run_git_profiles.sh)
```

## Deployment Strategies

### Comparative Analysis

| Deployment Method | Primary Benefits | Operational Considerations |
|-------------------|------------------|----------------------------|
| **Homebrew** | Automated dependency resolution, seamless updates, system PATH integration | Platform constraint (Unix-based only), Homebrew prerequisite |
| **Direct Execution** | Zero system footprint, guaranteed latest version, automatic cleanup | Network dependency on each invocation, marginal startup latency |
| **Manual Installation** | Complete operational autonomy, offline functionality post-setup | Manual update workflow required |

### Persistent Installation Procedures

#### Method A: Homebrew Package Manager
```bash
brew tap nhatpse/gitsw
brew install gitsw
```

#### Method B: Automated Installation Script
```bash
curl -fsSL https://raw.githubusercontent.com/nhatpse/git-switch/main/install.sh | bash
```

**Post-Installation Command Reference**
- `gitsw` or `git-profile` — Launch application
- `git-profile-update` — Synchronize with latest release

### Direct Python Invocation
```bash
python3 ~/.git-profile-manager/git_profiles.py
```

## Operational Modes

### Context-Sensitive Behavior

**Repository-Scoped Operations**
Execute within a Git repository to configure project-specific identity:
```bash
cd /path/to/project
git-profile  # Activates profile and updates remote configuration
```

**System-Wide Operations**
Execute outside repository context for global profile management:
```bash
cd ~
git-profile  # Access profile creation and SSH key management
```

### Automated Workflow Features

- **Repository URL Synchronization** — Automatic remote URL rewriting on profile activation
- **Intelligent SSH Configuration** — Dynamic Host entry generation per profile
- **Connectivity Diagnostics** — Post-configuration GitHub connection validation
- **Clipboard Automation** — Zero-touch SSH public key transfer for GitHub registration
- **Universal Path Handling** — Transparent Windows/Unix path translation

## Application Interface

```
   _______ _____ _______     ____  ____   ____  ______ _____ __    _____ _____
  / ____(_) __/_  __(_)    / __ \/ __ \ / __ \/ ____//   _// /   / ___// ___/
 / / __/ / /_   / /       / /_/ / /_/ // / / / /_    / / / /    \__ \ \__ \ 
/ /_/ / / __/  / /       / ____/ _, _// /_/ / __/  _/ / / /___ ___/ /___/ / 
\____/_/_/    /_/       /_/   /_/ |_|\____/_/    /___//_____//____/  

                    Git Profile Manager v2.3
              Switch between multiple GitHub accounts seamlessly


No Git configuration found!

Choose an option:
1. Add new profile
2. Switch profile
3. Remove profile
4. Settings
0. Exit

Enter your choice (0-4): 
```

## System Prerequisites

### Essential Components
- **Python Runtime** — Version 3.6 or later (standard library dependencies only)
- **Git Version Control** — Any modern release
- **Network Connectivity** — Required for initial download and GitHub API access

### SSH Infrastructure
- **OpenSSH Client** — ssh-keygen utility required
- **Linux** — Typically pre-installed with distribution
- **macOS** — Included with operating system
- **Windows** — Available via OpenSSH Client feature or Git for Windows

### Clipboard Integration
- **Linux** — xclip, xsel, or wl-copy (Wayland)
- **macOS** — pbcopy (system native)
- **Windows** — PowerShell or clip.exe (system native)

## Evolution from Version 1.0

### Engineering Improvements
- Architectural consolidation (reduced from 3-file to 2-file structure)
- Object-oriented design with comprehensive exception handling
- Type annotation throughout codebase
- Platform abstraction layer implementation

### Security Enhancements
- SSH key passphrase support with secure input
- Platform-appropriate file permission enforcement
- Input sanitization and validation framework
- Secure subprocess invocation patterns

### User Experience Refinement
- ANSI-enhanced terminal interface with ASCII typography
- Platform-specific error messaging and troubleshooting
- Contextual error reporting with actionable guidance
- Visual progress indicators and confirmation workflows

### Performance and Distribution
- Optimized startup sequence and runtime efficiency
- Zero external dependencies (Python standard library only)
- Stateless direct execution mode
- Proper resource cleanup and garbage collection

## Cross-Platform Feature Matrix

| Capability | Linux | macOS | Windows 10+ | Windows Legacy |
|------------|-------|-------|-------------|----------------|
| Core Operations | Full | Full | Full | Full |
| Homebrew Distribution | Supported | Supported | Not Available | Not Available |
| ANSI Color Rendering | Native | Native | Native | Limited |
| Clipboard Integration | Native | Native | Native | Basic |
| SSH Key Generation | Full Support | Full Support | Full Support | Partial |
| Browser Automation | Supported | Supported | Supported | Supported |
| Direct Execution | Full | Full | Full | Limited |

## Licensing

Released under MIT License. Refer to LICENSE file for complete terms.

---

**Professional-grade tooling for developers managing multiple GitHub identities**

**Copyright (c) NHATPMIO**
