#Requires AutoHotkey v2.0+

; ==============================================================================
; ImageCapture.ahk - Image Attachment System for ContentCapture Pro
; ==============================================================================
; Manages image attachments for captures, storing them in a local folder
; to prevent broken links when original files are moved.
;
; Features:
;   - Attach images to captures
;   - Store images in local /images folder
;   - Retrieve image paths for sharing
;   - Check if capture has an image
;
; Usage: #Include this file in ContentCapture-Pro.ahk
; ==============================================================================

global ImageData := Map()
global ImageDir := ""
global ImageDataFile := ""

; Initialize image system
IC_Initialize() {
    global ImageDir, ImageDataFile, ImageData
    
    ImageDir := A_ScriptDir . "\images"
    ImageDataFile := A_ScriptDir . "\images.dat"
    
    ; Create images directory if it doesn't exist
    if !DirExist(ImageDir)
        DirCreate(ImageDir)
    
    ; Load existing image associations
    IC_LoadImageData()
}

; Load image data from file
IC_LoadImageData() {
    global ImageData, ImageDataFile
    
    ImageData := Map()
    
    if !FileExist(ImageDataFile)
        return
    
    try {
        content := FileRead(ImageDataFile, "UTF-8")
        
        for line in StrSplit(content, "`n", "`r") {
            if (line = "")
                continue
            
            parts := StrSplit(line, "|")
            if (parts.Length >= 2) {
                name := parts[1]
                path := parts[2]
                ImageData[name] := path
            }
        }
    }
}

; Save image data to file
IC_SaveImageData() {
    global ImageData, ImageDataFile
    
    content := ""
    for name, path in ImageData {
        content .= name . "|" . path . "`n"
    }
    
    try {
        FileDelete(ImageDataFile)
    }
    
    if (content != "")
        FileAppend(content, ImageDataFile, "UTF-8")
}

; Check if a capture has an attached image
IC_HasImage(name) {
    global ImageData
    
    if (!ImageData.Has(name))
        return false
    
    path := ImageData[name]
    return (path != "" && FileExist(path))
}

; Get the image path for a capture
IC_GetImagePath(name) {
    global ImageData
    
    if (!ImageData.Has(name))
        return ""
    
    return ImageData[name]
}

; Attach an image to a capture
IC_AttachImage(name, sourcePath := "") {
    global ImageData, ImageDir
    
    ; If no source path provided, prompt user to select a file
    if (sourcePath = "") {
        sourcePath := FileSelect("1", , "Select Image for '" name "'", "Images (*.png; *.jpg; *.jpeg; *.gif; *.bmp; *.webp)")
        if (sourcePath = "")
            return false  ; User cancelled
    }
    
    if (!FileExist(sourcePath)) {
        MsgBox("Image file not found:`n" sourcePath, "Error", "48")
        return false
    }
    
    ; Get file extension
    SplitPath(sourcePath, &fileName, , &ext)
    
    ; Create unique filename
    newFileName := name . "_" . A_Now . "." . ext
    newPath := ImageDir . "\" . newFileName
    
    ; Copy image to local folder
    try {
        FileCopy(sourcePath, newPath, 1)
    } catch as err {
        MsgBox("Failed to copy image:`n" err.Message, "Error", "48")
        return false
    }
    
    ; Store association
    ImageData[name] := newPath
    IC_SaveImageData()
    
    TrayTip("Image attached to '" name "'", "📷 Image Added", "1")
    return true
}

; Remove image attachment from a capture
IC_RemoveImage(name) {
    global ImageData
    
    if (!ImageData.Has(name))
        return
    
    ; Optionally delete the file
    path := ImageData[name]
    if (FileExist(path)) {
        try {
            FileDelete(path)
        }
    }
    
    ImageData.Delete(name)
    IC_SaveImageData()
}

; Open image in default viewer
IC_OpenImage(name) {
    path := IC_GetImagePath(name)
    
    if (path = "" || !FileExist(path)) {
        MsgBox("No image found for '" name "'", "No Image", "48")
        return
    }
    
    Run(path)
}

; Get image dimensions
IC_GetImageDimensions(path) {
    if (!FileExist(path))
        return {width: 0, height: 0}
    
    ; Use GDI+ to get dimensions
    try {
        pToken := 0
        DllCall("LoadLibrary", "Str", "gdiplus")
        si := Buffer(24, 0)
        NumPut("UInt", 1, si)
        DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken, "Ptr", si, "Ptr", 0)
        
        pBitmap := 0
        DllCall("gdiplus\GdipCreateBitmapFromFile", "Str", path, "Ptr*", &pBitmap)
        
        width := 0, height := 0
        DllCall("gdiplus\GdipGetImageWidth", "Ptr", pBitmap, "UInt*", &width)
        DllCall("gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "UInt*", &height)
        
        DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
        DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
        
        return {width: width, height: height}
    } catch {
        return {width: 0, height: 0}
    }
}

; Initialize on load
IC_Initialize()
