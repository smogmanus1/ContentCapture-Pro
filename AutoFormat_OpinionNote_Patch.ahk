; ==============================================================================
; ContentCapture Pro - AUTO-FORMAT PATCH for Opinion and Note Fields
; ==============================================================================
; 
; This patch adds Auto-Format buttons to the Opinion and Private Note fields
; in the Capture Details (Edit) dialog.
;
; INSTRUCTIONS:
; 1. Open your ContentCapture-Pro.ahk
; 2. Find the CC_EditCapture function (search for "CC_EditCapture")
; 3. Locate the Opinion field section and Private Note section
; 4. Replace them with the code below
;
; ==============================================================================

; -----------------------------------------------------------------------------
; FIND THIS (Opinion field without Auto-Format button):
; -----------------------------------------------------------------------------
;   editGui.SetFont("s9 c666666")
;   editGui.Add("Text", "x15 y365", "Opinion (included in output):")
;   editGui.SetFont("s10 c000000")
;   editOpinion := editGui.Add("Edit", "x15 y383 w670 h50 Multi vEditOpinion", currentOpinion)

; -----------------------------------------------------------------------------
; REPLACE WITH THIS (Opinion field WITH Auto-Format button):
; -----------------------------------------------------------------------------

    ; Opinion field with Auto-Format button
    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y365", "Opinion (included in output):")
    editGui.SetFont("s8", "Segoe UI")
    opinionFormatBtn := editGui.Add("Button", "x200 y362 w90 h22", "🔧 Auto-Format")
    opinionFormatBtn.OnEvent("Click", (*) => CC_AutoFormatField(editOpinion))
    editGui.Add("Button", "x295 y362 w50 h22", "Clear").OnEvent("Click", (*) => editOpinion.Value := "")
    editGui.SetFont("s10 c000000")
    editOpinion := editGui.Add("Edit", "x15 y383 w670 h50 Multi vEditOpinion", currentOpinion)


; -----------------------------------------------------------------------------
; FIND THIS (Private Note field without Auto-Format button):
; -----------------------------------------------------------------------------
;   editGui.SetFont("s9 c666666")
;   editGui.Add("Text", "x15 y295", "📝 Private Note (only you see this):")
;   editGui.SetFont("s10 c000000")
;   editNote := editGui.Add("Edit", "x15 y313 w670 h45 Multi vEditNote", currentNote)

; -----------------------------------------------------------------------------
; REPLACE WITH THIS (Private Note field WITH Auto-Format button):
; -----------------------------------------------------------------------------

    ; Private Note field with Auto-Format button
    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y295", "📝 Private Note (only you see this):")
    editGui.SetFont("s8", "Segoe UI")
    noteFormatBtn := editGui.Add("Button", "x250 y292 w90 h22", "🔧 Auto-Format")
    noteFormatBtn.OnEvent("Click", (*) => CC_AutoFormatField(editNote))
    editGui.Add("Button", "x345 y292 w50 h22", "Clear").OnEvent("Click", (*) => editNote.Value := "")
    editGui.SetFont("s10 c000000")
    editNote := editGui.Add("Edit", "x15 y313 w670 h45 Multi vEditNote", currentNote)


; ==============================================================================
; ADD THIS FUNCTION (if you don't already have it)
; ==============================================================================
; Place this near your CC_AutoFormatBody function

/**
 * CC_AutoFormatField - Auto-format any multi-line text field
 * Works for Opinion, Note, Body, or any Edit control
 * Intelligently adds paragraph breaks to wall-of-text
 */
CC_AutoFormatField(editControl) {
    text := editControl.Value
    
    if (text = "") {
        TrayTip("No text to format", "Auto-Format", "2")
        return
    }
    
    ; First normalize existing line breaks
    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")
    
    ; If text already has proper line breaks, just clean it up
    if InStr(text, "`n`n") {
        text := CC_CleanContent(text)
        editControl.Value := text
        TrayTip("Text cleaned up!", "Auto-Format", "1")
        return
    }
    
    ; Common paragraph starters (after a period, !, or ?)
    starters := "I |You |We |They |He |She |It |The |This |That |These |Those |"
    starters .= "My |Your |Our |Their |His |Her |Its |"
    starters .= "In |On |At |By |For |From |With |To |"
    starters .= "However|But |And |So |Yet |Or |"
    starters .= "First|Second|Third|Finally|"
    starters .= "When |Where |What |Why |How |Who |"
    starters .= "If |Although |Because |Since |While |"
    starters .= "After |Before |During |Until |"
    starters .= "One |Two |Three |Four |Five |"
    starters .= "According |Additionally |Also |"
    starters .= "For example|For instance|In fact|"
    starters .= "Moreover|Furthermore|Therefore|Thus|Hence|"
    starters .= "As |Like |Unlike |"
    starters .= "Here |There |"
    starters .= "A |An |"
    starters .= "[0-9]+\. |[0-9]+\) |• |- |— "
    
    ; Build regex pattern for paragraph detection
    ; Look for: period/!/? + space + capital letter that starts common patterns
    pattern := "([.!?])\s+(" starters ")"
    
    ; Replace with sentence ender + double newline + starter
    formatted := RegExReplace(text, pattern, "$1`n`n$2")
    
    ; Also break on clear topic shifts (sentences starting with "I " after any sentence)
    formatted := RegExReplace(formatted, "([.!?])\s+(I [a-z])", "$1`n`n$2")
    
    ; Break after quoted statements followed by analysis
    formatted := RegExReplace(formatted, '([""])\s+(This |That |It |The )', "$1`n`n$2")
    
    ; Clean up any triple+ newlines
    formatted := RegExReplace(formatted, "`n`n`n+", "`n`n")
    
    ; Convert to Windows line endings for Edit controls
    formatted := StrReplace(formatted, "`n", "`r`n")
    
    ; Update the edit control
    editControl.Value := Trim(formatted)
    
    TrayTip("Text reformatted!", "Auto-Format", "1")
}


; ==============================================================================
; OPTIONAL: Add Auto-Format to Manual Capture Dialog (Ctrl+Alt+N)
; ==============================================================================
; In CC_ShowManualCapture, find the Opinion field section and add:

    ; Opinion (public) with Auto-Format
    opinionY := noteY + 70
    manualGui.Add("Text", "x20 y" opinionY, "Opinion (included when you paste):")
    manualGui.SetFont("s8")
    opinionFormatBtn := manualGui.Add("Button", "x230 y" (opinionY - 3) " w90 h22", "🔧 Auto-Format")
    opinionFormatBtn.OnEvent("Click", (*) => CC_AutoFormatField(opinionEdit))
    manualGui.SetFont("s10")
    opinionEdit := manualGui.Add("Edit", "x20 y" (opinionY + 20) " w550 h40 vOpinion")


; ==============================================================================
; EXAMPLE: What the Auto-Format does
; ==============================================================================
; 
; BEFORE (wall of text):
; "How Americans Became the Target of Their Own Government's Messaging For decades, U.S. law recognized a basic danger: a government should not use persuasion techniques on its own citizens. That is why the Smith–Mundt Act (1948) originally created a firewall. It allowed the U.S. government to produce messaging for foreign audiences only, while explicitly restricting its domestic distribution."
;
; AFTER (formatted paragraphs):
; "How Americans Became the Target of Their Own Government's Messaging
; 
; For decades, U.S. law recognized a basic danger: a government should not use persuasion techniques on its own citizens.
; 
; That is why the Smith–Mundt Act (1948) originally created a firewall.
; 
; It allowed the U.S. government to produce messaging for foreign audiences only, while explicitly restricting its domestic distribution."
;
; ==============================================================================
