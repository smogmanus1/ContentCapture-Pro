# ============================================================================
# ContentCapture Pro - PowerShell Installer v2.0
# ============================================================================
# Grandma-proof installer that:
#   - Automatically installs to Documents\ContentCapture Pro
#   - Warns if running from Downloads or inside a ZIP
#   - GUI message boxes for all prompts
#   - Silent AutoHotkey installation
#   - 5 detection methods for existing AHK installs
#   - Proper error handling
# ============================================================================

Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName PresentationFramework

# ============================================================================
# CONFIGURATION
# ============================================================================

$AppName = "ContentCapture Pro"
$InstallFolder = Join-Path ([Environment]::GetFolderPath('MyDocuments')) "ContentCapture Pro"

# Files required for the app to run
$RequiredFiles = @(
    "ContentCapture-Pro.ahk",
    "DynamicSuffixHandler.ahk"
)

# Optional files to copy if present
$OptionalFiles = @(
    "ContentCapture.ahk",
    "SocialShare.ahk",
    "ResearchTools.ahk",
    "ImageCapture.ahk",
    "ImageClipboard.ahk",
    "AutoFormat_OpinionNote_Patch.ahk",
    "CC_Patches_Jan2026.ahk",
    "ContentCapture-Pro-Post.ahk",
    "README.md",
    "CHANGELOG.md",
    "LICENSE",
    "FEATURES.md",
    "FEATURES.txt",
    "FEATURES-SHORT.md"
)

# ============================================================================
# HELPER FUNCTIONS
# ============================================================================

function Show-Message {
    param (
        [string]$Title,
        [string]$Message,
        [string]$Type = "Info"
    )
    
    $icon = switch ($Type) {
        "Info"    { [System.Windows.Forms.MessageBoxIcon]::Information }
        "Warning" { [System.Windows.Forms.MessageBoxIcon]::Warning }
        "Error"   { [System.Windows.Forms.MessageBoxIcon]::Error }
        "Question" { [System.Windows.Forms.MessageBoxIcon]::Question }
        default   { [System.Windows.Forms.MessageBoxIcon]::Information }
    }
    
    [System.Windows.Forms.MessageBox]::Show($Message, $Title, [System.Windows.Forms.MessageBoxButtons]::OK, $icon)
}

function Show-YesNo {
    param (
        [string]$Title,
        [string]$Message
    )
    
    $result = [System.Windows.Forms.MessageBox]::Show(
        $Message, 
        $Title, 
        [System.Windows.Forms.MessageBoxButtons]::YesNo, 
        [System.Windows.Forms.MessageBoxIcon]::Question
    )
    
    return $result -eq [System.Windows.Forms.DialogResult]::Yes
}

function Write-Status {
    param ([string]$Message)
    Write-Host ""
    Write-Host "  $Message" -ForegroundColor Cyan
    Write-Host ""
}

function Write-Success {
    param ([string]$Message)
    Write-Host "  [OK] $Message" -ForegroundColor Green
}

function Write-Fail {
    param ([string]$Message)
    Write-Host "  [!] $Message" -ForegroundColor Red
}

function Write-Info {
    param ([string]$Message)
    Write-Host "       $Message" -ForegroundColor Gray
}

# ============================================================================
# LOCATION CHECK
# ============================================================================

function Test-BadLocation {
    param ([string]$Path)
    
    $Path = $Path.ToLower()
    
    # Check for Downloads folder
    if ($Path -like "*\downloads\*" -or $Path -like "*\downloads") {
        return "Downloads folder"
    }
    
    # Check for Temp folder
    if ($Path -like "*\temp\*" -or $Path -like "*\tmp\*") {
        return "Temporary folder"
    }
    
    # Check for ZIP extraction temp folders
    if ($Path -like "*\appdata\local\temp\*") {
        return "ZIP temporary folder"
    }
    
    # Check for Desktop (not ideal but allowed)
    # if ($Path -like "*\desktop\*") {
    #     return "Desktop"
    # }
    
    return $null
}

# ============================================================================
# AUTOHOTKEY DETECTION (5 Methods)
# ============================================================================

function Find-AutoHotkey {
    Write-Status "Searching for AutoHotkey v2..."
    
    $ahkPath = $null
    $method = ""
    
    # Method 1: Registry HKLM
    Write-Host "  Checking registry (HKLM)..." -ForegroundColor Gray
    try {
        $regPath = Get-ItemProperty -Path "HKLM:\SOFTWARE\AutoHotkey" -ErrorAction SilentlyContinue
        if ($regPath -and $regPath.InstallDir) {
            $possiblePaths = @(
                "$($regPath.InstallDir)\v2\AutoHotkey64.exe",
                "$($regPath.InstallDir)\v2\AutoHotkey32.exe",
                "$($regPath.InstallDir)\AutoHotkey64.exe",
                "$($regPath.InstallDir)\AutoHotkey.exe"
            )
            foreach ($p in $possiblePaths) {
                if (Test-Path $p) {
                    $ahkPath = $p
                    $method = "Registry (HKLM)"
                    break
                }
            }
        }
    } catch {}
    
    # Method 2: Registry HKCU
    if (-not $ahkPath) {
        Write-Host "  Checking registry (HKCU)..." -ForegroundColor Gray
        try {
            $regPath = Get-ItemProperty -Path "HKCU:\SOFTWARE\AutoHotkey" -ErrorAction SilentlyContinue
            if ($regPath -and $regPath.InstallDir) {
                $possiblePaths = @(
                    "$($regPath.InstallDir)\v2\AutoHotkey64.exe",
                    "$($regPath.InstallDir)\v2\AutoHotkey32.exe",
                    "$($regPath.InstallDir)\AutoHotkey64.exe",
                    "$($regPath.InstallDir)\AutoHotkey.exe"
                )
                foreach ($p in $possiblePaths) {
                    if (Test-Path $p) {
                        $ahkPath = $p
                        $method = "Registry (HKCU)"
                        break
                    }
                }
            }
        } catch {}
    }
    
    # Method 3: File Association
    if (-not $ahkPath) {
        Write-Host "  Checking file associations..." -ForegroundColor Gray
        try {
            $assoc = Get-ItemProperty -Path "Registry::HKEY_CLASSES_ROOT\AutoHotkeyScript\Shell\Open\Command" -ErrorAction SilentlyContinue
            if ($assoc.'(default)') {
                $exePath = ($assoc.'(default)' -split '"')[1]
                if ($exePath -and (Test-Path $exePath)) {
                    $ahkPath = $exePath
                    $method = "File Association"
                }
            }
        } catch {}
    }
    
    # Method 4: Common Paths
    if (-not $ahkPath) {
        Write-Host "  Checking common install locations..." -ForegroundColor Gray
        $commonPaths = @(
            "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey64.exe",
            "$env:ProgramFiles\AutoHotkey\v2\AutoHotkey32.exe",
            "$env:ProgramFiles\AutoHotkey\AutoHotkey64.exe",
            "$env:ProgramFiles\AutoHotkey\AutoHotkey.exe",
            "${env:ProgramFiles(x86)}\AutoHotkey\v2\AutoHotkey32.exe",
            "${env:ProgramFiles(x86)}\AutoHotkey\AutoHotkey.exe",
            "$env:LocalAppData\Programs\AutoHotkey\v2\AutoHotkey64.exe",
            "$env:LocalAppData\Programs\AutoHotkey\v2\AutoHotkey32.exe",
            "$env:USERPROFILE\scoop\apps\autohotkey\current\v2\AutoHotkey64.exe"
        )
        foreach ($p in $commonPaths) {
            if (Test-Path $p) {
                $ahkPath = $p
                $method = "Common Path"
                break
            }
        }
    }
    
    # Method 5: PATH environment
    if (-not $ahkPath) {
        Write-Host "  Checking system PATH..." -ForegroundColor Gray
        $pathExes = @("AutoHotkey64.exe", "AutoHotkey.exe", "AutoHotkey32.exe")
        foreach ($exe in $pathExes) {
            $found = Get-Command $exe -ErrorAction SilentlyContinue
            if ($found) {
                $ahkPath = $found.Source
                $method = "System PATH"
                break
            }
        }
    }
    
    if ($ahkPath) {
        Write-Success "Found AutoHotkey!"
        Write-Info "Path: $ahkPath"
        Write-Info "Method: $method"
        return $ahkPath
    }
    
    Write-Fail "AutoHotkey v2 not found"
    return $null
}

# ============================================================================
# AUTOHOTKEY INSTALLATION
# ============================================================================

function Install-AutoHotkey {
    Write-Status "Installing AutoHotkey v2..."
    
    $tempDir = "$env:TEMP\ContentCaptureInstall"
    $installerPath = "$tempDir\ahk-v2-setup.exe"
    
    # Create temp directory
    if (-not (Test-Path $tempDir)) {
        New-Item -ItemType Directory -Path $tempDir -Force | Out-Null
    }
    
    # Check for bundled installer first
    $bundledInstaller = Join-Path $PSScriptRoot "autohotkey-v2-setup.exe"
    
    if (Test-Path $bundledInstaller) {
        Write-Host "  Using bundled installer..." -ForegroundColor Gray
        Copy-Item $bundledInstaller $installerPath -Force
    } else {
        # Download AutoHotkey
        Write-Host "  Downloading AutoHotkey v2..." -ForegroundColor Gray
        Write-Host "  (This may take a minute)" -ForegroundColor Gray
        
        try {
            [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri "https://www.autohotkey.com/download/ahk-v2.exe" -OutFile $installerPath -UseBasicParsing
        } catch {
            Write-Fail "Download failed: $_"
            
            # Fallback: open download page
            $openPage = Show-YesNo -Title "Download Failed" -Message "Could not download AutoHotkey automatically.`n`nWould you like to open the download page?"
            if ($openPage) {
                Start-Process "https://www.autohotkey.com/download/"
            }
            return $null
        }
    }
    
    if (-not (Test-Path $installerPath)) {
        Write-Fail "Installer not found"
        return $null
    }
    
    # Run silent install
    Write-Host "  Running silent install..." -ForegroundColor Gray
    
    try {
        $process = Start-Process -FilePath $installerPath -ArgumentList "/S" -Wait -PassThru
        Start-Sleep -Seconds 3
    } catch {
        Write-Fail "Installation failed: $_"
        return $null
    }
    
    # Clean up
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    Remove-Item $tempDir -Force -Recurse -ErrorAction SilentlyContinue
    
    # Verify installation
    $ahkPath = Find-AutoHotkey
    if ($ahkPath) {
        Write-Success "AutoHotkey v2 installed successfully!"
        return $ahkPath
    }
    
    Write-Fail "Installation could not be verified"
    return $null
}

# ============================================================================
# FILE INSTALLATION
# ============================================================================

function Install-ContentCaptureFiles {
    param (
        [string]$SourceDir,
        [string]$DestDir
    )
    
    Write-Status "Installing ContentCapture Pro files..."
    Write-Info "From: $SourceDir"
    Write-Info "To: $DestDir"
    
    # Create destination directory
    if (-not (Test-Path $DestDir)) {
        try {
            New-Item -ItemType Directory -Path $DestDir -Force | Out-Null
            Write-Success "Created install folder"
        } catch {
            Write-Fail "Could not create folder: $_"
            return $false
        }
    }
    
    # Create subdirectories
    $subDirs = @("backups", "documentation", "images")
    foreach ($subDir in $subDirs) {
        $subPath = Join-Path $DestDir $subDir
        if (-not (Test-Path $subPath)) {
            New-Item -ItemType Directory -Path $subPath -Force | Out-Null
        }
    }
    
    # Copy required files
    $copiedFiles = 0
    $allFiles = $RequiredFiles + $OptionalFiles
    
    foreach ($file in $allFiles) {
        $sourcePath = Join-Path $SourceDir $file
        $destPath = Join-Path $DestDir $file
        
        if (Test-Path $sourcePath) {
            try {
                Copy-Item $sourcePath $destPath -Force
                Write-Host "  Copied: $file" -ForegroundColor Gray
                $copiedFiles++
            } catch {
                if ($file -in $RequiredFiles) {
                    Write-Fail "Failed to copy required file: $file"
                    return $false
                }
            }
        }
    }
    
    # Copy documentation folder if exists
    $docsSource = Join-Path $SourceDir "documentation"
    $docsDest = Join-Path $DestDir "documentation"
    if (Test-Path $docsSource) {
        Copy-Item "$docsSource\*" $docsDest -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    # Copy images folder if exists
    $imagesSource = Join-Path $SourceDir "images"
    $imagesDest = Join-Path $DestDir "images"
    if (Test-Path $imagesSource) {
        Copy-Item "$imagesSource\*" $imagesDest -Recurse -Force -ErrorAction SilentlyContinue
    }
    
    Write-Success "Copied $copiedFiles files"
    return $true
}

# ============================================================================
# MAIN SCRIPT
# ============================================================================

Clear-Host
Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host "     CONTENTCAPTURE PRO - INSTALLER v2.0" -ForegroundColor White
Write-Host "  ============================================================" -ForegroundColor Cyan
Write-Host ""

# Get script directory (where the installer is running from)
$SourceDir = $PSScriptRoot
if (-not $SourceDir) { $SourceDir = Split-Path -Parent $MyInvocation.MyCommand.Path }
if (-not $SourceDir) { $SourceDir = (Get-Location).Path }

# Check if running from a bad location
$badLocation = Test-BadLocation -Path $SourceDir
if ($badLocation) {
    Write-Host "  [!] Running from: $badLocation" -ForegroundColor Yellow
    Write-Host ""
    Write-Host "  The installer will copy files to:" -ForegroundColor White
    Write-Host "  $InstallFolder" -ForegroundColor Green
    Write-Host ""
}

# Check for required files
$mainScript = Join-Path $SourceDir "ContentCapture-Pro.ahk"
if (-not (Test-Path $mainScript)) {
    Show-Message -Title "Files Not Found" -Message "Could not find ContentCapture-Pro.ahk`n`nMake sure you extracted the ZIP file and are running install.bat from the extracted folder." -Type "Error"
    exit 1
}

# Welcome message
$installPath = $InstallFolder
$welcomeMsg = "Welcome to ContentCapture Pro!`n`nThis installer will:`n"
$welcomeMsg += "  1. Install files to:`n       $installPath`n"
$welcomeMsg += "  2. Install AutoHotkey v2 if needed`n"
$welcomeMsg += "  3. Launch ContentCapture Pro`n"
$welcomeMsg += "  4. Optionally add to Windows startup`n`n"
$welcomeMsg += "Continue with installation?"

$proceed = Show-YesNo -Title "ContentCapture Pro Installer" -Message $welcomeMsg

if (-not $proceed) {
    Write-Host "  Installation cancelled." -ForegroundColor Yellow
    exit 0
}

# ============================================================================
# Step 1: Install/Copy Files
# ============================================================================

Write-Host ""
Write-Host "  Step 1 of 4: Installing Files" -ForegroundColor White
Write-Host "  ------------------------------" -ForegroundColor Gray

# Check if already installed in target location
$alreadyInstalled = Test-Path (Join-Path $InstallFolder "ContentCapture-Pro.ahk")

if ($SourceDir -eq $InstallFolder) {
    Write-Success "Already running from install location"
} elseif ($alreadyInstalled) {
    $overwrite = Show-YesNo -Title "Already Installed" -Message "ContentCapture Pro is already installed at:`n$InstallFolder`n`nDo you want to update/overwrite the existing installation?"
    
    if ($overwrite) {
        $result = Install-ContentCaptureFiles -SourceDir $SourceDir -DestDir $InstallFolder
        if (-not $result) {
            Show-Message -Title "Installation Failed" -Message "Could not copy files to install location.`n`nTry running as administrator." -Type "Error"
            exit 1
        }
    }
} else {
    $result = Install-ContentCaptureFiles -SourceDir $SourceDir -DestDir $InstallFolder
    if (-not $result) {
        Show-Message -Title "Installation Failed" -Message "Could not copy files to install location.`n`nTry running as administrator." -Type "Error"
        exit 1
    }
}

# Update source dir to install location for remaining steps
$AppDir = $InstallFolder

# ============================================================================
# Step 2: Find or Install AutoHotkey
# ============================================================================

Write-Host ""
Write-Host "  Step 2 of 4: AutoHotkey v2" -ForegroundColor White
Write-Host "  --------------------------" -ForegroundColor Gray

$ahkPath = Find-AutoHotkey

if (-not $ahkPath) {
    $installAhk = Show-YesNo -Title "AutoHotkey Required" -Message "AutoHotkey v2 is not installed.`n`nContentCapture Pro needs AutoHotkey v2 to run.`n`nWould you like to install it now?`n(Automatic, no clicking required)"
    
    if ($installAhk) {
        $ahkPath = Install-AutoHotkey
    }
    
    if (-not $ahkPath) {
        Show-Message -Title "Installation Incomplete" -Message "AutoHotkey v2 is required to run ContentCapture Pro.`n`nPlease install AutoHotkey v2 from:`nhttps://www.autohotkey.com/download/`n`nThen run this installer again." -Type "Warning"
        Start-Process "https://www.autohotkey.com/download/"
        exit 1
    }
}

# ============================================================================
# Step 3: Launch ContentCapture Pro
# ============================================================================

Write-Host ""
Write-Host "  Step 3 of 4: Launching ContentCapture Pro" -ForegroundColor White
Write-Host "  ------------------------------------------" -ForegroundColor Gray

$mainScript = Join-Path $AppDir "ContentCapture-Pro.ahk"

if (-not (Test-Path $mainScript)) {
    # Try alternate name
    $mainScript = Join-Path $AppDir "ContentCapture.ahk"
}

if (-not (Test-Path $mainScript)) {
    Show-Message -Title "Script Not Found" -Message "Could not find ContentCapture-Pro.ahk in:`n$AppDir" -Type "Error"
    exit 1
}

Write-Success "Found: $mainScript"
Write-Host "  Launching ContentCapture Pro..." -ForegroundColor Gray

try {
    Start-Process -FilePath $ahkPath -ArgumentList "`"$mainScript`"" -WorkingDirectory $AppDir
    Start-Sleep -Seconds 2
    Write-Success "ContentCapture Pro is running!"
    Write-Info "Look for the green H icon in your system tray"
} catch {
    Write-Fail "Failed to launch: $_"
    Show-Message -Title "Launch Failed" -Message "Could not start ContentCapture Pro.`n`nTry double-clicking ContentCapture-Pro.ahk directly." -Type "Error"
    exit 1
}

# ============================================================================
# Step 4: Add to Startup (Optional)
# ============================================================================

Write-Host ""
Write-Host "  Step 4 of 4: Windows Startup (Optional)" -ForegroundColor White
Write-Host "  ----------------------------------------" -ForegroundColor Gray

$addStartup = Show-YesNo -Title "Windows Startup" -Message "Would you like ContentCapture Pro to start automatically when Windows starts?`n`n(Recommended: Yes)"

if ($addStartup) {
    try {
        $startupFolder = [Environment]::GetFolderPath('Startup')
        $shortcutPath = Join-Path $startupFolder "ContentCapture Pro.lnk"
        
        $shell = New-Object -ComObject WScript.Shell
        $shortcut = $shell.CreateShortcut($shortcutPath)
        $shortcut.TargetPath = $ahkPath
        $shortcut.Arguments = "`"$mainScript`""
        $shortcut.WorkingDirectory = $AppDir
        $shortcut.Description = "ContentCapture Pro"
        $shortcut.Save()
        
        Write-Success "Added to Windows startup!"
    } catch {
        Write-Fail "Could not add to startup: $_"
    }
} else {
    Write-Host "  Skipped startup configuration" -ForegroundColor Gray
}

# ============================================================================
# Done!
# ============================================================================

Write-Host ""
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host "     INSTALLATION COMPLETE!" -ForegroundColor White
Write-Host "  ============================================================" -ForegroundColor Green
Write-Host ""
Write-Host "  Installed to: $AppDir" -ForegroundColor White
Write-Host ""
Write-Host "  ContentCapture Pro is now running!" -ForegroundColor White
Write-Host ""
Write-Host "  QUICK START:" -ForegroundColor Cyan
Write-Host "    Ctrl+Alt+P      Capture current webpage" -ForegroundColor Gray
Write-Host "    Ctrl+Alt+B      Browse all captures" -ForegroundColor Gray
Write-Host "    Ctrl+Alt+H      Show help" -ForegroundColor Gray
Write-Host ""
Write-Host "  Type a capture name + suffix to use it:" -ForegroundColor Cyan
Write-Host "    recipe1         Paste content" -ForegroundColor Gray
Write-Host "    recipe1go       Open URL" -ForegroundColor Gray
Write-Host "    recipe1em       Send as email" -ForegroundColor Gray
Write-Host "    recipe1fb       Share to Facebook" -ForegroundColor Gray
Write-Host ""

$doneMsg = "Installation Complete!`n`n"
$doneMsg += "Installed to:`n$AppDir`n`n"
$doneMsg += "ContentCapture Pro is now running!`n"
$doneMsg += "Look for the green H icon in your system tray.`n`n"
$doneMsg += "QUICK START:`n"
$doneMsg += "  Ctrl+Alt+P - Capture a webpage`n"
$doneMsg += "  Ctrl+Alt+B - Browse captures`n"
$doneMsg += "  Ctrl+Alt+H - Show help`n`n"
$doneMsg += "Enjoy!"

Show-Message -Title "Installation Complete!" -Message $doneMsg -Type "Info"

# Open the install folder
Start-Process "explorer.exe" -ArgumentList $AppDir
