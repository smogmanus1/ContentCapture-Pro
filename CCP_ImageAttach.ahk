; CCP_ImageAttach.ahk
; ContentCapture Pro - DB Image Key Picker
; Opens a search/preview GUI into images.db
; Called from the Edit GUI to attach an image key to a capture record
; AHK v2 - UTF-8 with BOM

#Requires AutoHotkey v2.0

; -- Show the image picker GUI ---------------------------------------------
; currentKey = already-attached key (shown as hint), or ""
; callback   = function(selectedKey) called when user clicks Attach
CIA_ShowPicker(currentKey, callback) {
    dbPath := A_ScriptDir "\images.db"
    if !FileExist(dbPath) {
        MsgBox("images.db not found.`nRun CCP_ImageBatchConverter.ahk first.",
            "No Database", "Icon!")
        return
    }

    pGui := Gui("+AlwaysOnTop +Resize", "Attach Image — CCP Image Database")
    pGui.SetFont("s9", "Segoe UI")
    pGui.OnEvent("Close", (*) => pGui.Destroy())
    pGui.OnEvent("Size", OnPickerSize)

    ; Search row
    pGui.Add("Text",   "x10 y10 w55", "Search:")
    searchBox := pGui.Add("Edit", "x68 y8 w300")
    pGui.Add("Button", "x374 y6 w70",  "Search").OnEvent("Click", DoSearch)
    pGui.Add("Button", "x449 y6 w60",  "Clear").OnEvent("Click",  ClearSearch)
    countLbl  := pGui.Add("Text", "x10 y36 w350 vCountLabel", "Loading...")

    ; List
    lv := pGui.Add("ListView",
        "x10 y55 w510 h360 Grid",
        ["Key", "Source File", "Folder", "KB"])
    lv.ModifyCol(1, 190)
    lv.ModifyCol(2, 165)
    lv.ModifyCol(3, 100)
    lv.ModifyCol(4, 45)
    lv.OnEvent("ItemSelect", OnItemSelect)
    lv.OnEvent("DoubleClick", (*) => DoSelect())

    ; Preview panel
    pGui.Add("GroupBox", "x528 y50 w250 h200", "Preview")
    pic := pGui.Add("Pic", "x538 y67 w230 h175 +Border", "")

    ; Info panel
    pGui.Add("GroupBox", "x528 y255 w250 h100", "Info")
    infoKey := pGui.Add("Text", "x538 y272 w235", "Key: -")
    infoHs  := pGui.Add("Text", "x538 y289 w235", "Hotstring: -")
    infoSize := pGui.Add("Text", "x538 y306 w235", "")

    ; Platform variants hint
    pGui.Add("GroupBox", "x528 y360 w250 h55", "Platform variants stored")
    varTxt := pGui.Add("Text", "x538 y378 w235 cGray", "(select an image to check)")

    ; Buttons
    selBtn := pGui.Add("Button", "x10 y425 w140 h28 Default", "Attach This Image")
    selBtn.OnEvent("Click", DoSelect)
    pGui.Add("Button", "x158 y425 w80 h28", "Cancel").OnEvent("Click",
        (*) => pGui.Destroy())
    if currentKey != ""
        pGui.Add("Text", "x248 y429 w275 cGray", "Current: " currentKey)

    ; State vars
    selKey   := ""
    tempFile := ""

    searchBox.OnEvent("Change", (*) => (searchBox.Value = "" ? LoadAll() : ""))
    LoadAll()
    pGui.Show("w788 h465")

    ; ---- Inner functions ------------------------------------------------

    LoadAll(*) {
        lv.Delete()
        selKey := ""
        try {
            db   := CCP_DB_Open(dbPath)
            rows := CCP_DB_GetAllImages(db)
            cnt  := CCP_DB_ImageCount(db)
            CCP_DB_Close(db)
            shown := 0
            for row in rows {
                ; Only show base keys (hide _pin/_bsky/_li variants)
                if RegExMatch(row["key"], "_(pin|bsky|li)$")
                    continue
                lv.Add("", row["key"], row["source_file"], row["folder"],
                    Round(row["b64_kb"], 0))
                shown++
            }
            countLbl.Value := shown " images  (" cnt " total including variants)"
        } catch as e {
            countLbl.Value := "Error loading DB: " e.Message
        }
    }

    DoSearch(*) {
        srch := Trim(searchBox.Value)
        if srch = "" {
            LoadAll()
            return
        }
        lv.Delete()
        selKey := ""
        try {
            db   := CCP_DB_Open(dbPath)
            rows := CCP_DB_SearchImages(db, srch)
            CCP_DB_Close(db)
            shown := 0
            for row in rows {
                if RegExMatch(row["key"], "_(pin|bsky|li)$")
                    continue
                lv.Add("", row["key"], row["source_file"], row["folder"],
                    Round(row["b64_kb"], 0))
                shown++
            }
            countLbl.Value := shown " results for: " srch
        } catch as e {
            countLbl.Value := "Search error: " e.Message
        }
    }

    ClearSearch(*) {
        searchBox.Value := ""
        LoadAll()
    }

    OnItemSelect(lvCtl, rowNum, selected) {
        if !selected || rowNum = 0
            return
        selKey := lvCtl.GetText(rowNum, 1)

        ; Update info panel
        infoKey.Value  := "Key: " selKey
        infoHs.Value   := "Hotstring: " Chr(59) Chr(59) selKey "img"

        ; Check which variants exist
        CleanTemp()
        try {
            db := CCP_DB_Open(dbPath)

            ; Get size info
            rows := CCP_DB_Query(db, "SELECT b64_kb FROM images WHERE key='"
                . CCP_DB_Escape(selKey) "'")
            if rows.Length > 0
                infoSize.Value := "Size: " Round(rows[1]["b64_kb"], 0) " KB (b64)"

            ; Check variants
            variants := []
            if CCP_DB_KeyExists(db, selKey "_pin")
                variants.Push("Pinterest")
            if CCP_DB_KeyExists(db, selKey "_bsky")
                variants.Push("Bluesky")
            if CCP_DB_KeyExists(db, selKey "_li")
                variants.Push("LinkedIn")
            varTxt.Value := variants.Length > 0
                ? "+" . StrJoin(variants, "  +")
                : "No platform variants found"

            ; Load preview
            b64 := CCP_DB_GetImage(db, selKey)
            CCP_DB_Close(db)

            if b64 != "" {
                ext := CIA_ExtFromB64(b64)
                tf  := A_Temp "\_ciapick_" A_TickCount "." ext
                if CIA_B64ToFile(b64, tf) {
                    tempFile := tf
                    try pic.Value := "*w230 *h175 " tf
                }
            }
        } catch {
            pic.Value := ""
        }
    }

    DoSelect(*) {
        if selKey = "" {
            MsgBox("Please click an image in the list first.", "No Selection", "Icon!")
            return
        }
        CleanTemp()
        pGui.Destroy()
        callback(selKey)
    }

    CleanTemp() {
        if tempFile && FileExist(tempFile)
            try FileDelete(tempFile)
        tempFile := ""
        try pic.Value := ""
    }

    OnPickerSize(g, mm, w, h) {
        if mm = 1
            return
        lv.Move(,, Max(300, w - 270), Max(150, h - 105))
    }
}

; -- Helper: join array with separator ------------------------------------
StrJoin(arr, sep) {
    out := ""
    for i, v in arr {
        if i > 1
            out .= sep
        out .= v
    }
    return out
}

; -- Detect image type from first bytes of b64 ----------------------------
CIA_ExtFromB64(b64) {
    h := SubStr(b64, 1, 8)
    if SubStr(h, 1, 6) = "R0lGOD"
        return "gif"
    if SubStr(h, 1, 5) = "iVBOR"
        return "png"
    if SubStr(h, 1, 4) = "/9j/"
        return "jpg"
    if SubStr(h, 1, 3) = "Qk0"
        return "bmp"
    return "jpg"
}

; -- Decode b64 to file ---------------------------------------------------
CIA_B64ToFile(b64, path) {
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
        f := FileOpen(path, "w")
        if !f
            return false
        f.RawWrite(buf, outSz)
        f.Close()
        return true
    } catch {
        return false
    }
}
