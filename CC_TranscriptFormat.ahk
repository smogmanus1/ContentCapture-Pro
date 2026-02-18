#Requires AutoHotkey v2.0+

; ==============================================================================
; CC_TranscriptFormat.ahk - Transcript Formatting for ContentCapture Pro
; ==============================================================================
; Version:     1.0
; Created:     2026-02-17
;
; PURPOSE: Adds a "Format" button to the Transcript field that cleans up raw
;          video/audio transcripts (YouTube, PBS, podcasts, etc.)
;
; FEATURES:
;   1. CLEAN TRANSCRIPT - Removes all non-speech content:
;      - Music cues (♪ ♪, ♫, etc.)
;      - Sound effects ((gunfire), (train chugging), (birds chirping), etc.)
;      - Stage directions ((crowd chattering), (whistle blows), etc.)
;      - Speaker labels (NARRATOR:, EDWARDS:, etc.)
;      - Redundant blank lines and whitespace cleanup
;
;   2. KEY QUOTES - Extracts notable interview quotes with speaker attribution:
;      - Identifies non-narrator speakers and their quotes
;      - Formats as "Speaker Name: quote text"
;      - Skips narrator/description passages
;      - Perfect for social media sharing and research notes
;
; DEPENDENCIES:
;   - ContentCapture-Pro.ahk (GUI integration)
;
; INTEGRATION:
;   Call TF_AddToGUI(myGui) when building the Edit GUI to add the Format
;   button next to the existing Paste/Clear buttons on the Transcript field.
; ==============================================================================


; ==============================================================================
; TF_AddToGUI - Add Format button to the transcript section of the Edit GUI
; ==============================================================================
; Call this when building your Edit GUI, near the Transcript field.
; Places a "Format" button alongside existing Paste and Clear buttons.
;
; @param myGui - The GUI object
; @param transcriptCtrl - The Edit control for the transcript field
; ==============================================================================
global TF_TranscriptCtrl := ""

TF_AddToGUI(myGui, transcriptCtrl) {
    global TF_TranscriptCtrl
    TF_TranscriptCtrl := transcriptCtrl
    
    ; Add Format button - place it near existing Paste/Clear buttons
    btnFormat := myGui.Add("Button", "x+5 w70 h24", "📝 Format")
    btnFormat.OnEvent("Click", TF_ShowFormatMenu)
    
    return btnFormat
}


; ==============================================================================
; TF_ShowFormatMenu - Display formatting options menu
; ==============================================================================
; Shows a menu with formatting choices when the Format button is clicked.
; ==============================================================================
TF_ShowFormatMenu(*) {
    global TF_TranscriptCtrl
    
    if (TF_TranscriptCtrl = "" || TF_TranscriptCtrl.Value = "") {
        MsgBox("No transcript text to format.`n`nPaste a transcript first, then click Format.", "No Transcript", "48")
        return
    }
    
    formatMenu := Menu()
    formatMenu.Add("🧹 Clean Transcript (remove all non-speech)", TF_DoCleanTranscript)
    formatMenu.Add("💬 Key Quotes Only (extract speaker quotes)", TF_DoKeyQuotes)
    formatMenu.Add()  ; Separator
    formatMenu.Add("🧹 Clean + 💬 Quotes (both in sequence)", TF_DoBoth)
    formatMenu.Show()
}


; ==============================================================================
; TF_DoCleanTranscript - Full transcript cleanup
; ==============================================================================
; Removes:
;   - Music symbols (♪ ♫ and variations)
;   - Parenthetical sound effects/stage directions
;   - ALL CAPS speaker labels (NARRATOR:, EDWARDS:, etc.)
;   - Excessive whitespace and blank lines
; ==============================================================================
TF_DoCleanTranscript(*) {
    global TF_TranscriptCtrl
    
    text := TF_TranscriptCtrl.Value
    cleaned := TF_CleanTranscript(text)
    TF_TranscriptCtrl.Value := cleaned
    
    ; Calculate stats
    origLen := StrLen(text)
    newLen := StrLen(cleaned)
    reduction := origLen > 0 ? Round((1 - newLen / origLen) * 100) : 0
    
    TrayTip("Transcript cleaned! (" reduction "% reduction)", "📝 Format", "1")
}


; ==============================================================================
; TF_DoKeyQuotes - Extract key quotes with speaker attribution
; ==============================================================================
TF_DoKeyQuotes(*) {
    global TF_TranscriptCtrl
    
    text := TF_TranscriptCtrl.Value
    quotes := TF_ExtractKeyQuotes(text)
    
    if (quotes = "") {
        MsgBox("No speaker quotes found in the transcript.`n`nThis works best with transcripts that have speaker labels like EDWARDS: or BRANDS:", "No Quotes Found", "48")
        return
    }
    
    ; Ask user where to put the quotes
    result := MsgBox(
        "Extracted key quotes from the transcript.`n`n"
        "REPLACE the transcript with quotes only?`n`n"
        "YES = Replace transcript with key quotes`n"
        "NO = Copy quotes to clipboard instead",
        "💬 Key Quotes Extracted",
        "YesNo Icon?"
    )
    
    if (result = "Yes") {
        TF_TranscriptCtrl.Value := quotes
        TrayTip("Transcript replaced with key quotes!", "💬 Key Quotes", "1")
    } else {
        A_Clipboard := quotes
        TrayTip("Key quotes copied to clipboard!", "💬 Key Quotes", "1")
    }
}


; ==============================================================================
; TF_DoBoth - Clean first, then extract quotes
; ==============================================================================
TF_DoBoth(*) {
    global TF_TranscriptCtrl
    
    text := TF_TranscriptCtrl.Value
    
    ; First extract quotes (from original text with speaker labels intact)
    quotes := TF_ExtractKeyQuotes(text)
    
    ; Then clean the transcript
    cleaned := TF_CleanTranscript(text)
    
    ; Combine: cleaned transcript at top, quotes at bottom
    combined := cleaned
    if (quotes != "") {
        combined .= "`n`n"
        combined .= "═══════════════════════════════════════`n"
        combined .= "KEY QUOTES`n"
        combined .= "═══════════════════════════════════════`n`n"
        combined .= quotes
    }
    
    TF_TranscriptCtrl.Value := combined
    TrayTip("Transcript cleaned + key quotes appended!", "📝 Format", "1")
}


; ==============================================================================
; TF_CleanTranscript - Core cleaning function
; ==============================================================================
; @param text - Raw transcript text
; @return Cleaned transcript text
; ==============================================================================
TF_CleanTranscript(text) {
    cleaned := text
    
    ; ── Step 1: Remove music symbols ──
    ; Covers: ♪ ♫ and any combinations with spaces
    cleaned := RegExReplace(cleaned, "[♪♫]+[\s]*[♪♫]*", "")
    
    ; ── Step 2: Remove parenthetical sound effects / stage directions ──
    ; Matches: (gunfire), (birds chirping), (train chugging, bell ringing), etc.
    ; Handles multi-word content and content with commas inside parens
    cleaned := RegExReplace(cleaned, "\([^)]*\)", "")
    
    ; ── Step 3: Remove ALL CAPS speaker labels ──
    ; Matches: NARRATOR:, EDWARDS:, H.W. BRANDS:, JOHN KUO WEI TCHEN:, etc.
    ; Pattern: Start of line or after whitespace, 2+ uppercase letters/dots/spaces, followed by colon
    cleaned := RegExReplace(cleaned, "(?m)^[ \t]*[A-Z][A-Z\s.]+:\s*", "")
    
    ; Also handle mid-line speaker labels
    cleaned := RegExReplace(cleaned, "\s+[A-Z][A-Z\s.]{2,}:\s*", " ")
    
    ; ── Step 4: Remove lines that are ONLY speaker labels or stage directions ──
    ; (already handled above, but catch any remainders)
    cleaned := RegExReplace(cleaned, "(?m)^[ \t]*$\R?", "")
    
    ; ── Step 5: Clean up excessive whitespace ──
    ; Multiple spaces to single space
    cleaned := RegExReplace(cleaned, "  +", " ")
    
    ; Multiple blank lines to double newline (paragraph break)
    cleaned := RegExReplace(cleaned, "(\R\s*){3,}", "`n`n")
    
    ; Remove leading/trailing whitespace per line
    cleaned := RegExReplace(cleaned, "(?m)^[ \t]+", "")
    cleaned := RegExReplace(cleaned, "(?m)[ \t]+$", "")
    
    ; ── Step 6: Remove orphaned punctuation ──
    ; Commas or periods left dangling from removed content
    cleaned := RegExReplace(cleaned, "(?m)^[,.\s]+$", "")
    
    ; ── Step 7: Final trim ──
    cleaned := Trim(cleaned, " `t`n`r")
    
    ; One more pass to collapse any remaining excessive blank lines
    cleaned := RegExReplace(cleaned, "(\R\s*){3,}", "`n`n")
    
    return cleaned
}


; ==============================================================================
; TF_ExtractKeyQuotes - Extract notable quotes with speaker attribution
; ==============================================================================
; Scans the transcript for non-narrator speaker sections and extracts
; their quotes. Skips NARRATOR sections entirely.
;
; @param text - Raw transcript text (with speaker labels)
; @return Formatted string of quotes with speaker names
; ==============================================================================
TF_ExtractKeyQuotes(text) {
    quotes := ""
    
    ; Split text into speaker sections
    ; Find all instances of SPEAKER_NAME: followed by their text
    ; Pattern matches: UPPERCASE NAME: text until next UPPERCASE NAME: or end
    
    ; First, normalize line endings
    text := StrReplace(text, "`r`n", "`n")
    
    ; Build a list of speaker positions
    speakerPositions := []
    startPos := 1
    
    while (startPos <= StrLen(text)) {
        ; Find next speaker label
        if RegExMatch(text, "(?m)([A-Z][A-Z\s.]{1,30}):\s*", &match, startPos) {
            speakerPositions.Push(Map(
                "name", TF_FormatSpeakerName(Trim(match[1])),
                "pos", match.Pos + match.Len,
                "rawname", Trim(match[1])
            ))
            startPos := match.Pos + 1
        } else {
            break
        }
    }
    
    if (speakerPositions.Length = 0)
        return ""
    
    ; Extract text between speaker labels
    skipNames := ["NARRATOR", "NEWSBOY"]  ; Skip these speakers
    
    for i, speaker in speakerPositions {
        ; Check if this speaker should be skipped
        shouldSkip := false
        for skipName in skipNames {
            if (speaker["rawname"] = skipName) {
                shouldSkip := true
                break
            }
        }
        if (shouldSkip)
            continue
        
        ; Get text from this speaker's position to the next speaker's position
        startP := speaker["pos"]
        if (i < speakerPositions.Length)
            endP := speakerPositions[i + 1]["pos"] - StrLen(speakerPositions[i + 1]["rawname"]) - 2
        else
            endP := StrLen(text)
        
        spokenText := SubStr(text, startP, endP - startP)
        
        ; Clean the spoken text
        spokenText := RegExReplace(spokenText, "[♪♫]+[\s]*[♪♫]*", "")
        spokenText := RegExReplace(spokenText, "\([^)]*\)", "")
        spokenText := RegExReplace(spokenText, "(\R\s*){2,}", " ")
        spokenText := RegExReplace(spokenText, "  +", " ")
        spokenText := Trim(spokenText, " `t`n`r")
        
        ; Skip very short quotes (likely fragments)
        if (StrLen(spokenText) < 30)
            continue
        
        ; Add to quotes collection
        if (quotes != "")
            quotes .= "`n`n"
        quotes .= speaker["name"] ": " spokenText
    }
    
    return quotes
}


; ==============================================================================
; TF_FormatSpeakerName - Convert ALL CAPS name to Title Case
; ==============================================================================
; Converts "REBECCA EDWARDS" to "Rebecca Edwards"
; Handles special cases like "H.W. BRANDS" and "JOHN KUO WEI TCHEN"
;
; @param name - ALL CAPS speaker name
; @return Title Case formatted name
; ==============================================================================
TF_FormatSpeakerName(name) {
    ; Handle initials like H.W. - keep them uppercase
    result := ""
    words := StrSplit(name, " ")
    
    for i, word in words {
        if (i > 1)
            result .= " "
        
        ; Check if it's an initial (like "H.W." or "J.")
        if RegExMatch(word, "^[A-Z]\.") {
            result .= word  ; Keep initials as-is
        } else {
            ; Title case: first letter upper, rest lower
            result .= StrUpper(SubStr(word, 1, 1)) . StrLower(SubStr(word, 2))
        }
    }
    
    return result
}


; ==============================================================================
; TF_FormatForPlatform - Format transcript quotes for specific platforms
; ==============================================================================
; Can be called from Research menu or suffix handlers to format
; transcript content for social media sharing.
;
; @param text - Transcript or quote text
; @param platform - "twitter", "facebook", "bluesky", etc.
; @param maxLen - Character limit (0 = no limit)
; @return Formatted text for the platform
; ==============================================================================
TF_FormatForPlatform(text, platform, maxLen := 0) {
    ; Clean it first
    cleaned := TF_CleanTranscript(text)
    
    ; Apply character limit if specified
    if (maxLen > 0 && StrLen(cleaned) > maxLen) {
        cleaned := SubStr(cleaned, 1, maxLen - 3) . "..."
    }
    
    return cleaned
}
