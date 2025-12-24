# Git Profile Manager for Windows 🔐
> A lightweight, powerful PowerShell utility to manage multiple Git identities and SSH keys instantly.
> **No more commit identity mistakes.**

![PowerShell](https://img.shields.io/badge/PowerShell-%235391FE.svg?style=for-the-badge&logo=powershell&logoColor=white)
![Git](https://img.shields.io/badge/git-%23F05033.svg?style=for-the-badge&logo=git&logoColor=white)
![GitHub](https://img.shields.io/badge/github-%23121011.svg?style=for-the-badge&logo=github&logoColor=white)

## ✨ Features

- **⚡ Instant Switching:** Changes Git identity (`user.name`, `user.email`) and SSH keys immediately for both global and local repositories.
- **🔑 SSH Auto-Generation:** Automatically creates SSH key pairs, configures `~/.ssh/config`, and registers with `ssh-agent`.
- **📋 Smart Clipboard:** Auto-copies public keys and opens GitHub SSH settings page for seamless key addition.
- **🔄 Remote URL Sync:** Automatically updates repository remote URLs to match the active profile's SSH host alias.
- **🛡️ Isolated Identities:** Complete separation between Work, Personal, and any custom profiles.
- **🎨 Beautiful UI:** Clean, intuitive interface with color-coded status indicators and box-drawing characters.

## 🚀 Quick Start (Run without installing)

You can run the script directly from your terminal without cloning the repository.
```powershell
iwr -useb https://raw.githubusercontent.com/nhatpse/git-switch/master/install.ps1 | iex
```
**Backup:** Universal Command (If Option 1 fails / For older Windows)  
Use this if you see SSL/TLS errors or Policy restrictions.
```powershell
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://raw.githubusercontent.com/nhatpse/git-switch/master/install.ps1'))
```
