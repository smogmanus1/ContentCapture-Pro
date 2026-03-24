#Requires AutoHotkey v2.0+

; ==============================================================================
; CC_Clipboard.ahk - Centralized Clipboard Operations for ContentCapture Pro
; ==============================================================================
; Version:     1.4.1
; Author:      Brad (with Claude AI assistance)
; Updated:     2026-03-23
;
; CHANGELOG v1.4.1:
;   - FIXED: CC_CLIP_CONTENT_SCALE and CC_CLIP_PASTE_MAX_DELAY were referenced
;     in CC_ClipPaste and CC_ClipPasteKeep but never defined anywhere in the
;     codebase. This caused a crash (unset variable) on any paste of content
;     that triggered the delay calculation. Both constants are now defined here.
;
; CHANGELOG v1.4.0:
;   - FIXED: Second hotstring never fires after first paste in Facebook comments
;   - ROOT CAUSE: SendInput("^v") disables the keyboard hook while running.
;   - FIX: Changed SendInput("^v") → SendEvent("^v") in CC_ClipPaste and
;     CC_ClipPasteKeep. SendEvent does NOT suppress the keyboard hook.
;   - FIX: Added Hotstring("Reset") after every paste to clear the recognizer.
;
; CHANGELOG v1.3.0:
;   - FIXED: Clipboard restore after paste was causing stale content bug.
;   - CC_ClipPaste now CLEARS clipboard after paste instead of restoring.
;
; CHANGELOG v1.2.0:
;   - Increased delays, added pre-paste input flush.
; ==============================================================================

; ==============================================================================
; CONFIGURATION
; ==============================================================================

global CC_CLIP_CLEAR_DELAY      := 100   ; ms to wait after clearing clipboard
global CC_CLIP_WAIT_TIMEOUT     := 2     ; seconds to wait for clipboard ready
global CC_CLIP_PRE_PASTE_DELAY  := 250   ; ms to wait BEFORE paste (flush input)
global CC_CLIP_PASTE_BASE_DELAY := 700   ; base ms to wait AFTER paste

; FIXED v1.4.1: These two were referenced but never defined — crash on large content
global CC_CLIP_CONTENT_SCALE    := 50    ; chars per ms of extra paste delay
global CC_CLIP_PASTE_MAX_DELAY  := 2000  ; cap on extra delay (ms)

; ==============================================================================
; PRIMARY CLIPBOARD FUNCTIONS
; ==============================================================================

; CC_ClipPaste(content, timeout)
; The PRIMARY paste function. Pastes content and CLEARS clipboard after.
CC_ClipPaste(content, timeout := 2) {
    if content = ""
        return false

    if !_CC_ClipSetInternal(content, timeout)
        return false

    ; Pre-paste flush
    Sleep(CC_CLIP_PRE_PASTE_DELAY)
    KeyWait("Ctrl",  "T0.3")
    KeyWait("Shift", "T0.3")
    KeyWait("Alt",   "T0.3")

    ; SendEvent, NOT SendInput — keeps keyboard hook alive for next hotstring
    SendEvent("^v")

    ; Dynamic delay based on content length
    contentLen := StrLen(content)
    pasteDelay := CC_CLIP_PASTE_BASE_DELAY
        + Min(contentLen // CC_CLIP_CONTENT_SCALE, CC_CLIP_PASTE_MAX_DELAY)
    pasteDelay := Max(pasteDelay, 500)
    Sleep(pasteDelay)

    ; Clear clipboard — prevents stale content on next operation
    A_Clipboard := ""

    ; Reset hotstring recognizer for clean slate on next hotstring
    Hotstring("Reset")

    return true
}

; CC_ClipPasteKeep(content, timeout)
; Pastes content but KEEPS it on the clipboard after pasting.
CC_ClipPasteKeep(content, timeout := 2) {
    if content = ""
        return false

    if !_CC_ClipSetInternal(content, timeout)
        return false

    Sleep(CC_CLIP_PRE_PASTE_DELAY)
    KeyWait("Ctrl",  "T0.3")
    KeyWait("Shift", "T0.3")
    KeyWait("Alt",   "T0.3")

    SendEvent("^v")

    contentLen := StrLen(content)
    pasteDelay := CC_CLIP_PASTE_BASE_DELAY
        + Min(contentLen // CC_CLIP_CONTENT_SCALE, CC_CLIP_PASTE_MAX_DELAY)
    pasteDelay := Max(pasteDelay, 500)
    Sleep(pasteDelay)

    Hotstring("Reset")

    return true
}

; CC_ClipCopy(content, timeout)
; Copies content to clipboard WITHOUT pasting.
CC_ClipCopy(content, timeout := 2) {
    if content = ""
        return false
    return _CC_ClipSetInternal(content, timeout)
}

; CC_ClipGet()
; Gets the current clipboard text.
CC_ClipGet() {
    return A_Clipboard
}

; CC_ClipClear()
; Clears the clipboard.
CC_ClipClear() {
    A_Clipboard := ""
    Sleep(CC_CLIP_CLEAR_DELAY)
    return true
}

; CC_ClipSave()
; Saves current clipboard state (all formats including images).
CC_ClipSave() {
    return ClipboardAll()
}

; CC_ClipRestore(savedClip)
; Restores a previously saved clipboard state.
CC_ClipRestore(savedClip) {
    A_Clipboard := savedClip
}

; ==============================================================================
; NOTIFICATION HELPER
; ==============================================================================

CC_ClipNotify(message, type := "info", duration := 2000) {
    static icons := Map("success","1","info","1","warning","2","error","3")
    iconType := icons.Has(type) ? icons[type] : "1"
    TrayTip(message, "ContentCapture", iconType)
    if duration > 0
        SetTimer(TrayTip, -duration)
}

; ==============================================================================
; INTERNAL HELPER
; ==============================================================================

_CC_ClipSetInternal(content, timeout) {
    ; Clear
    A_Clipboard := ""
    Sleep(CC_CLIP_CLEAR_DELAY)

    ; Wait for actual clear
    startTime := A_TickCount
    while A_TickCount - startTime < 300 {
        if A_Clipboard = ""
            break
        Sleep(25)
    }

    ; Set
    A_Clipboard := content

    ; Wait for text to be ready
    if !ClipWait(timeout, 1) {
        CC_ClipNotify("Clipboard operation timed out", "error")
        return false
    }

    Sleep(50)
    return true
}

; ==============================================================================
; LEGACY COMPATIBILITY WRAPPERS
; ==============================================================================

CC_SafePaste(content, timeout := 2) {
    return CC_ClipPaste(content, timeout)
}

CC_SafeCopy(content, timeout := 2) {
    return CC_ClipCopy(content, timeout)
}

CC_SafePasteNoRestore(content, timeout := 2) {
    return CC_ClipPasteKeep(content, timeout)
}
