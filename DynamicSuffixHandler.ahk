#Requires AutoHotkey v2.0+

; ==============================================================================
; DynamicSuffixHandler.ahk - Dynamic Suffix Detection for ContentCapture Pro
; ==============================================================================
; Version:     2.2
; Updated:     2026-01-16
;
; CHANGELOG v2.2:
;   - Added "img" suffix for pasting attached images
;   - Uses IC_GetImagePath() from ImageCapture.ahk
;   - Pastes actual image (not path) into documents, social media, etc.
;
; CHANGELOG v2.1:
;   - Added "sum" suffix for on-demand AI summarization
;   - Implements "Capture First, Process Later" workflow
;   - Summarization no longer blocks captures - happens when YOU want
;
; CHANGELOG v2.0:
;   - Fixed all clipboard operations to use CC_SafePaste/CC_SafeCopy
;   - Clipboard is now properly cleared before setting content
;   - User's original clipboard is preserved and restored
;
; Monitors typing and intercepts suffix patterns dynamically instead of
; generating thousands of separate hotstring entries.
;
; Supported Suffixes (type scriptnameSUFFIX then space/enter):
;   em  → Email via Outlook
;   vi  → View/Edit in GUI
;   go  → Open URL in browser
;   rd  → Read content in MsgBox
;   sh  → Paste short version only (for comments/replies)
;   fb  → Share to Facebook
;   x   → Share to Twitter/X
;   bs  → Share to Bluesky
;   li  → Share to LinkedIn
;   mt  → Share to Mastodon
;   sum → Summarize with AI (on-demand)
;   img → Paste attached image (NEW)
;   yt  → YouTube Transcript (Research)
;   pp  → Perplexity AI (Research)
;   fc  → Fact Check - Snopes (Research)
;   mb  → Media Bias Check (Research)
;   wb  → Wayback Machine (Research)
;   gs  → Google Scholar (Research)
;   av  → Archive Page (Research)
;
; Usage: #Include this file and call DynamicSuffixHandler.Initialize(CaptureData, CaptureNames)
; ==============================================================================

class DynamicSuffixHandler {
    ; ==== CONFIGURATION ====
    static SUFFIX_MAP := Map(
        ; Core actions
        "em", "email",       ; Email via Outlook
        "vi", "view",        ; View/Edit in GUI
        "go", "openurl",     ; Open URL in browser
        "rd", "read",        ; Read in MsgBox
        "sh", "short",       ; Paste short version only
        ; Social media sharing
        "fb", "facebook",    ; Share to Facebook
        "x",  "twitter",     ; Share to Twitter/X
        "bs", "bluesky",     ; Share to Bluesky
        "li", "linkedin",    ; Share to LinkedIn
        "mt", "mastodon",    ; Share to Mastodon
        ; AI & Processing
        "sum", "summarize",  ; Summarize with AI (on-demand)
        ; Image
        "img", "pasteimage", ; Paste attached image (NEW v2.2)
        ; Research tools
        "yt", "transcript",  ; YouTube Transcript
        "pp", "perplexity",  ; Perplexity AI research
        "fc", "factcheck",   ; Fact check (Snopes)
        "mb", "mediabias",   ; Media Bias check
        "wb", "wayback",     ; Wayback Machine
        "gs", "scholar",     ; Google Scholar
        "av", "archive"      ; Archive.today
    )
    
    ; Character limits for social platforms
    static LIMIT_TWITTER := 280
    static LIMIT_BLUESKY := 300
    static LIMIT_LINKEDIN := 3000
    static LIMIT_MASTODON := 500
    
    ; Internal state
    static inputHook := ""
    static inputBuffer := ""
    static isEnabled := false
    static maxBufferLen := 80
    
    ; Reference to capture database
    static captureDataRef := ""
    static captureNamesRef := ""
    
    ; ==== INITIALIZATION ====
    static Initialize(captureDataMap := "", captureNamesArray := "") {
        if (this.isEnabled)
            return true
        
        ; Store references
        if (captureDataMap != "")
            this.captureDataRef := captureDataMap
        if (captureNamesArray != "")
            this.captureNamesRef := captureNamesArray
        
        ; Create InputHook to monitor typing
        this.inputHook := InputHook("V I1")
        this.inputHook.KeyOpt("{All}", "N")
        this.inputHook.OnChar := ObjBindMethod(this, "OnCharTyped")
        this.inputHook.OnKeyDown := ObjBindMethod(this, "OnKeyDown")
        this.inputHook.Start()
        
        this.isEnabled := true
        return true
    }
    
    static Stop() {
        if (this.inputHook && this.isEnabled) {
            this.inputHook.Stop()
            this.isEnabled := false
        }
    }
    
    static SetCaptureData(dataMap, namesArray := "") {
        this.captureDataRef := dataMap
        if (namesArray != "")
            this.captureNamesRef := namesArray
    }
    
    ; ==== INPUT MONITORING ====
    static OnCharTyped(ih, char) {
        ; Check if this is an ending character (triggers hotstring check)
        endingChars := " `t`n.,;:!?)-]}"
        
        if InStr(endingChars, char) {
            ; Check for suffix pattern before adding char
            this.CheckForSuffixPattern(char)
        }
        
        ; Add character to buffer
        this.inputBuffer .= char
        
        ; Keep buffer at reasonable length
        if (StrLen(this.inputBuffer) > this.maxBufferLen)
            this.inputBuffer := SubStr(this.inputBuffer, -(this.maxBufferLen // 2))
    }
    
    static OnKeyDown(ih, vk, sc) {
        ; Clear buffer on Enter, Escape, Tab
        if (vk = 13 || vk = 27 || vk = 9)
            this.inputBuffer := ""
        
        ; Handle backspace
        if (vk = 8 && StrLen(this.inputBuffer) > 0)
            this.inputBuffer := SubStr(this.inputBuffer, 1, -1)
    }
    
    ; ==== PATTERN DETECTION ====
    static CheckForSuffixPattern(endingChar) {
        buffer := this.inputBuffer
        
        if (StrLen(buffer) < 3)
            return
        
        ; Check each suffix - research suffixes, sum, and img (others handled by generated hotstrings)
        ; Added "img" for image pasting (v2.2)
        suffixesByLen := ["sum", "img", "yt", "pp", "fc", "mb", "wb", "gs", "av"]
        
        for suffix in suffixesByLen {
            if (!this.SUFFIX_MAP.Has(suffix))
                continue
            
            action := this.SUFFIX_MAP[suffix]
            suffixLen := StrLen(suffix)
            
            ; Check if buffer ends with this suffix
            if (StrLen(buffer) >= suffixLen) {
                bufferEnd := SubStr(buffer, -suffixLen)
                
                if (bufferEnd = suffix) {
                    ; Get potential capture name (everything before suffix)
                    potentialName := SubStr(buffer, 1, StrLen(buffer) - suffixLen)
                    
                    ; Remove any leading non-word characters
                    potentialName := RegExReplace(potentialName, "^[^\w]+", "")
                    
                    ; Check if this is a valid capture name
                    if (this.captureDataRef != "" && this.captureDataRef.Has(potentialName)) {
                        ; Clear buffer and execute action
                        this.inputBuffer := ""
                        
                        ; Delete the typed text (name + suffix + ending char)
                        deleteLen := StrLen(potentialName) + suffixLen + 1
                        Send("{BS " deleteLen "}")
                        Sleep(50)
                        
                        ; Execute the action
                        this.ExecuteAction(potentialName, action)
                        return
                    }
                }
            }
        }
    }
    
    ; ==== ACTION EXECUTION ====
    static ExecuteAction(name, action) {
        if (!this.captureDataRef.Has(name))
            return
        
        capture := this.captureDataRef[name]
        
        switch action {
            ; Core actions
            case "email":
                this.ActionEmail(name, capture)
            case "view":
                this.ActionView(name, capture)
            case "openurl":
                this.ActionOpenURL(name, capture)
            case "read":
                this.ActionRead(name, capture)
            case "short":
                this.ActionShort(name, capture)
            ; Social media
            case "facebook":
                this.ActionFacebook(name, capture)
            case "twitter":
                this.ActionTwitter(name, capture)
            case "bluesky":
                this.ActionBluesky(name, capture)
            case "linkedin":
                this.ActionLinkedIn(name, capture)
            case "mastodon":
                this.ActionMastodon(name, capture)
            ; AI & Processing
            case "summarize":
                this.ActionSummarize(name, capture)
            ; Image (NEW v2.2)
            case "pasteimage":
                this.ActionPasteImage(name, capture)
            ; Research tools - delegate to ResearchTools class
            case "transcript", "perplexity", "factcheck", "mediabias", "wayback", "scholar", "archive":
                if IsSet(ResearchTools)
                    ResearchTools.ExecuteAction(action, name, capture)
        }
    }
    
    ; ==== INDIVIDUAL ACTIONS ====
    
    static BuildContent(capture) {
        ; Check for short version first (for social media)
        if (capture.Has("short") && capture["short"] != "") {
            return capture["short"]
        }
        
        content := ""
        
        if (capture.Has("title") && capture["title"] != "")
            content .= capture["title"]
        
        if (capture.Has("url") && capture["url"] != "")
            content .= (content != "" ? "`n" : "") . capture["url"]
        
        if (capture.Has("opinion") && capture["opinion"] != "")
            content .= (content != "" ? "`n`n" : "") . capture["opinion"]
        
        if (capture.Has("body") && capture["body"] != "")
            content .= (content != "" ? "`n`n" : "") . capture["body"]
        
        return content
    }
    
    static ActionEmail(name, capture) {
        content := this.BuildContent(capture)
        subject := capture.Has("title") ? capture["title"] : name
        
        if (StrLen(subject) > 100)
            subject := SubStr(subject, 1, 97) . "..."
        
        this.SendOutlookEmail(subject, content)
    }
    
    static SendOutlookEmail(subject, body) {
        try {
            outlook := ComObject("Outlook.Application")
            mail := outlook.CreateItem(0)
            mail.Subject := subject
            mail.Body := body
            mail.Display()
        } catch as err {
            MsgBox("Failed to create email:`n" . err.Message, "Email Error", "48")
        }
    }
    
    static ActionView(name, capture) {
        ; Call the main edit function if it exists
        if IsSet(CC_ShowEditDialog)
            CC_ShowEditDialog(name)
        else
            MsgBox("Edit function not available", "Error", "48")
    }
    
    static ActionOpenURL(name, capture) {
        url := capture.Has("url") ? capture["url"] : ""
        if (url != "")
            Run(url)
        else
            MsgBox("No URL found for '" name "'", "No URL", "48")
    }
    
    static ActionRead(name, capture) {
        content := this.BuildContent(capture)
        title := capture.Has("title") ? capture["title"] : name
        MsgBox(content, "📖 " title, "0")
    }
    
    static ActionShort(name, capture) {
        ; Paste exactly what's in the short field - nothing added
        if (capture.Has("short") && capture["short"] != "") {
            CC_SafePaste(capture["short"])
        } else {
            ; No short version - notify user
            TrayTip("No short version saved for '" name "'`nEdit capture to add one.", "No Short Version", "2")
        }
    }
    
    ; ==============================================================================
    ; ActionPasteImage - Paste attached image (NEW in v2.2)
    ; ==============================================================================
    ; PURPOSE: Paste an attached image directly into documents, social media, etc.
    ; USAGE: Type "capturenameimg " to paste the image
    ; ==============================================================================
    
    static ActionPasteImage(name, capture) {
        ; Get image path using IC_GetImagePath from ImageCapture.ahk
        imgPath := ""
        
        if IsSet(IC_GetImagePath) {
            imgPath := IC_GetImagePath(name)
        }
        
        ; Fallback: check capture data directly
        if (imgPath = "") {
            if (capture.Has("image") && capture["image"] != "")
                imgPath := capture["image"]
            else if (capture.Has("img") && capture["img"] != "")
                imgPath := capture["img"]
        }
        
        if (imgPath = "") {
            TrayTip("No image attached to '" name "'", "No Image 📷", "2")
            return
        }
        
        ; Check if file exists
        if !FileExist(imgPath) {
            MsgBox("Image file not found:`n" imgPath, "Image Not Found", "48")
            return
        }
        
        ; Load image to clipboard using PowerShell and paste
        try {
            ; Escape backslashes for PowerShell
            psPath := StrReplace(imgPath, "\", "\\")
            psPath := StrReplace(psPath, "'", "''")
            
            psScript := "Add-Type -AssemblyName System.Windows.Forms; Add-Type -AssemblyName System.Drawing; $img = [System.Drawing.Image]::FromFile('" psPath "'); [System.Windows.Forms.Clipboard]::SetImage($img); $img.Dispose()"
            
            RunWait('powershell -NoProfile -WindowStyle Hidden -Command "' psScript '"',, "Hide")
            
            ; Small delay to ensure clipboard is ready
            Sleep(150)
            
            ; Paste the image
            Send("^v")
            
            TrayTip("Image pasted!", name " 📷", "1")
        } catch as err {
            MsgBox("Failed to paste image:`n" err.Message, "Image Error", "48")
        }
    }
    
    ; ==============================================================================
    ; ActionSummarize - On-demand AI summarization
    ; ==============================================================================
    
    static ActionSummarize(name, capture) {
        ; Get content to summarize (prefer transcript, fall back to body)
        content := ""
        if (capture.Has("transcript") && capture["transcript"] != "")
            content := capture["transcript"]
        else if (capture.Has("body") && capture["body"] != "")
            content := capture["body"]
        
        if (content = "") {
            MsgBox("No content to summarize in '" name "'.`n`nThis capture has no body text or transcript.", "No Content", "48")
            return
        }
        
        ; Show AI choice dialog
        choice := this.ShowSummarizeDialog(name, content)
        
        if (choice = "cancel")
            return
        
        if (choice = "chatgpt") {
            A_Clipboard := content
            Run("https://chat.openai.com/")
            MsgBox("Content copied to clipboard!`n`n1. Paste into ChatGPT (Ctrl+V)`n2. Ask: 'Summarize the key points'`n3. Copy the summary`n`n💡 Tip: Use Ctrl+Alt+A to access AI features for this capture.", "ChatGPT", "64")
            return
        }
        
        if (choice = "claude") {
            A_Clipboard := content
            Run("https://claude.ai/")
            MsgBox("Content copied to clipboard!`n`n1. Paste into Claude (Ctrl+V)`n2. Ask: 'Summarize the key points'`n3. Copy the summary`n`n💡 Tip: Use Ctrl+Alt+A to access AI features for this capture.", "Claude", "64")
            return
        }
        
        if (choice = "ollama") {
            this.DoOllamaSummarize(name, content)
            return
        }
        
        if (choice = "copy") {
            A_Clipboard := content
            TrayTip("Content copied!", "Ready to paste into any AI (" StrLen(content) " chars)", "1")
            return
        }
    }
    
    static ShowSummarizeDialog(name, content) {
        choice := ""
        
        sumGui := Gui("+AlwaysOnTop", "🤖 Summarize: " name)
        sumGui.BackColor := "1a1a2e"
        sumGui.SetFont("s11 cWhite", "Segoe UI")
        
        ; Preview
        preview := StrLen(content) > 200 ? SubStr(content, 1, 200) "..." : content
        sumGui.Add("Text", "x20 y15 w400", "Content preview:")
        sumGui.SetFont("s9 cBBBBBB")
        sumGui.Add("Edit", "x20 y40 w400 h80 ReadOnly Background2d2d44 cWhite", preview)
        
        sumGui.SetFont("s10 cWhite")
        sumGui.Add("Text", "x20 y130 w400", "Choose how to summarize (" StrLen(content) " characters):")
        
        ; Buttons
        btnChatGPT := sumGui.Add("Button", "x20 y160 w130 h35", "🟢 ChatGPT")
        btnClaude := sumGui.Add("Button", "x160 y160 w130 h35", "🟠 Claude")
        btnOllama := sumGui.Add("Button", "x300 y160 w120 h35", "🔵 Ollama")
        
        btnCopy := sumGui.Add("Button", "x20 y205 w200 h30", "📋 Copy Content Only")
        btnCancel := sumGui.Add("Button", "x230 y205 w90 h30", "Cancel")
        
        ; Status for Ollama
        sumGui.SetFont("s8 c888888")
        sumGui.Add("Text", "x20 y245 w400", "Ollama = 100% local & private (requires: ollama serve)")
        
        ; Events
        btnChatGPT.OnEvent("Click", (*) => (choice := "chatgpt", sumGui.Destroy()))
        btnClaude.OnEvent("Click", (*) => (choice := "claude", sumGui.Destroy()))
        btnOllama.OnEvent("Click", (*) => (choice := "ollama", sumGui.Destroy()))
        btnCopy.OnEvent("Click", (*) => (choice := "copy", sumGui.Destroy()))
        btnCancel.OnEvent("Click", (*) => (choice := "cancel", sumGui.Destroy()))
        sumGui.OnEvent("Escape", (*) => (choice := "cancel", sumGui.Destroy()))
        sumGui.OnEvent("Close", (*) => (choice := "cancel", sumGui.Destroy()))
        
        sumGui.Show("w440 h275")
        WinWaitClose(sumGui.Hwnd)
        
        return choice
    }
    
    static DoOllamaSummarize(name, content) {
        global AIOllamaURL, AIModel, CaptureData
        
        ; Show progress
        progressGui := Gui("+AlwaysOnTop -Caption +Border", "Processing...")
        progressGui.SetFont("s12")
        progressGui.BackColor := "1a1a2e"
        progressGui.SetFont("cWhite")
        progressGui.Add("Text", "x20 y20 w280", "🔄 Summarizing with Ollama...")
        progressGui.Add("Text", "x20 y50 w280 cGray", "This may take 15-30 seconds...")
        progressGui.Show("w320 h90")
        
        try {
            ; Build the prompt
            prompt := "Summarize the key points of this content in a concise format suitable for social media sharing. Use bullet points for clarity:`n`n" content
            
            ; Get Ollama URL from global or use default
            ollamaUrl := IsSet(AIOllamaURL) ? AIOllamaURL : "http://localhost:11434"
            url := ollamaUrl "/api/generate"
            
            ; Get model from global or use default
            model := (IsSet(AIModel) && AIModel != "") ? AIModel : "llama2"
            body := '{"model": "' model '", "prompt": "' this.EscapeJSON(prompt) '", "stream": false}'
            
            http := ComObject("WinHttp.WinHttpRequest.5.1")
            http.Open("POST", url, false)
            http.SetRequestHeader("Content-Type", "application/json")
            http.Send(body)
            
            if (http.Status = 200) {
                response := http.ResponseText
                
                ; Extract the response text
                if RegExMatch(response, '"response"\s*:\s*"([^"]*(?:\\"[^"]*)*)"', &match) {
                    summary := match[1]
                    summary := StrReplace(summary, "\n", "`n")
                    summary := StrReplace(summary, '\"', '"')
                    
                    progressGui.Destroy()
                    
                    ; Ask what to do with summary
                    saveResult := MsgBox("Summary generated!`n`n" SubStr(summary, 1, 300) (StrLen(summary) > 300 ? "..." : "") "`n`nSave to this capture's 'short' field?`n`nYes = Save & Copy`nNo = Copy only", "Ollama Summary ✅", "YesNoCancel 64")
                    
                    if (saveResult = "Yes") {
                        ; Save to capture
                        if (IsSet(CaptureData) && CaptureData.Has(StrLower(name))) {
                            CaptureData[StrLower(name)]["short"] := summary
                            if IsSet(CC_SaveCaptureData)
                                CC_SaveCaptureData()
                            TrayTip("Summary saved!", "Also copied to clipboard", "1")
                        }
                        A_Clipboard := summary
                    } else if (saveResult = "No") {
                        A_Clipboard := summary
                        TrayTip("Summary copied!", "Ready to paste", "1")
                    }
                    ; Cancel = do nothing
                    
                } else {
                    throw Error("Could not parse Ollama response")
                }
            } else {
                throw Error("HTTP " http.Status)
            }
        } catch as err {
            progressGui.Destroy()
            MsgBox("Ollama summarization failed:`n`n" err.Message "`n`nMake sure Ollama is running locally:`n  ollama serve`n`nOr use ChatGPT/Claude instead.", "Ollama Error ❌", "48")
        }
    }
    
    static EscapeJSON(str) {
        str := StrReplace(str, "\", "\\")
        str := StrReplace(str, '"', '\"')
        str := StrReplace(str, "`n", "\n")
        str := StrReplace(str, "`r", "\r")
        str := StrReplace(str, "`t", "\t")
        return str
    }
    
    ; ==== SOCIAL MEDIA HANDLERS ====
    
    static ActionFacebook(name, capture) {
        hasShort := capture.Has("short") && capture["short"] != ""
        content := this.BuildContent(capture)
        CC_SafeCopy(content)
        
        url := capture.Has("url") ? capture["url"] : ""
        ; Only use sharer URL if NOT using short version
        if (!hasShort && url != "") {
            shareURL := "https://www.facebook.com/sharer/sharer.php?u=" . this.URLEncode(url)
            Run(shareURL)
        } else {
            Run("https://www.facebook.com/")
        }
        
        TrayTip("Content copied! Paste with Ctrl+V", "Facebook Share", "1")
    }
    
    static ActionTwitter(name, capture) {
        ; Check if using short version (already contains URL if needed)
        hasShort := capture.Has("short") && capture["short"] != ""
        content := this.BuildContent(capture)
        url := capture.Has("url") ? capture["url"] : ""
        
        ; Check character limit
        tweetText := content
        if (StrLen(tweetText) > this.LIMIT_TWITTER - 25)  ; Leave room for URL
            tweetText := SubStr(tweetText, 1, this.LIMIT_TWITTER - 28) . "..."
        
        shareURL := "https://twitter.com/intent/tweet?"
        if (tweetText != "")
            shareURL .= "text=" . this.URLEncode(tweetText)
        
        ; Only add URL parameter if NOT using short version (short already has URL if needed)
        if (!hasShort && url != "")
            shareURL .= "&url=" . this.URLEncode(url)
        
        Run(shareURL)
    }
    
    static ActionBluesky(name, capture) {
        ; Check if short version exists first
        if (capture.Has("short") && capture["short"] != "") {
            ; Use short version directly - no warning needed
            content := capture["short"]
            CC_SafePaste(content)
            TrayTip("Short version pasted (" StrLen(content) "/" this.LIMIT_BLUESKY " chars)", "Bluesky", "1")
            return
        }
        
        ; Build full content
        content := this.BuildContent(capture)
        charCount := StrLen(content)
        
        ; If under limit, just paste
        if (charCount <= this.LIMIT_BLUESKY) {
            CC_SafePaste(content)
            TrayTip("Content pasted (" charCount "/" this.LIMIT_BLUESKY " chars)", "Bluesky", "1")
            return
        }
        
        ; OVER LIMIT - Show warning/edit dialog
        this.ShowSocialEditDialog(name, capture, "Bluesky", this.LIMIT_BLUESKY, content)
    }
    
    ; Generic social media edit dialog for over-limit content
    static ShowSocialEditDialog(name, capture, platform, charLimit, content) {
        charCount := StrLen(content)
        
        editGui := Gui("+AlwaysOnTop", "⚠️ " platform " - Over Character Limit")
        editGui.SetFont("s10")
        editGui.BackColor := "FFFFF0"
        
        ; Warning header
        editGui.SetFont("s11 cCC0000 bold")
        editGui.Add("Text", "x15 y10 w450", "⚠️ Content exceeds " platform "'s " charLimit " character limit!")
        editGui.SetFont("s10 c000000 norm")
        editGui.Add("Text", "x15 y35 w450", "Current: " charCount " chars (over by " (charCount - charLimit) ")")
        
        ; Editable content
        editGui.Add("Text", "x15 y60 w450", "Edit your content below:")
        contentEdit := editGui.Add("Edit", "x15 y80 w450 h150 Multi vEditContent", content)
        
        ; Live character counter
        counterColor := "CC0000"
        editGui.Add("Text", "x15 y235 w200 vCharCounter c" counterColor, charCount "/" charLimit " chars")
        
        ; Update counter on change
        contentEdit.OnEvent("Change", (*) => this.UpdateCharCounter(editGui, charLimit))
        
        ; Buttons
        editGui.Add("Button", "x15 y260 w100 h30", "✂️ Auto-Trim").OnEvent("Click", (*) => this.AutoTrimContent(editGui, capture, charLimit))
        
        saveCheck := editGui.Add("Checkbox", "x130 y265 w180 vSaveShort", "Save as Short Version")
        
        editGui.Add("Button", "x320 y260 w70 h30 Default", "Share").OnEvent("Click", (*) => this.DoSocialShare(editGui, name, platform, charLimit))
        editGui.Add("Button", "x395 y260 w70 h30", "Cancel").OnEvent("Click", (*) => editGui.Destroy())
        
        editGui.OnEvent("Escape", (*) => editGui.Destroy())
        editGui.Show("w480 h305")
    }
    
    static UpdateCharCounter(gui, limit) {
        try {
            content := gui["EditContent"].Value
            count := StrLen(content)
            color := count <= limit ? "008800" : "CC0000"
            gui["CharCounter"].Value := count "/" limit " chars"
            ; Can't change color dynamically easily, but the text updates
        }
    }
    
    static AutoTrimContent(gui, capture, limit) {
        ; Get URL to preserve
        url := capture.Has("url") ? capture["url"] : ""
        urlLen := StrLen(url)
        
        ; Start with title + URL if they fit
        title := capture.Has("title") ? capture["title"] : ""
        
        if (url != "" && urlLen + StrLen(title) + 2 <= limit) {
            ; Title + newline + URL fits
            gui["EditContent"].Value := title "`n" url
        } else if (url != "" && urlLen + 50 <= limit) {
            ; Truncate title to fit with URL
            maxTitleLen := limit - urlLen - 5  ; Leave room for newline and "..."
            if (StrLen(title) > maxTitleLen)
                title := SubStr(title, 1, maxTitleLen) "..."
            gui["EditContent"].Value := title "`n" url
        } else if (url != "") {
            ; Just URL
            gui["EditContent"].Value := url
        } else {
            ; No URL, truncate content
            content := gui["EditContent"].Value
            gui["EditContent"].Value := SubStr(content, 1, limit - 3) "..."
        }
        
        this.UpdateCharCounter(gui, limit)
    }
    
    static DoSocialShare(gui, name, platform, limit) {
        saved := gui.Submit()
        content := saved.EditContent
        saveShort := saved.SaveShort
        
        ; Final check
        if (StrLen(content) > limit) {
            result := MsgBox("Content is still " StrLen(content) " chars (limit: " limit ").`n`nShare anyway (will be truncated)?", "Still Over Limit", "YesNo Icon!")
            if (result = "No")
                return
            content := SubStr(content, 1, limit - 3) "..."
        }
        
        ; Save as short version if checked
        if (saveShort) {
            global CaptureData
            if (CaptureData.Has(StrLower(name))) {
                CaptureData[StrLower(name)]["short"] := content
                if IsSet(CC_SaveCaptureData)
                    CC_SaveCaptureData()
                TrayTip("Short version saved for future use!", name, "1")
            }
        }
        
        ; Paste the content using safe paste
        gui.Destroy()
        CC_SafePaste(content)
    }
    
    static ActionLinkedIn(name, capture) {
        hasShort := capture.Has("short") && capture["short"] != ""
        content := this.BuildContent(capture)
        url := capture.Has("url") ? capture["url"] : ""
        
        CC_SafeCopy(content)
        
        ; Only use share URL if NOT using short version
        if (!hasShort && url != "") {
            shareURL := "https://www.linkedin.com/sharing/share-offsite/?url=" . this.URLEncode(url)
            Run(shareURL)
        } else {
            Run("https://www.linkedin.com/feed/")
        }
        
        TrayTip("Content copied! Paste with Ctrl+V", "LinkedIn Share", "1")
    }
    
    static ActionMastodon(name, capture) {
        content := this.BuildContent(capture)
        
        if (StrLen(content) > this.LIMIT_MASTODON)
            content := SubStr(content, 1, this.LIMIT_MASTODON - 3) . "..."
        
        CC_SafeCopy(content)
        TrayTip("Content copied! Paste into your Mastodon instance", "Mastodon Share", "1")
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
}
