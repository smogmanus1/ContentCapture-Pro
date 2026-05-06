#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; Hotstring / Hotkey Auditor
; Scan a folder of .ahk files and check whether a proposed trigger or combo
; is already in use. Also lists conflicts (same trigger defined twice).
; ============================================================================

class Auditor {
    static hotstrings := Map()   ; trigger -> [{file, line, opts}]
    static hotkeys    := Map()   ; combo   -> [{file, line}]
    static scanRoot   := ""

    static Run() {
        if !this.HasOwnProp("gui")
            this.BuildGui()
        this.gui.Show()
    }

    static BuildGui() {
        this.gui := Gui("+Resize", "Hotstring / Hotkey Auditor")
        this.gui.SetFont("s10", "Segoe UI")
        this.gui.MarginX := 14, this.gui.MarginY := 14

        this.gui.Add("Text",, "Scan folder:")
        this.folderEdit := this.gui.Add("Edit", "w520", A_ScriptDir)
        this.gui.Add("Button", "x+6 w90", "Browse...").OnEvent("Click", (*) => this.Browse())

        this.recursiveCb := this.gui.Add("Checkbox", "xm y+8 Checked", "Include subfolders")
        this.gui.Add("Button", "x+18 w90 Default", "Scan").OnEvent("Click", (*) => this.Scan())

        this.statsTxt := this.gui.Add("Text", "xm y+12 w620 cBlue", "Not scanned yet.")

        this.gui.Add("Text", "xm y+16", "Check trigger or combo (e.g. resizeimg, ^!r, F12):")
        this.checkEdit := this.gui.Add("Edit", "xm y+4 w400")
        this.gui.Add("Button", "x+6 w90", "As Hotstring").OnEvent("Click", (*) => this.CheckHotstring())
        this.gui.Add("Button", "x+6 w90", "As Hotkey").OnEvent("Click", (*) => this.CheckHotkey())

        this.resultTxt := this.gui.Add("Text", "xm y+10 w620 h22 cBlue", "")

        this.gui.Add("Button", "xm y+10 w130", "List Hotstrings").OnEvent("Click", (*) => this.ListAll("hs"))
        this.gui.Add("Button", "x+6 w130",     "List Hotkeys").OnEvent("Click", (*) => this.ListAll("hk"))
        this.gui.Add("Button", "x+6 w130",     "Find Conflicts").OnEvent("Click", (*) => this.FindConflicts())
        this.gui.Add("Button", "x+6 w130",     "Export to CSV").OnEvent("Click", (*) => this.ExportCsv())

        this.lv := this.gui.Add("ListView", "xm y+12 w620 r14", ["Trigger", "File", "Line"])
        this.lv.ModifyCol(1, 200)
        this.lv.ModifyCol(2, 340)
        this.lv.ModifyCol(3, 60)
        this.lv.OnEvent("DoubleClick", (*) => this.OpenSelected())

        this.gui.OnEvent("Close", (*) => this.gui.Hide())
    }

    static Browse() {
        p := DirSelect(, 3, "Select Folder to Scan")
        if p
            this.folderEdit.Value := p
    }

    static Scan() {
        folder := Trim(this.folderEdit.Value)
        if !DirExist(folder) {
            this.SetStats("Folder not found.", "Red")
            return
        }
        this.scanRoot := folder
        this.hotstrings := Map()
        this.hotkeys    := Map()
        files := 0

        flags := this.recursiveCb.Value ? "FR" : "F"
        Loop Files, folder "\*.ahk", flags {
            files++
            this.ParseFile(A_LoopFileFullPath)
        }

        this.lv.Delete()
        this.SetResult("", "Blue")
        this.SetStats(Format("Scanned {} file(s) - {} unique hotstring(s), {} unique hotkey(s)",
            files, this.hotstrings.Count, this.hotkeys.Count), "Green")
    }

    static ParseFile(path) {
        try content := FileRead(path, "UTF-8")
        catch
            return

        lineNum := 0
        for line in StrSplit(content, "`n", "`r") {
            lineNum++
            stripped := Trim(line)
            if stripped = "" || SubStr(stripped, 1, 1) = ";"
                continue

            ; Hotstring: :options:trigger::
            if RegExMatch(stripped, "^:([^:]*):([^:]+?)::", &m) {
                this.AddTo(this.hotstrings, m[2], {file: path, line: lineNum, opts: m[1]})
                continue
            }
            ; Hotkey: modifiers + key (+ optional & key2) + ::
            if RegExMatch(stripped, "^([\^!+#<>*~$]*[\w]+(?:\s*&\s*[\w]+)?)\s*::", &m) {
                this.AddTo(this.hotkeys, this.Normalize(m[1]), {file: path, line: lineNum})
            }
        }
    }

    static AddTo(map, key, entry) {
        if !map.Has(key)
            map[key] := []
        map[key].Push(entry)
    }

    static Normalize(combo) {
        ; Lowercase + strip whitespace; modifier order isn't normalized but
        ; people are usually consistent within a codebase.
        return StrLower(RegExReplace(Trim(combo), "\s+", ""))
    }

    static SetStats(text, color := "Blue") {
        this.statsTxt.Opt("c" color)
        this.statsTxt.Text := text
    }

    static SetResult(text, color := "Blue") {
        this.resultTxt.Opt("c" color)
        this.resultTxt.Text := text
    }

    static CheckHotstring() {
        t := Trim(this.checkEdit.Value)
        if !t {
            this.SetResult("Enter a trigger to check.", "Red")
            return
        }
        ; Strip user-supplied colons if they pasted ::foo::
        t := RegExReplace(t, "^:+|:+$", "")
        if this.hotstrings.Has(t) {
            entries := this.hotstrings[t]
            this.SetResult(Format("TAKEN as hotstring ::{}:: - {} definition(s)", t, entries.Length), "Red")
            this.ShowEntries("::" t "::", entries)
        } else {
            this.SetResult("AVAILABLE as hotstring ::" t "::", "Green")
            this.lv.Delete()
        }
    }

    static CheckHotkey() {
        t := Trim(this.checkEdit.Value)
        if !t {
            this.SetResult("Enter a combo to check.", "Red")
            return
        }
        t := RegExReplace(t, ":+$", "")
        norm := this.Normalize(t)
        if this.hotkeys.Has(norm) {
            entries := this.hotkeys[norm]
            this.SetResult(Format("TAKEN as hotkey {}:: - {} definition(s)", t, entries.Length), "Red")
            this.ShowEntries(t "::", entries)
        } else {
            this.SetResult("AVAILABLE as hotkey " t "::", "Green")
            this.lv.Delete()
        }
    }

    static ShowEntries(label, entries) {
        this.lv.Delete()
        for e in entries
            this.lv.Add(, label, this.Rel(e.file), e.line)
    }

    static Rel(path) {
        if this.scanRoot && InStr(path, this.scanRoot) = 1
            return SubStr(path, StrLen(this.scanRoot) + 2)
        return path
    }

    static ListAll(kind) {
        this.lv.Delete()
        total := 0
        if kind = "hs" {
            for trig, entries in this.hotstrings
                for e in entries {
                    this.lv.Add(, "::" trig "::", this.Rel(e.file), e.line)
                    total++
                }
            this.SetResult(Format("{} hotstring definition(s)", total), "Blue")
        } else {
            for combo, entries in this.hotkeys
                for e in entries {
                    this.lv.Add(, combo "::", this.Rel(e.file), e.line)
                    total++
                }
            this.SetResult(Format("{} hotkey definition(s)", total), "Blue")
        }
    }

    static FindConflicts() {
        this.lv.Delete()
        n := 0
        for trig, entries in this.hotstrings
            if entries.Length > 1
                for e in entries {
                    this.lv.Add(, "::" trig "::", this.Rel(e.file), e.line)
                    n++
                }
        for combo, entries in this.hotkeys
            if entries.Length > 1
                for e in entries {
                    this.lv.Add(, combo "::", this.Rel(e.file), e.line)
                    n++
                }
        if n = 0
            this.SetResult("No conflicts found.", "Green")
        else
            this.SetResult(Format("{} conflicting definition(s) - same trigger in multiple places", n), "Red")
    }

    static ExportCsv() {
        path := FileSelect("S 16", A_ScriptDir "\hotkey_audit.csv", "Save audit", "CSV (*.csv)")
        if !path
            return
        if !InStr(path, ".")
            path .= ".csv"
        out := "Kind,Trigger,File,Line,Options`n"
        for trig, entries in this.hotstrings
            for e in entries
                out .= Format('Hotstring,"::{}::","{}",{},"{}"`n', trig, this.Rel(e.file), e.line, e.opts)
        for combo, entries in this.hotkeys
            for e in entries
                out .= Format('Hotkey,"{}::","{}",{},`n', combo, this.Rel(e.file), e.line)
        try {
            if FileExist(path)
                FileDelete(path)
            FileAppend(out, path, "UTF-8")
            this.SetResult("Exported: " path, "Green")
        } catch as e {
            this.SetResult("Export failed: " e.Message, "Red")
        }
    }

    static OpenSelected() {
        row := this.lv.GetNext(0)
        if !row
            return
        relFile := this.lv.GetText(row, 2)
        line    := this.lv.GetText(row, 3)
        full := this.scanRoot ? this.scanRoot "\" relFile : relFile
        ; Open in VS Code at the specific line
        try Run('code -g "' full ':' line '"')
        catch
            try Run('explorer.exe /select,"' full '"')
    }
}

; --- Hotstring trigger: type "hotkeya" followed by space/enter/etc ---
::hotkeya::Auditor.Run()
