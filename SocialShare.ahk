#Requires AutoHotkey v2.0+

; ==============================================================================
; SocialShare.ahk - Social Media Sharing for ContentCapture Pro
; ==============================================================================
; Handles sharing captures to social media platforms with:
;   - Platform detection (knows when you're on Facebook, Twitter, etc.)
;   - Character limit warnings
;   - Image attachment support
;   - Platform-specific guidance
;
; Usage: #Include this file in ContentCapture-Pro.ahk
; ==============================================================================

; Platform definitions with limits and URLs
class SS_Platforms {
    static Facebook := {name: "Facebook", icon: "📘", limit: 63206, shareUrl: "https://www.facebook.com/sharer/sharer.php?u="}
    static Twitter := {name: "Twitter/X", icon: "🐦", limit: 280, shareUrl: "https://twitter.com/intent/tweet?"}
    static Bluesky := {name: "Bluesky", icon: "🦋", limit: 300, shareUrl: "https://bsky.app/"}
    static LinkedIn := {name: "LinkedIn", icon: "💼", limit: 3000, shareUrl: "https://www.linkedin.com/sharing/share-offsite/?url="}
    static Mastodon := {name: "Mastodon", icon: "🐘", limit: 500, shareUrl: ""}
}

; Detect which social platform is currently active
SS_DetectPlatform() {
    ; Check all browser windows, not just active
    platforms := [
        {pattern: "facebook.com", platform: SS_Platforms.Facebook},
        {pattern: "twitter.com", platform: SS_Platforms.Twitter},
        {pattern: "x.com", platform: SS_Platforms.Twitter},
        {pattern: "bsky.app", platform: SS_Platforms.Bluesky},
        {pattern: "linkedin.com", platform: SS_Platforms.LinkedIn},
        {pattern: "mastodon", platform: SS_Platforms.Mastodon}
    ]
    
    ; Get active window title first
    title := WinGetTitle("A")
    
    for item in platforms {
        if InStr(title, item.pattern)
            return item.platform
    }
    
    ; Scan all browser windows
    browserClasses := ["Chrome_WidgetWin_1", "MozillaWindowClass", "ApplicationFrameWindow"]
    
    for class in browserClasses {
        try {
            windows := WinGetList("ahk_class " class)
            for hwnd in windows {
                winTitle := WinGetTitle(hwnd)
                for item in platforms {
                    if InStr(winTitle, item.pattern)
                        return item.platform
                }
            }
        }
    }
    
    return ""
}

; Share a capture to a specific platform
SS_ShareCapture(captureName, platform := "") {
    global CaptureData
    
    if (!CaptureData.Has(captureName)) {
        MsgBox("Capture '" captureName "' not found.", "Error", "48")
        return
    }
    
    cap := CaptureData[captureName]
    
    ; Auto-detect platform if not specified
    if (platform = "")
        platform := SS_DetectPlatform()
    
    if (platform = "") {
        ; Show platform picker
        SS_ShowPlatformPicker(captureName)
        return
    }
    
    ; Build content
    content := SS_BuildShareContent(cap)
    
    ; Check character limit
    if (StrLen(content) > platform.limit) {
        result := MsgBox("Content is " StrLen(content) " characters.`n" 
            . platform.name " limit is " platform.limit " characters.`n`n"
            . "Share anyway?", "Character Limit", "YN Icon!")
        if (result = "No")
            return
    }
    
    ; Check for attached image
    hasImage := false
    imagePath := ""
    try {
        if IsSet(IC_HasImage) && IC_HasImage(captureName) {
            hasImage := true
            if IsSet(IC_GetImagePath)
                imagePath := IC_GetImagePath(captureName)
        }
    }
    
    ; Copy content to clipboard using safe method
    CC_SafeCopy(content)
    
    ; Handle image if present
    if (hasImage && imagePath != "" && FileExist(imagePath)) {
        SS_ShareWithImage(captureName, content, imagePath, platform)
    } else {
        SS_ShareTextOnly(content, platform)
    }
}

; Share text only (no image)
SS_ShareTextOnly(content, platform) {
    url := ""
    
    switch platform.name {
        case "Facebook":
            ; Facebook sharer doesn't support text, just copy and open
            Run("https://www.facebook.com/")
            TrayTip(platform.icon " Text copied!`nPaste with Ctrl+V on Facebook", "Facebook Share", "1")
            
        case "Twitter/X":
            url := platform.shareUrl . "text=" . SS_URLEncode(content)
            Run(url)
            
        case "Bluesky":
            Run("https://bsky.app/")
            TrayTip(platform.icon " Text copied (" StrLen(content) "/300 chars)`nPaste with Ctrl+V", "Bluesky Share", "1")
            
        case "LinkedIn":
            Run("https://www.linkedin.com/feed/")
            TrayTip(platform.icon " Text copied!`nPaste with Ctrl+V", "LinkedIn Share", "1")
            
        case "Mastodon":
            TrayTip(platform.icon " Text copied!`nPaste into your Mastodon instance", "Mastodon Share", "1")
    }
}

; Share with image attachment
SS_ShareWithImage(captureName, content, imagePath, platform) {
    ; Get platform-specific image instructions
    imageInstructions := SS_GetImageInstructions(platform)
    
    ; Ask user preference
    choice := MsgBox("📷 Image attached to this capture!`n`n"
        . "How would you like to share?`n`n"
        . "YES = " imageInstructions "`n"
        . "NO = Text only (no image)`n"
        . "CANCEL = Cancel", 
        platform.icon " " platform.name " Share", "YNC Iconi")
    
    if (choice = "Cancel")
        return
    
    if (choice = "Yes") {
        ; Copy image to clipboard first
        if IsSet(IC_CopyImageToClipboardGDI)
            IC_CopyImageToClipboardGDI(imagePath)
        else if IsSet(IC_CopyImageToClipboardPS)
            IC_CopyImageToClipboardPS(imagePath)
        
        ; Open platform
        Run(SS_GetPlatformURL(platform))
        
        ; Store text for later pasting
        global SS_PendingText := content
        
        TrayTip(platform.icon " Image copied!`n" imageInstructions "`nThen Ctrl+Alt+V for text", "Share with Image", "1")
    } else {
        ; Text only
        SS_ShareTextOnly(content, platform)
    }
}

; Get platform-specific image upload instructions
SS_GetImageInstructions(platform) {
    switch platform.name {
        case "Facebook":
            return "Click the GREEN 📷 photo button FIRST, then paste text"
        case "Twitter/X":
            return "Click the 🖼️ image icon FIRST, then paste text"
        case "Bluesky":
            return "Click the 📷 image button FIRST, then paste text"
        case "LinkedIn":
            return "Click the 📷 photo icon FIRST, then paste text"
        default:
            return "Add image first, then paste text"
    }
}

; Get platform URL
SS_GetPlatformURL(platform) {
    switch platform.name {
        case "Facebook":
            return "https://www.facebook.com/"
        case "Twitter/X":
            return "https://twitter.com/compose/tweet"
        case "Bluesky":
            return "https://bsky.app/"
        case "LinkedIn":
            return "https://www.linkedin.com/feed/"
        default:
            return ""
    }
}

; Build share content from capture
SS_BuildShareContent(cap) {
    content := ""
    
    ; Check for short version first
    if (cap.Has("short") && cap["short"] != "")
        return cap["short"]
    
    ; Build from regular fields
    if (cap.Has("opinion") && cap["opinion"] != "")
        content := cap["opinion"]
    else if (cap.Has("title") && cap["title"] != "")
        content := cap["title"]
    
    if (cap.Has("url") && cap["url"] != "") {
        if (content != "")
            content .= "`n`n"
        content .= cap["url"]
    }
    
    return content
}

; Show platform picker dialog
SS_ShowPlatformPicker(captureName) {
    global CaptureData
    
    if (!CaptureData.Has(captureName))
        return
    
    cap := CaptureData[captureName]
    content := SS_BuildShareContent(cap)
    charCount := StrLen(content)
    
    pickerGui := Gui("+AlwaysOnTop", "Share: " captureName)
    pickerGui.SetFont("s10")
    pickerGui.BackColor := "2d2d44"
    
    pickerGui.SetFont("s9 cFFFFFF")
    pickerGui.Add("Text", "x10 y10 w300", "📤 Choose a platform to share to:")
    pickerGui.Add("Text", "x10 y30 w300 c888888", "Content: " charCount " characters")
    
    yPos := 60
    
    ; Platform buttons
    platforms := [
        {name: "📘 Facebook", action: SS_Platforms.Facebook},
        {name: "🐦 Twitter/X", action: SS_Platforms.Twitter},
        {name: "🦋 Bluesky", action: SS_Platforms.Bluesky},
        {name: "💼 LinkedIn", action: SS_Platforms.LinkedIn},
        {name: "🐘 Mastodon", action: SS_Platforms.Mastodon}
    ]
    
    for p in platforms {
        limitWarning := charCount > p.action.limit ? " ⚠️" : ""
        btn := pickerGui.Add("Button", "x10 y" yPos " w150 h30", p.name . limitWarning)
        btn.OnEvent("Click", SS_MakeShareHandler(captureName, p.action, pickerGui))
        yPos += 35
    }
    
    pickerGui.Add("Button", "x10 y" yPos " w150 h30", "Cancel").OnEvent("Click", (*) => pickerGui.Destroy())
    
    pickerGui.OnEvent("Escape", (*) => pickerGui.Destroy())
    pickerGui.Show("w170 h" (yPos + 45))
}

; Create share handler closure
SS_MakeShareHandler(captureName, platform, gui) {
    return (*) => (gui.Destroy(), SS_ShareCapture(captureName, platform))
}

; Email a capture via Outlook
SS_EmailCapture(captureName) {
    global CaptureData
    
    if (!CaptureData.Has(captureName)) {
        MsgBox("Capture '" captureName "' not found.", "Error", "48")
        return
    }
    
    cap := CaptureData[captureName]
    
    ; Build email content
    content := ""
    
    if (cap.Has("title") && cap["title"] != "")
        content .= cap["title"] . "`r`n`r`n"
    
    if (cap.Has("url") && cap["url"] != "")
        content .= cap["url"] . "`r`n`r`n"
    
    if (cap.Has("opinion") && cap["opinion"] != "")
        content .= "My thoughts:`r`n" . cap["opinion"] . "`r`n`r`n"
    
    if (cap.Has("body") && cap["body"] != "")
        content .= cap["body"]
    
    ; Get subject
    subject := cap.Has("title") ? cap["title"] : captureName
    if (StrLen(subject) > 100)
        subject := SubStr(subject, 1, 97) . "..."
    
    ; Check for attached image
    hasImage := false
    imagePath := ""
    try {
        if IsSet(IC_HasImage) && IC_HasImage(captureName) {
            hasImage := true
            if IsSet(IC_GetImagePath)
                imagePath := IC_GetImagePath(captureName)
        }
    }
    
    ; Send via Outlook
    try {
        outlook := ComObject("Outlook.Application")
        mail := outlook.CreateItem(0)  ; 0 = olMailItem
        mail.Subject := subject
        mail.Body := content
        
        ; Attach image if present
        if (hasImage && imagePath != "" && FileExist(imagePath)) {
            mail.Attachments.Add(imagePath)
        }
        
        mail.Display()  ; Show email for review
        TrayTip("Email created" . (hasImage ? " with image attached" : ""), "📧 Outlook", "1")
    } catch as err {
        MsgBox("Failed to create email:`n" . err.Message . "`n`nMake sure Outlook is installed.", "Email Error", "48")
    }
}

; URL encode helper
SS_URLEncode(str) {
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

; Hotkey to paste pending text after image
^!v:: {
    global SS_PendingText
    if IsSet(SS_PendingText) && SS_PendingText != "" {
        CC_SafePaste(SS_PendingText)
        SS_PendingText := ""
    }
}
