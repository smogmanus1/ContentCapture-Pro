#Requires AutoHotkey v2.0
; ManualCapture.ahk - Manual Content Capture Module for ContentCapture Pro
; Version: 6.1.0
; Features: Full manual capture dialog with image attachment support

; ============================================================================
; MANUAL CAPTURE GUI
; ============================================================================

class ManualCaptureGUI {
    static gui := ""
    static controls := Map()
    static selectedTags := []
    static imagePath := ""
    static imagePreview := ""
    
    ; Available tags matching your existing system
    static availableTags := [
        "music", "politics", "tutorial", "news", "reference", "funny",
        "documentary", "tech", "personal", "work", "AI", "programming",
        "health", "science", "history", "education", "travel", "surveillance",
        "privacy", "automation", "autohotkey"
    ]
    
    static Show() {
        ; Destroy existing GUI if open
        if (this.gui) {
            try this.gui.Destroy()
        }
        
        this.selectedTags := []
        this.imagePath := ""
        
        ; Create the GUI
        this.gui := Gui("+Resize", "Manual Capture - Add Your Own Content")
        this.gui.SetFont("s9", "Segoe UI")
        this.gui.MarginX := 15
        this.gui.MarginY := 10
        
        ; ---- Hotstring Name ----
        this.gui.AddText("xm", "Hotstring Name (required, no spaces):")
        this.gui.AddText("x+10 yp cGray", "Example: rule72, mytip, quote1")
        this.controls["HotstringName"] := this.gui.AddEdit("xm w200 vHotstringName")
        
        ; ---- URL ----
        this.gui.AddText("xm", "URL (optional):")
        this.controls["URL"] := this.gui.AddEdit("xm w550 vURL")
        
        ; ---- Title ----
        this.gui.AddText("xm", "Title (optional - auto-generated if blank):")
        this.controls["Title"] := this.gui.AddEdit("xm w550 vTitle")
        
        ; ---- Tags Section ----
        this.gui.AddText("xm", "Tags (click to select):")
        this.gui.AddText("xm h1 w550 0x10")  ; Horizontal line
        
        ; Create tag checkboxes in a grid (6 columns)
        tagX := 15
        tagY := 0
        colWidth := 95
        colCount := 0
        
        for index, tag in this.availableTags {
            if (colCount = 0) {
                this.controls["Tag_" tag] := this.gui.AddCheckbox("xm y+5 w" colWidth " vTag_" tag, tag)
            } else {
                this.controls["Tag_" tag] := this.gui.AddCheckbox("x+5 yp w" colWidth " vTag_" tag, tag)
            }
            colCount++
            if (colCount >= 6) {
                colCount := 0
            }
        }
        
        ; ---- Image Attachment Section ----
        this.gui.AddText("xm y+15", "")
        this.gui.AddGroupBox("xm w550 h85", "📷 Image Attachment (optional)")
        
        this.controls["ImagePath"] := this.gui.AddEdit("xm+10 yp+20 w400 vImagePath ReadOnly", "No image selected")
        this.controls["ImagePath"].SetFont("cGray")
        
        btnBrowse := this.gui.AddButton("x+5 yp-1 w70", "Browse...")
        btnBrowse.OnEvent("Click", (*) => this.BrowseImage())
        
        btnClearImage := this.gui.AddButton("x+5 yp w70", "Clear")
        btnClearImage.OnEvent("Click", (*) => this.ClearImage())
        
        ; Image preview label
        this.controls["ImagePreviewLabel"] := this.gui.AddText("xm+10 y+5 w530 h30 cGray", "Supported formats: JPG, PNG, GIF, BMP, WEBP")
        
        ; ---- Opinion ----
        this.gui.AddText("xm y+20", "Opinion (included when you paste):")
        this.controls["Opinion"] := this.gui.AddEdit("xm w550 h60 vOpinion Multi")
        
        ; ---- Private Note ----
        this.gui.AddText("xm", "🔒 Private Note (only you see this):")
        this.controls["PrivateNote"] := this.gui.AddEdit("xm w550 h60 vPrivateNote Multi")
        
        ; ---- Research Notes ----
        this.gui.AddText("xm", "📚 Research Notes (verification/fact-check results):")
        this.controls["ResearchNotes"] := this.gui.AddEdit("xm w550 h60 vResearchNotes Multi Background0xFFFFF0")
        
        ; ---- Short Version ----
        this.gui.AddText("xm y+10", "🐦 Short Version (Bluesky/X - 300 char max):")
        this.controls["ShortCharCount"] := this.gui.AddText("x+150 yp w80 Right", "0/300 chars")
        btnAutoFormatShort := this.gui.AddButton("x+5 yp-3 w90", "✨ Auto-Format")
        btnAutoFormatShort.OnEvent("Click", (*) => this.AutoFormatShort())
        
        this.controls["ShortVersion"] := this.gui.AddEdit("xm w550 h60 vShortVersion Multi")
        this.controls["ShortVersion"].OnEvent("Change", (*) => this.UpdateShortCharCount())
        
        ; ---- Content ----
        this.gui.AddText("xm y+10", "Content:")
        btnAutoFormatContent := this.gui.AddButton("x+10 yp-3 w90", "✨ Auto-Format")
        btnAutoFormatContent.OnEvent("Click", (*) => this.AutoFormatContent())
        
        this.controls["Content"] := this.gui.AddEdit("xm w550 h120 vContent Multi")
        
        ; ---- Buttons ----
        this.gui.AddText("xm y+15 h1 w550 0x10")  ; Horizontal line
        
        btnSave := this.gui.AddButton("xm w80 h30", "💾 Save")
        btnSave.OnEvent("Click", (*) => this.SaveCapture())
        
        btnCancel := this.gui.AddButton("x+10 yp w80 h30", "Cancel")
        btnCancel.OnEvent("Click", (*) => this.gui.Destroy())
        
        ; Help text
        this.gui.AddText("x+30 yp+5 cGray", "After saving, type the name + suffix:")
        this.gui.AddText("x+5 yp c0x0066CC", "name = paste,  namesh = short,  namego = open URL")
        
        ; Show the GUI
        this.gui.OnEvent("Close", (*) => this.gui.Destroy())
        this.gui.OnEvent("Escape", (*) => this.gui.Destroy())
        this.gui.Show("AutoSize")
        
        ; Focus the hotstring name field
        this.controls["HotstringName"].Focus()
    }
    
    ; ---- Browse for Image ----
    static BrowseImage() {
        selectedFile := FileSelect(1, , "Select Image File", "Image Files (*.jpg; *.jpeg; *.png; *.gif; *.bmp; *.webp)")
        
        if (selectedFile) {
            this.imagePath := selectedFile
            this.controls["ImagePath"].Value := selectedFile
            this.controls["ImagePath"].SetFont("cBlack")
            
            ; Get file info for preview label
            try {
                fileSize := FileGetSize(selectedFile)
                fileSizeKB := Round(fileSize / 1024, 1)
                SplitPath(selectedFile, &fileName)
                this.controls["ImagePreviewLabel"].Text := "✓ " fileName " (" fileSizeKB " KB)"
                this.controls["ImagePreviewLabel"].SetFont("cGreen")
            } catch {
                this.controls["ImagePreviewLabel"].Text := "✓ Image selected"
                this.controls["ImagePreviewLabel"].SetFont("cGreen")
            }
        }
    }
    
    ; ---- Clear Image ----
    static ClearImage() {
        this.imagePath := ""
        this.controls["ImagePath"].Value := "No image selected"
        this.controls["ImagePath"].SetFont("cGray")
        this.controls["ImagePreviewLabel"].Text := "Supported formats: JPG, PNG, GIF, BMP, WEBP"
        this.controls["ImagePreviewLabel"].SetFont("cGray")
    }
    
    ; ---- Update Short Version Character Count ----
    static UpdateShortCharCount() {
        text := this.controls["ShortVersion"].Value
        charCount := StrLen(text)
        this.controls["ShortCharCount"].Text := charCount "/300 chars"
        
        if (charCount > 300) {
            this.controls["ShortCharCount"].SetFont("cRed Bold")
        } else if (charCount > 250) {
            this.controls["ShortCharCount"].SetFont("cOrange")
        } else {
            this.controls["ShortCharCount"].SetFont("cBlack")
        }
    }
    
    ; ---- Auto-Format Short Version ----
    static AutoFormatShort() {
        content := this.controls["Content"].Value
        url := this.controls["URL"].Value
        title := this.controls["Title"].Value
        
        ; Build short version: Title + URL (prioritize fitting within 300 chars)
        shortText := ""
        
        if (title) {
            shortText := title
        }
        
        if (url) {
            if (shortText) {
                shortText .= "`n" url
            } else {
                shortText := url
            }
        }
        
        ; If still under limit and we have content, add excerpt
        if (StrLen(shortText) < 250 && content) {
            remaining := 295 - StrLen(shortText)
            if (remaining > 50) {
                excerpt := SubStr(content, 1, remaining - 5) "..."
                shortText .= "`n" excerpt
            }
        }
        
        this.controls["ShortVersion"].Value := shortText
        this.UpdateShortCharCount()
    }
    
    ; ---- Auto-Format Content ----
    static AutoFormatContent() {
        title := this.controls["Title"].Value
        url := this.controls["URL"].Value
        content := this.controls["Content"].Value
        opinion := this.controls["Opinion"].Value
        
        ; Build formatted content
        formatted := ""
        
        if (title) {
            formatted := title "`n"
        }
        
        if (url) {
            formatted .= url "`n"
        }
        
        if (formatted && (content || opinion)) {
            formatted .= "`n"
        }
        
        if (opinion) {
            formatted .= opinion "`n`n"
        }
        
        if (content) {
            formatted .= content
        }
        
        this.controls["Content"].Value := Trim(formatted)
    }
    
    ; ---- Collect Selected Tags ----
    static GetSelectedTags() {
        tags := []
        for tag in this.availableTags {
            if (this.controls["Tag_" tag].Value) {
                tags.Push(tag)
            }
        }
        return tags
    }
    
    ; ---- Save Capture ----
    static SaveCapture() {
        ; Get all values
        submitted := this.gui.Submit(false)  ; Don't hide yet
        
        hotstringName := Trim(submitted.HotstringName)
        url := Trim(submitted.URL)
        title := Trim(submitted.Title)
        opinion := Trim(submitted.Opinion)
        privateNote := Trim(submitted.PrivateNote)
        researchNotes := Trim(submitted.ResearchNotes)
        shortVersion := Trim(submitted.ShortVersion)
        content := Trim(submitted.Content)
        
        ; Validation
        if (!hotstringName) {
            MsgBox("Please enter a Hotstring Name.", "Validation Error", "Icon!")
            this.controls["HotstringName"].Focus()
            return
        }
        
        ; Check for spaces in hotstring name
        if (InStr(hotstringName, " ")) {
            MsgBox("Hotstring Name cannot contain spaces.", "Validation Error", "Icon!")
            this.controls["HotstringName"].Focus()
            return
        }
        
        ; Check for content
        if (!content && !url) {
            MsgBox("Please enter Content or a URL.", "Validation Error", "Icon!")
            this.controls["Content"].Focus()
            return
        }
        
        ; Get selected tags
        selectedTags := this.GetSelectedTags()
        tagsStr := ""
        for tag in selectedTags {
            tagsStr .= "#" tag " "
        }
        tagsStr := Trim(tagsStr)
        
        ; Auto-generate title if blank
        if (!title && url) {
            title := this.ExtractDomainFromURL(url)
        } else if (!title && content) {
            ; Use first line of content as title
            firstLine := StrSplit(content, "`n")[1]
            title := SubStr(firstLine, 1, 100)
        }
        
        ; Build the capture data object
        captureData := Map(
            "name", hotstringName,
            "url", url,
            "title", title,
            "tags", selectedTags,
            "opinion", opinion,
            "privateNote", privateNote,
            "researchNotes", researchNotes,
            "shortVersion", shortVersion,
            "content", content,
            "imagePath", this.imagePath,
            "captureDate", FormatTime(, "yyyy-MM-dd HH:mm:ss"),
            "source", "manual"
        )
        
        ; Generate and save the hotstrings
        try {
            this.GenerateHotstrings(captureData)
            
            ; Success message
            MsgBox("Capture saved successfully!`n`nHotstring: " hotstringName "`nTags: " (tagsStr ? tagsStr : "(none)")`n`n" (this.imagePath ? "Image: " this.imagePath : ""), "Success", "Iconi")
            
            this.gui.Destroy()
        } catch as e {
            MsgBox("Error saving capture: " e.Message, "Error", "Icon!")
        }
    }
    
    ; ---- Extract Domain from URL ----
    static ExtractDomainFromURL(url) {
        ; Remove protocol
        domain := RegExReplace(url, "^https?://", "")
        ; Remove path
        domain := StrSplit(domain, "/")[1]
        ; Remove www.
        domain := RegExReplace(domain, "^www\.", "")
        return domain
    }
    
    ; ---- Generate Hotstrings ----
    static GenerateHotstrings(data) {
        ; Build the full content string
        fullContent := ""
        
        if (data["title"]) {
            fullContent := data["title"] "`n"
        }
        
        if (data["url"]) {
            fullContent .= data["url"] "`n"
        }
        
        if (data["opinion"]) {
            fullContent .= "`n" data["opinion"] "`n"
        }
        
        if (data["content"]) {
            fullContent .= "`n" data["content"]
        }
        
        fullContent := Trim(fullContent)
        
        ; Prepare tags comment
        tagsComment := ""
        for tag in data["tags"] {
            tagsComment .= "#" tag " "
        }
        
        ; Generate timestamp
        timestamp := FormatTime(, "dddd, MMMM dd, yyyy h:mm tt")
        
        ; Build the hotstring block
        hotstringBlock := "
        (
;~------------------------------------------------------------------------------

::" data["name"] "::   ;~ " timestamp "  " tagsComment "
" data["name"] "Func()
onesecfunc()
return

" data["name"] "Func() {
    clipboard := " data["name"] "_content()
    ClipWait, 2
    if ErrorLevel
        MsgBox, Failed to copy to clipboard
}

" data["name"] "_content() {
    return `"" this.EscapeForAHK(fullContent) "`"
}

" data["name"] "_title() {
    return `"" this.EscapeForAHK(data["title"]) "`"
}

" data["name"] "_url() {
    return `"" data["url"] "`"
}

::" data["name"] "go::
run " data["url"] "
return

::" data["name"] "m::
" data["name"] "Func()
MsgBox `%Clipboard`%
return

::" data["name"] "em::
" data["name"] "EmailFunc()
return

" data["name"] "EmailFunc() {
    SendOutlookEmail(" data["name"] "_content())
}
        )"
        
        ; Add short version hotstring if provided
        if (data["shortVersion"]) {
            hotstringBlock .= "
            (

::" data["name"] "sh::
clipboard := `"" this.EscapeForAHK(data["shortVersion"]) "`"
ClipWait, 2
send ^v
return
            )"
        }
        
        ; Add image path hotstring if provided
        if (data["imagePath"]) {
            hotstringBlock .= "
            (

::" data["name"] "img::
clipboard := `"" data["imagePath"] "`"
ClipWait, 2
return

" data["name"] "_imagePath() {
    return `"" data["imagePath"] "`"
}
            )"
        }
        
        ; Append to the captures file
        capturesFile := A_ScriptDir "\sharejason.ahk"
        
        ; Backup first
        if (FileExist(capturesFile)) {
            backupFile := A_ScriptDir "\backups\sharejason_" FormatTime(, "yyyyMMdd_HHmmss") ".ahk.bak"
            try {
                DirCreate(A_ScriptDir "\backups")
                FileCopy(capturesFile, backupFile)
            }
        }
        
        ; Append the new hotstrings
        FileAppend(hotstringBlock "`n", capturesFile)
        
        ; Save to JSON data file as well (for the capture browser)
        this.SaveToJSON(data)
        
        ; Reload the script to activate new hotstrings
        ; Reload  ; Uncomment to auto-reload
    }
    
    ; ---- Escape content for AHK strings ----
    static EscapeForAHK(text) {
        if (!text)
            return ""
        
        ; Escape special characters
        text := StrReplace(text, "\", "\\")
        text := StrReplace(text, "`"", "\`"")
        text := StrReplace(text, "`r`n", "\r\n")
        text := StrReplace(text, "`n", "\n")
        text := StrReplace(text, "`r", "\r")
        text := StrReplace(text, "`t", "\t")
        
        return text
    }
    
    ; ---- Save to JSON ----
    static SaveToJSON(data) {
        jsonFile := A_ScriptDir "\captures.json"
        
        ; Load existing data
        captures := []
        if (FileExist(jsonFile)) {
            try {
                jsonContent := FileRead(jsonFile)
                captures := JSON.Load(jsonContent)
            }
        }
        
        ; Add new capture
        captures.Push(data)
        
        ; Save back to file
        try {
            jsonOutput := JSON.Dump(captures)
            FileDelete(jsonFile)
            FileAppend(jsonOutput, jsonFile)
        }
    }
}

; ============================================================================
; HOTKEY TO LAUNCH MANUAL CAPTURE
; ============================================================================

; Ctrl+Alt+M to open Manual Capture GUI
^!m::ManualCaptureGUI.Show()

; ============================================================================
; JSON HELPER CLASS (if not already included)
; ============================================================================

class JSON {
    static Load(jsonStr) {
        ; Simple JSON parser - for production use a full JSON library
        return ComObject("ScriptControl").Language := "JScript", ComObject("ScriptControl").Eval("(" jsonStr ")")
    }
    
    static Dump(obj, indent := "") {
        if (Type(obj) = "Map") {
            items := []
            for key, value in obj {
                items.Push('"' key '": ' this.Dump(value))
            }
            return "{" this.Join(items, ", ") "}"
        } else if (Type(obj) = "Array") {
            items := []
            for item in obj {
                items.Push(this.Dump(item))
            }
            return "[" this.Join(items, ", ") "]"
        } else if (Type(obj) = "String") {
            return '"' StrReplace(StrReplace(obj, '\', '\\'), '"', '\"') '"'
        } else if (Type(obj) = "Integer" || Type(obj) = "Float") {
            return String(obj)
        } else {
            return '""'
        }
    }
    
    static Join(arr, delimiter) {
        result := ""
        for index, item in arr {
            if (index > 1)
                result .= delimiter
            result .= item
        }
        return result
    }
}

; ============================================================================
; HELPER FUNCTION (if not already in your common functions)
; ============================================================================

onesecfunc() {
    Sleep(1000)
}

SendOutlookEmail(content) {
    ; Placeholder - integrate with your existing email function
    try {
        outlook := ComObject("Outlook.Application")
        mail := outlook.CreateItem(0)
        mail.Body := content
        mail.Display()
    } catch {
        MsgBox("Could not open Outlook. Content copied to clipboard.", "Email", "Iconi")
    }
}
