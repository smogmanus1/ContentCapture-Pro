@echo off
setlocal EnableDelayedExpansion

:: ============================================================================
:: ContentCapture Pro - Grandma-Proof Installer v3.0
:: ============================================================================
:: 
:: DESIGN GOALS:
::   - Zero user decisions required (except "Yes install" at the start)
::   - Silent AutoHotkey installation (no wizard clicking)
::   - Clear, friendly messages throughout
::   - Works even if AHK is in unexpected locations
::   - Grandma can do this!
::
:: ============================================================================

title ContentCapture Pro - Easy Installer
color 1F

:: Check for admin rights (needed for silent install)
net session >nul 2>&1
if %errorlevel% neq 0 (
    echo.
    echo  ============================================================
    echo     ContentCapture Pro - Installer
    echo  ============================================================
    echo.
    echo  This installer needs administrator rights to install
    echo  AutoHotkey silently.
    echo.
    echo  Please right-click install.bat and select:
    echo  "Run as administrator"
    echo.
    echo  ============================================================
    pause
    exit /b
)

cls
echo.
echo  ============================================================
echo.
echo       CONTENTCAPTURE PRO - EASY INSTALLER
echo.
echo  ============================================================
echo.
echo   This will install ContentCapture Pro on your computer.
echo.
echo   What this installer does:
echo     1. Checks if AutoHotkey v2 is installed
echo     2. Installs AutoHotkey v2 if needed (automatic)
echo     3. Starts ContentCapture Pro
echo     4. Optionally adds to Windows startup
echo.
echo  ============================================================
echo.
choice /C YN /M "  Ready to install? (Y=Yes, N=No)"
if errorlevel 2 goto :cancelled
if errorlevel 1 goto :start_install

:cancelled
echo.
echo  Installation cancelled. No changes were made.
echo.
pause
exit /b

:start_install
cls
echo.
echo  ============================================================
echo     INSTALLING CONTENTCAPTURE PRO
echo  ============================================================
echo.
echo  Step 1 of 4: Checking for AutoHotkey v2...
echo.

set "AHK_PATH="
set "DETECTION_METHOD="

:: ============================================================================
:: DETECTION METHOD 1: Registry (most reliable)
:: ============================================================================

:: Check HKLM (machine-wide install)
for /f "tokens=2*" %%a in ('reg query "HKLM\SOFTWARE\AutoHotkey" /v InstallDir 2^>nul') do (
    set "AHK_DIR=%%b"
)

if defined AHK_DIR (
    if exist "!AHK_DIR!\v2\AutoHotkey64.exe" (
        set "AHK_PATH=!AHK_DIR!\v2\AutoHotkey64.exe"
        set "DETECTION_METHOD=Registry"
        goto :found
    )
    if exist "!AHK_DIR!\v2\AutoHotkey32.exe" (
        set "AHK_PATH=!AHK_DIR!\v2\AutoHotkey32.exe"
        set "DETECTION_METHOD=Registry"
        goto :found
    )
    if exist "!AHK_DIR!\AutoHotkey64.exe" (
        set "AHK_PATH=!AHK_DIR!\AutoHotkey64.exe"
        set "DETECTION_METHOD=Registry"
        goto :found
    )
    if exist "!AHK_DIR!\AutoHotkey.exe" (
        set "AHK_PATH=!AHK_DIR!\AutoHotkey.exe"
        set "DETECTION_METHOD=Registry"
        goto :found
    )
)

:: Check HKCU (user install)
set "AHK_DIR="
for /f "tokens=2*" %%a in ('reg query "HKCU\SOFTWARE\AutoHotkey" /v InstallDir 2^>nul') do (
    set "AHK_DIR=%%b"
)

if defined AHK_DIR (
    if exist "!AHK_DIR!\v2\AutoHotkey64.exe" (
        set "AHK_PATH=!AHK_DIR!\v2\AutoHotkey64.exe"
        set "DETECTION_METHOD=Registry"
        goto :found
    )
    if exist "!AHK_DIR!\v2\AutoHotkey32.exe" (
        set "AHK_PATH=!AHK_DIR!\v2\AutoHotkey32.exe"
        set "DETECTION_METHOD=Registry"
        goto :found
    )
)

:: ============================================================================
:: DETECTION METHOD 2: File associations
:: ============================================================================

for /f "tokens=2*" %%a in ('reg query "HKCR\AutoHotkeyScript\Shell\Open\Command" /ve 2^>nul') do (
    set "AHK_ASSOC=%%b"
)

if defined AHK_ASSOC (
    for /f "tokens=1 delims=," %%a in ("!AHK_ASSOC!") do (
        set "AHK_ASSOC_PATH=%%~a"
    )
    set "AHK_ASSOC_PATH=!AHK_ASSOC_PATH:"=!"
    
    if exist "!AHK_ASSOC_PATH!" (
        set "AHK_PATH=!AHK_ASSOC_PATH!"
        set "DETECTION_METHOD=File Association"
        goto :found
    )
)

:: ============================================================================
:: DETECTION METHOD 3: Common installation paths
:: ============================================================================

if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe"
    set "DETECTION_METHOD=Program Files"
    goto :found
)
if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey32.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\v2\AutoHotkey32.exe"
    set "DETECTION_METHOD=Program Files"
    goto :found
)
if exist "%ProgramFiles%\AutoHotkey\AutoHotkey64.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\AutoHotkey64.exe"
    set "DETECTION_METHOD=Program Files"
    goto :found
)
if exist "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\AutoHotkey.exe"
    set "DETECTION_METHOD=Program Files"
    goto :found
)
if exist "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe" (
    set "AHK_PATH=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
    set "DETECTION_METHOD=Local Install"
    goto :found
)
if exist "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey32.exe" (
    set "AHK_PATH=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey32.exe"
    set "DETECTION_METHOD=Local Install"
    goto :found
)

:: Scoop
if exist "%UserProfile%\scoop\apps\autohotkey\current\v2\AutoHotkey64.exe" (
    set "AHK_PATH=%UserProfile%\scoop\apps\autohotkey\current\v2\AutoHotkey64.exe"
    set "DETECTION_METHOD=Scoop"
    goto :found
)

:: ============================================================================
:: DETECTION METHOD 4: PATH
:: ============================================================================

where AutoHotkey64.exe >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%a in ('where AutoHotkey64.exe 2^>nul') do (
        set "AHK_PATH=%%a"
        set "DETECTION_METHOD=System PATH"
        goto :found
    )
)

where AutoHotkey.exe >nul 2>&1
if %errorlevel% equ 0 (
    for /f "delims=" %%a in ('where AutoHotkey.exe 2^>nul') do (
        set "AHK_PATH=%%a"
        set "DETECTION_METHOD=System PATH"
        goto :found
    )
)

:: ============================================================================
:: NOT FOUND - Install AutoHotkey silently
:: ============================================================================

:not_found
echo   AutoHotkey v2 is not installed.
echo.
echo  Step 2 of 4: Installing AutoHotkey v2...
echo.
echo   Please wait - this takes about 30 seconds...
echo.

:: Create temp directory
if not exist "%TEMP%\ContentCaptureInstall" mkdir "%TEMP%\ContentCaptureInstall"

:: Check if we bundled the installer
set "BUNDLED_INSTALLER=%~dp0autohotkey-v2-setup.exe"
if exist "%BUNDLED_INSTALLER%" (
    echo   Using bundled installer...
    copy "%BUNDLED_INSTALLER%" "%TEMP%\ContentCaptureInstall\ahk-setup.exe" >nul
    goto :run_installer
)

:: Download AutoHotkey v2 installer
echo   Downloading AutoHotkey v2...
echo.

powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; $ProgressPreference = 'SilentlyContinue'; Invoke-WebRequest -Uri 'https://www.autohotkey.com/download/ahk-v2.exe' -OutFile '%TEMP%\ContentCaptureInstall\ahk-setup.exe'}" 2>nul

if not exist "%TEMP%\ContentCaptureInstall\ahk-setup.exe" (
    echo.
    echo   [!] Download failed. Trying alternate method...
    echo.
    
    :: Try with curl (available on Windows 10+)
    curl -L -o "%TEMP%\ContentCaptureInstall\ahk-setup.exe" "https://www.autohotkey.com/download/ahk-v2.exe" 2>nul
)

if not exist "%TEMP%\ContentCaptureInstall\ahk-setup.exe" (
    echo.
    echo  ============================================================
    echo   DOWNLOAD FAILED
    echo  ============================================================
    echo.
    echo   Could not download AutoHotkey automatically.
    echo.
    echo   Please install manually:
    echo     1. Go to: https://www.autohotkey.com/download/
    echo     2. Click "Download v2.0"
    echo     3. Run the installer
    echo     4. Run this install.bat again
    echo.
    echo   Opening download page now...
    start "" "https://www.autohotkey.com/download/"
    echo.
    pause
    exit /b
)

:run_installer
echo   Installing AutoHotkey v2 (silent install)...
echo.

:: Run silent install
:: /S = silent, /D = install directory
"%TEMP%\ContentCaptureInstall\ahk-setup.exe" /S

:: Wait for installation to complete
echo   Waiting for installation to complete...
timeout /t 5 /nobreak >nul

:: Clean up
del "%TEMP%\ContentCaptureInstall\ahk-setup.exe" 2>nul
rmdir "%TEMP%\ContentCaptureInstall" 2>nul

:: Re-check for AutoHotkey
if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe"
    set "DETECTION_METHOD=Fresh Install"
    echo   [OK] AutoHotkey v2 installed successfully!
    echo.
    goto :launch
)
if exist "%ProgramFiles%\AutoHotkey\AutoHotkey64.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\AutoHotkey64.exe"
    set "DETECTION_METHOD=Fresh Install"
    echo   [OK] AutoHotkey v2 installed successfully!
    echo.
    goto :launch
)
if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey32.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\v2\AutoHotkey32.exe"
    set "DETECTION_METHOD=Fresh Install"
    echo   [OK] AutoHotkey v2 installed successfully!
    echo.
    goto :launch
)

:: Still not found - installation may have failed
echo.
echo  ============================================================
echo   INSTALLATION MAY HAVE FAILED
echo  ============================================================
echo.
echo   AutoHotkey v2 installation could not be verified.
echo.
echo   Please try:
echo     1. Go to: https://www.autohotkey.com/download/
echo     2. Download and install AutoHotkey v2 manually
echo     3. Run this install.bat again
echo.
start "" "https://www.autohotkey.com/download/"
pause
exit /b

:: ============================================================================
:: AUTOHOTKEY FOUND
:: ============================================================================

:found
echo   [OK] AutoHotkey v2 found!
echo       Location: %AHK_PATH%
echo.
echo  Step 2 of 4: AutoHotkey v2 is ready!
echo.

:: ============================================================================
:: LAUNCH CONTENTCAPTURE PRO
:: ============================================================================

:launch
echo  Step 3 of 4: Starting ContentCapture Pro...
echo.

:: Find the main script
set "SCRIPT_DIR=%~dp0"
set "MAIN_SCRIPT="

if exist "%SCRIPT_DIR%ContentCapture-Pro.ahk" (
    set "MAIN_SCRIPT=%SCRIPT_DIR%ContentCapture-Pro.ahk"
) else if exist "%SCRIPT_DIR%ContentCapture.ahk" (
    set "MAIN_SCRIPT=%SCRIPT_DIR%ContentCapture.ahk"
)

if not defined MAIN_SCRIPT (
    echo  ============================================================
    echo   ERROR: Script Not Found
    echo  ============================================================
    echo.
    echo   Could not find ContentCapture-Pro.ahk
    echo.
    echo   Make sure this installer is in the same folder as
    echo   the ContentCapture Pro files.
    echo.
    pause
    exit /b
)

:: Launch it!
start "" "%AHK_PATH%" "%MAIN_SCRIPT%"

echo   [OK] ContentCapture Pro is starting!
echo.
echo       Look for the green "H" icon in your system tray
echo       (bottom-right corner of your screen, near the clock)
echo.

:: Give it a moment to start
timeout /t 3 /nobreak >nul

:: ============================================================================
:: ADD TO STARTUP (OPTIONAL)
:: ============================================================================

echo  Step 4 of 4: Windows Startup
echo.
echo   Would you like ContentCapture Pro to start automatically
echo   when you turn on your computer?
echo.
echo   (Recommended: Yes)
echo.
choice /C YN /M "  Add to Windows startup? (Y=Yes, N=No)"
if errorlevel 2 goto :done
if errorlevel 1 goto :add_startup

:add_startup
echo.
echo   Adding to Windows startup...

set "STARTUP=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT=%STARTUP%\ContentCapture Pro.lnk"

:: Create shortcut using PowerShell
powershell -Command "$ws = New-Object -ComObject WScript.Shell; $s = $ws.CreateShortcut('%SHORTCUT%'); $s.TargetPath = '%AHK_PATH%'; $s.Arguments = '\"%MAIN_SCRIPT%\"'; $s.WorkingDirectory = '%SCRIPT_DIR%'; $s.Description = 'ContentCapture Pro'; $s.Save()" 2>nul

if exist "%SHORTCUT%" (
    echo   [OK] Added to startup!
    echo       ContentCapture Pro will start automatically.
) else (
    echo   [!] Could not add to startup automatically.
    echo       You can add it manually later if you want.
)

:: ============================================================================
:: DONE!
:: ============================================================================

:done
cls
echo.
echo  ============================================================
echo.
echo      INSTALLATION COMPLETE!
echo.
echo  ============================================================
echo.
echo   ContentCapture Pro is now running!
echo.
echo   Look for the green "H" icon in your system tray
echo   (bottom-right corner, near the clock)
echo.
echo  ============================================================
echo   QUICK START GUIDE
echo  ============================================================
echo.
echo   CAPTURE A WEBPAGE:
echo     1. Go to any webpage in your browser
echo     2. Highlight some text (optional)
echo     3. Press Ctrl+Alt+P
echo     4. Give it a short name like "recipe1"
echo.
echo   USE YOUR CAPTURE:
echo     - Type: recipe1     [pastes the content]
echo     - Type: recipe1go   [opens the webpage]
echo     - Type: recipe1em   [sends as email]
echo     - Type: recipe1fb   [shares to Facebook]
echo.
echo   BROWSE ALL CAPTURES:
echo     Press Ctrl+Alt+B to open the Capture Browser
echo.
echo  ============================================================
echo.
echo   Enjoy ContentCapture Pro!
echo.
echo   For help, press Ctrl+Alt+H or visit:
echo   https://github.com/smogmanus1/ContentCapture-Pro
echo.
echo  ============================================================
echo.
pause
