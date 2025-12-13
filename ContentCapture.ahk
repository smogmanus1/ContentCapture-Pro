#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
;
;   ██████╗ ██████╗ ███╗   ██╗████████╗███████╗███╗   ██╗████████╗
;  ██╔════╝██╔═══██╗████╗  ██║╚══██╔══╝██╔════╝████╗  ██║╚══██╔══╝
;  ██║     ██║   ██║██╔██╗ ██║   ██║   █████╗  ██╔██╗ ██║   ██║   
;  ██║     ██║   ██║██║╚██╗██║   ██║   ██╔══╝  ██║╚██╗██║   ██║   
;  ╚██████╗╚██████╔╝██║ ╚████║   ██║   ███████╗██║ ╚████║   ██║   
;   ╚═════╝ ╚═════╝ ╚═╝  ╚═══╝   ╚═╝   ╚══════╝╚═╝  ╚═══╝   ╚═╝   
;   ██████╗ █████╗ ██████╗ ████████╗██╗   ██╗██████╗ ███████╗
;  ██╔════╝██╔══██╗██╔══██╗╚══██╔══╝██║   ██║██╔══██╗██╔════╝
;  ██║     ███████║██████╔╝   ██║   ██║   ██║██████╔╝█████╗  
;  ██║     ██╔══██║██╔═══╝    ██║   ██║   ██║██╔══██╗██╔══╝  
;  ╚██████╗██║  ██║██║        ██║   ╚██████╔╝██║  ██║███████╗
;   ╚═════╝╚═╝  ╚═╝╚═╝        ╚═╝    ╚═════╝ ╚═╝  ╚═╝╚══════╝
;                         PRO v4.2
;
; ==============================================================================
; ContentCapture Pro - Main Entry Point (AutoHotkey v2)
; ==============================================================================
; 
; This is the main launcher file. Double-click to start ContentCapture Pro.
;
; QUICK START:
;   Ctrl+Alt+P     - Capture current webpage
;   Ctrl+Alt+B     - Browse all captures
;   Ctrl+Alt+Space - Quick search
;   Type ::name::  - Paste captured content
;   Type nameem    - Email capture (+ space to trigger)
;   Type namego    - Open URL in browser
;   Type namefb    - Share to Facebook
;
; For full documentation, see README.md
;
; ==============================================================================
; Created by Brad Schrunk
; https://github.com/smogmanus1/ContentCapture-Pro
; License: MIT
; ==============================================================================

global CC_ConfigFile := A_ScriptDir "\config.ini"
global CC_IsFirstRun := false

; Check if this is first run (no config file)
if (!FileExist(CC_ConfigFile)) {
    CC_IsFirstRun := true
    CC_RunFirstTimeSetup()
}

; Load the main application
#Include ContentCapture-Pro.ahk

; ==============================================================================
; FIRST-TIME SETUP (runs before main app loads on first run)
; ==============================================================================

CC_RunFirstTimeSetup() {
    global CC_ConfigFile
    
    setupGui := Gui("+AlwaysOnTop", "ContentCapture Pro - First Time Setup")
    setupGui.SetFont("s11")
    setupGui.BackColor := "FFFFFF"
    
    ; Header
    setupGui.SetFont("s16 bold")
    setupGui.Add("Text", "w450 Center", "Welcome to ContentCapture Pro!")
    
    setupGui.SetFont("s10 norm c666666")
    setupGui.Add("Text", "w450 Center", "Version 4.2 - AutoHotkey v2")
    
    setupGui.SetFont("s11 norm c000000")
    setupGui.Add("Text", "w450 y+20", "Capture webpages, create instant hotstrings, share anywhere.")
    
    ; Storage location
    setupGui.Add("Text", "w450 y+25", "")
    setupGui.SetFont("s11 bold")
    setupGui.Add("Text", "w450", "Where should captures be stored?")
    setupGui.SetFont("s10 norm")
    
    defaultPath := A_ScriptDir
    setupGui.Add("Edit", "vStoragePath w360 y+10", defaultPath)
    setupGui.Add("Button", "x+10 w80 yp h24", "Browse...").OnEvent("Click", CC_BrowseFolder)
    
    ; Options
    setupGui.Add("CheckBox", "vAddToStartup xm y+20", "Start ContentCapture Pro when Windows starts")
    
    ; Quick start info
    setupGui.SetFont("s10 c666666")
    setupGui.Add("Text", "w450 y+25 xm", "Quick Start after setup:")
    setupGui.Add("Text", "w450 y+5", "• Ctrl+Alt+P → Capture a webpage")
    setupGui.Add("Text", "w450 y+3", "• Ctrl+Alt+B → Browse your captures")
    setupGui.Add("Text", "w450 y+3", "• Type capture name + suffix → Instant action")
    
    ; Buttons
    setupGui.SetFont("s11 norm c000000")
    setupGui.Add("Button", "xm y+30 w140 h35 Default", "Get Started →").OnEvent("Click", CC_SaveSetup)
    setupGui.Add("Button", "x+20 w100 h35", "Cancel").OnEvent("Click", (*) => ExitApp())
    
    setupGui.Show()
    WinWaitClose(setupGui)
}

CC_BrowseFolder(btn, *) {
    folder := DirSelect("*" A_ScriptDir, 3, "Select folder for ContentCapture data")
    if (folder != "")
        btn.Gui["StoragePath"].Value := folder
}

CC_SaveSetup(btn, *) {
    global CC_ConfigFile
    
    saved := btn.Gui.Submit()
    storagePath := saved.StoragePath
    addToStartup := saved.AddToStartup
    
    ; Validate/create storage path
    if (!DirExist(storagePath)) {
        try {
            DirCreate(storagePath)
        } catch {
            MsgBox("Could not create folder: " storagePath, "Error", 16)
            return
        }
    }
    
    ; Save config
    try {
        IniWrite(storagePath, CC_ConfigFile, "Paths", "BaseDir")
        IniWrite(storagePath "\captures.dat", CC_ConfigFile, "Paths", "DataFile")
        IniWrite(storagePath "\capture_index.txt", CC_ConfigFile, "Paths", "IndexFile")
        IniWrite(storagePath "\contentcapture_log.txt", CC_ConfigFile, "Paths", "LogFile")
        IniWrite(storagePath "\archive", CC_ConfigFile, "Paths", "ArchiveDir")
        IniWrite(storagePath "\backup", CC_ConfigFile, "Paths", "BackupDir")
        IniWrite("4.2", CC_ConfigFile, "Settings", "Version")
        IniWrite("2", CC_ConfigFile, "Settings", "MaxFileSizeMB")
        IniWrite(FormatTime(, "yyyy-MM-dd HH:mm:ss"), CC_ConfigFile, "Settings", "FirstRun")
        IniWrite("0", CC_ConfigFile, "Settings", "TutorialComplete")
        
        ; Social media defaults (use SocialMedia section to match CC_LoadConfig)
        IniWrite("1", CC_ConfigFile, "SocialMedia", "EnableEmail")
        IniWrite("1", CC_ConfigFile, "SocialMedia", "EnableFacebook")
        IniWrite("1", CC_ConfigFile, "SocialMedia", "EnableTwitter")
        IniWrite("1", CC_ConfigFile, "SocialMedia", "EnableBluesky")
        IniWrite("0", CC_ConfigFile, "SocialMedia", "EnableLinkedIn")
        IniWrite("0", CC_ConfigFile, "SocialMedia", "EnableMastodon")
    } catch as e {
        MsgBox("Could not save config: " e.Message, "Error", 16)
        return
    }
    
    ; Add to startup if requested
    if (addToStartup)
        CC_AddToStartup()
    
    ; Create captures.dat if it doesn't exist
    dataFile := storagePath "\captures.dat"
    if (!FileExist(dataFile)) {
        try {
            FileAppend("; ContentCapture Pro - Capture Data`n; Version: 4.2`n; Created: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n`n", dataFile, "UTF-8")
        }
    }
    
    MsgBox("Setup complete! ContentCapture Pro is ready.`n`n"
        . "📁 Captures saved to: " storagePath "`n`n"
        . "Hotkeys:`n"
        . "• Ctrl+Alt+P → Capture webpage`n"
        . "• Ctrl+Alt+B → Browse captures`n"
        . "• Ctrl+Alt+Space → Quick search`n`n"
        . "The script will now reload.", "Setup Complete", "64")
    
    Reload()
}

CC_AddToStartup() {
    startupFolder := A_Startup
    shortcutPath := startupFolder "\ContentCapture Pro.lnk"
    
    try {
        if FileExist(shortcutPath)
            FileDelete(shortcutPath)
        
        ComObj := ComObject("WScript.Shell")
        Shortcut := ComObj.CreateShortcut(shortcutPath)
        Shortcut.TargetPath := A_ScriptFullPath
        Shortcut.WorkingDirectory := A_ScriptDir
        Shortcut.Description := "ContentCapture Pro - Capture and share content instantly"
        Shortcut.Save()
    }
}
