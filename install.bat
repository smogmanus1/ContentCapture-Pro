@echo off
:: ============================================================================
:: ContentCapture Pro - One-Click Installer
:: ============================================================================
:: Just double-click this file to install!
:: ============================================================================

title ContentCapture Pro Installer

:: Check if PowerShell is available
where powershell >nul 2>nul
if %errorlevel% neq 0 (
    echo ERROR: PowerShell is required but not found.
    echo Please install PowerShell or run Install-ContentCapture.ps1 manually.
    pause
    exit /b 1
)

:: Run the PowerShell installer with execution policy bypass
powershell -ExecutionPolicy Bypass -File "%~dp0Install-ContentCapture.ps1"

:: If PowerShell script didn't exist, show error
if %errorlevel% neq 0 (
    echo.
    echo If you see an error above, please try:
    echo   1. Right-click Install-ContentCapture.ps1
    echo   2. Select "Run with PowerShell"
    echo.
    pause
)
