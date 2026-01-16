; ==============================================================================
; CONFIG.INI INTEGRATION - Add to ContentCapture-Pro.ahk
; ==============================================================================
; 
; STEP 1: Add this near the top of the file (after globals, around line 400):
; ==============================================================================

global ConfigFile := A_ScriptDir "\config.ini"

; ==============================================================================
; STEP 2: Find the CC_ShowBrowser() function and add this after the ListView 
;         is created and populated (look for where it shows the GUI):
; ==============================================================================

; Load and apply default sort from config.ini
CC_ApplyBrowserDefaults(listView) {
    global ConfigFile
    
    ; Read config settings
    defaultSort := IniRead(ConfigFile, "Browser", "DefaultSort", "date")
    defaultSortOrder := IniRead(ConfigFile, "Browser", "DefaultSortOrder", "desc")
    
    ; Determine which column to sort
    sortCol := 4  ; Default to Date column
    switch defaultSort {
        case "name":
            sortCol := 1
        case "title":
            sortCol := 2
        case "tags":
            sortCol := 3
        case "date":
            sortCol := 4
    }
    
    ; Apply sort
    sortOption := (defaultSortOrder = "desc") ? "SortDesc" : "Sort"
    listView.ModifyCol(sortCol, sortOption)
}

; ==============================================================================
; STEP 3: Call CC_ApplyBrowserDefaults(listView) after populating the browser
;         In CC_ShowBrowser(), find where it does browserGui.Show() and add
;         the call just before it:
; ==============================================================================

; Example location in CC_ShowBrowser():
;
;   ... (ListView population code) ...
;   
;   ; Apply default sort from config
;   CC_ApplyBrowserDefaults(listView)
;   
;   browserGui.Show("w720 h480")

; ==============================================================================
; ALTERNATIVE: Quick inline version (add directly in CC_ShowBrowser)
; ==============================================================================

; Right before browserGui.Show(), add:

try {
    configFile := A_ScriptDir "\config.ini"
    defaultSort := IniRead(configFile, "Browser", "DefaultSort", "date")
    defaultSortOrder := IniRead(configFile, "Browser", "DefaultSortOrder", "desc")
    
    sortCol := (defaultSort = "name") ? 1 : (defaultSort = "title") ? 2 : (defaultSort = "tags") ? 3 : 4
    listView.ModifyCol(sortCol, (defaultSortOrder = "desc") ? "SortDesc" : "Sort")
}

; ==============================================================================
; That's it! The browser will now open sorted by date (newest first) by default.
; ==============================================================================
