; ==============================================================================
; ManualCaptureImageGUI.ahk - GUI Controls for Image Attachment
; ==============================================================================
; Version: 1.0
; 
; REQUIRES: ImageDatabase.ahk (for IDB_* functions)
;           ImageClipboard.ahk (for IC_CopyImageToClipboardGDI, IC_GetImageDimensionsGDI)
;
; This adds Browse/Paste/Clear buttons + preview to your ManualCapture GUI.
; Uses your existing image infrastructure - no duplicate code!
;
; Usage:
;   1. #Include this file AFTER ImageDatabase.ahk and ImageClipboard.ahk
;   2. Call MCIG_AddToGUI(myGui) after building your other GUI controls
;   3. Call MCIG_SaveImages(captureName) in your Save function
; ==============================================================================

class MCIG {
    ; GUI control references
    static ImagePathEdit := ""
    static PreviewPic := ""
    static ParentGui := ""
    
    ; Pending images (before save)
    static PendingImages := []
    
    ; Supported formats
    static Formats := "*.jpg;*.jpeg;*.png;*.gif;*.bmp;*.webp"
    
    ; ===========================================================================
    ; GUI SETUP
    ; ===========================================================================
    
    /**
     * Add image controls to ManualCapture GUI
     * Call this after your "Research Notes" section
     * 
     * @param {Gui} guiObj - Your ManualCapture GUI object
     */
    static AddToGUI(guiObj) {
        this.ParentGui := guiObj
        this.PendingImages := []
        
        ; Section label
        guiObj.Add("Text", "xm y+15", "📷 Attached Image (optional):")
        
        ; Image path/status display (read-only)
        this.ImagePathEdit := guiObj.Add("Edit", "xm w350 vImagePath ReadOnly", "")
        
        ; Browse button
        btnBrowse := guiObj.Add("Button", "x+5 yp-1 w70", "Browse...")
        btnBrowse.OnEvent("Click", (*) => this.OnBrowse())
        
        ; Paste from clipboard
        btnPaste := guiObj.Add("Button", "x+5 w60", "Paste")
        btnPaste.OnEvent("Click", (*) => this.OnPaste())
        
        ; Clear button
        btnClear := guiObj.Add("Button", "x+5 w50", "Clear")
        btnClear.OnEvent("Click", (*) => this.OnClear())
        
        ; Thumbnail preview
        this.PreviewPic := guiObj.Add("Picture", "xm y+5 w150 h100 vImagePreview Border", "")
        guiObj.Add("Text", "x+10 yp+40", "← Preview")
        
        ; Enable drag-and-drop on GUI
        guiObj.OnEvent("DropFiles", (g, ctrl, files, *) => this.OnDropFiles(files))
    }
    
    ; ===========================================================================
    ; EVENT HANDLERS
    ; ===========================================================================
    
    static OnBrowse() {
        selectedFile := FileSelect(1,, "Select Image to Attach", "Images (" this.Formats ")")
        
        if (selectedFile != "") {
            this.AddImage(selectedFile)
        }
    }
    
    static OnPaste() {
        ; Check if clipboard has a file path
        clipText := A_Clipboard
        if (clipText != "" && FileExist(clipText)) {
            SplitPath(clipText,,, &ext)
            if this.IsValidFormat(ext) {
                this.AddImage(clipText)
                return
            }
        }
        
        ; Try to save clipboard bitmap
        savedPath := this.SaveClipboardBitmap()
        if (savedPath != "") {
            this.AddImage(savedPath)
        } else {
            ToolTip("No image found in clipboard")
            SetTimer(() => ToolTip(), -2000)
        }
    }
    
    static OnClear() {
        this.PendingImages := []
        this.ImagePathEdit.Value := ""
        try this.PreviewPic.Value := ""
    }
    
    static OnDropFiles(fileArray) {
        for filePath in fileArray {
            SplitPath(filePath,,, &ext)
            if this.IsValidFormat(ext)
                this.AddImage(filePath)
        }
    }
    
    ; ===========================================================================
    ; IMAGE MANAGEMENT
    ; ===========================================================================
    
    static AddImage(imagePath) {
        if (imagePath = "" || !FileExist(imagePath))
            return
        
        ; Add to pending list (avoid duplicates)
        for existing in this.PendingImages {
            if (existing = imagePath)
                return
        }
        
        this.PendingImages.Push(imagePath)
        this.UpdateDisplay()
    }
    
    static UpdateDisplay() {
        count := this.PendingImages.Length
        
        if (count = 0) {
            this.ImagePathEdit.Value := ""
            try this.PreviewPic.Value := ""
            return
        }
        
        ; Show status text
        if (count = 1) {
            SplitPath(this.PendingImages[1], &name)
            this.ImagePathEdit.Value := "📷 " name
        } else {
            this.ImagePathEdit.Value := "📷 " count " images selected"
        }
        
        ; Show preview of first image
        this.UpdatePreview(this.PendingImages[1])
    }
    
    static UpdatePreview(imagePath) {
        if (imagePath = "" || !FileExist(imagePath)) {
            try this.PreviewPic.Value := ""
            return
        }
        
        try {
            ; Use existing GDI function from ImageClipboard.ahk
            dims := IC_GetImageDimensionsGDI(imagePath)
            
            ; Calculate scaled size (max 150x100)
            maxW := 150, maxH := 100
            if (dims.width > 0 && dims.height > 0) {
                ratio := Min(maxW / dims.width, maxH / dims.height)
                dispW := Round(dims.width * ratio)
                dispH := Round(dims.height * ratio)
            } else {
                dispW := maxW
                dispH := maxH
            }
            
            this.PreviewPic.Value := "*w" dispW " *h" dispH " " imagePath
        } catch {
            try this.PreviewPic.Value := ""
        }
    }
    
    ; ===========================================================================
    ; SAVE / LOAD
    ; ===========================================================================
    
    /**
     * Save pending images for a capture
     * Call this from your SaveCapture function
     * 
     * @param {String} captureName - The hotstring name being saved
     * @returns {Number} Number of images saved
     */
    static SaveImages(captureName) {
        if (this.PendingImages.Length = 0)
            return 0
        
        ; Use IDB_AddImages from ImageDatabase.ahk
        ; It handles copying to images folder and updating images.dat
        count := 0
        for imagePath in this.PendingImages {
            result := IDB_AddImages(captureName, imagePath)
            count += result
        }
        
        ; Clear pending after save
        this.PendingImages := []
        
        return count
    }
    
    /**
     * Load existing images when editing a capture
     * Call this when opening the edit dialog
     * 
     * @param {String} captureName - The hotstring name being edited
     */
    static LoadForEdit(captureName) {
        this.OnClear()  ; Reset first
        
        ; Use IDB_GetImages from ImageDatabase.ahk
        images := IDB_GetImages(captureName)
        
        for imagePath in images {
            this.PendingImages.Push(imagePath)
        }
        
        this.UpdateDisplay()
    }
    
    /**
     * Get count of pending images
     */
    static GetImageCount() {
        return this.PendingImages.Length
    }
    
    /**
     * Check if any images are pending
     */
    static HasImages() {
        return this.PendingImages.Length > 0
    }
    
    ; ===========================================================================
    ; HELPERS
    ; ===========================================================================
    
    static IsValidFormat(ext) {
        ext := StrLower(ext)
        return (ext = "jpg" || ext = "jpeg" || ext = "png" || 
                ext = "gif" || ext = "bmp" || ext = "webp")
    }
    
    /**
     * Save clipboard bitmap to images folder
     */
    static SaveClipboardBitmap() {
        global BaseDir
        
        ; Ensure images folder exists
        imagesFolder := BaseDir "\images"
        if !DirExist(imagesFolder)
            DirCreate(imagesFolder)
        
        ; Initialize GDI+
        pToken := 0
        DllCall("LoadLibrary", "Str", "gdiplus")
        si := Buffer(24, 0)
        NumPut("UInt", 1, si)
        
        if DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken, "Ptr", si, "Ptr", 0)
            return ""
        
        ; Open clipboard and get bitmap
        if !DllCall("OpenClipboard", "Ptr", A_ScriptHwnd) {
            DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
            return ""
        }
        
        hBitmap := DllCall("GetClipboardData", "UInt", 2, "Ptr")  ; CF_BITMAP = 2
        DllCall("CloseClipboard")
        
        if (!hBitmap) {
            DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
            return ""
        }
        
        ; Create GDI+ bitmap from HBITMAP
        pBitmap := 0
        DllCall("gdiplus\GdipCreateBitmapFromHBITMAP", "Ptr", hBitmap, "Ptr", 0, "Ptr*", &pBitmap)
        
        if (!pBitmap) {
            DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
            return ""
        }
        
        ; Generate unique filename
        savePath := imagesFolder "\clipboard_" A_Now ".png"
        
        ; Get PNG encoder CLSID
        CLSID := Buffer(16)
        DllCall("ole32\CLSIDFromString", "WStr", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "Ptr", CLSID)
        
        ; Save image
        result := DllCall("gdiplus\GdipSaveImageToFile", "Ptr", pBitmap, "WStr", savePath, "Ptr", CLSID, "Ptr", 0)
        
        ; Cleanup
        DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
        DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
        
        return (result = 0) ? savePath : ""
    }
}


; ==============================================================================
; INTEGRATION INSTRUCTIONS
; ==============================================================================
;
; 1. ADD #Include in your main script (after your other image includes):
;
;        #Include ImageDatabase.ahk
;        #Include ImageClipboard.ahk
;        #Include ManualCaptureImageGUI.ahk   ; <-- Add this
;
;
; 2. In your ManualCapture GUI building code, ADD this ONE line
;    after your "Research Notes" section:
;
;        MCIG.AddToGUI(myGui)
;
;
; 3. In your SAVE function, ADD this before final save:
;
;        imageCount := MCIG.SaveImages(hotstringName)
;        if (imageCount > 0)
;            TrayTip("Saved with " imageCount " image(s)", "📷", 1)
;
;
; 4. If you have an EDIT function, ADD this when loading:
;
;        MCIG.LoadForEdit(hotstringName)
;
;
; That's it! The GUI will handle:
;   ✓ Browse button (file picker)
;   ✓ Paste button (clipboard images)
;   ✓ Drag-and-drop onto GUI
;   ✓ Thumbnail preview
;   ✓ Multiple images support
;   ✓ Auto-save to images folder via IDB_AddImages()
;
; ==============================================================================
