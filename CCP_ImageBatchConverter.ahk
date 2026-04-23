; CCP_ImageBatchConverter.ahk
; ContentCapture Pro - Batch Image to Base64 Converter
; Stores images in SQLite (images.db) - no size limits
; Supports platform canvas fitting: Pinterest, Bluesky, LinkedIn
; Requires: winsqlite3.dll + CCP_SQLite.ahk in same folder
; AHK v2 - UTF-8 with BOM

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include CCP_SQLite.ahk

; -- Pad color ARGB values (0xAARRGGBB) ---
global padColors := Map(
    "White",      0xFFFFFFFF,
    "Black",      0xFF000000,
    "Light Gray", 0xFFD3D3D3,
    "Dark Gray",  0xFF404040
)

; -- Folder abbreviation map ---
global folderAbbrev := Map(
    "big-beautiful-bill",    "bbb",
    "children-deportation",  "childep",
    "debunking-claims",      "debunk",
    "due-process",           "dueproc",
    "economy-class",         "econ",
    "facebook",              "fb",
    "fascism-democracy",     "fascdem",
    "friends-debates",       "friends",
    "general-political",     "genpol",
    "immigration-ice",       "ice",
    "maga-supporters",       "maga",
    "massdet",               "massdet",
    "media-propaganda",      "media",
    "military-history",      "mil",
    "religion-hypocrisy",    "relig",
    "screenshots-misc",      "misc",
    "shareables",            "share",
    "site-assets",           "site",
    "trump",                 "trump",
    "thejokeisontheidiots",  "joke",
    "america",               "america",
    "a_data",                "skip"
)

global skipFolders  := ["chatgpt", "exporting-webpage", "new folder", "new tab_files", "a_data"]
global scannedFiles := []
global encodedCount := 0
global mainGui      := ""
global lvFiles      := ""
global editKeyGui   := ""

BuildGui()

; ============================================================================
; GUI
; ============================================================================
BuildGui() {
    global mainGui, lvFiles

    mainGui := Gui("+Resize", "CCP Image Batch Converter v3.1")
    mainGui.SetFont("s9", "Segoe UI")
    mainGui.OnEvent("Close", (*) => ExitApp())
    mainGui.OnEvent("Size",  OnGuiSize)

    ; Row 1: image folder
    mainGui.Add("Text",   "x10 y12 w80", "Image Folder:")
    global ctlFolder := mainGui.Add("Edit", "x95 y10 w480 vFolderPath",
        "E:\crisisoftruth\images")
    mainGui.Add("Button", "x580 y8 w80", "Browse...").OnEvent("Click", BrowseFolder)

    ; Row 2: database
    mainGui.Add("Text",   "x10 y42 w80", "Database:")
    global ctlDb := mainGui.Add("Edit", "x95 y40 w480 vDbPath",
        A_ScriptDir "\images.db")
    mainGui.Add("Button", "x580 y38 w80", "Browse...").OnEvent("Click", BrowseDb)

    ; Row 3: resize / quality
    global ctlResize   := mainGui.Add("Checkbox", "x10 y72 vDoResize Checked",
        "Resize source over")
    global ctlMaxPx    := mainGui.Add("Edit", "x175 y70 w50 vMaxPixels", "800")
    mainGui.Add("Text",  "x230 y72", "px   Quality:")
    global ctlQuality  := mainGui.Add("Edit", "x310 y70 w40 vJpegQuality", "75")
    mainGui.Add("Text",  "x355 y72", "%")
    global ctlConvJpeg := mainGui.Add("Checkbox", "x385 y72 vConvertToJpeg Checked",
        "Convert large PNGs to JPEG")

    ; Row 4: skip / recurse
    global ctlSkipExist := mainGui.Add("Checkbox", "x10 y98 vSkipExisting Checked",
        "Skip keys already in database")
    global ctlRecurse   := mainGui.Add("Checkbox", "x230 y98 vDoRecurse Checked",
        "Include subfolders")

    ; Row 5: Platform variants
    mainGui.Add("GroupBox", "x10 y118 w650 h84",
        "Platform Variants  (canvas-fitted per platform - no letterboxing)")
    mainGui.Add("Text", "x20 y137 w110", "Platforms to create:")
    global ctlPin  := mainGui.Add("Checkbox", "x138 y136 vDoPinterest",
        "Pinterest  1000x1500 (2:3 tall)")
    global ctlBsky := mainGui.Add("Checkbox", "x320 y136 vDoBluesky",
        "Bluesky  1200x675 (16:9)")
    global ctlLi   := mainGui.Add("Checkbox", "x490 y136 vDoLinkedIn",
        "LinkedIn  1200x628 (1.91:1)")
    mainGui.Add("Text", "x20 y163 w110", "Pad/fill color:")
    global ctlPadColor := mainGui.Add("DropDownList",
        "x138 y160 w120 vPadColor Choose1",
        ["White", "Black", "Light Gray", "Dark Gray"])
    global ctlStoreOrig := mainGui.Add("Checkbox",
        "x280 y163 vStoreOriginal Checked",
        "Also store original (no canvas fit)")
    mainGui.Add("Text", "x490 y163 w170 cGray",
        "Keys: key_pin  key_bsky  key_li")

    ; Row 6: action buttons
    mainGui.Add("Button", "x10  y212 w100", "Scan Folder").OnEvent("Click",     ScanFolder)
    mainGui.Add("Button", "x120 y212 w120", "Encode Selected").OnEvent("Click", EncodeSelected)
    mainGui.Add("Button", "x250 y212 w100", "Select All").OnEvent("Click",      SelectAll)
    mainGui.Add("Button", "x360 y212 w100", "Select None").OnEvent("Click",     SelectNone)
    mainGui.Add("Button", "x470 y212 w110", "Remove Selected").OnEvent("Click", RemoveSelected)

    ; Status bar
    global ctlStatus := mainGui.Add("Text", "x10 y242 w650",
        "Ready.  Check platforms above then click Scan Folder.")

    ; File list
    lvFiles := mainGui.Add("ListView",
        "x10 y260 w650 h360 vFileList Checked -LV0x10 Grid",
        ["Key", "Original File", "Folder", "Orig KB", "Est. KB", "Status"])
    lvFiles.ModifyCol(1, 130)
    lvFiles.ModifyCol(2, 155)
    lvFiles.ModifyCol(3, 100)
    lvFiles.ModifyCol(4, 60)
    lvFiles.ModifyCol(5, 55)
    lvFiles.ModifyCol(6, 120)
    lvFiles.OnEvent("DoubleClick", EditKey)

    ; Log
    mainGui.Add("Text", "x10 y628", "Log:")
    global ctlLog := mainGui.Add("Edit",
        "x10 y644 w650 h80 ReadOnly -Wrap HScroll VScroll", "")

    mainGui.Show("w670 h740")
}

OnGuiSize(g, mm, w, h) {
    global lvFiles, ctlLog, ctlStatus
    if mm = 1
        return
    lvFiles.Move(,, w-20, Max(200, h-390))
    ctlLog.Move(, h-90, w-20, 80)
    ctlStatus.Move(,, w-20,)
}

BrowseFolder(*) {
    global ctlFolder
    c := DirSelect("*" ctlFolder.Value, 3, "Select Image Folder")
    if c
        ctlFolder.Value := c
}

BrowseDb(*) {
    global ctlDb
    c := FileSelect("S", ctlDb.Value, "Select or Create Database",
        "SQLite Database (*.db)")
    if c
        ctlDb.Value := c
}

LogMsg(msg) {
    global ctlLog
    cur := ctlLog.Value
    ctlLog.Value := cur . (cur ? "`n" : "") . msg
    SendMessage(0x115, 7, 0, ctlLog.Hwnd)
}

; ============================================================================
; SCAN
; ============================================================================
ScanFolder(*) {
    global scannedFiles, lvFiles, ctlFolder, ctlDb, ctlSkipExist, ctlRecurse, ctlStatus

    folder    := ctlFolder.Value
    dbPath    := ctlDb.Value
    doRecurse := ctlRecurse.Value

    if !DirExist(folder) {
        MsgBox("Folder not found:`n" folder, "Error", "Icon!")
        return
    }

    existingKeys := Map()
    if FileExist(dbPath) && ctlSkipExist.Value {
        try {
            db := CCP_DB_Open(dbPath)
            CCP_DB_InitImages(db)
            for row in CCP_DB_Query(db, "SELECT key FROM images")
                existingKeys[StrLower(row["key"])] := 1
            CCP_DB_Close(db)
        } catch as e {
            LogMsg("Warning reading DB: " e.Message)
        }
    }

    scannedFiles := []
    lvFiles.Delete()
    usedKeys := Map()
    imgExts  := Map("png",1,"jpg",1,"jpeg",1,"gif",1,"bmp",1,"ico",1,"webp",1)
    loopFlag := doRecurse ? "FR" : "F"
    rootLen  := StrLen(folder)

    Loop Files, folder "\*.*", loopFlag {
        ext := StrLower(A_LoopFileExt)
        if !imgExts.Has(ext)
            continue
        relPath := SubStr(A_LoopFileDir, rootLen + 2)
        if ShouldSkipFolder(relPath)
            continue

        key := BuildKey(A_LoopFileName, relPath)
        baseKey := key
        n := 2
        while usedKeys.Has(key) {
            key := baseKey "_" n
            n++
        }
        usedKeys[key] := 1

        origKB   := Round(A_LoopFileSize / 1024, 1)
        estAfter := EstimateAfterSize(origKB, ext)
        status   := existingKeys.Has(StrLower(key)) ? "Exists - skip" : "Ready"

        fi := {path: A_LoopFilePath, key: key, file: A_LoopFileName,
               folder: relPath ? relPath : "(root)", origKB: origKB,
               estAfter: estAfter, ext: ext, status: status}
        scannedFiles.Push(fi)

        row := lvFiles.Add("Check", key, A_LoopFileName, fi.folder,
            origKB, estAfter, status)
        if status = "Exists - skip"
            lvFiles.Modify(row, "-Check")
    }

    total   := scannedFiles.Length
    skipped := 0
    for fi in scannedFiles
        if fi.status = "Exists - skip"
            skipped++

    ctlStatus.Value := "Scanned: " total " images  |  "
        . skipped " already in DB  |  " (total - skipped) " ready to encode"
    LogMsg("Scan complete: " total " files found")
}

ShouldSkipFolder(relPath) {
    global skipFolders
    if relPath = ""
        return false
    lp := StrLower(relPath)
    for s in skipFolders
        if InStr(lp, s)
            return true
    return false
}

BuildKey(filename, relPath) {
    global folderAbbrev
    SplitPath(filename, , , , &nameNoExt)
    key := StrLower(nameNoExt)
    key := RegExReplace(key, "[^a-z0-9_\-]", "")
    key := RegExReplace(key, "(img|jpg|jpeg|png|gif|bmp|webp)$", "")
    key := RegExReplace(key, "[\-_]+$", "")
    if key = ""
        key := "img_" SubStr(nameNoExt, 1, 8)
    if relPath != "" {
        parts     := StrSplit(relPath, "\")
        topFolder := StrLower(parts[1])
        if folderAbbrev.Has(topFolder) {
            abbrev := folderAbbrev[topFolder]
            if abbrev = "skip"
                return "SKIP_" key
            key := abbrev "_" key
        } else {
            key := SubStr(RegExReplace(topFolder, "[^a-z0-9]", ""), 1, 6) "_" key
        }
    }
    return key
}

EstimateAfterSize(origKB, ext) {
    global ctlConvJpeg, ctlResize, ctlQuality
    doResize  := IsSet(ctlResize)   ? ctlResize.Value   : 1
    doConvert := IsSet(ctlConvJpeg) ? ctlConvJpeg.Value : 1
    quality   := IsSet(ctlQuality)  ? (ctlQuality.Value + 0) : 75
    if origKB < 50
        return Round(origKB * 1.34, 1)
    if (ext = "png" || ext = "bmp") && doConvert && doResize
        return Round(origKB * 0.08 * (quality / 75) * 1.34, 1)
    if (ext = "jpg" || ext = "jpeg") && doResize {
        if origKB > 500
            return Round(origKB * 0.15 * 1.34, 1)
        if origKB > 200
            return Round(origKB * 0.30 * 1.34, 1)
    }
    return Round(origKB * 1.34, 1)
}

; ============================================================================
; KEY EDITING
; ============================================================================
EditKey(lvCtl, rowNum) {
    global scannedFiles, editKeyGui
    if rowNum = 0
        return
    fi  := scannedFiles[rowNum]
    cur := lvFiles.GetText(rowNum, 1)
    editKeyGui := Gui("+Owner" mainGui.Hwnd " +AlwaysOnTop", "Edit Key")
    editKeyGui.SetFont("s9", "Segoe UI")
    editKeyGui.Add("Text",, "File: " fi.file)
    editKeyGui.Add("Text",, "Base hotstring: " Chr(59) Chr(59) cur "img")
    editKeyGui.Add("Text",, "Variants: " cur "_pin  " cur "_bsky  " cur "_li")
    global ctlNewKey := editKeyGui.Add("Edit", "w300 vNewKey", cur)
    editKeyGui.Add("Button", "Default w80", "OK").OnEvent("Click",
        SaveEditedKey.Bind(rowNum))
    editKeyGui.Add("Button", "w80", "Cancel").OnEvent("Click",
        (*) => editKeyGui.Destroy())
    editKeyGui.Show()
}

SaveEditedKey(rowNum, *) {
    global scannedFiles, editKeyGui
    s      := editKeyGui.Submit()
    newKey := RegExReplace(StrLower(Trim(s.NewKey)), "[^a-z0-9_\-]", "")
    if newKey = "" {
        MsgBox("Key contains no valid characters.", "Error", "Icon!")
        return
    }
    scannedFiles[rowNum].key := newKey
    lvFiles.Modify(rowNum,, newKey)
    editKeyGui.Destroy()
    LogMsg("Key set to: " newKey)
}

SelectAll(*) {
    global scannedFiles
    Loop scannedFiles.Length
        lvFiles.Modify(A_Index, "Check")
}

SelectNone(*) {
    global scannedFiles
    Loop scannedFiles.Length
        lvFiles.Modify(A_Index, "-Check")
}

RemoveSelected(*) {
    global scannedFiles
    toDelete := []
    row := 0
    Loop {
        row := lvFiles.GetNext(row, "Checked")
        if !row
            break
        toDelete.Push(row)
    }
    if toDelete.Length = 0 {
        MsgBox("No items selected.", "Remove", "Icon!")
        return
    }
    newFiles := []
    for i, fi in scannedFiles {
        skip := false
        for r in toDelete
            if r = i {
                skip := true
                break
            }
        if !skip
            newFiles.Push(fi)
    }
    scannedFiles := newFiles
    lvFiles.Delete()
    for fi in scannedFiles {
        row := lvFiles.Add("Check", fi.key, fi.file, fi.folder,
            fi.origKB, fi.estAfter, fi.status)
        if fi.status = "Exists - skip"
            lvFiles.Modify(row, "-Check")
    }
    LogMsg("Removed " toDelete.Length " item(s).")
}

; ============================================================================
; ENCODE
; ============================================================================
EncodeSelected(*) {
    global scannedFiles, encodedCount
    global ctlDb, ctlStatus, ctlResize, ctlMaxPx, ctlConvJpeg, ctlQuality
    global ctlPin, ctlBsky, ctlLi, ctlPadColor, ctlStoreOrig, padColors

    dbPath      := ctlDb.Value
    doResize    := ctlResize.Value
    maxPx       := ctlMaxPx.Value + 0
    doConvert   := ctlConvJpeg.Value
    quality     := ctlQuality.Value + 0
    storeOrig   := ctlStoreOrig.Value
    doPinterest := ctlPin.Value
    doBluesky   := ctlBsky.Value
    doLinkedIn  := ctlLi.Value
    padColorName := ctlPadColor.Text
    padARGB      := padColors.Has(padColorName) ? padColors[padColorName] : 0xFFFFFFFF

    if quality < 1 || quality > 100
        quality := 75
    if maxPx < 100
        maxPx := 800

    if !storeOrig && !doPinterest && !doBluesky && !doLinkedIn {
        MsgBox("Nothing to encode - check at least one option (original or a platform).",
            "Nothing Selected", "Icon!")
        return
    }

    toEncode := []
    row := 0
    Loop {
        row := lvFiles.GetNext(row, "Checked")
        if !row
            break
        toEncode.Push(row)
    }
    if toEncode.Length = 0 {
        MsgBox("No images checked.", "Nothing to do", "Icon!")
        return
    }

    ; Build list of variants to produce
    variants := []
    if storeOrig
        variants.Push({suffix: "", label: "Original", canvas: false})
    if doPinterest
        variants.Push({suffix: "_pin",  label: "Pinterest 1000x1500",
            canvas: true, w: 1000, h: 1500, padARGB: padARGB})
    if doBluesky
        variants.Push({suffix: "_bsky", label: "Bluesky 1200x675",
            canvas: true, w: 1200, h: 675, padARGB: padARGB})
    if doLinkedIn
        variants.Push({suffix: "_li",   label: "LinkedIn 1200x628",
            canvas: true, w: 1200, h: 628, padARGB: padARGB})

    totalOps := toEncode.Length * variants.Length
    resp := MsgBox(toEncode.Length " image(s) x " variants.Length " variant(s) = "
        . totalOps " encode operation(s)`n`nDatabase: " dbPath
        . "`n`nPad color: " padColorName "`n`nContinue?",
        "Confirm Encode", "YesNo Icon?")
    if resp != "Yes"
        return

    db := ""
    try {
        db := CCP_DB_Open(dbPath)
        CCP_DB_InitImages(db)
    } catch as e {
        MsgBox("Cannot open database:`n" e.Message, "Error", "Icon!")
        return
    }

    pToken := Gdip_Startup()
    if !pToken {
        CCP_DB_Close(db)
        MsgBox("GDI+ failed to start.", "Error", "Icon!")
        return
    }

    encodedCount := 0
    failCount    := 0
    opNum        := 0
    CCP_DB_Begin(db)

    for row in toEncode {
        fi      := scannedFiles[row]
        anyFail := false

        for vr in variants {
            opNum++
            key      := fi.key . vr.suffix
            varLabel := "[" fi.file " -> " vr.label "]"
            ctlStatus.Value := "Encoding " opNum "/" totalOps ": " fi.file " (" vr.label ")"
            lvFiles.Modify(row, "", fi.key . vr.suffix, , , , "Encoding...")

            result := EncodeOneVariant(fi, vr, db, pToken, doResize, maxPx, doConvert, quality)

            if result = "OK" {
                encodedCount++
                LogMsg("OK  " varLabel "  ->  key: " key)
            } else {
                failCount++
                anyFail := true
                LogMsg("FAIL  " varLabel "  " result)
            }
        }

        scannedFiles[row].status := anyFail ? "PARTIAL FAIL" : "Encoded OK"
        lvFiles.Modify(row, "-Check", fi.key, , , ,
            anyFail ? "PARTIAL FAIL" : "Encoded OK (" variants.Length " variants)")
    }

    CCP_DB_Commit(db)
    Gdip_Shutdown(pToken)
    CCP_DB_Close(db)

    ctlStatus.Value := "Done.  Encoded: " encodedCount "  |  Failed: " failCount

    doneMsg := encodedCount " encode(s) complete - saved to:`n" dbPath "`n`n"
    if storeOrig
        doneMsg .= "Original:  " Chr(59) Chr(59) "(key)img`n"
    if doPinterest
        doneMsg .= "Pinterest: " Chr(59) Chr(59) "(key)_pinimg`n"
    if doBluesky
        doneMsg .= "Bluesky:   " Chr(59) Chr(59) "(key)_bskyimg`n"
    if doLinkedIn
        doneMsg .= "LinkedIn:  " Chr(59) Chr(59) "(key)_liimg`n"
    if failCount > 0
        doneMsg .= "`nFailed: " failCount " (see log)"
    MsgBox(doneMsg, "Converter Complete", "Iconi")
    LogMsg("Complete: " encodedCount " OK  |  " failCount " failed.")
}

; ============================================================================
; ENCODE ONE VARIANT
; ============================================================================
EncodeOneVariant(fi, vr, db, pToken, doResize, maxPx, doConvert, quality) {
    key      := fi.key . vr.suffix
    workPath := fi.path
    ext      := fi.ext

    if vr.canvas {
        ; Canvas-fit path: scale image to fit inside canvas, pad remainder
        tmp := A_Temp "\_ccpcanv_" A_TickCount ".jpg"
        res := FitToCanvas(pToken, fi.path, tmp, vr.w, vr.h, vr.padARGB, quality)
        if res != "OK"
            return "Canvas fit failed: " res
        workPath := tmp
    } else {
        ; Original path: optional resize/convert
        needsResize  := doResize  && fi.origKB > 200 && ext != "gif"
        needsConvert := doConvert && (ext = "png" || ext = "bmp") && fi.origKB > 100
        if needsResize || needsConvert {
            tmp := A_Temp "\_ccpconv_" A_TickCount "." (needsConvert ? "jpg" : ext)
            res := ResizeImage(pToken, fi.path, tmp, maxPx, needsConvert, quality)
            if res = "OK"
                workPath := tmp
            else
                LogMsg("Resize skipped (" fi.file "): " res)
        }
    }

    b64 := FileToBase64(workPath)
    if workPath != fi.path && FileExist(workPath)
        FileDelete(workPath)
    if !b64
        return "Base64 encode failed"

    try {
        CCP_DB_Execute(db,
            "INSERT OR REPLACE INTO images"
            . "(key,b64,source_file,folder,orig_kb,b64_kb,encoded_date) VALUES("
            . "'" CCP_DB_Escape(key)       "',"
            . "'" CCP_DB_Escape(b64)       "',"
            . "'" CCP_DB_Escape(fi.file)   "',"
            . "'" CCP_DB_Escape(fi.folder) "',"
            . fi.origKB                     ","
            . Round(StrLen(b64)/1024, 1)    ","
            . "'" FormatTime(, "yyyy-MM-dd HH:mm:ss") "')")
    } catch as e {
        return "DB write error: " e.Message
    }
    return "OK"
}

; ============================================================================
; FIT TO CANVAS
; Scales source image to fit entirely inside the target canvas,
; centers it, and fills the remainder with a solid pad color.
; No cropping. No stretching. No letterbox bars from the platform.
; ============================================================================
FitToCanvas(pToken, src, dst, canvasW, canvasH, padARGB, quality) {
    pb := Gdip_CreateBitmapFromFile(src)
    if !pb
        return "Load failed"

    sw := Gdip_GetImageWidth(pb)
    sh := Gdip_GetImageHeight(pb)
    if sw = 0 || sh = 0 {
        Gdip_DisposeImage(pb)
        return "Invalid source dimensions"
    }

    ; Scale to fit inside canvas preserving aspect ratio
    scaleW := canvasW / sw
    scaleH := canvasH / sh
    scale  := Min(scaleW, scaleH)
    drawW  := Round(sw * scale)
    drawH  := Round(sh * scale)

    ; Center the image on the canvas
    offX := Round((canvasW - drawW) / 2)
    offY := Round((canvasH - drawH) / 2)

    ; Create canvas bitmap
    pd := Gdip_CreateBitmap(canvasW, canvasH)
    if !pd {
        Gdip_DisposeImage(pb)
        return "Canvas create failed"
    }

    pg := Gdip_GraphicsFromImage(pd)
    if !pg {
        Gdip_DisposeImage(pb)
        Gdip_DisposeImage(pd)
        return "Graphics context failed"
    }

    ; Fill entire canvas with pad color
    brush := 0
    DllCall("gdiplus\GdipCreateSolidFill", "UInt", padARGB, "UPtr*", &brush)
    if brush {
        DllCall("gdiplus\GdipFillRectangleI",
            "UPtr", pg, "UPtr", brush,
            "Int", 0, "Int", 0, "Int", canvasW, "Int", canvasH)
        DllCall("gdiplus\GdipDeleteBrush", "UPtr", brush)
    }

    ; Draw scaled source image centered
    Gdip_SetInterpolationMode(pg, 7)
    Gdip_SetSmoothingMode(pg, 4)
    DllCall("gdiplus\GdipDrawImageRectI",
        "UPtr", pg, "UPtr", pb,
        "Int", offX, "Int", offY, "Int", drawW, "Int", drawH)

    Gdip_DeleteGraphics(pg)
    Gdip_DisposeImage(pb)

    r := Gdip_SaveBitmapToJpeg(pd, dst, quality)
    Gdip_DisposeImage(pd)
    return r = 0 ? "OK" : "Save failed (r=" r ")"
}

; ============================================================================
; HELPERS
; ============================================================================
FileToBase64(filePath) {
    try {
        f := FileOpen(filePath, "r")
        if !f
            return ""
        sz := f.Length
        if sz = 0 {
            f.Close()
            return ""
        }
        buf := Buffer(sz)
        f.RawRead(buf, sz)
        f.Close()
        outSz := 0
        DllCall("Crypt32.dll\CryptBinaryToStringW",
            "Ptr", buf, "UInt", sz, "UInt", 0x40000001, "Ptr", 0, "UInt*", &outSz)
        if outSz = 0
            return ""
        outBuf := Buffer(outSz * 2)
        DllCall("Crypt32.dll\CryptBinaryToStringW",
            "Ptr", buf, "UInt", sz, "UInt", 0x40000001, "Ptr", outBuf, "UInt*", &outSz)
        return StrGet(outBuf, "UTF-16")
    } catch {
        return ""
    }
}

ResizeImage(pToken, src, dst, maxPx, toJpeg, quality) {
    pb := Gdip_CreateBitmapFromFile(src)
    if !pb
        return "Load failed"
    sw := Gdip_GetImageWidth(pb)
    sh := Gdip_GetImageHeight(pb)
    if sw = 0 || sh = 0 {
        Gdip_DisposeImage(pb)
        return "Invalid dimensions"
    }
    if sw > sh {
        nw := Min(sw, maxPx)
        nh := Round(sh * (nw / sw))
    } else {
        nh := Min(sh, maxPx)
        nw := Round(sw * (nh / sh))
    }
    if nw >= sw && nh >= sh && !toJpeg {
        Gdip_DisposeImage(pb)
        return "OK"
    }
    pd := Gdip_CreateBitmap(nw, nh)
    if !pd {
        Gdip_DisposeImage(pb)
        return "Create dest failed"
    }
    pg := Gdip_GraphicsFromImage(pd)
    if !pg {
        Gdip_DisposeImage(pb)
        Gdip_DisposeImage(pd)
        return "Graphics context failed"
    }
    Gdip_SetInterpolationMode(pg, 7)
    Gdip_SetSmoothingMode(pg, 4)
    Gdip_DrawImage(pg, pb, 0, 0, nw, nh)
    Gdip_DeleteGraphics(pg)
    Gdip_DisposeImage(pb)
    r := toJpeg ? Gdip_SaveBitmapToJpeg(pd, dst, quality)
                : Gdip_SaveBitmapToFile(pd, dst)
    Gdip_DisposeImage(pd)
    return r = 0 ? "OK" : "Save failed (r=" r ")"
}

; ============================================================================
; GDI+ WRAPPERS
; ============================================================================
Gdip_Startup() {
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)
    pt := 0
    DllCall("gdiplus\GdiplusStartup", "UPtr*", &pt, "Ptr", si, "Ptr", 0)
    return pt
}
Gdip_Shutdown(pt)      => DllCall("gdiplus\GdiplusShutdown",    "UPtr", pt)
Gdip_DisposeImage(p)   => DllCall("gdiplus\GdipDisposeImage",   "UPtr", p)
Gdip_DeleteGraphics(p) => DllCall("gdiplus\GdipDeleteGraphics", "UPtr", p)

Gdip_CreateBitmapFromFile(path) {
    pb := 0
    w  := Buffer((StrLen(path)+1)*2)
    StrPut(path, w, "UTF-16")
    DllCall("gdiplus\GdipCreateBitmapFromFile", "Ptr", w, "UPtr*", &pb)
    return pb
}
Gdip_GetImageWidth(pb) {
    w := 0
    DllCall("gdiplus\GdipGetImageWidth", "UPtr", pb, "UInt*", &w)
    return w
}
Gdip_GetImageHeight(pb) {
    h := 0
    DllCall("gdiplus\GdipGetImageHeight", "UPtr", pb, "UInt*", &h)
    return h
}
Gdip_CreateBitmap(w, h) {
    pb := 0
    DllCall("gdiplus\GdipCreateBitmapFromScan0",
        "Int", w, "Int", h, "Int", 0, "Int", 0x0026200A, "Ptr", 0, "UPtr*", &pb)
    return pb
}
Gdip_GraphicsFromImage(pb) {
    pg := 0
    DllCall("gdiplus\GdipGetImageGraphicsContext", "UPtr", pb, "UPtr*", &pg)
    return pg
}
Gdip_SetInterpolationMode(pg, m) =>
    DllCall("gdiplus\GdipSetInterpolationMode", "UPtr", pg, "Int", m)
Gdip_SetSmoothingMode(pg, m) =>
    DllCall("gdiplus\GdipSetSmoothingMode", "UPtr", pg, "Int", m)
Gdip_DrawImage(pg, pb, x, y, w, h) =>
    DllCall("gdiplus\GdipDrawImageRectI",
        "UPtr", pg, "UPtr", pb, "Int", x, "Int", y, "Int", w, "Int", h)

Gdip_SaveBitmapToFile(pb, path) {
    clsid := Buffer(16)
    DllCall("ole32\CLSIDFromString",
        "Str", "{557CF406-1A04-11D3-9A73-0000F81EF32E}", "Ptr", clsid)
    w := Buffer((StrLen(path)+1)*2)
    StrPut(path, w, "UTF-16")
    return DllCall("gdiplus\GdipSaveImageToFile",
        "UPtr", pb, "Ptr", w, "Ptr", clsid, "Ptr", 0)
}

Gdip_SaveBitmapToJpeg(pb, path, quality := 75) {
    clsid := Buffer(16)
    DllCall("ole32\CLSIDFromString",
        "Str", "{557CF401-1A04-11D3-9A73-0000F81EF32E}", "Ptr", clsid)
    ep := Buffer(40, 0)
    NumPut("UInt",   1,          ep,  0)
    NumPut("UInt",   0xB5E45B1D, ep,  8)
    NumPut("UShort", 0x4AFA,     ep, 12)
    NumPut("UShort", 0x2D45,     ep, 14)
    NumPut("UChar",  0x9C, ep, 16)
    NumPut("UChar",  0xDD, ep, 17)
    NumPut("UChar",  0x5D, ep, 18)
    NumPut("UChar",  0xB3, ep, 19)
    NumPut("UChar",  0x51, ep, 20)
    NumPut("UChar",  0x05, ep, 21)
    NumPut("UChar",  0xE7, ep, 22)
    NumPut("UChar",  0xEB, ep, 23)
    NumPut("UInt",   1, ep, 24)
    NumPut("UInt",   4, ep, 28)
    qb := Buffer(4)
    NumPut("UInt", quality, qb, 0)
    NumPut("UPtr", qb.Ptr, ep, 32)
    w := Buffer((StrLen(path)+1)*2)
    StrPut(path, w, "UTF-16")
    return DllCall("gdiplus\GdipSaveImageToFile",
        "UPtr", pb, "Ptr", w, "Ptr", clsid, "Ptr", ep)
}
