; ==============================================================================
; ImageSharing.ahk - Multi-Image Social Media Sharing for ContentCapture Pro
; ==============================================================================
; Version:     2.3
; Updated:     2026-03-23
;
; CHANGELOG v2.3:
;   - NEW: SQLite images.db support
;     * IS_GetCaptureImages() checks images.db first, falls back to images.dat
;       and CaptureData image fields
;     * IS_GetImagesFromSQLite() retrieves b64 from DB, decodes to temp files
;     * IS_Base64ToTempFile() decodes Base64 with magic-byte type detection
;   - NEW: IS_CleanTempImages() cleans up temp files created during sharing
;   - Temp files written to A_Temp\_ccpimg_*.ext and deleted after use
;
; CHANGELOG v2.2:
;   - FIXED: Global state variables properly cleared after operations
;   - ADDED: IS_ClearPendingState() to reset all global state
;   - ADDED: Clipboard clearing before setting new content
;   - FIXED: All clipboard operations now clear first, then set content
;
; CHANGELOG v2.1:
;   - Fixed: EncodeURIComponent corrected to IS_EncodeURIComponent
; ==============================================================================

#Requires AutoHotkey v2.0

; ==============================================================================
; PLATFORM IMAGE LIMITS
; ==============================================================================

global IS_ImageLimits := Map(
    "facebook_post",    10,
    "facebook_comment",  1,
    "twitter",           4,
    "bluesky",           4,
    "linkedin_post",     9,
    "linkedin_comment",  1,
    "mastodon",          4,
    "email",            10
)

; ==============================================================================
; GLOBAL STATE
; ==============================================================================

global IS_PendingContent     := ""
global IS_PendingImages      := []
global IS_CurrentImageIndex  := 0

; ==============================================================================
; STATE CLEANUP
; ==============================================================================

IS_ClearPendingState() {
    global IS_PendingContent, IS_PendingImages, IS_CurrentImageIndex
    IS_PendingContent    := ""
    IS_PendingImages     := []
    IS_CurrentImageIndex := 0
    try {
        Hotkey("^!v", "Off")
    }
    try {
        Hotkey("^!i", "Off")
    }
}

; ==============================================================================
; SAFE CLIPBOARD HELPER
; ==============================================================================

IS_SafeClipboardSet(content) {
    A_Clipboard := ""
    Sleep(50)
    A_Clipboard := content
    if !ClipWait(2) {
        ShowNotification("Clipboard operation failed", "Error", 2000)
        return false
    }
    return true
}

; ==============================================================================
; SQLITE HELPERS
; ==============================================================================

; Decode a Base64 string to a temp file. Returns path or "".
; Detects image type from magic bytes.
IS_Base64ToTempFile(b64) {
    b64 := RegExReplace(b64, "\s+", "")
    if b64 = ""
        return ""

    nBytes := 0
    DllCall("Crypt32.dll\CryptStringToBinaryW",
        "Str",   b64, "UInt", 0, "UInt", 1,
        "Ptr",   0,   "UInt*", &nBytes, "Ptr", 0, "Ptr", 0)
    if nBytes = 0
        return ""

    buf := Buffer(nBytes)
    DllCall("Crypt32.dll\CryptStringToBinaryW",
        "Str",   b64, "UInt", 0, "UInt", 1,
        "Ptr",   buf, "UInt*", &nBytes, "Ptr", 0, "Ptr", 0)

    ; Magic-byte type detection
    ext := "jpg"
    if nBytes >= 4 {
        b0 := NumGet(buf, 0, "UChar")
        b1 := NumGet(buf, 1, "UChar")
        b2 := NumGet(buf, 2, "UChar")
        b3 := NumGet(buf, 3, "UChar")
        if      b0 = 0xFF && b1 = 0xD8                                  ; JPEG
            ext := "jpg"
        else if b0 = 0x89 && b1 = 0x50 && b2 = 0x4E && b3 = 0x47       ; PNG
            ext := "png"
        else if b0 = 0x47 && b1 = 0x49 && b2 = 0x46                     ; GIF
            ext := "gif"
        else if b0 = 0x42 && b1 = 0x4D                                   ; BMP
            ext := "bmp"
        else if b0 = 0x52 && b1 = 0x49 && b2 = 0x46 && b3 = 0x46       ; WEBP
            ext := "webp"
    }

    tmpPath := A_Temp "\_ccpimg_" A_TickCount "." ext
    try {
        f := FileOpen(tmpPath, "w")
        f.RawWrite(buf, nBytes)
        f.Close()
        return tmpPath
    } catch {
        return ""
    }
}

; Look up image from images.db, decode to temp file. Returns [] or [path].
; imageKey = explicit DB key to look up (from capture's imagekey field)
;            If "", falls back to looking up captureName directly.
; platform = detected platform ("bluesky","linkedin","pinterest","facebook",...)
;            Used to select the right canvas-fitted variant (_bsky, _li, _pin)
IS_GetImagesFromSQLite(captureName, imageKey := "", platform := "") {
    images := []
    dbPath := A_ScriptDir "\images.db"
    if !FileExist(dbPath)
        return images

    ; Determine which DB key to look up
    if imageKey != "" {
        ; Use the explicit imagekey with platform variant
        dbKey := IsSet(CCP_GetPlatformImageKey)
            ? CCP_GetPlatformImageKey(imageKey, platform)
            : imageKey
    } else {
        ; Legacy: look up by capture name directly (no platform variant)
        dbKey := captureName
    }

    try {
        db  := CCP_DB_Open(dbPath)
        b64 := CCP_DB_GetImage(db, dbKey)

        ; If platform variant not found, fall back to base imageKey
        if b64 = "" && imageKey != "" && dbKey != imageKey {
            b64 := CCP_DB_GetImage(db, imageKey)
        }

        ; Last resort: try captureName directly
        if b64 = "" && imageKey != "" {
            b64 := CCP_DB_GetImage(db, captureName)
        }

        CCP_DB_Close(db)
        if b64 != "" {
            tmpPath := IS_Base64ToTempFile(b64)
            if tmpPath != ""
                images.Push(tmpPath)
        }
    } catch {
        ; DB unavailable — caller falls through to legacy system
    }
    return images
}

; Delete temp files created during this sharing session
IS_CleanTempImages(images) {
    for imgPath in images {
        if InStr(imgPath, "_ccpimg_") && FileExist(imgPath)
            try {
            FileDelete(imgPath)
        }
    }
}

; ==============================================================================
; MAIN ENTRY POINTS — Called by DynamicSuffixHandler
; ==============================================================================

; img suffix — copy image to clipboard as bitmap
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

    imagePath := images[1]
    result    := IS_CopyImageFileToClipboard(imagePath)
    IS_CleanTempImages(images)

    if result {
        ShowNotification("Image copied to clipboard`n" IS_GetFileName(imagePath),
            "📷 Ready to Paste", 2000)
        return true
    }
    return false
}

; imgo suffix — open image in default viewer
IS_OpenImage(captureName) {
    images := IS_GetCaptureImages(captureName)
    if images.Length = 0 {
        ShowNotification("No images attached to: " captureName, "No Image", 2000)
        return false
    }
    for imagePath in images {
        if FileExist(imagePath)
            Run(imagePath)
    }
    return true
}

; fbi / xi / bsi / lii / mti suffixes — share to platform with image
IS_ShareWithImage(captureName, platform) {
    global CaptureData

    IS_ClearPendingState()

    if !CaptureData.Has(captureName) {
        ShowNotification("Capture not found: " captureName, "Error", 2000)
        return false
    }

    cap     := CaptureData[captureName]
    images  := IS_GetCaptureImages(captureName)
    content := IS_BuildShareContent(cap, platform)

    switch platform {
        case "facebook":         return IS_ShareToFacebook(content, images)
        case "twitter", "x":     return IS_ShareToTwitter(content, images)
        case "bluesky":          return IS_ShareToBluesky(content, images)
        case "linkedin":         return IS_ShareToLinkedIn(content, images)
        case "mastodon":         return IS_ShareToMastodon(content, images)
        default:
            ShowNotification("Unknown platform: " platform, "Error", 2000)
            IS_CleanTempImages(images)
            return false
    }
}

; emi suffix — email with image attachment
IS_EmailWithImage(captureName) {
    global CaptureData

    if !CaptureData.Has(captureName) {
        ShowNotification("Capture not found: " captureName, "Error", 2000)
        return false
    }

    cap     := CaptureData[captureName]
    images  := IS_GetCaptureImages(captureName)
    subject := cap.Has("title") ? cap["title"] : captureName
    body    := IS_BuildEmailBody(cap)

    return IS_SendOutlookEmailWithImages(subject, body, images)
}

; ==============================================================================
; IMAGE RETRIEVAL — Priority: 1) SQLite  2) images.dat  3) CaptureData fields
; ==============================================================================

IS_GetCaptureImages(captureName) {
    global BaseDir
    images := []

    ; 1. SQLite images.db (platform-aware via imagekey field)
    imageKey := ""
    platform := ""
    global CaptureData
    if CaptureData.Has(StrLower(captureName)) {
        cap := CaptureData[StrLower(captureName)]
        if cap.Has("imagekey") && cap["imagekey"] != ""
            imageKey := cap["imagekey"]
    }
    if IsSet(CCP_DetectActivePlatform)
        platform := CCP_DetectActivePlatform()
    for imgPath in IS_GetImagesFromSQLite(captureName, imageKey, platform)
        images.Push(imgPath)

    ; 2. Legacy images.dat (pipe-delimited file)
    imagesFile := BaseDir "\images.dat"
    if FileExist(imagesFile) {
        content := FileRead(imagesFile)
        Loop Parse, content, "`n", "`r" {
            if A_LoopField = ""
                continue
            parts := StrSplit(A_LoopField, "|")
            if parts.Length >= 2 && parts[1] = captureName {
                Loop parts.Length - 1 {
                    imgPath := parts[A_Index + 1]
                    if imgPath != "" {
                        if !InStr(imgPath, ":") && !InStr(imgPath, "\\")
                            imgPath := BaseDir "\images\" imgPath
                        if FileExist(imgPath) && !IS_ArrayContains(images, imgPath)
                            images.Push(imgPath)
                    }
                }
                break
            }
        }
    }

    ; 3. Legacy CaptureData image fields
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
    for item in arr
        if item = value
            return true
    return false
}

IS_GetFileName(path) {
    SplitPath(path, &name)
    return name
}

; ==============================================================================
; GDI+ CLIPBOARD IMAGE COPY
; ==============================================================================

IS_CopyImageFileToClipboard(imagePath) {
    if !FileExist(imagePath)
        return false

    pToken := 0
    si     := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken, "Ptr", si, "Ptr", 0)

    pBitmap := 0
    DllCall("gdiplus\GdipCreateBitmapFromFile", "Str", imagePath, "Ptr*", &pBitmap)

    if !pBitmap {
        DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
        return false
    }

    hBitmap := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap",
        "Ptr", pBitmap, "Ptr*", &hBitmap, "UInt", 0xFFFFFFFF)

    if hBitmap {
        DllCall("OpenClipboard",    "Ptr", A_ScriptHwnd)
        DllCall("EmptyClipboard")
        DllCall("SetClipboardData", "UInt", 2, "Ptr", hBitmap)  ; CF_BITMAP
        DllCall("CloseClipboard")
    }

    DllCall("gdiplus\GdipDisposeImage",  "Ptr", pBitmap)
    DllCall("gdiplus\GdiplusShutdown",   "Ptr", pToken)

    return hBitmap != 0
}

; ==============================================================================
; CONTENT BUILDING
; ==============================================================================

IS_BuildShareContent(cap, platform) {
    content   := ""
    charLimit := IS_GetCharLimit(platform)

    if cap.Has("body")  && cap["body"]  != ""
        content := cap["body"]
    else if cap.Has("title") && cap["title"] != ""
        content := cap["title"]

    if cap.Has("url") && cap["url"] != "" {
        url := IS_CleanURL(cap["url"])
        content := content != "" ? content "`n`n" url : url
    }

    if StrLen(content) > charLimit
        content := SubStr(content, 1, charLimit - 3) "..."

    return content
}

IS_BuildEmailBody(cap) {
    body := ""
    if cap.Has("body")  && cap["body"]  != ""
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
        "twitter",  280,
        "x",        280,
        "bluesky",  300,
        "facebook", 63206,
        "linkedin", 3000,
        "mastodon", 500
    )
    return limits.Has(platform) ? limits[platform] : 5000
}

IS_CleanURL(url) {
    trackingParams := ["utm_source","utm_medium","utm_campaign","utm_content",
                       "utm_term","fbclid","gclid","ref","source"]
    if InStr(url, "?") {
        parts   := StrSplit(url, "?", , 2)
        baseUrl := parts[1]
        if parts.Length > 1 {
            params      := StrSplit(parts[2], "&")
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

IS_ShareToFacebook(content, images) {
    global IS_PendingContent, IS_PendingImages, IS_CurrentImageIndex

    isComment := IS_DetectFacebookContext()
    maxImages := isComment ? IS_ImageLimits["facebook_comment"]
                           : IS_ImageLimits["facebook_post"]

    imagesToShare := []
    Loop Min(images.Length, maxImages)
        imagesToShare.Push(images[A_Index])

    if imagesToShare.Length > 0 {
        result := MsgBox(
            "Share to Facebook with " imagesToShare.Length " image(s)?`n`n"
            "YES = Upload image(s) first, then paste text`n"
            "NO = Paste text first, then upload image(s)`n"
            "CANCEL = Text only (no images)",
            "📷 Facebook Share", "YesNoCancel Icon?")

        if result = "Cancel" {
            IS_SafeClipboardSet(content)
            ShowNotification("Text copied - paste with Ctrl+V", "📋 Ready", 2000)
            IS_CleanTempImages(images)
            IS_ClearPendingState()
            return true
        }
        if result = "Yes"
            return IS_FacebookImagesFirst(content, imagesToShare)
        else
            return IS_FacebookTextFirst(content, imagesToShare)
    } else {
        IS_SafeClipboardSet(content)
        ShowNotification("Text copied - paste with Ctrl+V", "📋 Ready", 2000)
        IS_ClearPendingState()
        return true
    }
}

IS_FacebookImagesFirst(content, images) {
    global IS_PendingContent, IS_PendingImages, IS_CurrentImageIndex

    if images.Length > 0 {
        IS_CopyImageFileToClipboard(images[1])
        ShowNotification(
            "Image on clipboard!`n"
            "1. Click in Facebook post area`n"
            "2. Ctrl+V to paste image`n"
            "3. Wait for upload`n"
            "4. Ctrl+Alt+V for text",
            "📷 Step 1: Paste Image", 5000)

        IS_PendingContent    := content
        IS_PendingImages     := images
        IS_CurrentImageIndex := 2
        Hotkey("^!v", IS_FacebookPasteText, "On")
        return true
    }
    return false
}

IS_FacebookPasteText(*) {
    global IS_PendingContent, IS_PendingImages, IS_CurrentImageIndex
    Hotkey("^!v", IS_FacebookPasteText, "Off")
    IS_SafeClipboardSet(IS_PendingContent)
    Send("^v")

    if IS_PendingImages.Length >= IS_CurrentImageIndex {
        Sleep(500)
        ShowNotification(
            "Text pasted!`nMore images available.`nCtrl+Alt+I for next image",
            "📝 Text Added", 3000)
        Hotkey("^!i", IS_FacebookNextImage, "On")
    } else {
        ShowNotification("Share complete!", "✅ Done", 2000)
        IS_CleanTempImages(IS_PendingImages)
        IS_ClearPendingState()
    }
}

IS_FacebookNextImage(*) {
    global IS_PendingImages, IS_CurrentImageIndex

    if IS_CurrentImageIndex <= IS_PendingImages.Length {
        IS_CopyImageFileToClipboard(IS_PendingImages[IS_CurrentImageIndex])
        IS_CurrentImageIndex++

        if IS_CurrentImageIndex <= IS_PendingImages.Length {
            ShowNotification(
                "Image " (IS_CurrentImageIndex-1) " ready!`n"
                "Ctrl+V to paste, Ctrl+Alt+I for next",
                "📷 Image Ready", 3000)
        } else {
            Hotkey("^!i", IS_FacebookNextImage, "Off")
            ShowNotification("Last image ready! Ctrl+V to paste",
                "📷 Final Image", 3000)
            SetTimer(() => (IS_CleanTempImages(IS_PendingImages), IS_ClearPendingState()), -5000)
        }
    }
}

IS_FacebookTextFirst(content, images) {
    global IS_PendingImages, IS_CurrentImageIndex

    IS_SafeClipboardSet(content)
    ShowNotification(
        "Text on clipboard!`n"
        "1. Click in Facebook post area`n"
        "2. Ctrl+V to paste text`n"
        "3. Ctrl+Alt+I for image",
        "📝 Step 1: Paste Text", 4000)

    IS_PendingImages     := images
    IS_CurrentImageIndex := 1
    Hotkey("^!i", IS_FacebookNextImage, "On")
    return true
}

IS_DetectFacebookContext() {
    title := WinGetTitle("A")
    return InStr(title, "Comment") || InStr(title, "Reply")
}

IS_ShareToTwitter(content, images) {
    global IS_PendingImages, IS_CurrentImageIndex

    imagesToShare := []
    Loop Min(images.Length, IS_ImageLimits["twitter"])
        imagesToShare.Push(images[A_Index])

    composeUrl := "https://twitter.com/intent/tweet?text=" IS_EncodeURIComponent(content)
    Run(composeUrl)

    if imagesToShare.Length > 0 {
        Sleep(2000)
        ShowNotification(
            "Twitter opened!`n" imagesToShare.Length " image(s) ready.`nCtrl+Alt+I to copy each",
            "🐦 Add Images", 4000)
        IS_PendingImages     := imagesToShare
        IS_CurrentImageIndex := 1
        Hotkey("^!i", IS_GenericNextImage, "On")
    } else {
        IS_CleanTempImages(images)
        IS_ClearPendingState()
    }
    return true
}

IS_ShareToBluesky(content, images) {
    global IS_PendingImages, IS_CurrentImageIndex

    imagesToShare := []
    Loop Min(images.Length, IS_ImageLimits["bluesky"])
        imagesToShare.Push(images[A_Index])

    Run("https://bsky.app/")
    Sleep(2000)
    IS_SafeClipboardSet(content)

    if imagesToShare.Length > 0 {
        ShowNotification(
            "Bluesky opened!`nText on clipboard (Ctrl+V)`n"
            imagesToShare.Length " image(s) ready.`nCtrl+Alt+I after pasting text",
            "🦋 Bluesky Share", 4000)
        IS_PendingImages     := imagesToShare
        IS_CurrentImageIndex := 1
        Hotkey("^!i", IS_GenericNextImage, "On")
    } else {
        ShowNotification("Bluesky opened! Text on clipboard - paste with Ctrl+V",
            "🦋 Bluesky Share", 3000)
        IS_CleanTempImages(images)
        IS_ClearPendingState()
    }
    return true
}

IS_ShareToLinkedIn(content, images) {
    global IS_PendingImages, IS_CurrentImageIndex

    imagesToShare := []
    Loop Min(images.Length, IS_ImageLimits["linkedin_post"])
        imagesToShare.Push(images[A_Index])

    Run("https://www.linkedin.com/feed/")
    Sleep(2000)
    IS_SafeClipboardSet(content)

    if imagesToShare.Length > 0 {
        ShowNotification(
            "LinkedIn opened!`nText on clipboard (Ctrl+V)`n"
            imagesToShare.Length " image(s) ready.`nCtrl+Alt+I for images",
            "💼 LinkedIn Share", 4000)
        IS_PendingImages     := imagesToShare
        IS_CurrentImageIndex := 1
        Hotkey("^!i", IS_GenericNextImage, "On")
    } else {
        ShowNotification("LinkedIn opened! Text on clipboard - paste with Ctrl+V",
            "💼 LinkedIn Share", 3000)
        IS_CleanTempImages(images)
        IS_ClearPendingState()
    }
    return true
}

IS_ShareToMastodon(content, images) {
    global IS_PendingImages, IS_CurrentImageIndex

    imagesToShare := []
    Loop Min(images.Length, IS_ImageLimits["mastodon"])
        imagesToShare.Push(images[A_Index])

    IS_SafeClipboardSet(content)

    if imagesToShare.Length > 0 {
        ShowNotification(
            "Text on clipboard!`nOpen your Mastodon instance`n"
            imagesToShare.Length " image(s) ready.`nCtrl+Alt+I for images",
            "🐘 Mastodon Share", 4000)
        IS_PendingImages     := imagesToShare
        IS_CurrentImageIndex := 1
        Hotkey("^!i", IS_GenericNextImage, "On")
    } else {
        ShowNotification("Text on clipboard! Open your Mastodon instance and paste",
            "🐘 Mastodon Share", 3000)
        IS_CleanTempImages(images)
        IS_ClearPendingState()
    }
    return true
}

IS_GenericNextImage(*) {
    global IS_PendingImages, IS_CurrentImageIndex

    if IS_CurrentImageIndex <= IS_PendingImages.Length {
        IS_CopyImageFileToClipboard(IS_PendingImages[IS_CurrentImageIndex])
        remaining := IS_PendingImages.Length - IS_CurrentImageIndex
        IS_CurrentImageIndex++

        if remaining > 0 {
            ShowNotification(
                "Image " (IS_CurrentImageIndex-1) "/" IS_PendingImages.Length " ready!`n"
                "Ctrl+V to paste, Ctrl+Alt+I for next (" remaining " more)",
                "📷 Image Ready", 3000)
        } else {
            Hotkey("^!i", IS_GenericNextImage, "Off")
            ShowNotification("Final image ready! Ctrl+V to paste", "📷 Last Image", 3000)
            SetTimer(() => (IS_CleanTempImages(IS_PendingImages), IS_ClearPendingState()), -5000)
        }
    } else {
        Hotkey("^!i", IS_GenericNextImage, "Off")
        ShowNotification("All images shared!", "✅ Complete", 2000)
        IS_CleanTempImages(IS_PendingImages)
        IS_ClearPendingState()
    }
}

; ==============================================================================
; EMAIL WITH ATTACHMENTS
; ==============================================================================

IS_SendOutlookEmailWithImages(subject, body, images) {
    try {
        outlookApp := ComObject("Outlook.Application")
        email      := outlookApp.CreateItem(0)
        email.Subject := subject
        email.Body    := body
        for imagePath in images {
            if FileExist(imagePath)
                email.Attachments.Add(imagePath)
        }
        email.Display()
        ShowNotification("Email created with " images.Length " image(s) attached",
            "📧 Ready to Send", 3000)
        IS_CleanTempImages(images)
        return true
    } catch as err {
        ShowNotification("Outlook error: " err.Message, "Error", 3000)
        return false
    }
}

; ==============================================================================
; URL ENCODING
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
; NOTIFICATION HELPER
; ==============================================================================

ShowNotification(message, title := "ContentCapture Pro", duration := 3000) {
    TrayTip(message, title)
    if duration > 0
        SetTimer(() => TrayTip(), -duration)
}

; ============================================================================
; IS_SmartShare - Universal platform-aware sharing
; Called by ;;nazipauls  (isComment=false)
; Called by ;;nazipaulscom (isComment=true)
;
; Flow:
;   1. Resolve platform (detect from browser or show picker)
;   2. Get capture data
;   3. Build content formatted for that platform
;   4. Get right image variant from images.db
;   5. Share: image first then text (post) OR text first then image (comment)
; ============================================================================
IS_SmartShare(captureName, isComment := false) {
    global CaptureData

    ; Step 1: Resolve platform
    platform := IsSet(CCP_ResolvePlatform) ? CCP_ResolvePlatform() : ""
    if platform = "" {
        ShowNotification("Share cancelled.", "ContentCapture Pro", 2000)
        return false
    }

    ; Step 2: Get capture
    if !CaptureData.Has(StrLower(captureName)) {
        ShowNotification("Capture not found: " captureName, "Error", 2000)
        return false
    }
    cap := CaptureData[StrLower(captureName)]

    ; Step 3: Build platform-formatted content
    content := IS_BuildSmartContent(cap, platform)

    ; Step 4: Get image temp file
    imageKey := cap.Has("imagekey") ? cap["imagekey"] : ""
    imgPath  := ""
    if imageKey != "" {
        dbKey := IsSet(CCP_GetPlatformImageKey)
            ? CCP_GetPlatformImageKey(imageKey, platform)
            : imageKey
        images := IS_GetImagesFromSQLite(captureName, imageKey, platform)
        if images.Length > 0
            imgPath := images[1]
    }

    ; Step 5: Share with correct order and platform behavior
    IS_ClearPendingState()

    if isComment
        return IS_SmartShareComment(platform, content, imgPath, captureName)
    else
        return IS_SmartSharePost(platform, content, imgPath, captureName)
}

; -- Build content formatted for the detected platform --------------------
IS_BuildSmartContent(cap, platform) {
    limits := Map(
        "facebook",  63000,
        "twitter",   280,
        "bluesky",   300,
        "linkedin",  3000,
        "pinterest", 500,
        "mastodon",  500,
        "instagram", 2200
    )
    limit := limits.Has(platform) ? limits[platform] : 5000

    ; Use short version if available and platform has tight limit
    tightLimit := (limit <= 500)
    if tightLimit && cap.Has("short") && cap["short"] != "" {
        content := cap["short"]
    } else if cap.Has("opinion") && cap["opinion"] != "" {
        content := cap["opinion"]
        if cap.Has("title") && cap["title"] != ""
            content .= "`n`n" cap["title"]
    } else if cap.Has("body") && cap["body"] != "" {
        content := cap["body"]
    } else if cap.Has("title") && cap["title"] != "" {
        content := cap["title"]
    } else {
        content := ""
    }

    ; Append URL (Pinterest is image-only - skip URL)
    if platform != "pinterest" && cap.Has("url") && cap["url"] != "" {
        url := IS_CleanURL(cap["url"])
        if !InStr(content, url) {
            withUrl := content != "" ? content "`n`n" url : url
            if StrLen(withUrl) <= limit
                content := withUrl
            else if content = ""
                content := url
        }
    }

    ; Trim to limit
    if StrLen(content) > limit
        content := SubStr(content, 1, limit - 3) "..."

    return Trim(content)
}

; -- New post: image first, then text -------------------------------------
IS_SmartSharePost(platform, content, imgPath, captureName) {

    ; Pinterest: image only, open site
    if platform = "pinterest" {
        if imgPath != "" && FileExist(imgPath) {
            IS_CopyImageFileToClipboard(imgPath)
            Run("https://www.pinterest.com/pin/creation/button/")
            ShowNotification(
                "Pinterest opened!`nCtrl+V to paste your image.",
                "Pinterest Share", 3000)
            SetTimer(() => IS_CleanTempImages([imgPath]), -10000)
        } else {
            Run("https://www.pinterest.com/pin/creation/button/")
            ShowNotification("No image attached — add one in the Edit GUI.",
                "Pinterest Share", 3000)
        }
        return true
    }

    ; Facebook: text first (FB generates link preview card)
    if platform = "facebook" {
        IS_SafeClipboardSet(content)
        url := ""
        if imgPath != "" && FileExist(imgPath) {
            ; Set up pending image for Ctrl+Shift+V
            global IS_PendingImages, IS_CurrentImageIndex
            IS_PendingImages     := [imgPath]
            IS_CurrentImageIndex := 1
            Hotkey("^!i", IS_GenericNextImage, "On")
            ShowNotification(
                "Text copied — paste with Ctrl+V`n"
                "Then Ctrl+Alt+I to add your image.",
                "Facebook Share", 4000)
        } else {
            ShowNotification("Text copied — paste with Ctrl+V", "Facebook Share", 3000)
        }
        Run("https://www.facebook.com/")
        return true
    }

    ; All other platforms: image first, then text
    platformUrls := Map(
        "twitter",   "https://x.com/compose/post",
        "bluesky",   "https://bsky.app/",
        "linkedin",  "https://www.linkedin.com/feed/",
        "mastodon",  "",
        "instagram", "https://www.instagram.com/"
    )

    if imgPath != "" && FileExist(imgPath) {
        IS_CopyImageFileToClipboard(imgPath)
        ShowNotification(
            "Image on clipboard — Ctrl+V to paste`n"
            "Then Ctrl+Alt+V for your text.",
            IS_PlatformLabel(platform) " Share", 4000)

        ; Set up text for Ctrl+Alt+V
        global IS_PendingContent
        IS_PendingContent := content
        Hotkey("^!v", IS_SmartPasteText, "On")
        SetTimer(() => (IS_CleanTempImages([imgPath]), IS_ClearPendingState()), -30000)
    } else {
        IS_SafeClipboardSet(content)
        ShowNotification("Text copied — paste with Ctrl+V",
            IS_PlatformLabel(platform) " Share", 3000)
    }

    url := platformUrls.Has(platform) ? platformUrls[platform] : ""
    if url != ""
        Run(url)

    return true
}

; -- Comment/reply: text first, then image --------------------------------
IS_SmartShareComment(platform, content, imgPath, captureName) {

    ; Paste text into the focused comment box
    CC_SafePaste(content)

    if imgPath != "" && FileExist(imgPath) {
        Sleep(600)
        IS_CopyImageFileToClipboard(imgPath)
        Sleep(300)
        Send("^v")
        ShowNotification("Text + image pasted into comment!",
            IS_PlatformLabel(platform) " Comment", 2000)
        SetTimer(() => IS_CleanTempImages([imgPath]), -5000)
    } else {
        ShowNotification("Text pasted into comment.",
            IS_PlatformLabel(platform) " Comment", 2000)
    }

    return true
}

; -- Hotkey handler: paste text after image -------------------------------
IS_SmartPasteText(*) {
    global IS_PendingContent
    Hotkey("^!v", IS_SmartPasteText, "Off")
    if IS_PendingContent != "" {
        IS_SafeClipboardSet(IS_PendingContent)
        Send("^v")
        IS_PendingContent := ""
        ShowNotification("Text pasted!", "Share Complete", 2000)
    }
    IS_ClearPendingState()
}

; -- Platform display label -----------------------------------------------
IS_PlatformLabel(platform) {
    labels := Map(
        "facebook",  "Facebook",
        "twitter",   "X / Twitter",
        "bluesky",   "Bluesky",
        "linkedin",  "LinkedIn",
        "pinterest", "Pinterest",
        "mastodon",  "Mastodon",
        "instagram", "Instagram"
    )
    return labels.Has(platform) ? labels[platform] : platform
}
