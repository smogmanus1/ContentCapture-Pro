#Requires AutoHotkey v2.0+

; ==============================================================================
; DynamicSuffixHandler.ahk - Dynamic Suffix Detection for ContentCapture Pro
; ==============================================================================
; Version:     2.7
; Author:      Brad (with Claude AI assistance)
; License:     MIT
;
; CHANGELOG v2.7:
;   - ENHANCED: ActionSocial now checks for attached images via SocialImageShare.ahk
;     When a record has an attached image, user is prompted to include it in the post
;   - Works across ALL platforms: Facebook, Twitter/X, Bluesky, LinkedIn, Mastodon
;   - ActionSocialWithImage updated to use SI_SharePost for real clipboard image paste
;   - Content building extracted to _BuildSocialContent helper to avoid duplication
;   - Zero change to behavior when no image is attached or SocialImageShare.ahk not loaded
;
; CHANGELOG v2.6:
;   - CRITICAL FIX: Removed all suffix entries that overlap with static hotstrings
;     in ContentCapture_Generated.ahk. Both systems were firing on the same input,
;     causing double backspaces, clipboard corruption, and script death.
;   - DSH now ONLY handles suffixes that have NO static hotstring equivalent
;   - Static hotstrings (Generated file) handle: base, ?, t, url, body, cp, i, ti,
;     sh, em, go, rd, vi, d., ed, pr, oi, fb, x, bs, li, mt
;   - DSH handles ONLY: u, fbi, xi, bsi, lii, mti, img, imgo, sum, yt, pp, fc,
;     mb, wb, gs, av
;   - FIXED: ShowSocialEditWindow now properly suspends/resumes hotstrings
;
; CHANGELOG v2.5:
;   - FIXED: ActionSocial ignored the "short" field entirely - x/bs/mt suffixes
;     always built content from opinion+title+url instead of using the short version
;     that was specifically designed for character-limited platforms
;   - Short version is now used as primary content for social sharing when available
;   - URL is automatically appended if not already present and fits within limit
;
; CHANGELOG v2.4:
;   - FIXED: Initialize() early-return guard skipped updating captureDataRef/captureNamesRef
;     when already enabled, so re-initialization after edit/save used stale data
;
; CHANGELOG v2.3:
;   - FIXED: DSH_SafePaste was calling itself (infinite recursion) - now correctly calls CC_SafePaste
;   - FIXED: DSH_SafeCopy was calling itself (infinite recursion) - now correctly calls CC_SafeCopy  
;   - FIXED: DSH_UrlEncode had wrong function names - corrected all references
;   - ADDED: ActionFacebook, ActionTwitter, ActionBluesky, ActionLinkedIn, ActionMastodon static methods
;   - ADDED: Proper clipboard cleanup in ActionCopy (clear before set)
;
; CHANGELOG v2.2:
;   - Added "u" suffix for pasting URL only (no title, no content)
;   - Perfect for dropping clean links into chats/texts
;
; CHANGELOG v2.1:
;   - Added "sum" suffix for on-demand AI summarization
;   - Implements "Capture First, Process Later" workflow
;
; CHANGELOG v2.0:
;   - Fixed all clipboard operations to use CC_SafePaste/CC_SafeCopy
;   - Clipboard is now properly cleared before setting content
;   - User's original clipboard is preserved and restored
;
; Monitors typing and intercepts suffix patterns dynamically instead of
; generating thousands of separate hotstring entries.
;
; NOTE: Most suffixes are handled by static hotstrings in ContentCapture_Generated.ahk
; DSH only handles these EXTRA suffixes (type scriptnameSUFFIX then space/enter):
;   u   → Paste URL only
;   fbi → Share to Facebook + image
;   xi  → Share to Twitter/X + image
;   bsi → Share to Bluesky + image
;   lii → Share to LinkedIn + image
;   mti → Share to Mastodon + image
;   img → Copy image to clipboard as bitmap
;   imgo→ Open attached image
;   sum → Summarize with AI (on-demand)
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
    ; ONLY suffixes that do NOT have static hotstrings in ContentCapture_Generated.ahk
    ; The Generated file handles: (base), ?, t, url, body, cp, i, ti, sh, em, go, rd, vi, d., ed, pr, oi, fb, x, bs, li, mt
    ; DSH handles ONLY these extras (no overlap = no double-fire):
    static SUFFIX_MAP := Map(
        ; URL only (not in Generated)
        "u",   "url",

        ; Social media with image (not in Generated)
        "fbi", "facebookimg",
        "xi",  "twitterimg",
        "bsi", "blueskyimg",
        "lii", "linkedinimg",
        "mti", "mastodonimg",
        
        ; Image actions (img/imgo not in Generated - note: i and ti ARE in Generated)
        "img",  "copyimage",
        "imgo", "openimage",
        
        ; AI actions (not in Generated)
        "sum", "summarize",
        
        ; Research tools (not in Generated)
        "yt",  "transcript",
        "pp",  "perplexity",
        "fc",  "factcheck",
        "mb",  "mediabias",
        "wb",  "wayback",
        "gs",  "scholar",
        "av",  "archive"
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
        ; Always update data references, even if already running
        if (captureDataMap != "")
            this.captureDataRef := captureDataMap
        if (captureNamesArray != "")
            this.captureNamesRef := captureNamesArray
        
        if (this.isEnabled)
            return true
        
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
        ; Check if this is an ending character (triggers hotstring)
        endingChars := " `t`n.,;:!?()[]{}'" . '"<>/@#$%^&*-=+\|'
        
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
        
        ; Check suffixes in order of length (longest first) to avoid partial matches
        ; Sort suffixes by length descending
        suffixList := []
        for suffix, action in this.SUFFIX_MAP {
            suffixList.Push({suffix: suffix, action: action, len: StrLen(suffix)})
        }
        
        ; Sort by length descending (bubble sort for simplicity)
        loop suffixList.Length - 1 {
            i := A_Index
            loop suffixList.Length - i {
                j := A_Index + i - 1
                if (suffixList[j].len < suffixList[j + 1].len) {
                    temp := suffixList[j]
                    suffixList[j] := suffixList[j + 1]
                    suffixList[j + 1] := temp
                }
            }
        }
        
        ; Check each suffix
        for item in suffixList {
            suffix := item.suffix
            action := item.action
            suffixLen := StrLen(suffix)
            
            ; Check if buffer ends with this suffix
            if (StrLen(buffer) > suffixLen) {
                bufferEnd := SubStr(buffer, -(suffixLen - 1))  ; Get last N characters
                if (bufferEnd = suffix) {
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
    }
    
    ; ==== ACTION EXECUTION ====
    static ExecuteAction(captureName, action) {
        ; Erase the typed text (name + suffix)
        cap := this.captureDataRef[captureName]
        suffix := ""
        for s, a in this.SUFFIX_MAP {
            if (a = action) {
                suffix := s
                break
            }
        }
        eraseLen := StrLen(captureName) + StrLen(suffix)
        SendInput("{Backspace " eraseLen "}")
        Sleep(50)
        
        switch action {
            ; === CORE ACTIONS ===
            case "url":
                this.ActionURL(captureName)
            case "email":
                this.ActionEmail(captureName)
            case "outlookinsert":
                this.ActionOutlookInsert(captureName)
            case "view":
                ; Call the full Edit GUI (same as old static hotstring behavior)
                if IsSet(CC_EditCapture)
                    CC_EditCapture(captureName)
                else
                    this.ActionView(captureName)  ; Fallback to MsgBox if standalone
            case "openurl":
                this.ActionOpenURL(captureName)
            case "read":
                this.ActionRead(captureName)
            case "short":
                this.ActionShort(captureName)
            case "title":
                this.ActionTitle(captureName)
            case "copy":
                this.ActionCopy(captureName)
            case "print":
                this.ActionPrint(captureName)
            
            ; === SOCIAL MEDIA (TEXT ONLY) ===
            case "facebook":
                this.ActionSocial(captureName, "facebook")
            case "twitter":
                this.ActionSocial(captureName, "twitter")
            case "bluesky":
                this.ActionSocial(captureName, "bluesky")
            case "linkedin":
                this.ActionSocial(captureName, "linkedin")
            case "mastodon":
                this.ActionSocial(captureName, "mastodon")
            
            ; === SOCIAL MEDIA WITH IMAGE ===
            case "facebookimg":
                this.ActionSocialWithImage(captureName, "facebook")
            case "twitterimg":
                this.ActionSocialWithImage(captureName, "twitter")
            case "blueskyimg":
                this.ActionSocialWithImage(captureName, "bluesky")
            case "linkedinimg":
                this.ActionSocialWithImage(captureName, "linkedin")
            case "mastodonimg":
                this.ActionSocialWithImage(captureName, "mastodon")
            
            ; === IMAGE ACTIONS ===
            case "imagepath":
                this.ActionImagePath(captureName)
            case "copyimage":
                this.ActionCopyImage(captureName)
            case "openimage":
                this.ActionOpenImage(captureName)
            case "titleimage":
                this.ActionTitleImage(captureName)
            case "opendoc":
                this.ActionOpenDoc(captureName)
            case "emaildoc":
                this.ActionEmailDoc(captureName)
            
            ; === AI ACTIONS ===
            case "summarize":
                this.ActionSummarize(captureName)
            
            ; === RESEARCH TOOLS ===
            case "transcript":
                this.ActionResearch(captureName, "transcript")
            case "perplexity":
                this.ActionResearch(captureName, "perplexity")
            case "factcheck":
                this.ActionResearch(captureName, "factcheck")
            case "mediabias":
                this.ActionResearch(captureName, "mediabias")
            case "wayback":
                this.ActionResearch(captureName, "wayback")
            case "scholar":
                this.ActionResearch(captureName, "scholar")
            case "archive":
                this.ActionResearch(captureName, "archive")
            
            default:
                TrayTip("Unknown suffix action: " action, "ContentCapture Pro")
        }
    }
    
    ; ==== CORE ACTION IMPLEMENTATIONS ====
    
    ; NEW: Paste URL only
    static ActionURL(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("url") && cap["url"] != "") {
            DSH_SafePaste(cap["url"])
        } else {
            TrayTip("No URL stored for '" captureName "'", "URL Not Found", "17")
        }
    }
    
    static ActionTitle(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("title") && cap["title"] != "") {
            DSH_SafePaste(cap["title"])
        } else {
            TrayTip("No title stored for '" captureName "'", "Title Not Found", "17")
        }
    }
    
    static ActionEmail(captureName) {
        cap := this.captureDataRef[captureName]
        subject := cap.Has("title") ? cap["title"] : captureName
        body := this.BuildFullContent(cap)
        
        try {
            outlookApp := ComObject("Outlook.Application")
            mail := outlookApp.CreateItem(0)
            mail.Subject := subject
            mail.Body := body
            mail.Display()
        } catch {
            TrayTip("Could not open Outlook", "Email Error", "17")
        }
    }
    
    static ActionOutlookInsert(captureName) {
        cap := this.captureDataRef[captureName]
        content := this.BuildFullContent(cap)
        DSH_SafePaste(content)
    }
    
    static ActionView(captureName) {
        cap := this.captureDataRef[captureName]
        
        ; Build display content
        display := "=== " captureName " ===`n`n"
        if cap.Has("title")
            display .= "Title: " cap["title"] "`n"
        if cap.Has("url")
            display .= "URL: " cap["url"] "`n"
        if cap.Has("tags")
            display .= "Tags: " cap["tags"] "`n"
        if cap.Has("date")
            display .= "Date: " cap["date"] "`n"
        if cap.Has("image")
            display .= "Image: " cap["image"] "`n"
        if cap.Has("doc")
            display .= "Doc: " cap["doc"] "`n"
        display .= "`n"
        if cap.Has("opinion")
            display .= "Opinion:`n" cap["opinion"] "`n`n"
        if cap.Has("body")
            display .= "Body:`n" cap["body"] "`n"
        if cap.Has("short")
            display .= "`nShort Version:`n" cap["short"] "`n"
        if cap.Has("note")
            display .= "`nPrivate Note:`n" cap["note"] "`n"
        
        MsgBox(display, "View: " captureName, "0")
    }
    
    static ActionOpenURL(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("url") && cap["url"] != "") {
            Run(cap["url"])
        } else {
            TrayTip("No URL stored for '" captureName "'", "URL Not Found", "17")
        }
    }
    
    static ActionRead(captureName) {
        cap := this.captureDataRef[captureName]
        content := this.BuildFullContent(cap)
        MsgBox(content, "Read: " captureName, "0")
    }
    
    static ActionShort(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("short") && cap["short"] != "") {
            DSH_SafePaste(cap["short"])
        } else {
            TrayTip("No short version for '" captureName "'", "Short Not Found", "17")
        }
    }
    
    ; FIXED: Now clears clipboard before setting content
    static ActionCopy(captureName) {
        cap := this.captureDataRef[captureName]
        content := this.BuildFullContent(cap)
        
        ; Clear clipboard before setting (prevents stale content issues)
        A_Clipboard := ""
        Sleep(50)
        A_Clipboard := content
        ClipWait(2)
        TrayTip("Content copied to clipboard!", captureName, "1")
    }
    
    static ActionPrint(captureName) {
        cap := this.captureDataRef[captureName]
        content := this.BuildFullContent(cap)
        
        ; Create temp file and print
        tempFile := A_Temp "\cc_print_" captureName ".txt"
        try {
            FileDelete(tempFile)
        }
        FileAppend(content, tempFile)
        Run("notepad /p " tempFile)
    }
    
    ; ==== SOCIAL MEDIA ACTIONS ====
    ; These static methods are called by ContentCapture-Pro.ahk CC_Hotstring* functions
    
    ; Wrapper for CC_HotstringFacebook
    static ActionFacebook(captureName, cap := "") {
        this.ActionSocial(captureName, "facebook")
    }
    
    ; Wrapper for CC_HotstringTwitter
    static ActionTwitter(captureName, cap := "") {
        this.ActionSocial(captureName, "twitter")
    }
    
    ; Wrapper for CC_HotstringBluesky
    static ActionBluesky(captureName, cap := "") {
        this.ActionSocial(captureName, "bluesky")
    }
    
    ; Wrapper for CC_HotstringLinkedIn
    static ActionLinkedIn(captureName, cap := "") {
        this.ActionSocial(captureName, "linkedin")
    }
    
    ; Wrapper for CC_HotstringMastodon
    static ActionMastodon(captureName, cap := "") {
        this.ActionSocial(captureName, "mastodon")
    }
    
    static ActionSocial(captureName, platform) {
        cap := this.captureDataRef[captureName]
        
        ; ── CHECK FOR ATTACHED IMAGE ──
        ; If SocialImageShare.ahk is loaded and record has an image, delegate to it
        if IsSet(SI_SharePost) {
            imgPath := ""
            try {
                if IsSet(IC_HasImage) && IC_HasImage(captureName) {
                    if IsSet(IC_GetImagePath)
                        imgPath := IC_GetImagePath(captureName)
                }
            }
            if (imgPath != "" && FileExist(imgPath)) {
                content := this._BuildSocialContent(cap, platform)
                url := cap.Has("url") && cap["url"] != "" ? cap["url"] : ""
                SI_SharePost(platform, captureName, cap, content, url)
                return
            }
        }
        
        ; ── STANDARD SHARING (no image or SocialImageShare not loaded) ──
        content := this._BuildSocialContent(cap, platform)
        
        limits := Map(
            "facebook", 63206,
            "twitter", 280,
            "bluesky", 300,
            "linkedin", 3000,
            "mastodon", 500
        )
        limit := limits.Has(platform) ? limits[platform] : 500
        
        ; Check length and either paste or show edit window
        if (StrLen(content) <= limit) {
            DSH_SafePaste(content)
        } else {
            ; Show edit window for trimming
            this.ShowSocialEditWindow(captureName, platform, content, limit)
        }
    }
    
    ; Helper: Build social content (used by both image and non-image paths)
    static _BuildSocialContent(cap, platform) {
        limits := Map(
            "facebook", 63206,
            "twitter", 280,
            "bluesky", 300,
            "linkedin", 3000,
            "mastodon", 500
        )
        limit := limits.Has(platform) ? limits[platform] : 500
        
        ; Use short version if available (designed for character-limited platforms)
        if (cap.Has("short") && cap["short"] != "") {
            content := cap["short"]
            ; Append URL if not already in short text and there's room
            if (cap.Has("url") && cap["url"] != "" && !InStr(content, cap["url"])) {
                withUrl := content "`n" cap["url"]
                if (StrLen(withUrl) <= limit)
                    content := withUrl
            }
        } else {
            ; Fallback: build from opinion + title + URL
            content := ""
            if (cap.Has("opinion") && cap["opinion"] != "")
                content .= cap["opinion"] "`n`n"
            if (cap.Has("title") && cap["title"] != "")
                content .= cap["title"] "`n"
            if (cap.Has("url") && cap["url"] != "")
                content .= cap["url"]
        }
        
        return Trim(content)
    }
    
    static ActionSocialWithImage(captureName, platform) {
        cap := this.captureDataRef[captureName]
        
        ; If SocialImageShare.ahk is loaded, use it for real clipboard image paste
        if IsSet(SI_SharePost) {
            content := this._BuildSocialContent(cap, platform)
            url := cap.Has("url") && cap["url"] != "" ? cap["url"] : ""
            SI_SharePost(platform, captureName, cap, content, url)
            return
        }
        
        ; Fallback: paste text content then image path
        this.ActionSocial(captureName, platform)
        
        if (cap.Has("image") && cap["image"] != "") {
            Sleep(100)
            DSH_SafePaste("`n" cap["image"])
        }
    }
    
    static ShowSocialEditWindow(captureName, platform, content, limit) {
        ; Create edit GUI for trimming content
        editGui := Gui("+Resize", platform " Share - " captureName)
        editGui.SetFont("s10", "Segoe UI")
        
        ; Suspend hotstrings while this edit window is open
        if IsSet(CC_SuspendHotstrings)
            CC_SuspendHotstrings()
        
        editGui.Add("Text",, "Content exceeds " limit " characters. Edit below:")
        editBox := editGui.Add("Edit", "w500 h300 vContent", content)
        
        charCount := editGui.Add("Text", "w500", "Characters: " StrLen(content) " / " limit)
        
        ; Update character count on change
        editBox.OnEvent("Change", (*) => charCount.Value := "Characters: " StrLen(editBox.Value) " / " limit)
        
        btnRow := editGui.Add("Button", "w100", "Paste")
        btnRow.OnEvent("Click", (*) => (DSH_SafePaste(editBox.Value), IsSet(CC_GuiCleanup) ? CC_GuiCleanup(editGui) : editGui.Destroy()))
        
        editGui.Add("Button", "x+10 w100", "Cancel").OnEvent("Click", (*) => IsSet(CC_GuiCleanup) ? CC_GuiCleanup(editGui) : editGui.Destroy())
        
        ; Resume hotstrings on close/escape
        if IsSet(CC_GuiCleanup) {
            editGui.OnEvent("Close", (*) => CC_GuiCleanup(editGui))
            editGui.OnEvent("Escape", (*) => CC_GuiCleanup(editGui))
        }
        
        editGui.Show()
    }
    
    ; ==== IMAGE ACTIONS ====
    
    static ActionImagePath(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("image") && cap["image"] != "") {
            DSH_SafePaste(cap["image"])
        } else {
            TrayTip("No image attached to '" captureName "'", "Image Not Found", "17")
        }
    }
    
    static ActionCopyImage(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("image") && cap["image"] != "" && FileExist(cap["image"])) {
            ; Use ImageClipboard if available
            if IsSet(ImageClipboard) {
                ImageClipboard.CopyToClipboard(cap["image"])
                TrayTip("Image copied to clipboard!", captureName, "1")
            } else {
                ; Fallback: just copy the path (with proper clear first)
                A_Clipboard := ""
                Sleep(50)
                A_Clipboard := cap["image"]
                ClipWait(2)
                TrayTip("Image path copied (ImageClipboard not loaded)", captureName, "1")
            }
        } else {
            TrayTip("No image attached to '" captureName "'", "Image Not Found", "17")
        }
    }
    
    static ActionOpenImage(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("image") && cap["image"] != "" && FileExist(cap["image"])) {
            Run(cap["image"])
        } else {
            TrayTip("No image attached to '" captureName "'", "Image Not Found", "17")
        }
    }
    
    static ActionTitleImage(captureName) {
        cap := this.captureDataRef[captureName]
        output := ""
        if cap.Has("title")
            output .= cap["title"] "`n"
        if (cap.Has("image") && cap["image"] != "")
            output .= cap["image"]
        
        if (output != "")
            DSH_SafePaste(output)
        else
            TrayTip("No title or image for '" captureName "'", "Not Found", "17")
    }
    
    static ActionOpenDoc(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("doc") && cap["doc"] != "" && FileExist(cap["doc"])) {
            Run(cap["doc"])
        } else {
            TrayTip("No document attached to '" captureName "'", "Document Not Found", "17")
        }
    }
    
    static ActionEmailDoc(captureName) {
        cap := this.captureDataRef[captureName]
        if (!cap.Has("doc") || cap["doc"] = "" || !FileExist(cap["doc"])) {
            TrayTip("No document attached to '" captureName "'", "Document Not Found", "17")
            return
        }
        
        subject := cap.Has("title") ? cap["title"] : captureName
        body := this.BuildFullContent(cap)
        
        try {
            outlookApp := ComObject("Outlook.Application")
            mail := outlookApp.CreateItem(0)
            mail.Subject := subject
            mail.Body := body
            mail.Attachments.Add(cap["doc"])
            mail.Display()
        } catch {
            TrayTip("Could not open Outlook", "Email Error", "17")
        }
    }
    
    ; ==== AI ACTIONS ====
    
    static ActionSummarize(captureName) {
        cap := this.captureDataRef[captureName]
        
        ; Check if ResearchTools is available
        if IsSet(ResearchTools) {
            ResearchTools.Summarize(captureName, cap)
        } else {
            ; Fallback: open in Perplexity
            if (cap.Has("url") && cap["url"] != "") {
                Run("https://www.perplexity.ai/search?q=summarize " cap["url"])
            } else {
                TrayTip("ResearchTools not loaded and no URL available", "Summarize Error", "17")
            }
        }
    }
    
    ; ==== RESEARCH ACTIONS ====
    
    static ActionResearch(captureName, tool) {
        cap := this.captureDataRef[captureName]
        url := cap.Has("url") ? cap["url"] : ""
        title := cap.Has("title") ? cap["title"] : ""
        
        if (url = "" && title = "") {
            TrayTip("No URL or title to research for '" captureName "'", "Research Error", "17")
            return
        }
        
        switch tool {
            case "transcript":
                ; YouTube transcript - use YouTubeToTranscript.com
                if InStr(url, "youtube.com") || InStr(url, "youtu.be")
                    Run("https://youtubetotranscript.com/?v=" url)
                else
                    TrayTip("Not a YouTube URL", "Transcript Error", "17")
            case "perplexity":
                searchTerm := url != "" ? url : title
                Run("https://www.perplexity.ai/search?q=" DSH_UrlEncode(searchTerm))
            case "factcheck":
                searchTerm := title != "" ? title : url
                Run("https://www.snopes.com/search/" DSH_UrlEncode(searchTerm))
            case "mediabias":
                ; Extract domain from URL
                domain := RegExReplace(url, "^https?://(?:www\.)?([^/]+).*", "$1")
                Run("https://mediabiasfactcheck.com/search/?q=" DSH_UrlEncode(domain))
            case "wayback":
                Run("https://web.archive.org/web/*/" url)
            case "scholar":
                searchTerm := title != "" ? title : url
                Run("https://scholar.google.com/scholar?q=" DSH_UrlEncode(searchTerm))
            case "archive":
                Run("https://archive.today/?" url)
        }
    }
    
    ; ==== HELPER FUNCTIONS ====
    
    static BuildFullContent(cap) {
        content := ""
        
        if cap.Has("title") && cap["title"] != ""
            content .= cap["title"] "`n"
        if cap.Has("url") && cap["url"] != ""
            content .= cap["url"] "`n"
        if cap.Has("opinion") && cap["opinion"] != ""
            content .= "`n" cap["opinion"] "`n"
        if cap.Has("body") && cap["body"] != ""
            content .= "`n" cap["body"]
        
        return RTrim(content, "`n")
    }
}

; ==============================================================================
; SAFE CLIPBOARD FUNCTIONS
; ==============================================================================
; These are fallbacks - only used if not already defined in the main script
; The main ContentCapture-Pro.ahk should define these functions
; ==============================================================================

; Internal fallback versions (prefixed with underscore to avoid conflicts)
_DSH_SafePaste(text) {
    ; v1.3.0: No longer saving/restoring clipboard - clear after paste instead
    A_Clipboard := ""
    Sleep(50)
    A_Clipboard := text
    if !ClipWait(2) {
        TrayTip("Clipboard operation failed", "Error", "2")
        return
    }
    Sleep(150)  ; Pre-paste flush
    SendInput("^v")
    Sleep(500)  ; Wait for paste
    A_Clipboard := ""  ; Clear clipboard to prevent stale content
}

_DSH_SafeCopy() {
    savedClip := ClipboardAll()
    A_Clipboard := ""
    SendInput("^c")
    if !ClipWait(2) {
        A_Clipboard := savedClip
        return ""
    }
    result := A_Clipboard
    A_Clipboard := savedClip
    return result
}

_DSH_UrlEncode(str) {
    static doc := ""
    if !doc {
        doc := ComObject("HTMLFile")
        doc.write('<meta http-equiv="X-UA-Compatible" content="IE=edge">')
    }
    return doc.parentWindow.encodeURIComponent(str)
}

; ==============================================================================
; WRAPPER FUNCTIONS
; ==============================================================================
; These use the main script's version if available, otherwise use fallbacks
; FIXED v2.3: Previously these were calling themselves (infinite recursion)
; ==============================================================================

DSH_SafePaste(text) {
    ; Check if CC_SafePaste exists and use it, otherwise use internal fallback
    if IsSet(CC_SafePaste)
        CC_SafePaste(text)  ; FIXED: Was calling DSH_SafePaste (itself) - now calls CC_SafePaste
    else
        _DSH_SafePaste(text)
}

DSH_SafeCopy() {
    ; NOTE: CC_SafeCopy(content) copies content TO clipboard (different purpose)
    ; _DSH_SafeCopy() copies FROM selection via Ctrl+C (what we need here)
    ; So we always use the internal version
    return _DSH_SafeCopy()
}

DSH_UrlEncode(str) {
    ; Check if CC_UrlEncode exists and use it, otherwise use internal fallback
    if IsSet(CC_UrlEncode)
        return CC_UrlEncode(str)  ; FIXED: Was calling non-existent DSH_UrlEncode
    else
        return _DSH_UrlEncode(str)
}
