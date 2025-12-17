@echo off
title ContentCapture Pro - Installation Check
color 0B

echo.
echo  ============================================
echo   ContentCapture Pro v4.5 - Installation
echo  ============================================
echo.

:: Check if AutoHotkey v2 is installed
set "AHK_FOUND=0"

:: Check common installation paths (including 64-bit executables)
if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe" set "AHK_FOUND=1"
if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey32.exe" set "AHK_FOUND=1"
if exist "%ProgramFiles%\AutoHotkey\v2\AutoHotkey.exe" set "AHK_FOUND=1"
if exist "%ProgramFiles%\AutoHotkey\AutoHotkey64.exe" set "AHK_FOUND=1"
if exist "%ProgramFiles%\AutoHotkey\AutoHotkey.exe" set "AHK_FOUND=1"
if exist "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey64.exe" set "AHK_FOUND=1"
if exist "%LocalAppData%\Programs\AutoHotkey\v2\AutoHotkey.exe" set "AHK_FOUND=1"

:: Check if .ahk files are associated
assoc .ahk >nul 2>&1
if %errorlevel%==0 set "AHK_FOUND=1"

if "%AHK_FOUND%"=="1" (
    echo  [OK] AutoHotkey detected!
    echo.
    echo  Starting ContentCapture Pro...
    echo.
    
    :: Run the launcher
 start "" "%ProgramFiles%\AutoHotkey\v2\AutoHotkey64.exe" "%~dp0ContentCapture.ahk"
    echo  ============================================
    echo   ContentCapture Pro is now running!
    echo  ============================================
    echo.
    echo   Look for the green "H" icon in your system tray.
    echo.
    echo   QUICK START:
    echo   - Press Ctrl+Alt+P to capture a webpage
    echo   - Press Ctrl+Alt+Space for quick search
    echo   - Press Ctrl+Alt+B to browse captures
    echo.
    echo   Press any key to close this window...
    pause >nul
    exit
)

:: AHK not found - show installation instructions
echo  [!] AutoHotkey v2 is NOT installed
echo.
echo  ============================================
echo   AutoHotkey v2 Required
echo  ============================================
echo.
echo   ContentCapture Pro requires AutoHotkey v2.0 or later.
echo   It's free and takes about 30 seconds to install.
echo.
echo   INSTALLATION STEPS:
echo.
echo   1. Press any key to open the AutoHotkey website
echo   2. Click "Download" then "Download v2.0"
echo   3. Run the installer (keep default options)
echo   4. Come back here and run INSTALL.bat again
echo.
echo  ============================================
echo.

set /p choice="Open AutoHotkey download page? (Y/N): "

if /i "%choice%"=="Y" (
    start https://www.autohotkey.com/
    echo.
    echo  Browser opened! After installing AutoHotkey:
    echo  - Run this INSTALL.bat file again
    echo.
)

echo.
echo  Press any key to exit...
pause >nul