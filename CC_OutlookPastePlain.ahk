#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; Outlook Plain Text Paste - Ctrl+Shift+V
; ==============================================================================
; Paste clipboard contents as plain text into an open Outlook email
; at the current cursor position.
;
; Run this alongside ContentCapture Pro for universal plain-text Outlook paste.
; ==============================================================================

^+v:: {
    txt := A_Clipboard
    if (txt = "") {
        SoundBeep(900, 120)
        return
    }
    
    ; Normalize line breaks for Word paragraphs
    t := StrReplace(txt, "`r`n", "`n")
    t := StrReplace(t, "`r", "`n")
    t := StrReplace(t, "`n", "`r")
    
    ol := ""
    try {
        ol := ComObjActive("Outlook.Application")
    } catch {
        try {
            ol := ComObject("Outlook.Application")
        } catch {
            MsgBox("Outlook not available. Open Outlook and try again.", "Error", 48)
            return
        }
    }
    
    try {
        insp := ol.ActiveInspector
        if !insp {
            MsgBox("Open an email compose window and click in the body first.", "Error", 48)
            return
        }
        wd := insp.WordEditor
        sel := wd.Application.Selection
        sel.TypeText(t)
    } catch as e {
        MsgBox("Make sure cursor is in email body (not To/Subject).`n`n" . e.Message, "Error", 48)
    }
}
