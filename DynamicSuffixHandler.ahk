; ==============================================================================
; DynamicSuffixHandler.ahk - Dynamic Suffix Detection for ContentCapture Pro
; ==============================================================================
; Version:     1.0
; Author:      Brad (with Claude AI assistance)
; License:     MIT
;
; Instead of generating thousands of suffix variants (scriptem, scriptgo, etc.),
; this module monitors typing and intercepts suffix patterns dynamically.
;
; Supported Suffixes (type ::scriptnameSUFFIX::):
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
; The base hotstring (::scriptname::) and action menu (::scriptname?::) 
; are still generated statically for reliability.
;
; Usage: #Include this file and call DynamicSuffixHandler.Initialize()
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
        this.inputBuffer .= char
        
        if (StrLen(this.inputBuffer) > this.maxBufferLen)
            this.inputBuffer := SubStr(this.inputBuffer, -(this.maxBufferLen // 2))
        
        ; Check for patterns when : is typed (end of hotstring)
        if (char = ":")
            this.CheckForSuffixPattern()
    }
    
    static OnKeyDown(ih, vk, sc) {
        ; Clear buffer on Enter, Escape, Tab
        if (vk = 13 || vk = 27 || vk = 9)
            this.inputBuffer := ""
    }
    
    ; ==== PATTERN DETECTION ====
    static CheckForSuffixPattern() {
        buffer := this.inputBuffer
        
        if (StrLen(buffer) < 6)
            return
        
        ; Check each suffix (longest first to avoid partial matches)
        suffixesByLen := ["mt", "bs", "li", "fb", "em", "vi", "go", "rd", "x"]
        
        for suffix in suffixesByLen {
            if (!this.SUFFIX_MAP.Has(suffix))
                continue
                
            action := this.SUFFIX_MAP[suffix]
            
            ; Pattern: ::name{suffix}::
            pattern := "::(\w+)" . suffix . "::$"
            
            if (RegExMatch(buffer, pattern, &match)) {
                baseName := match[1]
                
                ; Verify this capture exists
                if (this.CaptureExists(baseName)) {
                    ; Erase the typed hotstring
                    this.EraseTypedText(StrLen(match[0]))
                    
                    ; Execute action
                    this.ExecuteAction(baseName, action)
                    
                    this.inputBuffer := ""
                    return
                }
            }
        }
    }
    
    ; ==== CAPTURE LOOKUP ====
    static CaptureExists(name) {
        nameLower := StrLower(name)
        
        ; Check our stored reference
        if (this.captureDataRef != "" && this.captureDataRef.Has(nameLower))
            return true
        
        ; Check global CaptureData if it exists
        if (IsSet(CaptureData) && CaptureData.Has(nameLower))
            return true
            
        ; Check CaptureNames array
        if (this.captureNamesRef != "") {
            for n in this.captureNamesRef {
                if (StrLower(n) = nameLower)
                    return true
            }
        }
        
        ; Check global CaptureNames
        if (IsSet(CaptureNames)) {
            for n in CaptureNames {
                if (StrLower(n) = nameLower)
                    return true
            }
        }
        
        return false
    }
    
    static GetCapture(name) {
        nameLower := StrLower(name)
        
        if (this.captureDataRef != "" && this.captureDataRef.Has(nameLower))
            return this.captureDataRef[nameLower]
        
        if (IsSet(CaptureData) && CaptureData.Has(nameLower))
            return CaptureData[nameLower]
        
        return ""
    }
    
    ; ==== TEXT MANIPULATION ====
    static EraseTypedText(charCount) {
        Send("{BS " . charCount . "}")
    }
    
    ; ==== ACTION EXECUTION ====
    static ExecuteAction(name, action) {
        ; Get capture data
        capture := this.GetCapture(name)
        if (capture = "")
            return
        
        switch action {
            case "email":
                this.DoEmail(name, capture)
            case "view":
                this.DoView(name, capture)
            case "openurl":
                this.DoOpenURL(name, capture)
            case "read":
                this.DoRead(name, capture)
            case "facebook":
                this.DoFacebook(name, capture)
            case "twitter":
                this.DoTwitter(name, capture)
            case "bluesky":
                this.DoBluesky(name, capture)
            case "linkedin":
                this.DoLinkedIn(name, capture)
            case "mastodon":
                this.DoMastodon(name, capture)
        }
    }
    
    ; ==== ACTION IMPLEMENTATIONS ====
    static DoEmail(name, capture) {
        ; Use the main script's email function if available
        if (IsSet(CC_HotstringEmail)) {
            CC_HotstringEmail(name)
        } else {
            content := this.BuildContent(capture)
            try {
                ol := ComObject("Outlook.Application")
                mail := ol.CreateItem(0)
                mail.Body := content
                mail.Display()
            } catch as e {
                MsgBox("Could not open Outlook: " . e.Message, "Email Error", "Icon!")
            }
        }
    }
    
    static DoView(name, capture) {
        ; Use the main script's view function if available
        if (IsSet(CC_ShowReadWindow)) {
            CC_ShowReadWindow(name)
        } else {
            this.DoRead(name, capture)
        }
    }
    
    static DoOpenURL(name, capture) {
        if (capture.Has("url") && capture["url"] != "") {
            try Run(capture["url"])
        } else {
            MsgBox("No URL found for '" . name . "'", "No URL", "Icon!")
        }
    }
    
    static DoRead(name, capture) {
        content := ""
        
        if (capture.Has("title") && capture["title"] != "")
            content .= capture["title"] . "`n`n"
        
        if (capture.Has("url") && capture["url"] != "")
            content .= capture["url"] . "`n`n"
        
        if (capture.Has("body") && capture["body"] != "")
            content .= capture["body"]
        
        if (content = "")
            content := "(No content)"
        
        MsgBox(content, "📖 " . name, 0)
    }
    
    static DoFacebook(name, capture) {
        if (IsSet(CC_HotstringFacebook)) {
            CC_HotstringFacebook(name)
        } else {
            content := this.BuildContent(capture)
            this.ShareToSocial("facebook", content)
        }
    }
    
    static DoTwitter(name, capture) {
        if (IsSet(CC_HotstringTwitter)) {
            CC_HotstringTwitter(name)
        } else {
            content := this.BuildContent(capture)
            this.ShareToSocial("twitter", content)
        }
    }
    
    static DoBluesky(name, capture) {
        if (IsSet(CC_HotstringBluesky)) {
            CC_HotstringBluesky(name)
        } else {
            content := this.BuildContent(capture)
            this.ShareToSocial("bluesky", content)
        }
    }
    
    static DoLinkedIn(name, capture) {
        if (IsSet(CC_HotstringLinkedIn)) {
            CC_HotstringLinkedIn(name)
        } else {
            content := this.BuildContent(capture)
            this.ShareToSocial("linkedin", content)
        }
    }
    
    static DoMastodon(name, capture) {
        if (IsSet(CC_HotstringMastodon)) {
            CC_HotstringMastodon(name)
        } else {
            content := this.BuildContent(capture)
            this.ShareToSocial("mastodon", content)
        }
    }
    
    ; ==== HELPER FUNCTIONS ====
    static BuildContent(capture) {
        content := ""
        
        if (capture.Has("title") && capture["title"] != "")
            content .= capture["title"] . "`n`n"
        
        if (capture.Has("url") && capture["url"] != "")
            content .= capture["url"] . "`n`n"
        
        if (capture.Has("opinion") && capture["opinion"] != "")
            content .= capture["opinion"] . "`n`n"
        
        if (capture.Has("body") && capture["body"] != "")
            content .= capture["body"]
        
        return Trim(content)
    }
    
    static ShareToSocial(platform, content) {
        ; Generic share - copy to clipboard and open platform
        A_Clipboard := content
        ClipWait(1)
        
        urls := Map(
            "facebook", "https://www.facebook.com/",
            "twitter", "https://twitter.com/compose/tweet",
            "bluesky", "https://bsky.app/",
            "linkedin", "https://www.linkedin.com/feed/",
            "mastodon", "https://mastodon.social/"
        )
        
        if (urls.Has(platform)) {
            try Run(urls[platform])
            TrayTip("Content copied! Paste with Ctrl+V", platform . " Share", "1")
        }
    }
}
