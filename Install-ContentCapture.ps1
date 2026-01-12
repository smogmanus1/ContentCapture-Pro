# ============================================================================
# ContentCapture Pro - PowerShell Installer v2.1
# ============================================================================
# Fixed: AutoHotkey v2 silent install (uses /silent not /S)
# ============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

$AppName = "ContentCapture Pro"
$InstallFolder = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "ContentCapture Pro"

$RequiredFiles = @("ContentCapture-Pro.ahk", "DynamicSuffixHandler.ahk")
$OptionalFiles = @(
    "ContentCapture.ahk", "SocialShare.ahk", "ResearchTools.ahk", 
    "ImageCapture.ahk", "ImageClipboard.ahk", "AutoFormat_OpinionNote_Patch.ahk",
    "CC_Patches_Jan2026.ahk", "ContentCapture-Pro-Post.ahk", "ContentCapture-Setup.ahk",
    "README.md", "CHANGELOG.md", "LICENSE", "QUICK-START.md", "HOW-TO-CREATE-EXE.md"
)

function Show-Message {
    param ([string]$Title, [string]$Message, [string]$Type = "Info")
    $icon = switch ($Type) {
        "Info" { [System.Windows.Forms.MessageBoxIcon]::Information }
        "Warning" { [System.Windows.Forms.MessageBoxIcon]::Warning }
        "Error" { [System.Windows.Forms.MessageBoxIcon]::Error }
        default { [System.Windows.Forms.MessageBoxIcon]::Information }
    }
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
}

function Show-YesNo {
    param ([string]$Title, [string]$Message)
    $result = [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::YesNo, [System.Windows.Forms.MessageBoxIcon]::Question)
    return $result -eq [System.Windows.Forms.DialogResult]::Yes
}

function Write-Status { param ([string]$Message) Write-Host "`n  $Message" -ForegroundColor Cyan }
function Write-Success { param ([string]$Message) Write-Host "  [OK] $Message" -ForegroundColor Green }
function Write-Fail { param ([string]$Message) Write-Host "  [!] $Message" -ForegroundColor Red }
function Write-Info { param ([string]$Message) Write-Host "       $Message" -ForegroundColor Gray }

function Find-AutoHotkey {
    Write-Status "Searching for AutoHotkey v2..."
    
    # Method 1: Registry HKLM
    Write-Host "  Checking registry (HKLM)..." -ForegroundColor Gray
    try {
        $regPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\AutoHotkey" -ErrorAction SilentlyContinue
        if ($regPath -and $regPath.InstallDir) {
            $paths = @("$($regPath.InstallDir)\v2\AutoHotkey64.exe", "$($regPath.InstallDir)\v2\AutoHotkey32.exe", "$($regPath.InstallDir)\AutoHotkey64.exe", "$($regPath.InstallDir)\AutoHotkey.exe")
            foreach ($p in $paths) { if (Test-Path $p) { Write-Success "Found: $p"; return $p } }
        }
    } catch {}
    
    # Method 2: Registry HKCU
    Write-Host "  Checking registry (HKCU)..." -ForegroundColor Gray
    try {
        $regPath = Get-ItemProperty -Path "HKCU:\SOFTWARE\AutoHotkey" -ErrorAction SilentlyContinue
        if ($regPath -and $regPath.InstallDir) {
            $paths = @("$($regPath.InstallDir)\v2\AutoHotkey64.exe", "$($regPath.InstallDir)\v2\AutoHotkey32.exe")
            foreach ($p in $paths) { if (Test-Path $p) { Write-Success "Found: $p"; return $p } }
        }
    } catch {}
    
    # Method 3: File associations
    Write-Host "  Checking file associations..." -ForegroundColor Gray
    try {
        $assoc = Get-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\AutoHotkeyScript\Shell\Open\Command" -ErrorAction SilentlyContinue
        if ($assoc.'(default)') {
            $exePath = ($assoc.'(default)' -split '"')[1]
            if ($exePath -and (Test-Path $exePath)) { Write-Success "Found: $exePath"; return $exePath }
        }
    } catch {}
    
    # Method 4: Common paths
    Write-Host "  Checking common install locations..." -ForegroundColor Gray
    $commonPaths = @(
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey32.exe",
        "$env:ProgramFiles\AutoHotkey\AutoHotkey64.exe",
        "$env:ProgramFiles\AutoHotkey\AutoHotkey.exe",
        "$env:LocalAppData\Programs\AutoHotkey\v2\AutoHotkey64.exe",
        "$env:LocalAppData\Programs\AutoHotkey\v2\AutoHotkey32.exe"
    )
    foreach ($p in $commonPaths) { if (Test-Path $p) { Write-Success "Found: $p"; return $p } }
    
    # Method 5: PATH
    Write-Host "  Checking system PATH..." -ForegroundColor Gray
    foreach ($exe in @("AutoHotkey64.exe", "AutoHotkey.exe", "AutoHotkey32.exe")) {
        $found = Get-Command $exe -ErrorAction SilentlyContinue
        if ($found) { Write-Success "Found: $($found.Source)"; return $found.Source }
    }
    
    Write-Fail "AutoHotkey v2 not found"
    return $null
}

function Install-AutoHotkey {
    Write-Status "Installing AutoHotkey v2..."
    
    $tempDir = "$env:TEMP\ContentCaptureInstall"
    $installerPath = "$tempDir\ahk-setup.exe"
    
    if (-not (Test-Path $tempDir)) { New-Item -ItemType Directory -Path $tempDir -Force | Out-Null }
    
    # Check for bundled installer
    $bundledInstaller = Join-Path $PSScriptRoot "AutoHotkey-v2-setup.exe"
    
    if (Test-Path $bundledInstaller) {
        Write-Host "  Using bundled installer..." -ForegroundColor Gray
        Copy-Item $bundledInstaller $installerPath -Force
    } else {
        Write-Host "  Downloading AutoHotkey v2..." -ForegroundColor Gray
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri "https://www.autohotkey.com/download/ahk-v2.exe" -OutFile $installerPath -UseBasicParsing
        } catch {
            Write-Fail "Download failed"
            return $null
        }
    }
    
    if (-not (Test-Path $installerPath)) { Write-Fail "Installer not found"; return $null }
    
    # AutoHotkey v2 installer - just run it normally and let user click through
    # The /S and /silent flags don't work reliably with AHK v2 installer
    Write-Host "  Launching AutoHotkey installer..." -ForegroundColor Yellow
    Write-Host "  Please follow the installation prompts." -ForegroundColor Yellow
    
    $process = Start-Process -FilePath $installerPath -Wait -PassThru
    
    # Cleanup
    Start-Sleep -Seconds 2
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    Remove-Item $tempDir -Force -Recurse -ErrorAction SilentlyContinue
    
    # Verify
    $ahkPath = Find-AutoHotkey
    if ($ahkPath) { Write-Success "AutoHotkey v2 installed!"; return $ahkPath }
    
    Write-Fail "Installation could not be verified"
    return $null
}

function Install-ContentCaptureFiles {
    param ([string]$SourceDir, [string]$DestDir)
    
    Write-Status "Installing ContentCapture Pro files..."
    Write-Info "From: $SourceDir"
    Write-Info "To: $DestDir"
    
    if (-not (Test-Path $DestDir)) {
        try { New-Item -ItemType Directory -Path $DestDir -Force | Out-Null; Write-Success "Created folder" }
        catch { Write-Fail "Could not create folder"; return $false }
    }
    
    # Create subdirectories
    foreach ($sub in @("backups", "docs", "images")) {
        $subPath = Join-Path $DestDir $sub
        if (-not (Test-Path $subPath)) { New-Item -ItemType Directory -Path $subPath -Force | Out-Null }
    }
    
    # Copy files
    $copied = 0
    foreach ($file in ($RequiredFiles + $OptionalFiles)) {
        $src = Join-Path $SourceDir $file
        $dst = Join-Path $DestDir $file
        if (Test-Path $src) {
            try { Copy-Item $src $dst -Force; Write-Host "  Copied: $file" -ForegroundColor Gray; $copied++ }
            catch { if ($file -in $RequiredFiles) { Write-Fail "Failed: $file"; return $false } }
        }
    }
    
    # Copy docs folder
    $docsSource = Join-Path $SourceDir "docs"
    if (Test-Path $docsSource) { Copy-Item "$docsSource\*" (Join-Path $DestDir "docs") -Recurse -Force -ErrorAction SilentlyContinue }
    
    Write-Success "Copied $copied files"
    return $true
}

# ============================================================================
# MAIN
# ============================================================================

Clear-Host
Write-Host "`n  ============================================================" -ForegroundColor Cyan
Write-Host "     CONTENTCAPTURE PRO - INSTALLER v2.1" -ForegroundColor White
Write-Host "  ============================================================" -ForegroundColor Cyan

$SourceDir = $PSScriptRoot
if (-not $SourceDir) { $SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $SourceDir) { $SourceDir = (Get-Location).Path }

# Check location
if ($SourceDir -like "*\Downloads\*") {
    Write-Host "`n  [!] Running from: Downloads folder" -ForegroundColor Yellow
    Write-Host "  The installer will copy files to:" -ForegroundColor White
    Write-Host "  $InstallFolder" -ForegroundColor Green
}

# Check for main script
if (-not (Test-Path (Join-Path $SourceDir "ContentCapture-Pro.ahk"))) {
    Show-Message -Title "Files Not Found" -Message "Could not find ContentCapture-Pro.ahk`n`nMake sure you extracted the ZIP file." -Type "Error"
    exit 1
}

# Welcome
$msg = "Welcome to ContentCapture Pro!`n`nThis installer will:`n"
$msg += "  1. Install files to:`n       $InstallFolder`n"
$msg += "  2. Install AutoHotkey v2 if needed`n"
$msg += "  3. Launch ContentCapture Pro`n"
$msg += "  4. Optionally add to Windows startup`n`nContinue?"

if (-not (Show-YesNo -Title "ContentCapture Pro Installer" -Message $msg)) {
    Write-Host "  Cancelled." -ForegroundColor Yellow
    exit 0
}

# Step 1: Copy files
Write-Host "`n  Step 1 of 4: Installing Files" -ForegroundColor White
Write-Host "  ------------------------------" -ForegroundColor Gray

if ($SourceDir -eq $InstallFolder) {
    Write-Success "Already in install location"
} else {
    if (-not (Install-ContentCaptureFiles -SourceDir $SourceDir -DestDir $InstallFolder)) {
        Show-Message -Title "Failed" -Message "Could not copy files.`nTry running as administrator." -Type "Error"
        exit 1
    }
}

$AppDir = $InstallFolder

# Step 2: AutoHotkey
Write-Host "`n  Step 2 of 4: AutoHotkey v2" -ForegroundColor White
Write-Host "  --------------------------" -ForegroundColor Gray

$ahkPath = Find-AutoHotkey

if (-not $ahkPath) {
    if (Show-YesNo -Title "AutoHotkey Required" -Message "AutoHotkey v2 is not installed.`n`nInstall it now?") {
        $ahkPath = Install-AutoHotkey
    }
    if (-not $ahkPath) {
        Show-Message -Title "Required" -Message "Please install AutoHotkey v2 from:`nhttps://www.autohotkey.com/download/`n`nThen run this installer again." -Type "Warning"
        Start-Process "https://www.autohotkey.com/download/"
        exit 1
    }
}

# Step 3: Launch
Write-Host "`n  Step 3 of 4: Launching" -ForegroundColor White
Write-Host "  ----------------------" -ForegroundColor Gray

$mainScript = Join-Path $AppDir "ContentCapture-Pro.ahk"
if (-not (Test-Path $mainScript)) { $mainScript = Join-Path $AppDir "ContentCapture.ahk" }

if (-not (Test-Path $mainScript)) {
    Show-Message -Title "Error" -Message "Could not find script in:`n$AppDir" -Type "Error"
    exit 1
}

Write-Success "Found: $mainScript"
try {
    Start-Process -FilePath $ahkPath -ArgumentList "`"$mainScript`"" -WorkingDirectory $AppDir
    Start-Sleep -Seconds 2
    Write-Success "ContentCapture Pro is running!"
    Write-Info "Look for the green H icon in your system tray"
} catch {
    Write-Fail "Launch failed: $_"
    exit 1
}

# Step 4: Startup
Write-Host "`n  Step 4 of 4: Windows Startup" -ForegroundColor White
Write-Host "  ----------------------------" -ForegroundColor Gray

if (Show-YesNo -Title "Startup" -Message "Add ContentCapture Pro to Windows startup?`n`n(Recommended: Yes)") {
    try {
        $startupFolder = [Environment]::GetFolderPath('Startup')
        $shortcut = (New-Object -ComObject WScript.Shell).CreateShortcut("$startupFolder\ContentCapture Pro.lnk")
        $shortcut.TargetPath = $ahkPath
        $shortcut.Arguments = "`"$mainScript`""
        $shortcut.WorkingDirectory = $AppDir
        $shortcut.Save()
        Write-Success "Added to startup!"
    } catch { Write-Fail "Could not add to startup" }
}

# Done
Write-Host "`n  ============================================================" -ForegroundColor Green
Write-Host "     INSTALLATION COMPLETE!" -ForegroundColor White
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host "`n  Installed to: $AppDir"
Write-Host "`n  QUICK START:" -ForegroundColor Cyan
Write-Host "    Ctrl+Alt+P      Capture webpage" -ForegroundColor Gray
Write-Host "    Ctrl+Alt+B      Browse captures" -ForegroundColor Gray
Write-Host "    Ctrl+Alt+H      Show help" -ForegroundColor Gray

Show-Message -Title "Complete!" -Message "ContentCapture Pro is running!`n`nLook for the green H icon in your system tray.`n`nQuick Start:`n  Ctrl+Alt+P - Capture`n  Ctrl+Alt+B - Browse`n  Ctrl+Alt+H - Help" -Type "Info"

Start-Process "explorer.exe" -ArgumentList $AppDir
