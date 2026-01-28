; ==============================================================================
; DynamicSuffixHandler.ahk - Dynamic Hotstring Suffix Router
; ==============================================================================
; Version: 4.0 - Complete Suffix Support
; Updated: 2026-01-24
; ==============================================================================
;
; COMPLETE SUFFIX REFERENCE:
; ==============================================================================
;
; CORE CONTENT SUFFIXES:
;   (none) → Paste full content (URL + title + opinion + body)
;   t      → Title only - paste just the title
;   url    → URL only - paste just the URL  
;   body   → Body only - paste just the body text
;   cp     → Copy to clipboard (without pasting)
;   sh     → Paste short version only (for comments/replies)
;   ?      → Show action menu with all options
;
; VIEW/EDIT SUFFIXES:
;   rd     → Read content in popup window
;   vi     → View/Edit in GUI
;   go     → Open URL in browser
;
; EMAIL SUFFIXES:
;   em     → Email via Outlook (new email)
;   oi     → Outlook Insert at cursor (in open email)
;   ed     → Email with document attached
;   emi    → Email with image attachment(s)
;
; SOCIAL MEDIA SUFFIXES (text only):
;   fb     → Share to Facebook
;   x      → Share to Twitter/X
;   bs     → Share to Bluesky
;   li     → Share to LinkedIn
;   mt     → Share to Mastodon
;
; IMAGE SUFFIXES:
;   i      → Paste image PATH (for file dialogs - copies path as text)
;   img    → Copy image to clipboard as BITMAP (for pasting into apps)
;   imgo   → Open image in default viewer
;   ti     → Title + Image path (paste title, then image path)
;
; SOCIAL MEDIA + IMAGE SUFFIXES:
;   fbi    → Facebook + image(s)
;   xi     → Twitter/X + image(s)
;   bsi    → Bluesky + image(s)
;   lii    → LinkedIn + image(s)
;   mti    → Mastodon + image(s)
;
; AI & RESEARCH SUFFIXES:
;   sum    → Summarize with AI (on-demand)
;   yt     → YouTube Transcript
;   pp     → Perplexity AI research
;   fc     → Fact check (Snopes)
;   mb     → Media Bias check
;   wb     → Wayback Machine
;   gs     → Google Scholar
;   av     → Archive.today
;
; DOCUMENT SUFFIXES:
;   d.     → Open attached document
;   pr     → Print formatted record
;
; ==============================================================================
;
; Usage: #Include this file and call DynamicSuffixHandler.Initialize(CaptureData, CaptureNames)
; ==============================================================================

#Warn VarUnset, Off  ; Suppress warnings - globals are defined in main script

class DynamicSuffixHandler {
    ; ==== CONFIGURATION ====
    static SUFFIX_MAP := Map(
        ; === CORE CONTENT SUFFIXES ===
        "t", "title",            ; Title only
        "url", "urlonly",        ; URL only
        "body", "bodyonly",      ; Body only
        "cp", "copy",            ; Copy to clipboard (no paste)
        "sh", "short",           ; Paste short version only
        
        ; === VIEW/EDIT SUFFIXES ===
        "rd", "read",            ; Read in popup window
        "vi", "view",            ; View/Edit in GUI
        "go", "openurl",         ; Open URL in browser
        
        ; === EMAIL SUFFIXES ===
        "em", "email",           ; Email via Outlook
        "oi", "outlookinsert",   ; Insert into open Outlook email
        "ed", "emaildoc",        ; Email with document
        "emi", "emailimg",       ; Email with image(s)
        
        ; === SOCIAL MEDIA (text only) ===
        "fb", "facebook",        ; Share to Facebook
        "x", "twitter",          ; Share to Twitter/X
        "bs", "bluesky",         ; Share to Bluesky
        "li", "linkedin",        ; Share to LinkedIn
        "mt", "mastodon",        ; Share to Mastodon
        
        ; === IMAGE SUFFIXES ===
        "i", "imagepath",        ; Paste image PATH (text for file dialogs)
        "img", "copyimage",      ; Copy image to clipboard as BITMAP
        "imgo", "openimage",     ; Open image in viewer
        "ti", "titleimage",      ; Title + Image path
        
        ; === SOCIAL + IMAGE ===
        "fbi", "facebookimg",    ; Facebook + image(s)
        "xi", "twitterimg",      ; Twitter/X + image(s)
        "bsi", "blueskyimg",     ; Bluesky + image(s)
        "lii", "linkedinimg",    ; LinkedIn + image(s)
        "mti", "mastodonimg",    ; Mastodon + image(s)
        
        ; === AI & RESEARCH ===
        "sum", "summarize",      ; Summarize with AI
        "yt", "transcript",      ; YouTube Transcript
        "pp", "perplexity",      ; Perplexity AI research
        "fc", "factcheck",       ; Fact check (Snopes)
        "mb", "mediabias",       ; Media Bias check
        "wb", "wayback",         ; Wayback Machine
        "gs", "scholar",         ; Google Scholar
        "av", "archive",         ; Archive.today
        
        ; === DOCUMENT ===
        "d.", "opendoc",         ; Open attached document
        "pr", "print"            ; Print formatted record
    )
    
    ; Character limits for social platforms
    static LIMIT_TWITTER := 280
    static LIMIT_BLUESKY := 300
    static LIMIT_LINKEDIN := 3000
    static LIMIT_MASTODON := 500
    static LIMIT_FACEBOOK := 63206
    
    ; Internal state
    static inputHook := ""
    static inputBuffer := ""
    static isEnabled := false
    static maxBufferLen := 80
    
    ; Reference to capture database
    static captureDataRef := ""
    static captureNamesRef := ""
    
    ; ==== INITIALIZATION ====
    static Initialize(captureData, captureNames) {
        this.captureDataRef := captureData
        this.captureNamesRef := captureNames
        this.isEnabled := true
        
        ; Set up input hook for suffix detection
        this.SetupInputHook()
        
        ; Load image database if available (after BaseDir is set)
        try {
            if IsSet(IDB_LoadImageDatabase)
                IDB_LoadImageDatabase()
        }
    }
    
    static SetupInputHook() {
        ; Clean up existing hook
        if (this.inputHook != "") {
            try this.inputHook.Stop()
        }
        
        ; Create new input hook
        this.inputHook := InputHook("V I1 L" this.maxBufferLen)
        this.inputHook.OnChar := ObjBindMethod(this, "OnChar")
        this.inputHook.OnEnd := ObjBindMethod(this, "OnEnd")
        this.inputHook.KeyOpt("{Space}{Tab}{Enter}", "E")
        this.inputHook.Start()
    }
    
    static OnChar(ih, char) {
        this.inputBuffer .= char
        
        ; Keep buffer manageable
        if (StrLen(this.inputBuffer) > this.maxBufferLen)
            this.inputBuffer := SubStr(this.inputBuffer, -this.maxBufferLen + 1)
    }
    
    static OnEnd(ih) {
        if (!this.isEnabled)
            return
        
        ; Check if buffer matches a capture + suffix pattern
        this.CheckForSuffix()
        
        ; Clear buffer and restart
        this.inputBuffer := ""
        this.inputHook.Start()
    }
    
    ; ==== SUFFIX DETECTION ====
    static CheckForSuffix() {
        buffer := this.inputBuffer
        
        ; Sort suffixes by length (longest first) for proper matching
        suffixes := this.GetSuffixesSortedByLength()
        
        for suffix in suffixes {
            if (suffix = "")
                continue
            
            ; Check if buffer ends with this suffix
            suffixLen := StrLen(suffix)
            if (SubStr(buffer, -suffixLen) = suffix) {
                ; Extract potential capture name
                captureName := SubStr(buffer, 1, StrLen(buffer) - suffixLen)
                
                ; Check if this is a valid capture
                if (this.captureDataRef.Has(captureName)) {
                    ; Found a match! Route to handler
                    this.HandleSuffix(captureName, suffix)
                    return
                }
            }
        }
    }
    
    static GetSuffixesSortedByLength() {
        ; Get all suffixes and sort by length descending
        suffixes := []
        for suffix, action in this.SUFFIX_MAP
            suffixes.Push({s: suffix, len: StrLen(suffix)})
        
        ; Simple bubble sort by length descending
        Loop suffixes.Length - 1 {
            Loop suffixes.Length - A_Index {
                if (suffixes[A_Index].len < suffixes[A_Index + 1].len) {
                    temp := suffixes[A_Index]
                    suffixes[A_Index] := suffixes[A_Index + 1]
                    suffixes[A_Index + 1] := temp
                }
            }
        }
        
        result := []
        for item in suffixes
            result.Push(item.s)
        return result
    }
    
    ; ==== ACTION ROUTING ====
    static HandleSuffix(captureName, suffix) {
        ; Backspace to remove typed text PLUS the ending character (space/tab/enter)
        backspaces := StrLen(captureName) + StrLen(suffix) + 1
        Send("{BS " backspaces "}")
        Sleep(50)
        
        ; Get the action for this suffix
        action := this.SUFFIX_MAP.Has(suffix) ? this.SUFFIX_MAP[suffix] : ""
        
        switch action {
            ; === CORE CONTENT ===
            case "title":
                this.ActionTitle(captureName)
            case "urlonly":
                this.ActionURLOnly(captureName)
            case "bodyonly":
                this.ActionBodyOnly(captureName)
            case "copy":
                this.ActionCopy(captureName)
            case "short":
                this.ActionShort(captureName)
            
            ; === VIEW/EDIT ===
            case "read":
                this.ActionRead(captureName)
            case "view":
                this.ActionView(captureName)
            case "openurl":
                this.ActionOpenURL(captureName)
            
            ; === EMAIL ===
            case "email":
                this.ActionEmail(captureName)
            case "outlookinsert":
                this.ActionOutlookInsert(captureName)
            case "emaildoc":
                this.ActionEmailWithDoc(captureName)
            case "emailimg":
                this.ActionEmailWithImage(captureName)
            
            ; === SOCIAL MEDIA (text only) ===
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
            
            ; === IMAGE ===
            case "imagepath":
                this.ActionImagePath(captureName)
            case "copyimage":
                this.ActionCopyImage(captureName)
            case "openimage":
                this.ActionOpenImage(captureName)
            case "titleimage":
                this.ActionTitleImage(captureName)
            
            ; === SOCIAL + IMAGE ===
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
            
            ; === AI & RESEARCH ===
            case "summarize":
                this.ActionSummarize(captureName)
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
            
            ; === DOCUMENT ===
            case "opendoc":
                this.ActionOpenDoc(captureName)
            case "print":
                this.ActionPrint(captureName)
        }
    }
    
    ; ==== CORE CONTENT ACTIONS ====
    
    ; Paste TITLE only
    static ActionTitle(captureName) {
        cap := this.captureDataRef[captureName]
        title := ""
        
        if (cap.Has("title") && cap["title"] != "")
            title := cap["title"]
        else
            title := captureName  ; Fallback to name
        
        this.SafePaste(title)
    }
    
    ; Paste URL only
    static ActionURLOnly(captureName) {
        cap := this.captureDataRef[captureName]
        
        if (cap.Has("url") && cap["url"] != "") {
            this.SafePaste(cap["url"])
        } else {
            TrayTip("No URL for: " captureName, "No URL", "2")
        }
    }
    
    ; Paste BODY only (no URL, no title)
    static ActionBodyOnly(captureName) {
        cap := this.captureDataRef[captureName]
        
        if (cap.Has("body") && cap["body"] != "") {
            this.SafePaste(cap["body"])
        } else if (cap.Has("content") && cap["content"] != "") {
            this.SafePaste(cap["content"])
        } else {
            TrayTip("No body content for: " captureName, "No Body", "2")
        }
    }
    
    ; Copy to clipboard WITHOUT pasting
    static ActionCopy(captureName) {
        cap := this.captureDataRef[captureName]
        content := this.BuildFullContent(cap)
        
        A_Clipboard := content
        ClipWait(2)
        TrayTip("Copied to clipboard!", captureName, "1")
    }
    
    ; Paste short version only
    static ActionShort(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("short") && cap["short"] != "") {
            this.SafePaste(cap["short"])
        } else {
            TrayTip("No short version saved for: " captureName, "No Short Version", "2")
        }
    }
    
    ; ==== VIEW/EDIT ACTIONS ====
    
    static ActionRead(captureName) {
        cap := this.captureDataRef[captureName]
        content := this.BuildFullContent(cap)
        title := cap.Has("title") ? cap["title"] : captureName
        MsgBox(content, title, "0x40000")
    }
    
    static ActionView(captureName) {
        ; Call main GUI's edit function
        if IsSet(CC_EditCapture)
            CC_EditCapture(captureName)
        else
            TrayTip("Edit function not available", "Error", "2")
    }
    
    static ActionOpenURL(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("url") && cap["url"] != "") {
            Run(cap["url"])
        } else {
            TrayTip("No URL for: " captureName, "No URL", "2")
        }
    }
    
    ; ==== EMAIL ACTIONS ====
    
    static ActionEmail(captureName) {
        cap := this.captureDataRef[captureName]
        subject := cap.Has("title") ? cap["title"] : captureName
        body := this.BuildFullContent(cap)
        
        try {
            outlookApp := ComObject("Outlook.Application")
            email := outlookApp.CreateItem(0)
            email.Subject := subject
            email.Body := body
            email.Display()
        } catch as err {
            TrayTip("Outlook error: " err.Message, "Error", "2")
        }
    }
    
    static ActionOutlookInsert(captureName) {
        cap := this.captureDataRef[captureName]
        content := this.BuildFullContent(cap)
        
        if IsSet(CC_OutlookInsertAtCursor)
            CC_OutlookInsertAtCursor(content)
        else
            TrayTip("Outlook insert not available", "Error", "2")
    }
    
    static ActionEmailWithDoc(captureName) {
        if IsSet(CC_EmailWithDocument)
            CC_EmailWithDocument(captureName)
        else
            TrayTip("Email with document not available", "Error", "2")
    }
    
    static ActionEmailWithImage(captureName) {
        if IsSet(IS_EmailWithImage) {
            IS_EmailWithImage(captureName)
        } else {
            ; Fallback to regular email
            TrayTip("Image attachment not available", "Note", "1")
            this.ActionEmail(captureName)
        }
    }
    
    ; ==== SOCIAL MEDIA (TEXT ONLY) ====
    
    ; Platform configurations
    static PLATFORMS := Map(
        "facebook", {name: "Facebook", limit: 63206, icon: "📘", url: "https://www.facebook.com/"},
        "twitter", {name: "Twitter/X", limit: 280, icon: "🐦", url: "https://twitter.com/compose/tweet"},
        "bluesky", {name: "Bluesky", limit: 300, icon: "🦋", url: "https://bsky.app/"},
        "linkedin", {name: "LinkedIn", limit: 3000, icon: "💼", url: "https://www.linkedin.com/feed/"},
        "mastodon", {name: "Mastodon", limit: 500, icon: "🐘", url: ""}
    )
    
    static ActionSocial(captureName, platformKey) {
        ; Get platform config object
        platformObj := this.PLATFORMS.Has(platformKey) ? this.PLATFORMS[platformKey] : {name: platformKey, limit: 5000, icon: "📤", url: ""}
        
        ; Use SocialShare module if available
        if IsSet(SS_ShareCapture) {
            SS_ShareCapture(captureName, platformObj)
            return
        }
        
        ; Fallback: just copy content
        cap := this.captureDataRef[captureName]
        content := this.BuildShareContent(cap, platformKey)
        A_Clipboard := content
        ClipWait(2)
        TrayTip("Content copied for " platformObj.name, "📋 Ready", "1")
    }
    
    ; Individual platform methods for direct calls from main script
    static ActionBluesky(captureName, cap := "") {
        this.ActionSocial(captureName, "bluesky")
    }
    
    static ActionFacebook(captureName, cap := "") {
        this.ActionSocial(captureName, "facebook")
    }
    
    static ActionTwitter(captureName, cap := "") {
        this.ActionSocial(captureName, "twitter")
    }
    
    static ActionLinkedIn(captureName, cap := "") {
        this.ActionSocial(captureName, "linkedin")
    }
    
    static ActionMastodon(captureName, cap := "") {
        this.ActionSocial(captureName, "mastodon")
    }
    
    ; ==== IMAGE ACTIONS ====
    
    ; Paste image PATH as text (for file dialogs)
    static ActionImagePath(captureName) {
        imagePath := this.GetImagePath(captureName)
        
        if (imagePath = "") {
            TrayTip("No image attached to: " captureName, "No Image", "2")
            return
        }
        
        if !FileExist(imagePath) {
            TrayTip("Image file not found: " imagePath, "File Missing", "2")
            return
        }
        
        ; Paste the PATH as text (for file open dialogs)
        this.SafePaste(imagePath)
        TrayTip("Image path pasted", "📷 " this.GetFileName(imagePath), "1")
    }
    
    ; Copy image to clipboard as BITMAP (for pasting into apps)
    static ActionCopyImage(captureName) {
        ; Try ImageSharing module first
        if IsSet(IS_CopyImageToClipboard) {
            IS_CopyImageToClipboard(captureName)
            return
        }
        
        ; Fallback: use ImageDatabase
        if IsSet(IDB_GetImages) {
            images := IDB_GetImages(captureName)
            if (images.Length > 0) {
                if IsSet(IC_CopyImageToClipboardGDI)
                    IC_CopyImageToClipboardGDI(images[1])
                else if IsSet(IS_CopyImageFileToClipboard)
                    IS_CopyImageFileToClipboard(images[1])
                else
                    TrayTip("Image clipboard not available", "Error", "2")
            } else {
                TrayTip("No images attached to: " captureName, "No Image", "2")
            }
        } else {
            TrayTip("Image database not loaded", "Error", "2")
        }
    }
    
    ; Open image in default viewer
    static ActionOpenImage(captureName) {
        if IsSet(IS_OpenImage) {
            IS_OpenImage(captureName)
            return
        }
        
        ; Fallback
        imagePath := this.GetImagePath(captureName)
        if (imagePath != "" && FileExist(imagePath))
            Run(imagePath)
        else
            TrayTip("No image found for: " captureName, "No Image", "2")
    }
    
    ; Paste TITLE, then IMAGE PATH
    static ActionTitleImage(captureName) {
        cap := this.captureDataRef[captureName]
        
        ; First paste title
        title := cap.Has("title") ? cap["title"] : captureName
        this.SafePaste(title)
        
        ; Add newline
        Sleep(100)
        Send("{Enter}")
        Sleep(100)
        
        ; Then paste image path
        imagePath := this.GetImagePath(captureName)
        if (imagePath != "" && FileExist(imagePath)) {
            this.SafePaste(imagePath)
            TrayTip("Title + Image path pasted", captureName, "1")
        } else {
            TrayTip("Title pasted (no image found)", captureName, "1")
        }
    }
    
    ; ==== SOCIAL + IMAGE ====
    
    static ActionSocialWithImage(captureName, platformKey) {
        if IsSet(IS_ShareWithImage) {
            ; ImageSharing expects a string like "facebook", "bluesky", etc.
            IS_ShareWithImage(captureName, platformKey)
        } else {
            ; Fallback to text-only sharing
            TrayTip("Image sharing not available, using text only", "Note", "1")
            this.ActionSocial(captureName, platformKey)
        }
    }
    
    ; ==== AI & RESEARCH ====
    
    static ActionSummarize(captureName) {
        if IsSet(RT_SummarizeCapture)
            RT_SummarizeCapture(captureName)
        else
            TrayTip("Research tools not available", "Error", "2")
    }
    
    static ActionResearch(captureName, tool) {
        if IsSet(RT_LaunchResearchTool)
            RT_LaunchResearchTool(captureName, tool)
        else
            TrayTip("Research tools not available", "Error", "2")
    }
    
    ; ==== DOCUMENT ACTIONS ====
    
    static ActionOpenDoc(captureName) {
        if IsSet(CC_OpenDocument)
            CC_OpenDocument(captureName)
        else
            TrayTip("Document open not available", "Error", "2")
    }
    
    static ActionPrint(captureName) {
        if IsSet(CC_PrintCapture)
            CC_PrintCapture(captureName)
        else
            TrayTip("Print not available", "Error", "2")
    }
    
    ; ==== CONTENT BUILDING ====
    
    static BuildFullContent(cap) {
        content := ""
        
        if (cap.Has("body") && cap["body"] != "")
            content := cap["body"]
        else if (cap.Has("content") && cap["content"] != "")
            content := cap["content"]
        
        if (cap.Has("url") && cap["url"] != "") {
            url := cap["url"]
            if (!InStr(content, url)) {
                if (content != "")
                    content .= "`n`n"
                content .= url
            }
        }
        
        return content
    }
    
    static BuildShareContent(cap, platform) {
        content := this.BuildFullContent(cap)
        
        ; Get character limit
        limit := 5000
        switch platform {
            case "twitter", "x":
                limit := this.LIMIT_TWITTER
            case "bluesky":
                limit := this.LIMIT_BLUESKY
            case "linkedin":
                limit := this.LIMIT_LINKEDIN
            case "mastodon":
                limit := this.LIMIT_MASTODON
        }
        
        ; Truncate if needed
        if (StrLen(content) > limit)
            content := SubStr(content, 1, limit - 3) "..."
        
        return content
    }
    
    ; ==== HELPER FUNCTIONS ====
    
    ; Get image path for a capture
    static GetImagePath(captureName) {
        global BaseDir
        
        ; Try ImageDatabase first
        if IsSet(IDB_GetImages) {
            images := IDB_GetImages(captureName)
            if (images.Length > 0)
                return images[1]
        }
        
        ; Try capture data
        cap := this.captureDataRef[captureName]
        if (cap.Has("image") && cap["image"] != "") {
            imgPath := cap["image"]
            ; Handle relative paths
            if (!InStr(imgPath, ":") && !InStr(imgPath, "\\"))
                imgPath := BaseDir "\images\" imgPath
            if FileExist(imgPath)
                return imgPath
        }
        
        return ""
    }
    
    ; Get filename from path
    static GetFileName(path) {
        SplitPath(path, &name)
        return name
    }
    
    ; Safe paste with clipboard handling
    static SafePaste(text) {
        ; Save clipboard
        savedClip := ClipboardAll()
        
        ; Set and paste
        A_Clipboard := text
        if ClipWait(2) {
            Send("^v")
            Sleep(100)
        }
        
        ; Restore clipboard
        SetTimer(() => (A_Clipboard := savedClip), -500)
    }
    
    ; ==== UTILITY ====
    
    static Stop() {
        this.isEnabled := false
        if (this.inputHook != "") {
            try this.inputHook.Stop()
        }
    }
    
    static Restart() {
        this.isEnabled := true
        this.SetupInputHook()
    }
}
