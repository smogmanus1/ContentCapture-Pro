; ==============================================================================
; CC_Patches_Jan2026.ahk - Fixes for YouTube Shorts detection and Edit Memory
; ==============================================================================
; 
; PATCH 1: YouTube Shorts URL Detection
; The Research button now recognizes youtube.com/shorts/ URLs
;
; PATCH 2: Remember Last Edited Capture
; After save/reload, automatically reopens the capture you were editing
;
; ==============================================================================

#Requires AutoHotkey v2.0

; ==============================================================================
; PATCH 1: Updated IsYouTubeURL Function
; ==============================================================================
; Replace your existing IsYouTubeURL function with this one.
; It now recognizes:
;   - youtube.com/watch?v=
;   - youtu.be/
;   - youtube.com/shorts/  <-- NEW!
;   - youtube.com/embed/
;   - youtube.com/v/

/**
 * IsYouTubeURL - Check if URL is any YouTube video format
 * Updated to include YouTube Shorts
 * 
 * @param url - URL to check
 * @return Boolean - true if YouTube video URL
 */
IsYouTubeURL(url) {
    ; Standard watch URL: youtube.com/watch?v=VIDEO_ID
    if RegExMatch(url, "i)youtube\.com/watch\?.*v=")
        return true
    
    ; Short URL: youtu.be/VIDEO_ID
    if RegExMatch(url, "i)youtu\.be/[a-zA-Z0-9_-]+")
        return true
    
    ; YouTube Shorts: youtube.com/shorts/VIDEO_ID
    if RegExMatch(url, "i)youtube\.com/shorts/[a-zA-Z0-9_-]+")
        return true
    
    ; Embed URL: youtube.com/embed/VIDEO_ID
    if RegExMatch(url, "i)youtube\.com/embed/[a-zA-Z0-9_-]+")
        return true
    
    ; Old format: youtube.com/v/VIDEO_ID
    if RegExMatch(url, "i)youtube\.com/v/[a-zA-Z0-9_-]+")
        return true
    
    return false
}

/**
 * GetYouTubeVideoId - Extract video ID from any YouTube URL format
 * Updated to include Shorts
 * 
 * @param url - YouTube URL
 * @return Video ID string or empty string if not found
 */
GetYouTubeVideoId(url) {
    ; youtu.be format
    if (RegExMatch(url, "i)youtu\.be/([a-zA-Z0-9_-]+)", &match))
        return match[1]
    
    ; youtube.com/watch?v= format
    if (RegExMatch(url, "i)youtube\.com/watch\?.*?v=([a-zA-Z0-9_-]+)", &match))
        return match[1]
    
    ; youtube.com/shorts/ format
    if (RegExMatch(url, "i)youtube\.com/shorts/([a-zA-Z0-9_-]+)", &match))
        return match[1]
    
    ; youtube.com/embed/ format
    if (RegExMatch(url, "i)youtube\.com/embed/([a-zA-Z0-9_-]+)", &match))
        return match[1]
    
    ; youtube.com/v/ format
    if (RegExMatch(url, "i)youtube\.com/v/([a-zA-Z0-9_-]+)", &match))
        return match[1]
    
    return ""
}


; ==============================================================================
; PATCH 2: Remember Last Edited Capture After Reload
; ==============================================================================
; 
; HOW IT WORKS:
; 1. When you save a capture, it writes the capture name to a temp file
; 2. When the script reloads, it checks for that temp file
; 3. If found, it opens the edit GUI for that capture
; 4. The temp file is deleted after reading
;
; INTEGRATION STEPS:
; 
; Step A: Add this to your script initialization (near the top after globals):
;   CC_CheckForLastEdited()
;
; Step B: In your save handler (CC_SaveCaptureHandler or similar), 
;         add this line BEFORE the reload:
;   CC_RememberLastEdited(captureName)
;
; ==============================================================================

global CC_LastEditedFile := A_ScriptDir "\last_edited.tmp"

/**
 * CC_RememberLastEdited - Save the capture name before reload
 * Call this in your save handler BEFORE Reload()
 * 
 * @param captureName - The name of the capture being saved
 */
CC_RememberLastEdited(captureName) {
    global CC_LastEditedFile
    
    if (captureName = "")
        return
    
    try {
        if FileExist(CC_LastEditedFile)
            FileDelete(CC_LastEditedFile)
        FileAppend(captureName, CC_LastEditedFile, "UTF-8")
    } catch as err {
        ; Silently fail - not critical
    }
}

/**
 * CC_CheckForLastEdited - Check if we should reopen an edited capture
 * Call this during script startup (after data is loaded)
 */
CC_CheckForLastEdited() {
    global CC_LastEditedFile, CaptureData
    
    if !FileExist(CC_LastEditedFile)
        return
    
    try {
        captureName := FileRead(CC_LastEditedFile, "UTF-8")
        captureName := Trim(captureName)
        FileDelete(CC_LastEditedFile)
        
        if (captureName != "" && CaptureData.Has(captureName)) {
            ; Use SetTimer to open after script fully initializes
            SetTimer(() => CC_OpenEditGUI(captureName), -500)
        }
    } catch as err {
        ; Silently fail
        try FileDelete(CC_LastEditedFile)
    }
}

/**
 * CC_OpenEditGUI - Open the edit GUI for a specific capture
 * This is a wrapper - adjust to match your actual edit function name
 * 
 * @param captureName - The capture to edit
 */
CC_OpenEditGUI(captureName) {
    global CaptureData
    
    if !CaptureData.Has(captureName)
        return
    
    ; Call the edit function
    CC_EditCapture(captureName)
    
    TrayTip("Reopened after save", captureName, "1")
}


; ==============================================================================
; USAGE SUMMARY
; ==============================================================================
;
; 1. Replace your IsYouTubeURL() function with the one above
; 
; 2. For "remember last edited":
;    a. Add to your initialization:
;       CC_CheckForLastEdited()
;    
;    b. In your save handler, before Reload():
;       CC_RememberLastEdited(captureName)
;       Reload()
;
; ==============================================================================
