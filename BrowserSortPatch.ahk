; ==============================================================================
; BROWSER SORT PATCH - Add to ContentCapture-Pro.ahk
; ==============================================================================
; This code reads config.ini and applies default sort to the Capture Browser
;
; ADD THIS: Near the top of the file, after global variable declarations
; ==============================================================================

global ConfigFile := A_ScriptDir "\config.ini"

; ==============================================================================
; ADD THIS: Inside CC_ShowBrowser() function, AFTER the ListView is populated
;           (after the loop that adds items to the ListView)
; ==============================================================================

; Apply default sort from config.ini
CC_ApplyDefaultSort(listView) {
    global ConfigFile
    
    ; Read config settings
    defaultSort := "date"
    defaultSortOrder := "desc"
    
    if FileExist(ConfigFile) {
        try {
            defaultSort := IniRead(ConfigFile, "Browser", "DefaultSort", "date")
            defaultSortOrder := IniRead(ConfigFile, "Browser", "DefaultSortOrder", "desc")
        }
    }
    
    ; Map sort column names to column indices
    ; Adjust these based on your actual ListView columns
    ; Column order: Icon, Name, Title, Tags, Date
    sortColMap := Map(
        "name", 2,
        "title", 3,
        "tags", 4,
        "date", 5
    )
    
    if (sortColMap.Has(defaultSort)) {
        colIndex := sortColMap[defaultSort]
        sortDir := (defaultSortOrder = "desc") ? "SortDesc" : "Sort"
        listView.ModifyCol(colIndex, sortDir)
    }
}

; ==============================================================================
; USAGE: Call CC_ApplyDefaultSort(listView) right after populating the ListView
;
; Example - in CC_ShowBrowser(), find where items are added to ListView, then add:
;
;     ; ... existing code that adds items ...
;     
;     ; Apply default sort
;     CC_ApplyDefaultSort(listView)
;
; ==============================================================================
