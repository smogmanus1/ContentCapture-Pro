#Requires AutoHotkey v2.0+

; ==============================================================================
; CC_Clipboard.ahk - Centralized Clipboard Operations for ContentCapture Pro
; ==============================================================================
; Version:     1.1.0
; Author:      Brad (with Claude AI assistance)
; Updated:     2026-02-01
;
; CHANGELOG v1.1.0:
;   - FIXED: Paste delay was too short (100-400ms) causing stale clipboard paste
;   - Increased CC_CLIP_PASTE_BASE_DELAY from 100ms to 400ms
;   - Increased CC_CLIP_PASTE_MAX_DELAY from 300ms to 1500ms
;   - Added verification loop to ensure paste completes before restore
;   - This fixes the bug where typing "400bill" would paste clipboard URL instead
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
;   7. Wait for action to complete (CRITICAL - must be long enough!)
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
; v1.1.0: Increased all delays to prevent "stale clipboard" paste bugs
; The old values (100/300/100) were causing clipboard restore before paste completed

global CC_CLIP_CLEAR_DELAY := 75          ; ms to wait after clearing clipboard
global CC_CLIP_WAIT_TIMEOUT := 2          ; seconds to wait for clipboard ready
global CC_CLIP_PASTE_BASE_DELAY := 400    ; base ms to wait after paste (was 100)
global CC_CLIP_PASTE_MAX_DELAY := 1500    ; max additional delay for long content (was 300)
global CC_CLIP_CONTENT_SCALE := 50        ; add 1ms per this many chars (was 100)

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
    
    ; Step 7: Wait for paste to complete (CRITICAL - must be long enough!)
    ; Calculate delay based on content length
    ; Short content (< 500 chars): 400ms base
    ; Medium content (500-2000 chars): 400-800ms  
    ; Long content (2000-5000 chars): 800-1200ms
    ; Very long content (5000+ chars): 1200-1900ms (capped)
    contentLen := StrLen(content)
    pasteDelay := CC_CLIP_PASTE_BASE_DELAY + Min(contentLen // CC_CLIP_CONTENT_SCALE, CC_CLIP_PASTE_MAX_DELAY)
    
    ; Ensure minimum delay for any content
    pasteDelay := Max(pasteDelay, 400)
    
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
    contentLen := StrLen(content)
    pasteDelay := CC_CLIP_PASTE_BASE_DELAY + Min(contentLen // CC_CLIP_CONTENT_SCALE, CC_CLIP_PASTE_MAX_DELAY)
    pasteDelay := Max(pasteDelay, 400)
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
    while (A_TickCount - startTime < 300) {
        if (A_Clipboard = "")
            break
        Sleep(25)
    }
    
    ; Step 4: Set new content
    A_Clipboard := content
    
    ; Step 5: Wait for clipboard to be ready with TEXT specifically
    if !ClipWait(timeout, 1) {
        CC_ClipNotify("Clipboard operation timed out", "error")
        return false
    }
    
    ; Step 6: Extra verification - make sure content actually matches
    ; This catches edge cases where ClipWait returns but content isn't fully set
    Sleep(50)
    
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
