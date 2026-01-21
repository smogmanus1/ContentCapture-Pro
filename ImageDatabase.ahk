; ==============================================================================
; ImageDatabase.ahk - Multiple Image Management for ContentCapture Pro
; ==============================================================================
; Version: 1.0
; Handles: images.dat file, multiple images per capture, image attachments
; ==============================================================================

#Requires AutoHotkey v2.0

global IDB_ImageAssociations := Map()

; ==============================================================================
; DATABASE FILE FORMAT (images.dat)
; ==============================================================================
; Each line: captureName|imagePath1|imagePath2|imagePath3|...
; Example:
; oneenable|congresscensorship.jpg|fascism-warning.png
; dtenable3|america-flag.jpg
; myrecipe|step1.png|step2.png|step3.png|finished.jpg
; ==============================================================================

; ==============================================================================
; LOAD/SAVE
; ==============================================================================

IDB_LoadImageDatabase() {
    global IDB_ImageAssociations, BaseDir
    
    IDB_ImageAssociations := Map()
    imagesFile := BaseDir "\images.dat"
    
    if !FileExist(imagesFile)
        return
    
    content := FileRead(imagesFile, "UTF-8")
    
    Loop Parse, content, "`n", "`r" {
        line := Trim(A_LoopField)
        if line = "" || SubStr(line, 1, 1) = ";"  ; Skip empty lines and comments
            continue
        
        parts := StrSplit(line, "|")
        if parts.Length < 2
            continue
        
        captureName := parts[1]
        images := []
        
        Loop parts.Length - 1 {
            imgPath := Trim(parts[A_Index + 1])
            if imgPath != ""
                images.Push(imgPath)
        }
        
        if images.Length > 0
            IDB_ImageAssociations[captureName] := images
    }
}

IDB_SaveImageDatabase() {
    global IDB_ImageAssociations, BaseDir
    
    imagesFile := BaseDir "\images.dat"
    content := "; ContentCapture Pro Image Database`n"
    content .= "; Format: captureName|image1|image2|...`n"
    content .= "; Generated: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n`n"
    
    for captureName, images in IDB_ImageAssociations {
        line := captureName
        for imgPath in images
            line .= "|" imgPath
        content .= line "`n"
    }
    
    try {
        if FileExist(imagesFile)
            FileDelete(imagesFile)
        FileAppend(content, imagesFile, "UTF-8")
        return true
    } catch as err {
        return false
    }
}

; ==============================================================================
; IMAGE MANAGEMENT
; ==============================================================================

; Add image(s) to a capture
IDB_AddImages(captureName, imagePaths*) {
    global IDB_ImageAssociations, BaseDir
    
    ; Ensure capture has an entry
    if !IDB_ImageAssociations.Has(captureName)
        IDB_ImageAssociations[captureName] := []
    
    images := IDB_ImageAssociations[captureName]
    
    for imgPath in imagePaths {
        ; Copy image to images folder if not already there
        finalPath := IDB_CopyImageToFolder(imgPath)
        if finalPath != "" && !IDB_ArrayContains(images, finalPath)
            images.Push(finalPath)
    }
    
    IDB_ImageAssociations[captureName] := images
    IDB_SaveImageDatabase()
    
    return images.Length
}

; Remove specific image from a capture
IDB_RemoveImage(captureName, imagePath) {
    global IDB_ImageAssociations
    
    if !IDB_ImageAssociations.Has(captureName)
        return false
    
    images := IDB_ImageAssociations[captureName]
    newImages := []
    
    for img in images {
        if img != imagePath
            newImages.Push(img)
    }
    
    if newImages.Length > 0
        IDB_ImageAssociations[captureName] := newImages
    else
        IDB_ImageAssociations.Delete(captureName)
    
    IDB_SaveImageDatabase()
    return true
}

; Remove all images from a capture
IDB_ClearImages(captureName) {
    global IDB_ImageAssociations
    
    if IDB_ImageAssociations.Has(captureName) {
        IDB_ImageAssociations.Delete(captureName)
        IDB_SaveImageDatabase()
        return true
    }
    return false
}

; Get all images for a capture
IDB_GetImages(captureName) {
    global IDB_ImageAssociations, BaseDir
    
    if !IDB_ImageAssociations.Has(captureName)
        return []
    
    images := []
    imagesFolder := BaseDir "\images\"
    
    for imgPath in IDB_ImageAssociations[captureName] {
        ; Handle relative vs absolute paths
        fullPath := imgPath
        if !InStr(imgPath, ":") && !InStr(imgPath, "\\")
            fullPath := imagesFolder imgPath
        
        if FileExist(fullPath)
            images.Push(fullPath)
    }
    
    return images
}

; Check if capture has any images
IDB_HasImages(captureName) {
    return IDB_GetImages(captureName).Length > 0
}

; Get image count
IDB_GetImageCount(captureName) {
    return IDB_GetImages(captureName).Length
}

; ==============================================================================
; FILE OPERATIONS
; ==============================================================================

; Copy image to images folder, return relative path
IDB_CopyImageToFolder(sourcePath) {
    global BaseDir
    
    if !FileExist(sourcePath)
        return ""
    
    ; Get filename
    SplitPath(sourcePath, &filename)
    
    ; Ensure images folder exists
    imagesFolder := BaseDir "\images"
    if !DirExist(imagesFolder)
        DirCreate(imagesFolder)
    
    destPath := imagesFolder "\" filename
    
    ; Handle duplicate filenames
    if FileExist(destPath) {
        SplitPath(sourcePath, , , &ext, &nameNoExt)
        counter := 1
        Loop {
            destPath := imagesFolder "\" nameNoExt "_" counter "." ext
            if !FileExist(destPath)
                break
            counter++
        }
        SplitPath(destPath, &filename)
    }
    
    ; Copy file
    try {
        FileCopy(sourcePath, destPath)
        return filename  ; Return relative path
    } catch {
        return ""
    }
}

; Delete image file from images folder
IDB_DeleteImageFile(imagePath) {
    global BaseDir
    
    ; Build full path if relative
    fullPath := imagePath
    if !InStr(imagePath, ":") && !InStr(imagePath, "\\")
        fullPath := BaseDir "\images\" imagePath
    
    if FileExist(fullPath) {
        try {
            FileDelete(fullPath)
            return true
        }
    }
    return false
}

; ==============================================================================
; HELPER FUNCTIONS
; ==============================================================================

IDB_ArrayContains(arr, value) {
    for item in arr {
        if item = value
            return true
    }
    return false
}

; ==============================================================================
; GUI HELPERS - For integration with Edit dialog
; ==============================================================================

; Open file picker to add images
IDB_PickAndAddImages(captureName) {
    selectedFiles := FileSelect("M35", , "Select Images", "Images (*.jpg; *.jpeg; *.png; *.gif; *.bmp)")
    
    if selectedFiles = ""
        return 0
    
    ; Handle single vs multiple selection
    if Type(selectedFiles) = "String" {
        return IDB_AddImages(captureName, selectedFiles)
    }
    
    ; Multiple files - first element is folder, rest are filenames
    folder := selectedFiles[1]
    added := 0
    Loop selectedFiles.Length - 1 {
        fullPath := folder "\" selectedFiles[A_Index + 1]
        added += IDB_AddImages(captureName, fullPath)
    }
    
    return added
}

; Get display text for images (for Edit dialog)
IDB_GetImagesDisplayText(captureName) {
    images := IDB_GetImages(captureName)
    if images.Length = 0
        return "No images attached"
    
    if images.Length = 1 {
        SplitPath(images[1], &name)
        return "📷 " name
    }
    
    return "📷 " images.Length " images attached"
}

; ==============================================================================
; INITIALIZATION
; ==============================================================================

; Call IDB_LoadImageDatabase() from your main script AFTER BaseDir is set
; Example: Put this in ContentCapture-Pro.ahk after CC_LoadCaptureData():
;   IDB_LoadImageDatabase()
