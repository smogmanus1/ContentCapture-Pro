@echo off
:: ContentCapture Pro Installer Launcher v2.1

echo.
echo  Starting ContentCapture Pro Installer...
echo.

powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0Install-ContentCapture.ps1"

if %errorlevel% neq 0 (
    echo.
    echo  If you see errors, try right-clicking install.bat
    echo  and selecting "Run as administrator"
    echo.
    pause
)
