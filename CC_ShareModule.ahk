; ==============================================================================
; ContentCapture Pro - Share Module (Full Version)
; ==============================================================================
; Allows users to export captures and share them with other ContentCapture Pro users
; Includes: Research notes, Transcripts, Summaries, and embedded Images
; Version: 2.0
; ==============================================================================

class CC_ShareModule {
    
    ; CCP Exchange Format version
    static FormatVersion := "2.0"
    
    ; Image folder path (relative to script)
    static ImageFolder := A_ScriptDir "\images"
    
    ; ===========================================================================
    ; BUILD CAPTURE EXPORT DATA (shared helper for all export methods)
    ; ===========================================================================
    static BuildCaptureExport(name, data, includeImage := true) {
        capture := Map()
        
        ; Core fields
        capture["name"] := name
        capture["url"] := data.Has("url") ? data["url"] : ""
        capture["title"] := data.Has("title") ? data["title"] : ""
        capture["body"] := data.Has("body") ? data["body"] : ""
        capture["tags"] := data.Has("tags") ? data["tags"] : ""
        capture["date"] := data.Has("date") ? data["date"] : ""
        capture["opinion"] := data.Has("opinion") ? data["opinion"] : ""
        capture["favorite"] := data.Has("favorite") ? data["favorite"] : false
        
        ; Research fields
        capture["research"] := data.Has("research") ? data["research"] : ""
        capture["transcript"] := data.Has("transcript") ? data["transcript"] : ""
        capture["summary"] := data.Has("summary") ? data["summary"] : ""
        
        ; Image handling
        capture["hasImage"] := false
        capture["imageData"] := ""
        capture["imageType"] := ""
        capture["imageName"] := ""
        
        if includeImage && data.Has("image") && data["image"] != "" {
            imagePath := data["image"]
            
            ; Handle relative paths
            if !InStr(imagePath, ":") && !InStr(imagePath, "\\")
                imagePath := this.ImageFolder "\" imagePath
            
            if FileExist(imagePath) {
                capture["hasImage"] := true
                capture["imageName"] := this.GetFileName(imagePath)
                capture["imageType"] := this.GetImageType(imagePath)
                capture["imageData"] := this.ImageToBase64(imagePath)
            }
        }
        
        return capture
    }
    
    ; ===========================================================================
    ; EXPORT: Single Capture to Clipboard (JSON)
    ; ===========================================================================
    static ExportToClipboard(captureName, includeImage := true) {
        global CaptureData
        
        if !CaptureData.Has(captureName) {
            MsgBox("Capture '" captureName "' not found.", "Export Error", "48")
            return false
        }
        
        data := CaptureData[captureName]
        
        ; Build the export object
        exportObj := Map()
        exportObj["ccpVersion"] := this.FormatVersion
        exportObj["exportDate"] := FormatTime(, "yyyy-MM-ddTHH:mm:ss")
        exportObj["captureCount"] := 1
        exportObj["includesImages"] := includeImage
        exportObj["includesResearch"] := true
        
        ; Build capture with all data
        capture := this.BuildCaptureExport(captureName, data, includeImage)
        exportObj["captures"] := [capture]
        
        ; Convert to JSON
        jsonStr := this.MapToJSON(exportObj)
        
        ; Copy to clipboard
        A_Clipboard := jsonStr
        
        ; Build status message
        extras := []
        if capture["hasImage"]
            extras.Push("📷 image")
        if capture["research"] != ""
            extras.Push("🔬 research")
        if capture["transcript"] != ""
            extras.Push("📝 transcript")
        if capture["summary"] != ""
            extras.Push("📋 summary")
        
        extraMsg := extras.Length > 0 ? " (" this.JoinArray(extras, ", ") ")" : ""
        
        TrayTip("Capture exported to clipboard!" extraMsg, captureName, "1")
        return true
    }
    
    ; ===========================================================================
    ; EXPORT: Multiple Captures to Clipboard
    ; ===========================================================================
    static ExportMultipleToClipboard(captureNames, includeImages := true) {
        global CaptureData
        
        if captureNames.Length = 0 {
            MsgBox("No captures selected.", "Export Error", "48")
            return false
        }
        
        ; Build the export object
        exportObj := Map()
        exportObj["ccpVersion"] := this.FormatVersion
        exportObj["exportDate"] := FormatTime(, "yyyy-MM-ddTHH:mm:ss")
        exportObj["captureCount"] := captureNames.Length
        exportObj["includesImages"] := includeImages
        exportObj["includesResearch"] := true
        
        captures := []
        imageCount := 0
        researchCount := 0
        
        for name in captureNames {
            if !CaptureData.Has(name)
                continue
                
            data := CaptureData[name]
            capture := this.BuildCaptureExport(name, data, includeImages)
            captures.Push(capture)
            
            if capture["hasImage"]
                imageCount++
            if capture["research"] != "" || capture["transcript"] != "" || capture["summary"] != ""
                researchCount++
        }
        
        exportObj["captures"] := captures
        
        ; Convert to JSON
        jsonStr := this.MapToJSON(exportObj)
        
        ; Copy to clipboard
        A_Clipboard := jsonStr
        
        ; Build status message
        extras := []
        if imageCount > 0
            extras.Push(imageCount " images")
        if researchCount > 0
            extras.Push(researchCount " with research")
        
        extraMsg := extras.Length > 0 ? " (" this.JoinArray(extras, ", ") ")" : ""
        
        TrayTip(captures.Length " captures exported!" extraMsg, "ContentCapture Pro", "1")
        return true
    }
    
    ; ===========================================================================
    ; EXPORT: Save to .ccp File
    ; ===========================================================================
    static ExportToFile(captureNames, filePath := "", includeImages := true) {
        global CaptureData
        
        if captureNames.Length = 0 {
            MsgBox("No captures selected.", "Export Error", "48")
            return false
        }
        
        ; If no filepath, prompt user
        if filePath = "" {
            defaultName := captureNames.Length = 1 ? captureNames[1] : "captures_" FormatTime(, "yyyyMMdd")
            filePath := FileSelect("S16", defaultName ".ccp", "Save Captures", "ContentCapture Pro Files (*.ccp)")
            if filePath = ""
                return false
            
            ; Ensure .ccp extension
            if !InStr(filePath, ".ccp")
                filePath .= ".ccp"
        }
        
        ; Build export object
        exportObj := Map()
        exportObj["ccpVersion"] := this.FormatVersion
        exportObj["exportDate"] := FormatTime(, "yyyy-MM-ddTHH:mm:ss")
        exportObj["captureCount"] := captureNames.Length
        exportObj["includesImages"] := includeImages
        exportObj["includesResearch"] := true
        
        captures := []
        imageCount := 0
        
        for name in captureNames {
            if !CaptureData.Has(name)
                continue
                
            data := CaptureData[name]
            capture := this.BuildCaptureExport(name, data, includeImages)
            captures.Push(capture)
            
            if capture["hasImage"]
                imageCount++
        }
        
        exportObj["captures"] := captures
        
        ; Convert to JSON and save
        jsonStr := this.MapToJSON(exportObj)
        
        try {
            FileDelete(filePath)
        }
        try {
            FileAppend(jsonStr, filePath, "UTF-8")
            
            extras := imageCount > 0 ? " (includes " imageCount " images)" : ""
            TrayTip(captures.Length " captures saved!" extras, filePath, "1")
            return true
        } catch as err {
            MsgBox("Failed to save file: " err.Message, "Export Error", "48")
            return false
        }
    }
    
    ; ===========================================================================
    ; IMAGE UTILITIES: Convert Image to Base64
    ; ===========================================================================
    static ImageToBase64(imagePath) {
        if !FileExist(imagePath)
            return ""
        
        try {
            ; Read file as binary
            file := FileOpen(imagePath, "r")
            if !file
                return ""
            
            size := file.Length
            buffer := Buffer(size)
            file.RawRead(buffer, size)
            file.Close()
            
            ; Convert to Base64 using CryptBinaryToString
            static CRYPT_STRING_BASE64 := 0x00000001
            static CRYPT_STRING_NOCRLF := 0x40000000
            
            ; Get required size
            requiredSize := 0
            DllCall("Crypt32.dll\CryptBinaryToStringW", 
                "Ptr", buffer.Ptr, 
                "UInt", size, 
                "UInt", CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF, 
                "Ptr", 0, 
                "UInt*", &requiredSize)
            
            ; Allocate output buffer
            outBuffer := Buffer(requiredSize * 2)
            
            ; Convert
            DllCall("Crypt32.dll\CryptBinaryToStringW", 
                "Ptr", buffer.Ptr, 
                "UInt", size, 
                "UInt", CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF, 
                "Ptr", outBuffer.Ptr, 
                "UInt*", &requiredSize)
            
            return StrGet(outBuffer, "UTF-16")
        } catch as err {
            return ""
        }
    }
    
    ; ===========================================================================
    ; IMAGE UTILITIES: Convert Base64 to Image File
    ; ===========================================================================
    static Base64ToImage(base64Data, outputPath) {
        if base64Data = ""
            return false
        
        try {
            static CRYPT_STRING_BASE64 := 0x00000001
            
            ; Get required size
            requiredSize := 0
            DllCall("Crypt32.dll\CryptStringToBinaryW",
                "Str", base64Data,
                "UInt", 0,
                "UInt", CRYPT_STRING_BASE64,
                "Ptr", 0,
                "UInt*", &requiredSize,
                "Ptr", 0,
                "Ptr", 0)
            
            ; Allocate buffer
            buffer := Buffer(requiredSize)
            
            ; Convert
            DllCall("Crypt32.dll\CryptStringToBinaryW",
                "Str", base64Data,
                "UInt", 0,
                "UInt", CRYPT_STRING_BASE64,
                "Ptr", buffer.Ptr,
                "UInt*", &requiredSize,
                "Ptr", 0,
                "Ptr", 0)
            
            ; Write to file
            file := FileOpen(outputPath, "w")
            if !file
                return false
            
            file.RawWrite(buffer, requiredSize)
            file.Close()
            
            return true
        } catch as err {
            return false
        }
    }
    
    ; ===========================================================================
    ; IMAGE UTILITIES: Helper Functions
    ; ===========================================================================
    static GetFileName(path) {
        SplitPath(path, &name)
        return name
    }
    
    static GetImageType(path) {
        SplitPath(path, , , &ext)
        ext := StrLower(ext)
        switch ext {
            case "jpg", "jpeg": return "image/jpeg"
            case "png": return "image/png"
            case "gif": return "image/gif"
            case "bmp": return "image/bmp"
            case "webp": return "image/webp"
            default: return "image/jpeg"
        }
    }
    
    static JoinArray(arr, sep := ", ") {
        result := ""
        for i, item in arr {
            if i > 1
                result .= sep
            result .= item
        }
        return result
    }
    
    ; ===========================================================================
    ; IMPORT: Show Import Dialog
    ; ===========================================================================
    static ShowImportDialog() {
        importGui := Gui("+AlwaysOnTop", "Import Captures - ContentCapture Pro")
        importGui.SetFont("s10", "Segoe UI")
        importGui.BackColor := "1a1a2e"
        
        importGui.SetFont("s12 bold cWhite")
        importGui.Add("Text", "x20 y15 w460", "📥 Import Captures")
        
        importGui.SetFont("s10 norm c888888")
        importGui.Add("Text", "x20 y45 w460", "Paste JSON from clipboard or load a .ccp file")
        
        importGui.SetFont("s10 norm cWhite")
        importGui.Add("Text", "x20 y80", "JSON Data:")
        
        ; JSON input area
        jsonEdit := importGui.Add("Edit", "x20 y105 w460 h200 Background2a2a4e cWhite vJsonInput", "")
        
        ; Buttons
        importGui.SetFont("s10")
        importGui.Add("Button", "x20 y320 w100", "📋 Paste").OnEvent("Click", (*) => this.PasteFromClipboard(jsonEdit))
        importGui.Add("Button", "x130 y320 w100", "📂 Load File").OnEvent("Click", (*) => this.LoadFromFile(jsonEdit))
        importGui.Add("Button", "x250 y320 w110", "✅ Preview").OnEvent("Click", (*) => this.PreviewImport(importGui, jsonEdit))
        importGui.Add("Button", "x380 y320 w100", "Cancel").OnEvent("Click", (*) => importGui.Destroy())
        
        importGui.Show("w500 h370")
    }
    
    ; ===========================================================================
    ; IMPORT: Paste from Clipboard
    ; ===========================================================================
    static PasteFromClipboard(jsonEdit) {
        clipText := A_Clipboard
        if clipText = "" {
            MsgBox("Clipboard is empty.", "Paste Error", "48")
            return
        }
        jsonEdit.Value := clipText
    }
    
    ; ===========================================================================
    ; IMPORT: Load from File
    ; ===========================================================================
    static LoadFromFile(jsonEdit) {
        filePath := FileSelect("1", , "Select Capture File", "ContentCapture Pro Files (*.ccp; *.json)")
        if filePath = ""
            return
            
        try {
            content := FileRead(filePath, "UTF-8")
            jsonEdit.Value := content
        } catch as err {
            MsgBox("Failed to read file: " err.Message, "Load Error", "48")
        }
    }
    
    ; ===========================================================================
    ; IMPORT: Preview Import (Parse and Show Confirmation)
    ; ===========================================================================
    static PreviewImport(importGui, jsonEdit) {
        global CaptureData, CaptureNames
        
        jsonStr := jsonEdit.Value
        if jsonStr = "" {
            MsgBox("No JSON data to import.", "Preview Error", "48")
            return
        }
        
        ; Parse JSON
        try {
            importData := this.JSONToMap(jsonStr)
        } catch as err {
            MsgBox("Invalid JSON format: " err.Message, "Parse Error", "48")
            return
        }
        
        ; Validate format
        if !importData.Has("ccpVersion") || !importData.Has("captures") {
            MsgBox("Invalid ContentCapture Pro format.`n`nMissing required fields.", "Format Error", "48")
            return
        }
        
        captures := importData["captures"]
        if captures.Length = 0 {
            MsgBox("No captures found in import data.", "Import Error", "48")
            return
        }
        
        ; Check for conflicts
        conflicts := []
        ready := []
        
        for capture in captures {
            name := capture.Has("name") ? capture["name"] : ""
            if name = ""
                continue
                
            if CaptureData.Has(name) {
                conflicts.Push(capture)
            } else {
                ready.Push(capture)
            }
        }
        
        ; Show preview dialog
        this.ShowPreviewDialog(importGui, ready, conflicts, importData)
    }
    
    ; ===========================================================================
    ; IMPORT: Show Preview/Confirmation Dialog
    ; ===========================================================================
    static ShowPreviewDialog(parentGui, ready, conflicts, importData) {
        previewGui := Gui("+AlwaysOnTop +Owner" parentGui.Hwnd, "Import Preview")
        previewGui.SetFont("s10", "Segoe UI")
        previewGui.BackColor := "1a1a2e"
        
        ; Header
        previewGui.SetFont("s12 bold cWhite")
        previewGui.Add("Text", "x20 y15 w660", "📋 Import Preview")
        
        previewGui.SetFont("s10 norm c888888")
        exportDate := importData.Has("exportDate") ? importData["exportDate"] : "Unknown"
        previewGui.Add("Text", "x20 y45 w660", "Exported: " exportDate)
        
        ; Summary with extras info
        previewGui.SetFont("s10 norm cWhite")
        totalCount := ready.Length + conflicts.Length
        
        ; Count extras
        imageCount := 0
        researchCount := 0
        transcriptCount := 0
        
        allCaptures := []
        for cap in ready
            allCaptures.Push(cap)
        for cap in conflicts
            allCaptures.Push(cap)
        
        for cap in allCaptures {
            if cap.Has("hasImage") && cap["hasImage"]
                imageCount++
            if cap.Has("research") && cap["research"] != ""
                researchCount++
            if cap.Has("transcript") && cap["transcript"] != ""
                transcriptCount++
        }
        
        summaryText := "Total: " totalCount " | Ready: " ready.Length " | Conflicts: " conflicts.Length
        if imageCount > 0
            summaryText .= " | 📷 " imageCount " images"
        if researchCount > 0
            summaryText .= " | 🔬 " researchCount " research"
        if transcriptCount > 0
            summaryText .= " | 📝 " transcriptCount " transcripts"
        
        previewGui.Add("Text", "x20 y75 w660", summaryText)
        
        ; ListView for captures - wider to show extras
        previewGui.SetFont("s9")
        cols := "Status|Name|Title|📷|🔬|📝|Conflict?"
        lv := previewGui.Add("ListView", "x20 y105 w660 h200 Background2a2a4e cWhite Grid -Multi", StrSplit(cols, "|"))
        lv.ModifyCol(1, 70)   ; Status
        lv.ModifyCol(2, 120)  ; Name
        lv.ModifyCol(3, 280)  ; Title
        lv.ModifyCol(4, 30)   ; Image icon
        lv.ModifyCol(5, 30)   ; Research icon
        lv.ModifyCol(6, 30)   ; Transcript icon
        lv.ModifyCol(7, 80)   ; Conflict
        
        ; Add ready captures
        for capture in ready {
            name := capture["name"]
            title := capture.Has("title") ? SubStr(capture["title"], 1, 45) : ""
            hasImg := capture.Has("hasImage") && capture["hasImage"] ? "✓" : ""
            hasRes := capture.Has("research") && capture["research"] != "" ? "✓" : ""
            hasTrs := capture.Has("transcript") && capture["transcript"] != "" ? "✓" : ""
            lv.Add("", "✅ Ready", name, title, hasImg, hasRes, hasTrs, "No")
        }
        
        ; Add conflicts
        for capture in conflicts {
            name := capture["name"]
            title := capture.Has("title") ? SubStr(capture["title"], 1, 45) : ""
            hasImg := capture.Has("hasImage") && capture["hasImage"] ? "✓" : ""
            hasRes := capture.Has("research") && capture["research"] != "" ? "✓" : ""
            hasTrs := capture.Has("transcript") && capture["transcript"] != "" ? "✓" : ""
            lv.Add("", "⚠️ Conflict", name, title, hasImg, hasRes, hasTrs, "Yes - Exists")
        }
        
        ; Legend
        previewGui.SetFont("s8 c888888")
        previewGui.Add("Text", "x20 y310 w400", "📷 = Has image | 🔬 = Has research notes | 📝 = Has transcript/summary")
        
        ; Conflict handling options
        if conflicts.Length > 0 {
            previewGui.SetFont("s10 cFFAA00")
            previewGui.Add("Text", "x20 y335 w660", "⚠️ " conflicts.Length " capture(s) already exist. Choose how to handle:")
            
            previewGui.SetFont("s9 cWhite")
            previewGui.Add("Radio", "x20 y360 w150 vConflictAction Checked", "Skip conflicts")
            previewGui.Add("Radio", "x180 y360 w150", "Replace existing")
            previewGui.Add("Radio", "x340 y360 w200", "Rename (add _imported)")
        }
        
        ; Buttons
        previewGui.SetFont("s10")
        yPos := conflicts.Length > 0 ? 400 : 340
        
        previewGui.Add("Button", "x20 y" yPos " w150", "✅ Import All").OnEvent("Click", (*) => this.ExecuteImport(previewGui, parentGui, ready, conflicts))
        previewGui.Add("Button", "x180 y" yPos " w150", "Import Ready Only").OnEvent("Click", (*) => this.ExecuteImport(previewGui, parentGui, ready, []))
        previewGui.Add("Button", "x550 y" yPos " w130", "Cancel").OnEvent("Click", (*) => previewGui.Destroy())
        
        ; Store data for import
        previewGui.ready := ready
        previewGui.conflicts := conflicts
        
        height := conflicts.Length > 0 ? 450 : 390
        previewGui.Show("w700 h" height)
    }
    
    ; ===========================================================================
    ; IMPORT: Execute the Import
    ; ===========================================================================
    static ExecuteImport(previewGui, parentGui, ready, conflicts) {
        global CaptureData, CaptureNames
        
        imported := 0
        skipped := 0
        replaced := 0
        renamed := 0
        imagesRestored := 0
        
        ; Get conflict handling preference
        conflictAction := 1  ; Default: skip
        try {
            submitted := previewGui.Submit(false)
            conflictAction := submitted.ConflictAction
        }
        
        ; Import ready captures (no conflicts)
        for capture in ready {
            if this.AddCaptureFromImport(capture) {
                imported++
                if capture.Has("hasImage") && capture["hasImage"]
                    imagesRestored++
            }
        }
        
        ; Handle conflicts based on user choice
        for capture in conflicts {
            name := capture["name"]
            
            switch conflictAction {
                case 1:  ; Skip
                    skipped++
                    
                case 2:  ; Replace
                    ; Delete existing first
                    if CaptureData.Has(name) {
                        CaptureData.Delete(name)
                        ; Remove from CaptureNames
                        newNames := []
                        for n in CaptureNames {
                            if n != name
                                newNames.Push(n)
                        }
                        CaptureNames := newNames
                    }
                    if this.AddCaptureFromImport(capture) {
                        replaced++
                        if capture.Has("hasImage") && capture["hasImage"]
                            imagesRestored++
                    }
                    
                case 3:  ; Rename
                    ; Find unique name
                    newName := name "_imported"
                    counter := 1
                    while CaptureData.Has(newName) {
                        counter++
                        newName := name "_imported" counter
                    }
                    capture["name"] := newName
                    if this.AddCaptureFromImport(capture) {
                        renamed++
                        if capture.Has("hasImage") && capture["hasImage"]
                            imagesRestored++
                    }
            }
        }
        
        ; Save and regenerate
        CC_SaveCaptureData()
        CC_GenerateHotstringFile()
        
        ; Show results
        resultMsg := "Import Complete!`n`n"
        resultMsg .= "✅ Imported: " imported "`n"
        if replaced > 0
            resultMsg .= "🔄 Replaced: " replaced "`n"
        if renamed > 0
            resultMsg .= "📝 Renamed: " renamed "`n"
        if skipped > 0
            resultMsg .= "⏭️ Skipped: " skipped "`n"
        if imagesRestored > 0
            resultMsg .= "📷 Images restored: " imagesRestored "`n"
        
        MsgBox(resultMsg, "Import Results", "64")
        
        ; Close dialogs
        previewGui.Destroy()
        parentGui.Destroy()
        
        ; Refresh browser if open
        try {
            CC_OpenCaptureBrowser()
        }
    }
    
    ; ===========================================================================
    ; IMPORT: Add Single Capture from Import Data
    ; ===========================================================================
    static AddCaptureFromImport(capture) {
        global CaptureData, CaptureNames
        
        name := capture.Has("name") ? capture["name"] : ""
        if name = ""
            return false
        
        ; Create capture data
        data := Map()
        
        ; Core fields
        data["url"] := capture.Has("url") ? capture["url"] : ""
        data["title"] := capture.Has("title") ? capture["title"] : ""
        data["body"] := capture.Has("body") ? capture["body"] : ""
        data["tags"] := capture.Has("tags") ? capture["tags"] : ""
        data["opinion"] := capture.Has("opinion") ? capture["opinion"] : ""
        data["favorite"] := capture.Has("favorite") ? capture["favorite"] : false
        
        ; Research fields
        data["research"] := capture.Has("research") ? capture["research"] : ""
        data["transcript"] := capture.Has("transcript") ? capture["transcript"] : ""
        data["summary"] := capture.Has("summary") ? capture["summary"] : ""
        
        ; Set date (use import date or current)
        if capture.Has("date") && capture["date"] != "" {
            data["date"] := capture["date"]
        } else {
            data["date"] := FormatTime(, "yyyy-MM-dd")
        }
        
        ; Handle image restoration
        if capture.Has("hasImage") && capture["hasImage"] && capture.Has("imageData") && capture["imageData"] != "" {
            ; Determine filename
            imageName := capture.Has("imageName") && capture["imageName"] != "" 
                ? capture["imageName"] 
                : name ".jpg"
            
            ; Ensure images folder exists
            imageFolder := this.ImageFolder
            if !DirExist(imageFolder)
                DirCreate(imageFolder)
            
            ; Generate unique filename if needed
            imagePath := imageFolder "\" imageName
            counter := 1
            while FileExist(imagePath) {
                SplitPath(imageName, , , &ext, &nameNoExt)
                imagePath := imageFolder "\" nameNoExt "_" counter "." ext
                counter++
            }
            
            ; Restore image from Base64
            if this.Base64ToImage(capture["imageData"], imagePath) {
                ; Store relative path
                data["image"] := this.GetFileName(imagePath)
            }
        }
        
        ; Add to data structures
        CaptureData[name] := data
        CaptureNames.Push(name)
        
        return true
    }
    
    ; ===========================================================================
    ; JSON UTILITIES: Map to JSON String
    ; ===========================================================================
    static MapToJSON(obj, indent := 0) {
        if Type(obj) = "Array" {
            if obj.Length = 0
                return "[]"
            
            result := "[`n"
            for i, item in obj {
                result .= this.Indent(indent + 1) . this.MapToJSON(item, indent + 1)
                if i < obj.Length
                    result .= ","
                result .= "`n"
            }
            result .= this.Indent(indent) . "]"
            return result
        }
        
        if Type(obj) = "Map" {
            if obj.Count = 0
                return "{}"
            
            result := "{`n"
            count := 0
            for key, value in obj {
                count++
                result .= this.Indent(indent + 1) . '"' . this.EscapeJSON(key) . '": '
                result .= this.MapToJSON(value, indent + 1)
                if count < obj.Count
                    result .= ","
                result .= "`n"
            }
            result .= this.Indent(indent) . "}"
            return result
        }
        
        if Type(obj) = "String"
            return '"' . this.EscapeJSON(obj) . '"'
        
        if Type(obj) = "Integer" || Type(obj) = "Float"
            return String(obj)
        
        if obj = true
            return "true"
        if obj = false
            return "false"
        
        return "null"
    }
    
    static EscapeJSON(str) {
        str := StrReplace(str, "\", "\\")
        str := StrReplace(str, '"', '\"')
        str := StrReplace(str, "`n", "\n")
        str := StrReplace(str, "`r", "\r")
        str := StrReplace(str, "`t", "\t")
        return str
    }
    
    static Indent(level) {
        result := ""
        Loop level
            result .= "  "
        return result
    }
    
    ; ===========================================================================
    ; JSON UTILITIES: JSON String to Map
    ; ===========================================================================
    static JSONToMap(jsonStr) {
        ; Simple JSON parser for CCP format
        jsonStr := Trim(jsonStr)
        
        if SubStr(jsonStr, 1, 1) = "{"
            return this.ParseObject(jsonStr, &pos := 1)
        else if SubStr(jsonStr, 1, 1) = "["
            return this.ParseArray(jsonStr, &pos := 1)
        else
            throw Error("Invalid JSON: must start with { or [")
    }
    
    static ParseObject(str, &pos) {
        result := Map()
        pos++  ; Skip {
        this.SkipWhitespace(str, &pos)
        
        if SubStr(str, pos, 1) = "}" {
            pos++
            return result
        }
        
        loop {
            this.SkipWhitespace(str, &pos)
            
            ; Parse key
            if SubStr(str, pos, 1) != '"'
                throw Error("Expected string key at position " pos)
            key := this.ParseString(str, &pos)
            
            this.SkipWhitespace(str, &pos)
            
            ; Expect colon
            if SubStr(str, pos, 1) != ":"
                throw Error("Expected : at position " pos)
            pos++
            
            this.SkipWhitespace(str, &pos)
            
            ; Parse value
            value := this.ParseValue(str, &pos)
            result[key] := value
            
            this.SkipWhitespace(str, &pos)
            
            char := SubStr(str, pos, 1)
            if char = "}" {
                pos++
                return result
            } else if char = "," {
                pos++
            } else {
                throw Error("Expected , or } at position " pos)
            }
        }
    }
    
    static ParseArray(str, &pos) {
        result := []
        pos++  ; Skip [
        this.SkipWhitespace(str, &pos)
        
        if SubStr(str, pos, 1) = "]" {
            pos++
            return result
        }
        
        loop {
            this.SkipWhitespace(str, &pos)
            value := this.ParseValue(str, &pos)
            result.Push(value)
            
            this.SkipWhitespace(str, &pos)
            
            char := SubStr(str, pos, 1)
            if char = "]" {
                pos++
                return result
            } else if char = "," {
                pos++
            } else {
                throw Error("Expected , or ] at position " pos)
            }
        }
    }
    
    static ParseValue(str, &pos) {
        this.SkipWhitespace(str, &pos)
        char := SubStr(str, pos, 1)
        
        if char = '"'
            return this.ParseString(str, &pos)
        if char = "{"
            return this.ParseObject(str, &pos)
        if char = "["
            return this.ParseArray(str, &pos)
        if char = "t" && SubStr(str, pos, 4) = "true" {
            pos += 4
            return true
        }
        if char = "f" && SubStr(str, pos, 5) = "false" {
            pos += 5
            return false
        }
        if char = "n" && SubStr(str, pos, 4) = "null" {
            pos += 4
            return ""
        }
        if RegExMatch(SubStr(str, pos), "^-?\d+\.?\d*", &match) {
            pos += StrLen(match[0])
            return Number(match[0])
        }
        
        throw Error("Unexpected character at position " pos ": " char)
    }
    
    static ParseString(str, &pos) {
        pos++  ; Skip opening quote
        result := ""
        
        loop {
            char := SubStr(str, pos, 1)
            if char = "" {
                throw Error("Unterminated string")
            }
            if char = '"' {
                pos++
                return result
            }
            if char = "\" {
                pos++
                escaped := SubStr(str, pos, 1)
                switch escaped {
                    case "n": result .= "`n"
                    case "r": result .= "`r"
                    case "t": result .= "`t"
                    case '"': result .= '"'
                    case "\": result .= "\"
                    default: result .= escaped
                }
                pos++
            } else {
                result .= char
                pos++
            }
        }
    }
    
    static SkipWhitespace(str, &pos) {
        while pos <= StrLen(str) {
            char := SubStr(str, pos, 1)
            if char != " " && char != "`t" && char != "`n" && char != "`r"
                break
            pos++
        }
    }
}

; ==============================================================================
; BROWSER INTEGRATION FUNCTIONS
; ==============================================================================

; Call this from the Share button in CC_OpenCaptureBrowser
CC_BrowserShareCapture(listView, browserGui) {
    ; Get selected captures
    selectedNames := []
    row := 0
    loop {
        row := listView.GetNext(row)
        if row = 0
            break
        ; Assuming Name is column 3 (after Fav and Image columns)
        name := listView.GetText(row, 3)
        if name != ""
            selectedNames.Push(name)
    }
    
    if selectedNames.Length = 0 {
        MsgBox("Select one or more captures to share.", "No Selection", "48")
        return
    }
    
    ; Check if any have images
    global CaptureData
    hasImages := false
    hasResearch := false
    for name in selectedNames {
        if CaptureData.Has(name) {
            data := CaptureData[name]
            if data.Has("image") && data["image"] != ""
                hasImages := true
            if (data.Has("research") && data["research"] != "") 
                || (data.Has("transcript") && data["transcript"] != "")
                || (data.Has("summary") && data["summary"] != "")
                hasResearch := true
        }
    }
    
    ; Show share options menu
    shareMenu := Menu()
    
    if selectedNames.Length = 1 {
        shareMenu.Add("📋 Copy to Clipboard (Full)", (*) => CC_ShareModule.ExportToClipboard(selectedNames[1], true))
        if hasImages
            shareMenu.Add("📋 Copy to Clipboard (No Images)", (*) => CC_ShareModule.ExportToClipboard(selectedNames[1], false))
        shareMenu.Add()  ; Separator
        shareMenu.Add("💾 Save to .ccp File (Full)", (*) => CC_ShareModule.ExportToFile(selectedNames, "", true))
        if hasImages
            shareMenu.Add("💾 Save to .ccp File (No Images)", (*) => CC_ShareModule.ExportToFile(selectedNames, "", false))
    } else {
        shareMenu.Add("📋 Copy " selectedNames.Length " Captures (Full)", (*) => CC_ShareModule.ExportMultipleToClipboard(selectedNames, true))
        if hasImages
            shareMenu.Add("📋 Copy " selectedNames.Length " Captures (No Images)", (*) => CC_ShareModule.ExportMultipleToClipboard(selectedNames, false))
        shareMenu.Add()  ; Separator
        shareMenu.Add("💾 Save " selectedNames.Length " to File (Full)", (*) => CC_ShareModule.ExportToFile(selectedNames, "", true))
        if hasImages
            shareMenu.Add("💾 Save " selectedNames.Length " to File (No Images)", (*) => CC_ShareModule.ExportToFile(selectedNames, "", false))
    }
    
    ; Add info about what's included
    shareMenu.Add()  ; Separator
    infoText := "ℹ️ Includes: content"
    if hasResearch
        infoText .= ", research"
    if hasImages
        infoText .= ", images"
    shareMenu.Add(infoText, (*) => {})
    shareMenu.Disable(infoText)
    
    shareMenu.Show()
}

; Call this from the Import button in CC_OpenCaptureBrowser
CC_BrowserImportCapture(*) {
    CC_ShareModule.ShowImportDialog()
}
