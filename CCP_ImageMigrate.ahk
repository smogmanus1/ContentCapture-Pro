; CCP_ImageMigrate.ahk
; ContentCapture Pro - One-time migration: images.txt -> images.db
; Run this once to migrate existing encoded images into SQLite.
; Safe to run multiple times (uses INSERT OR REPLACE).
; AHK v2 - UTF-8 with BOM
;
; VERSION HISTORY:
;   v1.1 - 2026-03-23
;     FIXED: No longer #Includes CCP_SQLite.ahk (which could pick up the wrong
;            or broken version). DLL resolution and DB functions are embedded
;            directly in this file so it is fully self-contained.
;     FIXED: Handles both UTF-16 LE with BOM and UTF-8 BOM source files.
;     ADDED: Parses Meta_ sections from images.txt to populate source_file,
;            folder, orig_kb, b64_kb, encoded_date columns in images.db.

#Requires AutoHotkey v2.0
#SingleInstance Force

; ==============================================================================
; EMBEDDED DB HELPERS (self-contained — no #Include needed)
; ==============================================================================

_Mig_DLL() {
    scriptDll := A_ScriptDir "\winsqlite3.dll"
    sysDll    := A_WinDir   "\System32\winsqlite3.dll"
    if FileExist(scriptDll)
        return scriptDll
    if FileExist(sysDll)
        return sysDll
    throw Error("winsqlite3.dll not found.`n`nChecked:`n  " scriptDll "`n  " sysDll)
}

_Mig_Open(dbPath) {
    dll := _Mig_DLL()
    if FileExist(dbPath) && FileGetSize(dbPath) = 0
        FileDelete(dbPath)
    pathBuf := Buffer(StrPut(dbPath, "UTF-8"))
    StrPut(dbPath, pathBuf, "UTF-8")
    db := 0
    rc := DllCall(dll "\sqlite3_open_v2",
        "Ptr",   pathBuf, "UPtr*", &db, "Int", 6, "Ptr", 0, "Int")
    if rc != 0 || !db
        throw Error("sqlite3_open_v2 rc=" rc " path=" dbPath)
    return db
}

_Mig_Close(db) {
    if db
        DllCall(_Mig_DLL() "\sqlite3_close", "UPtr", db)
}

_Mig_Exec(db, sql) {
    dll    := _Mig_DLL()
    sqlBuf := Buffer(StrPut(sql, "UTF-8"))
    StrPut(sql, sqlBuf, "UTF-8")
    errPtr := 0
    rc := DllCall(dll "\sqlite3_exec",
        "UPtr",  db, "Ptr", sqlBuf, "Ptr", 0, "Ptr", 0, "UPtr*", &errPtr, "Int")
    if rc != 0 {
        msg := errPtr ? StrGet(errPtr, "UTF-8") : "rc=" rc
        if errPtr
            DllCall(dll "\sqlite3_free", "Ptr", errPtr)
        throw Error("SQL error: " msg)
    }
}

_Mig_Esc(str) {
    return StrReplace(String(str), "'", "''")
}

; ==============================================================================
; GUI
; ==============================================================================

BuildGui()

BuildGui() {
    g := Gui(, "CCP Image Migration — images.txt → images.db")
    g.SetFont("s9", "Segoe UI")
    g.OnEvent("Close", (*) => ExitApp())

    g.Add("Text",   "x10 y12",         "Source (images.txt):")
    global ctlSrc := g.Add("Edit", "x165 y10 w380", A_ScriptDir "\images.txt")
    g.Add("Button", "x550 y8  w80", "Browse...").OnEvent("Click", BrowseSrc)

    g.Add("Text",   "x10 y42",         "Destination (images.db):")
    global ctlDst := g.Add("Edit", "x165 y40 w380", A_ScriptDir "\images.db")
    g.Add("Button", "x550 y38 w80", "Browse...").OnEvent("Click", BrowseDst)

    g.Add("Button", "x10 y72 w160 h30", "▶  Run Migration").OnEvent("Click", RunMigration)

    global ctlProg := g.Add("Text", "x10 y115 w620", "Ready.")
    global ctlLog  := g.Add("Edit", "x10 y135 w620 h200 ReadOnly -Wrap VScroll", "")

    g.Show("w640 h355")
    global migGui := g
}

BrowseSrc(*) {
    global ctlSrc
    c := FileSelect(, ctlSrc.Value, "Select images.txt", "Text/INI (*.txt;*.ini)")
    if c
        ctlSrc.Value := c
}

BrowseDst(*) {
    global ctlDst
    c := FileSelect("S", ctlDst.Value, "Select or Create images.db", "SQLite (*.db)")
    if c
        ctlDst.Value := c
}

MigLog(msg) {
    global ctlLog
    cur := ctlLog.Value
    ctlLog.Value := cur (cur ? "`n" : "") msg
    SendMessage(0x115, 7, 0, ctlLog.Hwnd)   ; WM_VSCROLL SB_BOTTOM
}

; ==============================================================================
; MIGRATION LOGIC
; ==============================================================================

RunMigration(*) {
    global ctlSrc, ctlDst, ctlProg

    srcFile := ctlSrc.Value
    dstDb   := ctlDst.Value

    if !FileExist(srcFile) {
        MsgBox("Source file not found:`n" srcFile, "Error", "Icon!")
        return
    }

    ; -- Detect encoding from BOM ------------------------------------------
    fh := FileOpen(srcFile, "r")
    if !fh {
        MsgBox("Cannot open source file.", "Error", "Icon!")
        return
    }
    bom := Buffer(4)
    fh.RawRead(bom, 4)
    fh.Close()

    b0 := NumGet(bom, 0, "UChar")
    b1 := NumGet(bom, 1, "UChar")
    encoding := (b0 = 0xFF && b1 = 0xFE) ? "UTF-16" : "UTF-8"
    MigLog("Detected encoding: " encoding)

    ; -- Parse source file -------------------------------------------------
    images  := Map()   ; key -> b64
    metas   := Map()   ; key -> {sourceFile, folder, origSizeKB, b64SizeKB, encoded}
    curSect := ""

    Loop Read, srcFile, encoding {
        line := Trim(A_LoopReadLine)
        if line = "" || SubStr(line, 1, 1) = ";"
            continue

        if RegExMatch(line, "^\[(.+)\]$", &m) {
            curSect := m[1]
            continue
        }

        eqPos := InStr(line, "=")
        if !eqPos
            continue

        fk := Trim(SubStr(line, 1, eqPos - 1))
        fv := Trim(SubStr(line, eqPos + 1))

        if curSect = "Images" {
            if fk != "" && fv != ""
                images[fk] := fv
        } else if SubStr(curSect, 1, 5) = "Meta_" {
            mk := SubStr(curSect, 6)   ; strip "Meta_" prefix
            if !metas.Has(mk)
                metas[mk] := Map()
            metas[mk][fk] := fv
        }
    }

    MigLog("Found " images.Count " image entries.")
    if images.Count = 0 {
        MsgBox("No images found in source file.", "Nothing to Migrate", "Iconi")
        return
    }

    ; -- Open / create destination DB --------------------------------------
    db := ""
    try {
        db := _Mig_Open(dstDb)
    } catch as e {
        MsgBox("Cannot open database:`n" e.Message, "Error", "Icon!")
        return
    }

    ; Create table
    _Mig_Exec(db,
        "CREATE TABLE IF NOT EXISTS images ("
        . "key TEXT PRIMARY KEY COLLATE NOCASE,"
        . "b64 TEXT NOT NULL,"
        . "source_file TEXT DEFAULT '',"
        . "folder TEXT DEFAULT '',"
        . "orig_kb REAL DEFAULT 0,"
        . "b64_kb REAL DEFAULT 0,"
        . "encoded_date TEXT DEFAULT '')")
    _Mig_Exec(db, "CREATE INDEX IF NOT EXISTS idx_folder ON images (folder)")
    _Mig_Exec(db, "BEGIN TRANSACTION")

    ok   := 0
    fail := 0
    idx  := 0

    for key, b64 in images {
        idx++
        ctlProg.Value := "Migrating " idx " of " images.Count ": " key

        meta    := metas.Has(key) ? metas[key] : Map()
        srcF    := meta.Has("sourceFile")  ? meta["sourceFile"]  : ""
        folder  := meta.Has("folder")      ? meta["folder"]      : "(root)"
        origKB  := meta.Has("origSizeKB")  ? meta["origSizeKB"]  : 0
        b64KB   := meta.Has("b64SizeKB")   ? meta["b64SizeKB"]   : Round(StrLen(b64)/1024, 1)
        encDate := meta.Has("encoded")     ? meta["encoded"]     : ""

        sql := "INSERT OR REPLACE INTO images"
            . " (key,b64,source_file,folder,orig_kb,b64_kb,encoded_date) VALUES ("
            . "'" _Mig_Esc(key)     "',"
            . "'" _Mig_Esc(b64)     "',"
            . "'" _Mig_Esc(srcF)    "',"
            . "'" _Mig_Esc(folder)  "',"
            .     _Mig_Esc(origKB)  ","
            .     _Mig_Esc(b64KB)   ","
            . "'" _Mig_Esc(encDate) "')"

        try {
            _Mig_Exec(db, sql)
            ok++
            MigLog("OK   " key "  (" Round(StrLen(b64)/1024,1) " KB b64)")
        } catch as e {
            fail++
            MigLog("FAIL " key ": " e.Message)
        }
    }

    _Mig_Exec(db, "COMMIT")
    _Mig_Close(db)

    ctlProg.Value := "Done — migrated: " ok "  |  failed: " fail
    MigLog("Migration complete: " ok " OK, " fail " failed.")

    if fail = 0
        MsgBox(ok " images migrated to:`n" dstDb
            . "`n`nYou can now use these images from hotstrings.",
            "Migration Complete", "Iconi")
    else
        MsgBox(ok " OK, " fail " failed. See log for details.",
            "Migration Done With Errors", "Icon!")
}
