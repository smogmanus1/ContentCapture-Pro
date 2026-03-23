; CCP_ImageViewer.ahk
; ContentCapture Pro - Image Viewer & Manager
; Browse, preview, rename, delete and export images from images.db
; Requires: winsqlite3.dll + CCP_SQLite.ahk in same folder
; AHK v2 - UTF-8 with BOM

#Requires AutoHotkey v2.0
#SingleInstance Force
#Include CCP_SQLite.ahk

global dbPath      := A_ScriptDir "\images.db"
global allRows     := []
global currentTemp := ""
global pToken      := 0
global mainGui, lvKeys, picPreview
global ctlSearch, ctlKeyLabel, ctlHotstring, ctlMeta, ctlDbPath

pToken := Gdip_Startup()
BuildGui()
LoadImages()

BuildGui() {
    global mainGui, lvKeys, picPreview
    global ctlSearch, ctlKeyLabel, ctlHotstring, ctlMeta, ctlDbPath

    mainGui := Gui("+Resize +MinSize800x500", "CCP Image Viewer")
    mainGui.SetFont("s9", "Segoe UI")
    mainGui.OnEvent("Close", OnClose)
    mainGui.OnEvent("Size", OnResize)

    mainGui.Add("Text", "x10 y12 w60", "Database:")
    ctlDbPath := mainGui.Add("Edit", "x74 y10 w465 ReadOnly", dbPath)
    mainGui.Add("Button", "x545 y8 w75", "Browse...").OnEvent("Click", BrowseDb)
    mainGui.Add("Button", "x625 y8 w75", "Reload").OnEvent("Click", (*) => LoadImages())

    mainGui.Add("Text", "x10 y40 w50", "Search:")
    ctlSearch := mainGui.Add("Edit", "x64 y38 w220")
    ctlSearch.OnEvent("Change", OnSearch)
    mainGui.Add("Text", "x292 y40 w400 vCountLabel", "")

    lvKeys := mainGui.Add("ListView",
        "x10 y62 w440 h450 Grid",
        ["Key", "Source File", "Folder", "KB", "Encoded"])
    lvKeys.ModifyCol(1, 140)
    lvKeys.ModifyCol(2, 125)
    lvKeys.ModifyCol(3, 80)
    lvKeys.ModifyCol(4, 42)
    lvKeys.ModifyCol(5, 115)
    lvKeys.OnEvent("ItemSelect", OnSelect)
    lvKeys.OnEvent("DoubleClick", OnDblClick)

    mainGui.Add("GroupBox", "x460 y58 w310 h200", "Preview")
    picPreview := mainGui.Add("Pic", "x470 y75 w290 h175 +Border", "")

    mainGui.Add("GroupBox", "x460 y265 w310 h120", "Info")
    ctlKeyLabel  := mainGui.Add("Text", "x470 y282 w295", "Key: -")
    ctlHotstring := mainGui.Add("Text", "x470 y299 w295", "Hotstring: -")
    ctlMeta      := mainGui.Add("Edit", "x470 y316 w290 h62 ReadOnly -VScroll", "")

    mainGui.Add("GroupBox", "x460 y392 w310 h125", "Actions")
    mainGui.Add("Button", "x470 y410 w130 h26",
        "Copy to Clipboard").OnEvent("Click", CopyToClipboard)
    mainGui.Add("Button", "x608 y410 w152 h26",
        "Copy Hotstring").OnEvent("Click", CopyHotstring)
    mainGui.Add("Button", "x470 y442 w130 h26",
        "Export to File...").OnEvent("Click", ExportImage)
    mainGui.Add("Button", "x608 y442 w152 h26",
        "Rename Key...").OnEvent("Click", RenameKey)
    mainGui.Add("Button", "x470 y474 w290 h26",
        "Delete Key (permanent)").OnEvent("Click", DeleteKey)

    mainGui.Show("w780 h530")
}

OnResize(g, mm, w, h) {
    global lvKeys
    if mm = 1
        return
    lvKeys.Move(,, 440, Max(200, h-90))
}

BrowseDb(*) {
    global dbPath, ctlDbPath
    c := FileSelect(, ctlDbPath.Value, "Select images.db",
        "SQLite Database (*.db)")
    if c {
        dbPath := c
        ctlDbPath.Value := c
        LoadImages()
    }
}

; -- Load all image list rows from DB (no b64 - fast) -----------------------
LoadImages(*) {
    global allRows, dbPath, ctlSearch

    if !FileExist(dbPath) {
        MsgBox("Database not found:`n" dbPath
            . "`n`nRun CCP_ImageBatchConverter.ahk first.",
            "Not Found", "Icon!")
        return
    }

    try {
        db := CCP_DB_Open(dbPath)
        CCP_DB_InitImages(db)
        allRows := CCP_DB_GetAllImages(db)
        total   := CCP_DB_ImageCount(db)
        CCP_DB_Close(db)
    } catch as e {
        MsgBox("Cannot open database:`n" e.Message, "Error", "Icon!")
        return
    }

    ctlSearch.Value := ""
    PopulateList(allRows)
    mainGui["CountLabel"].Value := allRows.Length " images in database"
}

OnSearch(*) {
    global allRows, dbPath, ctlSearch
    srch := Trim(ctlSearch.Value)
    if srch = "" {
        PopulateList(allRows)
        return
    }
    try {
        db   := CCP_DB_Open(dbPath)
        rows := CCP_DB_SearchImages(db, srch)
        CCP_DB_Close(db)
        PopulateList(rows)
        mainGui["CountLabel"].Value := rows.Length " of " allRows.Length " images"
    } catch as e {
        LogMsg("Search error: " e.Message)
    }
}

PopulateList(rows) {
    global lvKeys
    lvKeys.Delete()
    for r in rows
        lvKeys.Add("", r["key"], r["source_file"], r["folder"],
            r["b64_kb"], r["encoded_date"])
    ClearPreview()
}

OnSelect(lv, rowNum) {
    if rowNum > 0
        ShowPreview(rowNum)
}

OnDblClick(lv, rowNum) {
    if rowNum > 0
        CopyHotstring()
}

ShowPreview(rowNum) {
    global picPreview, currentTemp, ctlKeyLabel, ctlHotstring, ctlMeta, dbPath

    key     := lvKeys.GetText(rowNum, 1)
    srcFile := lvKeys.GetText(rowNum, 2)
    folder  := lvKeys.GetText(rowNum, 3)
    b64kb   := lvKeys.GetText(rowNum, 4)
    encDate := lvKeys.GetText(rowNum, 5)

    ctlKeyLabel.Value  := "Key: " key
    ctlHotstring.Value := "Hotstring: " Chr(59) Chr(59) key "img"
    ctlMeta.Value      := "Source:  " srcFile "`n"
        . "Folder:  " (folder ? folder : "(root)") "`n"
        . "Size:    " b64kb " KB (b64)`n"
        . "Encoded: " encDate

    ; Fetch b64 from DB
    CleanupTemp()
    b64 := ""
    try {
        db  := CCP_DB_Open(dbPath)
        b64 := CCP_DB_GetImage(db, key)
        CCP_DB_Close(db)
    } catch {
        picPreview.Value := ""
        return
    }

    if b64 = "" {
        picPreview.Value := ""
        return
    }

    ext      := GetExtFromB64(b64)
    tempPath := A_Temp "\_ccpview_" key "." ext
    if Base64ToFile(b64, tempPath) {
        currentTemp := tempPath
        try picPreview.Value := "*w290 *h175 " tempPath
        catch
            picPreview.Value := ""
    } else {
        picPreview.Value := ""
    }
}

GetExtFromB64(b64) {
    h := SubStr(b64, 1, 8)
    if SubStr(h, 1, 6) = "R0lGOD" return "gif"
    if SubStr(h, 1, 5) = "iVBOR" return "png"
    if SubStr(h, 1, 4) = "/9j/" return "jpg"
    if SubStr(h, 1, 3) = "Qk0"  return "bmp"
    return "png"
}

ClearPreview() {
    global picPreview, ctlKeyLabel, ctlHotstring, ctlMeta
    CleanupTemp()
    try picPreview.Value := ""
    ctlKeyLabel.Value  := "Key: -"
    ctlHotstring.Value := "Hotstring: -"
    ctlMeta.Value      := ""
}

GetSelectedKey() {
    row := lvKeys.GetNext(0, "Focused")
    if !row
        row := lvKeys.GetNext(0)
    if !row
        return ""
    return lvKeys.GetText(row, 1)
}

CopyToClipboard(*) {
    global pToken, dbPath
    key := GetSelectedKey()
    if key = "" {
        MsgBox("No image selected.", "Copy", "Icon!")
        return
    }
    b64 := ""
    try {
        db  := CCP_DB_Open(dbPath)
        b64 := CCP_DB_GetImage(db, key)
        CCP_DB_Close(db)
    } catch as e {
        MsgBox("DB error: " e.Message, "Error", "Icon!")
        return
    }
    if b64 = "" {
        MsgBox("No image data for key: " key, "Error", "Icon!")
        return
    }
    ext      := GetExtFromB64(b64)
    tempPath := A_Temp "\_ccpcopy_" A_TickCount "." ext
    if !Base64ToFile(b64, tempPath) {
        MsgBox("Decode failed.", "Error", "Icon!")
        return
    }
    pb := Gdip_CreateBitmapFromFile(tempPath)
    FileDelete(tempPath)
    if !pb {
        MsgBox("Could not load image.", "Error", "Icon!")
        return
    }
    hBmp := 0
    DllCall("gdiplus\GdipCreateHBITMAPFromBitmap",
        "UPtr", pb, "UPtr*", &hBmp, "UInt", 0xFFFFFFFF)
    Gdip_DisposeImage(pb)
    if !hBmp {
        MsgBox("Bitmap handle failed.", "Error", "Icon!")
        return
    }
    if DllCall("OpenClipboard", "Ptr", mainGui.Hwnd) {
        DllCall("EmptyClipboard")
        DllCall("SetClipboardData", "UInt", 2, "Ptr", hBmp)
        DllCall("CloseClipboard")
        TrayTip("Copied: " key, "CCP Image Viewer", 1)
    } else {
        DllCall("DeleteObject", "Ptr", hBmp)
        MsgBox("Could not open clipboard.", "Error", "Icon!")
    }
}

CopyHotstring(*) {
    key := GetSelectedKey()
    if key = "" {
        MsgBox("No image selected.", "Copy Hotstring", "Icon!")
        return
    }
    hs := Chr(59) Chr(59) key "img"
    A_Clipboard := hs
    TrayTip(hs " copied!", "CCP Image Viewer", 1)
}

ExportImage(*) {
    global dbPath
    key := GetSelectedKey()
    if key = "" {
        MsgBox("No image selected.", "Export", "Icon!")
        return
    }
    b64 := ""
    try {
        db  := CCP_DB_Open(dbPath)
        b64 := CCP_DB_GetImage(db, key)
        CCP_DB_Close(db)
    } catch as e {
        MsgBox("DB error: " e.Message, "Error", "Icon!")
        return
    }
    if b64 = "" {
        MsgBox("No image data for: " key, "Error", "Icon!")
        return
    }
    ext  := GetExtFromB64(b64)
    dest := FileSelect("S", key "." ext, "Export Image As",
        "Image Files (*.png;*.jpg;*.gif;*.bmp)")
    if !dest
        return
    if Base64ToFile(b64, dest)
        MsgBox("Exported to:`n" dest, "Export OK", "Iconi")
    else
        MsgBox("Export failed.", "Error", "Icon!")
}

RenameKey(*) {
    global dbPath
    key := GetSelectedKey()
    if key = "" {
        MsgBox("No image selected.", "Rename", "Icon!")
        return
    }
    rGui := Gui("+Owner" mainGui.Hwnd " +AlwaysOnTop", "Rename Key")
    rGui.SetFont("s9", "Segoe UI")
    rGui.Add("Text",, "Current key: " key)
    rGui.Add("Text",, "New key (a-z 0-9 _ - only):")
    global ctlRenameVal := rGui.Add("Edit", "w280 vNewKey", key)
    rGui.Add("Button", "Default w80", "OK").OnEvent("Click",
        DoRename.Bind(key, rGui))
    rGui.Add("Button", "w80", "Cancel").OnEvent("Click",
        (*) => rGui.Destroy())
    rGui.Show()
}

DoRename(oldKey, rGui, *) {
    global dbPath
    s      := rGui.Submit()
    newKey := RegExReplace(StrLower(Trim(s.NewKey)), "[^a-z0-9_\-]", "")
    if newKey = "" || newKey = oldKey {
        rGui.Destroy()
        return
    }
    try {
        db := CCP_DB_Open(dbPath)
        if CCP_DB_KeyExists(db, newKey) {
            CCP_DB_Close(db)
            MsgBox("Key '" newKey "' already exists.", "Duplicate", "Icon!")
            return
        }
        CCP_DB_RenameImage(db, oldKey, newKey)
        CCP_DB_Close(db)
    } catch as e {
        MsgBox("Rename failed: " e.Message, "Error", "Icon!")
        rGui.Destroy()
        return
    }
    rGui.Destroy()
    LoadImages()
    TrayTip("Renamed to: " newKey, "CCP Image Viewer", 1)
}

DeleteKey(*) {
    global dbPath
    key := GetSelectedKey()
    if key = "" {
        MsgBox("No image selected.", "Delete", "Icon!")
        return
    }
    if MsgBox("Permanently delete '" key "' from database?",
            "Confirm Delete", "YesNo Icon!") != "Yes"
        return
    try {
        db := CCP_DB_Open(dbPath)
        CCP_DB_DeleteImage(db, key)
        CCP_DB_Close(db)
    } catch as e {
        MsgBox("Delete failed: " e.Message, "Error", "Icon!")
        return
    }
    LoadImages()
    TrayTip("Deleted: " key, "CCP Image Viewer", 1)
}

Base64ToFile(b64, filePath) {
    try {
        outSz := 0
        DllCall("Crypt32.dll\CryptStringToBinaryW",
            "Str", b64, "UInt", 0, "UInt", 1,
            "Ptr", 0, "UInt*", &outSz, "Ptr", 0, "Ptr", 0)
        if !outSz
            return false
        buf := Buffer(outSz)
        DllCall("Crypt32.dll\CryptStringToBinaryW",
            "Str", b64, "UInt", 0, "UInt", 1,
            "Ptr", buf, "UInt*", &outSz, "Ptr", 0, "Ptr", 0)
        f := FileOpen(filePath, "w")
        if !f
            return false
        f.RawWrite(buf, outSz)
        f.Close()
        return true
    } catch {
        return false
    }
}

CleanupTemp() {
    global currentTemp
    if currentTemp && FileExist(currentTemp)
        try FileDelete(currentTemp)
    currentTemp := ""
}

OnClose(*) {
    CleanupTemp()
    Gdip_Shutdown(pToken)
    ExitApp()
}

; == GDI+ wrappers ============================================================

Gdip_Startup() {
    si := Buffer(24, 0)
    NumPut("UInt", 1, si, 0)
    pt := 0
    DllCall("gdiplus\GdiplusStartup", "UPtr*", &pt, "Ptr", si, "Ptr", 0)
    return pt
}
Gdip_Shutdown(pt)    => DllCall("gdiplus\GdiplusShutdown", "UPtr", pt)
Gdip_DisposeImage(p) => DllCall("gdiplus\GdipDisposeImage", "UPtr", p)

Gdip_CreateBitmapFromFile(path) {
    pb := 0
    w  := Buffer((StrLen(path)+1)*2)
    StrPut(path, w, "UTF-16")
    DllCall("gdiplus\GdipCreateBitmapFromFile", "Ptr", w, "UPtr*", &pb)
    return pb
}
