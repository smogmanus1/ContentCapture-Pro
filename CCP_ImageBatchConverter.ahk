; ============================================================
; CCP_ImageBatchConverter.ahk
; ContentCapture Pro - Image -> Base64 Batch Converter Utility
; Run standalone to convert your existing image collection
; ============================================================
; USAGE
;   1. Run this script directly (not via CCP)
;   2. Point it at your images folder (e.g. E:\crisisoftruth\images\)
;   3. It scans for png/jpg/gif/bmp/ico/webp files
;   4. Encodes each to Base64 and appends to images.txt
;   5. Shows a size report so you know what you're dealing with
;
; OUTPUT FORMAT  (same as Joe Glines / existing xmas entry)
;   images.txt  ->  INI file, [Images] section
;   key = base64string
;
; The "key" defaults to the filename without extension
;   usrights.png  ->  key: usrights  ->  hotstring: ;;usrightsimg
;   mylogo.jpg    ->  key: mylogo    ->  hotstring: ;;mylogoimg
; ============================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; -- Configuration - edit these to match your setup ----------
DEFAULT_IMAGE_FOLDER := "E:\crisisoftruth\images"
DEFAULT_INI_FILE     := A_ScriptDir "\images.txt"
SUPPORTED_EXTS       := ["png", "jpg", "jpeg", "gif", "bmp", "ico", "webp"]
; Large images (over this KB) get a warning before encoding
LARGE_FILE_WARN_KB   := 200
; ------------------------------------------------------------

; Build the GUI
mainGui := Gui(, "CCP Image -> Base64 Batch Converter")
mainGui.SetFont("s10", "Segoe UI")
mainGui.OnEvent("Close", (*) => ExitApp())

mainGui.Add("GroupBox", "w580 h70 Section", "Source Folder")
editFolder := mainGui.Add("Edit", "xs+10 ys+22 w500", DEFAULT_IMAGE_FOLDER)
mainGui.Add("Button", "x+5 w60", "Browse").OnEvent("Click", BrowseFolder)

mainGui.Add("GroupBox", "xs w580 h70 Section", "Output INI File")
editIni := mainGui.Add("Edit", "xs+10 ys+22 w500", DEFAULT_INI_FILE)
mainGui.Add("Button", "x+5 w60", "Browse").OnEvent("Click", BrowseIni)

mainGui.Add("GroupBox", "xs w580 h120 Section", "Options")
cbSkipExisting := mainGui.Add("Checkbox", "xs+10 ys+25 Checked", "Skip images already in INI (don't re-encode)")
cbAddMeta      := mainGui.Add("Checkbox", "xs+10 yp+25 Checked", "Write metadata (source path, date captured)")
cbWarnLarge    := mainGui.Add("Checkbox", "xs+10 yp+25 Checked", "Warn before encoding images over " LARGE_FILE_WARN_KB "KB")
mainGui.Add("Text", "xs+10 yp+30", "Custom key prefix (leave blank for none):")
editPrefix     := mainGui.Add("Edit", "x+5 w100", "")
mainGui.Add("Text", "x+5", "  e.g. 'cot' -> cotusrights")

btnScan   := mainGui.Add("Button", "xs w180 h35 Section", "1. Scan Folder")
btnEncode := mainGui.Add("Button", "x+10 w180 h35 Disabled", "2. Encode Selected ->  images.txt")
btnReport := mainGui.Add("Button", "x+10 w180 h35 Disabled", "3. View Size Report")

btnScan.OnEvent("Click", ScanFolder)
btnEncode.OnEvent("Click", EncodeSelected)
btnReport.OnEvent("Click", ShowReport)

mainGui.Add("Text", "xs", "Found images:")
lvImages := mainGui.Add("ListView",
    "xs w580 h220 Checked -LV0x10 Grid",
    ["Key (hotstring root)", "File", "Size", "Status"])
lvImages.ModifyCol(1, 150)
lvImages.ModifyCol(2, 220)
lvImages.ModifyCol(3, 80)
lvImages.ModifyCol(4, 100)

statusBar := mainGui.Add("StatusBar")
statusBar.SetText("  Ready - scan a folder to begin")

mainGui.Show("w610")

; -- Global state --------------------------------------------
scannedFiles  := []   ; array of {path, name, key, sizeKB, status}
encodedCount  := 0

; -- Button handlers -----------------------------------------

BrowseFolder(*) {
    f := DirSelect("*" editFolder.Value,, "Select your images folder")
    if (f != "")
        editFolder.Value := f
}

BrowseIni(*) {
    f := FileSelect("S", editIni.Value, "Select output INI file", "INI files (*.txt;*.ini)")
    if (f != "")
        editIni.Value := f
}

ScanFolder(*) {
    global scannedFiles
    folder := editFolder.Value
    if !DirExist(folder) {
        MsgBox("Folder not found:`n" folder, "CCP Converter", "Icon!")
        return
    }

    iniFile  := editIni.Value
    prefix   := editPrefix.Value
    skipExisting := cbSkipExisting.Value

    ; Read existing keys from INI
    existingKeys := Map()
    if FileExist(iniFile) {
        loop read, iniFile {
            if RegExMatch(A_LoopReadLine, "^(\w+)=", &m)
                existingKeys[m[1]] := true
        }
    }

    scannedFiles := []
    lvImages.Delete()

    ; Scan for image files
    extPattern := ""
    for ext in SUPPORTED_EXTS
        extPattern .= (extPattern ? "|" : "") ext

    loop files, folder "\*.*", "F" {
        SplitPath(A_LoopFilePath, , , &ext, &nameNoExt)
        if !RegExMatch(ext, "i)^(" extPattern ")$")
            continue

        sizeKB := Round(A_LoopFileSize / 1024, 1)
        key    := prefix . nameNoExt

        status := "Ready"
        if skipExisting && existingKeys.Has(key)
            status := "Exists - skip"

        fileInfo := {
            path:   A_LoopFilePath,
            name:   A_LoopFileName,
            key:    key,
            sizeKB: sizeKB,
            status: status
        }
        scannedFiles.Push(fileInfo)

        row := lvImages.Add(status = "Exists - skip" ? "Check0" : "Check",
            key, A_LoopFileName, sizeKB " KB", status)

        ; Colour-code large files
        if (sizeKB > LARGE_FILE_WARN_KB)
            lvImages.Modify(row, , , , , , "!! Large")
    }

    count := scannedFiles.Length
    statusBar.SetText("  Found " count " image(s) - check the ones you want to encode")
    if (count > 0) {
        btnEncode.Enabled := true
        btnReport.Enabled := true
    }
}

EncodeSelected(*) {
    global scannedFiles, encodedCount
    iniFile  := editIni.Value
    addMeta  := cbAddMeta.Value
    warnLarge := cbWarnLarge.Value

    ; Collect checked rows
    toEncode := []
    row := 0
    loop {
        row := lvImages.GetNext(row, "Checked")
        if !row
            break
        fi := scannedFiles[row]
        if (fi.status = "Exists - skip")
            continue
        toEncode.Push({row: row, fi: fi})
    }

    if !toEncode.Length {
        MsgBox("No images checked to encode.", "CCP Converter", "Iconi")
        return
    }

    ; Warn about large files
    if warnLarge {
        largeList := ""
        for item in toEncode {
            if (item.fi.sizeKB > LARGE_FILE_WARN_KB)
                largeList .= "  " item.fi.name " (" item.fi.sizeKB " KB)`n"
        }
        if largeList {
            result := MsgBox(
                "These images are over " LARGE_FILE_WARN_KB "KB and will produce large base64 strings:`n`n"
                . largeList
                . "`nLarge images may slow down CCP or bloat images.txt.`n"
                . "Consider resizing them first.`n`nContinue anyway?",
                "CCP Converter - Large File Warning", "YesNo Icon!")
            if (result = "No")
                return
        }
    }

    ; Encode each checked image
    encodedCount := 0
    failed := 0

    for item in toEncode {
        fi  := item.fi
        row := item.row

        statusBar.SetText("  Encoding: " fi.name "...")
        lvImages.Modify(row, , , , , , "Encoding...")

        b64 := ImageToBase64_v2(fi.path)
        if (b64 = "") {
            lvImages.Modify(row, , , , , , "FAILED")
            failed++
            continue
        }

        b64Len := StrLen(b64)
        b64KB  := Round(b64Len / 1024, 1)

        ; Write to INI
        IniWrite(b64, iniFile, "Images", fi.key)

        if addMeta {
            IniWrite(fi.name,   iniFile, "Meta_" fi.key, "sourceFile")
            IniWrite(fi.path,   iniFile, "Meta_" fi.key, "sourcePath")
            IniWrite(fi.sizeKB, iniFile, "Meta_" fi.key, "origSizeKB")
            IniWrite(b64KB,     iniFile, "Meta_" fi.key, "b64SizeKB")
            IniWrite(FormatTime(, "yyyy-MM-dd HH:mm:ss"), iniFile, "Meta_" fi.key, "captured")
        }

        lvImages.Modify(row, , , , , , "DONE Saved (" b64KB "KB)")
        encodedCount++
    }

    statusBar.SetText("  Done - " encodedCount " encoded, " failed " failed. INI: " iniFile)
    if (encodedCount > 0) {
        doneMsg := encodedCount " image(s) encoded and saved to:`n"
        doneMsg .= iniFile "`n`n"
        doneMsg .= "Hotstring format:  ;;<key>img`n"
        doneMsg .= "Example:  ;;usrightsimg`n`n"
        doneMsg .= "Add  #Include ImageCapture.ahk  to your CCP script,`n"
        doneMsg .= "then add the 'img' case to your suffix handler."
        MsgBox(doneMsg, "CCP Converter - Complete", "Iconi")
    }
}

ShowReport(*) {
    iniFile := editIni.Value
    if !FileExist(iniFile) {
        MsgBox("INI file not found yet - encode some images first.", "Report", "Iconi")
        return
    }

    ; Parse INI and report sizes
    report := "images.txt Size Report`n"
        . "File: " iniFile "`n"
        . StrReplace(Format("{:-" (StrLen(iniFile) + 14) "s}", ""), " ", "-") "`n`n"
        . Format("{:-25s} {:>10s}  {:>10s}`n", "Key", "B64 Size", "Orig Est.")
        . RepeatStr("-", 48) "`n"

    totalB64 := 0
    keyCount := 0

    loop read, iniFile {
        if RegExMatch(A_LoopReadLine, "^(\w+)=(.+)$", &m) {
            key    := m[1]
            b64len := StrLen(m[2])
            origEst := Round(b64len * 3 / 4 / 1024, 1)
            b64KB   := Round(b64len / 1024, 1)
            totalB64 += b64len
            keyCount++
            report .= Format("{:-25s} {:>8s}KB  {:>8s}KB`n", key, b64KB, origEst)
        }
    }

    report .= RepeatStr("-", 48) "`n"
    report .= Format("{:-25s} {:>8s}KB`n", "TOTAL (" keyCount " images)", Round(totalB64/1024, 1))
    report .= "`nNote: images.txt is loaded on demand - only`n"
        . "the requested image is decoded per hotstring fire."

    repGui := Gui(, "CCP images.txt Size Report")
    repGui.SetFont("s9", "Consolas")
    repGui.Add("Edit", "w500 h350 ReadOnly -Wrap", report)
    repGui.Add("Button", "w100", "Close").OnEvent("Click", (*) => repGui.Destroy())
    repGui.Show()
}


; -- Helper - repeat a character n times ----------------------
RepeatStr(char, n) {
    result := ""
    loop n
        result .= char
    return result
}

; -- Core encoder (AHK v2 native) ----------------------------
ImageToBase64_v2(filePath) {
    if !FileExist(filePath)
        return ""
    try {
        f := FileOpen(filePath, "rb")
        nBytes := f.Length
        buf := Buffer(nBytes, 0)
        f.RawRead(buf, nBytes)
        f.Close()
    } catch {
        return ""
    }

    outSize := 0
    DllCall("Crypt32.dll\CryptBinaryToStringW",
        "Ptr",   buf,
        "UInt",  nBytes,
        "UInt",  0x40000001,   ; CRYPT_STRING_BASE64 | CRYPT_STRING_NOCRLF
        "Ptr",   0,
        "UInt*", &outSize)

    if !outSize
        return ""

    outBuf := Buffer(outSize * 2, 0)
    DllCall("Crypt32.dll\CryptBinaryToStringW",
        "Ptr",   buf,
        "UInt",  nBytes,
        "UInt",  0x40000001,
        "Ptr",   outBuf,
        "UInt*", &outSize)

    return RTrim(StrGet(outBuf, "UTF-16"), "`r`n ")
}
