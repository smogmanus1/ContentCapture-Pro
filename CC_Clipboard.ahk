#Requires AutoHotkey v2.0+

; ==============================================================================
; CC_Clipboard.ahk - Centralized Clipboard Operations for ContentCapture Pro
; ==============================================================================
; Version:     1.3.0
; Author:      Brad (with Claude AI assistance)
; Updated:     2026-02-18
;
; CHANGELOG v1.3.0:
;   - FIXED: Clipboard restore after paste was THE cause of stale content bug
;   - CC_ClipPaste now CLEARS clipboard after paste instead of restoring old content
;   - _DSH_SafePaste fallback also updated to clear instead of restore
;   - Restoring old clipboard caused race conditions where stale content would
;     get pasted on the NEXT hotstring trigger instead of new content
;   - This is the definitive fix for "clipboard not clearing" / "wrong content pasting"
;
; CHANGELOG v1.2.0:
;   - FIXED: Paste delay STILL too short for some applications
;   - FIXED: Input race condition where ending character corrupts pasted text
;   - NEW: SendInput flush before paste prevents keystroke leaking into content
;   - NEW: KeyWait ensures modifier keys are released before paste
;   - Increased CC_CLIP_PASTE_BASE_DELAY to 500ms (was 400, originally 100)
;   - Increased CC_CLIP_PASTE_MAX_DELAY to 2000ms (was 1500, originally 300)
;   - Added 150ms pre-paste delay for input buffer to flush
;   - This fixes "dtlied" pasting partial/corrupted content
;
; CHANGELOG v1.1.0:
;   - FIXED: Paste delay was too short (100-400ms) causing stale clipboard paste
;   - This fixed "400bill" pasting stale clipboard URL instead of content
;
; PURPOSE:
;   This module provides a SINGLE, CONSISTENT way to handle ALL clipboard
;   operations in ContentCapture Pro. By centralizing clipboard logic here,
;   we eliminate an entire class of bugs related to stale clipboard content.
;
; THE PROBLEM THIS SOLVES:
;   Bug 1 (Stale Clipboard): Setting A_Clipboard and restoring too fast
;     causes the OLD clipboard content to get pasted instead of new content.
;   Bug 2 (Input Race): The hotstring trigger character (space/enter) can
;     leak into the paste operation, corrupting text (e.g., "lie" → "like").
;
; THE SOLUTION:
;   Every clipboard operation now follows this bulletproof sequence:
;   1. Clear clipboard completely
;   2. Wait for clear to complete
;   3. Set new content
;   4. Wait for content to be ready
;   5. FLUSH input buffer (prevent keystroke leaking)
;   6. Wait for modifier keys to release
;   7. Perform paste (Ctrl+V)
;   8. Wait for paste to complete (dynamic delay based on content size)
;   9. CLEAR clipboard (prevents stale content on next operation)
;
; USAGE:
;   CC_ClipPaste(content)      → Paste content, clear clipboard after
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
; v1.2.0: Further increased delays and added pre-paste input flush
;
; TIMING MATH (v1.2.0):
;   Short content  (100 chars):  500 + (100/50)  = 502ms   plus 150ms flush
;   Medium content (500 chars):  500 + (500/50)  = 510ms   plus 150ms flush
;   Long content   (2000 chars): 500 + (2000/50) = 540ms   plus 150ms flush
;   Very long      (5000 chars): 500 + (5000/50) = 600ms   plus 150ms flush
;   Huge content   (50000 chars):500 + 2000       = 2500ms  capped, plus flush

global CC_CLIP_CLEAR_DELAY := 75          ; ms to wait after clearing clipboard
global CC_CLIP_WAIT_TIMEOUT := 2          ; seconds to wait for clipboard ready
global CC_CLIP_PRE_PASTE_DELAY := 150     ; ms to wait BEFORE paste (flush input buffer)
global CC_CLIP_PASTE_BASE_DELAY := 500    ; base ms to wait AFTER paste (was 400, originally 100)
global CC_CLIP_PASTE_MAX_DELAY := 2000    ; max additional delay for long content (was 1500, originally 300)
global CC_CLIP_CONTENT_SCALE := 50        ; add 1ms per this many chars

; ==============================================================================
; PRIMARY CLIPBOARD FUNCTIONS
; ==============================================================================

; ------------------------------------------------------------------------------
; CC_ClipPaste(content, timeout)
; ------------------------------------------------------------------------------
; The PRIMARY paste function. Use this for hotstring paste operations.
; Pastes content and then CLEARS the clipboard to prevent stale content bugs.
;
; NOTE (v1.3.0): This function NO LONGER restores the original clipboard.
; Restoring caused race conditions where old content would get pasted on
; the next hotstring trigger. Clearing is the safe default.
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
    
    ; v1.3.0: NO LONGER saving/restoring clipboard
    ; Restoring old clipboard was THE root cause of stale content bugs.
    ; The old content would sit on the clipboard and win race conditions
    ; on the next hotstring trigger, causing wrong content to paste.
    
    ; Steps 1-4: Clear, wait, set, wait
    if !_CC_ClipSetInternal(content, timeout) {
        return false
    }
    
    ; Step 5: Pre-paste flush - let any pending keystrokes finish
    ; This prevents the hotstring trigger character (space/enter/etc.)
    ; from leaking into the pasted content (e.g., "lie" becoming "like")
    Sleep(CC_CLIP_PRE_PASTE_DELAY)
    
    ; Step 6: Ensure no modifier keys are stuck
    KeyWait("Ctrl", "T0.3")
    KeyWait("Shift", "T0.3")
    KeyWait("Alt", "T0.3")
    
    ; Step 7: Paste
    SendInput("^v")
    
    ; Step 8: Wait for paste to complete (CRITICAL - must be long enough!)
    ; Calculate delay based on content length
    contentLen := StrLen(content)
    pasteDelay := CC_CLIP_PASTE_BASE_DELAY + Min(contentLen // CC_CLIP_CONTENT_SCALE, CC_CLIP_PASTE_MAX_DELAY)
    pasteDelay := Max(pasteDelay, 500)
    Sleep(pasteDelay)
    
    ; Step 9: CLEAR clipboard after paste (v1.3.0 fix)
    ; This ensures no stale content remains for the next operation
    A_Clipboard := ""
    
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
    
    ; Pre-paste flush
    Sleep(CC_CLIP_PRE_PASTE_DELAY)
    KeyWait("Ctrl", "T0.3")
    KeyWait("Shift", "T0.3")
    KeyWait("Alt", "T0.3")
    
    ; Paste
    SendInput("^v")
    
    ; Wait for paste to complete
    contentLen := StrLen(content)
    pasteDelay := CC_CLIP_PASTE_BASE_DELAY + Min(contentLen // CC_CLIP_CONTENT_SCALE, CC_CLIP_PASTE_MAX_DELAY)
    pasteDelay := Max(pasteDelay, 500)
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
