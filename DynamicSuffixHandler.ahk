#Requires AutoHotkey v2.0+

; ==============================================================================
; DynamicSuffixHandler.ahk - Dynamic Suffix Detection for ContentCapture Pro
; ==============================================================================
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
        
        ; Check each suffix - ONLY research suffixes (others handled by generated hotstrings)
        suffixesByLen := ["yt", "pp", "fc", "mb", "wb", "gs", "av"]
        
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
            A_Clipboard := capture["short"]
            ClipWait(1)
            SendInput("^v")
        } else {
            ; No short version - notify user
            TrayTip("No short version saved for '" name "'`nEdit capture to add one.", "No Short Version", "2")
        }
    }
    
    static ActionFacebook(name, capture) {
        hasShort := capture.Has("short") && capture["short"] != ""
        content := this.BuildContent(capture)
        A_Clipboard := content
        
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
            A_Clipboard := content
            ClipWait(1)
            SendInput("^v")
            TrayTip("Short version pasted (" StrLen(content) "/" this.LIMIT_BLUESKY " chars)", "Bluesky", "1")
            return
        }
        
        ; Build full content
        content := this.BuildContent(capture)
        charCount := StrLen(content)
        
        ; If under limit, just paste
        if (charCount <= this.LIMIT_BLUESKY) {
            A_Clipboard := content
            ClipWait(1)
            SendInput("^v")
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
        
        ; Paste the content
        A_Clipboard := content
        ClipWait(1)
        SendInput("^v")
        
        gui.Destroy()
    }
    
    static ActionLinkedIn(name, capture) {
        hasShort := capture.Has("short") && capture["short"] != ""
        content := this.BuildContent(capture)
        url := capture.Has("url") ? capture["url"] : ""
        
        A_Clipboard := content
        
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
        
        A_Clipboard := content
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
