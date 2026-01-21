; ==============================================================================
; ImageSharing.ahk - Multi-Image Social Media Sharing Module for ContentCapture Pro
; ==============================================================================
; Version: 2.0
; Supports: Facebook, Twitter/X, Bluesky, LinkedIn, Mastodon
; Features: Multiple image support, auto-paste, platform detection
; ==============================================================================

#Requires AutoHotkey v2.0

; ==============================================================================
; PLATFORM IMAGE LIMITS
; ==============================================================================
; Facebook Post:    Up to 10 images
; Facebook Comment: 1 image only
; Twitter/X:        Up to 4 images
; Bluesky:          Up to 4 images  
; LinkedIn:         Up to 9 images (posts), 1 image (comments)
; Mastodon:         Up to 4 images
; ==============================================================================

global IS_ImageLimits := Map(
    "facebook_post", 10,
    "facebook_comment", 1,
    "twitter", 4,
    "bluesky", 4,
    "linkedin_post", 9,
    "linkedin_comment", 1,
    "mastodon", 4,
    "email", 10
)

; ==============================================================================
; MAIN ENTRY POINTS - Called by DynamicSuffixHandler
; ==============================================================================

; Single image to clipboard (img suffix)
IS_CopyImageToClipboard(captureName) {
    global CaptureData, BaseDir
    
    if !CaptureData.Has(captureName) {
        ShowNotification("Capture not found: " captureName, "Error", 2000)
        return false
    }
    
    images := IS_GetCaptureImages(captureName)
    if images.Length = 0 {
        ShowNotification("No images attached to: " captureName, "No Image", 2000)
        return false
    }
    
    ; Copy first image to clipboard
    imagePath := images[1]
    if IS_CopyImageFileToClipboard(imagePath) {
        ShowNotification("Image copied to clipboard`n" IS_GetFileName(imagePath), "📷 Ready to Paste", 2000)
        return true
    }
    return false
}

; Open image in default viewer (imgo suffix)
IS_OpenImage(captureName) {
    global CaptureData, BaseDir
    
    images := IS_GetCaptureImages(captureName)
    if images.Length = 0 {
        ShowNotification("No images attached to: " captureName, "No Image", 2000)
        return false
    }
    
    ; Open first image (or all if multiple)
    for imagePath in images {
        if FileExist(imagePath)
            Run(imagePath)
    }
    return true
}

; Share to platform WITH image (fbi, xi, bsi, li, mti suffixes)
IS_ShareWithImage(captureName, platform) {
    global CaptureData
    
    if !CaptureData.Has(captureName) {
        ShowNotification("Capture not found: " captureName, "Error", 2000)
        return false
    }
    
    cap := CaptureData[captureName]
    images := IS_GetCaptureImages(captureName)
    
    ; Build content
    content := IS_BuildShareContent(cap, platform)
    
    ; Determine sharing method based on platform
    switch platform {
        case "facebook":
            return IS_ShareToFacebook(content, images)
        case "twitter", "x":
            return IS_ShareToTwitter(content, images)
        case "bluesky":
            return IS_ShareToBluesky(content, images)
        case "linkedin":
            return IS_ShareToLinkedIn(content, images)
        case "mastodon":
            return IS_ShareToMastodon(content, images)
        default:
            ShowNotification("Unknown platform: " platform, "Error", 2000)
            return false
    }
}

; Email with image attachment (emi suffix)
IS_EmailWithImage(captureName) {
    global CaptureData
    
    if !CaptureData.Has(captureName) {
        ShowNotification("Capture not found: " captureName, "Error", 2000)
        return false
    }
    
    cap := CaptureData[captureName]
    images := IS_GetCaptureImages(captureName)
    
    ; Build email content
    subject := cap.Has("title") ? cap["title"] : captureName
    body := IS_BuildEmailBody(cap)
    
    return IS_SendOutlookEmailWithImages(subject, body, images)
}

; ==============================================================================
; IMAGE RETRIEVAL
; ==============================================================================

; Get all images associated with a capture
IS_GetCaptureImages(captureName) {
    global BaseDir
    images := []
    
    ; Check images.dat for associations
    imagesFile := BaseDir "\images.dat"
    if FileExist(imagesFile) {
        content := FileRead(imagesFile)
        
        ; Parse images.dat - format: captureName|imagePath1|imagePath2|...
        Loop Parse, content, "`n", "`r" {
            if A_LoopField = ""
                continue
            parts := StrSplit(A_LoopField, "|")
            if parts.Length >= 2 && parts[1] = captureName {
                Loop parts.Length - 1 {
                    imgPath := parts[A_Index + 1]
                    if imgPath != "" {
                        ; Handle relative paths
                        if !InStr(imgPath, ":") && !InStr(imgPath, "\\")
                            imgPath := BaseDir "\images\" imgPath
                        if FileExist(imgPath)
                            images.Push(imgPath)
                    }
                }
                break
            }
        }
    }
    
    ; Also check CaptureData for image field
    global CaptureData
    if CaptureData.Has(captureName) {
        cap := CaptureData[captureName]
        if cap.Has("image") && cap["image"] != "" {
            imgPath := cap["image"]
            if !InStr(imgPath, ":") && !InStr(imgPath, "\\")
                imgPath := BaseDir "\images\" imgPath
            if FileExist(imgPath) && !IS_ArrayContains(images, imgPath)
                images.Push(imgPath)
        }
        ; Check for multiple images field
        if cap.Has("images") && cap["images"] != "" {
            for imgPath in StrSplit(cap["images"], "|") {
                if imgPath = ""
                    continue
                if !InStr(imgPath, ":") && !InStr(imgPath, "\\")
                    imgPath := BaseDir "\images\" imgPath
                if FileExist(imgPath) && !IS_ArrayContains(images, imgPath)
                    images.Push(imgPath)
            }
        }
    }
    
    return images
}

IS_ArrayContains(arr, value) {
    for item in arr {
        if item = value
            return true
    }
    return false
}

IS_GetFileName(path) {
    SplitPath(path, &name)
    return name
}

; ==============================================================================
; CLIPBOARD IMAGE HANDLING (GDI+)
; ==============================================================================

IS_CopyImageFileToClipboard(imagePath) {
    if !FileExist(imagePath) {
        return false
    }
    
    ; Initialize GDI+
    pToken := 0
    si := Buffer(24, 0)  ; GdiplusStartupInput
    NumPut("UInt", 1, si, 0)  ; GdiplusVersion
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken, "Ptr", si, "Ptr", 0)
    
    ; Load image
    pBitmap := 0
    DllCall("gdiplus\GdipCreateBitmapFromFile", "Str", imagePath, "Ptr*", &pBitmap)
    
    if !pBitmap {
        DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
        return false
    }
    
    ; Get HBITMAP
    hBitmap := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "Ptr*", &hBitmap, "UInt", 0xFFFFFFFF)
    
    ; Copy to clipboard
    if hBitmap {
        DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
        DllCall("EmptyClipboard")
        DllCall("SetClipboardData", "UInt", 2, "Ptr", hBitmap)  ; CF_BITMAP = 2
        DllCall("CloseClipboard")
    }
    
    ; Cleanup
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
    
    return hBitmap != 0
}

; ==============================================================================
; CONTENT BUILDING
; ==============================================================================

IS_BuildShareContent(cap, platform) {
    content := ""
    
    ; Get character limit for platform
    charLimit := IS_GetCharLimit(platform)
    
    ; Build base content
    if cap.Has("body") && cap["body"] != ""
        content := cap["body"]
    else if cap.Has("title") && cap["title"] != ""
        content := cap["title"]
    
    ; Add URL if present
    if cap.Has("url") && cap["url"] != "" {
        url := cap["url"]
        ; Clean tracking parameters
        url := IS_CleanURL(url)
        if content != ""
            content .= "`n`n" url
        else
            content := url
    }
    
    ; Truncate if needed (leave room for images reducing URL preview)
    if StrLen(content) > charLimit {
        content := SubStr(content, 1, charLimit - 3) "..."
    }
    
    return content
}

IS_BuildEmailBody(cap) {
    body := ""
    
    if cap.Has("body") && cap["body"] != ""
        body := cap["body"]
    else if cap.Has("title") && cap["title"] != ""
        body := cap["title"]
    
    if cap.Has("url") && cap["url"] != "" {
        if body != ""
            body .= "`n`n"
        body .= cap["url"]
    }
    
    return body
}

IS_GetCharLimit(platform) {
    limits := Map(
        "twitter", 280,
        "x", 280,
        "bluesky", 300,
        "facebook", 63206,
        "linkedin", 3000,
        "mastodon", 500
    )
    return limits.Has(platform) ? limits[platform] : 5000
}

IS_CleanURL(url) {
    ; Remove common tracking parameters
    trackingParams := ["utm_source", "utm_medium", "utm_campaign", "utm_content", 
                       "utm_term", "fbclid", "gclid", "ref", "source"]
    
    if InStr(url, "?") {
        parts := StrSplit(url, "?", , 2)
        baseUrl := parts[1]
        if parts.Length > 1 {
            params := StrSplit(parts[2], "&")
            cleanParams := []
            for param in params {
                isTracking := false
                for tracker in trackingParams {
                    if InStr(param, tracker "=") = 1 {
                        isTracking := true
                        break
                    }
                }
                if !isTracking
                    cleanParams.Push(param)
            }
            if cleanParams.Length > 0
                return baseUrl "?" IS_JoinArray(cleanParams, "&")
            return baseUrl
        }
    }
    return url
}

IS_JoinArray(arr, delimiter) {
    result := ""
    for i, item in arr {
        if i > 1
            result .= delimiter
        result .= item
    }
    return result
}

; ==============================================================================
; PLATFORM-SPECIFIC SHARING
; ==============================================================================

; Facebook sharing with images
IS_ShareToFacebook(content, images) {
    ; Detect if we're in a Facebook post or comment
    isComment := IS_DetectFacebookContext()
    maxImages := isComment ? IS_ImageLimits["facebook_comment"] : IS_ImageLimits["facebook_post"]
    
    ; Limit images to platform max
    imagesToShare := []
    Loop Min(images.Length, maxImages)
        imagesToShare.Push(images[A_Index])
    
    ; Ask user preference: Image first or Text first?
    if imagesToShare.Length > 0 {
        result := MsgBox("Share to Facebook with " imagesToShare.Length " image(s)?`n`n"
                        "YES = Upload image(s) first, then paste text`n"
                        "NO = Paste text first, then upload image(s)`n"
                        "CANCEL = Text only (no images)",
                        "📷 Facebook Share", "YesNoCancel Icon?")
        
        if result = "Cancel" {
            ; Text only
            A_Clipboard := content
            ClipWait(2)
            ShowNotification("Text copied - paste with Ctrl+V", "📋 Ready", 2000)
            return true
        }
        
        if result = "Yes" {
            ; Images first approach
            return IS_FacebookImagesFirst(content, imagesToShare)
        } else {
            ; Text first approach
            return IS_FacebookTextFirst(content, imagesToShare)
        }
    } else {
        ; No images, just copy text
        A_Clipboard := content
        ClipWait(2)
        ShowNotification("Text copied - paste with Ctrl+V", "📋 Ready", 2000)
        return true
    }
}

IS_FacebookImagesFirst(content, images) {
    ; Copy first image to clipboard
    if images.Length > 0 {
        IS_CopyImageFileToClipboard(images[1])
        
        ShowNotification("Image on clipboard!`n"
                        "1. Click in Facebook post area`n"
                        "2. Press Ctrl+V to paste image`n"
                        "3. Wait for upload`n"
                        "4. Press Ctrl+Alt+V for text",
                        "📷 Step 1: Paste Image", 5000)
        
        ; Store content for second paste
        global IS_PendingContent := content
        global IS_PendingImages := images
        global IS_CurrentImageIndex := 2
        
        ; Set up hotkey for text paste
        Hotkey("^!v", IS_FacebookPasteText, "On")
        
        return true
    }
    return false
}

IS_FacebookPasteText(*) {
    global IS_PendingContent, IS_PendingImages, IS_CurrentImageIndex
    
    ; Disable hotkey
    Hotkey("^!v", IS_FacebookPasteText, "Off")
    
    ; Paste the text
    A_Clipboard := IS_PendingContent
    ClipWait(2)
    Send("^v")
    
    ; If more images, offer to add them
    if IS_PendingImages.Length >= IS_CurrentImageIndex {
        Sleep(500)
        ShowNotification("Text pasted!`n"
                        "More images available.`n"
                        "Press Ctrl+Alt+I to add next image",
                        "📝 Text Added", 3000)
        Hotkey("^!i", IS_FacebookNextImage, "On")
    } else {
        ShowNotification("Share complete!", "✅ Done", 2000)
    }
}

IS_FacebookNextImage(*) {
    global IS_PendingImages, IS_CurrentImageIndex
    
    if IS_CurrentImageIndex <= IS_PendingImages.Length {
        IS_CopyImageFileToClipboard(IS_PendingImages[IS_CurrentImageIndex])
        IS_CurrentImageIndex++
        
        if IS_CurrentImageIndex <= IS_PendingImages.Length {
            ShowNotification("Image " (IS_CurrentImageIndex-1) " ready!`n"
                            "Press Ctrl+V to paste`n"
                            "Press Ctrl+Alt+I for next",
                            "📷 Image Ready", 3000)
        } else {
            Hotkey("^!i", IS_FacebookNextImage, "Off")
            ShowNotification("Last image ready!`nPress Ctrl+V to paste",
                            "📷 Final Image", 3000)
        }
    }
}

IS_FacebookTextFirst(content, images) {
    ; Copy text first
    A_Clipboard := content
    ClipWait(2)
    
    ShowNotification("Text on clipboard!`n"
                    "1. Click in Facebook post area`n"
                    "2. Press Ctrl+V to paste text`n"
                    "3. Press Ctrl+Alt+I for image",
                    "📝 Step 1: Paste Text", 4000)
    
    ; Store images for later
    global IS_PendingImages := images
    global IS_CurrentImageIndex := 1
    
    ; Set up hotkey for image paste
    Hotkey("^!i", IS_FacebookNextImage, "On")
    
    return true
}

IS_DetectFacebookContext() {
    ; Try to detect if user is in a comment field vs post field
    ; Returns true if comment, false if post
    title := WinGetTitle("A")
    return InStr(title, "Comment") || InStr(title, "Reply")
}

; Twitter/X sharing
IS_ShareToTwitter(content, images) {
    maxImages := IS_ImageLimits["twitter"]
    imagesToShare := []
    Loop Min(images.Length, maxImages)
        imagesToShare.Push(images[A_Index])
    
    ; Open Twitter compose
    composeUrl := "https://twitter.com/intent/tweet?text=" IS_EncodeURIComponent(content)
    Run(composeUrl)
    
    if imagesToShare.Length > 0 {
        Sleep(2000)
        ShowNotification("Twitter opened!`n"
                        imagesToShare.Length " image(s) ready.`n"
                        "Press Ctrl+Alt+I to copy each image",
                        "🐦 Add Images", 4000)
        
        global IS_PendingImages := imagesToShare
        global IS_CurrentImageIndex := 1
        Hotkey("^!i", IS_GenericNextImage, "On")
    }
    
    return true
}

; Bluesky sharing  
IS_ShareToBluesky(content, images) {
    maxImages := IS_ImageLimits["bluesky"]
    imagesToShare := []
    Loop Min(images.Length, maxImages)
        imagesToShare.Push(images[A_Index])
    
    ; Bluesky intent URL (if logged in)
    ; Note: Bluesky doesn't have a standard intent URL yet, so we open the site
    Run("https://bsky.app/")
    
    Sleep(2000)
    
    ; Copy content
    A_Clipboard := content
    ClipWait(2)
    
    if imagesToShare.Length > 0 {
        ShowNotification("Bluesky opened!`n"
                        "Text on clipboard (Ctrl+V)`n"
                        imagesToShare.Length " image(s) ready.`n"
                        "Press Ctrl+Alt+I after pasting text",
                        "🦋 Bluesky Share", 4000)
        
        global IS_PendingImages := imagesToShare
        global IS_CurrentImageIndex := 1
        Hotkey("^!i", IS_GenericNextImage, "On")
    } else {
        ShowNotification("Bluesky opened!`nText on clipboard - paste with Ctrl+V",
                        "🦋 Bluesky Share", 3000)
    }
    
    return true
}

; LinkedIn sharing
IS_ShareToLinkedIn(content, images) {
    maxImages := IS_ImageLimits["linkedin_post"]
    imagesToShare := []
    Loop Min(images.Length, maxImages)
        imagesToShare.Push(images[A_Index])
    
    ; LinkedIn share URL
    url := ""
    global CaptureData
    ; Try to extract URL from content or use share URL
    Run("https://www.linkedin.com/feed/")
    
    Sleep(2000)
    A_Clipboard := content
    ClipWait(2)
    
    if imagesToShare.Length > 0 {
        ShowNotification("LinkedIn opened!`n"
                        "Text on clipboard (Ctrl+V)`n"
                        imagesToShare.Length " image(s) ready.`n"
                        "Press Ctrl+Alt+I for images",
                        "💼 LinkedIn Share", 4000)
        
        global IS_PendingImages := imagesToShare
        global IS_CurrentImageIndex := 1
        Hotkey("^!i", IS_GenericNextImage, "On")
    } else {
        ShowNotification("LinkedIn opened!`nText on clipboard - paste with Ctrl+V",
                        "💼 LinkedIn Share", 3000)
    }
    
    return true
}

; Mastodon sharing
IS_ShareToMastodon(content, images) {
    maxImages := IS_ImageLimits["mastodon"]
    imagesToShare := []
    Loop Min(images.Length, maxImages)
        imagesToShare.Push(images[A_Index])
    
    ; Mastodon doesn't have universal intent - user needs to be on their instance
    ; Copy content and notify
    A_Clipboard := content
    ClipWait(2)
    
    if imagesToShare.Length > 0 {
        ShowNotification("Text on clipboard!`n"
                        "Open your Mastodon instance`n"
                        imagesToShare.Length " image(s) ready.`n"
                        "Press Ctrl+Alt+I for images",
                        "🐘 Mastodon Share", 4000)
        
        global IS_PendingImages := imagesToShare
        global IS_CurrentImageIndex := 1
        Hotkey("^!i", IS_GenericNextImage, "On")
    } else {
        ShowNotification("Text on clipboard!`nOpen your Mastodon instance and paste",
                        "🐘 Mastodon Share", 3000)
    }
    
    return true
}

; Generic image cycling for all platforms
IS_GenericNextImage(*) {
    global IS_PendingImages, IS_CurrentImageIndex
    
    if IS_CurrentImageIndex <= IS_PendingImages.Length {
        IS_CopyImageFileToClipboard(IS_PendingImages[IS_CurrentImageIndex])
        
        remaining := IS_PendingImages.Length - IS_CurrentImageIndex
        IS_CurrentImageIndex++
        
        if remaining > 0 {
            ShowNotification("Image " (IS_CurrentImageIndex-1) "/" IS_PendingImages.Length " ready!`n"
                            "Press Ctrl+V to paste`n"
                            "Press Ctrl+Alt+I for next (" remaining " more)",
                            "📷 Image Ready", 3000)
        } else {
            Hotkey("^!i", IS_GenericNextImage, "Off")
            ShowNotification("Final image ready!`nPress Ctrl+V to paste",
                            "📷 Last Image", 3000)
        }
    } else {
        Hotkey("^!i", IS_GenericNextImage, "Off")
        ShowNotification("All images shared!", "✅ Complete", 2000)
    }
}

; ==============================================================================
; EMAIL WITH ATTACHMENTS
; ==============================================================================

IS_SendOutlookEmailWithImages(subject, body, images) {
    try {
        outlookApp := ComObject("Outlook.Application")
        email := outlookApp.CreateItem(0)  ; olMailItem
        
        email.Subject := subject
        email.Body := body
        
        ; Add image attachments
        for imagePath in images {
            if FileExist(imagePath)
                email.Attachments.Add(imagePath)
        }
        
        email.Display()  ; Show email for user to review/send
        
        ShowNotification("Email created with " images.Length " image(s) attached",
                        "📧 Ready to Send", 3000)
        return true
    } catch as err {
        ShowNotification("Outlook error: " err.Message, "Error", 3000)
        return false
    }
}

; ==============================================================================
; URL ENCODING HELPER
; ==============================================================================

IS_EncodeURIComponent(str) {
    static doc := ""
    if !doc {
        doc := ComObject("HTMLFile")
        doc.write("<meta http-equiv='X-UA-Compatible' content='IE=edge'>")
    }
    return doc.parentWindow.encodeURIComponent(str)
}

; ==============================================================================
; NOTIFICATION HELPER (if not already defined)
; ==============================================================================

ShowNotification(message, title := "ContentCapture Pro", duration := 3000) {
    ; Use TrayTip for notifications
    TrayTip(message, title)
    if duration > 0
        SetTimer(() => TrayTip(), -duration)
}
