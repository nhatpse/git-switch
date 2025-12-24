# install.ps1 - Git Switch Installer
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8
$OutputEncoding = [System.Text.Encoding]::UTF8

# Download and execute main script
$ScriptUrl = "https://raw.githubusercontent.com/nhatpse/git-switch/master/git.ps1"
$ScriptContent = (Invoke-WebRequest -Uri $ScriptUrl -UseBasicParsing).Content

# Execute with proper encoding
Invoke-Expression $ScriptContent