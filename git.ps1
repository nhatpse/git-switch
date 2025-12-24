# ==============================================================================
# GIT PROFILE MANAGER - ULTIMATE EDITION (NATIVE POWERSHELL)
# Version: 2.0 (Ported from Python Core)
# Author: nhatpse
# Features: SSH Auto-Gen, Config Management, Clipboard, Browser Integration
# ==============================================================================

# -------------------------- CONFIGURATION --------------------------
$BaseDir = "$env:USERPROFILE\.git-switch"
$ProfilesFile = "$BaseDir\profiles.json"
$SSHDir = "$env:USERPROFILE\.ssh"
$SSHConfigFile = "$SSHDir\config"

# Ensure UTF-8 Output
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

# -------------------------- HELPER: UI & BOX DRAWING --------------------------
function Write-Color {
    param([string]$Text, [ConsoleColor]$Color = "White", [switch]$NoNewLine)
    if ($NoNewLine) { Write-Host $Text -ForegroundColor $Color -NoNewline }
    else { Write-Host $Text -ForegroundColor $Color }
}

function Draw-Border-Top {
    param([int]$Width = 60, [ConsoleColor]$Color = "Cyan")
    Write-Color ("╔" + ("═" * $Width) + "╗") -Color $Color
}

function Draw-Border-Bottom {
    param([int]$Width = 60, [ConsoleColor]$Color = "Cyan")
    Write-Color ("╚" + ("═" * $Width) + "╝") -Color $Color
}

function Draw-Line {
    param([string]$Text, [int]$Width = 60, [ConsoleColor]$Color = "Cyan", [ConsoleColor]$TextColor = "White")
    $Content = " $Text "
    $PadRight = $Width - $Content.Length
    if ($PadRight -lt 0) { $PadRight = 0 }
    Write-Color "║" -Color $Color -NoNewLine
    Write-Color $Content -Color $TextColor -NoNewLine
    Write-Color (" " * $PadRight) -NoNewLine
    Write-Color "║" -Color $Color
}

function Draw-Separator {
    param([int]$Width = 60, [ConsoleColor]$Color = "Cyan")
    Write-Color ("╟" + ("─" * $Width) + "╢") -Color $Color
}

function Draw-Sep {
    # Vẽ đường kẻ ngang dài
    Write-Host " ──────────────────────────────────────────────────────────────────────" -ForegroundColor DarkGray
}

function Draw-Header {
    param([string]$Title)
    Draw-Sep
    Write-Host "   » $Title" -ForegroundColor Cyan
    Draw-Sep
}
# -------------------------- CORE LOGIC (PORTED FROM PYTHON) --------------------------

function Initialize-System {
    # Tạo thư mục config nếu chưa có
    if (-not (Test-Path $BaseDir)) { New-Item -ItemType Directory -Path $BaseDir -Force | Out-Null }
    
    # Tạo file profiles.json nếu chưa có
    if (-not (Test-Path $ProfilesFile)) { 
        "[]" | Set-Content $ProfilesFile -Encoding UTF8 -Force 
    }

    # Tạo thư mục .ssh nếu chưa có
    if (-not (Test-Path $SSHDir)) { New-Item -ItemType Directory -Path $SSHDir -Force | Out-Null }
    
    # Tạo file config ssh nếu chưa có
    if (-not (Test-Path $SSHConfigFile)) { New-Item -ItemType File -Path $SSHConfigFile -Force | Out-Null }
}

function Load-Profiles {
    Initialize-System
    try {
        $Content = Get-Content $ProfilesFile -Raw -Encoding UTF8 -ErrorAction Stop
        if ([string]::IsNullOrWhiteSpace($Content)) { return @() }
        $Data = $Content | ConvertFrom-Json
        if ($Data -is [System.Array]) { return $Data }
        if ($null -eq $Data) { return @() }
        return @($Data)
    } catch {
        return @()
    }
}

function Save-Profiles($Data) {
    if ($Data -isnot [System.Array]) { $Data = @($Data) }
    $Data | ConvertTo-Json -Depth 5 | Set-Content $ProfilesFile -Encoding UTF8
}

function Get-Git-Current {
    try {
        $Name = git config --global user.name
        $Email = git config --global user.email
        if (-not $Name) { $Name = "Not Set" }
        if (-not $Email) { $Email = "Not Set" }
        return @{ Name = $Name; Email = $Email }
    } catch {
        return @{ Name = "Git Not Found"; Email = "Check Install" }
    }
}

# --- SSH LOGIC ---

function Generate-SSH-Key {
    param($Email, $Alias)
    
    $KeyPath = "$SSHDir\id_rsa_$Alias"
    
    if (Test-Path $KeyPath) {
        Write-Color "  [!] SSH Key already exists for this alias. Using existing key." -Color Yellow
        return $KeyPath
    }

    Write-Color "  [INFO] Generating new SSH Key..." -Color Cyan
    
    # Gọi ssh-keygen, passphase rỗng (-N "") để tự động hóa
    try {
        # FIX: Dùng '""' (bao quanh bởi nháy đơn) để PowerShell truyền đúng chuỗi rỗng cho ssh-keygen
        & ssh-keygen -t rsa -b 4096 -C "$Email" -f "$KeyPath" -N '""' | Out-Null
        
        if ($LASTEXITCODE -eq 0) {
            Write-Color "  [✔] SSH Key generated successfully." -Color Green
            return $KeyPath
        } else {
            throw "ssh-keygen failed."
        }
    } catch {
        Write-Color "  [X] Failed to generate SSH Key. Ensure OpenSSH is installed." -Color Red
        return $null
    }
}

function Update-SSH-Config {
    param($Alias, $KeyPath)
    
    # Định dạng block config giống logic Python
    # Host ảo sẽ là: github.com-<alias>
    $ConfigBlock = @"

# Git profile: $Alias
Host github.com-$Alias
    HostName github.com
    User git
    IdentityFile $KeyPath
    IdentitiesOnly yes
"@
    
    try {
        Add-Content -Path $SSHConfigFile -Value $ConfigBlock -Encoding UTF8
        Write-Color "  [✔] SSH Config updated (Host: github.com-$Alias)." -Color Green
    } catch {
        Write-Color "  [X] Failed to update .ssh/config." -Color Red
    }
}

function Remove-From-SSH-Config {
    param($Alias)
    
    if (-not (Test-Path $SSHConfigFile)) { return }
    
    try {
        # Đọc toàn bộ dòng
        $Lines = Get-Content $SSHConfigFile -Encoding UTF8
        $NewLines = @()
        $Skip = $false
        
        foreach ($Line in $Lines) {
            # Tìm dòng bắt đầu comment profile
            if ($Line -match "# Git profile: $Alias") {
                $Skip = $true
                continue
            }
            
            # Nếu đang skip mà gặp dòng trống (hết block) hoặc block mới -> dừng skip
            if ($Skip -and ($Line.Trim() -eq "" -or $Line -match "^Host ")) {
                 # Nếu gặp Host khác ngay lập tức thì giữ lại, nếu dòng trống thì bỏ qua 1 dòng trống
                 if ($Line -match "^Host ") { $Skip = $false }
            }
            
            # Logic đơn giản hóa: Block kết thúc bằng dòng trống hoặc Host tiếp theo
            # Logic Python: Remove lines until next empty line or next header
            if ($Skip) {
                if ([string]::IsNullOrWhiteSpace($Line)) { $Skip = $false }
            } else {
                $NewLines += $Line
            }
        }
        
        $NewLines | Set-Content $SSHConfigFile -Encoding UTF8
        Write-Color "  [✔] Removed entry from SSH Config." -Color Green
    } catch {
        Write-Color "  [!] Error cleaning SSH Config." -Color Yellow
    }
}

function Update-Repo-Url {
    param($Alias)
    # Kiểm tra xem đang ở trong repo git không
    $IsGit = git rev-parse --is-inside-work-tree 2>$null
    if (-not $IsGit) { return }

    $CurrentUrl = git remote get-url origin 2>$null
    if (-not $CurrentUrl) { return }

    Write-Color "`n  [INFO] Checking Repository URL..." -Color Cyan
    
    # Logic chuyển đổi URL (Python logic ported)
    # Convert: https://github.com/user/repo -> git@github.com-Alias:user/repo
    # Convert: git@github.com:user/repo     -> git@github.com-Alias:user/repo
    
    $NewHost = "github.com-$Alias"
    $NewUrl = $null

    if ($CurrentUrl -match "https://github.com/(.*)") {
        $RepoPart = $Matches[1]
        $NewUrl = "git@$NewHost`:$RepoPart"
    }
    elseif ($CurrentUrl -match "git@github.com:(.*)") {
        $RepoPart = $Matches[1]
        $NewUrl = "git@$NewHost`:$RepoPart"
    }
    elseif ($CurrentUrl -match "git@github.com-.*:(.*)") {
        # Đã dùng profile khác, switch sang profile này
        $RepoPart = $Matches[1]
        $NewUrl = "git@$NewHost`:$RepoPart"
    }

    if ($NewUrl -and $NewUrl -ne $CurrentUrl) {
        git remote set-url origin $NewUrl
        Write-Color "  [✔] Updated Remote URL to: $NewUrl" -Color Green
    } else {
        Write-Color "  [INFO] Remote URL is already correct or not hosted on GitHub." -Color Gray
    }
}

# -------------------------- FEATURE FUNCTIONS --------------------------
function Test-Connection-Action {
    $Profiles = @(Load-Profiles)
    if ($Profiles.Count -eq 0) { Write-Color "`n  [!] No profiles found." "Yellow"; return }

    Write-Host "`n"
    Draw-Border-Top 60 "Magenta"
    Draw-Line "TEST GITHUB CONNECTION" 60 "Magenta" "White"
    Draw-Separator 60 "Magenta"
    
    for ($i = 0; $i -lt $Profiles.Count; $i++) {
        $Text = "  [$($i+1)] $($Profiles[$i].alias)"
        Draw-Line $Text 60 "Magenta" "White"
    }
    Draw-Border-Bottom 60 "Magenta"

    $Choice = Read-Host "  Select ID to test (0 to cancel)"
    if ($Choice -eq "0" -or -not ($Choice -as [int])) { return }
    $Idx = [int]$Choice - 1
    if ($Idx -lt 0 -or $Idx -ge $Profiles.Count) { return }

    $Selected = $Profiles[$Idx]

    if (-not $Selected.keyPath) {
        Write-Color "  [!] Profile '$($Selected.alias)' does not have an SSH key recorded." "Yellow"
        return
    }

    Test-GitHub-Connection -Alias $Selected.alias
}

function Test-GitHub-Connection {
    param($Alias)
    $HostAlias = "github.com-$Alias"
    Write-Color "`n   [INFO] Testing connection to $HostAlias..." -Color Cyan
    
    $OutputStr = ""
    try {
        # FIX: Thêm pipe | ForEach-Object { "$_" }
        # Tác dụng: Biến mọi ErrorRecord thành String thuần túy ngay lập tức
        # Giúp chặn hoàn toàn dòng lỗi đỏ "NativeCommandError"
        $Output = & ssh -T "git@$HostAlias" 2>&1 | ForEach-Object { "$_" }
        $OutputStr = $Output | Out-String
    } catch {
        $OutputStr = $_.Exception.Message
    }

    if ($OutputStr -match "successfully authenticated") {
        Write-Color "   [✔] Connection SUCCESS! You are authenticated." -Color Green
        return $true
    } else {
        Write-Color "   [X] Connection FAILED." -Color Red
        # Clean bớt dòng chữ thừa nếu có
        $CleanErr = $OutputStr -replace "ssh.exe : ", ""
        Write-Color "   [DEBUG] $CleanErr" -Color DarkGray
        return $false
    }
}

function Add-Profile-Action {
    Write-Host "`n"
    Draw-Header "ADD NEW GIT PROFILE"
    
    $Alias = $null
    
    # --- VÒNG LẶP NHẬP ALIAS (RETRY LOOP) ---
    while ($true) {
        $Alias = Read-Host "   Enter Profile Alias (e.g. Work, Personal)"
        if ($Alias -eq "0") { return }

        $ErrorMsg = $null
        
        if ([string]::IsNullOrWhiteSpace($Alias)) {
            $ErrorMsg = "Alias required."
        }
        elseif ($Alias -notmatch "^[a-zA-Z0-9]+$") {
            $ErrorMsg = "Alias must be alphanumeric (no spaces/symbols)."
        }
        else {
            $Profiles = @(Load-Profiles)
            if ($Profiles | Where-Object { $_.alias -eq $Alias }) {
                $ErrorMsg = "Profile '$Alias' already exists."
            }
        }

        if ($ErrorMsg) {
            Write-Color "   [!] $ErrorMsg" "Red"
            $Retry = Read-Host "   Press ENTER to retry, or type '0' to back"
            if ($Retry -eq "0") { return }
            Write-Host ""
        } else {
            break
        }
    }
    # ---------------------------------------

    $UName = Read-Host "   Enter Git User Name (e.g. John Doe)"
    $UEmail = Read-Host "   Enter Git Email     (e.g. john@company.com)"

    if ([string]::IsNullOrWhiteSpace($UName) -or [string]::IsNullOrWhiteSpace($UEmail)) { 
        Write-Color "   [!] Name and Email are required." "Red"; return 
    }

    # 1. Generate Key
    $KeyPath = Generate-SSH-Key -Email $UEmail -Alias $Alias
    if (-not $KeyPath) { return }

    # 2. Update SSH Config
    Update-SSH-Config -Alias $Alias -KeyPath $KeyPath

    # 3. Clipboard
    $PubKeyPath = "$KeyPath.pub"
    if (Test-Path $PubKeyPath) {
        $PubKeyContent = Get-Content $PubKeyPath -Raw
        try {
            Set-Clipboard -Value $PubKeyContent
            Write-Color "   [✔] Public Key copied to CLIPBOARD!" -Color Green
        } catch {
            Write-Color "   [!] Could not auto-copy. Please open .pub file manually." -Color Yellow
        }
    }

    # 4. Hướng dẫn & Mở Browser
    Write-Host "`n   [ACTION REQUIRED]" -ForegroundColor Yellow
    Write-Host "   1. I will open GitHub SSH settings now." -ForegroundColor Gray
    Write-Host "   2. Click 'New SSH Key'." -ForegroundColor Gray
    Write-Host "   3. Paste (Ctrl+V) the key into the box." -ForegroundColor Gray
    Write-Host "   4. Come back here and press ENTER." -ForegroundColor Gray
    
    Start-Sleep -Seconds 2
    Start-Process "https://github.com/settings/ssh/new"
    
    Read-Host "`n   Press ENTER after you have added the key on GitHub..."

    # 5. Test Connection
    $null = Test-GitHub-Connection -Alias $Alias

    # 6. Save Profile
    $NewProfile = [PSCustomObject]@{
        alias = $Alias
        userName = $UName
        userEmail = $UEmail
        keyPath = $KeyPath
        created = (Get-Date).ToString("yyyy-MM-dd HH:mm")
    }
    $Profiles += $NewProfile
    Save-Profiles $Profiles
    Write-Color "`n   [✔] Profile '$Alias' saved successfully!" -Color Green

    # ==========================================================================
    # LOGIC MỚI: Tự động set Global Config nếu hiện tại đang là "Not Set"
    # ==========================================================================
    $Curr = Get-Git-Current
    if ($Curr.Name -eq "Not Set" -or $Curr.Name -eq $null) {
        git config --global user.name "$UName"
        git config --global user.email "$UEmail"
        Write-Color "   [INFO] Auto-set as Global Git Config (was previously unset)." -Color Cyan
    }
}

function Switch-Profile-Action {
    $Profiles = @(Load-Profiles)
    if ($Profiles.Count -eq 0) { Write-Color "`n   [!] No profiles. Add one first." "Yellow"; return }

    Write-Host "`n"
    Draw-Header "SWITCH PROFILE"
    
    # Header cột (Màu tối để làm nền)
    $Format = "     [{0}] {1,-15} {2}"
    Write-Host ($Format -f "#", "ALIAS", "EMAIL") -ForegroundColor DarkGray
    
    # Danh sách Profile
    for ($i = 0; $i -lt $Profiles.Count; $i++) {
        Write-Host ($Format -f ($i+1), $Profiles[$i].alias, $Profiles[$i].userEmail) -ForegroundColor White
    }
    Draw-Sep

    $Choice = Read-Host "   Choose ID (0 to cancel)"
    
    # Validate Input
    if ($Choice -eq "0" -or -not ($Choice -as [int])) { return }
    $Idx = [int]$Choice - 1
    if ($Idx -lt 0 -or $Idx -ge $Profiles.Count) { return }

    $Selected = $Profiles[$Idx]
    
    Write-Color "`n   [INFO] Switching to '$($Selected.alias)'..." -Color Cyan
    
    # 1. Change Global Config
    git config --global user.name "$($Selected.userName)"
    git config --global user.email "$($Selected.userEmail)"
    
    # 2. Update Repo URL (Local Override)
    Update-Repo-Url -Alias $Selected.alias

    # 3. Test SSH (Để đảm bảo key hoạt động tốt)
    if ($Selected.keyPath) {
        $null = Test-GitHub-Connection -Alias $Selected.alias
    }

    Write-Color "`n   [✔] Switched successfully!" -Color Green
    Write-Color "       Global User : $($Selected.userName)" -Color Gray
    Write-Color "       Global Email: $($Selected.userEmail)" -Color Gray
}

function Remove-Profile-Action {
    $Profiles = @(Load-Profiles)
    if ($Profiles.Count -eq 0) { Write-Color "`n   [!] No profiles to remove." "Yellow"; return }

    Write-Host "`n"
    Draw-Header "REMOVE PROFILE"
    
    # Hiển thị danh sách rõ ràng (Có cả Email)
    $Format = "     [{0}] {1,-15} {2}"
    Write-Host ($Format -f "#", "ALIAS", "EMAIL") -ForegroundColor DarkGray
    
    for ($i = 0; $i -lt $Profiles.Count; $i++) {
        Write-Host ($Format -f ($i+1), $Profiles[$i].alias, $Profiles[$i].userEmail) -ForegroundColor White
    }
    Draw-Sep

    $Choice = Read-Host "   Select ID to remove (0 to cancel)"
    
    # Validate Input
    if ($Choice -eq "0" -or -not ($Choice -as [int])) { return }
    $Idx = [int]$Choice - 1
    if ($Idx -lt 0 -or $Idx -ge $Profiles.Count) { return }

    $Removed = $Profiles[$Idx]
    
    Write-Color "`n   [WARNING] Deleting profile '$($Removed.alias)'..." "Red"
    $Confirm = Read-Host "   Type 'DELETE' to confirm"
    if ($Confirm -ne "DELETE") { return }

    # 1. Remove SSH Keys
    if ($Removed.keyPath) {
        if (Test-Path $Removed.keyPath) { Remove-Item $Removed.keyPath -Force; Write-Color "   [✔] Private Key deleted." "Gray" }
        if (Test-Path "$($Removed.keyPath).pub") { Remove-Item "$($Removed.keyPath).pub" -Force; Write-Color "   [✔] Public Key deleted." "Gray" }
    }

    # 2. Remove from SSH Config
    Remove-From-SSH-Config -Alias $Removed.alias

    # 3. Remove from JSON
    $NewProfiles = @($Profiles | Where-Object { $_.alias -ne $Removed.alias })
    
    if ($NewProfiles.Count -eq 0) {
        "[]" | Set-Content $ProfilesFile -Encoding UTF8
    } else {
        Save-Profiles $NewProfiles
    }

    # 4. Check & Clear Global Config
    $Curr = Get-Git-Current
    if ($Curr.Name -eq $Removed.userName) {
        git config --global --unset user.name
        git config --global --unset user.email
        Write-Color "   [INFO] Current Git config cleared because profile was removed." "Cyan"
    }

    Write-Color "   [✔] Profile removed successfully." "Green"
}

function Show-Settings-Action {
    Write-Host "`n"
    Draw-Header "SETTINGS & TOOLS"

    Write-Host "     [1] Open profiles.json (View/Edit DB)"
    Write-Host "     [2] Backup Profiles (Create snapshot)"
    Write-Host "     [3] Open .ssh folder (View Keys)"
    Write-Host "     [0] Back"
    
    Draw-Sep

    $Opt = Read-Host "   Choose"
    switch ($Opt) {
        "1" { Invoke-Item $ProfilesFile }
        "2" { 
            $Bak = "$BaseDir\backup_$(Get-Date -Format 'yyyyMMdd_HHmm').json"
            Copy-Item $ProfilesFile $Bak
            Write-Color "   [✔] Backup created: $Bak" "Green"
        }
        "3" { Invoke-Item $SSHDir }
    }
}


# -------------------------- MAIN UI --------------------------

function Show-Banner {
    $Art = @"
      ██████  ██ ████████     ███████ ██     ██ ██ ████████  ██████  ██   ██
     ██       ██    ██        ██      ██     ██ ██    ██    ██       ██   ██
     ██   ███ ██    ██        ███████ ██  █  ██ ██    ██    ██       ███████
     ██    ██ ██    ██             ██ ██ ███ ██ ██    ██    ██       ██   ██
      ██████  ██    ██        ███████  ███ ███  ██    ██     ██████  ██   ██
"@
    Write-Host $Art -ForegroundColor Magenta
    Draw-Sep
    
    $Curr = Get-Git-Current
    Write-Host "   » GIT PROFILE MANAGEMENT SYSTEM [v2.1]" -ForegroundColor White
    Draw-Sep
    
    $IsAdmin = ([Security.Principal.WindowsPrincipal][Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)
    
    if ($IsAdmin) {
        Write-Color "   [✔] STATUS: Running as Administrator" -Color Green
    } else {
        Write-Color "   [!] STATUS: Running as Standard User (Restrictions may apply)" -Color Yellow
    }

    Write-Host "   [●] CURRENT: " -NoNewline -ForegroundColor Cyan
    Write-Host "$($Curr.Name) " -NoNewline -ForegroundColor White
    Write-Host "<$($Curr.Email)>" -ForegroundColor DarkGray
    Draw-Sep
}

function Show-Menu {
    Write-Host ""
    Write-Host "   SELECT AN OPTION:" -ForegroundColor Gray
    Write-Host ""
    Write-Host "     [1] Add New Profile"
    Write-Host "     [2] Switch Profile"
    Write-Host "     [3] Remove Profile"
    Write-Host "     [4] Settings"
    Write-Host "     [5] Test Connection"
    Write-Host "     [0] Exit Program"
    Write-Host ""
    Draw-Sep
}
# ================= MAIN EXECUTION LOOP =================
$Running = $true
Initialize-System

do {
    Clear-Host
    Show-Banner
    Show-Menu
    $Selection = Read-Host "  Choose an option (0-5)"

    switch ($Selection) {
        "1" { Add-Profile-Action; Pause }
        "2" { Switch-Profile-Action; Pause }
        "3" { Remove-Profile-Action; Pause }
        "4" { Show-Settings-Action; Pause }
        "5" { Test-Connection-Action; Pause }  # <-- Mới thêm dòng này
        "0" { $Running = $false; Write-Color "`n  Goodbye! 👋" "Magenta" }
        default { Write-Color "  Invalid option." "Red"; Start-Sleep -Milliseconds 500 }
    }
} while ($Running)