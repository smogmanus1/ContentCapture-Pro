; ==============================================================================
; ImageCapture Module for ContentCapture Pro
; ==============================================================================
; Adds image attachment capability to your captures
; Images are copied to local folder and can be shared via clipboard or email
;
; New suffixes when image is attached:
;   scriptnameimg   - Copy image to clipboard
;   scriptnameimgo  - Open image in default viewer
;   scriptnamefbi   - Facebook with image on clipboard
;   scriptnamexi    - Twitter/X with image on clipboard
;   scriptnameemi   - Email with image attached (Outlook)
; ==============================================================================

; Global image storage
global ImageData := Map()
global ImageFolder := ""

; Initialize image system
IC_Initialize() {
    global ImageFolder, ImageData
    
    ; Create images folder next to captures.dat
    baseDir := IsSet(ContentCaptureDir) && ContentCaptureDir != "" ? ContentCaptureDir : A_ScriptDir
    ImageFolder := baseDir "\images"
    if !DirExist(ImageFolder)
        DirCreate(ImageFolder)
    
    ; Load image database
    IC_LoadImageData()
}

; Load image associations from file
IC_LoadImageData() {
    global ImageData, ContentCaptureDir
    
    baseDir := IsSet(ContentCaptureDir) && ContentCaptureDir != "" ? ContentCaptureDir : A_ScriptDir
    imageFile := baseDir "\images.dat"
    if !FileExist(imageFile)
        return
    
    ImageData := Map()
    currentName := ""
    
    Loop Read, imageFile {
        line := Trim(A_LoopReadLine)
        if (line = "" || SubStr(line, 1, 1) = ";")
            continue
        
        if (SubStr(line, 1, 1) = "[" && SubStr(line, -1) = "]") {
            currentName := StrLower(SubStr(line, 2, -1))
            ImageData[currentName] := Map()
        } else if (currentName != "" && InStr(line, "=")) {
            parts := StrSplit(line, "=", , 2)
            key := Trim(parts[1])
            value := parts.Has(2) ? Trim(parts[2]) : ""
            ImageData[currentName][key] := value
        }
    }
}

; Save image associations to file
IC_SaveImageData() {
    global ImageData, ContentCaptureDir
    
    baseDir := IsSet(ContentCaptureDir) && ContentCaptureDir != "" ? ContentCaptureDir : A_ScriptDir
    imageFile := baseDir "\images.dat"
    content := "; ContentCapture Pro - Image Database`n"
    content .= "; Format: [scriptname] followed by key=value pairs`n`n"
    
    for name, data in ImageData {
        content .= "[" name "]`n"
        for key, value in data {
            content .= key "=" value "`n"
        }
        content .= "`n"
    }
    
    try {
        if FileExist(imageFile)
            FileDelete(imageFile)
        FileAppend(content, imageFile, "UTF-8")
    }
}

; Attach image to a capture
IC_AttachImage(captureName, imagePath := "") {
    global ImageData, ImageFolder
    
    nameLower := StrLower(captureName)
    
    ; If no path provided, let user select
    if (imagePath = "") {
        imagePath := FileSelect(1, , "Select Image for '" captureName "'", "Images (*.png; *.jpg; *.jpeg; *.gif; *.bmp; *.webp)")
        if (imagePath = "")
            return false
    }
    
    if !FileExist(imagePath) {
        MsgBox("Image file not found: " imagePath, "Error", "16")
        return false
    }
    
    ; Copy image to local images folder
    SplitPath(imagePath, &fileName, , &ext)
    localName := nameLower "." ext
    localPath := ImageFolder "\" localName
    
    try {
        FileCopy(imagePath, localPath, 1)  ; Overwrite if exists
    } catch as err {
        MsgBox("Failed to copy image: " err.Message, "Error", "16")
        return false
    }
    
    ; Store in database
    ImageData[nameLower] := Map(
        "localpath", localPath,
        "originalpath", imagePath,
        "filename", localName,
        "added", FormatTime(, "yyyy-MM-dd HH:mm")
    )
    
    IC_SaveImageData()
    TrayTip("Image attached to '" captureName "'", "ImageCapture", "1")
    return true
}

; Remove image from a capture
IC_RemoveImage(captureName) {
    global ImageData
    
    nameLower := StrLower(captureName)
    
    if !ImageData.Has(nameLower)
        return false
    
    ; Delete local file
    localPath := ImageData[nameLower]["localpath"]
    if FileExist(localPath) {
        try FileDelete(localPath)
    }
    
    ImageData.Delete(nameLower)
    IC_SaveImageData()
    return true
}

; Check if capture has image
IC_HasImage(captureName) {
    global ImageData
    return ImageData.Has(StrLower(captureName))
}

; Get image path for a capture
IC_GetImagePath(captureName) {
    global ImageData
    nameLower := StrLower(captureName)
    
    if !ImageData.Has(nameLower)
        return ""
    
    return ImageData[nameLower]["localpath"]
}

; ==============================================================================
; CORE FUNCTION: Copy Image to Clipboard
; ==============================================================================
; Uses PowerShell to copy image to clipboard (most reliable cross-platform method)

IC_CopyImageToClipboard(imagePath) {
    if !FileExist(imagePath) {
        MsgBox("Image not found: " imagePath, "Error", "16")
        return false
    }
    
    ; PowerShell command to copy image to clipboard
    ; This works reliably for PNG, JPG, BMP, GIF
    psScript := '
    (
        Add-Type -AssemblyName System.Windows.Forms
        $image = [System.Drawing.Image]::FromFile("' imagePath '")
        [System.Windows.Forms.Clipboard]::SetImage($image)
        $image.Dispose()
    )'
    
    ; Run PowerShell hidden
    try {
        RunWait('powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "' psScript '"', , "Hide")
        return true
    } catch as err {
        MsgBox("Failed to copy image: " err.Message, "Error", "16")
        return false
    }
}

; ==============================================================================
; SHARING FUNCTIONS
; ==============================================================================

; Copy image to clipboard only
IC_ShareImageClipboard(captureName) {
    imagePath := IC_GetImagePath(captureName)
    if (imagePath = "") {
        MsgBox("No image attached to '" captureName "'", "No Image", "48")
        return
    }
    
    if IC_CopyImageToClipboard(imagePath)
        TrayTip("Image copied to clipboard - Paste with Ctrl+V", captureName, "1")
}

; Open image in default viewer
IC_OpenImage(captureName) {
    imagePath := IC_GetImagePath(captureName)
    if (imagePath = "") {
        MsgBox("No image attached to '" captureName "'", "No Image", "48")
        return
    }
    
    try Run(imagePath)
}

; Facebook with image
IC_ShareFacebookWithImage(captureName, textContent := "") {
    imagePath := IC_GetImagePath(captureName)
    
    ; Copy image to clipboard first
    if (imagePath != "" && FileExist(imagePath))
        IC_CopyImageToClipboard(imagePath)
    
    ; Open Facebook
    Run("https://www.facebook.com/")
    
    ; Also put text in clipboard after a delay (user can paste image first, then text)
    if (textContent != "") {
        Sleep(500)
        TrayTip("Image on clipboard! Paste image first, then text is ready.", "Facebook Share", "1")
    } else {
        TrayTip("Image copied! Paste with Ctrl+V in Facebook", "Facebook Share", "1")
    }
}

; Twitter/X with image
IC_ShareTwitterWithImage(captureName, textContent := "") {
    imagePath := IC_GetImagePath(captureName)
    
    ; Copy image to clipboard first
    if (imagePath != "" && FileExist(imagePath))
        IC_CopyImageToClipboard(imagePath)
    
    ; Open Twitter compose
    Run("https://twitter.com/compose/tweet")
    
    TrayTip("Image copied! Paste with Ctrl+V in Twitter", "Twitter Share", "1")
}

; Bluesky with image
IC_ShareBlueskyWithImage(captureName, textContent := "") {
    imagePath := IC_GetImagePath(captureName)
    
    if (imagePath != "" && FileExist(imagePath))
        IC_CopyImageToClipboard(imagePath)
    
    Run("https://bsky.app/")
    
    TrayTip("Image copied! Paste with Ctrl+V in Bluesky", "Bluesky Share", "1")
}

; ==============================================================================
; EMAIL WITH ATTACHMENT (Outlook COM - No clipboard needed!)
; ==============================================================================

IC_EmailWithImage(captureName, textContent := "", subject := "") {
    global ImageData
    
    imagePath := IC_GetImagePath(captureName)
    
    if (subject = "")
        subject := "Shared: " captureName
    
    ; Try Outlook COM
    try {
        olApp := ComObject("Outlook.Application")
        mail := olApp.CreateItem(0)  ; 0 = olMailItem
        
        mail.Subject := subject
        mail.Body := textContent
        
        ; Attach image if exists
        if (imagePath != "" && FileExist(imagePath)) {
            mail.Attachments.Add(imagePath)
        }
        
        mail.Display()  ; Show email for editing before send
        
        TrayTip("Email created with image attached!", "Outlook", "1")
        return true
    } catch as err {
        ; Fallback - just open the image and copy text
        if (imagePath != "" && FileExist(imagePath))
            Run(imagePath)
        
        A_Clipboard := textContent
        MsgBox("Outlook not available. Image opened, text copied to clipboard.", "Email Fallback", "48")
        return false
    }
}

; ==============================================================================
; GUI: Add/Edit Image in Capture Dialog
; ==============================================================================

IC_ShowImageButton(editGui, captureName, yPos) {
    global ImageData
    
    hasImage := IC_HasImage(captureName)
    
    if hasImage {
        imagePath := IC_GetImagePath(captureName)
        
        ; Show thumbnail preview
        editGui.SetFont("s9 c666666")
        editGui.Add("Text", "x15 y" yPos, "📷 Attached Image:")
        
        ; Try to show preview (small)
        try {
            editGui.Add("Picture", "x15 y" (yPos + 20) " w100 h75", imagePath)
        }
        
        ; Buttons
        editGui.Add("Button", "x130 y" (yPos + 30) " w80 h25", "Change").OnEvent("Click", (*) => IC_AttachImage(captureName))
        editGui.Add("Button", "x220 y" (yPos + 30) " w80 h25", "Remove").OnEvent("Click", (*) => IC_RemoveImage(captureName))
        editGui.Add("Button", "x310 y" (yPos + 30) " w80 h25", "View").OnEvent("Click", (*) => IC_OpenImage(captureName))
        
        return yPos + 110
    } else {
        editGui.SetFont("s9 c666666")
        editGui.Add("Text", "x15 y" yPos, "📷 Image (optional):")
        editGui.Add("Button", "x15 y" (yPos + 20) " w120 h28", "Attach Image...").OnEvent("Click", (*) => IC_AttachImage(captureName))
        
        return yPos + 60
    }
}

; ==============================================================================
; BROWSER: Show image indicator
; ==============================================================================

IC_GetImageIndicator(captureName) {
    return IC_HasImage(captureName) ? "📷" : ""
}

; ==============================================================================
; Initialize on load
; ==============================================================================
IC_Initialize()
