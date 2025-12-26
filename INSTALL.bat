@echo off
setlocal enabledelayedexpansion

:: ============================================================================
:: ContentCapture Pro - Easy Installer
:: ============================================================================
:: This script will:
:: 1. Check if AutoHotkey v2 is installed
:: 2. Download and install AutoHotkey v2 if needed
:: 3. Launch ContentCapture Pro
:: ============================================================================

title ContentCapture Pro - Installer
color 0A

echo.
echo  ============================================================
echo     ContentCapture Pro - Easy Installer
echo  ============================================================
echo.
echo  This will install ContentCapture Pro on your system.
echo.
pause

:: Check if AutoHotkey v2 is already installed
echo.
echo  [1/3] Checking for AutoHotkey v2...

set "AHK_PATH="

:: Check common installation locations
if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe"
    goto :ahk_found
)
if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey32.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\v2\AutoHotkey32.exe"
    goto :ahk_found
)
if exist "%ProgramFiles%\AutoHotkey\AutoHotkey64.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\AutoHotkey64.exe"
    goto :ahk_found
)
if exist "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\AutoHotkey.exe"
    goto :ahk_found
)
if exist "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe" (
    set "AHK_PATH=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
    goto :ahk_found
)
if exist "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey32.exe" (
    set "AHK_PATH=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey32.exe"
    goto :ahk_found
)

:: Check if ahk files are associated
where AutoHotkey64.exe >nul 2>&1
if %errorlevel% equ 0 (
    set "AHK_PATH=AutoHotkey64.exe"
    goto :ahk_found
)

where AutoHotkey.exe >nul 2>&1
if %errorlevel% equ 0 (
    set "AHK_PATH=AutoHotkey.exe"
    goto :ahk_found
)

:: AutoHotkey not found - need to install
echo.
echo  [!] AutoHotkey v2 is NOT installed.
echo.
echo  AutoHotkey v2 is required to run ContentCapture Pro.
echo.
echo  Would you like to download and install it now?
echo.
choice /C YN /M "  Install AutoHotkey v2"
if errorlevel 2 goto :manual_install
if errorlevel 1 goto :auto_install

:auto_install
echo.
echo  [2/3] Downloading AutoHotkey v2 installer...
echo.

:: Create temp directory if needed
if not exist "%TEMP%\ContentCaptureInstall" mkdir "%TEMP%\ContentCaptureInstall"

:: Download AutoHotkey installer using PowerShell
powershell -Command "& {[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; Invoke-WebRequest -Uri 'https://www.autohotkey.com/download/ahk-v2.exe' -OutFile '%TEMP%\ContentCaptureInstall\ahk-v2-setup.exe'}" 2>nul

if not exist "%TEMP%\ContentCaptureInstall\ahk-v2-setup.exe" (
    echo  [!] Download failed. Please install manually.
    goto :manual_install
)

echo  [2/3] Installing AutoHotkey v2...
echo.
echo  The AutoHotkey installer will now open.
echo  Please follow the installation prompts.
echo.
pause

:: Run the installer
start /wait "" "%TEMP%\ContentCaptureInstall\ahk-v2-setup.exe"

:: Clean up
del "%TEMP%\ContentCaptureInstall\ahk-v2-setup.exe" 2>nul
rmdir "%TEMP%\ContentCaptureInstall" 2>nul

:: Re-check for AutoHotkey after installation
if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe"
    goto :ahk_found
)
if exist "%ProgramFiles%\AutoHotkey\AutoHotkey64.exe" (
    set "AHK_PATH=%ProgramFiles%\AutoHotkey\AutoHotkey64.exe"
    goto :ahk_found
)
if exist "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe" (
    set "AHK_PATH=%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe"
    goto :ahk_found
)

echo.
echo  [!] Could not verify AutoHotkey installation.
echo  Please try running this installer again, or install manually.
goto :manual_install

:manual_install
echo.
echo  ============================================================
echo  MANUAL INSTALLATION INSTRUCTIONS
echo  ============================================================
echo.
echo  1. Open your web browser
echo  2. Go to: https://www.autohotkey.com/download/
echo  3. Click "Download v2.0" (the green button)
echo  4. Run the downloaded installer
echo  5. After installation, run this installer again
echo.
echo  Or press any key to open the download page now...
pause >nul
start "" "https://www.autohotkey.com/download/"
echo.
echo  After installing AutoHotkey v2, run this installer again.
echo.
pause
goto :end

:ahk_found
echo        Found: %AHK_PATH%
echo.
echo  [3/3] Launching ContentCapture Pro...
echo.

:: Find ContentCapture-Pro.ahk in the same directory as this batch file
set "SCRIPT_DIR=%~dp0"
set "MAIN_SCRIPT=%SCRIPT_DIR%ContentCapture-Pro.ahk"

if not exist "%MAIN_SCRIPT%" (
    echo  [!] ERROR: ContentCapture-Pro.ahk not found!
    echo.
    echo  Make sure this installer is in the same folder as
    echo  ContentCapture-Pro.ahk
    echo.
    echo  Expected location: %MAIN_SCRIPT%
    echo.
    pause
    goto :end
)

:: Launch the script
echo  Starting ContentCapture Pro...
echo.
start "" "%AHK_PATH%" "%MAIN_SCRIPT%"

echo  ============================================================
echo     ContentCapture Pro is now running!
echo  ============================================================
echo.
echo  Look for the green "H" icon in your system tray.
echo.
echo  QUICK START:
echo    - Press Ctrl+Alt+C on any webpage to capture content
echo    - Press Ctrl+Alt+B to open the Capture Browser
echo    - Type a script name + suffix to paste content
echo.
echo  Would you like to add ContentCapture Pro to Windows startup?
echo  (It will run automatically when you log in)
echo.
choice /C YN /M "  Add to startup"
if errorlevel 2 goto :no_startup
if errorlevel 1 goto :add_startup

:add_startup
:: Create shortcut in Startup folder
set "STARTUP_FOLDER=%APPDATA%\Microsoft\Windows\Start Menu\Programs\Startup"
set "SHORTCUT=%STARTUP_FOLDER%\ContentCapture Pro.lnk"

powershell -Command "& {$WshShell = New-Object -ComObject WScript.Shell; $Shortcut = $WshShell.CreateShortcut('%SHORTCUT%'); $Shortcut.TargetPath = '%AHK_PATH%'; $Shortcut.Arguments = '\"%MAIN_SCRIPT%\"'; $Shortcut.WorkingDirectory = '%SCRIPT_DIR%'; $Shortcut.Description = 'ContentCapture Pro'; $Shortcut.Save()}"

if exist "%SHORTCUT%" (
    echo.
    echo  [OK] Added to Windows startup!
) else (
    echo.
    echo  [!] Could not add to startup. You can do this manually later.
)
goto :done

:no_startup
echo.
echo  [OK] Skipped startup configuration.
echo.
echo  You can add it later by creating a shortcut to
echo  ContentCapture-Pro.ahk in your Startup folder.

:done
echo.
echo  ============================================================
echo     Installation Complete!
echo  ============================================================
echo.
echo  Enjoy ContentCapture Pro!
echo.
echo  For help, press Ctrl+Alt+H or visit:
echo  https://github.com/smogmanus1/ContentCapture-Pro
echo.
pause
goto :end

:end
endlocal
exit /b
