; ==============================================================================
; DynamicSuffixHandler.ahk - Dynamic Hotstring Suffix Router
; ==============================================================================
; Version: 3.0 - With Image Suffix Support
; ==============================================================================
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
;   yt  → YouTube Transcript (Research)
;   pp  → Perplexity AI (Research)
;   fc  → Fact Check - Snopes (Research)
;   mb  → Media Bias Check (Research)
;   wb  → Wayback Machine (Research)
;   gs  → Google Scholar (Research)
;   av  → Archive Page (Research)
;
; NEW IMAGE SUFFIXES:
;   img → Copy attached image to clipboard
;   imgo → Open image in default viewer
;   fbi → Facebook + image(s)
;   xi  → Twitter/X + image(s)
;   bsi → Bluesky + image(s)
;   lii → LinkedIn + image(s)
;   mti → Mastodon + image(s)
;   emi → Email with image attachment(s)
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
        ; Social media sharing (text only)
        "fb", "facebook",    ; Share to Facebook
        "x",  "twitter",     ; Share to Twitter/X
        "bs", "bluesky",     ; Share to Bluesky
        "li", "linkedin",    ; Share to LinkedIn
        "mt", "mastodon",    ; Share to Mastodon
        ; AI & Processing
        "sum", "summarize",  ; Summarize with AI (on-demand)
        ; Research tools
        "yt", "transcript",  ; YouTube Transcript
        "pp", "perplexity",  ; Perplexity AI research
        "fc", "factcheck",   ; Fact check (Snopes)
        "mb", "mediabias",   ; Media Bias check
        "wb", "wayback",     ; Wayback Machine
        "gs", "scholar",     ; Google Scholar
        "av", "archive",     ; Archive.today
        ; IMAGE SUFFIXES (NEW)
        "img", "copyimage",      ; Copy image to clipboard
        "imgo", "openimage",     ; Open image in viewer
        "fbi", "facebookimg",    ; Facebook + image(s)
        "xi", "twitterimg",      ; Twitter/X + image(s)
        "bsi", "blueskyimg",     ; Bluesky + image(s)
        "lii", "linkedinimg",    ; LinkedIn + image(s)
        "mti", "mastodonimg",    ; Mastodon + image(s)
        "emi", "emailimg"        ; Email with image(s)
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
        ; Backspace to remove typed text
        backspaces := StrLen(captureName) + StrLen(suffix)
        Send("{BS " backspaces "}")
        Sleep(50)
        
        ; Get the action for this suffix
        action := this.SUFFIX_MAP.Has(suffix) ? this.SUFFIX_MAP[suffix] : ""
        
        switch action {
            ; Core actions
            case "email":
                this.ActionEmail(captureName)
            case "view":
                this.ActionView(captureName)
            case "openurl":
                this.ActionOpenURL(captureName)
            case "read":
                this.ActionRead(captureName)
            case "short":
                this.ActionShort(captureName)
            
            ; Social media (text only)
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
            
            ; AI & Research
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
            
            ; IMAGE ACTIONS (NEW)
            case "copyimage":
                this.ActionCopyImage(captureName)
            case "openimage":
                this.ActionOpenImage(captureName)
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
            case "emailimg":
                this.ActionEmailWithImage(captureName)
            
            default:
                TrayTip("Unknown suffix action: " action, "Error")
        }
    }
    
    ; ==== CORE ACTIONS ====
    
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
            TrayTip("Outlook error: " err.Message, "Error")
        }
    }
    
    static ActionView(captureName) {
        ; Call main GUI's edit function
        if IsSet(CC_EditCapture)
            CC_EditCapture(captureName)
        else
            TrayTip("Edit function not available", "Error")
    }
    
    static ActionOpenURL(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("url") && cap["url"] != "") {
            Run(cap["url"])
        } else {
            TrayTip("No URL for: " captureName, "No URL")
        }
    }
    
    static ActionRead(captureName) {
        cap := this.captureDataRef[captureName]
        content := this.BuildFullContent(cap)
        title := cap.Has("title") ? cap["title"] : captureName
        MsgBox(content, title, "0x40000")
    }
    
    static ActionShort(captureName) {
        cap := this.captureDataRef[captureName]
        if (cap.Has("short") && cap["short"] != "") {
            A_Clipboard := cap["short"]
            ClipWait(2)
            Send("^v")
        } else {
            TrayTip("No short version saved for: " captureName, "No Short Version")
        }
    }
    
    ; ==== SOCIAL MEDIA (TEXT ONLY) ====
    
    static ActionSocial(captureName, platform) {
        ; Use SocialShare module if available
        if IsSet(SS_ShareCapture) {
            SS_ShareCapture(captureName, platform)
            return
        }
        
        ; Fallback: just copy content
        cap := this.captureDataRef[captureName]
        content := this.BuildShareContent(cap, platform)
        A_Clipboard := content
        ClipWait(2)
        TrayTip("Content copied for " platform, "📋 Ready")
    }
    
    ; ==== AI & RESEARCH ====
    
    static ActionSummarize(captureName) {
        if IsSet(RT_SummarizeCapture)
            RT_SummarizeCapture(captureName)
        else
            TrayTip("Research tools not available", "Error")
    }
    
    static ActionResearch(captureName, tool) {
        if IsSet(RT_LaunchResearchTool)
            RT_LaunchResearchTool(captureName, tool)
        else
            TrayTip("Research tools not available", "Error")
    }
    
    ; ==== IMAGE ACTIONS (NEW) ====
    
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
                if IsSet(IS_CopyImageFileToClipboard)
                    IS_CopyImageFileToClipboard(images[1])
                else
                    TrayTip("Image clipboard not available", "Error")
            } else {
                TrayTip("No images attached to: " captureName, "No Image")
            }
        } else {
            TrayTip("Image database not loaded", "Error")
        }
    }
    
    static ActionOpenImage(captureName) {
        if IsSet(IS_OpenImage) {
            IS_OpenImage(captureName)
            return
        }
        
        ; Fallback
        if IsSet(IDB_GetImages) {
            images := IDB_GetImages(captureName)
            for imgPath in images {
                if FileExist(imgPath)
                    Run(imgPath)
            }
        }
    }
    
    static ActionSocialWithImage(captureName, platform) {
        if IsSet(IS_ShareWithImage) {
            IS_ShareWithImage(captureName, platform)
        } else {
            ; Fallback to text-only sharing
            TrayTip("Image sharing not available, using text only", "Note")
            this.ActionSocial(captureName, platform)
        }
    }
    
    static ActionEmailWithImage(captureName) {
        if IsSet(IS_EmailWithImage) {
            IS_EmailWithImage(captureName)
        } else {
            ; Fallback to regular email
            TrayTip("Image attachment not available", "Note")
            this.ActionEmail(captureName)
        }
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
