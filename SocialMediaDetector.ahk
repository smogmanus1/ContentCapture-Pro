; ==============================================================================
; SocialMediaDetector.ahk - Auto-detect social media sites
; ==============================================================================
; Monitors active browser window and detects when you're on social media.
; Can automatically prep images or show helpful prompts.
;
; Supported Platforms:
;   Facebook, Twitter/X, Bluesky, LinkedIn, Mastodon, Instagram,
;   Threads, Reddit, TikTok, YouTube
;
; Features:
;   - Auto-detect platform from URL/title
;   - Show tray tip when you have content ready to paste
;   - Auto-copy image to clipboard when on matching platform
;   - Quick paste hotkey (Ctrl+Shift+V) for full content
; ==============================================================================

; Platform detection patterns
global SocialPlatforms := Map(
    "facebook", {
        patterns: ["facebook.com", "fb.com"],
        titlePatterns: ["Facebook"],
        charLimit: 63206,
        name: "Facebook",
        icon: "🔵"
    },
    "twitter", {
        patterns: ["twitter.com", "x.com"],
        titlePatterns: ["/ X", "/ Twitter"],
        charLimit: 280,
        name: "Twitter/X",
        icon: "𝕏"
    },
    "bluesky", {
        patterns: ["bsky.app", "bluesky"],
        titlePatterns: ["Bluesky"],
        charLimit: 300,
        name: "Bluesky",
        icon: "🦋"
    },
    "linkedin", {
        patterns: ["linkedin.com"],
        titlePatterns: ["LinkedIn"],
        charLimit: 3000,
        name: "LinkedIn",
        icon: "💼"
    },
    "mastodon", {
        patterns: ["mastodon", "mstdn", ".social"],
        titlePatterns: ["Mastodon"],
        charLimit: 500,
        name: "Mastodon",
        icon: "🐘"
    },
    "instagram", {
        patterns: ["instagram.com"],
        titlePatterns: ["Instagram"],
        charLimit: 2200,
        name: "Instagram",
        icon: "📷"
    },
    "threads", {
        patterns: ["threads.net"],
        titlePatterns: ["Threads"],
        charLimit: 500,
        name: "Threads",
        icon: "🧵"
    },
    "reddit", {
        patterns: ["reddit.com"],
        titlePatterns: ["Reddit"],
        charLimit: 40000,
        name: "Reddit",
        icon: "🤖"
    },
    "youtube", {
        patterns: ["youtube.com"],
        titlePatterns: ["YouTube"],
        charLimit: 5000,
        name: "YouTube",
        icon: "▶️"
    },
    "tiktok", {
        patterns: ["tiktok.com"],
        titlePatterns: ["TikTok"],
        charLimit: 2200,
        name: "TikTok",
        icon: "🎵"
    }
)

; State tracking
global SMD_Enabled := false
global SMD_LastPlatform := ""
global SMD_LastCaptureName := ""
global SMD_AutoPrepImage := true
global SMD_ShowNotifications := true
global SMD_CheckInterval := 2000  ; Check every 2 seconds

; ==============================================================================
; INITIALIZATION
; ==============================================================================

SMD_Initialize() {
    global SMD_Enabled
    
    if SMD_Enabled
        return
    
    ; Start monitoring timer
    SetTimer(SMD_CheckActivePlatform, SMD_CheckInterval)
    SMD_Enabled := true
}

SMD_Stop() {
    global SMD_Enabled
    
    SetTimer(SMD_CheckActivePlatform, 0)
    SMD_Enabled := false
}

SMD_Toggle() {
    global SMD_Enabled
    
    if SMD_Enabled
        SMD_Stop()
    else
        SMD_Initialize()
    
    TrayTip("Social Media Detection " (SMD_Enabled ? "ON" : "OFF"), "ContentCapture Pro", "1")
    return SMD_Enabled
}

; ==============================================================================
; PLATFORM DETECTION
; ==============================================================================

SMD_CheckActivePlatform() {
    global SMD_LastPlatform, SocialPlatforms, SMD_ShowNotifications
    
    ; Get active window info
    try {
        hwnd := WinGetID("A")
        title := WinGetTitle("A")
        processName := WinGetProcessName("A")
    } catch {
        return
    }
    
    ; Only check browsers
    browsers := ["chrome.exe", "firefox.exe", "msedge.exe", "brave.exe", "opera.exe", "vivaldi.exe", "safari.exe"]
    isBrowser := false
    for browser in browsers {
        if (StrLower(processName) = browser) {
            isBrowser := true
            break
        }
    }
    
    if !isBrowser
        return
    
    ; Detect platform from title
    platform := SMD_DetectPlatformFromTitle(title)
    
    ; Platform changed?
    if (platform != SMD_LastPlatform) {
        SMD_LastPlatform := platform
        
        if (platform != "" && SMD_ShowNotifications) {
            SMD_OnPlatformDetected(platform)
        }
    }
}

SMD_DetectPlatformFromTitle(title) {
    global SocialPlatforms
    
    titleLower := StrLower(title)
    
    for key, platform in SocialPlatforms {
        ; Check URL patterns (often in title)
        for pattern in platform.patterns {
            if InStr(titleLower, pattern)
                return key
        }
        
        ; Check title patterns
        for pattern in platform.titlePatterns {
            if InStr(title, pattern)
                return key
        }
    }
    
    return ""
}

; Get current platform (call anytime)
SMD_GetCurrentPlatform() {
    try {
        title := WinGetTitle("A")
        return SMD_DetectPlatformFromTitle(title)
    }
    return ""
}

; Get platform info
SMD_GetPlatformInfo(platformKey) {
    global SocialPlatforms
    
    if SocialPlatforms.Has(platformKey)
        return SocialPlatforms[platformKey]
    
    return ""
}

; ==============================================================================
; AUTO-ACTIONS ON PLATFORM DETECTION
; ==============================================================================

SMD_OnPlatformDetected(platform) {
    global SocialPlatforms, SMD_LastCaptureName, SMD_AutoPrepImage, CaptureData
    
    platformInfo := SocialPlatforms[platform]
    
    ; Check if we have a recent capture to share
    if (SMD_LastCaptureName != "" && CaptureData.Has(StrLower(SMD_LastCaptureName))) {
        
        ; Check if this capture has an image
        hasImage := IsSet(IC_HasImage) && IC_HasImage(SMD_LastCaptureName)
        
        if hasImage && SMD_AutoPrepImage {
            ; Auto-copy image to clipboard
            if IsSet(IC_CopyImageToClipboard) {
                imagePath := IC_GetImagePath(SMD_LastCaptureName)
                if (imagePath != "") {
                    IC_CopyImageToClipboard(imagePath)
                    TrayTip(
                        platformInfo.icon " " platformInfo.name " detected!`n" .
                        "📷 Image ready - Ctrl+V to paste`n" .
                        "📝 Ctrl+Shift+V for text",
                        "ContentCapture Pro", "1"
                    )
                    return
                }
            }
        }
        
        ; No image, but have text
        TrayTip(
            platformInfo.icon " " platformInfo.name " detected!`n" .
            "Press Ctrl+Shift+V to paste your content",
            "ContentCapture Pro", "1"
        )
    } else {
        ; Just notify platform detected
        TrayTip(
            platformInfo.icon " On " platformInfo.name "`n" .
            "Type a capture name + suffix to share",
            "ContentCapture Pro", "1"
        )
    }
}

; Set the "active" capture for quick sharing
SMD_SetActiveCapture(name) {
    global SMD_LastCaptureName
    SMD_LastCaptureName := name
}

; ==============================================================================
; QUICK PASTE HOTKEY
; ==============================================================================

; Ctrl+Shift+V - Paste active capture content (text)
^+v:: {
    global SMD_LastCaptureName, CaptureData
    
    if (SMD_LastCaptureName = "") {
        TrayTip("No active capture set", "ContentCapture Pro", "2")
        return
    }
    
    nameLower := StrLower(SMD_LastCaptureName)
    if !CaptureData.Has(nameLower) {
        TrayTip("Capture not found: " SMD_LastCaptureName, "ContentCapture Pro", "2")
        return
    }
    
    capture := CaptureData[nameLower]
    
    ; Build share content
    content := ""
    if (capture.Has("opinion") && capture["opinion"] != "")
        content .= capture["opinion"] . "`r`n`r`n"
    if (capture.Has("title") && capture["title"] != "")
        content .= capture["title"] . "`r`n"
    if (capture.Has("url") && capture["url"] != "")
        content .= capture["url"]
    
    ; Check character limit for current platform
    platform := SMD_GetCurrentPlatform()
    if (platform != "") {
        platformInfo := SMD_GetPlatformInfo(platform)
        if (platformInfo != "" && StrLen(content) > platformInfo.charLimit) {
            TrayTip(
                "⚠️ Content exceeds " platformInfo.name " limit!`n" .
                StrLen(content) " / " platformInfo.charLimit " chars",
                "ContentCapture Pro", "2"
            )
        }
    }
    
    ; Paste
    A_Clipboard := content
    ClipWait(1)
    Send("^v")
}

; ==============================================================================
; SMART SHARE FUNCTION
; ==============================================================================

; Call this when user triggers any share action
; It will auto-detect platform and prep appropriately
SMD_SmartShare(captureName) {
    global CaptureData
    
    ; Remember this capture
    SMD_SetActiveCapture(captureName)
    
    ; Get current platform
    platform := SMD_GetCurrentPlatform()
    
    if (platform = "") {
        ; Not on social media - just copy to clipboard
        return false
    }
    
    ; On social media - check for image
    hasImage := IsSet(IC_HasImage) && IC_HasImage(captureName)
    
    if hasImage {
        ; Copy image to clipboard
        if IsSet(IC_CopyImageToClipboard) {
            imagePath := IC_GetImagePath(captureName)
            if (imagePath != "" && IC_CopyImageToClipboard(imagePath)) {
                TrayTip("📷 Image ready! Paste with Ctrl+V", captureName, "1")
                return true
            }
        }
    }
    
    return false
}

; ==============================================================================
; CHARACTER LIMIT CHECKER
; ==============================================================================

SMD_CheckCharacterLimit(text, platformKey := "") {
    global SocialPlatforms
    
    ; If no platform specified, detect current
    if (platformKey = "")
        platformKey := SMD_GetCurrentPlatform()
    
    if (platformKey = "" || !SocialPlatforms.Has(platformKey))
        return {ok: true, message: ""}
    
    platform := SocialPlatforms[platformKey]
    textLen := StrLen(text)
    
    if (textLen <= platform.charLimit) {
        remaining := platform.charLimit - textLen
        return {
            ok: true,
            message: platform.icon " " textLen "/" platform.charLimit " (" remaining " remaining)"
        }
    } else {
        over := textLen - platform.charLimit
        return {
            ok: false,
            message: "⚠️ " textLen "/" platform.charLimit " (" over " over limit!)"
        }
    }
}

; ==============================================================================
; GUI HELPER - Platform indicator for dialogs
; ==============================================================================

SMD_GetCurrentPlatformDisplay() {
    platform := SMD_GetCurrentPlatform()
    
    if (platform = "")
        return ""
    
    info := SMD_GetPlatformInfo(platform)
    if (info = "")
        return ""
    
    return info.icon " " info.name " (limit: " info.charLimit " chars)"
}

; ==============================================================================
; INITIALIZATION - Start monitoring on load
; ==============================================================================
SMD_Initialize()
