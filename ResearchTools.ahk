#Requires AutoHotkey v2.0+

; ==============================================================================
; ResearchTools.ahk - Research & Verification Toolkit for ContentCapture Pro
; ==============================================================================
; Adds research and fact-checking capabilities via:
;   1. GUI dropdown menu in Capture Browser
;   2. Dynamic suffix shortcuts (yt, fc, pp, mb, wb, gs, av)
;   3. Auto-append research notes to captures
;
; Tools included:
;   - YouTube Transcript (yt) - Extract video transcripts for AI analysis
;   - Perplexity AI (pp) - AI-powered research
;   - Fact Check (fc) - Search Snopes for fact verification
;   - Media Bias (mb) - Check source credibility ratings
;   - Wayback Machine (wb) - View archived versions
;   - Google Scholar (gs) - Find academic sources
;   - Archive Page (av) - Save page to Archive.today
;
; Usage: #Include this file and call ResearchTools.AddToSuffixMap()
; ==============================================================================

class ResearchTools {
    
    ; Research tool definitions
    static TOOLS := Map(
        "yt", Map("name", "🎬 YouTube Transcript", "desc", "Get transcript for AI analysis", "action", "transcript"),
        "pp", Map("name", "🔍 Perplexity AI", "desc", "Research with AI", "action", "perplexity"),
        "fc", Map("name", "✓ Fact Check (Snopes)", "desc", "Search fact-checkers", "action", "factcheck"),
        "mb", Map("name", "📊 Media Bias Check", "desc", "Check source credibility", "action", "mediabias"),
        "wb", Map("name", "🕐 Wayback Machine", "desc", "View archived versions", "action", "wayback"),
        "gs", Map("name", "📚 Google Scholar", "desc", "Find academic sources", "action", "scholar"),
        "av", Map("name", "💾 Archive This Page", "desc", "Save to Archive.today", "action", "archive")
    )
    
    ; Store current research context
    static CurrentCapture := ""
    static CurrentTool := ""
    
    ; ==== SUFFIX MAP INTEGRATION ====
    ; Call this to add research suffixes to DynamicSuffixHandler
    static AddToSuffixMap(suffixMap) {
        for suffix, tool in this.TOOLS {
            suffixMap[suffix] := tool["action"]
        }
        return suffixMap
    }
    
    ; ==== GUI INTEGRATION ====
    ; Creates the Research dropdown button - call from ShowCaptureBrowser
    static CreateResearchButton(browserGui, xPos, yPos, listView) {
        btn := browserGui.Add("Button", "x" xPos " y" yPos " w75", "🔬 Research")
        btn.OnEvent("Click", (*) => this.ShowResearchMenu(browserGui, listView))
        return btn
    }
    
    ; Shows the research tools popup menu
    static ShowResearchMenu(browserGui, listView) {
        ; Get selected capture
        row := listView.GetNext(0, "F")
        if (row = 0) {
            MsgBox("Select a capture first.", "No Selection", "48")
            return
        }
        
        name := listView.GetText(row, 3)  ; Column 3 is Name (after star and image columns)
        
        ; Create popup menu
        researchMenu := Menu()
        
        ; Add each tool to menu
        researchMenu.Add("🎬 YouTube Transcript", (*) => this.OpenTranscript(name))
        researchMenu.Add("🔍 Perplexity AI", (*) => this.OpenPerplexity(name))
        researchMenu.Add()  ; Separator
        researchMenu.Add("✓ Fact Check (Snopes)", (*) => this.OpenFactCheck(name))
        researchMenu.Add("📊 Media Bias Check", (*) => this.OpenMediaBias(name))
        researchMenu.Add()  ; Separator
        researchMenu.Add("🕐 Wayback Machine", (*) => this.OpenWayback(name))
        researchMenu.Add("📚 Google Scholar", (*) => this.OpenScholar(name))
        researchMenu.Add()  ; Separator
        researchMenu.Add("💾 Archive This Page", (*) => this.ArchivePage(name))
        researchMenu.Add()  ; Separator
        researchMenu.Add("📝 Add Research Note...", (*) => this.ShowAddNoteDialog(name))
        
        ; Show menu at mouse position
        researchMenu.Show()
    }
    
    ; ==== TOOL IMPLEMENTATIONS ====
    
    ; Get capture data helper
    static GetCaptureData(name) {
        global CaptureData
        if !CaptureData.Has(name)
            return ""
        return CaptureData[name]
    }
    
    ; Get URL from capture
    static GetCaptureURL(name) {
        cap := this.GetCaptureData(name)
        if !cap
            return ""
        return cap.Has("url") ? cap["url"] : ""
    }
    
    ; Get title from capture
    static GetCaptureTitle(name) {
        cap := this.GetCaptureData(name)
        if !cap
            return name
        return cap.Has("title") ? cap["title"] : name
    }
    
    ; Extract domain from URL
    static GetDomain(url) {
        if RegExMatch(url, "i)https?://(?:www\.)?([^/]+)", &match)
            return match[1]
        return ""
    }
    
    ; ---- YouTube Transcript ----
    static OpenTranscript(name) {
        url := this.GetCaptureURL(name)
        
        ; Check if it's a YouTube URL (including Shorts)
        if !RegExMatch(url, "i)(youtube\.com/watch|youtube\.com/shorts|youtu\.be/)", &match) {
            MsgBox("'" name "' doesn't contain a YouTube URL.`n`nThis tool only works with YouTube videos.", "Not a YouTube Video", "48")
            return
        }
        
        ; Store context for potential note
        this.CurrentCapture := name
        this.CurrentTool := "YouTube Transcript"
        
        ; Copy URL to clipboard for easy pasting
        CC_SafeCopy(url)
        
        ; Open transcript site
        Run("https://youtubetotranscript.com/")
        
        ; Wait for page to load, then auto-paste
        Sleep(2500)
        
        ; Paste the URL into the input field
        Send("^v")
        
        ; Small delay then press Enter to submit
        Sleep(300)
        Send("{Enter}")
        
        ; Offer to add note after delay
        SetTimer(() => this.OfferResearchNote(name, "YouTube Transcript"), -5000)
        
        this.ShowToolTip("YouTube URL pasted! Getting transcript...", 3000)
    }
    
    ; ---- Perplexity AI Research ----
    static OpenPerplexity(name) {
        title := this.GetCaptureTitle(name)
        url := this.GetCaptureURL(name)
        
        this.CurrentCapture := name
        this.CurrentTool := "Perplexity AI"
        
        ; Create search query from title (clean it up)
        query := RegExReplace(title, "i)\s*[-|]\s*(YouTube|Facebook|Twitter|X).*$", "")
        query := StrReplace(query, '"', "")
        query := Trim(query)
        
        if (query = "")
            query := name
        
        ; URL encode the query
        encodedQuery := this.URLEncode(query)
        
        ; Open Perplexity with the query
        Run("https://www.perplexity.ai/search?q=" encodedQuery)
        
        SetTimer(() => this.OfferResearchNote(name, "Perplexity AI"), -8000)
        
        this.ShowToolTip("Researching: " SubStr(query, 1, 50) "...", 3000)
    }
    
    ; ---- Fact Check (Snopes) ----
    static OpenFactCheck(name) {
        title := this.GetCaptureTitle(name)
        
        this.CurrentCapture := name
        this.CurrentTool := "Snopes Fact Check"
        
        ; Extract key terms from title
        query := RegExReplace(title, "i)\s*[-|]\s*(YouTube|Facebook|Twitter|X).*$", "")
        query := RegExReplace(query, "i)^\(\d+\)\s*", "")  ; Remove notification counts
        query := Trim(query)
        
        if (query = "")
            query := name
        
        encodedQuery := this.URLEncode(query)
        
        ; Search Snopes
        Run("https://www.snopes.com/?s=" encodedQuery)
        
        ; Offer quick note options after delay
        SetTimer(() => this.OfferFactCheckNote(name), -6000)
        
        this.ShowToolTip("Searching Snopes for fact checks...", 3000)
    }
    
    ; ---- Media Bias Check ----
    static OpenMediaBias(name) {
        url := this.GetCaptureURL(name)
        domain := this.GetDomain(url)
        
        this.CurrentCapture := name
        this.CurrentTool := "Media Bias Check"
        
        if (domain = "") {
            MsgBox("Could not extract domain from URL.", "No Domain", "48")
            return
        }
        
        ; Search Media Bias Fact Check for this source
        encodedDomain := this.URLEncode(domain)
        Run("https://mediabiasfactcheck.com/?s=" encodedDomain)
        
        SetTimer(() => this.OfferBiasNote(name, domain), -6000)
        
        this.ShowToolTip("Checking bias rating for: " domain, 3000)
    }
    
    ; ---- Wayback Machine ----
    static OpenWayback(name) {
        url := this.GetCaptureURL(name)
        
        this.CurrentCapture := name
        this.CurrentTool := "Wayback Machine"
        
        if (url = "") {
            MsgBox("No URL found for this capture.", "No URL", "48")
            return
        }
        
        ; Open Wayback Machine with the URL
        encodedURL := this.URLEncode(url)
        Run("https://web.archive.org/web/*/" url)
        
        SetTimer(() => this.OfferResearchNote(name, "Wayback Machine"), -5000)
        
        this.ShowToolTip("Opening archived versions...", 3000)
    }
    
    ; ---- Google Scholar ----
    static OpenScholar(name) {
        title := this.GetCaptureTitle(name)
        
        this.CurrentCapture := name
        this.CurrentTool := "Google Scholar"
        
        ; Clean title for academic search
        query := RegExReplace(title, "i)\s*[-|]\s*(YouTube|Facebook|Twitter|X).*$", "")
        query := RegExReplace(query, "i)^\(\d+\)\s*", "")
        query := Trim(query)
        
        if (query = "")
            query := name
        
        encodedQuery := this.URLEncode(query)
        
        ; Search Google Scholar
        Run("https://scholar.google.com/scholar?q=" encodedQuery)
        
        SetTimer(() => this.OfferResearchNote(name, "Google Scholar"), -6000)
        
        this.ShowToolTip("Searching academic sources...", 3000)
    }
    
    ; ---- Archive Page ----
    static ArchivePage(name) {
        url := this.GetCaptureURL(name)
        
        this.CurrentCapture := name
        this.CurrentTool := "Archive.today"
        
        if (url = "") {
            MsgBox("No URL found for this capture.", "No URL", "48")
            return
        }
        
        ; Submit to Archive.today
        Run("https://archive.today/?run=1&url=" this.URLEncode(url))
        
        SetTimer(() => this.OfferArchiveNote(name), -8000)
        
        this.ShowToolTip("Archiving page to Archive.today...", 3000)
    }
    
    ; ==== RESEARCH NOTE FUNCTIONS ====
    
    ; Generic offer to add research note
    static OfferResearchNote(name, toolName) {
        result := MsgBox("Add a research note for '" name "'?`n`nTool used: " toolName, "📝 Add Research Note?", "YN Iconi T10")
        
        if (result = "Yes")
            this.ShowAddNoteDialog(name, toolName)
    }
    
    ; Fact check specific note dialog
    static OfferFactCheckNote(name) {
        noteGui := Gui("+AlwaysOnTop", "📝 Fact Check Result: " name)
        noteGui.SetFont("s10")
        noteGui.BackColor := "FFFFF0"
        
        noteGui.Add("Text", "x15 y10 w350", "What did Snopes say about this?")
        
        ; Quick buttons for common results
        noteGui.Add("Button", "x15 y40 w100 h30 BackgroundC8E6C9", "✓ TRUE").OnEvent("Click", (*) => (this.AppendResearchNote(name, "✓ Verified TRUE (Snopes) - " FormatTime(, "yyyy-MM-dd")), noteGui.Destroy()))
        noteGui.Add("Button", "x120 y40 w100 h30 BackgroundFFCDD2", "✗ FALSE").OnEvent("Click", (*) => (this.AppendResearchNote(name, "✗ Verified FALSE (Snopes) - " FormatTime(, "yyyy-MM-dd")), noteGui.Destroy()))
        noteGui.Add("Button", "x225 y40 w100 h30 BackgroundFFF9C4", "⚠ MIXED").OnEvent("Click", (*) => (this.AppendResearchNote(name, "⚠ MIXED/Partly True (Snopes) - " FormatTime(, "yyyy-MM-dd")), noteGui.Destroy()))
        
        noteGui.Add("Button", "x15 y80 w155 h25", "📝 Add Custom Note...").OnEvent("Click", (*) => (noteGui.Destroy(), this.ShowAddNoteDialog(name, "Snopes")))
        noteGui.Add("Button", "x175 y80 w155 h25", "Skip").OnEvent("Click", (*) => noteGui.Destroy())
        
        noteGui.OnEvent("Escape", (*) => noteGui.Destroy())
        noteGui.Show("w345 h120")
    }
    
    ; Media bias specific note dialog
    static OfferBiasNote(name, domain) {
        noteGui := Gui("+AlwaysOnTop", "📊 Bias Rating: " domain)
        noteGui.SetFont("s10")
        noteGui.BackColor := "FFFFF0"
        
        noteGui.Add("Text", "x15 y10 w400", "What bias rating did you find for " domain "?")
        
        ; Quick buttons for bias ratings
        noteGui.Add("Button", "x15 y40 w90 h28 BackgroundE3F2FD", "Left").OnEvent("Click", (*) => (this.AppendResearchNote(name, "📊 Source bias: LEFT (" domain ") - " FormatTime(, "yyyy-MM-dd")), noteGui.Destroy()))
        noteGui.Add("Button", "x110 y40 w90 h28 BackgroundE8F5E9", "Center-Left").OnEvent("Click", (*) => (this.AppendResearchNote(name, "📊 Source bias: CENTER-LEFT (" domain ") - " FormatTime(, "yyyy-MM-dd")), noteGui.Destroy()))
        noteGui.Add("Button", "x205 y40 w90 h28 BackgroundFFFDE7", "Center").OnEvent("Click", (*) => (this.AppendResearchNote(name, "📊 Source bias: CENTER (" domain ") - " FormatTime(, "yyyy-MM-dd")), noteGui.Destroy()))
        noteGui.Add("Button", "x300 y40 w90 h28 BackgroundFFF3E0", "Center-Right").OnEvent("Click", (*) => (this.AppendResearchNote(name, "📊 Source bias: CENTER-RIGHT (" domain ") - " FormatTime(, "yyyy-MM-dd")), noteGui.Destroy()))
        
        noteGui.Add("Button", "x15 y75 w90 h28 BackgroundFFEBEE", "Right").OnEvent("Click", (*) => (this.AppendResearchNote(name, "📊 Source bias: RIGHT (" domain ") - " FormatTime(, "yyyy-MM-dd")), noteGui.Destroy()))
        noteGui.Add("Button", "x110 y75 w90 h28 BackgroundF3E5F5", "Questionable").OnEvent("Click", (*) => (this.AppendResearchNote(name, "⚠️ Source: QUESTIONABLE (" domain ") - " FormatTime(, "yyyy-MM-dd")), noteGui.Destroy()))
        noteGui.Add("Button", "x205 y75 w90 h28 BackgroundE0E0E0", "Not Found").OnEvent("Click", (*) => (this.AppendResearchNote(name, "📊 Source not rated (" domain ") - " FormatTime(, "yyyy-MM-dd")), noteGui.Destroy()))
        noteGui.Add("Button", "x300 y75 w90 h28", "Skip").OnEvent("Click", (*) => noteGui.Destroy())
        
        noteGui.OnEvent("Escape", (*) => noteGui.Destroy())
        noteGui.Show("w405 h115")
    }
    
    ; Archive note dialog
    static OfferArchiveNote(name) {
        result := MsgBox("Page archived successfully?`n`nAdd archive link to research notes?", "📝 Archive Complete?", "YN Iconi T15")
        
        if (result = "Yes") {
            ; Prompt for archive URL
            InputGui := Gui("+AlwaysOnTop", "Enter Archive URL")
            InputGui.SetFont("s10")
            InputGui.Add("Text", "x15 y10 w350", "Paste the Archive.today URL:")
            urlEdit := InputGui.Add("Edit", "x15 y35 w350 h24 vArchiveURL")
            InputGui.Add("Button", "x15 y70 w100 h30", "Save").OnEvent("Click", (*) => (this.AppendResearchNote(name, "💾 Archived: " urlEdit.Value " - " FormatTime(, "yyyy-MM-dd")), InputGui.Destroy()))
            InputGui.Add("Button", "x125 y70 w100 h30", "Cancel").OnEvent("Click", (*) => InputGui.Destroy())
            InputGui.OnEvent("Escape", (*) => InputGui.Destroy())
            InputGui.Show("w380 h115")
        }
    }
    
    ; Show dialog to add custom research note
    static ShowAddNoteDialog(name, toolName := "") {
        global CaptureData
        
        if !CaptureData.Has(name) {
            MsgBox("Capture '" name "' not found.", "Error", "48")
            return
        }
        
        cap := CaptureData[name]
        currentResearch := cap.Has("research") ? cap["research"] : ""
        
        noteGui := Gui("+AlwaysOnTop +Resize", "📝 Research Notes: " name)
        noteGui.SetFont("s10")
        noteGui.BackColor := "FFFFF0"
        
        noteGui.Add("Text", "x15 y10 w450", "Add your research findings, verification results, or notes:")
        
        ; Show existing notes if any
        if (currentResearch != "") {
            noteGui.Add("Text", "x15 y35 w450 c666666", "Existing notes (new note will be appended):")
            noteGui.Add("Edit", "x15 y55 w450 h80 ReadOnly Background F5F5F5", currentResearch)
            yOffset := 150
        } else {
            yOffset := 40
        }
        
        ; Prefill with tool name and date if provided
        prefill := toolName != "" ? toolName " - " FormatTime(, "yyyy-MM-dd") ": " : ""
        
        noteGui.Add("Text", "x15 y" yOffset " w80", "New note:")
        noteEdit := noteGui.Add("Edit", "x15 y" (yOffset + 20) " w450 h80 Multi vNewNote", prefill)
        ; Auto-Format button - positioned next to "New note:" label
        formatBtn := noteGui.Add("Button", "x100 y" (yOffset - 2) " w100 h22", "🔧 Auto-Format")
        formatBtn.OnEvent("Click", (*) => CC_AutoFormatBody(noteEdit))
        
        ; Buttons
        btnY := yOffset + 110
        noteGui.Add("Button", "x15 y" btnY " w120 h35 BackgroundC8E6C9", "💾 Save Note").OnEvent("Click", (*) => (this.SaveResearchNote(name, noteEdit.Value, noteGui)))
        noteGui.Add("Button", "x145 y" btnY " w100 h35", "Cancel").OnEvent("Click", (*) => noteGui.Destroy())
        
        ; Quick insert buttons
        noteGui.Add("Text", "x270 y" btnY " w80 Right c888888", "Quick add:")
        noteGui.Add("Button", "x355 y" btnY " w50 h35 BackgroundC8E6C9", "✓").OnEvent("Click", (*) => (noteEdit.Value .= "✓ VERIFIED "))
        noteGui.Add("Button", "x410 y" btnY " w50 h35 BackgroundFFCDD2", "✗").OnEvent("Click", (*) => (noteEdit.Value .= "✗ FALSE "))
        
        noteGui.OnEvent("Escape", (*) => noteGui.Destroy())
        noteGui.Show("w480 h" (btnY + 50))
    }
    
    ; Save research note (replaces existing)
    static SaveResearchNote(name, note, gui) {
        global CaptureData
        
        if (Trim(note) = "") {
            gui.Destroy()
            return
        }
        
        if !CaptureData.Has(name)
            return
        
        cap := CaptureData[name]
        currentResearch := cap.Has("research") ? cap["research"] : ""
        
        ; Append new note to existing
        if (currentResearch != "")
            cap["research"] := currentResearch "`n" Trim(note)
        else
            cap["research"] := Trim(note)
        
        CaptureData[name] := cap
        
        ; Save to file
        if IsSet(CC_SaveCaptureData)
            CC_SaveCaptureData()
        
        gui.Destroy()
        TrayTip("Research note saved for '" name "'", "📝 Note Added", "1")
    }
    
    ; Append a quick research note
    static AppendResearchNote(name, note) {
        global CaptureData
        
        if !CaptureData.Has(name)
            return
        
        cap := CaptureData[name]
        currentResearch := cap.Has("research") ? cap["research"] : ""
        
        ; Append new note
        if (currentResearch != "")
            cap["research"] := currentResearch "`n" note
        else
            cap["research"] := note
        
        CaptureData[name] := cap
        
        ; Save to file
        if IsSet(CC_SaveCaptureData)
            CC_SaveCaptureData()
        
        TrayTip("Research note added for '" name "'", "📝 " note, "1")
    }
    
    ; ==== UTILITY FUNCTIONS ====
    
    static URLEncode(str) {
        encoded := ""
        for i, char in StrSplit(str) {
            if RegExMatch(char, "[a-zA-Z0-9_.-]")
                encoded .= char
            else if (char = " ")
                encoded .= "+"
            else
                encoded .= "%" Format("{:02X}", Ord(char))
        }
        return encoded
    }
    
    static ShowToolTip(msg, duration := 3000) {
        ToolTip(msg)
        SetTimer(() => ToolTip(), -duration)
    }
    
    ; ==== EXECUTE ACTION (for DynamicSuffixHandler integration) ====
    static ExecuteAction(action, captureName, captureData) {
        switch action {
            case "transcript":
                this.OpenTranscript(captureName)
            case "perplexity":
                this.OpenPerplexity(captureName)
            case "factcheck":
                this.OpenFactCheck(captureName)
            case "mediabias":
                this.OpenMediaBias(captureName)
            case "wayback":
                this.OpenWayback(captureName)
            case "scholar":
                this.OpenScholar(captureName)
            case "archive":
                this.ArchivePage(captureName)
            default:
                return false
        }
        return true
    }
}
