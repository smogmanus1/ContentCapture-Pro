; ==============================================================================
; CC_ContentFiles.ahk - External Content File Storage
; ==============================================================================
; Author:      Brad (with Claude AI)
; Version:     1.0.0
; Description: Stores large body and transcript content as separate text files
;              instead of inline in captures.dat. This keeps the data file lean
;              and fast, prevents GUI control crashes, and speeds up hotstrings.
;
; Architecture:
;   captures.dat  = lightweight index (metadata + short fields only)
;   content/      = folder with body_*.txt and transcript_*.txt files
;
;   When body > threshold chars → saved to content/body_capturename.txt
;   When transcript exists     → saved to content/transcript_capturename.txt
;   captures.dat stores "body=FILE:body_capturename.txt" as pointer
;
; Key Functions:
;   CF_SaveContent(name, field, text)   - Save content to file if large
;   CF_LoadContent(name, field)         - Load content from file
;   CF_DeleteContent(name)              - Remove content files for a capture
;   CF_RenameContent(oldName, newName)  - Rename content files when capture renamed
;   CF_MigrateInline(cap, name)         - Move inline content to files
;   CF_GetContentDir()                  - Get/create content directory
;   CF_IsFilePointer(value)             - Check if value is a FILE: pointer
;   CF_GetPreview(text, maxChars)       - Get preview of long content
;
; ==============================================================================

; Threshold: content longer than this goes to a file (5000 chars)
global CF_THRESHOLD := 5000

; ==============================================================================
; DIRECTORY MANAGEMENT
; ==============================================================================

; Get the content directory path, creating it if needed
CF_GetContentDir() {
    global BaseDir
    contentDir := BaseDir "\content"
    if !DirExist(contentDir) {
        try DirCreate(contentDir)
    }
    return contentDir
}

; Get the filename for a specific content field
CF_GetFilePath(name, field) {
    return CF_GetContentDir() "\" field "_" StrLower(name) ".txt"
}

; ==============================================================================
; FILE POINTER DETECTION
; ==============================================================================

; Check if a value stored in captures.dat is a file pointer
CF_IsFilePointer(value) {
    return (SubStr(value, 1, 5) = "FILE:")
}

; Extract the filename from a FILE: pointer
CF_GetPointerFilename(value) {
    return SubStr(value, 6)  ; Skip "FILE:"
}

; ==============================================================================
; SAVE CONTENT
; ==============================================================================

; Save content - returns the value to store in captures.dat
; If content is large, writes to file and returns "FILE:filename"
; If content is small, returns the content itself (stays inline)
CF_SaveContent(name, field, text) {
    if (text = "")
        return ""
    
    nameLower := StrLower(name)
    
    ; Transcript ALWAYS goes to file (any size), body only if over threshold
    if (field = "transcript" || StrLen(text) > CF_THRESHOLD) {
        filePath := CF_GetFilePath(nameLower, field)
        try {
            if FileExist(filePath)
                FileDelete(filePath)
            FileAppend(text, filePath, "UTF-8")
            return "FILE:" field "_" nameLower ".txt"
        } catch as err {
            ; If file save fails, fall back to inline (better than losing data)
            return text
        }
    }
    
    ; Small content stays inline
    return text
}

; ==============================================================================
; LOAD CONTENT
; ==============================================================================

; Load content - handles both inline values and file pointers transparently
; This is the main function other code should call to get content
CF_LoadContent(name, field, capValue := "") {
    ; If no value provided, try to get it from CaptureData
    if (capValue = "") {
        global CaptureData
        nameLower := StrLower(name)
        if !CaptureData.Has(nameLower)
            return ""
        cap := CaptureData[nameLower]
        if !cap.Has(field)
            return ""
        capValue := cap[field]
    }
    
    if (capValue = "")
        return ""
    
    ; Check if it's a file pointer
    if CF_IsFilePointer(capValue) {
        fileName := CF_GetPointerFilename(capValue)
        filePath := CF_GetContentDir() "\" fileName
        if FileExist(filePath) {
            try {
                return FileRead(filePath, "UTF-8")
            } catch {
                return ""  ; File exists but can't be read
            }
        }
        return ""  ; File doesn't exist (may have been deleted)
    }
    
    ; Not a file pointer - return inline value as-is
    return capValue
}

; ==============================================================================
; DELETE CONTENT FILES
; ==============================================================================

; Remove all content files for a capture (used when deleting a capture)
CF_DeleteContent(name) {
    nameLower := StrLower(name)
    for field in ["body", "transcript"] {
        filePath := CF_GetFilePath(nameLower, field)
        if FileExist(filePath) {
            try FileDelete(filePath)
        }
    }
}

; ==============================================================================
; RENAME CONTENT FILES
; ==============================================================================

; Rename content files when a capture is renamed
CF_RenameContent(oldName, newName) {
    oldLower := StrLower(oldName)
    newLower := StrLower(newName)
    
    if (oldLower = newLower)
        return  ; Same name, nothing to do
    
    for field in ["body", "transcript"] {
        oldPath := CF_GetFilePath(oldLower, field)
        newPath := CF_GetFilePath(newLower, field)
        if FileExist(oldPath) {
            try {
                if FileExist(newPath)
                    FileDelete(newPath)
                FileMove(oldPath, newPath)
            }
        }
    }
}

; ==============================================================================
; MIGRATION - Move inline content to files
; ==============================================================================

; Migrate a single capture's large inline content to files
; Returns true if any content was migrated
CF_MigrateCapture(cap, name) {
    migrated := false
    nameLower := StrLower(name)
    
    ; Migrate transcript (always externalize)
    if (cap.Has("transcript") && cap["transcript"] != "" && !CF_IsFilePointer(cap["transcript"])) {
        pointer := CF_SaveContent(nameLower, "transcript", cap["transcript"])
        if CF_IsFilePointer(pointer) {
            cap["transcript"] := pointer
            migrated := true
        }
    }
    
    ; Migrate body (only if over threshold)
    if (cap.Has("body") && cap["body"] != "" && !CF_IsFilePointer(cap["body"]) && StrLen(cap["body"]) > CF_THRESHOLD) {
        pointer := CF_SaveContent(nameLower, "body", cap["body"])
        if CF_IsFilePointer(pointer) {
            cap["body"] := pointer
            migrated := true
        }
    }
    
    return migrated
}

; Migrate ALL captures - run once to externalize existing inline content
; Returns count of captures migrated
CF_MigrateAll() {
    global CaptureData, CaptureNames
    
    migratedCount := 0
    CF_GetContentDir()  ; Ensure directory exists
    
    for name in CaptureNames {
        nameLower := StrLower(name)
        if !CaptureData.Has(nameLower)
            continue
        
        cap := CaptureData[nameLower]
        if CF_MigrateCapture(cap, name)
            migratedCount++
    }
    
    return migratedCount
}

; ==============================================================================
; PREVIEW - Get truncated preview of content for GUI display
; ==============================================================================

; Get a preview of content (first N chars + indicator)
CF_GetPreview(text, maxChars := 500) {
    if (text = "" || StrLen(text) <= maxChars)
        return text
    
    ; Cut at word boundary
    preview := SubStr(text, 1, maxChars)
    lastSpace := InStr(preview, " ",, -1)  ; Find last space from end
    if (lastSpace > maxChars * 0.8)  ; Only trim if we don't lose too much
        preview := SubStr(preview, 1, lastSpace)
    
    remaining := StrLen(text) - StrLen(preview)
    return preview "`n`n... [" remaining " more chars in file]"
}

; ==============================================================================
; CONTENT STATS
; ==============================================================================

; Get stats about externalized content
CF_GetStats() {
    contentDir := CF_GetContentDir()
    fileCount := 0
    totalSize := 0
    
    if DirExist(contentDir) {
        Loop Files contentDir "\*.txt" {
            fileCount++
            totalSize += A_LoopFileSize
        }
    }
    
    return {files: fileCount, totalSize: totalSize, dir: contentDir}
}
