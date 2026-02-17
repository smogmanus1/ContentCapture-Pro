#Requires AutoHotkey v2.0+

; ==============================================================================
; SocialImageShare.ahk - Image-Aware Social Media Sharing for ContentCapture Pro
; ==============================================================================
; Version:     1.0
; Created:     2026-02-17
;
; PURPOSE: Enhances ALL social media sharing suffixes to detect attached images
;          and offer to include them in posts and comments across every platform.
;
; SUPPORTED PLATFORMS:
;   fb  / fbc  → Facebook (post / comment)
;   x          → Twitter/X
;   bs         → Bluesky
;   li         → LinkedIn
;   mt         → Mastodon
;
; HOW IT WORKS:
;   - When any social suffix fires, checks if the record has an attached image
;   - If image exists, prompts user: "Include image in your [Platform] post?"
;   - If Yes: copies image to clipboard, opens platform, pastes text + image
;   - If No: proceeds with standard text-only sharing
;
; CLIPBOARD IMAGE PASTE SUPPORT:
;   All major social platforms accept Ctrl+V image paste in their compose boxes:
;   ✅ Facebook (posts + comments)
;   ✅ Twitter/X (compose tweet)
;   ✅ Bluesky (compose post)
;   ✅ LinkedIn (create post)
;   ✅ Mastodon (compose toot)
;
; DEPENDENCIES:
;   - ImageCapture.ahk (IC_HasImage, IC_GetImagePath functions)
;   - ContentCapture-Pro.ahk (CC_SafePaste, CC_SafeCopy)
;   - DynamicSuffixHandler.ahk (URLEncode, BuildContent, character limits)
;
; USAGE:
;   Called from DynamicSuffixHandler.ahk Action methods
;   #Include SocialImageShare.ahk (after ImageCapture.ahk)
; ==============================================================================


; ==============================================================================
; PLATFORM CONFIGURATION
; ==============================================================================
; Central config for each platform's URLs, names, and icons.
; Easy to add new platforms - just add an entry here.
; ==============================================================================

class SocialPlatforms {
    ; Platform display names and icons for MsgBox prompts
    static Info := Map(
        "facebook",  Map("name", "Facebook",   "icon", "📘", "postUrl", "https://www.facebook.com/",           "sharerUrl", "https://www.facebook.com/sharer/sharer.php?u="),
        "twitter",   Map("name", "Twitter/X",  "icon", "🐦", "postUrl", "https://x.com/compose/post",          "sharerUrl", "https://twitter.com/intent/tweet?"),
        "bluesky",   Map("name", "Bluesky",    "icon", "🦋", "postUrl", "https://bsky.app/",                   "sharerUrl", ""),
        "linkedin",  Map("name", "LinkedIn",   "icon", "💼", "postUrl", "https://www.linkedin.com/feed/",      "sharerUrl", "https://www.linkedin.com/sharing/share-offsite/?url="),
        "mastodon",  Map("name", "Mastodon",   "icon", "🐘", "postUrl", "",                                    "sharerUrl", "")
    )
    
    static GetName(platform)     => this.Info.Has(platform) ? this.Info[platform]["name"]     : platform
    static GetIcon(platform)     => this.Info.Has(platform) ? this.Info[platform]["icon"]     : "📤"
    static GetPostUrl(platform)  => this.Info.Has(platform) ? this.Info[platform]["postUrl"]  : ""
    static GetSharerUrl(platform) => this.Info.Has(platform) ? this.Info[platform]["sharerUrl"] : ""
}


; ==============================================================================
; SI_CopyImageToClipboard - Load image file into clipboard as bitmap
; ==============================================================================
; Uses PowerShell to load image into Windows clipboard as a bitmap object.
; All social media compose boxes accept Ctrl+V paste of clipboard images.
;
; @param imagePath - Full path to image file (png, jpg, gif, bmp, webp)
; @return true if successful, false on error
; ==============================================================================
SI_CopyImageToClipboard(imagePath) {
    if (imagePath = "" || !FileExist(imagePath))
        return false
    
    ; Escape path for PowerShell
    psPath := StrReplace(imagePath, "'", "''")
    
    psScript := "Add-Type -AssemblyName System.Windows.Forms; "
              . "Add-Type -AssemblyName System.Drawing; "
              . "$img = [System.Drawing.Image]::FromFile('" psPath "'); "
              . "[System.Windows.Forms.Clipboard]::SetImage($img); "
              . "$img.Dispose()"
    
    try {
        RunWait('powershell -NoProfile -WindowStyle Hidden -Command "' psScript '"',, "Hide")
        Sleep(200)  ; Let clipboard settle
        return true
    } catch as err {
        TrayTip("Failed to copy image: " err.Message, "Image Error", "2")
        return false
    }
}


; ==============================================================================
; SI_CheckForImage - Check if a capture has an attached image
; ==============================================================================
; @param name - The capture/script name (e.g., "rand50")
; @return image path if found and file exists, empty string if not
; ==============================================================================
SI_CheckForImage(name) {
    imgPath := ""
    
    ; Primary check: ImageCapture module
    try {
        if IsSet(IC_HasImage) && IC_HasImage(name) {
            if IsSet(IC_GetImagePath)
                imgPath := IC_GetImagePath(name)
        }
    }
    
    ; Return path only if file actually exists
    if (imgPath != "" && FileExist(imgPath))
        return imgPath
    
    return ""
}


; ==============================================================================
; SI_AskIncludeImage - Prompt user to include image
; ==============================================================================
; Shows a consistent MsgBox across all platforms asking if user wants
; to include the attached image.
;
; @param platform - Platform key (e.g., "facebook", "twitter")
; @param imgPath  - Path to the image file
; @param isComment - true if sharing to a comment box (vs new post)
; @return true if user wants image, false if not
; ==============================================================================
SI_AskIncludeImage(platform, imgPath, isComment := false) {
    platName := SocialPlatforms.GetName(platform)
    platIcon := SocialPlatforms.GetIcon(platform)
    action := isComment ? "comment" : "post"
    
    ; Get just the filename for display
    SplitPath(imgPath, &fileName)
    
    result := MsgBox(
        "This record has an attached image.`n`n"
        "Include the image in your " platName " " action "?`n`n"
        "YES = Share text + image`n"
        "NO = Share text only`n`n"
        "Image: " fileName,
        platIcon " Image Available - " platName,
        "YesNo Icon?"
    )
    
    return (result = "Yes")
}


; ==============================================================================
; SI_SharePost - Universal POST sharing with image support
; ==============================================================================
; Handles new post creation for ANY platform with image detection.
;
; WORKFLOW (with image, user says Yes):
;   1. Copy text content to clipboard
;   2. Open platform's compose page (not sharer URL)
;   3. Show tooltip with Ctrl+Shift+V instructions
;   4. User pastes text (Ctrl+V), then image (Ctrl+Shift+V)
;
; WORKFLOW (no image, or user says No):
;   1. Standard behavior - sharer URL or compose page
;
; @param platform - Platform key ("facebook", "twitter", "bluesky", "linkedin", "mastodon")
; @param name     - Capture name
; @param capture  - Capture data Map
; @param content  - Pre-built content string
; @param url      - The record's URL
; ==============================================================================
SI_SharePost(platform, name, capture, content, url) {
    imgPath := SI_CheckForImage(name)
    platName := SocialPlatforms.GetName(platform)
    platIcon := SocialPlatforms.GetIcon(platform)
    
    if (imgPath != "" && SI_AskIncludeImage(platform, imgPath, false)) {
        ; ═══════════════════════════════════════════════════
        ; IMAGE POST WORKFLOW
        ; ═══════════════════════════════════════════════════
        
        ; Step 1: Copy text content to clipboard
        CC_SafeCopy(content)
        
        ; Step 2: Open platform's compose page (not sharer - we need image support)
        composeUrl := SI_GetComposeUrl(platform, capture, content, url)
        if (composeUrl != "")
            Run(composeUrl)
        
        ; Step 3: Set up pending image paste
        SI_SetPendingImage(imgPath, platName, platIcon)
        
        return
    }
    
    ; ═══════════════════════════════════════════════════
    ; STANDARD POST WORKFLOW (no image or user said No)
    ; ═══════════════════════════════════════════════════
    CC_SafeCopy(content)
    
    standardUrl := SI_GetStandardShareUrl(platform, capture, content, url)
    if (standardUrl != "")
        Run(standardUrl)
    
    TrayTip("Content copied! Paste with Ctrl+V", platIcon " " platName " Share", "1")
}


; ==============================================================================
; SI_ShareComment - Universal COMMENT sharing with image support
; ==============================================================================
; Handles comment/reply posting for ANY platform with image detection.
; Comments auto-paste both text AND image (no manual Ctrl+Shift+V needed).
;
; WORKFLOW (with image, user says Yes):
;   1. Paste text content into comment box
;   2. Brief delay for platform to process
;   3. Copy image to clipboard via PowerShell
;   4. Auto-paste image (Ctrl+V)
;
; WORKFLOW (no image, or user says No):
;   1. Standard behavior - paste text only
;
; @param platform - Platform key
; @param name     - Capture name
; @param capture  - Capture data Map
; ==============================================================================
SI_ShareComment(platform, name, capture) {
    platName := SocialPlatforms.GetName(platform)
    platIcon := SocialPlatforms.GetIcon(platform)
    
    ; Build comment content (always includes URL)
    content := ""
    
    if (capture.Has("short") && capture["short"] != "") {
        content := capture["short"]
    } else if (capture.Has("title") && capture["title"] != "") {
        content := capture["title"]
    }
    
    ; Always append URL for comments
    if (capture.Has("url") && capture["url"] != "") {
        if (content != "")
            content .= "`n"
        content .= capture["url"]
    }
    
    if (content = "") {
        TrayTip("No content to share", platIcon " " platName " Comment", "2")
        return
    }
    
    ; Apply character limits for platforms that need them
    content := SI_ApplyCharLimit(platform, content)
    
    imgPath := SI_CheckForImage(name)
    
    if (imgPath != "" && SI_AskIncludeImage(platform, imgPath, true)) {
        ; ═══════════════════════════════════════════════════
        ; IMAGE COMMENT WORKFLOW (fully automatic)
        ; ═══════════════════════════════════════════════════
        
        ; Step 1: Paste text content first
        CC_SafePaste(content)
        
        ; Step 2: Brief delay for platform to process the text paste
        Sleep(800)
        
        ; Step 3: Load image to clipboard
        if SI_CopyImageToClipboard(imgPath) {
            ; Step 4: Auto-paste the image
            Sleep(300)
            Send("^v")
            
            TrayTip("Text + image pasted!", platIcon " " platName " Comment", "1")
        } else {
            TrayTip("Text pasted, but image failed to load", platIcon " " platName, "2")
        }
        
        return
    }
    
    ; ═══════════════════════════════════════════════════
    ; STANDARD COMMENT WORKFLOW (no image or user said No)
    ; ═══════════════════════════════════════════════════
    CC_SafePaste(content)
    TrayTip("Comment pasted", platIcon " " platName " Comment", "1")
}


; ==============================================================================
; SI_GetComposeUrl - Get the compose/create post URL for a platform
; ==============================================================================
; When sharing with an image, we open the compose page directly instead of
; the sharer URL, because sharer URLs don't support image uploads.
;
; @param platform - Platform key
; @param capture  - Capture data Map
; @param content  - Content string
; @param url      - Record URL
; @return URL string to open
; ==============================================================================
SI_GetComposeUrl(platform, capture, content, url) {
    switch platform {
        case "facebook":
            return "https://www.facebook.com/"
        
        case "twitter":
            ; Twitter compose accepts text parameter even without sharer
            return "https://x.com/compose/post"
        
        case "bluesky":
            return "https://bsky.app/"
        
        case "linkedin":
            return "https://www.linkedin.com/feed/"
        
        case "mastodon":
            ; Mastodon doesn't have a universal compose URL
            ; User needs to be on their instance already
            return ""
        
        default:
            return ""
    }
}


; ==============================================================================
; SI_GetStandardShareUrl - Get the standard share URL (no image, text only)
; ==============================================================================
; Falls back to sharer/intent URLs when no image is needed.
; This is the original behavior before image support was added.
;
; @param platform - Platform key
; @param capture  - Capture data Map
; @param content  - Content string
; @param url      - Record URL
; @return URL string to open
; ==============================================================================
SI_GetStandardShareUrl(platform, capture, content, url) {
    switch platform {
        case "facebook":
            if (url != "")
                return "https://www.facebook.com/sharer/sharer.php?u=" . SI_URLEncode(url)
            return "https://www.facebook.com/"
        
        case "twitter":
            hasShort := capture.Has("short") && capture["short"] != ""
            tweetText := hasShort ? capture["short"] : (capture.Has("title") ? capture["title"] : "")
            shareURL := "https://twitter.com/intent/tweet?"
            if (tweetText != "")
                shareURL .= "text=" . SI_URLEncode(tweetText)
            if (url != "")
                shareURL .= "&url=" . SI_URLEncode(url)
            return shareURL
        
        case "bluesky":
            return "https://bsky.app/"
        
        case "linkedin":
            if (url != "")
                return "https://www.linkedin.com/sharing/share-offsite/?url=" . SI_URLEncode(url)
            return "https://www.linkedin.com/feed/"
        
        case "mastodon":
            return ""
        
        default:
            return ""
    }
}


; ==============================================================================
; SI_ApplyCharLimit - Apply platform character limits
; ==============================================================================
; @param platform - Platform key
; @param content  - Content string
; @return Trimmed content string
; ==============================================================================
SI_ApplyCharLimit(platform, content) {
    limits := Map(
        "twitter",  280,
        "bluesky",  300,
        "mastodon", 500
    )
    
    if (limits.Has(platform)) {
        maxLen := limits[platform]
        if (StrLen(content) > maxLen)
            content := SubStr(content, 1, maxLen - 3) . "..."
    }
    
    return content
}


; ==============================================================================
; PENDING IMAGE PASTE SYSTEM
; ==============================================================================
; After user pastes text into a compose box, these functions manage the
; temporary Ctrl+Shift+V hotkey for pasting the image.
;
; FLOW:
;   1. SI_SetPendingImage() - registers hotkey + shows tooltip
;   2. User presses Ctrl+Shift+V → SI_DoPasteImage() fires
;   3. Image loaded to clipboard → pasted → hotkeys cleaned up
;   4. Or user presses Escape → cancelled → hotkeys cleaned up
;   5. Auto-cleanup after 60 seconds if user does nothing
; ==============================================================================

global SI_PendingImagePath := ""
global SI_PendingPlatform := ""

SI_SetPendingImage(imgPath, platName, platIcon) {
    global SI_PendingImagePath, SI_PendingPlatform
    SI_PendingImagePath := imgPath
    SI_PendingPlatform := platName
    
    ; Register temporary hotkeys
    Hotkey("^+v", SI_DoPasteImage, "On")
    Hotkey("Escape", SI_CancelPaste, "On")
    
    ; Show persistent tooltip with instructions
    ToolTip(
        platIcon " IMAGE READY FOR " StrUpper(platName) "!`n`n"
        "1. Click in the compose/post box`n"
        "2. Ctrl+V = paste your text`n"
        "3. Ctrl+Shift+V = paste the IMAGE`n`n"
        "Press Escape to cancel"
    )
    
    ; Auto-cleanup after 60 seconds
    SetTimer(SI_AutoCleanup, -60000)
}

SI_DoPasteImage(*) {
    global SI_PendingImagePath, SI_PendingPlatform
    
    if (SI_PendingImagePath = "" || !FileExist(SI_PendingImagePath)) {
        TrayTip("No pending image to paste", "Image Error", "2")
        SI_Cleanup()
        return
    }
    
    ; Load image to clipboard and paste
    if SI_CopyImageToClipboard(SI_PendingImagePath) {
        Sleep(200)
        Send("^v")
        TrayTip("📷 Image pasted to " SI_PendingPlatform "!", "Image Share", "1")
    } else {
        TrayTip("Failed to paste image", "Image Error", "2")
    }
    
    SI_Cleanup()
}

SI_CancelPaste(*) {
    TrayTip("Image paste cancelled", "Cancelled", "1")
    SI_Cleanup()
}

SI_AutoCleanup() {
    SI_Cleanup()
}

SI_Cleanup() {
    global SI_PendingImagePath, SI_PendingPlatform
    SI_PendingImagePath := ""
    SI_PendingPlatform := ""
    ToolTip()
    
    try Hotkey("^+v", SI_DoPasteImage, "Off")
    try Hotkey("Escape", SI_CancelPaste, "Off")
}


; ==============================================================================
; SI_URLEncode - URL encode a string
; ==============================================================================
; Local copy so this module works independently if needed.
; ==============================================================================
SI_URLEncode(str) {
    encoded := ""
    for i, char in StrSplit(str) {
        if RegExMatch(char, "[a-zA-Z0-9_.\-~]")
            encoded .= char
        else if (char = " ")
            encoded .= "+"
        else
            encoded .= "%" Format("{:02X}", Ord(char))
    }
    return encoded
}
