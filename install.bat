@echo off
:: ContentCapture Pro Installer Launcher v2.0
:: This launches the PowerShell installer

echo.
echo  Starting ContentCapture Pro Installer...
echo.

powershell -ExecutionPolicy Bypass -NoProfile -File "%~dp0Install-ContentCapture.ps1"

if %errorlevel% neq 0 (
    echo.
    echo  Installation encountered an issue.
    echo  Try right-clicking install.bat and select "Run as administrator"
    echo.
    pause
)
