#Requires AutoHotkey v2.0+

; ==============================================================================
; ImageClipboard.ahk - GDI+ Image Clipboard Operations
; ==============================================================================
; Fast, native Windows GDI+ implementation for copying images to clipboard.
; Much faster and more reliable than PowerShell methods.
;
; Functions:
;   IC_CopyImageToClipboardGDI(imagePath) - Copy image to clipboard
;   IC_GetImageDimensionsGDI(imagePath)   - Get image width/height
;
; Usage: #Include this file in ContentCapture-Pro.ahk
; ==============================================================================

; Copy image to clipboard using GDI+
IC_CopyImageToClipboardGDI(imagePath) {
    if (!FileExist(imagePath)) {
        return false
    }
    
    ; Initialize GDI+
    pToken := 0
    hGdiplus := DllCall("LoadLibrary", "Str", "gdiplus", "Ptr")
    
    si := Buffer(24, 0)
    NumPut("UInt", 1, si)
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken, "Ptr", si, "Ptr", 0)
    
    ; Load image
    pBitmap := 0
    DllCall("gdiplus\GdipCreateBitmapFromFile", "Str", imagePath, "Ptr*", &pBitmap)
    
    if (!pBitmap) {
        DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
        return false
    }
    
    ; Get HBITMAP
    hBitmap := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap", "Ptr", pBitmap, "Ptr*", &hBitmap, "UInt", 0xFFFFFFFF)
    
    ; Copy to clipboard
    success := false
    if (hBitmap && DllCall("OpenClipboard", "Ptr", 0)) {
        DllCall("EmptyClipboard")
        
        ; Create a compatible bitmap for clipboard
        hdc := DllCall("GetDC", "Ptr", 0, "Ptr")
        hdcMem := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
        
        ; Get bitmap info
        bm := Buffer(24, 0)
        DllCall("GetObject", "Ptr", hBitmap, "Int", 24, "Ptr", bm)
        width := NumGet(bm, 4, "Int")
        height := NumGet(bm, 8, "Int")
        
        ; Create DIB section
        bi := Buffer(40, 0)
        NumPut("UInt", 40, bi, 0)        ; biSize
        NumPut("Int", width, bi, 4)       ; biWidth
        NumPut("Int", height, bi, 8)      ; biHeight
        NumPut("UShort", 1, bi, 12)       ; biPlanes
        NumPut("UShort", 32, bi, 14)      ; biBitCount
        
        pBits := 0
        hDib := DllCall("CreateDIBSection", "Ptr", hdc, "Ptr", bi, "UInt", 0, "Ptr*", &pBits, "Ptr", 0, "UInt", 0, "Ptr")
        
        if (hDib) {
            hOld := DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hDib, "Ptr")
            
            ; Draw the original bitmap to the DIB
            hdcSrc := DllCall("CreateCompatibleDC", "Ptr", hdc, "Ptr")
            hOldSrc := DllCall("SelectObject", "Ptr", hdcSrc, "Ptr", hBitmap, "Ptr")
            DllCall("BitBlt", "Ptr", hdcMem, "Int", 0, "Int", 0, "Int", width, "Int", height,
                    "Ptr", hdcSrc, "Int", 0, "Int", 0, "UInt", 0x00CC0020)  ; SRCCOPY
            DllCall("SelectObject", "Ptr", hdcSrc, "Ptr", hOldSrc)
            DllCall("DeleteDC", "Ptr", hdcSrc)
            
            DllCall("SelectObject", "Ptr", hdcMem, "Ptr", hOld)
            
            ; Set clipboard data
            if (DllCall("SetClipboardData", "UInt", 2, "Ptr", hDib))  ; CF_BITMAP = 2
                success := true
        }
        
        DllCall("DeleteDC", "Ptr", hdcMem)
        DllCall("ReleaseDC", "Ptr", 0, "Ptr", hdc)
        DllCall("CloseClipboard")
    }
    
    ; Cleanup
    DllCall("DeleteObject", "Ptr", hBitmap)
    DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
    
    return success
}

; Get image dimensions using GDI+
IC_GetImageDimensionsGDI(imagePath) {
    if (!FileExist(imagePath))
        return {width: 0, height: 0}
    
    ; Initialize GDI+
    pToken := 0
    DllCall("LoadLibrary", "Str", "gdiplus")
    
    si := Buffer(24, 0)
    NumPut("UInt", 1, si)
    DllCall("gdiplus\GdiplusStartup", "Ptr*", &pToken, "Ptr", si, "Ptr", 0)
    
    ; Load image
    pBitmap := 0
    DllCall("gdiplus\GdipCreateBitmapFromFile", "Str", imagePath, "Ptr*", &pBitmap)
    
    width := 0, height := 0
    if (pBitmap) {
        DllCall("gdiplus\GdipGetImageWidth", "Ptr", pBitmap, "UInt*", &width)
        DllCall("gdiplus\GdipGetImageHeight", "Ptr", pBitmap, "UInt*", &height)
        DllCall("gdiplus\GdipDisposeImage", "Ptr", pBitmap)
    }
    
    DllCall("gdiplus\GdiplusShutdown", "Ptr", pToken)
    
    return {width: width, height: height}
}

; PowerShell fallback for older systems
IC_CopyImageToClipboardPS(imagePath) {
    if (!FileExist(imagePath))
        return false
    
    psScript := '
    (
    Add-Type -AssemblyName System.Windows.Forms
    $image = [System.Drawing.Image]::FromFile("' imagePath '")
    [System.Windows.Forms.Clipboard]::SetImage($image)
    $image.Dispose()
    )'
    
    try {
        RunWait('powershell.exe -NoProfile -Command "' psScript '"',, "Hide")
        return true
    } catch {
        return false
    }
}
