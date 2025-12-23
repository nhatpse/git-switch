# Git Profile Manager - Direct Run Script for Windows PowerShell
# Version: 2.3
# Run directly from GitHub without installation

param(
    [switch]$Help,
    [switch]$Install
)

# Colors for PowerShell
$Colors = @{
    Red = "Red"
    Green = "Green"
    Yellow = "Yellow"
    Blue = "Blue"
    Cyan = "Cyan"
    White = "White"
}

function Write-Header {
    Write-Host "╔══════════════════════════════════════════════════════════════╗" -ForegroundColor Cyan
    Write-Host "║               Git Profile Manager v2.3                      ║" -ForegroundColor Cyan
    Write-Host "║               Direct Run from GitHub                        ║" -ForegroundColor Cyan  
    Write-Host "║                    (Windows)                               ║" -ForegroundColor Cyan
    Write-Host "╚══════════════════════════════════════════════════════════════╝" -ForegroundColor Cyan
}

function Write-Success {
    param([string]$Message)
    Write-Host "✅ $Message" -ForegroundColor Green
}

function Write-Error {
    param([string]$Message)
    Write-Host "❌ $Message" -ForegroundColor Red
}

function Write-Info {
    param([string]$Message)
    Write-Host "ℹ️  $Message" -ForegroundColor Blue
}

function Write-Warning {
    param([string]$Message)
    Write-Host "⚠️  $Message" -ForegroundColor Yellow
}

function Test-Python {
    Write-Info "Checking for Python 3..."
    
    # Check for python3 command
    if (Get-Command python3 -ErrorAction SilentlyContinue) {
        $version = python3 --version 2>&1
        if ($version -match "Python 3\.([6-9]|\d{2,})") {
            Write-Success "Python 3 found: $version"
            return "python3"
        }
    }
    
    # Check for python command
    if (Get-Command python -ErrorAction SilentlyContinue) {
        $version = python --version 2>&1
        if ($version -match "Python 3\.([6-9]|\d{2,})") {
            Write-Success "Python 3 found: $version"
            return "python"
        }
    }
    
    # Check in common installation paths
    $pythonPaths = @(
        "$env:LOCALAPPDATA\Programs\Python\Python*\python.exe",
        "$env:PROGRAMFILES\Python*\python.exe",
        "$env:PROGRAMFILES(X86)\Python*\python.exe"
    )
    
    foreach ($path in $pythonPaths) {
        $pythonExes = Get-ChildItem $path -ErrorAction SilentlyContinue
        foreach ($exe in $pythonExes) {
            try {
                $version = & $exe.FullName --version 2>&1
                if ($version -match "Python 3\.([6-9]|\d{2,})") {
                    Write-Success "Python 3 found: $version at $($exe.FullName)"
                    return $exe.FullName
                }
            } catch {}
        }
    }
    
    Write-Error "Python 3.6+ is required but not found"
    Write-Info "Please install Python 3 from: https://python.org"
    Write-Info "Make sure to check 'Add Python to PATH' during installation"
    exit 1
}

function Test-Git {
    Write-Info "Checking for Git..."
    
    if (Get-Command git -ErrorAction SilentlyContinue) {
        $version = git --version
        Write-Success "Git found: $version"
        return $true
    } else {
        Write-Error "Git is required but not installed"
        Write-Info "Please install Git from: https://git-scm.com/download/win"
        exit 1
    }
}

function Test-SSH {
    Write-Info "Checking for SSH tools..."
    
    if (Get-Command ssh-keygen -ErrorAction SilentlyContinue) {
        Write-Success "SSH tools found"
        return $true
    } else {
        Write-Warning "ssh-keygen not found"
        Write-Info "Some features may not work. Please install OpenSSH client:"
        Write-Info "Settings > Apps > Optional Features > Add a feature > OpenSSH Client"
        return $false
    }
}

function Start-GitProfiles {
    param([string]$PythonCmd)
    
    Write-Info "Downloading Git Profile Manager..."
    
    # Create temporary directory
    $tempDir = Join-Path $env:TEMP "git-profile-manager-$(Get-Random)"
    New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    Set-Location $tempDir
    
    try {
        # Download main files
        Write-Info "Downloading git_profile_manager.py..."
        try {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nhatpse/git-switch/main/git_profile_manager.py" -OutFile "git_profile_manager.py"
        } catch {
            Write-Error "Failed to download git_profile_manager.py"
            throw
        }
        
        Write-Info "Downloading git_profiles.py..."
        try {
            Invoke-WebRequest -Uri "https://raw.githubusercontent.com/nhatpse/git-switch/main/git_profiles.py" -OutFile "git_profiles.py"
        } catch {
            Write-Error "Failed to download git_profiles.py"
            throw
        }
        
        Write-Success "Files downloaded successfully"
        
        Write-Info "Starting Git Profile Manager..."
        Write-Host "Note: This is running from temporary directory. No files will be installed." -ForegroundColor Cyan
        Write-Host "Your profiles and SSH keys will be saved to your home directory as usual." -ForegroundColor Yellow
        Write-Host ""
        
        # Run the application
        & $PythonCmd "git_profiles.py"
        
    } finally {
        # Cleanup
        Set-Location $env:USERPROFILE
        if (Test-Path $tempDir) {
            Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
            Write-Info "Temporary files cleaned up"
        }
    }
}

function Show-Help {
    Write-Host "Git Profile Manager - Direct Run Script for Windows" -ForegroundColor White
    Write-Host ""
    Write-Host "This script downloads and runs Git Profile Manager directly from GitHub"
    Write-Host "without installing it permanently on your system."
    Write-Host ""
    Write-Host "Usage:" -ForegroundColor White
    Write-Host "  # Download and run this script:"
    Write-Host "  iwr -useb https://raw.githubusercontent.com/nhatpse/git-switch/main/run_git_profiles.ps1 | iex"
    Write-Host ""
    Write-Host "  # Or save and run locally:"
    Write-Host "  Invoke-WebRequest -Uri 'https://raw.githubusercontent.com/nhatpse/git-switch/main/run_git_profiles.ps1' -OutFile 'run_git_profiles.ps1'"
    Write-Host "  .\run_git_profiles.ps1"
    Write-Host ""
    Write-Host "Options:" -ForegroundColor White
    Write-Host "  -Help      Show this help message"
    Write-Host "  -Install   Run the installer instead"
    Write-Host ""
    Write-Host "Features:" -ForegroundColor White
    Write-Host "  • No permanent installation required"
    Write-Host "  • Automatic cleanup after use"
    Write-Host "  • Native Windows PowerShell support"
    Write-Host "  • All profile data saved to your home directory"
    Write-Host ""
    Write-Host "Requirements:" -ForegroundColor White
    Write-Host "  • Windows 10+ (PowerShell 5.1+)"
    Write-Host "  • Python 3.6+"
    Write-Host "  • Git for Windows"
    Write-Host "  • Internet connection"
    Write-Host "  • OpenSSH Client (for SSH key generation)"
}

# Main execution
if ($Help) {
    Show-Help
    exit 0
}

if ($Install) {
    Write-Info "Running installer instead..."
    iwr -useb https://raw.githubusercontent.com/nhatpse/git-switch/main/install.sh | bash
    exit $LASTEXITCODE
}

try {
    Write-Header
    Write-Info "Checking system requirements..."
    
    # Check requirements
    $pythonCmd = Test-Python
    Test-Git | Out-Null
    Test-SSH | Out-Null
    
    Write-Host ""
    Write-Info "All requirements met! Starting direct run..."
    Write-Host ""
    
    # Download and run
    Start-GitProfiles -PythonCmd $pythonCmd
    
} catch {
    Write-Error "An error occurred: $($_.Exception.Message)"
    exit 1
} 