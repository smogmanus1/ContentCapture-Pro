#Requires AutoHotkey v2.0
; =============================================================================
;  CC_FacebookComment.ahk    v0.2
;  Drop-in module for ContentCapture Pro (CCP).
;  Adds Facebook-safe paste behavior for comment/post fields.
;
;  Changes from v0.1:
;    - Delegates paste to CCP's centralized CC_Paste() pipeline (no duplicate).
;    - urlLast defaults to TRUE (auto-moves first URL to last line so
;      Facebook generates its link-preview card).
;    - Kept reference-counted suspension wrappers around the whole operation,
;      which nest safely inside any suspension CC_Paste does internally.
;
;  Integration:
;    1. Save this file next to ContentCapture-Pro.ahk
;    2. Add this line to ContentCapture-Pro.ahk (with the other #Include lines):
;         #Include CC_FacebookComment.ahk
;       Place it AFTER CC_Clipboard.ahk so CC_Paste is already defined.
;    3. Reload CCP.
;
;  Public API:
;    CC_FBPaste(content, opts := "")
;        content : String to paste.
;        opts    : Object with optional flags (any subset):
;                    requireFB      : true  -> abort if foreground isn't a FB tab
;                                              (default false)
;                    urlLast        : false -> keep URL in original position
;                                              (default TRUE)
;                    pressEnter     : true  -> submit the comment after paste
;                                              (default FALSE - Enter posts on FB)
;                    imageModeHint  : true  -> confirm user clicked image
;                                              button BEFORE running
;                                              (default false)
;
;    CC_IsFacebookWindow()
;        Returns 1 if the active window looks like a Facebook browser tab.
;
;    CC_FBFormatURLLast(content)
;        Returns content with the first http(s):// URL moved to the last line.
; =============================================================================


; -----------------------------------------------------------------------------
;  CC_FBPaste - main public entry point
; -----------------------------------------------------------------------------
CC_FBPaste(content, opts := "") {
    ; Defaults
    o := {
        requireFB:     false,
        urlLast:       true,        ; <-- default ON
        pressEnter:    false,
        imageModeHint: false
    }
    if IsObject(opts) {
        for k, v in opts.OwnProps()
            o.%k% := v
    }

    ; Optional: strict window check
    if (o.requireFB && !CC_IsFacebookWindow()) {
        MsgBox("Focus a Facebook comment or post field before using this.",
               "CCP - Facebook Paste", 48)
        return false
    }

    ; Optional: reminder for image-attached posts
    if (o.imageModeHint) {
        r := MsgBox("Did you click the IMAGE button FIRST?`n`n"
                  . "(Pasting text before clicking the image button"
                  . " grays out the image option on Facebook.)",
                    "CCP - Facebook Paste", 0x4 | 0x30)   ; Yes/No + warning
        if (r = "No")
            return false
    }

    ; Reorder URL to last line so FB generates the preview card
    if (o.urlLast)
        content := CC_FBFormatURLLast(content)

    ; Balanced hotstring suspension around the whole operation.
    ; Nests safely inside any suspension CC_Paste performs internally
    ; because CCP's suspend/resume is reference-counted.
    _CC_FBSuspend()
    ok := false
    try {
        ok := _CC_FBInternalPaste(content)
    } finally {
        _CC_FBResume()
    }

    if (!ok)
        return false

    ; Re-arm hotstring buffer so the next ;;xxx fires cleanly.
    ; Harmless if CC_Paste already did this.
    Hotstring("Reset")

    ; Optional: submit the comment (OFF by default - Enter = post on Facebook)
    if (o.pressEnter) {
        Sleep(150)
        SendEvent("{Enter}")
    }

    return true
}


; -----------------------------------------------------------------------------
;  CC_IsFacebookWindow - detect FB tab in any common browser
; -----------------------------------------------------------------------------
CC_IsFacebookWindow() {
    ; LibreWolf is primary; rest covered for edge cases.
    browsers := ["librewolf.exe", "firefox.exe", "chrome.exe",
                 "msedge.exe", "brave.exe", "opera.exe"]
    prevMatchMode := A_TitleMatchMode
    SetTitleMatchMode(2)    ; contains-match
    try {
        for exe in browsers {
            if WinActive("Facebook ahk_exe " exe)
                return true
            ; Some FB pages read as "(n) Facebook" or "Page Name | Facebook"
            if WinActive("| Facebook ahk_exe " exe)
                return true
        }
        return false
    } finally {
        SetTitleMatchMode(prevMatchMode)
    }
}


; -----------------------------------------------------------------------------
;  CC_FBFormatURLLast - move first http(s):// URL to the last line
;  Keeps other URLs in place. No-op if no URL found.
; -----------------------------------------------------------------------------
CC_FBFormatURLLast(content) {
    if !RegExMatch(content, "https?://\S+", &m)
        return content

    url := m[]
    pos := InStr(content, url)
    if !pos
        return content

    before := SubStr(content, 1, pos - 1)
    after  := SubStr(content, pos + StrLen(url))
    rebuilt := before . after

    ; Trim trailing whitespace/newlines, then re-append URL on its own line
    rebuilt := RegExReplace(rebuilt, "[\s`r`n]+$", "")
    return rebuilt . "`r`n`r`n" . url
}


; =============================================================================
;  INTERNAL HELPERS - not intended for direct use outside this module
; =============================================================================

; -----------------------------------------------------------------------------
;  _CC_FBInternalPaste - delegates to CCP's centralized paste pipeline.
;  CC_Paste handles the clear-before-set clipboard logic, ClipWait,
;  SendEvent("^v"), and length-based settle delay.
;  Returns true on success. Treats a void (empty-string) return as success.
; -----------------------------------------------------------------------------
_CC_FBInternalPaste(content) {
    result := CC_Paste(content)
    return (result = "" || result) ? true : false
}

; -----------------------------------------------------------------------------
;  Defensive wrappers for CCP's reference-counted suspension helpers.
;  If CC_SuspendHotstrings / CC_ResumeHotstrings aren't loaded yet (e.g.
;  this module runs standalone during testing), these become no-ops.
; -----------------------------------------------------------------------------
_CC_FBSuspend() {
    try {
        if IsSet(CC_SuspendHotstrings)
            CC_SuspendHotstrings()
    }
}

_CC_FBResume() {
    try {
        if IsSet(CC_ResumeHotstrings)
            CC_ResumeHotstrings()
    }
}


; =============================================================================
;  EXAMPLE HOTSTRINGS - remove or move to your content file.
;  Naming follows the CCP convention: ;;name for plain, ;;namefb for Facebook.
;  urlLast is now default-on, so you don't need to pass it explicitly.
; =============================================================================

; Plain FB paste: disposable-income talking point (from your screenshot)
:*:;;cotwylfb::{
    content := "
    (Join`r`n
There's a reason you don't have disposable income anymore.

Watch this and tell me it doesn't line up with what you're seeing:
https://www.youtube.com/watch?v=REPLACE_WITH_REAL_ID
    )"
    CC_FBPaste(content)
}

; FB-strict: aborts outside a Facebook browser tab
:*:;;cothwghfb::{
    content := "
    (Join`r`n
Your middle class life was taken. Here's how it happened:
https://www.youtube.com/watch?v=REPLACE_WITH_REAL_ID
    )"
    CC_FBPaste(content, { requireFB: true })
}

; With image-mode reminder (for posts where you're also attaching an image)
:*:;;cotwdigfbimg::{
    content := "
    (Join`r`n
Where did your disposable income go? The answer isn't what they told you.
https://www.youtube.com/watch?v=REPLACE_WITH_REAL_ID
    )"
    CC_FBPaste(content, { imageModeHint: true })
}

; Hotkey alternative - Ctrl+Alt+Shift+F pastes current clipboard, FB-formatted
^!+f::{
    if (A_Clipboard = "") {
        MsgBox("Clipboard is empty - nothing to paste.",
               "CCP - Facebook Paste", 48)
        return
    }
    CC_FBPaste(A_Clipboard, { requireFB: true })
}
