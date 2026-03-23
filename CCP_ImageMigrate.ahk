; CCP_ImageMigrate.ahk
; ContentCapture Pro - One-time migration: images.txt -> images.db
; Run this once to migrate your existing encoded images into SQLite
; Safe to run multiple times - uses INSERT OR REPLACE
; AHK v2 - UTF-8 with BOM

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include CCP_SQLite.ahk

BuildGui()

BuildGui() {
    g := Gui(, "CCP Image Migration: images.txt to images.db")
    g.SetFont("s9", "Segoe UI")
    g.OnEvent("Close", (*) => ExitApp())

    g.Add("Text", "x10 y12", "Source (images.txt):")
    global ctlSrc := g.Add("Edit", "x165 y10 w380",
        A_ScriptDir "\images.txt")
    g.Add("Button", "x550 y8 w80", "Browse...").OnEvent("Click", BrowseSrc)

    g.Add("Text", "x10 y42", "Destination (images.db):")
    global ctlDst := g.Add("Edit", "x165 y40 w380",
        A_ScriptDir "\images.db")
    g.Add("Button", "x550 y38 w80", "Browse...").OnEvent("Click", BrowseDst)

    g.Add("Button", "x10 y72 w150 h30", "Run Migration").OnEvent("Click", RunMigration)

    global ctlProgress := g.Add("Text",   "x10 y115 w620", "")
    global ctlLog      := g.Add("Edit", "x10 y135 w620 h200 ReadOnly -Wrap VScroll", "")

    g.Show("w640 h350")
    global migGui := g
}

BrowseSrc(*) {
    global ctlSrc
    c := FileSelect(, ctlSrc.Value, "Select images.txt",
        "Text/INI files (*.txt;*.ini)")
    if c
        ctlSrc.Value := c
}

BrowseDst(*) {
    global ctlDst
    c := FileSelect("S", ctlDst.Value, "Select or Create images.db",
        "SQLite Database (*.db)")
    if c
        ctlDst.Value := c
}

Log(msg) {
    global ctlLog
    cur := ctlLog.Value
    ctlLog.Value := cur . (cur ? "`n" : "") . msg
    SendMessage(0x115, 7, 0, ctlLog.Hwnd)
}

RunMigration(*) {
    global ctlSrc, ctlDst, ctlProgress

    srcFile := ctlSrc.Value
    dstDb   := ctlDst.Value

    if !FileExist(srcFile) {
        MsgBox("Source file not found:`n" srcFile, "Error", "Icon!")
        return
    }

    ; -- Parse images.txt (handles both UTF-8 BOM and UTF-16) ----------------
    ; Detect encoding from BOM
    rawBytes := ""
    f := FileOpen(srcFile, "r")
    if !f {
        MsgBox("Cannot open source file.", "Error", "Icon!")
        return
    }
    firstBytes := Buffer(4)
    f.RawRead(firstBytes, 4)
    f.Close()

    b0 := NumGet(firstBytes, 0, "UChar")
    b1 := NumGet(firstBytes, 1, "UChar")

    if b0 = 0xFF && b1 = 0xFE
        encoding := "UTF-16"
    else
        encoding := "UTF-8"

    Log("Detected encoding: " encoding)

    ; Read all lines
    images  := Map()  ; key -> b64
    metas   := Map()  ; key -> Map of meta fields
    curSect := ""

    Loop Read, srcFile, encoding {
        line := Trim(A_LoopReadLine)
        if line = "" || SubStr(line,1,1) = ";"
            continue
        if RegExMatch(line, "^\[(.+)\]$", &m) {
            curSect := m[1]
            continue
        }
        eqPos := InStr(line, "=")
        if !eqPos
            continue
        fk := Trim(SubStr(line, 1, eqPos-1))
        fv := Trim(SubStr(line, eqPos+1))

        if curSect = "Images" {
            images[fk] := fv
        } else if SubStr(curSect, 1, 5) = "Meta_" {
            mk := SubStr(curSect, 6)
            if !metas.Has(mk)
                metas[mk] := Map()
            metas[mk][fk] := fv
        }
    }

    Log("Found " images.Count " image entries in source file.")

    if images.Count = 0 {
        MsgBox("No images found in source file.", "Nothing to migrate", "Iconi")
        return
    }

    ; -- Open / create destination DB ----------------------------------------
    db := ""
    try {
        db := CCP_DB_Open(dstDb)
        CCP_DB_InitImages(db)
    } catch as e {
        MsgBox("Cannot open database:`n" e.Message, "Error", "Icon!")
        return
    }

    ; -- Migrate -------------------------------------------------------------
    ok := 0
    fail := 0
    CCP_DB_Begin(db)

    for key, b64 in images {
        meta    := metas.Has(key) ? metas[key] : Map()
        srcFile := meta.Has("sourceFile") ? meta["sourceFile"] : ""
        folder  := meta.Has("folder")     ? meta["folder"]     : "(root)"
        origKB  := meta.Has("origSizeKB") ? meta["origSizeKB"] : 0
        b64KB   := meta.Has("b64SizeKB")  ? meta["b64SizeKB"]  : Round(StrLen(b64)/1024, 1)
        encDate := meta.Has("encoded")    ? meta["encoded"]    : ""

        ctlProgress.Value := "Migrating: " key " (" ok+1 " of " images.Count ")"

        try {
            CCP_DB_UpsertImage(db, key, b64, srcFile, folder, origKB, b64KB, encDate)
            ok++
            Log("OK  " key " (" Round(StrLen(b64)/1024,1) " KB b64)")
        } catch as e {
            fail++
            Log("FAIL  " key ": " e.Message)
        }
    }

    CCP_DB_Commit(db)
    CCP_DB_Close(db)

    ctlProgress.Value := "Done.  Migrated: " ok "  |  Failed: " fail
    Log("Migration complete: " ok " OK, " fail " failed.")

    if fail = 0
        MsgBox(ok " images migrated to:`n" dstDb
            . "`n`nYou can now use CCP_ImageViewer.ahk and the SQLite-based converter.",
            "Migration Complete", "Iconi")
    else
        MsgBox(ok " OK, " fail " failed. See log for details.",
            "Migration Done With Errors", "Icon!")
}
