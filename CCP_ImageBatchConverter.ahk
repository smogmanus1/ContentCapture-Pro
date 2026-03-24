; CCP_ImageBatchConverter.ahk
; ContentCapture Pro - Batch Image to Base64 Converter
; Stores images in SQLite database (images.db) - no size limits
; SQLite wrapper embedded - no external CCP_SQLite.ahk needed
; AHK v2 - UTF-8 with BOM

#Requires AutoHotkey v2.0
#SingleInstance Force

; =============================================================================
; EMBEDDED SQLite WRAPPER
; Checks script dir first for winsqlite3.dll, then Windows System32
; =============================================================================

CCP_SQLite_DLL() {
    scriptDll := A_ScriptDir "\winsqlite3.dll"
    sysDll    := A_WinDir   "\System32\winsqlite3.dll"
    if FileExist(scriptDll)
        return scriptDll
    if FileExist(sysDll)
        return sysDll
    throw Error("winsqlite3.dll not found.`n`nChecked:`n  " scriptDll "`n  " sysDll
        . "`n`nThe DLL is included in the CCP folder - check it was not accidentally deleted.")
}

CCP_DB_Open(dbPath) {
    dll := CCP_SQLite_DLL()
    ; Delete zero-byte DB left by a failed previous open attempt
    if FileExist(dbPath) && (FileGetSize(dbPath) = 0)
        FileDelete(dbPath)
    pathBuf := Buffer(StrPut(dbPath, "UTF-8"))
    StrPut(dbPath, pathBuf, "UTF-8")
    db := 0
    try {
        rc := DllCall(dll "\sqlite3_open_v2",
            "Ptr",   pathBuf,
            "UPtr*", &db,
            "Int",   6,
            "Ptr",   0,
            "Int")
    } catch as e {
        throw Error("sqlite3_open_v2 failed.`nDLL: " dll "`nError: " e.Message)
    }
    if rc != 0 || !db
        throw Error("sqlite3_open_v2 rc=" rc " db=" db "`nPath: " dbPath "`nDLL: " dll)
    return db
}

CCP_DB_Close(db) {
    if db
        DllCall(CCP_SQLite_DLL() "\sqlite3_close", "UPtr", db)
}

CCP_DB_Execute(db, sql) {
    dll    := CCP_SQLite_DLL()
    sqlBuf := Buffer(StrPut(sql, "UTF-8"))
    StrPut(sql, sqlBuf, "UTF-8")
    errPtr := 0
    rc := DllCall(dll "\sqlite3_exec",
        "UPtr", db, "Ptr", sqlBuf, "Ptr", 0, "Ptr", 0, "UPtr*", &errPtr, "Int")
    if rc != 0 {
        msg := errPtr ? StrGet(errPtr, "UTF-8") : "unknown error"
        if errPtr
            DllCall(dll "\sqlite3_free", "Ptr", errPtr)
        throw Error("SQL error [rc=" rc "]: " msg)
    }
}

CCP_DB_Query(db, sql) {
    dll    := CCP_SQLite_DLL()
    sqlBuf := Buffer(StrPut(sql, "UTF-8"))
    StrPut(sql, sqlBuf, "UTF-8")
    stmt := 0
    rc := DllCall(dll "\sqlite3_prepare_v2",
        "UPtr", db, "Ptr", sqlBuf, "Int", -1, "UPtr*", &stmt, "Ptr", 0, "Int")
    if rc != 0 || !stmt
        throw Error("sqlite3_prepare_v2 failed (rc=" rc ")")
    colCount := DllCall(dll "\sqlite3_column_count", "UPtr", stmt, "Int")
    colNames := []
    Loop colCount {
        p := DllCall(dll "\sqlite3_column_name",
            "UPtr", stmt, "Int", A_Index - 1, "UPtr")
        colNames.Push(p ? StrGet(p, "UTF-8") : "col" A_Index)
    }
    rows := []
    Loop {
        rc := DllCall(dll "\sqlite3_step", "UPtr", stmt, "Int")
        if rc = 101
            break
        if rc != 100
            break
        row := Map()
        Loop colCount {
            ci  := A_Index - 1
            typ := DllCall(dll "\sqlite3_column_type", "UPtr", stmt, "Int", ci, "Int")
            if typ = 1
                row[colNames[A_Index]] := DllCall(dll "\sqlite3_column_int64",
                    "UPtr", stmt, "Int", ci, "Int64")
            else if typ = 2
                row[colNames[A_Index]] := DllCall(dll "\sqlite3_column_double",
                    "UPtr", stmt, "Int", ci, "Double")
            else if typ = 5
                row[colNames[A_Index]] := ""
            else {
                p := DllCall(dll "\sqlite3_column_text", "UPtr", stmt, "Int", ci, "UPtr")
                row[colNames[A_Index]] := p ? StrGet(p, "UTF-8") : ""
            }
        }
        rows.Push(row)
    }
    DllCall(dll "\sqlite3_finalize", "UPtr", stmt)
    return rows
}

CCP_DB_QueryOne(db, sql, default := "") {
    rows := CCP_DB_Query(db, sql)
    if rows.Length = 0
        return default
    for k, v in rows[1]
        return v
    return default
}

CCP_DB_Escape(str) {
    return StrReplace(String(str), "'", "''")
}

CCP_DB_Begin(db) {
    CCP_DB_Execute(db, "BEGIN TRANSACTION")
}
CCP_DB_Commit(db) {
    CCP_DB_Execute(db, "COMMIT")
}
CCP_DB_Rollback(db) {
    CCP_DB_Execute(db, "ROLLBACK")
}

CCP_DB_InitImages(db) {
    CCP_DB_Execute(db,
        "CREATE TABLE IF NOT EXISTS images ("
        . "key TEXT PRIMARY KEY COLLATE NOCASE,"
        . "b64 TEXT NOT NULL,"
        . "source_file TEXT DEFAULT '',"
        . "folder TEXT DEFAULT '',"
        . "orig_kb REAL DEFAULT 0,"
        . "b64_kb REAL DEFAULT 0,"
        . "encoded_date TEXT DEFAULT '')")
    CCP_DB_Execute(db,
        "CREATE INDEX IF NOT EXISTS idx_folder ON images (folder)")
}

CCP_DB_UpsertImage(db, key, b64, srcFile, folder, origKB, b64KB, encDate) {
    CCP_DB_Execute(db,
        "INSERT OR REPLACE INTO images"
        . "(key,b64,source_file,folder,orig_kb,b64_kb,encoded_date) VALUES("
        . "'" CCP_DB_Escape(key)     "',"
        . "'" CCP_DB_Escape(b64)     "',"
        . "'" CCP_DB_Escape(srcFile) "',"
        . "'" CCP_DB_Escape(folder)  "',"
        . CCP_DB_Escape(origKB)      ","
        . CCP_DB_Escape(b64KB)       ","
        . "'" CCP_DB_Escape(encDate) "')")
}

CCP_DB_GetImage(db, key) {
    return CCP_DB_QueryOne(db,
        "SELECT b64 FROM images WHERE key='" CCP_DB_Escape(key) "' LIMIT 1", "")
}

CCP_DB_KeyExists(db, key) {
    return CCP_DB_QueryOne(db,
        "SELECT COUNT(*) FROM images WHERE key='" CCP_DB_Escape(key) "'", 0) > 0
}

CCP_DB_DeleteImage(db, key) {
    CCP_DB_Execute(db,
        "DELETE FROM images WHERE key='" CCP_DB_Escape(key) "'")
}

CCP_DB_RenameImage(db, oldKey, newKey) {
    CCP_DB_Execute(db,
        "UPDATE images SET key='" CCP_DB_Escape(newKey)
        . "' WHERE key='" CCP_DB_Escape(oldKey) "'")
}

CCP_DB_GetAllImages(db) {
    return CCP_DB_Query(db,
        "SELECT key,source_file,folder,orig_kb,b64_kb,encoded_date"
        . " FROM images ORDER BY folder,key")
}

CCP_DB_SearchImages(db, srch) {
    s := CCP_DB_Escape(srch)
    return CCP_DB_Query(db,
        "SELECT key,source_file,folder,orig_kb,b64_kb,encoded_date"
        . " FROM images WHERE key LIKE '%" s "%'"
        . " OR source_file LIKE '%" s "%'"
        . " OR folder LIKE '%" s "%'"
        . " ORDER BY folder,key")
}

CCP_DB_ImageCount(db) {
    return CCP_DB_QueryOne(db, "SELECT COUNT(*) FROM images", 0)
}

; =============================================================================
; MAIN APPLICATION
; =============================================================================

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

BuildGui() {
    global mainGui, lvFiles
    mainGui := Gui("+Resize", "CCP Image Batch Converter v3.0")
    mainGui.SetFont("s9", "Segoe UI")
    mainGui.OnEvent("Close", (*) => ExitApp())
    mainGui.OnEvent("Size", OnGuiSize)

    mainGui.Add("Text", "x10 y12 w80", "Image Folder:")
    global ctlFolder := mainGui.Add("Edit", "x95 y10 w480 vFolderPath",
        "E:\crisisoftruth\images")
    mainGui.Add("Button", "x580 y8 w80", "Browse...").OnEvent("Click", BrowseFolder)

    mainGui.Add("Text", "x10 y42 w80", "Database:")
    global ctlDb := mainGui.Add("Edit", "x95 y40 w480 vDbPath",
        A_ScriptDir "\images.db")
    mainGui.Add("Button", "x580 y38 w80", "Browse...").OnEvent("Click", BrowseDb)

    global ctlResize   := mainGui.Add("Checkbox", "x10 y72 vDoResize Checked",
        "Resize images over")
    global ctlMaxPx    := mainGui.Add("Edit", "x170 y70 w50 vMaxPixels", "800")
    mainGui.Add("Text", "x225 y72", "px  Quality:")
    global ctlQuality  := mainGui.Add("Edit", "x305 y70 w40 vJpegQuality", "75")
    mainGui.Add("Text", "x350 y72", "%")
    global ctlConvJpeg := mainGui.Add("Checkbox", "x390 y72 vConvertToJpeg Checked",
        "Convert large PNGs to JPEG")
    global ctlSkipExist := mainGui.Add("Checkbox", "x10 y96 vSkipExisting Checked",
        "Skip keys already in database")
    global ctlRecurse   := mainGui.Add("Checkbox", "x220 y96 vDoRecurse Checked",
        "Include subfolders")

    mainGui.Add("Button", "x10  y122 w100", "Scan Folder").OnEvent("Click", ScanFolder)
    mainGui.Add("Button", "x120 y122 w120", "Encode Selected").OnEvent("Click", EncodeSelected)
    mainGui.Add("Button", "x250 y122 w100", "Select All").OnEvent("Click", SelectAll)
    mainGui.Add("Button", "x360 y122 w100", "Select None").OnEvent("Click", SelectNone)
    mainGui.Add("Button", "x470 y122 w110", "Remove Selected").OnEvent("Click", RemoveSelected)

    global ctlStatus := mainGui.Add("Text", "x10 y152 w650",
        "Ready. Click Scan Folder to begin.")

    lvFiles := mainGui.Add("ListView",
        "x10 y170 w650 h380 vFileList Checked -LV0x10 Grid",
        ["Key", "Original File", "Folder", "Orig KB", "Est. After KB", "Status"])
    lvFiles.ModifyCol(1, 130)
    lvFiles.ModifyCol(2, 155)
    lvFiles.ModifyCol(3, 100)
    lvFiles.ModifyCol(4, 60)
    lvFiles.ModifyCol(5, 75)
    lvFiles.ModifyCol(6, 100)
    lvFiles.OnEvent("DoubleClick", EditKey)

    mainGui.Add("Text", "x10 y558", "Log:")
    global ctlLog := mainGui.Add("Edit",
        "x10 y574 w650 h80 ReadOnly -Wrap HScroll VScroll", "")

    mainGui.Show("w670 h670")
}

OnGuiSize(g, mm, w, h) {
    global lvFiles, ctlLog, ctlStatus
    if mm = 1
        return
    lvFiles.Move(,, w-20, Max(200, h-300))
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
    usedKeys  := Map()
    imgExts   := Map("png",1,"jpg",1,"jpeg",1,"gif",1,"bmp",1,"ico",1,"webp",1)
    loopFlag  := doRecurse ? "FR" : "F"
    rootLen   := StrLen(folder)

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

EditKey(lvCtl, rowNum) {
    global scannedFiles, editKeyGui
    if rowNum = 0
        return
    fi  := scannedFiles[rowNum]
    cur := lvFiles.GetText(rowNum, 1)
    editKeyGui := Gui("+Owner" mainGui.Hwnd " +AlwaysOnTop", "Edit Key")
    editKeyGui.SetFont("s9", "Segoe UI")
    editKeyGui.Add("Text",, "File: " fi.file)
    editKeyGui.Add("Text",, "Hotstring will be: " Chr(59) Chr(59) cur "img")
    global ctlNewKey := editKeyGui.Add("Edit", "w300 vNewKey", cur)
    editKeyGui.Add("Button", "Default w80", "OK").OnEvent("Click",
        SaveEditedKey.Bind(rowNum))
    editKeyGui.Add("Button", "w80", "Cancel").OnEvent("Click",
        (*) => editKeyGui.Destroy())
    editKeyGui.Show()
}

SaveEditedKey(rowNum, *) {
    global scannedFiles, editKeyGui, ctlNewKey
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
        for r in toDelete {
            if r = i {
                skip := true
                break
            }
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

EncodeSelected(*) {
    global scannedFiles, encodedCount, ctlDb, ctlStatus
    global ctlResize, ctlMaxPx, ctlConvJpeg, ctlQuality

    dbPath    := ctlDb.Value
    doResize  := ctlResize.Value
    maxPx     := ctlMaxPx.Value + 0
    doConvert := ctlConvJpeg.Value
    quality   := ctlQuality.Value + 0
    if quality < 1 || quality > 100
        quality := 75
    if maxPx < 100
        maxPx := 800

    toEncode := []
    row := 0
    Loop {
        row := lvFiles.GetNext(row, "Checked")
        if !row
            break
        toEncode.Push(row)
    }
    if toEncode.Length = 0 {
        MsgBox("No items checked.", "Nothing to do", "Icon!")
        return
    }

    resp := MsgBox("Encode " toEncode.Length " image(s) into:`n" dbPath
        . "`n`nContinue?", "Confirm", "YesNo Icon?")
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
    CCP_DB_Begin(db)

    for row in toEncode {
        fi := scannedFiles[row]
        lvFiles.Modify(row, "", "", "", "", "", "Encoding...")
        ctlStatus.Value := "Encoding " A_Index " of " toEncode.Length ": " fi.file

        result := EncodeOneImage(fi, db, pToken, doResize, maxPx, doConvert, quality)

        if result = "OK" {
            encodedCount++
            scannedFiles[row].status := "Encoded OK"
            lvFiles.Modify(row, "-Check", , , , , "Encoded OK")
        } else {
            failCount++
            scannedFiles[row].status := "FAILED"
            lvFiles.Modify(row, "-Check", , , , , "FAILED")
            LogMsg("FAIL [" fi.key "]: " result)
        }
    }

    CCP_DB_Commit(db)
    Gdip_Shutdown(pToken)
    CCP_DB_Close(db)

    ctlStatus.Value := "Done.  Encoded: " encodedCount "  |  Failed: " failCount
    doneMsg := encodedCount " image(s) saved to:`n" dbPath "`n`n"
    doneMsg .= "Use CCP_ImageViewer.ahk to browse your images.`n"
    doneMsg .= "Hotstring example: " Chr(59) Chr(59) "usrightsimg"
    if failCount > 0
        doneMsg .= "`n`nFailed: " failCount " (see log)"
    MsgBox(doneMsg, "Converter Complete", "Iconi")
    LogMsg("Complete: " encodedCount " OK  |  " failCount " failed.")
}

EncodeOneImage(fi, db, pToken, doResize, maxPx, doConvert, quality) {
    ext          := fi.ext
    needsResize  := doResize  && fi.origKB > 200 && ext != "gif"
    needsConvert := doConvert && (ext = "png" || ext = "bmp") && fi.origKB > 100
    workPath     := fi.path

    if needsResize || needsConvert {
        tmp := A_Temp "\_ccpconv_" A_TickCount "." (needsConvert ? "jpg" : ext)
        res := ResizeImage(pToken, fi.path, tmp, maxPx, needsConvert, quality)
        if res = "OK"
            workPath := tmp
        else
            LogMsg("Resize skipped (" fi.file "): " res)
    }

    b64 := FileToBase64(workPath)
    if workPath != fi.path && FileExist(workPath)
        FileDelete(workPath)
    if !b64
        return "Base64 encode failed"

    try {
        CCP_DB_UpsertImage(db, fi.key, b64, fi.file, fi.folder,
            fi.origKB, Round(StrLen(b64)/1024, 1),
            FormatTime(, "yyyy-MM-dd HH:mm:ss"))
    } catch as e {
        return "DB write error: " e.Message
    }

    LogMsg("OK  [" fi.key "]  " fi.file "  ->  " Round(StrLen(b64)/1024,1) " KB b64")
    return "OK"
}

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

; == GDI+ wrappers ============================================================

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
    NumPut("UInt", 1, ep, 0)
    NumPut("UInt",   0xB5E45B1D, ep,  8)
    NumPut("UShort", 0x4AFA,     ep, 12)
    NumPut("UShort", 0x2D45,     ep, 14)
    NumPut("UChar",  0x9C, ep, 16)  NumPut("UChar", 0xDD, ep, 17)
    NumPut("UChar",  0x5D, ep, 18)  NumPut("UChar", 0xB3, ep, 19)
    NumPut("UChar",  0x51, ep, 20)  NumPut("UChar", 0x05, ep, 21)
    NumPut("UChar",  0xE7, ep, 22)  NumPut("UChar", 0xEB, ep, 23)
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
