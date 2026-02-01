<# 
.SYNOPSIS
    ContentCapture Pro Installer v6.2.1
    
.DESCRIPTION
    One-click installer that handles everything:
    - Checks/installs AutoHotkey v2
    - Creates install directory
    - Copies all files
    - Preserves existing data on upgrades
    - Creates shortcuts
    - Launches the application
    
.NOTES
    Author: Brad
    Version: 6.2.1
    Right-click this file → "Run with PowerShell"
#>

# ============================================================================
# CONFIGURATION
# ============================================================================

$AppName = "ContentCapture Pro"
$AppVersion = "6.2.1"
$AppExe = "ContentCapture.ahk"
$DefaultInstallPath = "$env:USERPROFILE\ContentCapture-Pro"
$AHKInstallerName = "AutoHotkey-v2-setup.exe"
$MinAHKVersion = "2.0"

# Files that contain user data (preserve on upgrade)
$UserDataFiles = @(
    "captures.dat",
    "capturesarchive.dat", 
    "capturesbackup.dat",
    "capture_index.txt",
    "captures_export.html",
    "config.ini",
    "contentcapture_log.txt",
    "personal-shortcuts.ahk"
)

$UserDataFolders = @(
    "images",
    "backups"
)

# ============================================================================
# GUI SETUP
# ============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Write-Log {
    param([string]$Message, [string]$Color = "White")
    $timestamp = Get-Date -Format "HH:mm:ss"
    Write-Host "[$timestamp] $Message" -ForegroundColor $Color
}

function Test-AutoHotkeyV2 {
    # Check registry for AHK v2
    $ahkPaths = @(
        "HKLM:\SOFTWARE\AutoHotkey",
        "HKCU:\SOFTWARE\AutoHotkey",
        "HKLM:\SOFTWARE\WOW6432Node\AutoHotkey"
    )
    
    foreach ($path in $ahkPaths) {
        if (Test-Path $path) {
            try {
                $version = (Get-ItemProperty $path -ErrorAction SilentlyContinue).Version
                if ($version -and $version -match "^2\.") {
                    return $true
                }
            } catch {}
        }
    }
    
    # Check if AutoHotkey64.exe exists and is v2
    $ahkExe = "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey64.exe"
    if (Test-Path $ahkExe) {
        return $true
    }
    
    $ahkExe = "${env:ProgramFiles}\AutoHotkey\AutoHotkey64.exe"
    if (Test-Path $ahkExe) {
        # Could be v1 or v2, check version
        try {
            $versionInfo = (Get-Item $ahkExe).VersionInfo.ProductVersion
            if ($versionInfo -match "^2\.") {
                return $true
            }
        } catch {}
    }
    
    return $false
}

function Install-AutoHotkeyV2 {
    param([string]$InstallerPath)
    
    if (-not (Test-Path $InstallerPath)) {
        return $false
    }
    
    Write-Log "Installing AutoHotkey v2..." "Yellow"
    
    try {
        # Silent install
        $process = Start-Process -FilePath $InstallerPath -ArgumentList "/silent" -Wait -PassThru
        
        if ($process.ExitCode -eq 0) {
            Write-Log "AutoHotkey v2 installed successfully!" "Green"
            return $true
        } else {
            Write-Log "AutoHotkey installer returned code: $($process.ExitCode)" "Yellow"
            # Try UI install as fallback
            Start-Process -FilePath $InstallerPath -Wait
            return (Test-AutoHotkeyV2)
        }
    } catch {
        Write-Log "Error during AHK install: $_" "Red"
        return $false
    }
}

function Get-InstallPath {
    # Show folder picker dialog
    $folderBrowser = New-Object System.Windows.Forms.FolderBrowserDialog
    $folderBrowser.Description = "Choose where to install $AppName"
    $folderBrowser.SelectedPath = $DefaultInstallPath
    $folderBrowser.ShowNewFolderButton = $true
    
    # Create a hidden form to own the dialog (fixes focus issues)
    $form = New-Object System.Windows.Forms.Form
    $form.TopMost = $true
    $form.WindowState = 'Minimized'
    $form.Show()
    $form.Hide()
    
    $result = $folderBrowser.ShowDialog($form)
    $form.Dispose()
    
    if ($result -eq [System.Windows.Forms.DialogResult]::OK) {
        return $folderBrowser.SelectedPath
    }
    
    return $null
}

function Backup-UserData {
    param([string]$InstallPath)
    
    $backupPath = "$env:TEMP\ContentCapture-Backup-$(Get-Date -Format 'yyyyMMdd-HHmmss')"
    $hasData = $false
    
    # Check if there's data to backup
    foreach ($file in $UserDataFiles) {
        if (Test-Path "$InstallPath\$file") {
            $hasData = $true
            break
        }
    }
    
    foreach ($folder in $UserDataFolders) {
        if (Test-Path "$InstallPath\$folder") {
            $hasData = $true
            break
        }
    }
    
    if (-not $hasData) {
        return $null
    }
    
    Write-Log "Backing up user data..." "Cyan"
    New-Item -ItemType Directory -Path $backupPath -Force | Out-Null
    
    foreach ($file in $UserDataFiles) {
        $sourcePath = "$InstallPath\$file"
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath "$backupPath\" -Force
            Write-Log "  Backed up: $file" "Gray"
        }
    }
    
    foreach ($folder in $UserDataFolders) {
        $sourcePath = "$InstallPath\$folder"
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath "$backupPath\" -Recurse -Force
            Write-Log "  Backed up: $folder\" "Gray"
        }
    }
    
    return $backupPath
}

function Restore-UserData {
    param([string]$BackupPath, [string]$InstallPath)
    
    if (-not $BackupPath -or -not (Test-Path $BackupPath)) {
        return
    }
    
    Write-Log "Restoring user data..." "Cyan"
    
    foreach ($file in $UserDataFiles) {
        $sourcePath = "$BackupPath\$file"
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath "$InstallPath\" -Force
            Write-Log "  Restored: $file" "Gray"
        }
    }
    
    foreach ($folder in $UserDataFolders) {
        $sourcePath = "$BackupPath\$folder"
        if (Test-Path $sourcePath) {
            Copy-Item $sourcePath "$InstallPath\" -Recurse -Force
            Write-Log "  Restored: $folder\" "Gray"
        }
    }
}

function Create-Shortcut {
    param(
        [string]$ShortcutPath,
        [string]$TargetPath,
        [string]$Arguments = "",
        [string]$WorkingDir = "",
        [string]$IconPath = "",
        [string]$Description = ""
    )
    
    try {
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($ShortcutPath)
        $shortcut.TargetPath = $TargetPath
        
        if ($Arguments) { $shortcut.Arguments = $Arguments }
        if ($WorkingDir) { $shortcut.WorkingDirectory = $WorkingDir }
        if ($IconPath) { $shortcut.IconLocation = $IconPath }
        if ($Description) { $shortcut.Description = $Description }
        
        $shortcut.Save()
        return $true
    } catch {
        Write-Log "Failed to create shortcut: $_" "Red"
        return $false
    }
}

function Show-WelcomeDialog {
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "$AppName Installer"
    $form.Size = New-Object System.Drawing.Size(500, 350)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 46)
    
    # Title
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "ContentCapture Pro"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 20, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = [System.Drawing.Color]::White
    $titleLabel.AutoSize = $true
    $titleLabel.Location = New-Object System.Drawing.Point(30, 20)
    $form.Controls.Add($titleLabel)
    
    # Version
    $versionLabel = New-Object System.Windows.Forms.Label
    $versionLabel.Text = "Version $AppVersion"
    $versionLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $versionLabel.ForeColor = [System.Drawing.Color]::FromArgb(166, 173, 200)
    $versionLabel.AutoSize = $true
    $versionLabel.Location = New-Object System.Drawing.Point(32, 58)
    $form.Controls.Add($versionLabel)
    
    # Description
    $descLabel = New-Object System.Windows.Forms.Label
    $descLabel.Text = "Capture web content with one hotkey (Ctrl+Alt+G)`nRecall it instantly by typing a memorable name`n`nThis installer will:`n  • Check/install AutoHotkey v2 if needed`n  • Install ContentCapture Pro`n  • Create Start Menu shortcut`n  • Preserve your existing data (if upgrading)"
    $descLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $descLabel.ForeColor = [System.Drawing.Color]::FromArgb(205, 214, 244)
    $descLabel.AutoSize = $true
    $descLabel.Location = New-Object System.Drawing.Point(32, 95)
    $form.Controls.Add($descLabel)
    
    # Install button
    $installBtn = New-Object System.Windows.Forms.Button
    $installBtn.Text = "Install"
    $installBtn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $installBtn.Size = New-Object System.Drawing.Size(120, 40)
    $installBtn.Location = New-Object System.Drawing.Point(150, 255)
    $installBtn.BackColor = [System.Drawing.Color]::FromArgb(137, 180, 250)
    $installBtn.ForeColor = [System.Drawing.Color]::FromArgb(30, 30, 46)
    $installBtn.FlatStyle = "Flat"
    $installBtn.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($installBtn)
    
    # Cancel button
    $cancelBtn = New-Object System.Windows.Forms.Button
    $cancelBtn.Text = "Cancel"
    $cancelBtn.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $cancelBtn.Size = New-Object System.Drawing.Size(100, 40)
    $cancelBtn.Location = New-Object System.Drawing.Point(280, 255)
    $cancelBtn.BackColor = [System.Drawing.Color]::FromArgb(69, 71, 90)
    $cancelBtn.ForeColor = [System.Drawing.Color]::White
    $cancelBtn.FlatStyle = "Flat"
    $cancelBtn.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
    $form.Controls.Add($cancelBtn)
    
    $form.AcceptButton = $installBtn
    $form.CancelButton = $cancelBtn
    
    return $form.ShowDialog()
}

function Show-CompleteDialog {
    param([string]$InstallPath, [bool]$LaunchNow = $true)
    
    $form = New-Object System.Windows.Forms.Form
    $form.Text = "Installation Complete"
    $form.Size = New-Object System.Drawing.Size(450, 280)
    $form.StartPosition = "CenterScreen"
    $form.FormBorderStyle = "FixedDialog"
    $form.MaximizeBox = $false
    $form.MinimizeBox = $false
    $form.TopMost = $true
    $form.BackColor = [System.Drawing.Color]::FromArgb(30, 30, 46)
    
    # Success icon (checkmark)
    $successLabel = New-Object System.Windows.Forms.Label
    $successLabel.Text = "✓"
    $successLabel.Font = New-Object System.Drawing.Font("Segoe UI", 36)
    $successLabel.ForeColor = [System.Drawing.Color]::FromArgb(166, 227, 161)
    $successLabel.AutoSize = $true
    $successLabel.Location = New-Object System.Drawing.Point(30, 20)
    $form.Controls.Add($successLabel)
    
    # Title
    $titleLabel = New-Object System.Windows.Forms.Label
    $titleLabel.Text = "Installation Complete!"
    $titleLabel.Font = New-Object System.Drawing.Font("Segoe UI", 16, [System.Drawing.FontStyle]::Bold)
    $titleLabel.ForeColor = [System.Drawing.Color]::White
    $titleLabel.AutoSize = $true
    $titleLabel.Location = New-Object System.Drawing.Point(85, 30)
    $form.Controls.Add($titleLabel)
    
    # Info
    $infoLabel = New-Object System.Windows.Forms.Label
    $infoLabel.Text = "ContentCapture Pro has been installed to:`n$InstallPath`n`nPress Ctrl+Alt+G to capture any webpage!`nType your capture name + space to paste it."
    $infoLabel.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $infoLabel.ForeColor = [System.Drawing.Color]::FromArgb(205, 214, 244)
    $infoLabel.AutoSize = $true
    $infoLabel.Location = New-Object System.Drawing.Point(32, 85)
    $form.Controls.Add($infoLabel)
    
    # Launch checkbox
    $launchCheck = New-Object System.Windows.Forms.CheckBox
    $launchCheck.Text = "Launch ContentCapture Pro now"
    $launchCheck.Font = New-Object System.Drawing.Font("Segoe UI", 10)
    $launchCheck.ForeColor = [System.Drawing.Color]::White
    $launchCheck.Checked = $LaunchNow
    $launchCheck.AutoSize = $true
    $launchCheck.Location = New-Object System.Drawing.Point(32, 175)
    $form.Controls.Add($launchCheck)
    
    # Finish button
    $finishBtn = New-Object System.Windows.Forms.Button
    $finishBtn.Text = "Finish"
    $finishBtn.Font = New-Object System.Drawing.Font("Segoe UI", 11, [System.Drawing.FontStyle]::Bold)
    $finishBtn.Size = New-Object System.Drawing.Size(120, 40)
    $finishBtn.Location = New-Object System.Drawing.Point(160, 210)
    $finishBtn.BackColor = [System.Drawing.Color]::FromArgb(137, 180, 250)
    $finishBtn.ForeColor = [System.Drawing.Color]::FromArgb(30, 30, 46)
    $finishBtn.FlatStyle = "Flat"
    $finishBtn.DialogResult = [System.Windows.Forms.DialogResult]::OK
    $form.Controls.Add($finishBtn)
    
    $form.AcceptButton = $finishBtn
    $form.ShowDialog() | Out-Null
    
    return $launchCheck.Checked
}

function Show-ErrorDialog {
    param([string]$Message)
    
    [System.Windows.Forms.MessageBox]::Show(
        $Message,
        "Installation Error",
        [System.Windows.Forms.MessageBoxButtons]::OK,
        [System.Windows.Forms.MessageBoxIcon]::Error
    )
}

# ============================================================================
# MAIN INSTALLATION LOGIC
# ============================================================================

Clear-Host
Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  ContentCapture Pro Installer v$AppVersion" -ForegroundColor Cyan
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory (where installer is running from)
$ScriptDir = Split-Path -Parent $MyInvocation.MyCommand.Path
if (-not $ScriptDir) { $ScriptDir = Get-Location }

Write-Log "Installer location: $ScriptDir"

# Show welcome dialog
$welcomeResult = Show-WelcomeDialog
if ($welcomeResult -ne [System.Windows.Forms.DialogResult]::OK) {
    Write-Log "Installation cancelled by user." "Yellow"
    exit 0
}

# Step 1: Check AutoHotkey v2
Write-Log "Checking for AutoHotkey v2..." "Cyan"

if (Test-AutoHotkeyV2) {
    Write-Log "AutoHotkey v2 is installed ✓" "Green"
} else {
    Write-Log "AutoHotkey v2 not found." "Yellow"
    
    $ahkInstaller = Join-Path $ScriptDir $AHKInstallerName
    
    if (Test-Path $ahkInstaller) {
        $msgResult = [System.Windows.Forms.MessageBox]::Show(
            "AutoHotkey v2 is required but not installed.`n`nWould you like to install it now?",
            "AutoHotkey Required",
            [System.Windows.Forms.MessageBoxButtons]::YesNo,
            [System.Windows.Forms.MessageBoxIcon]::Question
        )
        
        if ($msgResult -eq [System.Windows.Forms.DialogResult]::Yes) {
            if (-not (Install-AutoHotkeyV2 -InstallerPath $ahkInstaller)) {
                Show-ErrorDialog "Failed to install AutoHotkey v2.`n`nPlease install it manually from:`nhttps://www.autohotkey.com/download/"
                exit 1
            }
        } else {
            Show-ErrorDialog "AutoHotkey v2 is required to run ContentCapture Pro.`n`nPlease install it from:`nhttps://www.autohotkey.com/download/"
            exit 1
        }
    } else {
        Show-ErrorDialog "AutoHotkey v2 is required but the installer was not found.`n`nPlease download and install AutoHotkey v2 from:`nhttps://www.autohotkey.com/download/`n`nThen run this installer again."
        exit 1
    }
}

# Step 2: Choose install location
Write-Log "Choose installation folder..." "Cyan"

# Check if running from an existing install (upgrade scenario)
$existingInstall = Test-Path (Join-Path $ScriptDir "captures.dat")
if ($existingInstall) {
    $msgResult = [System.Windows.Forms.MessageBox]::Show(
        "It looks like ContentCapture Pro is already installed here.`n`nWould you like to upgrade in place?`n`nYour captures and settings will be preserved.",
        "Upgrade Detected",
        [System.Windows.Forms.MessageBoxButtons]::YesNo,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    if ($msgResult -eq [System.Windows.Forms.DialogResult]::Yes) {
        $InstallPath = $ScriptDir
    } else {
        $InstallPath = Get-InstallPath
    }
} else {
    # Fresh install - ask for location
    $msgResult = [System.Windows.Forms.MessageBox]::Show(
        "Install to default location?`n`n$DefaultInstallPath`n`nClick 'No' to choose a different folder.",
        "Install Location",
        [System.Windows.Forms.MessageBoxButtons]::YesNoCancel,
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    if ($msgResult -eq [System.Windows.Forms.DialogResult]::Yes) {
        $InstallPath = $DefaultInstallPath
    } elseif ($msgResult -eq [System.Windows.Forms.DialogResult]::No) {
        $InstallPath = Get-InstallPath
    } else {
        Write-Log "Installation cancelled." "Yellow"
        exit 0
    }
}

if (-not $InstallPath) {
    Write-Log "No install path selected. Installation cancelled." "Yellow"
    exit 0
}

Write-Log "Install path: $InstallPath" "Green"

# Step 3: Backup existing data
$BackupPath = Backup-UserData -InstallPath $InstallPath

# Step 4: Create install directory
if (-not (Test-Path $InstallPath)) {
    Write-Log "Creating install directory..." "Cyan"
    New-Item -ItemType Directory -Path $InstallPath -Force | Out-Null
}

# Step 5: Copy files
Write-Log "Copying files..." "Cyan"

$filesToCopy = @(
    "CC_Clipboard.ahk",
    "CC_HoverPreview.ahk",
    "CC_ShareModule.ahk",
    "ContentCapture.ahk",
    "ContentCapture-Pro.ahk",
    "DynamicSuffixHandler.ahk",
    "ImageCapture.ahk",
    "ImageClipboard.ahk",
    "ImageDatabase.ahk",
    "ImageSharing.ahk",
    "ResearchTools.ahk",
    "SocialShare.ahk",
    "ContentCapture_Generated.ahk"
)

$copiedCount = 0
foreach ($file in $filesToCopy) {
    $sourcePath = Join-Path $ScriptDir $file
    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath $InstallPath -Force
        Write-Log "  Copied: $file" "Gray"
        $copiedCount++
    }
}

# Copy documentation if present
$docFiles = @("README.md", "CHANGELOG.md", "LICENSE", "INSTALL.md", "QUICK-START.md", "TROUBLESHOOTING.md", "SUFFIX-REFERENCE.md", "USER_MANUAL.md", "ROADMAP.md")
foreach ($file in $docFiles) {
    $sourcePath = Join-Path $ScriptDir $file
    if (Test-Path $sourcePath) {
        Copy-Item $sourcePath $InstallPath -Force
    }
}

# Copy AHK installer for future use
$ahkInstaller = Join-Path $ScriptDir $AHKInstallerName
if (Test-Path $ahkInstaller) {
    Copy-Item $ahkInstaller $InstallPath -Force
}

Write-Log "Copied $copiedCount application files" "Green"

# Step 6: Restore user data
Restore-UserData -BackupPath $BackupPath -InstallPath $InstallPath

# Step 7: Create images folder if it doesn't exist
$imagesPath = Join-Path $InstallPath "images"
if (-not (Test-Path $imagesPath)) {
    New-Item -ItemType Directory -Path $imagesPath -Force | Out-Null
    Write-Log "Created images folder" "Gray"
}

# Step 8: Create Start Menu shortcut
Write-Log "Creating shortcuts..." "Cyan"

$startMenuPath = "$env:APPDATA\Microsoft\Windows\Start Menu\Programs"
$shortcutPath = Join-Path $startMenuPath "ContentCapture Pro.lnk"

# Find AutoHotkey executable
$ahkExe = "${env:ProgramFiles}\AutoHotkey\v2\AutoHotkey64.exe"
if (-not (Test-Path $ahkExe)) {
    $ahkExe = "${env:ProgramFiles}\AutoHotkey\AutoHotkey64.exe"
}
if (-not (Test-Path $ahkExe)) {
    $ahkExe = "${env:ProgramFiles}\AutoHotkey\AutoHotkey.exe"
}

$targetScript = Join-Path $InstallPath $AppExe

if (Test-Path $ahkExe) {
    Create-Shortcut -ShortcutPath $shortcutPath `
                    -TargetPath $ahkExe `
                    -Arguments "`"$targetScript`"" `
                    -WorkingDir $InstallPath `
                    -Description "ContentCapture Pro - Capture and recall web content instantly"
    Write-Log "Created Start Menu shortcut ✓" "Green"
} else {
    # Fallback: create shortcut directly to .ahk file (requires AHK file association)
    Create-Shortcut -ShortcutPath $shortcutPath `
                    -TargetPath $targetScript `
                    -WorkingDir $InstallPath `
                    -Description "ContentCapture Pro - Capture and recall web content instantly"
    Write-Log "Created Start Menu shortcut ✓" "Green"
}

# Step 9: Show completion dialog and optionally launch
Write-Host ""
Write-Log "Installation complete!" "Green"
Write-Host ""

$shouldLaunch = Show-CompleteDialog -InstallPath $InstallPath -LaunchNow $true

if ($shouldLaunch) {
    Write-Log "Launching ContentCapture Pro..." "Cyan"
    
    if (Test-Path $ahkExe) {
        Start-Process -FilePath $ahkExe -ArgumentList "`"$targetScript`"" -WorkingDirectory $InstallPath
    } else {
        Start-Process -FilePath $targetScript -WorkingDirectory $InstallPath
    }
    
    Write-Log "ContentCapture Pro is now running!" "Green"
    Write-Log "Look for the icon in your system tray." "Gray"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor Cyan
Write-Host "  Installation Complete!" -ForegroundColor Green
Write-Host "========================================" -ForegroundColor Cyan
Write-Host ""
Write-Host "Press any key to exit..."
$null = $Host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
