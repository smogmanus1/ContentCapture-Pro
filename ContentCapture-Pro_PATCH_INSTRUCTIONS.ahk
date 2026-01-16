; ==============================================================================
; ContentCapture-Pro.ahk - PATCH FILE v5.7
; ==============================================================================
; 
; This file contains the exact changes needed to update ContentCapture-Pro.ahk
; from v5.6 to v5.7 ("Capture First, Process Later")
;
; ==============================================================================
; CHANGE 1: UPDATE THE VERSION AND CHANGELOG (Lines 3-18)
; ==============================================================================
; 
; FIND these lines at the top of the file:
; 
;   ; Version:     5.6 (AHK v2)
;   ; Updated:     2026-01-15
;
; REPLACE with:
;
;   ; Version:     5.7 (AHK v2)
;   ; Updated:     2026-01-15
;
; FIND this changelog block:
;
;   ; CHANGELOG v5.6:
;   ;   - Added "Quiet Mode" toggle...
;
; ADD THIS NEW BLOCK above it:
;
;   ; CHANGELOG v5.7:
;   ;   - NEW: "Capture First, Process Later" workflow
;   ;   - Removed AI choice dialog from YouTube capture flow
;   ;   - Captures NEVER fail due to Ollama being down
;   ;   - Added "sum" suffix for on-demand summarization
;   ;   - Type "capturenamesum" to summarize any capture when YOU want
;   ;   - Ollama errors no longer block captures
;   ;
;
; ==============================================================================
; CHANGE 2: SIMPLIFY THE YOUTUBE CAPTURE FLOW (Lines 3534-3590)
; ==============================================================================
;
; FIND this section (starting around line 3534):
;
;     ; Check if YouTube video - offer timestamp and transcript options
;     youtubeTranscript := ""
;     gotTranscript := false
;     if (RegExMatch(url, "i)youtube\.com/watch|youtube\.com/shorts|youtu\.be/")) {
;         ; Remove any existing timestamp from URL first
;         url := RegExReplace(url, "[?&]t=\d+", "")
;         
;         ; Offer transcript option first (for better note-taking)
;         ytResult := MsgBox("This is a YouTube video.`n`nWould you like to get the TRANSCRIPT first?`n`nThis helps you write better notes/opinions for sharing.`n`nYes = I'll get the transcript`nNo = Continue without transcript", "YouTube Video Detected 🎬", "YesNo")
;         
;         if (ytResult = "Yes") {
;             ; Open working transcript service
;             videoId := CC_GetYouTubeVideoId(url)
;             if (videoId != "") {
;                 transcriptUrl := "https://youtubetotranscript.com/transcript?v=" videoId
;                 Run(transcriptUrl)
;                 
;                 MsgBox("Transcript page opened!`n`n1. Wait for transcript to load`n2. Click 'Copy entire transcript' button (bottom left)`n3. Click OK when you have it copied", "Get YouTube Transcript 📝", "OK Iconi")
;             } else {
;                 MsgBox("Could not extract video ID.`n`nTry YouTube's built-in transcript:`n1. Click '...more' below the video`n2. Click 'Show transcript'`n3. Select all and copy", "Transcript", "OK Icon!")
;             }
;             gotTranscript := true
;             
;             ; Offer to send to AI for summarization
;             aiChoice := CC_ShowAIChoiceDialog()
;             
;             if (aiChoice = "chatgpt") {
;                 Run("https://chat.openai.com/")
;                 MsgBox("ChatGPT opened.`n`n1. Paste the transcript`n2. Ask: 'Summarize the key points of this video transcript'`n3. Copy the summary`n4. Click OK to continue capture`n`nThe summary will go in your Body field.", "ChatGPT Summary", "OK Iconi")
;             } else if (aiChoice = "claude") {
;                 Run("https://claude.ai/")
;                 MsgBox("Claude opened.`n`n1. Paste the transcript`n2. Ask: 'Summarize the key points of this video transcript'`n3. Copy the summary`n4. Click OK to continue capture`n`nThe summary will go in your Body field.", "Claude Summary", "OK Iconi")
;             } else if (aiChoice = "ollama") {
;                 ; Use local Ollama
;                 CC_SummarizeWithOllama()
;             }
;             ; If "skip", just use the raw transcript they already copied
;         }
;         
;         ; Then offer timestamp option
;         tsResult := MsgBox(...)
;
; REPLACE THE ENTIRE SECTION (from "Check if YouTube video" to just before "If user got transcript")
; WITH THIS NEW SIMPLIFIED VERSION:
;
; ==============================================================================

    ; =========================================================================
    ; SIMPLIFIED YOUTUBE FLOW v5.7 - No AI during capture
    ; =========================================================================
    ; Check if YouTube video - offer transcript option (NO AI during capture)
    gotTranscript := false
    if (RegExMatch(url, "i)youtube\.com/watch|youtube\.com/shorts|youtu\.be/")) {
        ; Remove any existing timestamp from URL first
        url := RegExReplace(url, "[?&]t=\d+", "")
        
        ; Offer transcript option (simplified - no AI choice)
        ytResult := MsgBox("This is a YouTube video.`n`nWould you like to get the TRANSCRIPT first?`n`nThis helps you write better notes/opinions for sharing.`n`nYes = Open transcript page`nNo = Continue without transcript", "YouTube Video Detected 🎬", "YesNo")
        
        if (ytResult = "Yes") {
            ; Open transcript service
            videoId := CC_GetYouTubeVideoId(url)
            if (videoId != "") {
                transcriptUrl := "https://youtubetotranscript.com/transcript?v=" videoId
                Run(transcriptUrl)
                
                MsgBox("Transcript page opened!`n`n1. Wait for transcript to load`n2. Click 'Copy entire transcript' button`n3. Click OK when you have it copied`n`n💡 Tip: Type 'capturenamesum' later to summarize!", "Get YouTube Transcript 📝", "OK Iconi")
            } else {
                MsgBox("Could not extract video ID.`n`nTry YouTube's built-in transcript:`n1. Click '...more' below the video`n2. Click 'Show transcript'`n3. Select all and copy", "Transcript", "OK Icon!")
            }
            gotTranscript := true
            
            ; =====================================================
            ; REMOVED: AI choice dialog
            ; User can summarize later with 'sum' suffix
            ; This prevents Ollama errors from blocking captures
            ; =====================================================
        }
        
        ; Timestamp option (unchanged)
        tsResult := MsgBox("Start video from the BEGINNING (recommended)`nor enter a specific start time?`n`nYes = Beginning`nNo = Enter timestamp", "YouTube Timestamp", "YesNo")
        
        if (tsResult = "No") {
            timestamp := InputBox("Enter start time:`n`nExamples: 1:30 (1m 30s) or 1:15:30 (1h 15m 30s)`n`nLeave blank for beginning.", "Start Time", "w300 h150").Value
            
            if (timestamp != "") {
                seconds := CC_ParseTimestamp(timestamp)
                if (seconds > 0) {
                    if InStr(url, "?")
                        url .= "&t=" seconds
                    else
                        url .= "?t=" seconds
                }
            }
        }
    }
    ; =========================================================================
    ; END OF SIMPLIFIED YOUTUBE FLOW
    ; =========================================================================

; ==============================================================================
; CHANGE 3: ADD "sum" TO SUFFIX DOCUMENTATION (Around line 249)
; ==============================================================================
;
; FIND this block in the hotstring suffix reference:
;
;   ; mt        Share to Mastodon           ::recipemt::
;
; ADD THIS LINE after it:
;
;   ; sum       Summarize with AI           ::recipesum::
;
; ==============================================================================
; CHANGE 4: UPDATE STARTUP NOTIFICATION (Around line 468)
; ==============================================================================
;
; FIND:
;   CC_Notify("ContentCapture Pro v5.6 loaded!`n" CaptureNames.Length " captures available.`nSmart paste detects social media limits!")
;
; REPLACE with:
;   CC_Notify("ContentCapture Pro v5.7 loaded!`n" CaptureNames.Length " captures available.`nType 'namesum' to summarize any capture!")
;
; ==============================================================================
; THAT'S IT! The changes are minimal but impactful.
; ==============================================================================
;
; SUMMARY OF CHANGES:
; 1. Version bump from 5.6 to 5.7
; 2. New changelog entry
; 3. Simplified YouTube capture flow (removes AI choice dialog)
; 4. Documentation update for 'sum' suffix
; 5. Updated startup notification
;
; The DynamicSuffixHandler.ahk file handles all the 'sum' suffix logic.
; Just replace that file entirely with the new version.
;
; ==============================================================================
; TESTING CHECKLIST:
; ==============================================================================
; [ ] Capture a YouTube video - should NOT show AI choice dialog
; [ ] Transcript is stored in capture body
; [ ] Type "capturenamesum " - should show AI choice dialog
; [ ] Test Ollama option (with Ollama running)
; [ ] Test Ollama option (with Ollama NOT running) - should show error, not crash
; [ ] Test ChatGPT/Claude options - should open browser and copy content
; [ ] Test "Copy only" option - should copy to clipboard
; [ ] Verify existing suffixes still work (go, em, fb, bs, etc.)
; ==============================================================================
