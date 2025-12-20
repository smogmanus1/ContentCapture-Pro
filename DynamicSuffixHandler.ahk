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
;   fb  → Share to Facebook
;   x   → Share to Twitter/X
;   bs  → Share to Bluesky
;   li  → Share to LinkedIn
;   mt  → Share to Mastodon
;
; Usage: #Include this file and call DynamicSuffixHandler.Initialize(CaptureData, CaptureNames)
; ==============================================================================

class DynamicSuffixHandler {
    ; ==== CONFIGURATION ====
    static SUFFIX_MAP := Map(
        "em", "email",       ; Email via Outlook
        "vi", "view",        ; View/Edit in GUI
        "go", "openurl",     ; Open URL in browser
        "rd", "read",        ; Read in MsgBox
        "fb", "facebook",    ; Share to Facebook
        "x",  "twitter",     ; Share to Twitter/X
        "bs", "bluesky",     ; Share to Bluesky
        "li", "linkedin",    ; Share to LinkedIn
        "mt", "mastodon"     ; Share to Mastodon
    )
    
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
        endingChars := " `t`n.,;:!?)]-"
        
        if InStr(endingChars, char) {
            ; Check buffer for suffix match BEFORE adding the ending char
            this.CheckForSuffixMatch()
            this.inputBuffer := ""  ; Reset after trigger
        } else {
            ; Add character to buffer
            this.inputBuffer .= char
            
            ; Trim buffer if too long
            if (StrLen(this.inputBuffer) > this.maxBufferLen)
                this.inputBuffer := SubStr(this.inputBuffer, -this.maxBufferLen)
        }
    }
    
    static OnKeyDown(ih, vk, sc) {
        ; Handle special keys that should reset buffer
        resetKeys := [8, 27, 13, 9]  ; Backspace, Escape, Enter, Tab
        
        if (vk = 8) {  ; Backspace
            if (StrLen(this.inputBuffer) > 0)
                this.inputBuffer := SubStr(this.inputBuffer, 1, -1)
        } else if (vk = 27) {  ; Escape
            this.inputBuffer := ""
        } else if (vk = 13 || vk = 9) {  ; Enter or Tab
            this.CheckForSuffixMatch()
            this.inputBuffer := ""
        }
    }
    
    ; ==== SUFFIX DETECTION ====
    static CheckForSuffixMatch() {
        if (this.inputBuffer = "" || !this.captureDataRef)
            return
        
        buffer := StrLower(this.inputBuffer)
        
        ; Check each suffix (longest first for specificity)
        for suffix, action in this.SUFFIX_MAP {
            suffixLen := StrLen(suffix)
            
            ; Check if buffer ends with this suffix
            if (StrLen(buffer) > suffixLen && SubStr(buffer, -suffixLen) = suffix) {
                ; Extract potential capture name (everything before suffix)
                potentialName := SubStr(buffer, 1, StrLen(buffer) - suffixLen)
                
                ; Check if this is a valid capture name
                if (this.captureDataRef.Has(potentialName)) {
                    ; Found a match! Execute the action
                    this.ExecuteAction(potentialName, action)
                    return
                }
            }
        }
    }
    
    ; ==== ACTION EXECUTION ====
    static ExecuteAction(name, action) {
        ; Calculate how many characters to delete (name + suffix + ending char)
        ; The ending character was already typed, so we need to remove it too
        
        capture := this.captureDataRef[name]
        
        ; Get the suffix length that matched
        for suffix, act in this.SUFFIX_MAP {
            if (act = action) {
                deleteLen := StrLen(name) + StrLen(suffix) + 1  ; +1 for ending char
                break
            }
        }
        
        ; Delete the typed text
        Send("{BS " deleteLen "}")
        Sleep(50)
        
        ; Execute the appropriate action
        switch action {
            case "email":
                this.ActionEmail(name, capture)
            case "view":
                this.ActionView(name, capture)
            case "openurl":
                this.ActionOpenURL(name, capture)
            case "read":
                this.ActionRead(name, capture)
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
        }
    }
    
    ; ==== INDIVIDUAL ACTIONS ====
    
    static ActionEmail(name, capture) {
        ; Build email content
        content := ""
        
        if (capture.Has("title") && capture["title"] != "")
            content .= capture["title"] . "`r`n`r`n"
        
        if (capture.Has("url") && capture["url"] != "")
            content .= capture["url"] . "`r`n`r`n"
        
        if (capture.Has("body") && capture["body"] != "")
            content .= capture["body"]
        
        ; Get subject line
        subject := capture.Has("title") ? capture["title"] : name
        if (StrLen(subject) > 100)
            subject := SubStr(subject, 1, 97) . "..."
        
        ; Send via Outlook
        this.SendOutlookEmail(subject, content)
    }
    
    static SendOutlookEmail(subject, body) {
        try {
            outlook := ComObject("Outlook.Application")
            mail := outlook.CreateItem(0)  ; 0 = olMailItem
            mail.Subject := subject
            mail.Body := body
            mail.Display()  ; Show email for review before sending
        } catch as err {
            MsgBox("Failed to create email:`n" . err.Message, "Email Error", 16)
        }
    }
    
    static ActionView(name, capture) {
        ; Call the main ContentCapture Pro edit function
        if IsSet(CC_EditCapture)
            CC_EditCapture(name)
        else
            MsgBox("View/Edit function not available", "Error", 16)
    }
    
    static ActionOpenURL(name, capture) {
        if (capture.Has("url") && capture["url"] != "") {
            try {
                Run(capture["url"])
            } catch as err {
                MsgBox("Failed to open URL:`n" . err.Message, "Error", 16)
            }
        } else {
            MsgBox("No URL saved for '" . name . "'", "No URL", 48)
        }
    }
    
    static ActionRead(name, capture) {
        ; Call the main ContentCapture Pro read function
        if IsSet(CC_ShowReadWindow)
            CC_ShowReadWindow(name)
        else {
            ; Fallback: simple MsgBox
            content := "=== " . name . " ===`n`n"
            
            if (capture.Has("title") && capture["title"] != "")
                content .= "Title: " . capture["title"] . "`n`n"
            
            if (capture.Has("url") && capture["url"] != "")
                content .= "URL: " . capture["url"] . "`n`n"
            
            if (capture.Has("body") && capture["body"] != "")
                content .= capture["body"]
            
            MsgBox(content, name, 0)
        }
    }
    
    static ActionFacebook(name, capture) {
        url := capture.Has("url") ? capture["url"] : ""
        if (url != "") {
            Run("https://www.facebook.com/sharer/sharer.php?u=" . this.UrlEncode(url))
            
            ; Also copy full content to clipboard
            content := this.BuildShareContent(capture)
            A_Clipboard := content
            TrayTip("Content copied! Paste into Facebook.", "Facebook Share", "1")
        } else {
            MsgBox("No URL to share for '" . name . "'", "No URL", 48)
        }
    }
    
    static ActionTwitter(name, capture) {
        title := capture.Has("title") ? capture["title"] : ""
        url := capture.Has("url") ? capture["url"] : ""
        
        ; Twitter has 280 char limit, so keep it short
        tweetText := title
        if (StrLen(tweetText) > 200)
            tweetText := SubStr(tweetText, 1, 197) . "..."
        
        if (url != "")
            tweetText .= " " . url
        
        Run("https://twitter.com/intent/tweet?text=" . this.UrlEncode(tweetText))
    }
    
    static ActionBluesky(name, capture) {
        title := capture.Has("title") ? capture["title"] : ""
        url := capture.Has("url") ? capture["url"] : ""
        
        postText := title
        if (StrLen(postText) > 250)
            postText := SubStr(postText, 1, 247) . "..."
        
        if (url != "")
            postText .= " " . url
        
        Run("https://bsky.app/intent/compose?text=" . this.UrlEncode(postText))
    }
    
    static ActionLinkedIn(name, capture) {
        url := capture.Has("url") ? capture["url"] : ""
        if (url != "") {
            Run("https://www.linkedin.com/sharing/share-offsite/?url=" . this.UrlEncode(url))
        } else {
            MsgBox("No URL to share for '" . name . "'", "No URL", 48)
        }
    }
    
    static ActionMastodon(name, capture) {
        title := capture.Has("title") ? capture["title"] : ""
        url := capture.Has("url") ? capture["url"] : ""
        
        postText := title
        if (url != "")
            postText .= " " . url
        
        ; Mastodon doesn't have a universal share URL, so copy to clipboard
        A_Clipboard := postText
        TrayTip("Content copied! Paste into Mastodon.", "Mastodon Share", "1")
    }
    
    ; ==== HELPER FUNCTIONS ====
    
    static BuildShareContent(capture) {
        content := ""
        
        if (capture.Has("title") && capture["title"] != "")
            content .= capture["title"] . "`r`n`r`n"
        
        if (capture.Has("url") && capture["url"] != "")
            content .= capture["url"] . "`r`n`r`n"
        
        if (capture.Has("opinion") && capture["opinion"] != "")
            content .= capture["opinion"] . "`r`n`r`n"
        
        if (capture.Has("body") && capture["body"] != "")
            content .= capture["body"]
        
        return RTrim(content, "`r`n")
    }
    
    static UrlEncode(str) {
        encoded := ""
        for char in StrSplit(str) {
            code := Ord(char)
            if (code >= 48 && code <= 57)       ; 0-9
                || (code >= 65 && code <= 90)   ; A-Z
                || (code >= 97 && code <= 122)  ; a-z
                || InStr("-_.~", char)
                encoded .= char
            else if (code <= 127)
                encoded .= Format("%{:02X}", code)
            else {
                ; Handle UTF-8 multi-byte
                buf := Buffer(4)
                len := StrPut(char, buf, "UTF-8") - 1
                loop len
                    encoded .= Format("%{:02X}", NumGet(buf, A_Index - 1, "UChar"))
            }
        }
        return encoded
    }
}
