#Requires AutoHotkey v2.0+

; ==============================================================================
; ImageCapture.ahk - Image Attachment System for ContentCapture Pro
; ==============================================================================
; Version:     1.2
; Updated:     2026-03-23
;
; CHANGELOG v1.2:
;   - IC_HasImage()     checks images.db (SQLite) first, falls back to images.dat
;   - IC_GetImagePath() decodes Base64 from images.db to a temp file when found
;     in SQLite. Falls back to images.dat file path.
;   - Added IC_Base64ToTempFile() — decodes Base64 → temp file in A_Temp,
;     auto-detects jpg/png/gif/bmp/webp from magic bytes.
;   - Temp files use _ccpimg_ prefix. Caller responsible for cleanup when path
;     contains _ccpimg_ (use IC_CleanTempFile or check InStr(path,"_ccpimg_")).
;
; CHANGELOG v1.1:
;   - Original file-based image attachment system
; ==============================================================================

global ImageData     := Map()
global ImageDir      := ""
global ImageDataFile := ""

; ---------------------------------------------------------------------------
; INITIALIZATION
; ---------------------------------------------------------------------------

IC_Initialize() {
    global ImageDir, ImageDataFile, ImageData
    ImageDir      := A_ScriptDir "\images"
    ImageDataFile := A_ScriptDir "\images.dat"
    if !DirExist(ImageDir)
        DirCreate(ImageDir)
    IC_LoadImageData()
}

IC_LoadImageData() {
    global ImageData, ImageDataFile
    ImageData := Map()
    if !FileExist(ImageDataFile)
        return
    try {
        content := FileRead(ImageDataFile, "UTF-8")
        for line in StrSplit(content, "`n", "`r") {
            if line = ""
                continue
            parts := StrSplit(line, "|")
            if parts.Length >= 2
                ImageData[parts[1]] := parts[2]
        }
    }
}

IC_SaveImageData() {
    global ImageData, ImageDataFile
    content := ""
    for name, path in ImageData
        content .= name "|" path "`n"
    try {
        FileDelete(ImageDataFile)
    }
    if content != ""
        FileAppend(content, ImageDataFile, "UTF-8")
}

; ---------------------------------------------------------------------------
; CHECK / RETRIEVE  (SQLite-first)
; ---------------------------------------------------------------------------

; Returns true if a capture has an associated image.
; Checks images.db first, then images.dat.
IC_HasImage(name) {
    ; --- SQLite ---
    dbPath := A_ScriptDir "\images.db"
    if FileExist(dbPath) {
        try {
            db     := CCP_DB_Open(dbPath)
            exists := CCP_DB_KeyExists(db, name)
            CCP_DB_Close(db)
            if exists
                return true
        } catch {
            ; DB unavailable — fall through
        }
    }
    ; --- Legacy images.dat ---
    global ImageData
    if !ImageData.Has(name)
        return false
    path := ImageData[name]
    return path != "" && FileExist(path)
}

; Returns the image path for a capture.
; If found in SQLite: decodes Base64 → temp file, returns that path.
; If found in images.dat: returns the stored file path.
; Returns "" if not found.
; NOTE: Temp file paths contain "_ccpimg_". Caller should delete when done.
IC_GetImagePath(name) {
    ; --- SQLite ---
    dbPath := A_ScriptDir "\images.db"
    if FileExist(dbPath) {
        try {
            db  := CCP_DB_Open(dbPath)
            b64 := CCP_DB_GetImage(db, name)
            CCP_DB_Close(db)
            if b64 != "" {
                tmpPath := IC_Base64ToTempFile(b64)
                if tmpPath != ""
                    return tmpPath
            }
        } catch {
            ; DB unavailable — fall through
        }
    }
    ; --- Legacy images.dat ---
    global ImageData
    if !ImageData.Has(name)
        return ""
    return ImageData[name]
}

; ---------------------------------------------------------------------------
; BASE64 → TEMP FILE
; ---------------------------------------------------------------------------

IC_Base64ToTempFile(b64) {
    b64 := RegExReplace(b64, "\s+", "")
    if b64 = ""
        return ""

    nBytes := 0
    DllCall("Crypt32.dll\CryptStringToBinaryW",
        "Str",   b64,  "UInt", 0, "UInt", 1,
        "Ptr",   0,    "UInt*", &nBytes, "Ptr", 0, "Ptr", 0)
    if nBytes = 0
        return ""

    buf := Buffer(nBytes)
    DllCall("Crypt32.dll\CryptStringToBinaryW",
        "Str",   b64,  "UInt", 0, "UInt", 1,
        "Ptr",   buf,  "UInt*", &nBytes, "Ptr", 0, "Ptr", 0)

    ; Detect image type from magic bytes
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
        else if b0 = 0x52 && b1 = 0x49 && b2 = 0x46 && b3 = 0x46       ; WEBP (RIFF)
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

; Deletes a temp file created by IC_Base64ToTempFile (safe to call on any path)
IC_CleanTempFile(path) {
    if path != "" && InStr(path, "_ccpimg_") && FileExist(path)
        try FileDelete(path)
}

; ---------------------------------------------------------------------------
; ATTACH / REMOVE  (writes to images.dat — legacy system)
; ---------------------------------------------------------------------------

; Attach an image to a capture. Copies file to local images\ folder.
IC_AttachImage(name, sourcePath := "") {
    global ImageData, ImageDir

    if sourcePath = "" {
        sourcePath := FileSelect("1", , "Select Image for '" name "'",
            "Images (*.png; *.jpg; *.jpeg; *.gif; *.bmp; *.webp)")
        if sourcePath = ""
            return false
    }

    if !FileExist(sourcePath) {
        MsgBox("Image file not found:`n" sourcePath, "Error", "48")
        return false
    }

    SplitPath(sourcePath, , , &ext)
    newFileName := name "_" A_Now "." ext
    newPath     := ImageDir "\" newFileName

    try {
        FileCopy(sourcePath, newPath, 1)
    } catch as err {
        MsgBox("Failed to copy image:`n" err.Message, "Error", "48")
        return false
    }

    ImageData[name] := newPath
    IC_SaveImageData()
    TrayTip("Image attached to '" name "'", "📷 Image Added", "1")
    return true
}

; Remove image attachment from a capture
IC_RemoveImage(name) {
    global ImageData
    if !ImageData.Has(name)
        return
    path := ImageData[name]
    if FileExist(path) {
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
    if path = "" || !FileExist(path) {
        MsgBox("No image found for '" name "'", "No Image", "48")
        return
    }
    Run(path)
}

; Get image dimensions via GDI+
IC_GetImageDimensions(path) {
    if !FileExist(path)
        return {width: 0, height: 0}
    try {
        pToken := 0
        DllCall("LoadLibrary", "Str", "gdiplus")
        si := Buffer(24, 0)
        NumPut("UInt", 1, si)
        DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken, "Ptr", si, "Ptr", 0)
        pBitmap := 0
        DllCall("gdiplus\GdipCreateBitmapFromFile", "Str", path, "Ptr*", &pBitmap)
        width := 0, height := 0
        DllCall("gdiplus\GdipGetImageWidth",  "Ptr", pBitmap, "UInt*", &width)
        DllCall("gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "UInt*", &height)
        DllCall("gdiplus\GdipDisposeImage",   "Ptr", pBitmap)
        DllCall("gdiplus\GdiplusShutdown",    "Ptr", pToken)
        return {width: width, height: height}
    } catch {
        return {width: 0, height: 0}
    }
}

; ---------------------------------------------------------------------------
; AUTO-INITIALIZE
; ---------------------------------------------------------------------------
IC_Initialize()
