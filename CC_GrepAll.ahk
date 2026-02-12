; ==============================================================================
; ContentCapture Pro - Deep Search (JSON + Legacy .ahk Files)
; ==============================================================================
; Searches through EVERYTHING - JSON capture database AND legacy .ahk files
; (gramshare.ahk, sharejason.ahk, etc.) for any text: URLs, phrases, keywords.
;
; When matches are found in legacy files, results display in a browser-style
; ListView — just like the Capture Browser but for legacy .ahk content.
;
; Version: 2.0
; ==============================================================================

; ==============================================================================
; CONFIGURATION
; ==============================================================================
class CC_GrepConfig {
    ; Legacy .ahk files to search through
    ; Update these paths to match YOUR file locations
    static LegacyFiles := [
        A_ScriptDir "\gramshare.ahk",
        A_ScriptDir "\sharejason.ahk"
    ]
    
    ; Maximum results per source
    static MaxResultsPerSource := 200
}

; ==============================================================================
; MAIN ENTRY POINT
; ==============================================================================

CC_GrepAll(searchText := "", parentGui := "") {
    if (searchText = "") {
        grepInput := InputBox(
            "Deep Search ALL captures (JSON + legacy .ahk files):`n`n"
            "Paste a URL, type a keyword, phrase — anything.",
            "Deep Search", "w450 h160")
        if (grepInput.Result = "Cancel" || grepInput.Value = "")
            return
        searchText := grepInput.Value
    }
    
    searchText := Trim(searchText)
    if (searchText = "")
        return
    
    ; Search both sources
    jsonResults := CC_GrepJSON(searchText)
    legacyResults := CC_GrepLegacyAHK(searchText)
    
    ; Show combined results in browser-style window
    CC_GrepShowBrowser(searchText, jsonResults, legacyResults, parentGui)
}

; ==============================================================================
; SEARCH JSON CAPTURES
; ==============================================================================

CC_GrepJSON(searchText) {
    global CaptureData, CaptureNames
    results := []
    searchLower := StrLower(searchText)
    
    if !IsSet(CaptureNames) || !IsSet(CaptureData)
        return results
    
    for name in CaptureNames {
        cap := CaptureData.Has(name) ? CaptureData[name] 
             : CaptureData.Has(StrLower(name)) ? CaptureData[StrLower(name)] 
             : ""
        if (cap = "")
            continue
        
        ; Search ALL fields
        matchField := ""
        if InStr(StrLower(name), searchLower)
            matchField := "Name"
        else if InStr(StrLower(cap.Has("url") ? cap["url"] : ""), searchLower)
            matchField := "URL"
        else if InStr(StrLower(cap.Has("title") ? cap["title"] : ""), searchLower)
            matchField := "Title"
        else if InStr(StrLower(cap.Has("body") ? cap["body"] : ""), searchLower)
            matchField := "Body"
        else if InStr(StrLower(cap.Has("opinion") ? cap["opinion"] : ""), searchLower)
            matchField := "Opinion"
        else if InStr(StrLower(cap.Has("note") ? cap["note"] : ""), searchLower)
            matchField := "Note"
        else if InStr(StrLower(cap.Has("tags") ? cap["tags"] : ""), searchLower)
            matchField := "Tags"
        else if InStr(StrLower(cap.Has("research") ? cap["research"] : ""), searchLower)
            matchField := "Research"
        else
            continue
        
        result := Map()
        result["name"] := name
        result["source"] := "JSON"
        result["matchField"] := matchField
        result["title"] := cap.Has("title") ? cap["title"] : ""
        result["url"] := cap.Has("url") ? cap["url"] : ""
        result["content"] := ""
        if cap.Has("body")
            result["content"] .= cap["body"]
        if cap.Has("opinion") && cap["opinion"] != ""
            result["content"] .= "`n" cap["opinion"]
        results.Push(result)
        
        if (results.Length >= CC_GrepConfig.MaxResultsPerSource)
            break
    }
    return results
}

; ==============================================================================
; SEARCH LEGACY .AHK FILES — Robust line-by-line grep
; ==============================================================================
; Strategy: Find every matching line, then backtrack to find the nearest
; ::hotstring:: definition above it. This catches matches inside stline blocks,
; _content() functions, run commands, and anywhere else in the file.
; ==============================================================================

CC_GrepLegacyAHK(searchText) {
    results := []
    searchLower := StrLower(searchText)
    foundNames := Map()  ; Deduplicate by hotstring name
    
    for filePath in CC_GrepConfig.LegacyFiles {
        if !FileExist(filePath)
            continue
        
        SplitPath(filePath, &fileName)
        
        try {
            fileContent := FileRead(filePath)
        } catch {
            continue
        }
        
        lines := StrSplit(fileContent, "`n", "`r")
        totalLines := lines.Length
        
        ; STEP 1: Find every line that matches the search text
        matchingLineNums := []
        for lineNum, line in lines {
            if InStr(StrLower(line), searchLower)
                matchingLineNums.Push(lineNum)
        }
        
        ; STEP 2: For each match, backtrack to find nearest ::hotstring::
        for idx, matchLine in matchingLineNums {
            hotstringName := ""
            hotstringLineNum := 0
            funcBaseName := ""
            
            ; Walk backwards from the match line
            searchLine := matchLine
            while (searchLine >= 1) {
                ; Check for ::hotstring:: pattern
                if RegExMatch(lines[searchLine], "^::(\w+)::", &m) {
                    hotstringName := m[1]
                    hotstringLineNum := searchLine
                    break
                }
                ; Check for function pattern: name_content() or nameFunc()
                if (funcBaseName = "" && RegExMatch(lines[searchLine], "^(\w+?)(?:_content|Func|_title|EmailFunc)\s*\(", &fm)) {
                    funcBaseName := fm[1]
                }
                searchLine--
            }
            
            ; Use function base name if no hotstring found
            if (hotstringName = "" && funcBaseName != "")
                hotstringName := funcBaseName
            if (hotstringName = "")
                continue
            
            ; Find the base name (strip suffixes like r, em, m, t)
            baseName := hotstringName
            if RegExMatch(baseName, "^(.{3,}?)(em|r\.|r|m|t|go|c)$", &sm)
                baseName := sm[1]
            
            ; Deduplicate: skip if we already found this base name
            if foundNames.Has(baseName)
                continue
            foundNames[baseName] := true
            
            ; STEP 3: Extract title, URL, and context
            title := ""
            url := ""
            contextParts := []
            
            ; Scan forward from the hotstring to gather content
            scanStart := (hotstringLineNum > 0) ? hotstringLineNum : Max(1, matchLine - 10)
            scanEnd := Min(totalLines, scanStart + 50)
            
            loop (scanEnd - scanStart + 1) {
                i := scanStart + A_Index - 1
                if (i > totalLines)
                    break
                ln := Trim(lines[i])
                
                ; Stop at the NEXT unrelated hotstring
                if (A_Index > 1 && RegExMatch(ln, "^::(\w+)::", &nextM)) {
                    if !InStr(nextM[1], baseName)
                        break
                }
                
                ; Extract URL from plain text lines
                if (url = "" && RegExMatch(ln, "(https?://\S+)", &urlM)) {
                    url := urlM[1]
                }
                
                ; Extract URL from return statements: return "...http://..."
                if (url = "") {
                    urlPos := RegExMatch(ln, "https?://\S+", &retUrlM)
                    if (urlPos > 0)
                        url := retUrlM[0]
                }
                
                ; Extract title: first real content line (not code)
                if (title = "") {
                    if (ln != "" 
                        && !RegExMatch(ln, "^(::|\(|\)|stline|clipw|return|run |sleep|send|msgbox|onesec|SetKey|SetDef|SetWin|SetCon|SetTitle|if |#|;|global|local|\{|\}|functions)")
                        && !RegExMatch(ln, "^\w+(?:Func|_content|_title|EmailFunc)\s*\(")) {
                        title := SubStr(ln, 1, 150)
                    }
                }
                
                ; Extract title from return statement content
                if (title = "") {
                    retPattern := "return\s+" Chr(34) "(.+)"
                    retPos := RegExMatch(ln, retPattern, &retM)
                    if (retPos > 0) {
                        retContent := retM[1]
                        ; Remove URLs and format chars
                        cleanTitle := RegExReplace(retContent, "https?://\S+", "")
                        cleanTitle := StrReplace(cleanTitle, Chr(96) "r", " ")
                        cleanTitle := StrReplace(cleanTitle, Chr(34) Chr(34), Chr(34))
                        cleanTitle := Trim(cleanTitle)
                        if (StrLen(cleanTitle) > 5)
                            title := SubStr(cleanTitle, 1, 150)
                    }
                }
                
                ; Collect context lines (skip boilerplate)
                if (ln != "" 
                    && !RegExMatch(ln, "^(::|\(|\)|stline|clipw|return$|run |sleep|send|onesec|SetKey|SetDef|SetWin|SetCon|\{|\}|;~|#|functions)")
                    && !RegExMatch(ln, "^\w+(?:Func|_content|_title|EmailFunc)\s*\(")) {
                    contextParts.Push(ln)
                }
            }
            
            ; Clean up URL - remove AHK escape chars and trailing junk
            url := StrReplace(url, Chr(96) "r", "")
            url := StrReplace(url, Chr(34) Chr(34), "")
            url := RTrim(url, " )`r`n}")
            url := RTrim(url, Chr(34) Chr(96))
            
            ; Build content snippet
            snippet := ""
            for part in contextParts {
                if (snippet != "")
                    snippet .= " | "
                snippet .= part
                if (StrLen(snippet) > 300)
                    break
            }
            
            result := Map()
            result["name"] := baseName
            result["source"] := fileName
            result["matchField"] := "Line " matchLine
            result["title"] := title
            result["url"] := url
            result["content"] := snippet
            results.Push(result)
            
            if (results.Length >= CC_GrepConfig.MaxResultsPerSource)
                break
        }
        
        if (results.Length >= CC_GrepConfig.MaxResultsPerSource)
            break
    }
    
    return results
}

; ==============================================================================
; RESULTS BROWSER — Browser-style ListView
; ==============================================================================

CC_GrepShowBrowser(searchText, jsonResults, legacyResults, parentGui := "") {
    totalCount := jsonResults.Length + legacyResults.Length
    
    if (totalCount = 0) {
        MsgBox("No matches found for:`n`n" searchText 
            "`n`nSearched JSON captures and " 
            CC_GrepConfig.LegacyFiles.Length " legacy .ahk files.",
            "Deep Search - No Results", "48")
        return
    }
    
    ; Combine results
    allResults := []
    for r in jsonResults
        allResults.Push(r)
    for r in legacyResults
        allResults.Push(r)
    
    grepGui := Gui("+Resize +MinSize750x400", "Deep Search Results - " totalCount " matches")
    grepGui.SetFont("s10")
    
    ; --- Top bar: search + filter ---
    grepGui.Add("Text", "x10 y10", "Search:")
    grepEdit := grepGui.Add("Edit", "x55 y8 w420 vGrepText", searchText)
    grepGui.Add("Button", "x480 y7 w80", "🔍 Search").OnEvent("Click", (*) => CC_GrepReSearch(grepGui))
    
    grepGui.Add("Text", "x570 y10", "Source:")
    sourceFilter := grepGui.Add("DropDownList", "x620 y7 w110 vSourceFilter", 
        ["All Sources", "JSON Only", "Legacy Only"])
    sourceFilter.Choose(1)
    sourceFilter.OnEvent("Change", (*) => CC_GrepApplyFilter(grepGui))
    
    ; Info line
    grepGui.Add("Text", "x10 y38 w720", 
        "Double-click to open URL | " totalCount " results (" 
        jsonResults.Length " JSON, " legacyResults.Length " legacy)")
    
    ; --- ListView ---
    lv := grepGui.Add("ListView", "x10 y60 w720 h320 vGrepList Grid", 
        ["Source", "Name", "Title", "Matched In", "URL"])
    lv.ModifyCol(1, 90)
    lv.ModifyCol(2, 110)
    lv.ModifyCol(3, 270)
    lv.ModifyCol(4, 80)
    lv.ModifyCol(5, 155)
    
    ; Store data
    grepGui.allResults := allResults
    grepGui.jsonResults := jsonResults
    grepGui.legacyResults := legacyResults
    
    ; Populate
    CC_GrepPopulateList(grepGui, allResults)
    
    ; Events
    lv.OnEvent("DoubleClick", (*) => CC_GrepOpenURL(grepGui))
    
    ; --- Button row ---
    grepGui.Add("Button", "x10 y390 w60", "🌐 Open").OnEvent("Click", (*) => CC_GrepOpenURL(grepGui))
    grepGui.Add("Button", "x75 y390 w60", "📋 Copy").OnEvent("Click", (*) => CC_GrepCopyResult(grepGui))
    grepGui.Add("Button", "x140 y390 w65", "📖 Read").OnEvent("Click", (*) => CC_GrepViewDetail(grepGui))
    grepGui.Add("Button", "x210 y390 w80", "📧 Use Name").OnEvent("Click", (*) => CC_GrepCopyName(grepGui))
    grepGui.Add("Button", "x295 y390 w60", "🔗 Link").OnEvent("Click", (*) => CC_GrepCopyURL(grepGui))
    grepGui.Add("Button", "x570 y390 w70", "❓ Help").OnEvent("Click", (*) => CC_GrepShowHelp())
    grepGui.Add("Button", "x645 y390 w85", "Close").OnEvent("Click", (*) => grepGui.Destroy())
    
    ; Status
    grepGui.grepStatus := grepGui.Add("Text", "x10 y420 w720", 
        "Showing " totalCount " | Enter=Re-search | Double-click=Open URL")
    
    ; Keyboard
    grepGui.OnEvent("Close", (*) => grepGui.Destroy())
    grepGui.OnEvent("Escape", (*) => grepGui.Destroy())
    
    HotIfWinActive("ahk_id " grepGui.Hwnd)
    Hotkey("Enter", (*) => CC_GrepReSearch(grepGui), "On")
    Hotkey("^g", (*) => grepEdit.Focus(), "On")
    HotIf()
    
    grepGui.Show("w740 h445")
    
    if (parentGui != "") {
        try {
            parentGui.GetPos(&px, &py)
            grepGui.Move(px + 30, py + 30)
        }
    }
}

CC_GrepPopulateList(grepGui, results) {
    lv := grepGui["GrepList"]
    lv.Delete()
    for result in results {
        sourceLabel := (result["source"] = "JSON") ? "📋 JSON" : "📁 " result["source"]
        lv.Add(, sourceLabel, result["name"],
            result["title"] != "" ? result["title"] : "(no title)",
            result["matchField"],
            result["url"])
    }
}

; ==============================================================================
; ACTION HANDLERS
; ==============================================================================

CC_GrepReSearch(grepGui) {
    searchText := grepGui["GrepText"].Value
    if (searchText = "")
        return
    grepGui.Destroy()
    CC_GrepAll(searchText)
}

CC_GrepApplyFilter(grepGui) {
    filter := grepGui["SourceFilter"].Text
    filtered := []
    if (filter = "All Sources" || filter = "JSON Only") {
        for r in grepGui.jsonResults
            filtered.Push(r)
    }
    if (filter = "All Sources" || filter = "Legacy Only") {
        for r in grepGui.legacyResults
            filtered.Push(r)
    }
    grepGui.allResults := filtered
    CC_GrepPopulateList(grepGui, filtered)
    grepGui.grepStatus.Value := "Showing " filtered.Length " results"
}

CC_GrepGetSelectedResult(grepGui) {
    lv := grepGui["GrepList"]
    row := lv.GetNext(0, "F")
    if (row = 0) {
        MsgBox("Select a result first.", "No Selection", "48")
        return ""
    }
    if (row > grepGui.allResults.Length)
        return ""
    return grepGui.allResults[row]
}

CC_GrepOpenURL(grepGui) {
    result := CC_GrepGetSelectedResult(grepGui)
    if (result = "")
        return
    if (result["url"] != "") {
        try {
            Run(result["url"])
        }
    } else {
        MsgBox("No URL found for this result.", "No URL", "48")
    }
}

CC_GrepCopyResult(grepGui) {
    result := CC_GrepGetSelectedResult(grepGui)
    if (result = "")
        return
    
    if (result["source"] = "JSON") {
        global CaptureData
        name := result["name"]
        cap := CaptureData.Has(name) ? CaptureData[name] 
             : CaptureData.Has(StrLower(name)) ? CaptureData[StrLower(name)] 
             : ""
        if (cap != "") {
            content := ""
            if cap.Has("title")
                content .= cap["title"] "`n"
            if cap.Has("url")
                content .= cap["url"] "`n"
            if cap.Has("body")
                content .= "`n" cap["body"]
            if cap.Has("opinion") && cap["opinion"] != ""
                content .= "`n`n" cap["opinion"]
            A_Clipboard := content
            ClipWait(1)
            TrayTip("Copied!", name, "1")
            return
        }
    }
    
    ; Legacy or fallback
    content := ""
    if (result["title"] != "")
        content .= result["title"] "`n"
    if (result["url"] != "")
        content .= result["url"] "`n"
    if (result["content"] != "")
        content .= "`n" result["content"]
    A_Clipboard := content
    ClipWait(1)
    TrayTip("Copied!", result["name"], "1")
}

CC_GrepCopyName(grepGui) {
    result := CC_GrepGetSelectedResult(grepGui)
    if (result = "")
        return
    A_Clipboard := result["name"]
    ClipWait(1)
    TrayTip("Hotstring name copied!", result["name"] "`nType  " result["name"] "  to use it", "1")
}

CC_GrepCopyURL(grepGui) {
    result := CC_GrepGetSelectedResult(grepGui)
    if (result = "")
        return
    if (result["url"] = "") {
        MsgBox("No URL found for this result.", "No URL", "48")
        return
    }
    A_Clipboard := result["url"]
    ClipWait(1)
    TrayTip("URL Copied!", result["url"], "1")
}

CC_GrepViewDetail(grepGui) {
    result := CC_GrepGetSelectedResult(grepGui)
    if (result = "")
        return
    
    detail := "HOTSTRING NAME:  " result["name"] "`n"
    detail .= "SOURCE:          " result["source"] "`n"
    detail .= "MATCHED IN:      " result["matchField"] "`n"
    detail .= "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
    
    if (result["url"] != "")
        detail .= "URL: " result["url"] "`n`n"
    if (result["title"] != "")
        detail .= "TITLE: " result["title"] "`n`n"
    
    if (result["source"] = "JSON") {
        global CaptureData
        name := result["name"]
        cap := CaptureData.Has(name) ? CaptureData[name] 
             : CaptureData.Has(StrLower(name)) ? CaptureData[StrLower(name)] 
             : ""
        if (cap != "") {
            if cap.Has("body") && cap["body"] != ""
                detail .= "BODY:`n" cap["body"] "`n`n"
            if cap.Has("opinion") && cap["opinion"] != ""
                detail .= "OPINION:`n" cap["opinion"] "`n`n"
            if cap.Has("note") && cap["note"] != ""
                detail .= "NOTE:`n" cap["note"] "`n`n"
            if cap.Has("tags") && cap["tags"] != ""
                detail .= "TAGS: " cap["tags"] "`n"
            if cap.Has("date")
                detail .= "DATE: " cap["date"] "`n"
        }
    } else {
        if (result["content"] != "")
            detail .= "CONTENT:`n" StrReplace(result["content"], " | ", "`n") "`n"
    }
    
    detail .= "`n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━`n"
    detail .= "USE:  Type  " result["name"] "  to paste this content`n"
    detail .= "      Type  " result["name"] "go  to open the URL`n"
    detail .= "      Type  " result["name"] "em  to email it"
    
    detailGui := Gui("+Resize", "Deep Search Detail - " result["name"])
    detailGui.SetFont("s10", "Consolas")
    detailGui.Add("Edit", "x10 y10 w580 h380 ReadOnly Multi VScroll", detail)
    detailGui.Add("Button", "x10 y400 w90", "📋 Copy All").OnEvent("Click", (*) => (A_Clipboard := detail, TrayTip("Copied!", "", "1")))
    detailGui.Add("Button", "x110 y400 w90", "🌐 Open URL").OnEvent("Click", (*) => CC_GrepDetailOpenURL(result))
    detailGui.Add("Button", "x500 y400 w90", "Close").OnEvent("Click", (*) => detailGui.Destroy())
    detailGui.OnEvent("Escape", (*) => detailGui.Destroy())
    detailGui.Show("w600 h440")
}

CC_GrepDetailOpenURL(result) {
    if (result["url"] != "") {
        try {
            Run(result["url"])
        }
    }
}

CC_GrepShowHelp() {
    helpText := "
    (
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  DEEP SEARCH - UNIVERSAL SEARCH
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Deep Search looks through EVERYTHING:
  • Your JSON capture database (newer captures)
  • gramshare.ahk (legacy captures)
  • sharejason.ahk (legacy captures)

WHAT YOU CAN SEARCH:
  • Full or partial URLs
  • YouTube video IDs
  • Keywords or phrases
  • Hotstring names
  • Any text in any capture

RESULTS COLUMNS:
  Source     Where found (JSON or filename)
  Name       The hotstring name
  Title      Page title or content preview
  Matched In Which field or line number
  URL        The captured URL

BUTTONS:
  🌐 Open      Open URL in your browser
  📋 Copy      Copy full content to clipboard
  📖 Read      See all details in a popup
  📧 Use Name  Copy the hotstring name
  🔗 Link      Copy just the URL

SOURCE FILTER:
  All Sources  JSON + legacy results
  JSON Only    Newer JSON captures only
  Legacy Only  gramshare/sharejason only

TIPS:
  • Paste a URL to find its hotstring name
  • Search a video ID like NqPqdi3orzQ
  • Type a keyword to find related captures
  • Double-click any result to open the URL
  • Press Enter to re-search with new text
    )"
    
    MsgBox(helpText, "Deep Search Help", "64")
}
