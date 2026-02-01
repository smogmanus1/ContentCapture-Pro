#Requires AutoHotkey v2.0+

; ==============================================================================
; CC_Clipboard.ahk - Centralized Clipboard Operations for ContentCapture Pro
; ==============================================================================
; Version:     1.0.0
; Author:      Brad (with Claude AI assistance)
; Created:     2026-02-01
;
; PURPOSE:
;   This module provides a SINGLE, CONSISTENT way to handle ALL clipboard
;   operations in ContentCapture Pro. By centralizing clipboard logic here,
;   we eliminate an entire class of bugs related to stale clipboard content.
;
; THE PROBLEM THIS SOLVES:
;   When you set A_Clipboard := content without clearing first, Windows may
;   not fully replace the old content before ClipWait returns. This causes
;   the "stale clipboard" bug where the wrong content gets pasted.
;
; THE SOLUTION:
;   Every clipboard operation now follows this bulletproof sequence:
;   1. Save original clipboard (if needed)
;   2. Clear clipboard completely
;   3. Wait for clear to complete
;   4. Set new content
;   5. Wait for content to be ready
;   6. Perform action (paste, etc.)
;   7. Wait for action to complete
;   8. Restore original clipboard (if needed)
;
; USAGE:
;   CC_ClipPaste(content)      → Paste content, restore original clipboard
;   CC_ClipPasteKeep(content)  → Paste content, keep it on clipboard
;   CC_ClipCopy(content)       → Copy content to clipboard (no paste)
;   CC_ClipGet()               → Get current clipboard text
;   CC_ClipClear()             → Clear clipboard
;
; RULES FOR OTHER FILES:
;   1. NEVER set A_Clipboard directly - always use CC_Clip* functions
;   2. The ONLY exception is restoring a saved clipboard (A_Clipboard := savedClip)
;   3. If you need custom clipboard logic, add it to THIS file
;
; ==============================================================================

; ==============================================================================
; CONFIGURATION - Tune these if clipboard operations are unreliable
; ==============================================================================

global CC_CLIP_CLEAR_DELAY := 50        ; ms to wait after clearing clipboard
global CC_CLIP_WAIT_TIMEOUT := 2        ; seconds to wait for clipboard ready
global CC_CLIP_PASTE_BASE_DELAY := 100  ; base ms to wait after paste
global CC_CLIP_PASTE_MAX_DELAY := 300   ; max additional delay for long content
global CC_CLIP_CONTENT_SCALE := 100     ; add 1ms per this many chars

; ==============================================================================
; PRIMARY CLIPBOARD FUNCTIONS
; ==============================================================================

; ------------------------------------------------------------------------------
; CC_ClipPaste(content, timeout)
; ------------------------------------------------------------------------------
; The PRIMARY paste function. Use this for hotstring paste operations.
; Pastes content and restores the user's original clipboard afterward.
;
; Parameters:
;   content  - Text to paste
;   timeout  - ClipWait timeout in seconds (default: 2)
;
; Returns:
;   true on success, false on failure
;
; Example:
;   CC_ClipPaste("Hello World")           ; Paste and restore clipboard
;   CC_ClipPaste(myContent, 5)            ; Longer timeout for big content
; ------------------------------------------------------------------------------
CC_ClipPaste(content, timeout := 2) {
    if (content = "")
        return false
    
    ; Step 1: Save original clipboard (preserves all formats including images)
    savedClip := ClipboardAll()
    
    ; Steps 2-5: Clear, wait, set, wait
    if !_CC_ClipSetInternal(content, timeout) {
        A_Clipboard := savedClip
        return false
    }
    
    ; Step 6: Paste
    SendInput("^v")
    
    ; Step 7: Wait for paste to complete (dynamic based on content length)
    pasteDelay := CC_CLIP_PASTE_BASE_DELAY + Min(StrLen(content) // CC_CLIP_CONTENT_SCALE, CC_CLIP_PASTE_MAX_DELAY)
    Sleep(pasteDelay)
    
    ; Step 8: Restore original clipboard
    A_Clipboard := savedClip
    
    return true
}

; ------------------------------------------------------------------------------
; CC_ClipPasteKeep(content, timeout)
; ------------------------------------------------------------------------------
; Pastes content but KEEPS it on the clipboard after pasting.
; Use when you want the user to be able to Ctrl+V again.
;
; Parameters:
;   content  - Text to paste
;   timeout  - ClipWait timeout in seconds (default: 2)
;
; Returns:
;   true on success, false on failure
; ------------------------------------------------------------------------------
CC_ClipPasteKeep(content, timeout := 2) {
    if (content = "")
        return false
    
    ; Clear, wait, set, wait (no save/restore)
    if !_CC_ClipSetInternal(content, timeout)
        return false
    
    ; Paste
    SendInput("^v")
    
    ; Wait for paste to complete
    pasteDelay := CC_CLIP_PASTE_BASE_DELAY + Min(StrLen(content) // CC_CLIP_CONTENT_SCALE, CC_CLIP_PASTE_MAX_DELAY)
    Sleep(pasteDelay)
    
    return true
}

; ------------------------------------------------------------------------------
; CC_ClipCopy(content, timeout)
; ------------------------------------------------------------------------------
; Copies content to clipboard WITHOUT pasting.
; Use when you just want to put something on the clipboard for the user.
;
; Parameters:
;   content  - Text to copy to clipboard
;   timeout  - ClipWait timeout in seconds (default: 2)
;
; Returns:
;   true on success, false on failure
; ------------------------------------------------------------------------------
CC_ClipCopy(content, timeout := 2) {
    if (content = "")
        return false
    
    return _CC_ClipSetInternal(content, timeout)
}

; ------------------------------------------------------------------------------
; CC_ClipGet()
; ------------------------------------------------------------------------------
; Gets the current clipboard text content.
;
; Returns:
;   The clipboard text, or empty string if clipboard is empty/non-text
; ------------------------------------------------------------------------------
CC_ClipGet() {
    return A_Clipboard
}

; ------------------------------------------------------------------------------
; CC_ClipClear()
; ------------------------------------------------------------------------------
; Clears the clipboard completely and waits for it to clear.
;
; Returns:
;   true (always succeeds)
; ------------------------------------------------------------------------------
CC_ClipClear() {
    A_Clipboard := ""
    Sleep(CC_CLIP_CLEAR_DELAY)
    return true
}

; ------------------------------------------------------------------------------
; CC_ClipSave()
; ------------------------------------------------------------------------------
; Saves the current clipboard state (all formats including images).
; Use with CC_ClipRestore() for manual clipboard management.
;
; Returns:
;   ClipboardAll object that can be restored later
;
; Example:
;   saved := CC_ClipSave()
;   ; ... do stuff ...
;   CC_ClipRestore(saved)
; ------------------------------------------------------------------------------
CC_ClipSave() {
    return ClipboardAll()
}

; ------------------------------------------------------------------------------
; CC_ClipRestore(savedClip)
; ------------------------------------------------------------------------------
; Restores a previously saved clipboard state.
;
; Parameters:
;   savedClip - ClipboardAll object from CC_ClipSave()
; ------------------------------------------------------------------------------
CC_ClipRestore(savedClip) {
    A_Clipboard := savedClip
}

; ==============================================================================
; NOTIFICATION HELPER
; ==============================================================================

; ------------------------------------------------------------------------------
; CC_ClipNotify(message, type, duration)
; ------------------------------------------------------------------------------
; Shows a notification for clipboard operations.
; Provides consistent user feedback across all clipboard operations.
;
; Parameters:
;   message  - The message to show
;   type     - "success", "warning", "error", or "info" (default: "info")
;   duration - How long to show in ms (default: 2000), 0 = persistent
; ------------------------------------------------------------------------------
CC_ClipNotify(message, type := "info", duration := 2000) {
    ; Icon types: 1 = info/success, 2 = warning, 3 = error
    static icons := Map("success", "1", "info", "1", "warning", "2", "error", "3")
    
    iconType := icons.Has(type) ? icons[type] : "1"
    TrayTip(message, "ContentCapture", iconType)
    
    if duration > 0
        SetTimer(TrayTip, -duration)
}

; ==============================================================================
; INTERNAL HELPER FUNCTIONS (Do not call directly from other files)
; ==============================================================================

; ------------------------------------------------------------------------------
; _CC_ClipSetInternal(content, timeout)
; ------------------------------------------------------------------------------
; INTERNAL: Sets clipboard content with guaranteed clear-wait-set-wait sequence.
; This is the CORE operation that prevents stale clipboard bugs.
;
; DO NOT CALL DIRECTLY - Use CC_ClipCopy, CC_ClipPaste, etc.
;
; Parameters:
;   content  - Text to put on clipboard
;   timeout  - ClipWait timeout in seconds
;
; Returns:
;   true if clipboard was set successfully, false otherwise
; ------------------------------------------------------------------------------
_CC_ClipSetInternal(content, timeout) {
    ; Step 1: Clear clipboard completely
    A_Clipboard := ""
    
    ; Step 2: Wait for clear to take effect
    Sleep(CC_CLIP_CLEAR_DELAY)
    
    ; Step 3: Verify clipboard is actually empty (extra safety for reliability)
    startTime := A_TickCount
    while (A_TickCount - startTime < 200) {
        if (A_Clipboard = "")
            break
        Sleep(20)
    }
    
    ; Step 4: Set new content
    A_Clipboard := content
    
    ; Step 5: Wait for clipboard to be ready with TEXT specifically
    if !ClipWait(timeout, 1) {
        CC_ClipNotify("Clipboard operation timed out", "error")
        return false
    }
    
    return true
}

; ==============================================================================
; LEGACY COMPATIBILITY WRAPPERS
; ==============================================================================
; These maintain backward compatibility with existing code that calls the old
; function names. New code should use CC_ClipPaste, CC_ClipCopy, etc.
;
; These wrappers will be removed in a future version.
; ==============================================================================

; Old CC_SafePaste → New CC_ClipPaste
CC_SafePaste(content, timeout := 2) {
    return CC_ClipPaste(content, timeout)
}

; Old CC_SafeCopy → New CC_ClipCopy
CC_SafeCopy(content, timeout := 2) {
    return CC_ClipCopy(content, timeout)
}

; Old CC_SafePasteNoRestore → New CC_ClipPasteKeep
CC_SafePasteNoRestore(content, timeout := 2) {
    return CC_ClipPasteKeep(content, timeout)
}
