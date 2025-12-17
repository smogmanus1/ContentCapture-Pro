; ==============================================================================
; ContentCapture Pro - Launcher & Installation Check
; ==============================================================================
; Version: 4.5
; This file checks for proper installation before launching the main script.
; ==============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; INSTALLATION CHECKS
; ==============================================================================

; Check 1: Verify we're running from a safe location (not Program Files)
CheckInstallLocation()

; Check 2: First-run setup and data location warning
CheckFirstRun()

; ==============================================================================
; LAUNCH MAIN SCRIPT
; ==============================================================================

#Include ContentCapture-Pro.ahk

; ==============================================================================
; INSTALLATION CHECK FUNCTIONS
; ==============================================================================

CheckInstallLocation() {
    currentDir := A_ScriptDir
    
    ; Warn if installed in Program Files (data won't persist properly)
    if (InStr(currentDir, "Program Files") || InStr(currentDir, "ProgramData")) {
        result := MsgBox(
            "⚠️ WARNING: ContentCapture Pro is installed in a system folder:`n`n" 
            currentDir "`n`n"
            "This location may cause issues:`n"
            "• Your captured data may be lost during updates`n"
            "• Windows may block saving files here`n`n"
            "RECOMMENDED: Install to one of these locations:`n"
            "• D:\ContentCapture\ (secondary drive - BEST)`n"
            "• C:\Users\YourName\Documents\ContentCapture\`n"
            "• Any folder synced to cloud backup`n`n"
            "Continue anyway?",
            "Installation Warning",
            "YesNo Icon!"
        )
        if (result = "No")
            ExitApp()
    }
    
    ; Warn if on C: drive root
    if (SubStr(currentDir, 1, 3) = "C:\" && StrLen(currentDir) < 20) {
        MsgBox(
            "💡 TIP: Your captures will be saved to:`n`n" 
            currentDir "`n`n"
            "Consider installing on a secondary drive (D:, E:) or a backed-up folder "
            "to protect your data from system crashes or reinstalls.",
            "Data Location Tip",
            "Icon!"
        )
    }
}

CheckFirstRun() {
    configFile := A_ScriptDir "\config.ini"
    
    ; If config exists, not first run
    if FileExist(configFile)
        return
    
    ; First run - show welcome message
    result := MsgBox(
        "👋 Welcome to ContentCapture Pro!`n`n"
        "This appears to be your first time running the script.`n`n"
        "Your captured data will be saved to:`n"
        A_ScriptDir "`n`n"
        "IMPORTANT: Make sure this folder is:`n"
        "✓ On a drive you back up regularly`n"
        "✓ NOT in Program Files or Windows folders`n"
        "✓ Somewhere you won't accidentally delete`n`n"
        "The setup wizard will guide you through configuration.`n`n"
        "Ready to begin?",
        "Welcome to ContentCapture Pro",
        "YesNo Iconi"
    )
    
    if (result = "No")
        ExitApp()
}
