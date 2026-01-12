#Requires AutoHotkey v2.0+
#SingleInstance Force

; ==============================================================================
; ContentCapture Pro - First Run Setup Wizard
; ==============================================================================
; This runs on first launch (no config file) or when user requests setup.
; 
; For NEW users: Standalone mode - just works
; For EXPERIENCED users: Integration mode - adds #Include to their main script
; ==============================================================================

class CCSetup {
    static CONFIG_FILE := A_ScriptDir "\ContentCapture-Config.ini"
    static VERSION := "4.2"
    
    ; ==== MAIN ENTRY POINT ====
    static Run() {
        ; Check if this is first run
        if (!FileExist(this.CONFIG_FILE)) {
            this.ShowWelcomeWizard()
        } else {
            this.ShowSettingsMenu()
        }
    }
    
    ; ==== WELCOME WIZARD (First Run) ====
    static ShowWelcomeWizard() {
        wizardGui := Gui("+AlwaysOnTop", "ContentCapture Pro - Welcome!")
        wizardGui.SetFont("s11")
        wizardGui.BackColor := "FFFFFF"
        
        ; Header
        wizardGui.SetFont("s16 bold")
        wizardGui.Add("Text", "w500 Center", "Welcome to ContentCapture Pro!")
        
        wizardGui.SetFont("s10 norm")
        wizardGui.Add("Text", "w500 Center c666666", "Version " this.VERSION)
        
        wizardGui.Add("Text", "w500 y+20", "Capture webpages, create instant hotstrings, share anywhere.")
        
        ; Detect AHK installation
        ahkInstalled := this.DetectAHK()
        
        wizardGui.Add("Text", "w500 y+20", "")  ; Spacer
        
        ; User type selection
        wizardGui.SetFont("s11 bold")
        wizardGui.Add("Text", "w500", "How would you like to use ContentCapture Pro?")
        wizardGui.SetFont("s10 norm")
        
        ; Option 1: Standalone (for everyone)
        wizardGui.Add("Radio", "vUserType w500 y+15 Checked", "🚀 Standalone Mode (Recommended)")
        wizardGui.Add("Text", "x+0 w400 c666666 y+2 xp+25", "Run ContentCapture Pro by itself. Best for most users.")
        
        ; Option 2: Integration (for experienced users)
        wizardGui.Add("Radio", "w500 xm y+15", "🔧 Integration Mode (Advanced)")
        if (ahkInstalled) {
            wizardGui.Add("Text", "w400 c666666 y+2 xp+25", "Add to your existing AutoHotkey script. For power users.")
        } else {
            wizardGui.Add("Text", "w400 cCC0000 y+2 xp+25", "AutoHotkey not detected. Install AHK first to use this option.")
        }
        
        wizardGui.ahkInstalled := ahkInstalled
        
        ; Storage location
        wizardGui.Add("Text", "xm w500 y+25", "")
        wizardGui.SetFont("s11 bold")
        wizardGui.Add("Text", "w500 xm", "Where should captures be stored?")
        wizardGui.SetFont("s10 norm")
        
        defaultPath := A_ScriptDir
        wizardGui.Add("Edit", "vStoragePath w400 y+10", defaultPath)
        wizardGui.Add("Button", "x+10 w80 yp", "Browse...").OnEvent("Click", (*) => this.BrowseFolder(wizardGui))
        
        ; Startup option
        wizardGui.Add("CheckBox", "vAddToStartup xm y+20", "Start ContentCapture Pro when Windows starts")
        
        ; Buttons
        wizardGui.Add("Button", "xm y+30 w120 h35 Default", "Continue →").OnEvent("Click", (*) => this.ProcessWizard(wizardGui))
        wizardGui.Add("Button", "x+20 w120 h35", "Cancel").OnEvent("Click", (*) => ExitApp())
        
        wizardGui.Show()
    }
    
    ; ==== DETECT AHK INSTALLATION ====
    static DetectAHK() {
        ; Check common installation paths
        paths := [
            "C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe",
            "C:\Program Files\AutoHotkey\v2\AutoHotkey32.exe",
            A_MyDocuments "\AutoHotkey\AutoHotkey.exe",
            A_AppData "\AutoHotkey\AutoHotkey.exe"
        ]
        
        for path in paths {
            if FileExist(path)
                return true
        }
        
        ; Check if ahk files are associated
        try {
            RegRead("HKCR\.ahk", "")
            return true
        } catch {
            return false
        }
    }
    
    ; ==== BROWSE FOR FOLDER ====
    static BrowseFolder(gui) {
        folder := DirSelect("*" A_ScriptDir, 3, "Select folder for ContentCapture data")
        if (folder != "")
            gui["StoragePath"].Value := folder
    }
    
    ; ==== PROCESS WIZARD CHOICES ====
    static ProcessWizard(gui) {
        saved := gui.Submit()
        
        ; Get user type (1 = standalone, 2 = integration)
        userType := saved.UserType
        storagePath := saved.StoragePath
        addToStartup := saved.AddToStartup
        
        ; Validate storage path
        if (!DirExist(storagePath)) {
            try {
                DirCreate(storagePath)
            } catch {
                MsgBox("Could not create folder: " storagePath, "Error", 16)
                return
            }
        }
        
        if (userType = 2 && gui.ahkInstalled) {
            ; Integration mode
            this.ShowIntegrationSetup(storagePath, addToStartup)
        } else {
            ; Standalone mode
            this.SetupStandalone(storagePath, addToStartup)
        }
    }
    
    ; ==== STANDALONE SETUP ====
    static SetupStandalone(storagePath, addToStartup) {
        ; Save config
        this.SaveConfig("standalone", storagePath, "")
        
        ; Add to startup if requested
        if (addToStartup)
            this.AddToStartup()
        
        ; Show success
        MsgBox("ContentCapture Pro is ready!`n`n"
            . "📁 Captures saved to: " storagePath "`n`n"
            . "Quick Start:`n"
            . "• Ctrl+Alt+P - Capture a webpage`n"
            . "• Ctrl+Alt+B - Browse your captures`n"
            . "• Ctrl+Alt+Space - Quick search`n`n"
            . "Type any capture name to paste it!",
            "Setup Complete", "64")
        
        Reload()
    }
    
    ; ==== INTEGRATION SETUP ====
    static ShowIntegrationSetup(storagePath, addToStartup) {
        intGui := Gui("+AlwaysOnTop", "Integration Setup")
        intGui.SetFont("s10")
        intGui.storagePath := storagePath
        intGui.addToStartup := addToStartup
        
        intGui.Add("Text", "w450", "Select your main AutoHotkey script file.")
        intGui.Add("Text", "w450 c666666", "ContentCapture Pro will add an #Include line to integrate with it.")
        
        intGui.Add("Text", "w450 y+20", "Your main .ahk file:")
        intGui.Add("Edit", "vMainScript w350 y+5 ReadOnly", "")
        intGui.Add("Button", "x+10 w80 yp", "Browse...").OnEvent("Click", (*) => this.BrowseMainScript(intGui))
        
        ; Preview
        intGui.Add("Text", "xm w450 y+20", "Preview - This line will be added:")
        intGui.Add("Edit", "vPreview w450 h60 ReadOnly c666666 y+5", "(Select a file first)")
        
        ; Options
        intGui.Add("CheckBox", "vBackupFirst xm y+15 Checked", "Backup original file first (recommended)")
        
        ; Buttons
        intGui.Add("Button", "xm y+25 w120 h30", "← Back").OnEvent("Click", (*) => this.GoBackToWizard(intGui))
        intGui.Add("Button", "x+20 w120 h30 Default Disabled", "Install").OnEvent("Click", (*) => this.DoIntegration(intGui))
        intGui["Install"].Enabled := false
        
        intGui.Add("Button", "x+20 w100 h30", "Cancel").OnEvent("Click", (*) => ExitApp())
        
        intGui.Show()
    }
    
    ; ==== BROWSE FOR MAIN SCRIPT ====
    static BrowseMainScript(gui) {
        ; Start in common AHK locations
        startPath := A_MyDocuments
        if (DirExist(A_MyDocuments "\AutoHotkey"))
            startPath := A_MyDocuments "\AutoHotkey"
        
        file := FileSelect(1, startPath, "Select your main AutoHotkey script", "AutoHotkey Scripts (*.ahk)")
        
        if (file != "") {
            gui["MainScript"].Value := file
            
            ; Generate include line
            includePath := A_ScriptDir "\ContentCapture-Pro.ahk"
            includeLine := '#Include "' includePath '"'
            
            gui["Preview"].Value := "; ContentCapture Pro Integration`n" includeLine
            gui["Install"].Enabled := true
        }
    }
    
    ; ==== GO BACK TO WIZARD ====
    static GoBackToWizard(gui) {
        gui.Destroy()
        this.ShowWelcomeWizard()
    }
    
    ; ==== PERFORM INTEGRATION ====
    static DoIntegration(gui) {
        saved := gui.Submit()
        
        mainScript := saved.MainScript
        backupFirst := saved.BackupFirst
        storagePath := gui.storagePath
        addToStartup := gui.addToStartup
        
        if (mainScript = "" || !FileExist(mainScript)) {
            MsgBox("Please select a valid .ahk file", "Error", 16)
            return
        }
        
        ; Backup if requested
        if (backupFirst) {
            backupPath := mainScript . ".backup-" FormatTime(, "yyyyMMdd-HHmmss")
            try {
                FileCopy(mainScript, backupPath)
            } catch as err {
                MsgBox("Could not create backup: " err.Message, "Error", 16)
                return
            }
        }
        
        ; Read the file
        try {
            content := FileRead(mainScript, "UTF-8")
        } catch as err {
            MsgBox("Could not read file: " err.Message, "Error", 16)
            return
        }
        
        ; Check if already integrated
        if (InStr(content, "ContentCapture-Pro.ahk")) {
            MsgBox("This script already includes ContentCapture Pro!", "Already Integrated", 48)
            return
        }
        
        ; Find the right place to insert (after #Requires and #SingleInstance)
        includePath := A_ScriptDir "\ContentCapture-Pro.ahk"
        includeLine := '`n; ContentCapture Pro Integration`n#Include "' includePath '"`n'
        
        ; Try to insert after #SingleInstance or #Requires
        if (RegExMatch(content, "im)^#SingleInstance.*$", &match)) {
            insertPos := match.Pos + match.Len
            newContent := SubStr(content, 1, insertPos) . includeLine . SubStr(content, insertPos + 1)
        } else if (RegExMatch(content, "im)^#Requires.*$", &match)) {
            insertPos := match.Pos + match.Len
            newContent := SubStr(content, 1, insertPos) . includeLine . SubStr(content, insertPos + 1)
        } else {
            ; Just add at the top
            newContent := includeLine . content
        }
        
        ; Write the file
        try {
            FileDelete(mainScript)
            FileAppend(newContent, mainScript, "UTF-8")
        } catch as err {
            MsgBox("Could not write file: " err.Message, "Error", 16)
            return
        }
        
        ; Save config
        this.SaveConfig("integrated", storagePath, mainScript)
        
        ; Success message
        MsgBox("ContentCapture Pro integrated successfully!`n`n"
            . "📄 Modified: " mainScript "`n"
            . (backupFirst ? "💾 Backup: " mainScript ".backup-*`n`n" : "`n")
            . "Reload your main script to activate ContentCapture Pro.",
            "Integration Complete", "64")
        
        ExitApp()
    }
    
    ; ==== SAVE CONFIG ====
    static SaveConfig(mode, storagePath, mainScript) {
        config := "[Settings]`n"
        config .= "Mode=" mode "`n"
        config .= "StoragePath=" storagePath "`n"
        config .= "MainScript=" mainScript "`n"
        config .= "Version=" this.VERSION "`n"
        config .= "FirstRun=" FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n"
        
        try {
            if FileExist(this.CONFIG_FILE)
                FileDelete(this.CONFIG_FILE)
            FileAppend(config, this.CONFIG_FILE, "UTF-8")
        }
    }
    
    ; ==== ADD TO STARTUP ====
    static AddToStartup() {
        startupFolder := A_Startup
        shortcutPath := startupFolder "\ContentCapture Pro.lnk"
        
        try {
            if FileExist(shortcutPath)
                FileDelete(shortcutPath)
            
            ; Create shortcut
            ComObj := ComObject("WScript.Shell")
            Shortcut := ComObj.CreateShortcut(shortcutPath)
            Shortcut.TargetPath := A_ScriptFullPath
            Shortcut.WorkingDirectory := A_ScriptDir
            Shortcut.Description := "ContentCapture Pro - Capture and share content instantly"
            Shortcut.Save()
        } catch as err {
            MsgBox("Could not add to startup: " err.Message, "Warning", 48)
        }
    }
    
    ; ==== SETTINGS MENU (After Setup) ====
    static ShowSettingsMenu() {
        ; Read current config
        try {
            mode := IniRead(this.CONFIG_FILE, "Settings", "Mode", "standalone")
            storagePath := IniRead(this.CONFIG_FILE, "Settings", "StoragePath", A_ScriptDir)
            mainScript := IniRead(this.CONFIG_FILE, "Settings", "MainScript", "")
        } catch {
            mode := "standalone"
            storagePath := A_ScriptDir
            mainScript := ""
        }
        
        setGui := Gui("+AlwaysOnTop", "ContentCapture Pro - Settings")
        setGui.SetFont("s10")
        
        setGui.Add("Text", "w400", "Current Mode: " (mode = "standalone" ? "🚀 Standalone" : "🔧 Integrated"))
        setGui.Add("Text", "w400", "Storage: " storagePath)
        if (mainScript != "")
            setGui.Add("Text", "w400", "Main Script: " mainScript)
        
        setGui.Add("Text", "w400 y+20", "")
        
        setGui.Add("Button", "w150 h30", "Change Storage").OnEvent("Click", (*) => this.ChangeStorage(setGui))
        setGui.Add("Button", "x+10 w150 h30", "Run Setup Again").OnEvent("Click", (*) => this.RerunSetup(setGui))
        setGui.Add("Button", "xm y+15 w150 h30", "Manage Startup").OnEvent("Click", (*) => this.ManageStartup())
        setGui.Add("Button", "x+10 w150 h30", "Close").OnEvent("Click", (*) => setGui.Destroy())
        
        setGui.Show()
    }
    
    ; ==== CHANGE STORAGE ====
    static ChangeStorage(gui) {
        folder := DirSelect("*" A_ScriptDir, 3, "Select new folder for ContentCapture data")
        if (folder != "") {
            try {
                IniWrite(folder, this.CONFIG_FILE, "Settings", "StoragePath")
                MsgBox("Storage path updated to:`n" folder "`n`nReload to apply.", "Settings Updated", 64)
                gui.Destroy()
            }
        }
    }
    
    ; ==== RERUN SETUP ====
    static RerunSetup(gui) {
        gui.Destroy()
        if FileExist(this.CONFIG_FILE)
            FileDelete(this.CONFIG_FILE)
        this.ShowWelcomeWizard()
    }
    
    ; ==== MANAGE STARTUP ====
    static ManageStartup() {
        shortcutPath := A_Startup "\ContentCapture Pro.lnk"
        inStartup := FileExist(shortcutPath)
        
        if (inStartup) {
            result := MsgBox("ContentCapture Pro is in Windows startup.`n`nRemove from startup?", "Manage Startup", "YesNo")
            if (result = "Yes") {
                FileDelete(shortcutPath)
                MsgBox("Removed from startup.", "Done", 64)
            }
        } else {
            result := MsgBox("ContentCapture Pro is NOT in Windows startup.`n`nAdd to startup?", "Manage Startup", "YesNo")
            if (result = "Yes") {
                this.AddToStartup()
                MsgBox("Added to startup.", "Done", 64)
            }
        }
    }
}

; ==============================================================================
; Run setup if called directly
; ==============================================================================
if (A_ScriptName = "ContentCapture-Setup.ahk") {
    CCSetup.Run()
}
