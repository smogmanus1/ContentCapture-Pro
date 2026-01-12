; ==============================================================================
; ContentCapture.ahk - Launcher for ContentCapture Pro
; ==============================================================================
; This is the entry point that should be run to start ContentCapture Pro.
; It sets up the environment and includes the main application file.
;
; To run: Double-click this file or add to Windows Startup
; ==============================================================================

#Requires AutoHotkey v2.0+
#SingleInstance Force

; Set working directory to script location (portable support)
SetWorkingDir(A_ScriptDir)

; Include the main application
#Include ContentCapture-Pro.ahk

; The application is now running!
; See the system tray icon for options.
