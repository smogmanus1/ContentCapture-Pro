; ==============================================================================
; ContentCapture Pro - Professional Content Capture & Sharing System
; ==============================================================================
; Author:      Brad
; Version:     4.5 (AHK v2)
; Updated:     2025-12-16
; License:     MIT
;
; NOTE: This file is designed to be #Included from a launcher script.
;       Do NOT add #Requires or #SingleInstance here!
;
; ==============================================================================
; WHAT IS CONTENTCAPTURE PRO?
; ==============================================================================
;
; ContentCapture Pro transforms how you save, organize, and share web content.
; Instead of bookmarks you never revisit or scattered notes, capture any webpage
; with a simple hotkey and recall it instantly by typing a short name.
;
; Think of it as a personal knowledge base that lives at your fingertips —
; accessible from ANY application with just a few keystrokes.
;
; ==============================================================================
; KEY FEATURES AT A GLANCE
; ==============================================================================
;
; 🚀 INSTANT CAPTURE
;    • Press Ctrl+Alt+P on any webpage to capture URL, title, and content
;    • Highlight text before capturing to save specific excerpts
;    • Add tags, notes, and your personal opinion/commentary
;    • Works with Chrome, Firefox, Edge, Brave, and most browsers
;
; ⚡ LIGHTNING-FAST RECALL
;    • Type ::recipe:: anywhere to instantly paste your saved "recipe" capture
;    • No app switching, no searching — just type and it appears
;    • Works in Word, email, social media, chat apps — everywhere you can type
;
; 🔍 POWERFUL SEARCH
;    • Quick Search (Ctrl+Alt+Space): Alfred/Raycast-style instant popup
;    • Full Browser (Ctrl+Alt+B): Search by name, tags, URL, date, or content
;    • Filter by favorites, date range, or specific tags
;
; 📱 SMART SOCIAL SHARING
;    • Auto-detects when you're on Facebook, Twitter/X, Bluesky, LinkedIn, etc.
;    • Warns you when content exceeds platform character limits
;    • Counts characters the way platforms do (URLs = 23 chars on Twitter/Bluesky)
;    • Auto-cleans titles (removes "- YouTube", "| CNN", etc.) to save space
;    • Save shortened versions for future one-click sharing
;
; 🎯 SUFFIX SYSTEM — The Magic Behind the Scenes
;    Every capture gets automatic hotstring variants:
;    • ::name::     → Paste full content
;    • ::name?::    → Show action menu with all options
;    • ::namego::   → Open the original URL in browser
;    • ::nameem::   → Create Outlook email with content
;    • ::namerd::   → Read content in popup window
;    • ::namevi::   → View/Edit the capture
;    • ::namefb::   → Share to Facebook
;    • ::namex::    → Share to Twitter/X
;    • ::namebs::   → Share to Bluesky
;    • ::nameli::   → Share to LinkedIn
;    • ::namemt::   → Share to Mastodon
;
; 🤖 AI INTEGRATION (Optional)
;    • Summarize long articles into key points
;    • Rewrite content for different platforms (Twitter, LinkedIn, etc.)
;    • Improve writing style and clarity
;    • Supports OpenAI, Anthropic Claude, or local Ollama models
;
; ⭐ FAVORITES & ORGANIZATION
;    • Star frequently-used captures for quick access
;    • Tag system for categorization (news, tutorial, reference, etc.)
;    • Tray menu shows your favorites for one-click pasting
;
; 💾 BACKUP & RESTORE
;    • Automatic backups (configurable interval)
;    • Manual backup with one click
;    • Full restore browser to recover from any backup
;    • Plain-text data files you can edit manually if needed
;
; 🎨 BEAUTIFUL INTERFACE
;    • Dark-themed GUIs that are easy on the eyes
;    • Resizable windows with keyboard navigation
;    • Preview pane shows content before pasting
;    • Live character counters for social sharing
;
; 📊 EXPORT OPTIONS
;    • Export all captures to HTML for web viewing
;    • Open data file directly in any text editor
;    • Portable — runs from USB drive, Dropbox, anywhere
;
; ==============================================================================
; WHY USE CONTENTCAPTURE PRO?
; ==============================================================================
;
; PROBLEM: You find great content online but lose track of it
; SOLUTION: Capture it in seconds, recall it forever with a short name
;
; PROBLEM: Copy-pasting to social media is tedious and error-prone
; SOLUTION: Type ::articlebs:: and your content appears, properly formatted
;
; PROBLEM: You hit character limits and have to manually edit every time
; SOLUTION: Smart limits warn you AND remember your shortened versions
;
; PROBLEM: Bookmarks pile up and become useless
; SOLUTION: Searchable captures with tags, notes, and instant recall
;
; PROBLEM: Sharing the same content to multiple platforms is repetitive
; SOLUTION: One capture, multiple sharing suffixes (fb, x, bs, li, mt)
;
; ==============================================================================
; GETTING STARTED (2 MINUTES)
; ==============================================================================
;
; 1. Run the script — first launch opens Setup wizard
; 2. Go to any webpage you want to save
; 3. Press Ctrl+Alt+P
; 4. Give it a short name like "recipe" or "article"
; 5. Now type ::recipe:: anywhere to paste it!
;
; That's it. You're capturing and recalling content like a pro.
;
; ==============================================================================
; CREDITS & ACKNOWLEDGMENTS
; ==============================================================================
;
; AutoHotkey Development Team - https://www.autohotkey.com/
;   The foundation that makes all of this possible. AutoHotkey has empowered
;   millions of users to automate their workflows and take control of their
;   computing experience.
;
; Jack Dunning - Author of "AutoHotkey Applications" & "AutoHotkey Tricks"
;   https://www.computoredge.com/AutoHotkey/
;   His books and tutorials have made AutoHotkey accessible to beginners and
;   experts alike. An invaluable resource for learning practical AHK techniques
;   that you won't find documented elsewhere.
;
; Joe Glines & The Automator - https://www.the-automator.com/
;   Joe's dedication to AutoHotkey education through videos, courses, and the
;   AutoHotkey community has transformed how people approach automation. His
;   practical examples and teaching style have helped countless users unlock
;   the full potential of their computers. The Automator website and YouTube
;   channel remain essential resources for anyone serious about AHK.
;
; Antonio Bueno (atnbueno) - Browser URL capture concepts
;   Original techniques for capturing URLs and content from web browsers
;   that inspired the capture functionality in this script.
;
; The AutoHotkey Forums Community - https://www.autohotkey.com/boards/
;   Countless contributors who share code, answer questions, and push the
;   boundaries of what's possible with AutoHotkey.
;
; Claude AI (Anthropic) - Development assistance
;   AI-assisted development for code optimization and feature implementation.
;
; ==============================================================================
; HOTKEY QUICK REFERENCE
; ==============================================================================
;
; CAPTURE & CREATE
;   Ctrl+Alt+P         Capture current webpage (highlight text first for excerpt)
;   Ctrl+Alt+N         Manual capture (no browser needed)
;   Ctrl+Alt+F         Format selected text into a new capture
;
; SEARCH & BROWSE
;   Ctrl+Alt+Space     Quick Search — fast popup, type to find, Enter to paste
;   Ctrl+Alt+B         Full Browser — search, filter, edit, delete captures
;   Ctrl+Alt+Shift+B   Restore Browser — recover captures from backups
;
; UTILITIES
;   Ctrl+Alt+M         Show main menu with all options
;   Ctrl+Alt+A         AI Assist menu (summarize, rewrite, improve)
;   Ctrl+Alt+E         Email last capture via Outlook
;   Ctrl+Alt+W         Toggle recent captures widget (desktop overlay)
;   Ctrl+Alt+O         Open captures file in text editor
;   Ctrl+Alt+H         Export all captures to HTML file
;   Ctrl+Alt+K         Backup/Restore captures
;   Ctrl+Alt+S         Re-run Setup wizard
;   Ctrl+Alt+R         Reset data file (caution!)
;   Ctrl+Alt+L         Reload script
;   Ctrl+Alt+F12       Show help popup
;
; ==============================================================================
; HOTSTRING SUFFIX REFERENCE
; ==============================================================================
;
; Base hotstring: ::name:: where "name" is your capture's name
;
; SUFFIX    ACTION                      EXAMPLE
; -------   --------------------------  ------------------
; (none)    Paste full content          ::recipe::
; ?         Show action menu            ::recipe?::
; go        Open URL in browser         ::recipego::
; em        Email via Outlook           ::recipeem::
; rd        Read in popup window        ::reciperd::
; vi        View/Edit capture           ::recipevi::
; fb        Share to Facebook           ::recipefb::
; x         Share to Twitter/X          ::recipex::
; bs        Share to Bluesky            ::recipebs::
; li        Share to LinkedIn           ::recipeli::
; mt        Share to Mastodon           ::recipemt::
;
; ==============================================================================
; FILE STRUCTURE
; ==============================================================================
;
; ContentCapture-Pro.ahk      This file — main application logic
; ContentCapture.ahk          Launcher script (add #Requires, #SingleInstance)
; DynamicSuffixHandler.ahk    Handles suffix detection for hotstrings
; ContentCapture_Generated.ahk Auto-generated hotstrings (don't edit manually)
; config.ini                  User settings and preferences
; captures.dat                Your saved captures (plain text, editable)
; captures.idx                Search index for fast lookups
; favorites.txt               List of starred captures
; backups/                    Automatic and manual backups folder
;
; ==============================================================================
; CODE ARCHITECTURE OVERVIEW
; ==============================================================================
;
; This script is organized into logical sections:
;
; 1. CONFIGURATION (lines ~300-380)
;    Global variables, file paths, settings loaded from config.ini
;
; 2. INITIALIZATION (lines ~380-420)
;    Setup wizard, load captures, generate hotstrings, tray menu
;
; 3. HOTKEYS (lines ~420-450)
;    All Ctrl+Alt+X keyboard shortcuts defined here
;
; 4. QUICK SEARCH (lines ~450-650)
;    Alfred/Raycast-style popup search with live filtering
;
; 5. AI INTEGRATION (lines ~650-1100)
;    OpenAI/Anthropic/Ollama API calls for summarize/rewrite
;
; 6. TRAY MENU & FAVORITES (lines ~1100-1300)
;    System tray menu setup, favorites management
;
; 7. SOCIAL MEDIA DETECTION (lines ~1300-1700)
;    Platform detection, character counting, title cleaning
;
; 8. HOTSTRING HANDLERS (lines ~1700-1900)
;    Functions called when user types ::name:: variants
;
; 9. SETUP WIZARD (lines ~1900-2200)
;    First-run configuration, settings UI
;
; 10. DATA STORAGE & INDEXING (lines ~2200-2600)
;     ★ THE SPEED SECRET ★
;     - CaptureData: Hash Map for O(1) instant lookup
;     - CaptureNames: Sorted array for alphabetical browsing
;     - Full-text search across ALL fields (name, title, URL, tags, body)
;     - Handles 10,000+ captures without slowing down
;     - Plain-text storage: human-readable, portable, recoverable
;
; 11. CAPTURE BROWSER (lines ~2600-3600)
;     Full-featured search/browse interface with preview pane
;
; 12. RESTORE BROWSER (lines ~3600-4000)
;     Backup recovery interface
;
; 13. CAPTURE DIALOG (lines ~4000-4600)
;     UI for capturing new content from webpages
;
; 14. SHARING FUNCTIONS (lines ~4600-5000)
;     Email, Facebook, Twitter, Bluesky, etc.
;
; 15. HELP SYSTEM (lines ~5000-5400)
;     Tutorial, tips, quick help popup
;
; ==============================================================================
; UNDERSTANDING THE DATA FORMAT
; ==============================================================================
;
; Captures are stored in captures.dat as INI-style sections:
;
; [recipename]
; url=https://example.com/recipe
; title=Delicious Pasta Recipe
; date=2025-12-16 14:30:00
; tags=food,italian,dinner
; note=Mom's favorite
; opinion=Best pasta I've ever made
; body=<<<BODY
; Full recipe content goes here...
; Multiple lines are supported...
; BODY>>>
; short=Shortened version for social media (optional)
;
; The <<<BODY ... BODY>>> syntax allows multi-line content.
;
; ==============================================================================

; ==============================================================================
; DETERMINE OUR OWN DIRECTORY (works when #Included)
; ==============================================================================
; NOTE: #Requires and #SingleInstance are in the launcher (ContentCapture.ahk)
#Include DynamicSuffixHandler.ahk

global ContentCaptureDir := ""

; This trick gets the directory of THIS file, not the main script
GetContentCaptureDir() {
    ; Use the script's own directory - works for portable installs
    return A_ScriptDir
}

ContentCaptureDir := GetContentCaptureDir()

; ==============================================================================
; GLOBAL CONFIGURATION
; ==============================================================================

global ConfigFile := ContentCaptureDir "\config.ini"
global DataFile := ""
global IndexFile := ""
global LogFile := ""
global BaseDir := ""
global ArchiveDir := ""
global BackupDir := ""

global MaxFileSizeMB := 2
global MaxFileSize := 2097152

global LastCapturedURL := ""
global LastCapturedTitle := ""
global LastCapturedBody := ""

global stline := ""
global clipboardold := ""

; Capture data storage (loaded at startup)
global CaptureData := Map()
global CaptureNames := []

; Social Media Settings
global EnableEmail := 1
global EnableFacebook := 1
global EnableTwitter := 1
global EnableBluesky := 1
global EnableLinkedIn := 0
global EnableMastodon := 0

; Backup Settings
global BackupEnabled := 1
global BackupLocation := ""
global LastBackupDate := ""
global AutoBackupDays := 7

; Widget state
global WidgetGui := ""
global WidgetVisible := false

; AI Integration Settings
global AIEnabled := 0
global AIProvider := "openai"  ; openai, anthropic, ollama
global AIApiKey := ""
global AIModel := "gpt-4o-mini"  ; Default model
global AIOllamaURL := "http://localhost:11434"  ; For local Ollama

; Help popup setting
global ShowHelpOnStartup := false  ; Disabled by default now

; Available tags
global AvailableTags := ["music", "politics", "tutorial", "news", "reference", "funny", "documentary", "tech", "personal", "work", "AI", "programming", "health", "science", "history", "education", "travel", "surveillance", "privacy", "automation", "autohotkey"]

; ==============================================================================
; INITIALIZATION
; ==============================================================================

if !FileExist(ConfigFile) {
    CC_RunSetup()
} else {
    CC_LoadConfig()
}

; Load capture data
CC_LoadCaptureData()

DynamicSuffixHandler.Initialize(CaptureData, CaptureNames)

; Generate static hotstrings file
CC_GenerateHotstringFile()

; Check if backup is needed
CC_CheckAutoBackup()

; Setup tray menu
CC_SetupTrayMenu()

; Show startup notification
TrayTip("ContentCapture Pro v4.5 loaded!`n" CaptureNames.Length " captures available.`nSmart paste detects social media limits!", "ContentCapture Pro", "1")

; Show tutorial for first-time users
if (CCHelp.ShouldShowTutorial()) {
    SetTimer(() => CCHelp.ShowFirstRunTutorial(), -1500)
}

; ==============================================================================
; HOTKEYS
; ==============================================================================

^!Space:: CC_QuickSearch()
^!a:: CC_AIAssistMenu()
^!m:: CC_ShowMainMenu()
^!p:: CC_CaptureContent()
^!n:: CC_ManualCapture()
^!b:: CC_OpenCaptureBrowser()
^!+b:: CC_OpenRestoreBrowser()
^!o:: CC_OpenDataFileInEditor()
^!w:: CC_ToggleRecentWidget()
^!h:: CC_ExportToHTML()
^!k:: CC_BackupCaptures()
^!f:: CC_FormatTextToHotstring()
^!c:: CC_CopyCleanPaste()
^!e:: CC_EmailLastCapture()
^!s:: {
    result := MsgBox("Re-run ContentCapture Pro Setup?", "Settings", "YesNo")
    if (result = "Yes")
        CC_RunSetup()
}
^!r:: CC_ResetDataFile()
^!F12:: CCHelp.ShowQuickHelp()

; ==============================================================================
; QUICK SEARCH POPUP - Alfred/Raycast style instant search
; ==============================================================================
; This is the fastest way to find and paste captures. Press Ctrl+Alt+Space
; and a minimal popup appears. Start typing and results filter in real-time.
;
; KEYBOARD NAVIGATION:
;   Type          Filter results as you type
;   Up/Down       Navigate through results
;   Enter         Paste selected capture
;   Ctrl+Enter    Open URL in browser
;   Escape        Close popup
;
; DESIGN PHILOSOPHY:
;   - Minimal UI: No buttons, no clutter, just search and results
;   - Instant: Results appear as you type (150ms debounce)
;   - Keyboard-first: Never need to touch the mouse
;   - Always on top: Won't lose focus to other windows
;
; WHY IT'S FAST:
;   Unlike the full browser, Quick Search doesn't load previews or extra UI.
;   It's designed for the 80% use case: "I know roughly what I want, 
;   let me find it and paste it in 2 seconds."
; ==============================================================================

; ------------------------------------------------------------------------------
; CC_QuickSearch()
; ------------------------------------------------------------------------------
; PURPOSE: Show the Quick Search popup
; HOTKEY: Ctrl+Alt+Space
; ------------------------------------------------------------------------------
CC_QuickSearch() {
    global CaptureData, CaptureNames
    
    ; Create minimal, centered popup
    searchGui := Gui("+AlwaysOnTop -Caption +Border", "Quick Search")
    searchGui.BackColor := "1a1a2e"
    searchGui.SetFont("s14 cWhite", "Segoe UI")
    
    searchGui.Add("Text", "x15 y10 w500", "🔍 Quick Search - Type to find, Enter to paste")
    
    searchGui.SetFont("s12 c000000")
    searchEdit := searchGui.Add("Edit", "x15 y45 w500 h30 vSearchTerm -E0x200")
    
    searchGui.SetFont("s10 cWhite")
    resultList := searchGui.Add("ListBox", "x15 y85 w500 h250 vSelectedResult Background2d2d44 cWhite")
    
    ; Status bar
    searchGui.SetFont("s9 c888888")
    statusText := searchGui.Add("Text", "x15 y345 w400", "↑↓ Navigate • Enter=Paste • Ctrl+Enter=Open URL • Esc=Close")
    
    ; Store references for event handlers
    searchGui.resultList := resultList
    searchGui.statusText := statusText
    
    ; Populate with recent/favorites first
    CC_PopulateQuickSearch(resultList, "")
    
    ; Real-time search as you type
    searchEdit.OnEvent("Change", (*) => CC_QuickSearchFilter(searchGui, searchEdit, resultList, statusText))
    
    ; Handle Enter key on the edit box
    searchEdit.OnEvent("Focus", (*) => searchGui.hotkeysActive := true)
    
    ; Keyboard navigation
    searchGui.OnEvent("Escape", (*) => searchGui.Destroy())
    searchGui.OnEvent("Close", (*) => searchGui.Destroy())
    
    ; Custom hotkeys for this GUI
    HotIfWinActive("ahk_id " searchGui.Hwnd)
    Hotkey("Enter", (*) => CC_QuickSearchAction(searchGui, resultList, "paste"), "On")
    Hotkey("^Enter", (*) => CC_QuickSearchAction(searchGui, resultList, "go"), "On")
    Hotkey("Up", (*) => CC_QuickSearchNavigate(resultList, -1), "On")
    Hotkey("Down", (*) => CC_QuickSearchNavigate(resultList, 1), "On")
    HotIf()
    
    ; Center on screen
    searchGui.Show("w530 h370")
    
    ; Move to center
    WinGetPos(,, &w, &h, searchGui.Hwnd)
    MonitorGetWorkArea(, &mLeft, &mTop, &mRight, &mBottom)
    xPos := (mRight - mLeft - w) // 2
    yPos := (mBottom - mTop - h) // 3  ; Slightly above center
    searchGui.Move(xPos, yPos)
    
    searchEdit.Focus()
}

CC_PopulateQuickSearch(resultList, filter) {
    global CaptureData, CaptureNames, Favorites
    
    resultList.Delete()
    
    filter := Trim(StrLower(filter))
    matches := []
    
    ; If no filter, show favorites first, then recent
    if (filter = "") {
        ; Add favorites first
        if IsSet(Favorites) && Favorites.Length > 0 {
            for name in Favorites {
                if CaptureData.Has(StrLower(name)) {
                    title := CaptureData[StrLower(name)].Has("title") ? CaptureData[StrLower(name)]["title"] : name
                    matches.Push({name: name, title: title, fav: true})
                }
            }
        }
        
        ; Add recent (first 20)
        count := 0
        for name in CaptureNames {
            if (count >= 20)
                break
            ; Skip if already in favorites
            alreadyAdded := false
            for m in matches {
                if (m.name = name) {
                    alreadyAdded := true
                    break
                }
            }
            if (!alreadyAdded) {
                title := CaptureData[StrLower(name)].Has("title") ? CaptureData[StrLower(name)]["title"] : name
                matches.Push({name: name, title: title, fav: false})
                count++
            }
        }
    } else {
        ; Search by filter
        for name in CaptureNames {
            if InStr(StrLower(name), filter) {
                title := CaptureData[StrLower(name)].Has("title") ? CaptureData[StrLower(name)]["title"] : name
                isFav := IsSet(Favorites) && CC_ArrayContains(Favorites, name)
                matches.Push({name: name, title: title, fav: isFav})
            } else if CaptureData[StrLower(name)].Has("title") && InStr(StrLower(CaptureData[StrLower(name)]["title"]), filter) {
                title := CaptureData[StrLower(name)]["title"]
                isFav := IsSet(Favorites) && CC_ArrayContains(Favorites, name)
                matches.Push({name: name, title: title, fav: isFav})
            } else if CaptureData[StrLower(name)].Has("tags") && InStr(StrLower(CaptureData[StrLower(name)]["tags"]), filter) {
                title := CaptureData[StrLower(name)].Has("title") ? CaptureData[StrLower(name)]["title"] : name
                isFav := IsSet(Favorites) && CC_ArrayContains(Favorites, name)
                matches.Push({name: name, title: title, fav: isFav})
            }
            
            if (matches.Length >= 50)
                break
        }
    }
    
    ; Populate list
    for m in matches {
        star := m.fav ? "⭐ " : "   "
        displayTitle := StrLen(m.title) > 50 ? SubStr(m.title, 1, 47) "..." : m.title
        resultList.Add([star m.name " - " displayTitle])
    }
    
    if (matches.Length > 0)
        resultList.Choose(1)
    
    return matches.Length
}

CC_QuickSearchFilter(searchGui, searchEdit, resultList, statusText) {
    filter := searchEdit.Value
    count := CC_PopulateQuickSearch(resultList, filter)
    statusText.Value := count " matches • ↑↓ Navigate • Enter=Paste • Ctrl+Enter=Open URL"
}

CC_QuickSearchNavigate(resultList, direction) {
    current := resultList.Value
    count := resultList.GetCount()
    
    if (count = 0)
        return
    
    newPos := current + direction
    if (newPos < 1)
        newPos := count
    else if (newPos > count)
        newPos := 1
    
    resultList.Choose(newPos)
}

CC_QuickSearchAction(searchGui, resultList, action) {
    selected := resultList.Value
    if (selected = 0)
        return
    
    text := resultList.GetText(selected)
    ; Extract name from "⭐ name - title" or "   name - title"
    if RegExMatch(text, "^[\s⭐]+(\S+)", &m)
        name := m[1]
    else
        return
    
    searchGui.Destroy()
    
    ; Disable the hotkeys
    HotIf()
    try {
        Hotkey("Enter", "Off")
        Hotkey("^Enter", "Off")
        Hotkey("Up", "Off")
        Hotkey("Down", "Off")
    }
    
    if (action = "paste")
        CC_HotstringPaste(name)
    else if (action = "go")
        CC_HotstringGo(name)
}

CC_ArrayContains(arr, value) {
    for item in arr {
        if (item = value)
            return true
    }
    return false
}

; ==============================================================================
; AI INTEGRATION - Summarize, Rewrite, Improve content with AI
; ==============================================================================
; ContentCapture Pro can optionally use AI to help with your content.
; This is completely optional — the script works perfectly without it.
;
; SUPPORTED AI PROVIDERS:
;   • OpenAI (GPT-4, GPT-4o-mini, etc.) — requires API key from openai.com
;   • Anthropic (Claude) — requires API key from anthropic.com
;   • Ollama (Local AI) — free, runs on your computer, no API key needed
;
; AI FEATURES:
;   • Summarize: Turn long articles into key bullet points
;   • Rewrite for Twitter: Condense to 280 chars with hashtags
;   • Rewrite for LinkedIn: Professional tone, call to action
;   • Improve Writing: Fix grammar, clarity, flow
;   • Custom Prompt: Ask AI anything about your content
;
; SETUP:
;   1. Press Ctrl+Alt+A (AI Assist)
;   2. If not configured, you'll be prompted to set up
;   3. Enter your API key or Ollama URL
;   4. Choose your preferred model
;
; PRIVACY NOTE:
;   When using OpenAI or Anthropic, your content is sent to their servers.
;   If privacy is a concern, use Ollama for 100% local processing.
;
; COST:
;   OpenAI/Anthropic charge per token (word). A typical summarize request
;   costs fractions of a penny. Ollama is completely free.
; ==============================================================================

; ------------------------------------------------------------------------------
; CC_AIAssistMenu()
; ------------------------------------------------------------------------------
; PURPOSE: Show the AI Assist menu with options to process content
; HOTKEY: Ctrl+Alt+A
; ------------------------------------------------------------------------------
CC_AIAssistMenu() {
    global AIEnabled, AIProvider, AIApiKey
    
    ; Check if AI is configured
    if (!AIEnabled || AIApiKey = "") {
        result := MsgBox("AI Integration is not configured yet.`n`nWould you like to set it up now?", "AI Setup Required", "YesNo Icon?")
        if (result = "Yes")
            CC_AISetup()
        return
    }
    
    ; Show AI menu
    aiMenu := Menu()
    aiMenu.Add("📝 Summarize Last Capture", (*) => CC_AIAction("summarize", "last"))
    aiMenu.Add("✨ Generate Better Title", (*) => CC_AIAction("title", "last"))
    aiMenu.Add("🐦 Rewrite for Twitter/X", (*) => CC_AIAction("twitter", "last"))
    aiMenu.Add("💼 Rewrite for LinkedIn", (*) => CC_AIAction("linkedin", "last"))
    aiMenu.Add("✉️ Rewrite for Email", (*) => CC_AIAction("email", "last"))
    aiMenu.Add("🎯 Make More Professional", (*) => CC_AIAction("professional", "last"))
    aiMenu.Add("📋 Extract Key Points", (*) => CC_AIAction("keypoints", "last"))
    aiMenu.Add()
    aiMenu.Add("🔍 AI on Selected Capture...", (*) => CC_AISelectCapture())
    aiMenu.Add()
    aiMenu.Add("⚙️ AI Settings", (*) => CC_AISetup())
    aiMenu.Show()
}

CC_AISetup() {
    global AIEnabled, AIProvider, AIApiKey, AIModel, AIOllamaURL, ConfigFile
    
    setupGui := Gui("+AlwaysOnTop", "AI Integration Setup")
    setupGui.BackColor := "1a1a2e"
    setupGui.SetFont("s10 cWhite", "Segoe UI")
    
    ; Enable checkbox
    setupGui.SetFont("s11 cWhite Bold")
    setupGui.Add("Text", "x20 y20 w400", "🤖 AI Integration Setup")
    setupGui.SetFont("s10 cWhite norm")
    
    setupGui.Add("Text", "x20 y60 w400 cBBBBBB", "Connect to an AI service to summarize, rewrite, and improve your captures.")
    
    enableCheck := setupGui.Add("Checkbox", "x20 y100 w200 vAIEnabled Checked" AIEnabled, "Enable AI Features")
    enableCheck.SetFont("cWhite")
    
    ; Provider selection
    setupGui.Add("Text", "x20 y140 w100", "Provider:")
    providerDrop := setupGui.Add("DropDownList", "x120 y137 w200 vAIProvider Background333355 cWhite", ["openai|OpenAI (GPT)", "anthropic|Anthropic (Claude)", "ollama|Ollama (Local/Free)"])
    
    ; Set current provider
    if (AIProvider = "openai")
        providerDrop.Choose(1)
    else if (AIProvider = "anthropic")
        providerDrop.Choose(2)
    else if (AIProvider = "ollama")
        providerDrop.Choose(3)
    else
        providerDrop.Choose(1)
    
    ; API Key
    setupGui.Add("Text", "x20 y180 w100", "API Key:")
    keyEdit := setupGui.Add("Edit", "x120 y177 w300 vAIApiKey Password Background333355 cWhite", AIApiKey)
    
    setupGui.SetFont("s8 c888888")
    setupGui.Add("Text", "x20 y210 w400", "(Get key: OpenAI→platform.openai.com | Anthropic→console.anthropic.com)")
    setupGui.SetFont("s10 cWhite")
    
    ; Model selection
    setupGui.Add("Text", "x20 y245 w100", "Model:")
    modelEdit := setupGui.Add("Edit", "x120 y242 w200 vAIModel Background333355 cWhite", AIModel)
    setupGui.Add("Text", "x330 y245 w100 c888888", "(e.g. gpt-4o-mini)")
    
    ; Ollama URL (for local)
    setupGui.Add("Text", "x20 y285 w100", "Ollama URL:")
    ollamaEdit := setupGui.Add("Edit", "x120 y282 w300 vAIOllamaURL Background333355 cWhite", AIOllamaURL)
    setupGui.SetFont("s8 c888888")
    setupGui.Add("Text", "x20 y310 w400", "(Only needed for Ollama - default: http://localhost:11434)")
    setupGui.SetFont("s10 cWhite")
    
    ; Privacy notice
    setupGui.Add("Text", "x20 y350 w420 cFFAA00", "⚠️ Note: Cloud AI (OpenAI/Anthropic) sends your content to their servers.`nFor privacy, use Ollama which runs 100% locally on your PC.")
    
    ; Buttons
    saveBtn := setupGui.Add("Button", "x120 y400 w120 h35", "💾 Save")
    saveBtn.OnEvent("Click", (*) => CC_AISaveSettings(setupGui))
    
    cancelBtn := setupGui.Add("Button", "x260 y400 w120 h35", "Cancel")
    cancelBtn.OnEvent("Click", (*) => setupGui.Destroy())
    
    ; Test button
    testBtn := setupGui.Add("Button", "x20 y400 w80 h35", "🧪 Test")
    testBtn.OnEvent("Click", (*) => CC_AITest(setupGui))
    
    setupGui.Show("w460 h460")
}

CC_AISaveSettings(setupGui) {
    global AIEnabled, AIProvider, AIApiKey, AIModel, AIOllamaURL, ConfigFile
    
    saved := setupGui.Submit()
    
    AIEnabled := saved.AIEnabled
    AIApiKey := saved.AIApiKey
    AIModel := saved.AIModel
    AIOllamaURL := saved.AIOllamaURL
    
    ; Parse provider from dropdown
    providerText := saved.AIProvider
    if InStr(providerText, "openai")
        AIProvider := "openai"
    else if InStr(providerText, "anthropic")
        AIProvider := "anthropic"
    else if InStr(providerText, "ollama")
        AIProvider := "ollama"
    
    ; Save to config
    IniWrite(AIEnabled, ConfigFile, "AI", "Enabled")
    IniWrite(AIProvider, ConfigFile, "AI", "Provider")
    IniWrite(AIApiKey, ConfigFile, "AI", "ApiKey")
    IniWrite(AIModel, ConfigFile, "AI", "Model")
    IniWrite(AIOllamaURL, ConfigFile, "AI", "OllamaURL")
    
    MsgBox("AI settings saved!`n`nProvider: " AIProvider "`nModel: " AIModel "`n`nPress Ctrl+Alt+A to use AI features.", "Settings Saved", "Iconi")
}

CC_AITest(setupGui) {
    saved := setupGui.Submit(false)
    
    testProvider := ""
    providerText := saved.AIProvider
    if InStr(providerText, "openai")
        testProvider := "openai"
    else if InStr(providerText, "anthropic")
        testProvider := "anthropic"
    else if InStr(providerText, "ollama")
        testProvider := "ollama"
    
    ; Test the connection
    testPrompt := "Say 'Hello from ContentCapture Pro!' in exactly those words."
    
    result := CC_CallAI(testPrompt, testProvider, saved.AIApiKey, saved.AIModel, saved.AIOllamaURL)
    
    if (result != "" && !InStr(result, "Error:"))
        MsgBox("✅ Connection successful!`n`nAI Response:`n" result, "Test Passed", "Iconi")
    else
        MsgBox("❌ Connection failed!`n`n" result "`n`nPlease check your API key and settings.", "Test Failed", "Icon!")
}

CC_AISelectCapture() {
    global CaptureData, CaptureNames
    
    ; Show a simple selection GUI
    selectGui := Gui("+AlwaysOnTop", "Select Capture for AI")
    selectGui.BackColor := "1a1a2e"
    selectGui.SetFont("s10 cWhite", "Segoe UI")
    
    selectGui.Add("Text", "x20 y20 w300", "Search for a capture:")
    searchBox := selectGui.Add("Edit", "x20 y50 w350 vSearch Background333355 cWhite")
    
    captureList := selectGui.Add("ListBox", "x20 y90 w350 h300 vSelected Background333355 cWhite")
    
    ; Populate with recent captures
    count := 0
    for name in CaptureNames {
        if (count++ > 100)
            break
        title := CaptureData.Has(StrLower(name)) && CaptureData[StrLower(name)].Has("title") ? CaptureData[StrLower(name)]["title"] : ""
        captureList.Add([name " - " SubStr(title, 1, 40)])
    }
    
    ; Search filter
    searchBox.OnEvent("Change", (*) => CC_AIFilterCaptures(selectGui, searchBox, captureList))
    
    ; Action buttons
    selectGui.Add("Button", "x20 y400 w100 h30", "📝 Summarize").OnEvent("Click", (*) => CC_AIOnSelected(selectGui, captureList, "summarize"))
    selectGui.Add("Button", "x130 y400 w100 h30", "✨ Title").OnEvent("Click", (*) => CC_AIOnSelected(selectGui, captureList, "title"))
    selectGui.Add("Button", "x240 y400 w100 h30", "🐦 Twitter").OnEvent("Click", (*) => CC_AIOnSelected(selectGui, captureList, "twitter"))
    
    selectGui.Add("Button", "x20 y440 w100 h30", "💼 LinkedIn").OnEvent("Click", (*) => CC_AIOnSelected(selectGui, captureList, "linkedin"))
    selectGui.Add("Button", "x130 y440 w100 h30", "✉️ Email").OnEvent("Click", (*) => CC_AIOnSelected(selectGui, captureList, "email"))
    selectGui.Add("Button", "x240 y440 w100 h30", "🎯 Polish").OnEvent("Click", (*) => CC_AIOnSelected(selectGui, captureList, "professional"))
    
    selectGui.Show("w390 h490")
}

CC_AIFilterCaptures(selectGui, searchBox, captureList) {
    global CaptureData, CaptureNames
    
    searchTerm := searchBox.Value
    captureList.Delete()
    
    count := 0
    for name in CaptureNames {
        if (count++ > 100)
            break
        
        title := CaptureData.Has(StrLower(name)) && CaptureData[StrLower(name)].Has("title") ? CaptureData[StrLower(name)]["title"] : ""
        
        if (searchTerm = "" || InStr(name, searchTerm) || InStr(title, searchTerm))
            captureList.Add([name " - " SubStr(title, 1, 40)])
    }
}

CC_AIOnSelected(selectGui, captureList, action) {
    if (captureList.Value = 0) {
        MsgBox("Please select a capture first.", "No Selection", "Icon!")
        return
    }
    
    text := captureList.Text
    if RegExMatch(text, "^(\S+)", &m)
        name := m[1]
    else
        return
    
    selectGui.Destroy()
    CC_AIAction(action, name)
}

CC_AIAction(action, target) {
    global CaptureData, CaptureNames, LastCapturedBody, LastCapturedTitle, LastCapturedURL
    global AIEnabled, AIProvider, AIApiKey, AIModel, AIOllamaURL
    
    ; Get the content
    if (target = "last") {
        ; Use last captured content
        if (LastCapturedBody = "") {
            MsgBox("No recent capture found.`n`nCapture something first with Ctrl+Alt+P", "No Content", "Icon!")
            return
        }
        content := LastCapturedBody
        title := LastCapturedTitle
        url := LastCapturedURL
        captureName := ""
    } else {
        ; Use specified capture
        if (!CaptureData.Has(StrLower(target))) {
            MsgBox("Capture '" target "' not found.", "Not Found", "Icon!")
            return
        }
        content := CaptureData[StrLower(target)].Has("body") ? CaptureData[StrLower(target)]["body"] : ""
        title := CaptureData[StrLower(target)].Has("title") ? CaptureData[StrLower(target)]["title"] : ""
        url := CaptureData[StrLower(target)].Has("url") ? CaptureData[StrLower(target)]["url"] : ""
        captureName := target
    }
    
    if (content = "") {
        MsgBox("This capture has no content to process.", "Empty Content", "Icon!")
        return
    }
    
    ; Build the prompt based on action
    prompt := ""
    actionName := ""
    
    switch action {
        case "summarize":
            actionName := "Summary"
            prompt := "Summarize this content in 2-3 concise bullet points. Be direct and informative:`n`n" content
        
        case "title":
            actionName := "Generated Title"
            prompt := "Generate a compelling, concise title (max 10 words) for this content. Return ONLY the title, nothing else:`n`n" content
        
        case "twitter":
            actionName := "Twitter/X Version"
            prompt := "Rewrite this for Twitter/X. Make it engaging, under 280 characters. Include relevant hashtags. Return ONLY the tweet:`n`n" content
        
        case "linkedin":
            actionName := "LinkedIn Version"  
            prompt := "Rewrite this for LinkedIn. Make it professional, insightful, and engaging. Add a call to action. Keep it under 500 characters:`n`n" content
        
        case "email":
            actionName := "Email Version"
            prompt := "Rewrite this as a professional email share. Include a brief intro, the key points, and a closing. Be concise:`n`n" content
        
        case "professional":
            actionName := "Professional Version"
            prompt := "Rewrite this content to be more professional, clear, and polished. Fix any grammar issues. Maintain the core message:`n`n" content
        
        case "keypoints":
            actionName := "Key Points"
            prompt := "Extract the 3-5 most important key points from this content. Be specific and actionable:`n`n" content
    }
    
    ; Show progress
    progressGui := Gui("+AlwaysOnTop -Caption", "AI Working")
    progressGui.BackColor := "1a1a2e"
    progressGui.SetFont("s12 cWhite", "Segoe UI")
    progressGui.Add("Text", "x20 y20 w260 Center", "🤖 AI is thinking...")
    progressGui.Add("Text", "x20 y50 w260 Center c888888", "Processing with " AIProvider)
    progressGui.Show("w300 h90")
    
    ; Call the AI
    result := CC_CallAI(prompt, AIProvider, AIApiKey, AIModel, AIOllamaURL)
    
    progressGui.Destroy()
    
    if (result = "" || InStr(result, "Error:")) {
        MsgBox("AI request failed:`n`n" result, "AI Error", "Icon!")
        return
    }
    
    ; Show result
    CC_AIShowResult(actionName, result, captureName, action)
}

CC_AIShowResult(actionName, result, captureName, action) {
    global CaptureData, DataFile
    
    resultGui := Gui("+AlwaysOnTop", "AI Result: " actionName)
    resultGui.BackColor := "1a1a2e"
    resultGui.SetFont("s10 cWhite", "Segoe UI")
    
    resultGui.SetFont("s12 cWhite Bold")
    resultGui.Add("Text", "x20 y15 w460", "🤖 " actionName)
    resultGui.SetFont("s10 cWhite norm")
    
    ; Result text
    resultEdit := resultGui.Add("Edit", "x20 y50 w460 h200 vResult Background333355 cWhite ReadOnly", result)
    
    ; Buttons
    copyBtn := resultGui.Add("Button", "x20 y270 w100 h35", "📋 Copy")
    copyBtn.OnEvent("Click", (*) => (A_Clipboard := result, ToolTip("Copied!"), SetTimer((*) => ToolTip(), -1500)))
    
    pasteBtn := resultGui.Add("Button", "x130 y270 w100 h35", "📝 Paste")
    pasteBtn.OnEvent("Click", (*) => (resultGui.Destroy(), CC_TypeText(result)))
    
    ; Save to capture (if we have a capture name and it's a title)
    if (captureName != "" && action = "title") {
        saveBtn := resultGui.Add("Button", "x240 y270 w120 h35", "💾 Save as Title")
        saveBtn.OnEvent("Click", (*) => CC_AISaveTitle(resultGui, captureName, result))
    }
    
    closeBtn := resultGui.Add("Button", "x380 y270 w100 h35", "Close")
    closeBtn.OnEvent("Click", (*) => resultGui.Destroy())
    
    resultGui.Show("w500 h320")
}

CC_AISaveTitle(resultGui, captureName, newTitle) {
    global CaptureData, DataFile
    
    if (!CaptureData.Has(StrLower(captureName))) {
        MsgBox("Capture not found.", "Error", "Icon!")
        return
    }
    
    ; Update in memory
    CaptureData[StrLower(captureName)]["title"] := newTitle
    
    ; Save to file
    CC_SaveCaptureData()
    
    resultGui.Destroy()
    MsgBox("Title updated for '" captureName "'!`n`nNew title: " newTitle, "Title Saved", "Iconi")
}

CC_CallAI(prompt, provider, apiKey, model, ollamaURL) {
    ; Prepare the request based on provider
    
    if (provider = "ollama") {
        ; Local Ollama - no API key needed
        url := ollamaURL "/api/generate"
        
        ; Build JSON payload
        payload := '{"model": "' model '", "prompt": "' CC_EscapeJSON(prompt) '", "stream": false}'
        
        try {
            http := ComObject("WinHttp.WinHttpRequest.5.1")
            http.Open("POST", url, false)
            http.SetRequestHeader("Content-Type", "application/json")
            http.Send(payload)
            
            if (http.Status = 200) {
                response := http.ResponseText
                ; Parse Ollama response - look for "response" field
                if RegExMatch(response, '"response"\s*:\s*"([^"]*(?:\\.[^"]*)*)"', &m)
                    return CC_UnescapeJSON(m[1])
                return "Error: Could not parse Ollama response"
            } else {
                return "Error: HTTP " http.Status " - " http.StatusText
            }
        } catch as e {
            return "Error: " e.Message "`n`nMake sure Ollama is running (ollama serve)"
        }
    }
    else if (provider = "openai") {
        url := "https://api.openai.com/v1/chat/completions"
        
        payload := '{"model": "' model '", "messages": [{"role": "user", "content": "' CC_EscapeJSON(prompt) '"}], "max_tokens": 1000}'
        
        try {
            http := ComObject("WinHttp.WinHttpRequest.5.1")
            http.Open("POST", url, false)
            http.SetRequestHeader("Content-Type", "application/json")
            http.SetRequestHeader("Authorization", "Bearer " apiKey)
            http.Send(payload)
            
            if (http.Status = 200) {
                response := http.ResponseText
                ; Parse OpenAI response
                if RegExMatch(response, '"content"\s*:\s*"([^"]*(?:\\.[^"]*)*)"', &m)
                    return CC_UnescapeJSON(m[1])
                return "Error: Could not parse OpenAI response"
            } else {
                return "Error: HTTP " http.Status " - Check your API key"
            }
        } catch as e {
            return "Error: " e.Message
        }
    }
    else if (provider = "anthropic") {
        url := "https://api.anthropic.com/v1/messages"
        
        payload := '{"model": "' model '", "max_tokens": 1000, "messages": [{"role": "user", "content": "' CC_EscapeJSON(prompt) '"}]}'
        
        try {
            http := ComObject("WinHttp.WinHttpRequest.5.1")
            http.Open("POST", url, false)
            http.SetRequestHeader("Content-Type", "application/json")
            http.SetRequestHeader("x-api-key", apiKey)
            http.SetRequestHeader("anthropic-version", "2023-06-01")
            http.Send(payload)
            
            if (http.Status = 200) {
                response := http.ResponseText
                ; Parse Anthropic response
                if RegExMatch(response, '"text"\s*:\s*"([^"]*(?:\\.[^"]*)*)"', &m)
                    return CC_UnescapeJSON(m[1])
                return "Error: Could not parse Anthropic response"
            } else {
                return "Error: HTTP " http.Status " - Check your API key"
            }
        } catch as e {
            return "Error: " e.Message
        }
    }
    
    return "Error: Unknown provider"
}

CC_EscapeJSON(str) {
    str := StrReplace(str, "\", "\\")
    str := StrReplace(str, '"', '\"')
    str := StrReplace(str, "`n", "\n")
    str := StrReplace(str, "`r", "\r")
    str := StrReplace(str, "`t", "\t")
    return str
}

CC_UnescapeJSON(str) {
    str := StrReplace(str, "\n", "`n")
    str := StrReplace(str, "\r", "`r")
    str := StrReplace(str, "\t", "`t")
    str := StrReplace(str, '\"', '"')
    str := StrReplace(str, "\\", "\")
    return str
}

CC_TypeText(text) {
    ; Type the text using SendInput
    oldClip := A_Clipboard
    A_Clipboard := text
    Sleep(50)
    Send("^v")
    Sleep(100)
    A_Clipboard := oldClip
}

; ==============================================================================
; TRAY MENU SETUP
; ==============================================================================

CC_SetupTrayMenu() {
    global CaptureNames, AIEnabled
    
    A_TrayMenu.Delete()
    A_TrayMenu.Add("📚 ContentCapture Pro v4.5", (*) => CC_ShowMainMenu())
    A_TrayMenu.Default := "📚 ContentCapture Pro v4.5"
    A_TrayMenu.Add()
    
    ; Quick actions
    A_TrayMenu.Add("🔍 Quick Search`tCtrl+Alt+Space", (*) => CC_QuickSearch())
    A_TrayMenu.Add("🤖 AI Assist`tCtrl+Alt+A", (*) => CC_AIAssistMenu())
    A_TrayMenu.Add("📷 Capture Webpage`tCtrl+Alt+P", (*) => CC_CaptureContent())
    A_TrayMenu.Add("📝 Manual Capture`tCtrl+Alt+N", (*) => CC_ManualCapture())
    A_TrayMenu.Add("🔎 Browse All`tCtrl+Alt+B", (*) => CC_OpenCaptureBrowser())
    A_TrayMenu.Add()
    
    ; Favorites submenu
    favMenu := Menu()
    global Favorites
    if IsSet(Favorites) && Favorites.Length > 0 {
        for name in Favorites {
            ; Create closure to capture name
            boundName := name
            favMenu.Add("⭐ " name, (*) => CC_HotstringPaste(boundName))
        }
    } else {
        favMenu.Add("(No favorites yet)", (*) => "")
        favMenu.Disable("(No favorites yet)")
    }
    A_TrayMenu.Add("⭐ Favorites", favMenu)
    
    A_TrayMenu.Add()
    A_TrayMenu.Add("💾 Backup/Restore", (*) => CC_BackupCaptures())
    A_TrayMenu.Add("⚙️ Settings", (*) => CC_RunSetup())
    A_TrayMenu.Add("🔄 Reload Script", (*) => Reload())
    A_TrayMenu.Add()
    A_TrayMenu.Add("❌ Exit", (*) => ExitApp())
    
    ; Update icon tooltip
    aiStatus := AIEnabled ? " | AI On" : ""
    A_IconTip := "ContentCapture Pro - " CaptureNames.Length " captures" aiStatus
}

; ==============================================================================
; FAVORITES SYSTEM
; ==============================================================================

global Favorites := []

CC_LoadFavorites() {
    global Favorites, BaseDir
    
    Favorites := []
    favFile := BaseDir "\favorites.txt"
    
    if !FileExist(favFile)
        return
    
    try {
        content := FileRead(favFile, "UTF-8")
        loop parse content, "`n", "`r" {
            if (Trim(A_LoopField) != "")
                Favorites.Push(Trim(A_LoopField))
        }
    }
}

CC_SaveFavorites() {
    global Favorites, BaseDir
    
    favFile := BaseDir "\favorites.txt"
    
    content := ""
    for name in Favorites
        content .= name "`n"
    
    try {
        if FileExist(favFile)
            FileDelete(favFile)
        FileAppend(content, favFile, "UTF-8")
    }
}

CC_ToggleFavorite(name) {
    global Favorites
    
    ; Check if already favorite
    for i, fav in Favorites {
        if (fav = name) {
            Favorites.RemoveAt(i)
            CC_SaveFavorites()
            CC_SetupTrayMenu()  ; Refresh tray menu
            TrayTip("Removed from favorites", name, "1")
            return false
        }
    }
    
    ; Add to favorites
    Favorites.Push(name)
    CC_SaveFavorites()
    CC_SetupTrayMenu()  ; Refresh tray menu
    TrayTip("Added to favorites ⭐", name, "1")
    return true
}

CC_IsFavorite(name) {
    global Favorites
    for fav in Favorites {
        if (fav = name)
            return true
    }
    return false
}

; Load favorites at startup
CC_LoadFavorites()

; ==============================================================================
; STATIC HOTSTRING FILE GENERATION - COMPACT FORMAT
; ==============================================================================

CC_GenerateHotstringFile() {
    global CaptureNames, BaseDir
    
    genFile := BaseDir "\ContentCapture_Generated.ahk"
    
    content := "; Auto-generated hotstrings - DO NOT EDIT`n"
    content .= "; Generated: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n"
    content .= "; Captures: " CaptureNames.Length "`n"
    content .= "; Suffixes (em, vi, go, rd, fb, x, bs, li, mt) handled by DynamicSuffixHandler`n`n"
    
    skipped := 0
    
    for name in CaptureNames {
        ; Skip names over 40 chars (AHK hotstring limit)
        if (StrLen(name) > 40) {
            skipped++
            continue
        }
        
        ; Generate only BASE and ACTION MENU (suffixes handled dynamically)
        content .= "::" name "::{`n    CC_HotstringPaste(`"" name "`")`n}`n"
        content .= "::" name "?::{`n    CC_ShowActionMenu(`"" name "`")`n}`n"
    }
    
    ; Write file
    try {
        if FileExist(genFile)
            FileDelete(genFile)
        FileAppend(content, genFile, "UTF-8")
    } catch as err {
        MsgBox("Could not generate hotstrings file: " err.Message, "Error", "16")
    }
}


; ==============================================================================
; HOTSTRING HANDLER FUNCTIONS (prefixed with CC_ to avoid conflicts)
; ==============================================================================

CC_ShowActionMenu(name, *) {
    global CaptureData

    if !CaptureData.Has(StrLower(name))
        return

    cap := CaptureData[StrLower(name)]
    title := cap.Has("title") ? cap["title"] : name

    if (StrLen(title) > 50)
        title := SubStr(title, 1, 47) "..."

    actionGui := Gui("+AlwaysOnTop +ToolWindow", "Action Menu: " name)
    actionGui.SetFont("s10")
    actionGui.BackColor := "2d2d44"

    actionGui.SetFont("s9 cFFFFFF")
    actionGui.Add("Text", "x10 y10 w280", "📌 " name)
    actionGui.SetFont("s8 cAAAAAA")
    actionGui.Add("Text", "x10 y30 w280", title)

    actionGui.SetFont("s10 cFFFFFF")

    btn1 := actionGui.Add("Button", "x10 y60 w90 h30", "📋 Paste")
    btn1.OnEvent("Click", (*) => (actionGui.Destroy(), CC_HotstringPaste(name)))

    btn2 := actionGui.Add("Button", "x105 y60 w90 h30", "📄 Copy")
    btn2.OnEvent("Click", (*) => (actionGui.Destroy(), CC_HotstringCopy(name)))

    btn3 := actionGui.Add("Button", "x200 y60 w90 h30", "📖 Read")
    btn3.OnEvent("Click", (*) => (actionGui.Destroy(), CC_ShowReadWindow(name)))

    btn4 := actionGui.Add("Button", "x10 y95 w135 h30", "🌐 Open URL")
    btn4.OnEvent("Click", (*) => (actionGui.Destroy(), CC_HotstringGo(name)))

    btn5 := actionGui.Add("Button", "x155 y95 w135 h30", "📧 Email")
    btn5.OnEvent("Click", (*) => (actionGui.Destroy(), CC_HotstringEmail(name)))

    btn6 := actionGui.Add("Button", "x10 y130 w90 h28", "Facebook")
    btn6.OnEvent("Click", (*) => (actionGui.Destroy(), CC_HotstringFacebook(name)))

    btn7 := actionGui.Add("Button", "x105 y130 w90 h28", "Twitter/X")
    btn7.OnEvent("Click", (*) => (actionGui.Destroy(), CC_HotstringTwitter(name)))

    btn8 := actionGui.Add("Button", "x200 y130 w90 h28", "Bluesky")
    btn8.OnEvent("Click", (*) => (actionGui.Destroy(), CC_HotstringBluesky(name)))

    actionGui.SetFont("s8 c888888")
    actionGui.Add("Text", "x10 y168 w280 Center", "Tip: " name "rd = read/edit")

    actionGui.OnEvent("Escape", (*) => actionGui.Destroy())
    actionGui.Show("w300 h195")
}

CC_GetCaptureContent(name) {
    global CaptureData

    if !CaptureData.Has(StrLower(name))
        return ""

    cap := CaptureData[StrLower(name)]

    content := cap.Has("url") ? cap["url"] : ""
    content .= "`n" (cap.Has("title") ? cap["title"] : "")

    if (cap.Has("opinion") && cap["opinion"] != "")
        content .= "`n`n--- My Take ---`n" cap["opinion"]

    if (cap.Has("body") && cap["body"] != "")
        content .= "`n`n" cap["body"]

    return content
}

CC_GetCaptureShortContent(name) {
    global CaptureData

    if !CaptureData.Has(StrLower(name))
        return ""

    cap := CaptureData[StrLower(name)]
    
    ; If short version exists, use it with URL
    if (cap.Has("short") && cap["short"] != "") {
        content := cap.Has("url") ? cap["url"] "`n" : ""
        content .= cap["short"]
        return content
    }
    
    ; Fallback to regular content
    return ""
}

; ==============================================================================
; SOCIAL MEDIA DETECTION & CHARACTER COUNTING
; ==============================================================================
; These functions handle smart social media integration:
; 1. Detect when user is on a social platform (by window title)
; 2. Count characters the way platforms actually count them
; 3. Clean titles to save precious characters
; 4. Show edit window when content exceeds limits
; ==============================================================================

; ------------------------------------------------------------------------------
; CC_DetectSocialMedia()
; ------------------------------------------------------------------------------
; PURPOSE: Detect if the active window is a social media site
; 
; HOW IT WORKS:
;   - Reads the active window's title bar text
;   - Checks against known patterns for social platforms
;   - Returns the platform identifier (e.g., "bsky.app", "x.com")
;   - Returns empty string "" if not on social media
;
; WHY WINDOW TITLE?
;   Using WinGetTitle() is non-invasive and fast. The alternative would be
;   to focus the address bar (Ctrl+L), copy the URL, then restore focus —
;   but that's slow, visible to the user, and can cause issues.
;
; RETURNS: Platform identifier string or ""
; ------------------------------------------------------------------------------
CC_DetectSocialMedia() {
    ; Check window title for social media sites - non-invasive method
    ; This avoids the Ctrl+L address bar issue
    
    static socialPatterns := [
        {pattern: "Bluesky", name: "bsky.app"},
        {pattern: "bsky.app", name: "bsky.app"},
        {pattern: " / X", name: "x.com"},
        {pattern: "x.com", name: "x.com"},
        {pattern: "Twitter", name: "x.com"},
        {pattern: "Facebook", name: "facebook.com"},
        {pattern: "Mastodon", name: "mastodon"},
        {pattern: "LinkedIn", name: "linkedin.com"},
        {pattern: "Threads", name: "threads.net"},
        {pattern: "Reddit", name: "reddit.com"},
        {pattern: "Truth Social", name: "truthsocial.com"},
        {pattern: "Gab", name: "gab.com"},
        {pattern: "Tumblr", name: "tumblr.com"},
        {pattern: "GETTR", name: "gettr.com"}
    ]
    
    ; Get the active window title
    try {
        winTitle := WinGetTitle("A")
        
        ; Check if title matches any social media pattern
        for item in socialPatterns {
            if InStr(winTitle, item.pattern)
                return item.name
        }
    }
    
    return ""
}

; ------------------------------------------------------------------------------
; CC_GetSocialMediaLimit(site)
; ------------------------------------------------------------------------------
; PURPOSE: Get the character limit for a social media platform
;
; PARAMETERS:
;   site - Platform identifier (e.g., "bsky.app", "x.com")
;
; RETURNS: Integer character limit, or 0 if unknown platform
;
; NOTE: These limits are current as of 2025. Platforms may change them.
; ------------------------------------------------------------------------------
; Get character limit for detected social media platform
CC_GetSocialMediaLimit(site) {
    static limits := Map(
        "bsky.app", 300,         ; Bluesky: 300 characters
        "x.com", 280,            ; Twitter/X: 280 characters
        "twitter.com", 280,      ; Twitter legacy
        "facebook.com", 63206,   ; Facebook: 63,206 characters (rarely an issue)
        "mastodon", 500,         ; Mastodon: typically 500 (varies by instance)
        "linkedin.com", 3000,    ; LinkedIn posts: 3,000 characters
        "threads.net", 500,      ; Threads: 500 characters
        "reddit.com", 40000,     ; Reddit posts: 40,000 characters
        "truthsocial.com", 500,  ; Truth Social: 500 characters
        "gab.com", 3000,         ; Gab: 3,000 characters
        "tumblr.com", 4096,      ; Tumblr: 4,096 characters
        "gettr.com", 750         ; GETTR: 750 characters
    )
    
    return limits.Has(site) ? limits[site] : 0
}

; ------------------------------------------------------------------------------
; CC_CountSocialChars(text, site)
; ------------------------------------------------------------------------------
; PURPOSE: Count characters the way social media platforms actually count them
;
; THE PROBLEM:
;   Twitter and Bluesky don't count URLs by their actual length. A 100-character
;   URL counts as only 23 characters. If we used StrLen(), we'd show the wrong
;   count and confuse users.
;
; THE SOLUTION:
;   1. Find all URLs in the text using regex
;   2. Calculate the difference between actual length and platform length (23)
;   3. Subtract the difference from total length
;
; PARAMETERS:
;   text - The content to count
;   site - Platform identifier (for platform-specific counting rules)
;
; RETURNS: Integer character count as the platform would count it
;
; EXAMPLE:
;   text = "Check this out https://www.youtube.com/watch?v=abc123def456"
;   Actual length: 60 characters
;   URL actual: 47 chars, but Twitter counts as 23
;   Platform count: 60 - (47 - 23) = 36 characters
; ------------------------------------------------------------------------------
; Count characters the way social media platforms do (URLs count as fixed length)
CC_CountSocialChars(text, site) {
    ; URL length as counted by platforms (Bluesky/Twitter treat URLs as ~23 chars)
    ; This is called "t.co wrapping" on Twitter — all URLs become t.co links
    static urlLength := Map(
        "bsky.app", 23,
        "x.com", 23,
        "twitter.com", 23
    )
    
    ; If platform doesn't shorten URLs, return actual length
    if !urlLength.Has(site)
        return StrLen(text)
    
    ; Find and replace URLs with placeholder of correct length
    tempText := text
    urlPattern := "https?://[^\s\]\)]+"  ; Match http:// or https:// until whitespace
    
    ; Count URLs and adjust
    charCount := StrLen(text)
    pos := 1
    while (pos := RegExMatch(text, urlPattern, &match, pos)) {
        actualUrlLen := StrLen(match[0])
        platformUrlLen := urlLength[site]
        charCount -= (actualUrlLen - platformUrlLen)  ; Subtract the difference
        pos += actualUrlLen
    }
    
    return charCount
}

; ------------------------------------------------------------------------------
; CC_CleanTitleForSocial(title)
; ------------------------------------------------------------------------------
; PURPOSE: Remove source website suffixes from titles to save characters
;
; THE PROBLEM:
;   Webpage titles often include the site name at the end:
;   "How to Make Pasta - YouTube"
;   "Breaking News | CNN"
;   "Great Article - The New York Times"
;   
;   These suffixes waste 10-25 characters that could be your actual message!
;
; THE SOLUTION:
;   Automatically strip common suffixes when preparing content for social media.
;   "How to Make Pasta - YouTube" becomes "How to Make Pasta"
;   That's 10 characters saved.
;
; PARAMETERS:
;   title - The original webpage title
;
; RETURNS: Cleaned title with source suffix removed
;
; NOTE: Only removes ONE suffix (the last one found). Suffixes are checked
;       from most specific to least specific to avoid partial matches.
; ------------------------------------------------------------------------------
; Clean title by removing source site suffixes (saves characters for social sharing)
CC_CleanTitleForSocial(title) {
    ; Common suffixes to remove (most specific first)
    ; Order matters! Check longer/more specific patterns before shorter ones
    static suffixes := [
        " - YouTube —",
        " - YouTube—",
        " - YouTube",
        " | YouTube",
        " — YouTube —",
        " — YouTube",
        " - Facebook",
        " | Facebook",
        " - Twitter",
        " | Twitter",
        " / X",
        " on X",
        " - X",
        " | X",
        " - Reddit",
        " | Reddit",
        " - Wikipedia",
        " | Wikipedia",
        " - The New York Times",
        " | The New York Times",
        " - NYT",
        " - CNN",
        " | CNN",
        " - BBC",
        " | BBC",
        " - Fox News",
        " | Fox News",
        " - MSNBC",
        " | MSNBC",
        " - NBC News",
        " - CBS News",
        " - ABC News",
        " - The Washington Post",
        " - The Guardian",
        " | The Guardian",
        " - Forbes",
        " | Forbes",
        " - Reuters",
        " | Reuters",
        " - AP News",
        " - Vimeo",
        " | Vimeo",
        " - TikTok",
        " | TikTok",
        " - Instagram",
        " | Instagram",
        " - LinkedIn",
        " | LinkedIn",
        " - Medium",
        " | Medium",
        " - Substack"
    ]
    
    cleanTitle := title
    for suffix in suffixes {
        ; Check if title ends with this suffix (case-sensitive)
        if (SubStr(cleanTitle, -StrLen(suffix)) = suffix) {
            ; Remove the suffix
            cleanTitle := SubStr(cleanTitle, 1, StrLen(cleanTitle) - StrLen(suffix))
            break  ; Only remove one suffix
        }
    }
    
    return Trim(cleanTitle)
}

; Get friendly name for social media site
CC_GetSocialMediaName(site) {
    static names := Map(
        "bsky.app", "Bluesky",
        "x.com", "X/Twitter",
        "twitter.com", "Twitter",
        "facebook.com", "Facebook",
        "mastodon", "Mastodon",
        "linkedin.com", "LinkedIn",
        "threads.net", "Threads",
        "reddit.com", "Reddit",
        "truthsocial.com", "Truth Social",
        "gab.com", "Gab",
        "tumblr.com", "Tumblr",
        "gettr.com", "GETTR"
    )
    
    return names.Has(site) ? names[site] : site
}

CC_GetCaptureURL(name) {
    global CaptureData

    if !CaptureData.Has(StrLower(name))
        return ""

    return CaptureData[StrLower(name)].Has("url") ? CaptureData[StrLower(name)]["url"] : ""
}

; ==============================================================================
; HOTSTRING HANDLER FUNCTIONS
; ==============================================================================
; These functions are called when users type ::name:: hotstrings.
; Each suffix (go, em, rd, vi, fb, x, bs, etc.) calls a different function.
; ==============================================================================

; ------------------------------------------------------------------------------
; CC_HotstringPaste(name)
; ------------------------------------------------------------------------------
; PURPOSE: The main paste function — called when user types ::name::
;
; SMART BEHAVIOR:
;   1. Detect if user is on a social media site
;   2. If yes, check if a "short" version exists — use it (faster sharing)
;   3. If no short version, check if content exceeds platform limit
;   4. If over limit, show edit window so user can trim content
;   5. If under limit (or not on social media), just paste the content
;
; THIS IS THE MAGIC:
;   The user just types ::article:: and we figure out:
;   - Where they are (Bluesky? Facebook? Word doc?)
;   - What version to use (short? full?)
;   - Whether to warn about limits
;   All automatically, invisibly, instantly.
;
; PARAMETERS:
;   name - The capture name (e.g., "recipe", "article")
; ------------------------------------------------------------------------------
CC_HotstringPaste(name, *) {
    global CaptureData
    
    ; Check if we're on social media
    socialSite := CC_DetectSocialMedia()
    
    ; If on social media and short version exists, use it
    if (socialSite != "") {
        shortContent := CC_GetCaptureShortContent(name)
        if (shortContent != "") {
            A_Clipboard := shortContent
            ClipWait(1)
            SendInput("^v")
            TrayTip("Using short version for " CC_GetSocialMediaName(socialSite), name, "1")
            CCHelp.TipAfterFirstHotstring()
            return
        }
    }
    
    ; Get full content
    content := CC_GetCaptureContent(name)
    if (content = "")
        return
    
    ; If on social media, check character limit
    if (socialSite != "") {
        charLimit := CC_GetSocialMediaLimit(socialSite)
        socialCharCount := CC_CountSocialChars(content, socialSite)
        if (charLimit > 0 && socialCharCount > charLimit) {
            ; Show edit window for content that exceeds limit
            CC_ShowSocialEditWindow(name, content, socialSite, charLimit)
            return
        }
    }

    A_Clipboard := content
    ClipWait(1)
    SendInput("^v")
    
    ; Show tip for new users
    CCHelp.TipAfterFirstHotstring()
}

; Show edit window when content exceeds social media character limit
CC_ShowSocialEditWindow(name, content, socialSite, charLimit) {
    siteName := CC_GetSocialMediaName(socialSite)
    
    ; Auto-clean the content for social sharing
    cleanedContent := CC_CleanContentForSocial(content)
    
    currentLen := CC_CountSocialChars(cleanedContent, socialSite)
    overBy := currentLen - charLimit
    
    editGui := Gui("+AlwaysOnTop", "✂️ Edit for " siteName " - " name)
    editGui.SetFont("s10")
    editGui.BackColor := "1a1a2e"
    
    ; Store data in GUI object for access in event handlers
    editGui.captureName := name
    editGui.socialSite := socialSite
    editGui.charLimit := charLimit
    
    ; Header with limit info
    editGui.SetFont("s11 cWhite")
    editGui.Add("Text", "x15 y10 w550", "📝 Content exceeds " siteName " limit (" charLimit " chars)")
    
    if (overBy > 0)
        editGui.Add("Text", "x15 y32 cFF6B6B", "Current: " currentLen " chars | Over by: " overBy " chars (URLs=23, titles cleaned)")
    else
        editGui.Add("Text", "x15 y32 c00FF00", "Current: " currentLen " chars | Under limit! (URLs=23, titles cleaned)")
    
    ; Edit box - use cleaned content (store reference in GUI)
    editGui.SetFont("s10")
    editGui.contentEdit := editGui.Add("Edit", "x15 y60 w550 h280 vEditedContent Background2d2d44 cWhite", cleanedContent)
    
    ; Character counter (store reference in GUI)
    editGui.SetFont("s10")
    editGui.charCounter := editGui.Add("Text", "x15 y350 w250 cWhite", "Characters: " currentLen "/" charLimit)
    
    ; Update counter on edit - use standalone function
    editGui.contentEdit.OnEvent("Change", CC_SocialEditUpdateCounter)
    
    ; Save as short version checkbox (store reference in GUI)
    editGui.SetFont("s10 cWhite")
    editGui.saveShortChk := editGui.Add("Checkbox", "x15 y375 vSaveShort", "💾 Save as short version for future use")
    
    ; Buttons - use standalone functions
    editGui.SetFont("s10")
    editGui.Add("Button", "x300 y372 w130 h30 Default", "📋 Paste").OnEvent("Click", CC_SocialEditDoPaste)
    editGui.Add("Button", "x440 y372 w120 h30", "Cancel").OnEvent("Click", (*) => editGui.Destroy())
    
    editGui.Show("w580 h415")
}

; Update character counter in social edit window (standalone function)
CC_SocialEditUpdateCounter(ctrl, *) {
    editGui := ctrl.Gui
    len := CC_CountSocialChars(editGui.contentEdit.Value, editGui.socialSite)
    
    if (len > editGui.charLimit)
        editGui.charCounter.Opt("cFF6B6B")  ; Red when over
    else
        editGui.charCounter.Opt("c00FF00")  ; Green when under
    
    editGui.charCounter.Value := "Characters: " len "/" editGui.charLimit
}

; Handle paste button click in social edit window (standalone function)
CC_SocialEditDoPaste(ctrl, *) {
    editGui := ctrl.Gui
    
    ; Get values BEFORE destroying GUI
    editedContent := editGui.contentEdit.Value
    saveName := editGui.captureName
    socialSite := editGui.socialSite
    charLimit := editGui.charLimit
    saveShort := editGui.saveShortChk.Value
    
    editedLen := CC_CountSocialChars(editedContent, socialSite)
    siteName := CC_GetSocialMediaName(socialSite)
    
    ; Check if still over limit
    if (editedLen > charLimit) {
        result := MsgBox("Content still exceeds " siteName " limit by " (editedLen - charLimit) " chars.`n`nPaste anyway?", "Over Limit", "YesNo 48")
        if (result = "No")
            return
    }
    
    ; Save short version if checked (before destroying GUI)
    if (saveShort)
        CC_SaveShortVersion(saveName, editedContent)
    
    ; Destroy GUI
    editGui.Destroy()
    
    ; Small delay to let GUI close and focus return
    Sleep(150)
    
    ; Paste the content
    A_Clipboard := editedContent
    ClipWait(1)
    SendInput("^v")
    
    ; Show confirmation if saved
    if (saveShort)
        TrayTip("Short version saved for future use!", saveName, "1")
}

; Clean entire content for social sharing (clean titles in each line)
CC_CleanContentForSocial(content) {
    lines := StrSplit(content, "`n")
    cleanedLines := []
    
    for line in lines {
        ; Clean title suffixes from lines that look like titles
        cleanedLine := CC_CleanTitleForSocial(line)
        cleanedLines.Push(cleanedLine)
    }
    
    return CC_ArrayJoin(cleanedLines, "`n")
}

; Helper to join array with delimiter
CC_ArrayJoin(arr, delimiter) {
    result := ""
    for i, item in arr {
        if (i > 1)
            result .= delimiter
        result .= item
    }
    return result
}

CC_HotstringCopy(name, *) {
    content := CC_GetCaptureContent(name)
    if (content = "")
        return

    A_Clipboard := content
    ClipWait(1)
    TrayTip("Content copied to clipboard!", name, "1")
}

CC_HotstringGo(name, *) {
    url := CC_GetCaptureURL(name)
    if (url = "")
        return

    try Run(url)
}

CC_HotstringEmail(name, *) {
    content := CC_GetCaptureContent(name)
    if (content = "")
        return

    CC_SendOutlookEmail(content)
}

CC_HotstringFacebook(name, *) {
    content := CC_GetCaptureContent(name)
    if (content = "")
        return

    CC_ShareToFacebook(content)
}

CC_HotstringTwitter(name, *) {
    content := CC_GetCaptureContent(name)
    if (content = "")
        return

    CC_ShareToTwitter(content)
}

CC_HotstringBluesky(name, *) {
    content := CC_GetCaptureContent(name)
    if (content = "")
        return

    CC_ShareToBluesky(content)
}

CC_HotstringLinkedIn(name, *) {
    content := CC_GetCaptureContent(name)
    if (content = "")
        return

    CC_ShareToLinkedIn(content)
}

CC_HotstringMastodon(name, *) {
    content := CC_GetCaptureContent(name)
    if (content = "")
        return

    CC_ShareToMastodon(content)
}

; ==============================================================================
; READ WINDOW
; ==============================================================================

CC_ShowReadWindow(name, *) {
    global CaptureData

    if !CaptureData.Has(StrLower(name))
        return

    cap := CaptureData[StrLower(name)]

    title := cap.Has("title") ? cap["title"] : name
    url := cap.Has("url") ? cap["url"] : ""
    date := cap.Has("date") ? cap["date"] : ""
    tags := cap.Has("tags") ? cap["tags"] : ""
    opinion := cap.Has("opinion") ? cap["opinion"] : ""
    note := cap.Has("note") ? cap["note"] : ""
    body := cap.Has("body") ? cap["body"] : ""

    readGui := Gui("+Resize", "📖 " title)
    readGui.SetFont("s10")
    readGui.BackColor := "FFFEF5"

    readGui.SetFont("s14 bold c333333")
    readGui.Add("Text", "x20 y15 w660", title)

    readGui.SetFont("s9 norm c666666")
    if (date != "")
        readGui.Add("Text", "x20 y45", "📅 " date)
    if (tags != "")
        readGui.Add("Text", "x150 y45", "🏷️ " tags)

    if (url != "") {
        readGui.SetFont("s9 norm c0066CC underline")
        urlText := readGui.Add("Text", "x20 y65 w660", "🔗 " url)
        urlText.OnEvent("Click", (*) => Run(url))
    }

    yPos := (url != "") ? 95 : 75

    if (opinion != "") {
        readGui.SetFont("s10 bold c2E7D32")
        readGui.Add("Text", "x20 y" yPos, "💭 My Take:")
        yPos += 25
        readGui.SetFont("s10 norm c333333")
        readGui.Add("Edit", "x20 y" yPos " w660 h60 ReadOnly -E0x200 Background" readGui.BackColor, opinion)
        yPos += 70
    }

    if (note != "") {
        readGui.SetFont("s10 bold c1565C0")
        readGui.Add("Text", "x20 y" yPos, "📝 Note:")
        yPos += 25
        readGui.SetFont("s10 norm c333333")
        readGui.Add("Edit", "x20 y" yPos " w660 h60 ReadOnly -E0x200 Background" readGui.BackColor, note)
        yPos += 70
    }

    readGui.SetFont("s10 bold c333333")
    readGui.Add("Text", "x20 y" yPos, "📄 Content:")
    yPos += 25

    bodyHeight := 350
    if (opinion != "")
        bodyHeight -= 95
    if (note != "")
        bodyHeight -= 95

    readGui.SetFont("s11 norm c333333", "Segoe UI")
    readGui.Add("Edit", "x20 y" yPos " w660 h" bodyHeight " ReadOnly Multi VScroll -E0x200 BackgroundFFFFFF", body)

    yPos += bodyHeight + 15

    readGui.SetFont("s10")
    readGui.Add("Button", "x20 y" yPos " w80", "Copy All").OnEvent("Click", (*) => CC_CopyReadContent(name))
    readGui.Add("Button", "x105 y" yPos " w80", "Open URL").OnEvent("Click", (*) => (url != "") ? Run(url) : "")
    readGui.Add("Button", "x190 y" yPos " w80", "✏️ Edit").OnEvent("Click", (*) => (readGui.Destroy(), CC_EditCapture(name)))
    readGui.Add("Button", "x580 y" yPos " w100", "Close").OnEvent("Click", (*) => readGui.Destroy())

    winHeight := yPos + 55
    if (winHeight < 400)
        winHeight := 400
    if (winHeight > 700)
        winHeight := 700

    readGui.OnEvent("Close", (*) => readGui.Destroy())
    readGui.OnEvent("Escape", (*) => readGui.Destroy())

    readGui.Show("w700 h" winHeight)
}

CC_CopyReadContent(name) {
    content := CC_GetCaptureContent(name)
    A_Clipboard := content
    ClipWait(1)
    TrayTip("Copied to clipboard!", name, "1")
}

; ==============================================================================
; CONFIGURATION FUNCTIONS
; ==============================================================================

CC_RunSetup() {
    global BaseDir, DataFile, IndexFile, ArchiveDir, BackupDir, LogFile
    global MaxFileSizeMB, MaxFileSize, ConfigFile
    global EnableEmail, EnableFacebook, EnableTwitter, EnableBluesky, EnableLinkedIn, EnableMastodon
    global ContentCaptureDir

    clouds := CC_GetCloudFolders()

    defaultPath := ""
    cloudDetected := ""

    if (clouds.Length > 0) {
        defaultPath := clouds[1]["path"] "\ContentCapture"
        cloudDetected := clouds[1]["name"]
    } else {
        defaultPath := EnvGet("USERPROFILE") "\Documents\ContentCapture"
    }

    setupGui := Gui("+AlwaysOnTop", "ContentCapture Pro - Setup")
    setupGui.SetFont("s11")
    setupGui.BackColor := "1a1a2e"

    setupGui.SetFont("s16 bold cWhite")
    setupGui.Add("Text", "x20 y15 w460 Center", "Welcome to ContentCapture Pro! 🎉")

    setupGui.SetFont("s10 norm cAAAAAA")
    setupGui.Add("Text", "x20 y50 w460 Center", "Capture webpages and recall them instantly with hotstrings.")

    setupGui.SetFont("s12 bold cWhite")
    setupGui.Add("Text", "x20 y90", "📁 Where should we save your captures?")

    if (cloudDetected != "") {
        setupGui.SetFont("s10 norm c00ff00")
        setupGui.Add("Text", "x20 y115", "✓ " cloudDetected " detected!")
    }

    setupGui.Add("Text", "x20 y150 cWhite", "Save captures to:")
    setupGui.SetFont("s10 norm")
    pathEdit := setupGui.Add("Edit", "x20 y175 w350 vFolderPath", defaultPath)
    setupGui.SetFont("s10 norm cWhite")
    browseBtn := setupGui.Add("Button", "x380 y173 w100 h28", "Browse...")
    browseBtn.OnEvent("Click", (*) => CC_BrowseForFolder(pathEdit, clouds))

    setupGui.SetFont("s12 bold cWhite")
    setupGui.Add("Text", "x20 y220", "📤 Sharing options:")

    setupGui.SetFont("s10 norm cWhite")
    cbEmail := setupGui.Add("Checkbox", "x30 y250 Checked", "📧 Email")
    cbFacebook := setupGui.Add("Checkbox", "x130 y250 Checked", "📘 Facebook")
    cbTwitter := setupGui.Add("Checkbox", "x250 y250 Checked", "🐦 Twitter/X")
    cbBluesky := setupGui.Add("Checkbox", "x370 y250 Checked", "🦋 Bluesky")

    setupGui.SetFont("s11")
    okBtn := setupGui.Add("Button", "x150 y300 w100 h35 Default", "Let's Go! ✓")
    okBtn.OnEvent("Click", (*) => CC_FinishSetup(setupGui, pathEdit, cbEmail, cbFacebook, cbTwitter, cbBluesky))

    cancelBtn := setupGui.Add("Button", "x260 y300 w100 h35", "Cancel")
    cancelBtn.OnEvent("Click", (*) => ExitApp())

    setupGui.OnEvent("Close", (*) => ExitApp())
    setupGui.Show("w500 h360")
}

CC_BrowseForFolder(pathEdit, clouds) {
    startPath := ""
    if (clouds.Length > 0) {
        startPath := clouds[1]["path"]
    } else {
        startPath := EnvGet("USERPROFILE") "\Documents"
    }

    folder := DirSelect("*" startPath, 3, "Select folder for your captures:")
    if (folder != "")
        pathEdit.Value := folder
}

CC_FinishSetup(setupGui, pathEdit, cbEmail, cbFacebook, cbTwitter, cbBluesky) {
    global BaseDir, DataFile, IndexFile, ArchiveDir, BackupDir, LogFile
    global MaxFileSizeMB, MaxFileSize
    global EnableEmail, EnableFacebook, EnableTwitter, EnableBluesky

    selectedFolder := Trim(pathEdit.Value)

    if (selectedFolder = "")
        selectedFolder := EnvGet("USERPROFILE") "\Documents\ContentCapture"

    EnableEmail := cbEmail.Value
    EnableFacebook := cbFacebook.Value
    EnableTwitter := cbTwitter.Value
    EnableBluesky := cbBluesky.Value

    BaseDir := selectedFolder
    DataFile := BaseDir "\captures.dat"
    IndexFile := BaseDir "\capture_index.txt"
    ArchiveDir := BaseDir "\archive"
    BackupDir := BaseDir "\backup"
    LogFile := BaseDir "\contentcapture_log.txt"
    MaxFileSizeMB := 2
    MaxFileSize := MaxFileSizeMB * 1024 * 1024

    if !DirExist(BaseDir) {
        try DirCreate(BaseDir)
        catch as err {
            MsgBox("Could not create folder:`n" BaseDir "`n`n" err.Message, "Error", "16")
            return
        }
    }

    if !DirExist(ArchiveDir)
        try DirCreate(ArchiveDir)

    if !DirExist(BackupDir)
        try DirCreate(BackupDir)

    if !FileExist(DataFile)
        try FileAppend("", DataFile, "UTF-8")

    CC_SaveConfig()

    setupGui.Destroy()

    TrayTip("Setup complete!`n`nPress Ctrl+Alt+P to capture.", "ContentCapture Pro", "1")
}

CC_SaveConfig() {
    global ConfigFile, BaseDir, DataFile, IndexFile, ArchiveDir, BackupDir, LogFile, MaxFileSizeMB
    global EnableEmail, EnableFacebook, EnableTwitter, EnableBluesky, EnableLinkedIn, EnableMastodon
    global AvailableTags, BackupLocation, LastBackupDate

    if FileExist(ConfigFile)
        try FileDelete(ConfigFile)

    IniWrite(BaseDir, ConfigFile, "Paths", "BaseDir")
    IniWrite(DataFile, ConfigFile, "Paths", "DataFile")
    IniWrite(IndexFile, ConfigFile, "Paths", "IndexFile")
    IniWrite(ArchiveDir, ConfigFile, "Paths", "ArchiveDir")
    IniWrite(BackupDir, ConfigFile, "Paths", "BackupDir")
    IniWrite(LogFile, ConfigFile, "Paths", "LogFile")
    IniWrite(MaxFileSizeMB, ConfigFile, "Settings", "MaxFileSizeMB")

    IniWrite(EnableEmail, ConfigFile, "SocialMedia", "EnableEmail")
    IniWrite(EnableFacebook, ConfigFile, "SocialMedia", "EnableFacebook")
    IniWrite(EnableTwitter, ConfigFile, "SocialMedia", "EnableTwitter")
    IniWrite(EnableBluesky, ConfigFile, "SocialMedia", "EnableBluesky")
    IniWrite(EnableLinkedIn, ConfigFile, "SocialMedia", "EnableLinkedIn")
    IniWrite(EnableMastodon, ConfigFile, "SocialMedia", "EnableMastodon")

    tagStr := ""
    for tag in AvailableTags
        tagStr .= (tagStr ? "," : "") tag
    IniWrite(tagStr, ConfigFile, "Settings", "AvailableTags")

    IniWrite(BackupLocation, ConfigFile, "Backup", "BackupLocation")
    IniWrite(LastBackupDate, ConfigFile, "Backup", "LastBackupDate")

    IniWrite(FormatTime(, "yyyy-MM-dd HH:mm:ss"), ConfigFile, "Metadata", "LastUpdated")
    IniWrite("3.8", ConfigFile, "Metadata", "Version")
}

CC_LoadConfig() {
    global ConfigFile, BaseDir, DataFile, IndexFile, ArchiveDir, BackupDir, LogFile
    global MaxFileSizeMB, MaxFileSize
    global EnableEmail, EnableFacebook, EnableTwitter, EnableBluesky, EnableLinkedIn, EnableMastodon
    global AvailableTags, BackupLocation, LastBackupDate, ShowHelpOnStartup
    global AIEnabled, AIProvider, AIApiKey, AIModel, AIOllamaURL

    try {
        BaseDir := IniRead(ConfigFile, "Paths", "BaseDir")
        DataFile := IniRead(ConfigFile, "Paths", "DataFile", BaseDir "\captures.dat")
        IndexFile := IniRead(ConfigFile, "Paths", "IndexFile", BaseDir "\capture_index.txt")
        ArchiveDir := IniRead(ConfigFile, "Paths", "ArchiveDir", BaseDir "\archive")
        BackupDir := IniRead(ConfigFile, "Paths", "BackupDir", BaseDir "\backup")
        LogFile := IniRead(ConfigFile, "Paths", "LogFile", BaseDir "\contentcapture_log.txt")
        MaxFileSizeMB := Integer(IniRead(ConfigFile, "Settings", "MaxFileSizeMB", "2"))
        MaxFileSize := MaxFileSizeMB * 1024 * 1024
        
        ShowHelpOnStartup := IniRead(ConfigFile, "Settings", "ShowHelpOnStartup", "0") = "1"

        EnableEmail := Integer(IniRead(ConfigFile, "SocialMedia", "EnableEmail", "1"))
        EnableFacebook := Integer(IniRead(ConfigFile, "SocialMedia", "EnableFacebook", "1"))
        EnableTwitter := Integer(IniRead(ConfigFile, "SocialMedia", "EnableTwitter", "1"))
        EnableBluesky := Integer(IniRead(ConfigFile, "SocialMedia", "EnableBluesky", "1"))
        EnableLinkedIn := Integer(IniRead(ConfigFile, "SocialMedia", "EnableLinkedIn", "0"))
        EnableMastodon := Integer(IniRead(ConfigFile, "SocialMedia", "EnableMastodon", "0"))

        tagStr := IniRead(ConfigFile, "Settings", "AvailableTags", "")
        if (tagStr != "")
            AvailableTags := StrSplit(tagStr, ",")

        BackupLocation := IniRead(ConfigFile, "Backup", "BackupLocation", "")
        LastBackupDate := IniRead(ConfigFile, "Backup", "LastBackupDate", "")
        
        ; AI Integration settings
        AIEnabled := Integer(IniRead(ConfigFile, "AI", "Enabled", "0"))
        AIProvider := IniRead(ConfigFile, "AI", "Provider", "openai")
        AIApiKey := IniRead(ConfigFile, "AI", "ApiKey", "")
        AIModel := IniRead(ConfigFile, "AI", "Model", "gpt-4o-mini")
        AIOllamaURL := IniRead(ConfigFile, "AI", "OllamaURL", "http://localhost:11434")

    } catch as err {
        MsgBox("Error reading config: " err.Message "`n`nRunning setup.", "Config Error", "48")
        CC_RunSetup()
        return
    }

    if !DirExist(BaseDir) {
        result := MsgBox("Directory does not exist:`n" BaseDir "`n`nCreate it?", "Directory Missing", "YesNo")
        if (result = "Yes") {
            try {
                DirCreate(BaseDir)
                if !DirExist(ArchiveDir)
                    DirCreate(ArchiveDir)
                if !DirExist(BackupDir)
                    DirCreate(BackupDir)
            } catch {
                CC_RunSetup()
                return
            }
        } else {
            CC_RunSetup()
            return
        }
    }
}

; ==============================================================================
; DATA STORAGE & INDEXING SYSTEM
; ==============================================================================
; This section handles the core data management that makes ContentCapture Pro
; able to handle thousands of captures with instant lookup and search.
;
; DATA STRUCTURES:
;
;   CaptureData (Map)
;   ─────────────────
;   A hash table mapping lowercase names to capture data.
;   
;   Key: "recipe" (lowercase, for case-insensitive lookup)
;   Value: Map containing:
;     - name     : "Recipe" (original case preserved)
;     - url      : "https://example.com/recipe"
;     - title    : "Best Pasta Recipe Ever"
;     - date     : "2025-12-16 14:30:00"
;     - tags     : "food,italian,dinner"
;     - note     : "Mom's favorite"
;     - opinion  : "Best pasta I've made"
;     - body     : "Full recipe content..."
;     - short    : "Shortened version for social media"
;
;   WHY A MAP?
;   Hash table lookup is O(1) — constant time regardless of size.
;   Whether you have 10 or 10,000 captures, finding ::recipe:: takes
;   the same amount of time (microseconds).
;
;   CaptureNames (Array)
;   ────────────────────
;   An ordered array of all capture names, maintained in alphabetical order.
;   Used for:
;     - Displaying sorted lists in browsers
;     - Iterating through captures in order
;     - Generating hotstrings file
;
; PERFORMANCE:
;
;   Operation             | Time Complexity | 10,000 Captures
;   ──────────────────────|─────────────────|────────────────
;   Hotstring lookup      | O(1)            | ~0.001ms
;   Full-text search      | O(n)            | ~50ms (still instant)
;   Add new capture       | O(n)            | ~10ms (re-sort)
;   Load from disk        | O(n)            | ~100ms at startup
;   Save to disk          | O(n)            | ~100ms
;
; SEARCH STRATEGY:
;
;   When user types in Quick Search or Browser, we search ALL fields:
;   
;   for name in CaptureNames {
;       capture := CaptureData[name]
;       if (InStr(capture["name"], query) ||
;           InStr(capture["title"], query) ||
;           InStr(capture["url"], query) ||
;           InStr(capture["tags"], query) ||
;           InStr(capture["note"], query) ||
;           InStr(capture["opinion"], query) ||
;           InStr(capture["body"], query)) {
;           ; Match found!
;       }
;   }
;
;   This "search everything" approach means users don't need to remember
;   exactly what they named something — any word from any field works.
;
; FILE FORMAT:
;
;   captures.dat uses a simple INI-style format:
;
;   [recipename]
;   url=https://example.com
;   title=My Recipe
;   date=2025-12-16 14:30:00
;   tags=food,cooking
;   note=Family favorite
;   opinion=Delicious!
;   body=<<<BODY
;   Full content here...
;   Can be multiple lines...
;   BODY>>>
;   short=Short version for social
;
;   WHY PLAIN TEXT?
;   - Human-readable and editable
;   - No database dependencies
;   - Easy to backup/sync with Dropbox, Git, etc.
;   - Survives AutoHotkey version changes
;   - Can be recovered even if script breaks
;
; ==============================================================================

; ------------------------------------------------------------------------------
; CC_LoadCaptureData()
; ------------------------------------------------------------------------------
; PURPOSE: Load all captures from disk into memory at startup
;
; PROCESS:
;   1. Read entire file into memory (faster than line-by-line disk reads)
;   2. Parse INI-style sections into Map entries
;   3. Handle multi-line body content with <<<BODY ... BODY>>> markers
;   4. Store in CaptureData Map for O(1) lookup
;   5. Build CaptureNames array for ordered iteration
;
; CALLED: Once at script startup
; PERFORMANCE: ~10ms per 1,000 captures
; ------------------------------------------------------------------------------
CC_LoadCaptureData() {
    global DataFile, CaptureData, CaptureNames

    CaptureData := Map()
    CaptureNames := []

    if !FileExist(DataFile)
        return

    try {
        content := FileRead(DataFile, "UTF-8")

        currentCapture := Map()
        currentName := ""
        inBody := false
        bodyLines := ""

        Loop Parse, content, "`n", "`r" {
            line := A_LoopField

            if RegExMatch(line, "^\[([^\]]+)\]$", &match) {
                if (currentName != "") {
                    if (inBody && bodyLines != "")
                        currentCapture["body"] := RTrim(bodyLines, "`n")
                    CaptureData[StrLower(currentName)] := currentCapture
                    CaptureNames.Push(currentName)
                }

                currentName := match[1]
                currentCapture := Map()
                currentCapture["name"] := currentName
                inBody := false
                bodyLines := ""
                continue
            }

            if (currentName = "")
                continue

            if (SubStr(line, 1, 4) = "url=") {
                currentCapture["url"] := SubStr(line, 5)
            } else if (SubStr(line, 1, 6) = "title=") {
                currentCapture["title"] := SubStr(line, 7)
            } else if (SubStr(line, 1, 5) = "date=") {
                currentCapture["date"] := SubStr(line, 6)
            } else if (SubStr(line, 1, 5) = "tags=") {
                currentCapture["tags"] := SubStr(line, 6)
            } else if (SubStr(line, 1, 5) = "note=") {
                currentCapture["note"] := SubStr(line, 6)
            } else if (SubStr(line, 1, 8) = "opinion=") {
                currentCapture["opinion"] := SubStr(line, 9)
            } else if (SubStr(line, 1, 6) = "short=") {
                currentCapture["short"] := SubStr(line, 7)
            } else if (line = "body=<<<BODY") {
                inBody := true
            } else if (line = "BODY>>>") {
                inBody := false
                if (bodyLines != "")
                    currentCapture["body"] := RTrim(bodyLines, "`n")
            } else if (inBody) {
                bodyLines .= line "`n"
            }
        }

        if (currentName != "") {
            if (inBody && bodyLines != "")
                currentCapture["body"] := RTrim(bodyLines, "`n")
            CaptureData[StrLower(currentName)] := currentCapture
            CaptureNames.Push(currentName)
        }
        
        ; Sort names alphabetically (case-insensitive)
        CC_SortCaptureNames()
    }
}

CC_SaveCaptureData() {
    global DataFile, CaptureData, CaptureNames

    content := "; ContentCapture Pro - Capture Data`n"
    content .= "; Version: 3.8`n"
    content .= "; Updated: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n"
    content .= "; Captures: " CaptureNames.Length "`n`n"

    for name in CaptureNames {
        if !CaptureData.Has(StrLower(name))
            continue

        cap := CaptureData[StrLower(name)]

        content .= "[" name "]`n"

        if (cap.Has("url") && cap["url"] != "")
            content .= "url=" cap["url"] "`n"

        if (cap.Has("title") && cap["title"] != "")
            content .= "title=" cap["title"] "`n"

        if (cap.Has("date") && cap["date"] != "")
            content .= "date=" cap["date"] "`n"

        if (cap.Has("tags") && cap["tags"] != "")
            content .= "tags=" cap["tags"] "`n"

        if (cap.Has("note") && cap["note"] != "")
            content .= "note=" cap["note"] "`n"

        if (cap.Has("opinion") && cap["opinion"] != "")
            content .= "opinion=" cap["opinion"] "`n"

        if (cap.Has("short") && cap["short"] != "")
            content .= "short=" cap["short"] "`n"

        if (cap.Has("body") && cap["body"] != "") {
            content .= "body=<<<BODY`n"
            content .= cap["body"] "`n"
            content .= "BODY>>>`n"
        }

        content .= "`n"
    }

    try {
        if FileExist(DataFile)
            FileDelete(DataFile)
        FileAppend(content, DataFile, "UTF-8")
    } catch as err {
        MsgBox("Could not save data: " err.Message, "Error", "16")
    }

    CC_UpdateIndexFile()
}

; Save short version for a capture (called by DynamicSuffixHandler)
CC_SaveShortVersion(name, shortText) {
    global CaptureData
    
    if (!CaptureData.Has(StrLower(name)))
        return
    
    ; Update the capture with short version
    CaptureData[StrLower(name)]["short"] := shortText
    
    ; Save to disk
    CC_SaveCaptureData()
    
    ToolTip("Short version saved for: " name)
    SetTimer(() => ToolTip(), -2000)
}

CC_AddCapture(name, url, title, date, tags, note, opinion, body) {
    global CaptureData, CaptureNames

    cap := Map()
    cap["name"] := name
    cap["url"] := url
    cap["title"] := title
    cap["date"] := date
    cap["tags"] := tags
    cap["note"] := note
    cap["opinion"] := opinion
    cap["body"] := body

    CaptureData[StrLower(name)] := cap

    found := false
    for n in CaptureNames {
        if (n = name) {
            found := true
            break
        }
    }
    if (!found) {
        CaptureNames.Push(name)
        CC_SortCaptureNames()  ; Keep alphabetical order
    }

    CC_SaveCaptureData()
    CC_GenerateHotstringFile()
    
    ; Show message that reload is needed
    TrayTip("Capture saved! Reloading to activate hotstring...", "ContentCapture Pro", "1")
    Sleep(500)
    Reload()
}

CC_UpdateIndexFile() {
    global IndexFile, CaptureData, CaptureNames

    content := "; ContentCapture Pro - Search Index`n"
    content .= "; Generated: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n"
    content .= "; Captures: " CaptureNames.Length "`n`n"

    for name in CaptureNames {
        if !CaptureData.Has(StrLower(name))
            continue

        cap := CaptureData[StrLower(name)]

        title := cap.Has("title") ? StrReplace(cap["title"], "|", "-") : ""
        date := cap.Has("date") ? cap["date"] : ""
        url := cap.Has("url") ? cap["url"] : ""
        tags := cap.Has("tags") ? cap["tags"] : ""

        content .= name "|" title "|" date "|" url "|" tags "`n"
    }

    try {
        if FileExist(IndexFile)
            FileDelete(IndexFile)
        FileAppend(content, IndexFile, "UTF-8")
    }
}

; ------------------------------------------------------------------------------
; CC_SortCaptureNames()
; ------------------------------------------------------------------------------
; PURPOSE: Sort CaptureNames array alphabetically (case-insensitive)
;
; WHY SORT?
;   - Browser displays in logical order (A-Z)
;   - Quick Search results are consistent
;   - Easier to find captures visually
;   - Generated hotstrings file is organized
;
; ALGORITHM: Simple bubble sort (fast enough for <10,000 items)
; ------------------------------------------------------------------------------
CC_SortCaptureNames() {
    global CaptureNames
    
    n := CaptureNames.Length
    if (n < 2)
        return
    
    ; Bubble sort with case-insensitive comparison
    Loop n - 1 {
        swapped := false
        Loop n - A_Index {
            i := A_Index
            if (StrCompare(CaptureNames[i], CaptureNames[i + 1], true) > 0) {
                ; Swap
                temp := CaptureNames[i]
                CaptureNames[i] := CaptureNames[i + 1]
                CaptureNames[i + 1] := temp
                swapped := true
            }
        }
        if (!swapped)
            break  ; Already sorted
    }
}

; ==============================================================================
; CLOUD DETECTION
; ==============================================================================

CC_GetCloudFolders() {
    clouds := []
    userProfile := EnvGet("USERPROFILE")

    cloudPaths := [
        {name: "Dropbox", paths: [
            userProfile "\Dropbox",
            "C:\Dropbox", "D:\Dropbox", "E:\Dropbox", "F:\Dropbox"
        ]},
        {name: "OneDrive", paths: [
            userProfile "\OneDrive"
        ]},
        {name: "Google Drive", paths: [
            userProfile "\Google Drive",
            "G:\My Drive"
        ]}
    ]

    for cloud in cloudPaths {
        for path in cloud.paths {
            if DirExist(path) {
                cloudInfo := Map()
                cloudInfo["name"] := cloud.name
                cloudInfo["path"] := path
                clouds.Push(cloudInfo)
                break
            }
        }
    }

    return clouds
}

; ==============================================================================
; BACKUP
; ==============================================================================

CC_BackupCaptures() {
    global DataFile, BaseDir, ConfigFile
    
    backupGui := Gui("+AlwaysOnTop", "💾 Backup & Restore")
    backupGui.SetFont("s10")
    backupGui.BackColor := "FFFFFF"
    
    backupGui.Add("Text", "x20 y15 w400", "BACKUP creates a complete copy of all your data.")
    backupGui.Add("Text", "x20 y35 w400", "RESTORE lets you recover from a previous backup.")
    
    backupGui.Add("Text", "x20 y70 cGray", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    btnBackup := backupGui.Add("Button", "x20 y90 w180 h40", "💾 Create Full Backup")
    btnBackup.OnEvent("Click", (*) => (backupGui.Destroy(), CC_CreateFullBackup()))
    
    btnRestore := backupGui.Add("Button", "x210 y90 w180 h40", "📂 Restore from Backup")
    btnRestore.OnEvent("Click", (*) => (backupGui.Destroy(), CC_RestoreFromBackup()))
    
    backupGui.Add("Text", "x20 y145 cGray", "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━")
    
    backupGui.Add("Text", "x20 y165", "Backup includes:")
    backupGui.Add("Text", "x30 y185 c666666", "• captures.dat (all your saved content)")
    backupGui.Add("Text", "x30 y205 c666666", "• ContentCapture_Generated.ahk (hotstrings)")
    backupGui.Add("Text", "x30 y225 c666666", "• config.ini (your settings)")
    
    backupGui.Add("Button", "x150 y260 w100", "Close").OnEvent("Click", (*) => backupGui.Destroy())
    
    backupGui.OnEvent("Escape", (*) => backupGui.Destroy())
    backupGui.Show("w410 h300")
}

CC_CreateFullBackup() {
    global DataFile, BaseDir, ConfigFile
    
    ; Create timestamped backup folder
    timestamp := FormatTime(, "yyyy-MM-dd_HHmmss")
    backupFolder := BaseDir "\backup\backup_" timestamp
    
    try {
        DirCreate(backupFolder)
    } catch {
        MsgBox("Could not create backup folder.", "Error", "16")
        return
    }
    
    filesCopied := 0
    errors := []
    
    ; Backup captures.dat
    if FileExist(DataFile) {
        try {
            FileCopy(DataFile, backupFolder "\captures.dat")
            filesCopied++
        } catch as err {
            errors.Push("captures.dat: " err.Message)
        }
    }
    
    ; Backup generated hotstrings
    genFile := BaseDir "\ContentCapture_Generated.ahk"
    if FileExist(genFile) {
        try {
            FileCopy(genFile, backupFolder "\ContentCapture_Generated.ahk")
            filesCopied++
        } catch as err {
            errors.Push("Generated.ahk: " err.Message)
        }
    }
    
    ; Backup config
    if FileExist(ConfigFile) {
        try {
            FileCopy(ConfigFile, backupFolder "\config.ini")
            filesCopied++
        } catch as err {
            errors.Push("config.ini: " err.Message)
        }
    }
    
    ; Backup main script (for reference)
    mainScript := BaseDir "\ContentCapture-Pro.ahk"
    if FileExist(mainScript) {
        try {
            FileCopy(mainScript, backupFolder "\ContentCapture-Pro.ahk")
            filesCopied++
        } catch as err {
            errors.Push("ContentCapture-Pro.ahk: " err.Message)
        }
    }
    
    ; Create restore instructions
    instructions := "CONTENTCAPTURE PRO BACKUP`n"
    instructions .= "Created: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n"
    instructions .= "=========================================`n`n"
    instructions .= "TO RESTORE:`n"
    instructions .= "1. Use Ctrl+Alt+K > Restore from Backup`n"
    instructions .= "   OR`n"
    instructions .= "2. Copy all files to: " BaseDir "`n`n"
    instructions .= "FILES IN THIS BACKUP:`n"
    instructions .= "- captures.dat (your saved content)`n"
    instructions .= "- ContentCapture_Generated.ahk (hotstrings)`n"
    instructions .= "- config.ini (settings)`n"
    instructions .= "- ContentCapture-Pro.ahk (main script)`n"
    
    try {
        FileAppend(instructions, backupFolder "\README.txt", "UTF-8")
    }
    
    if (errors.Length > 0) {
        errorMsg := ""
        for err in errors
            errorMsg .= err "`n"
        MsgBox("Backup completed with errors:`n`n" errorMsg, "Backup Warning", "48")
    } else {
        msg := "✅ Full backup created!`n`n"
        msg .= "📁 Location:`n" backupFolder "`n`n"
        msg .= "📄 Files backed up: " filesCopied "`n`n"
        msg .= "To restore, use Ctrl+Alt+K > Restore"
        MsgBox(msg, "Backup Complete", "64")
    }
    
    ; Open backup folder
    Run("explorer.exe `"" backupFolder "`"")
}

CC_RestoreFromBackup() {
    global BaseDir, DataFile
    
    backupDir := BaseDir "\backup"
    
    if !DirExist(backupDir) {
        MsgBox("No backup folder found at:`n" backupDir, "No Backups", "48")
        return
    }
    
    ; Find all backup folders
    backups := []
    loop files backupDir "\backup_*", "D" {
        backups.Push({name: A_LoopFileName, path: A_LoopFilePath, time: A_LoopFileTimeModified})
    }
    
    if (backups.Length = 0) {
        MsgBox("No backups found in:`n" backupDir "`n`nCreate a backup first with Ctrl+Alt+K", "No Backups", "48")
        return
    }
    
    ; Sort by time (newest first)
    ; Simple bubble sort for small arrays
    loop backups.Length - 1 {
        i := A_Index
        loop backups.Length - i {
            j := A_Index
            if (backups[j].time < backups[j+1].time) {
                temp := backups[j]
                backups[j] := backups[j+1]
                backups[j+1] := temp
            }
        }
    }
    
    ; Show restore GUI
    restoreGui := Gui("+AlwaysOnTop", "📂 Restore from Backup")
    restoreGui.SetFont("s10")
    restoreGui.BackColor := "FFFFFF"
    
    restoreGui.Add("Text", "x20 y15", "Select a backup to restore:")
    restoreGui.Add("Text", "x20 y35 c666666", "⚠️ This will REPLACE your current data!")
    
    ; Listbox of backups
    backupList := restoreGui.Add("ListBox", "x20 y65 w350 h200 vSelectedBackup")
    
    for backup in backups {
        ; Parse timestamp from folder name
        displayName := backup.name
        if RegExMatch(backup.name, "backup_(\d{4})-(\d{2})-(\d{2})_(\d{2})(\d{2})(\d{2})", &m) {
            displayName := m[2] "/" m[3] "/" m[1] " at " m[4] ":" m[5] ":" m[6]
        }
        backupList.Add([displayName])
    }
    backupList.Choose(1)
    
    ; Store backup paths for later
    restoreGui.backups := backups
    
    btnRestore := restoreGui.Add("Button", "x20 y280 w150 h35", "🔄 Restore Selected")
    btnRestore.OnEvent("Click", (*) => CC_DoRestore(restoreGui, backupList))
    
    btnCancel := restoreGui.Add("Button", "x180 y280 w100 h35", "Cancel")
    btnCancel.OnEvent("Click", (*) => restoreGui.Destroy())
    
    btnOpen := restoreGui.Add("Button", "x290 y280 w80 h35", "📁 Open")
    btnOpen.OnEvent("Click", (*) => Run("explorer.exe `"" backupDir "`""))
    
    restoreGui.OnEvent("Escape", (*) => restoreGui.Destroy())
    restoreGui.Show("w390 h330")
}

CC_DoRestore(restoreGui, backupList) {
    global BaseDir, DataFile, CaptureData, CaptureNames
    
    selected := backupList.Value
    if (selected = 0) {
        MsgBox("Please select a backup to restore.", "No Selection", "48")
        return
    }
    
    backup := restoreGui.backups[selected]
    
    result := MsgBox("Restore from:`n" backup.name "`n`nThis will REPLACE your current data!`n`nContinue?", "Confirm Restore", "YesNo Icon!")
    if (result = "No")
        return
    
    restoreGui.Destroy()
    
    errors := []
    restored := 0
    
    ; Restore captures.dat
    srcCaptures := backup.path "\captures.dat"
    if FileExist(srcCaptures) {
        try {
            if FileExist(DataFile)
                FileDelete(DataFile)
            FileCopy(srcCaptures, DataFile)
            restored++
        } catch as err {
            errors.Push("captures.dat: " err.Message)
        }
    }
    
    ; Restore generated hotstrings
    srcGen := backup.path "\ContentCapture_Generated.ahk"
    destGen := BaseDir "\ContentCapture_Generated.ahk"
    if FileExist(srcGen) {
        try {
            if FileExist(destGen)
                FileDelete(destGen)
            FileCopy(srcGen, destGen)
            restored++
        } catch as err {
            errors.Push("Generated.ahk: " err.Message)
        }
    }
    
    ; Restore config
    srcConfig := backup.path "\config.ini"
    destConfig := BaseDir "\config.ini"
    if FileExist(srcConfig) {
        try {
            if FileExist(destConfig)
                FileDelete(destConfig)
            FileCopy(srcConfig, destConfig)
            restored++
        } catch as err {
            errors.Push("config.ini: " err.Message)
        }
    }
    
    if (errors.Length > 0) {
        errorMsg := ""
        for err in errors
            errorMsg .= err "`n"
        MsgBox("Restore completed with errors:`n`n" errorMsg, "Restore Warning", "48")
    } else {
        msg := "✅ Restore complete!`n`n"
        msg .= "📄 Files restored: " restored "`n`n"
        msg .= "🔄 Reloading script to apply changes..."
        MsgBox(msg, "Restore Complete", "64")
    }
    
    ; Reload to apply restored data
    Reload()
}

CC_CheckAutoBackup() {
    ; Simplified - just check if we have captures
    global CaptureNames
    if (CaptureNames.Length = 0)
        return
}

; ==============================================================================
; MAIN MENU
; ==============================================================================

CC_ShowMainMenu() {
    global CaptureNames, Favorites, AIEnabled

    menuGui := Gui("+AlwaysOnTop", "ContentCapture Pro - Menu")
    menuGui.SetFont("s11")
    menuGui.BackColor := "1a1a2e"

    menuGui.SetFont("s14 bold cWhite")
    menuGui.Add("Text", "x20 y15 w360 Center", "📚 ContentCapture Pro v4.4")

    menuGui.SetFont("s10 norm c888888")
    favCount := IsSet(Favorites) ? Favorites.Length : 0
    aiStatus := AIEnabled ? " | 🤖 AI" : ""
    menuGui.Add("Text", "x20 y45 w360 Center", CaptureNames.Length " captures | " favCount " favorites" aiStatus)

    ; QUICK ACCESS - most important
    menuGui.SetFont("s11 norm cWhite")
    menuGui.Add("Text", "x20 y75", "━━━━━━━━━ QUICK ACCESS ━━━━━━━━━")

    menuGui.SetFont("s10")
    btnQuick := menuGui.Add("Button", "x20 y100 w170 h40", "🔍 SEARCH (Ctrl+Alt+Space)")
    btnQuick.OnEvent("Click", (*) => (menuGui.Destroy(), CC_QuickSearch()))
    
    btnAI := menuGui.Add("Button", "x200 y100 w170 h40", "🤖 AI ASSIST (Ctrl+Alt+A)")
    btnAI.OnEvent("Click", (*) => (menuGui.Destroy(), CC_AIAssistMenu()))

    menuGui.SetFont("s11 cWhite")
    menuGui.Add("Text", "x20 y150", "━━━━━━━━━━━ CAPTURE ━━━━━━━━━━━")

    menuGui.SetFont("s10")
    btn1 := menuGui.Add("Button", "x20 y175 w110 h35", "📷 Webpage")
    btn1.OnEvent("Click", (*) => (menuGui.Destroy(), CC_CaptureFromMenu()))

    btn1b := menuGui.Add("Button", "x135 y175 w110 h35", "📝 Manual")
    btn1b.OnEvent("Click", (*) => (menuGui.Destroy(), CC_ManualCapture()))

    btn2 := menuGui.Add("Button", "x250 y175 w120 h35", "✂️ Format Text")
    btn2.OnEvent("Click", (*) => (menuGui.Destroy(), CC_FormatTextToHotstring()))

    menuGui.SetFont("s11 cWhite")
    menuGui.Add("Text", "x20 y220", "━━━━━━━━━━━ BROWSE ━━━━━━━━━━━")

    menuGui.SetFont("s10")
    btn3 := menuGui.Add("Button", "x20 y245 w110 h35", "🔎 Browse All")
    btn3.OnEvent("Click", (*) => (menuGui.Destroy(), CC_OpenCaptureBrowser()))

    btn3b := menuGui.Add("Button", "x135 y245 w110 h35", "📦 Restore")
    btn3b.OnEvent("Click", (*) => (menuGui.Destroy(), CC_OpenRestoreBrowser()))

    btn4 := menuGui.Add("Button", "x250 y245 w120 h35", "📂 Open File")
    btn4.OnEvent("Click", (*) => (menuGui.Destroy(), CC_OpenDataFileInEditor()))

    menuGui.SetFont("s11 cWhite")
    menuGui.Add("Text", "x20 y290", "━━━━━━━━━━ PROTECT ━━━━━━━━━━")

    menuGui.SetFont("s10")
    btn5 := menuGui.Add("Button", "x20 y315 w170 h35", "💾 Backup/Restore")
    btn5.OnEvent("Click", (*) => (menuGui.Destroy(), CC_BackupCaptures()))

    btn6 := menuGui.Add("Button", "x200 y315 w170 h35", "🔄 Reload Script")
    btn6.OnEvent("Click", (*) => (menuGui.Destroy(), Reload()))

    menuGui.SetFont("s9 c888888")
    menuGui.Add("Text", "x20 y365 w350", "Space=Search, A=AI, P=Webpage, N=Manual, B=Browse")

    menuGui.SetFont("s10 cWhite")
    menuGui.Add("Button", "x130 y395 w130 h30", "Close").OnEvent("Click", (*) => menuGui.Destroy())

    menuGui.OnEvent("Escape", (*) => menuGui.Destroy())
    menuGui.Show("w390 h440")
}

CC_CaptureFromMenu() {
    result := MsgBox("Navigate to the webpage you want to capture, then click OK.", "Ready to Capture?", "OKCancel")
    if (result = "OK")
        CC_CaptureContent()
}

; ==============================================================================
; CAPTURE CONTENT
; ==============================================================================

CC_CaptureContent() {
    global LastCapturedURL, LastCapturedTitle, LastCapturedBody, CaptureData, CaptureNames

    oldClip := ClipboardAll()
    A_Clipboard := ""

    Send("^l")
    Sleep(100)
    Send("^c")
    if !ClipWait(0.5) {
        MsgBox("Could not retrieve URL from browser.", "Error", "16")
        A_Clipboard := oldClip
        return
    }

    url := A_Clipboard
    Send("{Esc}")

    if (url = "") {
        MsgBox("Could not retrieve URL.", "Error", "16")
        A_Clipboard := oldClip
        return
    }

    url := CC_CleanURL(url)

    ; Check for duplicate URL
    for name in CaptureNames {
        if CaptureData.Has(StrLower(name)) && CaptureData[StrLower(name)].Has("url") {
            if (CaptureData[StrLower(name)]["url"] = url) {
                result := MsgBox("This URL has already been captured as:`n`n" name "`n`nCapture anyway?", "Duplicate Detected", "YesNo Icon!")
                if (result = "No") {
                    A_Clipboard := oldClip
                    return
                }
                break
            }
        }
    }

    rawTitle := WinGetTitle("A")
    title := CC_GetPageTitle(rawTitle)
    if (title = "")
        title := "Untitled Page"

    title := CC_CleanContent(title)
    title := CC_CleanTitleForSocial(title)  ; Remove " - YouTube", " | CNN", etc.

    ; Check if YouTube video - offer timestamp option
    if (RegExMatch(url, "i)youtube\.com/watch|youtu\.be/")) {
        ; Remove any existing timestamp from URL first
        url := RegExReplace(url, "[?&]t=\d+", "")
        
        tsResult := MsgBox("This is a YouTube video.`n`nStart from the BEGINNING (recommended)`nor enter a specific start time?`n`nYes = Beginning`nNo = Enter timestamp", "YouTube Timestamp", "YesNo")
        
        if (tsResult = "No") {
            timestamp := InputBox("Enter start time:`n`nExamples: 1:30 (1m 30s) or 1:15:30 (1h 15m 30s)`n`nLeave blank for beginning.", "Start Time", "w300 h150").Value
            
            if (timestamp != "") {
                seconds := CC_ParseTimestamp(timestamp)
                if (seconds > 0) {
                    ; Add timestamp to URL
                    if InStr(url, "?")
                        url .= "&t=" seconds
                    else
                        url .= "?t=" seconds
                }
            }
        }
    }

    result := MsgBox("URL: " url "`n`nTitle: " title "`n`nCapture body text?`n`nYes = Highlight text and press Ctrl+C`nNo = URL + title only", "Ready to Capture", "YesNoCancel")

    if (result = "Cancel") {
        A_Clipboard := oldClip
        return
    }

    bodyText := ""

    if (result = "Yes") {
        A_Clipboard := ""
        if !ClipWait(60) {
            noTextResult := MsgBox("No text copied.`n`nContinue without body text?", "No Selection", "YesNo")
            if (noTextResult = "No") {
                A_Clipboard := oldClip
                return
            }
        } else {
            bodyText := A_Clipboard
            bodyText := CC_CleanContent(bodyText)
        }
    }

    LastCapturedURL := url
    LastCapturedTitle := title
    LastCapturedBody := bodyText

    A_Clipboard := ""
    Sleep(200)

    captureResult := CC_GetCaptureDetailsWithTags()

    if (captureResult.name = "") {
        A_Clipboard := oldClip
        return
    }

    if CaptureData.Has(StrLower(captureResult.name)) {
        result := MsgBox("A capture named '" captureResult.name "' already exists.`n`nOverwrite it?", "Name Exists", "YesNo Icon!")
        if (result = "No") {
            A_Clipboard := oldClip
            return
        }
    }

    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    CC_AddCapture(captureResult.name, url, title, timestamp, captureResult.tags, captureResult.comment, captureResult.opinion, bodyText)

    ; Show helpful tip for new users
    CCHelp.TipAfterFirstCapture(captureResult.name)

    CC_UpdateRecentWidget()

    A_Clipboard := oldClip
}

; ==============================================================================
; MANUAL CAPTURE - Add your own content without browser
; ==============================================================================

CC_ManualCapture() {
    global CaptureData, CaptureNames, AvailableTags
    
    manualGui := Gui("+AlwaysOnTop", "📝 Manual Capture - Add Your Own Content")
    manualGui.SetFont("s10")
    manualGui.BackColor := "FFFFFF"
    
    ; Name (required)
    manualGui.Add("Text", "x20 y15", "Hotstring Name (required, no spaces):")
    nameEdit := manualGui.Add("Edit", "x20 y35 w200 vName")
    manualGui.Add("Text", "x230 y35 cGray", "Example: rule72, mytip, quote1")
    
    ; URL (optional)
    manualGui.Add("Text", "x20 y70", "URL (optional):")
    urlEdit := manualGui.Add("Edit", "x20 y90 w550 vURL")
    
    ; Title (optional)
    manualGui.Add("Text", "x20 y125", "Title (optional - auto-generated if blank):")
    titleEdit := manualGui.Add("Edit", "x20 y145 w550 vTitle")
    
    ; Tags
    manualGui.Add("Text", "x20 y180", "Tags (click to select):")
    tagCheckboxes := []
    xPos := 20
    yPos := 200
    for i, tag in AvailableTags {
        cb := manualGui.Add("Checkbox", "x" xPos " y" yPos " w90", tag)
        tagCheckboxes.Push({cb: cb, tag: tag})
        xPos += 95
        if (Mod(i, 6) = 0) {
            xPos := 20
            yPos += 25
        }
    }
    
    ; Body text (the main content)
    manualGui.Add("Text", "x20 y" (yPos + 35), "Content:")
    manualGui.SetFont("s8")
    formatBtn := manualGui.Add("Button", "x80 y" (yPos + 32) " w90 h22", "🔧 Auto-Format")
    formatBtn.OnEvent("Click", (*) => CC_AutoFormatBody(bodyEdit))
    manualGui.SetFont("s10")
    bodyEdit := manualGui.Add("Edit", "x20 y" (yPos + 55) " w550 h150 vBody Multi WantReturn")
    
    ; Private note
    noteY := yPos + 215
    manualGui.Add("Text", "x20 y" noteY, "Private Note (only you see this):")
    noteEdit := manualGui.Add("Edit", "x20 y" (noteY + 20) " w550 h40 vNote")
    
    ; Opinion (public)
    opinionY := noteY + 70
    manualGui.Add("Text", "x20 y" opinionY, "Opinion (included when you paste):")
    opinionEdit := manualGui.Add("Edit", "x20 y" (opinionY + 20) " w550 h40 vOpinion")
    
    ; Buttons
    btnY := opinionY + 75
    saveBtn := manualGui.Add("Button", "x20 y" btnY " w100 Default", "💾 Save")
    cancelBtn := manualGui.Add("Button", "x130 y" btnY " w100", "Cancel")
    
    ; Help text
    manualGui.Add("Text", "x250 y" btnY " cGray", "After saving, type the name + suffix:`n  name = paste,  namego = open URL,  namevi = edit")
    
    saveBtn.OnEvent("Click", (*) => CC_SaveManualCapture(manualGui, nameEdit, urlEdit, titleEdit, bodyEdit, noteEdit, opinionEdit, tagCheckboxes))
    cancelBtn.OnEvent("Click", (*) => manualGui.Destroy())
    manualGui.OnEvent("Close", (*) => manualGui.Destroy())
    manualGui.OnEvent("Escape", (*) => manualGui.Destroy())
    
    guiHeight := btnY + 70
    manualGui.Show("w590 h" guiHeight)
    nameEdit.Focus()
}

CC_SaveManualCapture(manualGui, nameEdit, urlEdit, titleEdit, bodyEdit, noteEdit, opinionEdit, tagCheckboxes) {
    global CaptureData, CaptureNames
    
    ; Get values
    name := RegExReplace(Trim(nameEdit.Value), "[\s\r\n]+", "")
    url := Trim(urlEdit.Value)
    title := Trim(titleEdit.Value)
    body := Trim(bodyEdit.Value)
    note := Trim(noteEdit.Value)
    opinion := Trim(opinionEdit.Value)
    
    ; Validate name
    if (name = "") {
        MsgBox("Please enter a hotstring name.", "Name Required", "48")
        return
    }
    
    if (StrLen(name) > 40) {
        MsgBox("Name must be 40 characters or less.`n`nCurrent length: " StrLen(name), "Name Too Long", "48")
        return
    }
    
    if RegExMatch(name, "[^a-zA-Z0-9_-]") {
        MsgBox("Name can only contain letters, numbers, underscore, and hyphen.", "Invalid Characters", "48")
        return
    }
    
    ; Check for duplicate
    if CaptureData.Has(StrLower(name)) {
        result := MsgBox("A capture named '" name "' already exists.`n`nOverwrite it?", "Name Exists", "YesNo Icon!")
        if (result = "No")
            return
    }
    
    ; Build tags string
    selectedTags := []
    for item in tagCheckboxes {
        if (item.cb.Value)
            selectedTags.Push(item.tag)
    }
    tags := ""
    for i, tag in selectedTags {
        tags .= (i > 1 ? "," : "") tag
    }
    
    ; Auto-generate title if blank
    if (title = "" && body != "") {
        ; Use first 50 chars of body as title
        title := SubStr(body, 1, 50)
        if (StrLen(body) > 50)
            title .= "..."
    } else if (title = "") {
        title := "Manual Entry: " name
    }
    
    ; Clean content
    body := CC_CleanContent(body)
    title := CC_CleanContent(title)
    
    ; Save
    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    CC_AddCapture(name, url, title, timestamp, tags, note, opinion, body)
    
    manualGui.Destroy()
    
    ; Show success with hotstring info
    msg := "✅ Saved '" name "'`n`n"
    msg .= "HOTSTRINGS NOW AVAILABLE:`n"
    msg .= "━━━━━━━━━━━━━━━━━━━━━`n"
    msg .= name "      → Paste content`n"
    msg .= name "go    → Open URL`n"
    msg .= name "rd    → Read window`n"
    msg .= name "vi    → Edit capture`n"
    msg .= name "em    → Email`n"
    msg .= name "?     → Action menu"
    
    MsgBox(msg, "Manual Capture Saved", "64")
    
    CC_UpdateRecentWidget()
}

CC_GetCaptureDetailsWithTags() {
    global AvailableTags

    resultData := {name: "", comment: "", opinion: "", tags: ""}

    captureGui := Gui("+AlwaysOnTop", "Capture Details")
    captureGui.SetFont("s10")

    captureGui.Add("Text", , "Hotstring name (short, memorable):")
    nameEdit := captureGui.Add("Edit", "vHotstringName w450")

    captureGui.Add("Text", "y+15", "Tags (click to toggle):")

    tagCheckboxes := []
    xPos := 10
    for i, tag in AvailableTags {
        cb := captureGui.Add("Checkbox", "x" xPos " y+5 w100", tag)
        tagCheckboxes.Push(cb)
        if (Mod(i, 5) = 0) {
            xPos := 10
        } else {
            xPos += 110
        }
    }

    captureGui.Add("Text", "x10 y+20", "Private note (only you see this):")
    commentEdit := captureGui.Add("Edit", "x10 vComment w450 h40")

    captureGui.Add("Text", "y+10", "Opinion (included in output):")
    opinionEdit := captureGui.Add("Edit", "vOpinion w450 h60")

    captureGui.Add("Button", "y+15 w100 Default", "Save").OnEvent("Click", (*) => captureGui.Submit())
    captureGui.Add("Button", "x+10 w100", "Cancel").OnEvent("Click", (*) => captureGui.Destroy())
    captureGui.OnEvent("Close", (*) => captureGui.Destroy())
    captureGui.OnEvent("Escape", (*) => captureGui.Destroy())

    captureGui.Show()
    WinWaitClose(captureGui.Hwnd)

    try {
        resultData.name := RegExReplace(nameEdit.Value, "[\r\n\t\s]+", "")
        resultData.comment := Trim(commentEdit.Value)
        resultData.opinion := Trim(opinionEdit.Value)

        selectedTags := ""
        for cb in tagCheckboxes {
            if (cb.Value)
                selectedTags .= (selectedTags ? "," : "") cb.Text
        }
        resultData.tags := selectedTags
    }

    return resultData
}

; ==============================================================================
; CAPTURE BROWSER - Full-Featured Search & Management Interface
; ==============================================================================
; The Capture Browser is the "home base" for managing all your captures.
; It's more powerful than Quick Search but takes a bit more screen space.
;
; FEATURES:
;   • Full-text search across names, titles, URLs, tags, and content
;   • Filter by tag using dropdown
;   • Sort by name, date, or title
;   • Preview pane shows full content before pasting
;   • Edit, delete, copy, or open any capture
;   • Add/remove favorites with one click
;   • Resizable window that remembers your layout
;
; KEYBOARD SHORTCUTS (while browser is open):
;   Ctrl+F        Focus search box
;   Up/Down       Navigate list
;   Enter         Paste selected capture
;   Delete        Delete selected capture (with confirmation)
;   Escape        Close browser
;
; SEARCH TIPS:
;   • Type multiple words to AND search (all must match)
;   • Search matches: name, title, URL, tags, note, opinion, body
;   • Use tag filter dropdown for tag-specific filtering
;
; GUI STRUCTURE:
;   ┌──────────────────────────────────────────────────────────────┐
;   │ Search: [___________] Tag: [dropdown] Sort: [dropdown]       │
;   ├──────────────────────────────────────────────────────────────┤
;   │ Results List          │ Preview Pane                         │
;   │ ○ capture1            │ [Title]                              │
;   │ ● capture2 (selected) │ [URL]                                │
;   │ ○ capture3            │ [Content preview...]                 │
;   │                       │                                      │
;   ├──────────────────────────────────────────────────────────────┤
;   │ [Paste] [Copy] [Edit] [Delete] [Open URL] [⭐ Favorite]      │
;   └──────────────────────────────────────────────────────────────┘
; ==============================================================================

; ------------------------------------------------------------------------------
; CC_OpenCaptureBrowser()
; ------------------------------------------------------------------------------
; PURPOSE: Open the full Capture Browser window
; HOTKEY: Ctrl+Alt+B
; ------------------------------------------------------------------------------
CC_OpenCaptureBrowser() {
    global CaptureData, CaptureNames, AvailableTags

    if (CaptureNames.Length = 0) {
        MsgBox("No captures yet.`n`nUse Ctrl+Alt+P to capture content.", "Capture Browser", "48")
        return
    }

    browserGui := Gui("+Resize +MinSize700x500", "Capture Browser - " CaptureNames.Length " captures")
    browserGui.SetFont("s10")

    browserGui.Add("Text", "x10 y10", "Search:")
    searchEdit := browserGui.Add("Edit", "x60 y8 w300 vSearchText")

    browserGui.Add("Text", "x380 y10", "Tag:")
    tagDropdown := browserGui.Add("DropDownList", "x410 y7 w120 vTagFilter", ["All Tags", AvailableTags*])
    tagDropdown.Choose(1)

    browserGui.Add("Button", "x545 y7 w70", "Filter").OnEvent("Click", (*) => CC_FilterBrowserCaptures(browserGui))

    browserGui.filterFunc := CC_FilterBrowserCaptures.Bind(browserGui)
    searchEdit.OnEvent("Change", (*) => SetTimer(browserGui.filterFunc, -300))
    tagDropdown.OnEvent("Change", (*) => CC_FilterBrowserCaptures(browserGui))

    browserGui.Add("Text", "x10 y40", "Double-click to open URL | Enter=Paste | ⭐=Toggle favorite")

    listView := browserGui.Add("ListView", "x10 y65 w680 h330 vCaptureList Grid", ["⭐", "Name", "Title", "Tags", "Date"])
    listView.ModifyCol(1, 30)
    listView.ModifyCol(2, 110)
    listView.ModifyCol(3, 310)
    listView.ModifyCol(4, 110)
    listView.ModifyCol(5, 100)

    ; Populate with favorites indicator
    for name in CaptureNames {
        if !CaptureData.Has(StrLower(name))
            continue
        cap := CaptureData[StrLower(name)]
        isFav := CC_IsFavorite(name) ? "⭐" : ""
        listView.Add(, isFav, name,
            cap.Has("title") ? cap["title"] : "",
            cap.Has("tags") ? cap["tags"] : "",
            cap.Has("date") ? cap["date"] : "")
    }
    
    listView.ModifyCol(2, "Sort")  ; Sort alphabetically by Name

    listView.OnEvent("DoubleClick", (*) => CC_BrowserOpenURL(listView))
    
    ; Keyboard handler for ListView
    listView.OnEvent("ItemFocus", (*) => "")  ; Just to ensure focus events work

    ; Button row 1
    browserGui.Add("Button", "x10 y405 w60", "🌐 Open").OnEvent("Click", (*) => CC_BrowserOpenURL(listView))
    browserGui.Add("Button", "x75 y405 w60", "📋 Copy").OnEvent("Click", (*) => CC_BrowserCopyContent(listView))
    browserGui.Add("Button", "x140 y405 w60", "📧 Email").OnEvent("Click", (*) => CC_BrowserEmailContent(listView))
    browserGui.Add("Button", "x205 y405 w50", "⭐ Fav").OnEvent("Click", (*) => CC_BrowserToggleFavorite(listView, browserGui))
    browserGui.Add("Button", "x260 y405 w75", "❓ Hotstring").OnEvent("Click", (*) => CC_BrowserShowHotstring(listView))
    browserGui.Add("Button", "x340 y405 w60", "📖 Read").OnEvent("Click", (*) => CC_BrowserReadContent(listView))
    browserGui.Add("Button", "x405 y405 w60", "✏️ Edit").OnEvent("Click", (*) => CC_BrowserEditCapture(listView))
    browserGui.Add("Button", "x470 y405 w55", "🗑️ Del").OnEvent("Click", (*) => CC_BrowserDeleteCapture(listView, browserGui))
    browserGui.Add("Button", "x605 y405 w90", "Close").OnEvent("Click", (*) => browserGui.Destroy())

    browserGui.statusText := browserGui.Add("Text", "x10 y440 w680", "Showing " CaptureNames.Length " captures | Enter=Paste selected | Arrows to navigate")

    browserGui.OnEvent("Close", (*) => browserGui.Destroy())
    browserGui.OnEvent("Escape", (*) => browserGui.Destroy())
    
    ; Store listView reference for keyboard handling
    browserGui.listView := listView
    
    ; Keyboard shortcuts when browser is active
    HotIfWinActive("ahk_id " browserGui.Hwnd)
    Hotkey("Enter", (*) => CC_BrowserPasteSelected(listView, browserGui), "On")
    Hotkey("Delete", (*) => CC_BrowserDeleteCapture(listView, browserGui), "On")
    Hotkey("^f", (*) => searchEdit.Focus(), "On")
    HotIf()

    browserGui.Show("w710 h470")
    searchEdit.Focus()
    
    ; Show helpful tip for new users
    CCHelp.TipAfterFirstBrowse()
}

CC_BrowserToggleFavorite(listView, browserGui) {
    row := listView.GetNext(0, "F")
    if (row = 0) {
        MsgBox("Select a capture first.", "No Selection", "48")
        return
    }
    
    name := listView.GetText(row, 2)  ; Column 2 is name now
    isFav := CC_ToggleFavorite(name)
    
    ; Update the star column
    listView.Modify(row, , isFav ? "⭐" : "")
}

CC_BrowserEditCapture(listView) {
    row := listView.GetNext(0, "F")
    if (row = 0) {
        MsgBox("Select a capture first.", "No Selection", "48")
        return
    }
    
    name := listView.GetText(row, 2)
    CC_EditCapture(name)
}

CC_BrowserPasteSelected(listView, browserGui) {
    row := listView.GetNext(0, "F")
    if (row = 0)
        return
    
    name := listView.GetText(row, 2)
    browserGui.Destroy()
    
    ; Small delay to let window close
    Sleep(100)
    CC_HotstringPaste(name)
}

CC_FilterBrowserCaptures(browserGui) {
    global CaptureData, CaptureNames

    listView := browserGui["CaptureList"]
    searchText := browserGui["SearchText"].Value
    tagFilter := browserGui["TagFilter"].Text

    listView.Delete()

    searchLower := StrLower(searchText)
    matchCount := 0

    for name in CaptureNames {
        if !CaptureData.Has(StrLower(name))
            continue

        cap := CaptureData[StrLower(name)]

        if (tagFilter != "All Tags") {
            capTags := cap.Has("tags") ? cap["tags"] : ""
            if !InStr(capTags, tagFilter)
                continue
        }

        if (searchText != "") {
            nameLower := StrLower(name)
            titleLower := StrLower(cap.Has("title") ? cap["title"] : "")
            
            if !InStr(nameLower, searchLower) && !InStr(titleLower, searchLower)
                continue
        }

        isFav := CC_IsFavorite(name) ? "⭐" : ""
        listView.Add(, isFav, name,
            cap.Has("title") ? cap["title"] : "",
            cap.Has("tags") ? cap["tags"] : "",
            cap.Has("date") ? cap["date"] : "")
        matchCount++
    }
    
    listView.ModifyCol(2, "Sort")  ; Sort alphabetically by Name
    browserGui.statusText.Value := "Showing " matchCount " of " CaptureNames.Length " captures"
}

CC_BrowserOpenURL(listView) {
    row := listView.GetNext(0, "F")
    if (row = 0) {
        MsgBox("Select a capture first.", "No Selection", "48")
        return
    }

    name := listView.GetText(row, 2)
    url := CC_GetCaptureURL(name)
    if (url != "")
        try Run(url)
}

CC_BrowserCopyContent(listView) {
    row := listView.GetNext(0, "F")
    if (row = 0) {
        MsgBox("Select a capture first.", "No Selection", "48")
        return
    }

    name := listView.GetText(row, 2)
    content := CC_GetCaptureContent(name)
    A_Clipboard := content
    ClipWait(1)
    TrayTip("Copied!", name, "1")
}

CC_BrowserReadContent(listView) {
    row := listView.GetNext(0, "F")
    if (row = 0) {
        MsgBox("Select a capture first.", "No Selection", "48")
        return
    }

    name := listView.GetText(row, 2)
    CC_ShowReadWindow(name)
}

CC_BrowserEmailContent(listView) {
    row := listView.GetNext(0, "F")
    if (row = 0) {
        MsgBox("Select a capture first.", "No Selection", "48")
        return
    }

    name := listView.GetText(row, 2)
    CC_HotstringEmail(name)
}

CC_BrowserShowHotstring(listView) {
    row := listView.GetNext(0, "F")
    if (row = 0) {
        MsgBox("Select a capture first.", "No Selection", "48")
        return
    }

    name := listView.GetText(row, 2)
    title := listView.GetText(row, 3)

    msg := "HOTSTRING COMMANDS for '" name "'`n"
    msg .= "================================`n`n"
    msg .= name "      -> Paste content`n"
    msg .= name "go    -> Open URL in browser`n"
    msg .= name "rd    -> Read in window`n"
    msg .= name "vi    -> Edit capture`n"
    msg .= name "em    -> Email via Outlook`n"
    msg .= name "?     -> Show action menu`n`n"
    msg .= "Title: " title

    MsgBox(msg, "Hotstring Help", "64")
}

CC_BrowserDeleteCapture(listView, browserGui) {
    global CaptureData, CaptureNames

    ; Collect all selected rows
    selectedNames := []
    row := 0
    Loop {
        row := listView.GetNext(row)
        if (row = 0)
            break
        name := listView.GetText(row, 2)  ; Column 2 is the name
        selectedNames.Push(name)
    }
    
    if (selectedNames.Length = 0) {
        MsgBox("Select a capture first.", "No Selection", "48")
        return
    }

    ; Confirmation message based on count
    if (selectedNames.Length = 1) {
        confirmMsg := "Delete capture '" selectedNames[1] "'?`n`nThis cannot be undone."
    } else {
        confirmMsg := "Delete " selectedNames.Length " captures?`n`n"
        ; Show first few names
        showCount := Min(selectedNames.Length, 5)
        Loop showCount {
            confirmMsg .= "• " selectedNames[A_Index] "`n"
        }
        if (selectedNames.Length > 5)
            confirmMsg .= "• ... and " (selectedNames.Length - 5) " more`n"
        confirmMsg .= "`nThis cannot be undone."
    }

    result := MsgBox(confirmMsg, "Confirm Delete", "YesNo Icon!")
    if (result = "No")
        return

    ; Delete all selected captures
    for name in selectedNames {
        if CaptureData.Has(StrLower(name))
            CaptureData.Delete(name)
    }

    ; Rebuild CaptureNames without deleted items
    newNames := []
    for n in CaptureNames {
        isDeleted := false
        for delName in selectedNames {
            if (n = delName) {
                isDeleted := true
                break
            }
        }
        if (!isDeleted)
            newNames.Push(n)
    }
    CaptureNames := newNames

    CC_SaveCaptureData()
    CC_GenerateHotstringFile()

    browserGui.Destroy()
    CC_OpenCaptureBrowser()

    if (selectedNames.Length = 1)
        TrayTip("Capture deleted.", selectedNames[1], "1")
    else
        TrayTip(selectedNames.Length " captures deleted.", "Batch Delete", "1")
}

; ==============================================================================
; RESTORE FROM BACKUP BROWSER
; ==============================================================================

CC_OpenRestoreBrowser() {
    global BaseDir, CaptureData, CaptureNames
    
    backupFile := BaseDir "\capturesbackup.dat"
    
    if !FileExist(backupFile) {
        MsgBox("Backup file not found:`n" backupFile "`n`nMake sure capturesbackup.dat is in your ContentCapture folder.", "No Backup Found", "48")
        return
    }
    
    ; Load backup data into temporary maps
    backupData := Map()
    backupNames := []
    
    try {
        content := FileRead(backupFile, "UTF-8")
        
        currentCapture := Map()
        currentName := ""
        inBody := false
        bodyLines := ""
        
        Loop Parse, content, "`n", "`r" {
            line := A_LoopField
            
            if RegExMatch(line, "^\[([^\]]+)\]$", &match) {
                if (currentName != "") {
                    if (inBody && bodyLines != "")
                        currentCapture["body"] := RTrim(bodyLines, "`n")
                    backupData[StrLower(currentName)] := currentCapture
                    backupNames.Push(currentName)
                }
                
                currentName := match[1]
                currentCapture := Map()
                currentCapture["name"] := currentName
                inBody := false
                bodyLines := ""
                continue
            }
            
            if (currentName = "")
                continue
            
            if (SubStr(line, 1, 4) = "url=") {
                currentCapture["url"] := SubStr(line, 5)
            } else if (SubStr(line, 1, 6) = "title=") {
                currentCapture["title"] := SubStr(line, 7)
            } else if (SubStr(line, 1, 5) = "date=") {
                currentCapture["date"] := SubStr(line, 6)
            } else if (SubStr(line, 1, 5) = "tags=") {
                currentCapture["tags"] := SubStr(line, 6)
            } else if (SubStr(line, 1, 5) = "note=") {
                currentCapture["note"] := SubStr(line, 6)
            } else if (SubStr(line, 1, 8) = "opinion=") {
                currentCapture["opinion"] := SubStr(line, 9)
            } else if (SubStr(line, 1, 6) = "short=") {
                currentCapture["short"] := SubStr(line, 7)
            } else if (line = "body=<<<BODY") {
                inBody := true
            } else if (line = "BODY>>>") {
                inBody := false
                if (bodyLines != "")
                    currentCapture["body"] := RTrim(bodyLines, "`n")
            } else if (inBody) {
                bodyLines .= line "`n"
            }
        }
        
        ; Don't forget the last entry
        if (currentName != "") {
            if (inBody && bodyLines != "")
                currentCapture["body"] := RTrim(bodyLines, "`n")
            backupData[StrLower(currentName)] := currentCapture
            backupNames.Push(currentName)
        }
    } catch as err {
        MsgBox("Error reading backup file:`n" err.Message, "Error", "16")
        return
    }
    
    if (backupNames.Length = 0) {
        MsgBox("Backup file is empty or has no valid entries.", "Empty Backup", "48")
        return
    }
    
    ; Create the restore browser GUI
    restoreGui := Gui("+Resize +MinSize800x550", "📦 Restore from Backup - " backupNames.Length " entries")
    restoreGui.SetFont("s10")
    restoreGui.BackColor := "1e1e2e"
    
    ; Store backup data in GUI for later access
    restoreGui.backupData := backupData
    restoreGui.backupNames := backupNames
    
    restoreGui.SetFont("s11 cWhite")
    restoreGui.Add("Text", "x10 y10 w700", "📦 Restore entries from capturesbackup.dat to your working captures")
    
    restoreGui.SetFont("s10 cWhite")
    restoreGui.Add("Text", "x10 y38", "Search:")
    searchEdit := restoreGui.Add("Edit", "x65 y35 w300 vSearchText Background333355 cWhite")
    
    ; Filter to show only entries NOT already in working file
    showNewOnly := restoreGui.Add("Checkbox", "x390 y38 cWhite vShowNewOnly", "Hide duplicates")
    showNewOnly.OnEvent("Click", (*) => CC_FilterRestoreList(restoreGui))
    
    restoreGui.Add("Button", "x580 y33 w80 h26", "🔍 Filter").OnEvent("Click", (*) => CC_FilterRestoreList(restoreGui))
    
    ; Set up live search
    restoreGui.filterFunc := CC_FilterRestoreList.Bind(restoreGui)
    searchEdit.OnEvent("Change", (*) => SetTimer(restoreGui.filterFunc, -300))
    
    restoreGui.SetFont("s9 cAAAAAA")
    restoreGui.Add("Text", "x10 y68", "✓ = Check items to restore | Double-click to edit | 🔴 = Already exists in working file")
    
    ; ListView with checkboxes
    restoreGui.SetFont("s10 c000000")
    listView := restoreGui.Add("ListView", "x10 y95 w520 h350 vRestoreList Checked Grid BackgroundFFFFFF", ["Status", "Name", "Title", "Date"])
    listView.ModifyCol(1, 50)
    listView.ModifyCol(2, 120)
    listView.ModifyCol(3, 250)
    listView.ModifyCol(4, 80)
    
    ; Populate list
    for name in backupNames {
        if !backupData.Has(StrLower(name))
            continue
        cap := backupData[StrLower(name)]
        
        ; Check if already exists in working file
        exists := CaptureData.Has(StrLower(name))
        status := exists ? "🔴" : "🟢"
        
        listView.Add(, status, name,
            cap.Has("title") ? cap["title"] : "",
            cap.Has("date") ? cap["date"] : "")
    }
    
    listView.OnEvent("DoubleClick", (*) => CC_PreviewBackupEntry(restoreGui))
    listView.OnEvent("ItemFocus", (*) => CC_UpdateRestorePreview(restoreGui))
    
    ; Preview pane
    restoreGui.SetFont("s10 bold cWhite")
    restoreGui.Add("Text", "x545 y95", "Preview:")
    
    restoreGui.SetFont("s9 norm c000000")
    previewEdit := restoreGui.Add("Edit", "x545 y115 w245 h330 vPreviewText ReadOnly Multi VScroll BackgroundFFFEF5")
    
    ; Buttons
    restoreGui.SetFont("s10 cWhite")
    restoreGui.Add("Button", "x10 y455 w100 h30", "✓ Select All").OnEvent("Click", (*) => CC_RestoreSelectAll(restoreGui, true))
    restoreGui.Add("Button", "x120 y455 w100 h30", "✗ Select None").OnEvent("Click", (*) => CC_RestoreSelectAll(restoreGui, false))
    restoreGui.Add("Button", "x230 y455 w110 h30", "✏️ Edit Selected").OnEvent("Click", (*) => CC_PreviewBackupEntry(restoreGui))
    restoreGui.Add("Button", "x350 y455 w100 h30", "🗑️ Delete").OnEvent("Click", (*) => CC_DeleteFromBackup(restoreGui))
    
    ; Archive checkbox
    restoreGui.SetFont("s9 cFFCC00")
    archiveCheck := restoreGui.Add("Checkbox", "x545 y420 w245 vMoveToArchive", "📁 Move to archive after restore")
    archiveCheck.ToolTip := "Removes restored entries from backup`nand saves them to capturesarchive.dat"
    
    restoreBtn := restoreGui.Add("Button", "x545 y455 w120 h35 Default", "📥 RESTORE")
    restoreBtn.OnEvent("Click", (*) => CC_RestoreSelectedEntries(restoreGui))
    
    restoreGui.Add("Button", "x680 y455 w110 h35", "Cancel").OnEvent("Click", (*) => CC_CloseRestoreGui(restoreGui))
    
    ; Status bar
    restoreGui.SetFont("s9 cAAAAAA")
    newCount := 0
    for name in backupNames {
        if !CaptureData.Has(StrLower(name))
            newCount++
    }
    restoreGui.statusText := restoreGui.Add("Text", "x10 y495 w780", 
        "Backup: " backupNames.Length " entries | New (not in working file): " newCount " | Working file: " CaptureNames.Length " captures")
    
    restoreGui.OnEvent("Close", (*) => CC_CloseRestoreGui(restoreGui))
    restoreGui.OnEvent("Escape", (*) => CC_CloseRestoreGui(restoreGui))
    
    restoreGui.Show("w800 h520")
    searchEdit.Focus()
}

CC_FilterRestoreList(restoreGui) {
    global CaptureData
    
    ; Guard against destroyed GUI (timer may fire after close)
    try {
        if !WinExist("ahk_id " restoreGui.Hwnd)
            return
    } catch
        return
    
    listView := restoreGui["RestoreList"]
    searchText := restoreGui["SearchText"].Value
    showNewOnly := restoreGui["ShowNewOnly"].Value
    
    backupData := restoreGui.backupData
    backupNames := restoreGui.backupNames
    
    listView.Delete()
    
    searchLower := StrLower(searchText)
    matchCount := 0
    newCount := 0
    
    ; Collect matches in two groups: name matches first, then body/title matches
    nameMatches := []
    bodyMatches := []
    
    for name in backupNames {
        if !backupData.Has(StrLower(name))
            continue
        
        cap := backupData[StrLower(name)]
        exists := CaptureData.Has(StrLower(name))
        
        ; Filter by "show new only"
        if (showNewOnly && exists)
            continue
        
        ; Filter by search text - prioritize name matches
        if (searchText != "") {
            nameLower := StrLower(name)
            titleLower := StrLower(cap.Has("title") ? cap["title"] : "")
            bodyLower := StrLower(cap.Has("body") ? cap["body"] : "")
            
            isNameMatch := InStr(nameLower, searchLower)
            isTitleMatch := InStr(titleLower, searchLower)
            isBodyMatch := InStr(bodyLower, searchLower)
            
            if !isNameMatch && !isTitleMatch && !isBodyMatch
                continue
            
            ; Prioritize: name matches go to front, body/title matches go to back
            entry := {name: name, cap: cap, exists: exists}
            if isNameMatch
                nameMatches.Push(entry)
            else
                bodyMatches.Push(entry)
        } else {
            ; No search - add all
            entry := {name: name, cap: cap, exists: exists}
            nameMatches.Push(entry)
        }
    }
    
    ; Add name matches first (exact/partial script name hits)
    for entry in nameMatches {
        status := entry.exists ? "🔴" : "🟢"
        if !entry.exists
            newCount++
        listView.Add(, status, entry.name,
            entry.cap.Has("title") ? entry.cap["title"] : "",
            entry.cap.Has("date") ? entry.cap["date"] : "")
        matchCount++
    }
    
    ; Then add body/title matches
    for entry in bodyMatches {
        status := entry.exists ? "🔴" : "🟢"
        if !entry.exists
            newCount++
        listView.Add(, status, entry.name,
            entry.cap.Has("title") ? entry.cap["title"] : "",
            entry.cap.Has("date") ? entry.cap["date"] : "")
        matchCount++
    }
    
    restoreGui.statusText.Value := "Showing " matchCount " of " backupNames.Length " | New entries: " newCount " | Name matches: " nameMatches.Length
}

CC_CloseRestoreGui(restoreGui) {
    ; Stop the filter timer before destroying to prevent "control is destroyed" error
    if restoreGui.HasOwnProp("filterFunc")
        SetTimer(restoreGui.filterFunc, 0)
    restoreGui.Destroy()
}

CC_UpdateRestorePreview(restoreGui) {
    listView := restoreGui["RestoreList"]
    previewEdit := restoreGui["PreviewText"]
    
    row := listView.GetNext(0, "F")
    if (row = 0) {
        previewEdit.Value := ""
        return
    }
    
    name := listView.GetText(row, 2)
    backupData := restoreGui.backupData
    
    if !backupData.Has(StrLower(name)) {
        previewEdit.Value := ""
        return
    }
    
    cap := backupData[StrLower(name)]
    
    preview := "📌 " name "`n"
    preview .= "━━━━━━━━━━━━━━━━`n"
    
    if (cap.Has("title") && cap["title"] != "")
        preview .= "📝 " cap["title"] "`n`n"
    
    if (cap.Has("url") && cap["url"] != "")
        preview .= "🔗 " cap["url"] "`n`n"
    
    if (cap.Has("date") && cap["date"] != "")
        preview .= "📅 " cap["date"] "`n"
    
    if (cap.Has("tags") && cap["tags"] != "")
        preview .= "🏷️ " cap["tags"] "`n"
    
    if (cap.Has("short") && cap["short"] != "")
        preview .= "`n🐦 Short: " cap["short"] "`n"
    
    if (cap.Has("opinion") && cap["opinion"] != "")
        preview .= "`n💭 " cap["opinion"] "`n"
    
    if (cap.Has("note") && cap["note"] != "")
        preview .= "`n📝 Note: " cap["note"] "`n"
    
    if (cap.Has("body") && cap["body"] != "") {
        bodyPreview := cap["body"]
        if (StrLen(bodyPreview) > 500)
            bodyPreview := SubStr(bodyPreview, 1, 500) "..."
        preview .= "`n━━━━━━━━━━━━━━━━`n" bodyPreview
    }
    
    previewEdit.Value := preview
}

CC_PreviewBackupEntry(restoreGui) {
    listView := restoreGui["RestoreList"]
    
    row := listView.GetNext(0, "F")
    if (row = 0) {
        MsgBox("Select an entry to preview.", "No Selection", "48")
        return
    }
    
    name := listView.GetText(row, 2)
    backupData := restoreGui.backupData
    
    if !backupData.Has(StrLower(name))
        return
    
    cap := backupData[StrLower(name)]
    
    ; Show EDITABLE preview in popup
    editGui := Gui("+AlwaysOnTop", "✏️ Edit Before Restore: " name)
    editGui.SetFont("s10")
    editGui.BackColor := "F5F5F5"
    
    ; Store reference to update backupData
    editGui.backupData := backupData
    editGui.entryName := name
    editGui.restoreGui := restoreGui
    
    ; Hotstring Name (editable for Save As New)
    editGui.SetFont("s9 norm c666666")
    editGui.Add("Text", "x15 y10", "📌 Hotstring Name:")
    editGui.SetFont("s11 bold c000000")
    editGui.Add("Edit", "x130 y7 w200 h24 vEditName BackgroundE8F5E9", name)
    editGui.SetFont("s8 c888888")
    editGui.Add("Text", "x340 y12", "(change to create new entry)")
    
    ; Title
    editGui.SetFont("s9 norm c666666")
    editGui.Add("Text", "x15 y40", "Title:")
    editGui.SetFont("s10 norm c000000")
    currentTitle := cap.Has("title") ? cap["title"] : ""
    editGui.Add("Edit", "x15 y58 w560 h24 vEditTitle", currentTitle)
    
    ; URL
    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y90", "URL:")
    editGui.SetFont("s10 c000000")
    currentURL := cap.Has("url") ? cap["url"] : ""
    editGui.Add("Edit", "x15 y108 w560 h24 vEditURL", currentURL)
    
    ; Date (read-only display)
    editGui.SetFont("s9 c666666")
    currentDate := cap.Has("date") ? cap["date"] : ""
    if (currentDate != "")
        editGui.Add("Text", "x15 y140", "📅 " currentDate)
    
    yPos := (currentDate != "") ? 160 : 140
    
    ; Short version for social media
    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y" yPos, "🐦 Short version (for X/Bluesky, max 280 chars):")
    yPos += 18
    editGui.SetFont("s10 c000000")
    currentShort := cap.Has("short") ? cap["short"] : ""
    editGui.Add("Edit", "x15 y" yPos " w560 h50 vEditShort Multi BackgroundFFFDD0", currentShort)
    yPos += 58
    
    ; Opinion
    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y" yPos, "💭 Opinion (optional):")
    yPos += 18
    editGui.SetFont("s10 c000000")
    currentOpinion := cap.Has("opinion") ? cap["opinion"] : ""
    editGui.Add("Edit", "x15 y" yPos " w560 h45 vEditOpinion Multi", currentOpinion)
    yPos += 55
    
    ; Note
    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y" yPos, "📝 Note (private, optional):")
    yPos += 18
    editGui.SetFont("s10 c000000")
    currentNote := cap.Has("note") ? cap["note"] : ""
    editGui.Add("Edit", "x15 y" yPos " w560 h35 vEditNote Multi", currentNote)
    yPos += 45
    
    ; Body with cleanup button
    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y" yPos, "📄 Body content:")
    editGui.Add("Button", "x450 y" (yPos - 3) " w125 h22", "🧹 Clean URLs").OnEvent("Click", (*) => CC_CleanBodyURLs(editGui))
    yPos += 18
    editGui.SetFont("s10 c000000")
    currentBody := cap.Has("body") ? cap["body"] : ""
    editGui.Add("Edit", "x15 y" yPos " w560 h130 vEditBody Multi VScroll", currentBody)
    yPos += 140
    
    ; Buttons row 1 - backup operations
    editGui.SetFont("s10")
    editGui.Add("Button", "x15 y" yPos " w130 h30", "💾 Save Changes").OnEvent("Click", (*) => CC_SaveBackupEdits(editGui, false))
    editGui.Add("Button", "x155 y" yPos " w150 h30", "📋 Save As New").OnEvent("Click", (*) => CC_SaveBackupEdits(editGui, true))
    editGui.Add("Button", "x455 y" yPos " w120 h30", "Close").OnEvent("Click", (*) => editGui.Destroy())
    
    yPos += 38
    
    ; Button row 2 - direct to working file
    editGui.Add("Button", "x15 y" yPos " w290 h32 BackgroundC8E6C9", "⚡ Save Directly to Working File (Ready to Use!)").OnEvent("Click", (*) => CC_SaveToWorkingFile(editGui))
    
    editGui.SetFont("s8 c888888")
    editGui.Add("Text", "x15 y" (yPos + 38) " w560", "💡 Top row saves to backup | Green button saves to captures.dat for immediate use")
    
    editGui.OnEvent("Escape", (*) => editGui.Destroy())
    editGui.Show("w590 h" (yPos + 65))
}

CC_CleanBodyURLs(editGui) {
    ; Get current URL and body
    urlField := editGui["EditURL"]
    bodyField := editGui["EditBody"]
    
    url := urlField.Value
    body := bodyField.Value
    
    if (url = "") {
        MsgBox("No URL to match against.", "Clean URLs", "48")
        return
    }
    
    originalBody := body
    
    ; Remove the exact URL (with and without trailing slash)
    urlNoSlash := RTrim(url, "/")
    urlWithSlash := urlNoSlash "/"
    
    body := StrReplace(body, urlWithSlash, "")
    body := StrReplace(body, urlNoSlash, "")
    
    ; Also find and remove any URLs that share the same domain
    ; Extract domain from URL
    if RegExMatch(url, "https?://([^/]+)", &domainMatch) {
        domain := domainMatch[1]
        ; Remove any URL containing this domain
        body := RegExReplace(body, "https?://" domain "[^\s]*", "")
    }
    
    ; Clean up double spaces, double newlines left behind
    body := RegExReplace(body, " {2,}", " ")
    body := RegExReplace(body, "(\r?\n){3,}", "`n`n")
    body := Trim(body)
    
    if (body = originalBody) {
        MsgBox("No matching URLs found in body.", "Clean URLs", "i")
        return
    }
    
    bodyField.Value := body
    TrayTip("URLs cleaned from body text!", "Clean URLs", "1")
}

CC_SaveBackupEdits(editGui, saveAsNew := false) {
    global BaseDir
    
    ; Get the edited values
    saved := editGui.Submit(false)
    
    backupData := editGui.backupData
    originalName := editGui.entryName
    newName := Trim(saved.EditName)
    restoreGui := editGui.restoreGui
    
    ; Validate new name
    if (newName = "") {
        MsgBox("Hotstring name cannot be empty.", "Error", "48")
        return
    }
    
    ; Check for invalid characters in name
    if RegExMatch(newName, "[^\w\-]") {
        MsgBox("Hotstring name can only contain letters, numbers, underscores, and hyphens.", "Invalid Name", "48")
        return
    }
    
    ; Check name length (AHK hotstring limit)
    if (StrLen(newName) > 40) {
        MsgBox("Hotstring name must be 40 characters or less.", "Name Too Long", "48")
        return
    }
    
    if !backupData.Has(StrLower(originalName))
        return
    
    ; Get original cap data
    originalCap := backupData[StrLower(originalName)]
    
    ; Create new cap with edited values
    newCap := Map()
    newCap["name"] := newName
    newCap["title"] := saved.EditTitle
    newCap["url"] := saved.EditURL
    newCap["short"] := saved.EditShort
    newCap["opinion"] := saved.EditOpinion
    newCap["note"] := saved.EditNote
    newCap["body"] := saved.EditBody
    
    ; Preserve date and tags from original
    if (originalCap.Has("date"))
        newCap["date"] := originalCap["date"]
    if (originalCap.Has("tags"))
        newCap["tags"] := originalCap["tags"]
    
    if (saveAsNew) {
        ; Save As New - create a new entry
        
        ; Check if name already exists
        if (backupData.Has(StrLower(newName)) && StrLower(newName) != StrLower(originalName)) {
            result := MsgBox("'" newName "' already exists in backup.`n`nOverwrite it?", "Name Exists", "YesNo Icon!")
            if (result = "No")
                return
        }
        
        ; If name is same as original, warn user
        if (StrLower(newName) = StrLower(originalName)) {
            MsgBox("To save as new entry, change the hotstring name first.`n`nCurrent name: " originalName, "Same Name", "48")
            return
        }
        
        ; Add new entry
        backupData[StrLower(newName)] := newCap
        restoreGui.backupNames.Push(newName)
        
        ; Save and refresh
        CC_SaveBackupFile(restoreGui.backupData, restoreGui.backupNames)
        CC_FilterRestoreList(restoreGui)
        
        editGui.Destroy()
        TrayTip("New entry created: " newName, "Save As New", "1")
        
    } else {
        ; Regular Save - update existing entry
        
        ; If name changed, handle rename
        if (StrLower(newName) != StrLower(originalName)) {
            ; Check if new name already exists
            if (backupData.Has(StrLower(newName))) {
                result := MsgBox("'" newName "' already exists.`n`nUse 'Save As New' to create a copy, or change the name.", "Name Exists", "OK Icon!")
                return
            }
            
            ; Remove old entry
            backupData.Delete(StrLower(originalName))
            
            ; Update the name in backupNames array
            for i, n in restoreGui.backupNames {
                if (StrLower(n) = StrLower(originalName)) {
                    restoreGui.backupNames[i] := newName
                    break
                }
            }
        }
        
        ; Save the entry
        backupData[StrLower(newName)] := newCap
        
        ; Also update the backup file on disk so changes persist
        CC_SaveBackupFile(restoreGui.backupData, restoreGui.backupNames)
        
        ; Refresh the list and preview
        CC_FilterRestoreList(restoreGui)
        CC_UpdateRestorePreview(restoreGui)
        
        editGui.Destroy()
        TrayTip("Changes saved to backup!", newName, "1")
    }
}

CC_SaveToWorkingFile(editGui) {
    global CaptureData, CaptureNames, BaseDir
    
    ; Get the edited values
    saved := editGui.Submit(false)
    
    originalName := editGui.entryName
    newName := Trim(saved.EditName)
    restoreGui := editGui.restoreGui
    backupData := editGui.backupData
    
    ; Validate new name
    if (newName = "") {
        MsgBox("Hotstring name cannot be empty.", "Error", "48")
        return
    }
    
    ; Check for invalid characters in name
    if RegExMatch(newName, "[^\w\-]") {
        MsgBox("Hotstring name can only contain letters, numbers, underscores, and hyphens.", "Invalid Name", "48")
        return
    }
    
    ; Check name length (AHK hotstring limit)
    if (StrLen(newName) > 40) {
        MsgBox("Hotstring name must be 40 characters or less.", "Name Too Long", "48")
        return
    }
    
    ; Check if name already exists in working file
    if (CaptureData.Has(StrLower(newName))) {
        result := MsgBox("'" newName "' already exists in your working file.`n`nOverwrite it?", "Name Exists", "YesNo Icon!")
        if (result = "No")
            return
        
        ; Remove from CaptureNames to avoid duplicate
        newNames := []
        for n in CaptureNames {
            if (StrLower(n) != StrLower(newName))
                newNames.Push(n)
        }
        CaptureNames := newNames
    }
    
    ; Get original cap data for date/tags
    originalCap := backupData.Has(StrLower(originalName)) ? backupData[StrLower(originalName)] : Map()
    
    ; Create new cap with edited values
    newCap := Map()
    newCap["name"] := newName
    newCap["title"] := saved.EditTitle
    newCap["url"] := saved.EditURL
    newCap["short"] := saved.EditShort
    newCap["opinion"] := saved.EditOpinion
    newCap["note"] := saved.EditNote
    newCap["body"] := saved.EditBody
    
    ; Set date - use today if new entry, preserve original if editing
    if (originalCap.Has("date") && originalCap["date"] != "")
        newCap["date"] := originalCap["date"]
    else
        newCap["date"] := FormatTime(, "yyyy-MM-dd")
    
    ; Preserve tags from original if they exist
    if (originalCap.Has("tags"))
        newCap["tags"] := originalCap["tags"]
    
    ; Add to CaptureData and CaptureNames
    CaptureData[StrLower(newName)] := newCap
    CaptureNames.Push(newName)
    
    ; Save to captures.dat
    CC_SaveCaptureData()
    
    ; Regenerate hotstrings
    CC_GenerateHotstringFile()
    
    ; Update DynamicSuffixHandler
    DynamicSuffixHandler.Initialize(CaptureData, CaptureNames)
    
    ; Close the edit window
    editGui.Destroy()
    
    ; Refresh the restore browser list (mark this as now existing)
    try {
        CC_FilterRestoreList(restoreGui)
    }
    
    TrayTip("Saved to working file!`nHotstring ::" newName ":: ready to use.", "Saved", "1")
    
    ; Ask about reload
    result := MsgBox("'" newName "' saved to captures.dat!`n`nReload script now to activate the hotstring?", "Saved to Working File", "YesNo Iconi")
    if (result = "Yes")
        Reload()
}

CC_SaveBackupFile(backupData, backupNames) {
    global BaseDir
    
    backupFile := BaseDir "\capturesbackup.dat"
    
    content := "; ContentCapture Pro - Backup`n"
    content .= "; Updated: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n"
    content .= "; Entries: " backupNames.Length "`n`n"
    
    for name in backupNames {
        if !backupData.Has(StrLower(name))
            continue
        
        cap := backupData[StrLower(name)]
        
        content .= "[" name "]`n"
        
        if (cap.Has("url") && cap["url"] != "")
            content .= "url=" cap["url"] "`n"
        
        if (cap.Has("title") && cap["title"] != "")
            content .= "title=" cap["title"] "`n"
        
        if (cap.Has("date") && cap["date"] != "")
            content .= "date=" cap["date"] "`n"
        
        if (cap.Has("tags") && cap["tags"] != "")
            content .= "tags=" cap["tags"] "`n"
        
        if (cap.Has("note") && cap["note"] != "")
            content .= "note=" cap["note"] "`n"
        
        if (cap.Has("opinion") && cap["opinion"] != "")
            content .= "opinion=" cap["opinion"] "`n"
        
        if (cap.Has("short") && cap["short"] != "")
            content .= "short=" cap["short"] "`n"
        
        if (cap.Has("body") && cap["body"] != "") {
            content .= "body=<<<BODY`n"
            content .= cap["body"] "`n"
            content .= "BODY>>>`n"
        }
        
        content .= "`n"
    }
    
    try {
        if FileExist(backupFile)
            FileDelete(backupFile)
        FileAppend(content, backupFile, "UTF-8")
    } catch as err {
        MsgBox("Could not save backup file:`n" err.Message, "Error", "16")
    }
}

CC_RestoreSelectAll(restoreGui, selectAll) {
    listView := restoreGui["RestoreList"]
    
    row := 0
    Loop {
        row := listView.GetNext(row)
        if (row = 0)
            break
        
        if (selectAll)
            listView.Modify(row, "Check")
        else
            listView.Modify(row, "-Check")
    }
}

CC_DeleteFromBackup(restoreGui) {
    listView := restoreGui["RestoreList"]
    backupData := restoreGui.backupData
    backupNames := restoreGui.backupNames
    
    ; Collect checked items
    selectedNames := []
    
    row := 0
    Loop {
        row := listView.GetNext(row, "C")  ; C = Checked
        if (row = 0)
            break
        
        name := listView.GetText(row, 2)
        selectedNames.Push(name)
    }
    
    if (selectedNames.Length = 0) {
        MsgBox("No entries selected.`n`nCheck the boxes next to entries you want to delete.", "Nothing Selected", "48")
        return
    }
    
    ; Confirmation message
    if (selectedNames.Length = 1) {
        confirmMsg := "Delete '" selectedNames[1] "' from backup?`n`nThis cannot be undone."
    } else {
        confirmMsg := "Delete " selectedNames.Length " entries from backup?`n`n"
        showCount := Min(selectedNames.Length, 8)
        Loop showCount {
            confirmMsg .= "• " selectedNames[A_Index] "`n"
        }
        if (selectedNames.Length > 8)
            confirmMsg .= "• ... and " (selectedNames.Length - 8) " more`n"
        confirmMsg .= "`nThis cannot be undone."
    }
    
    result := MsgBox(confirmMsg, "Confirm Delete from Backup", "YesNo Icon!")
    if (result = "No")
        return
    
    ; Build set of names to delete
    deleteSet := Map()
    for name in selectedNames {
        deleteSet[StrLower(name)] := true
    }
    
    ; Remove from backupData
    for name in selectedNames {
        if backupData.Has(StrLower(name))
            backupData.Delete(StrLower(name))
    }
    
    ; Rebuild backupNames without deleted items
    newNames := []
    for n in backupNames {
        if !deleteSet.Has(StrLower(n))
            newNames.Push(n)
    }
    
    ; Update the restoreGui's backupNames reference
    restoreGui.backupNames := newNames
    
    ; Save the updated backup file
    CC_SaveBackupFile(backupData, newNames)
    
    ; Refresh the list
    CC_FilterRestoreList(restoreGui)
    
    ; Update status bar
    global CaptureData, CaptureNames
    newCount := 0
    for name in newNames {
        if !CaptureData.Has(StrLower(name))
            newCount++
    }
    restoreGui.statusText.Value := "Backup: " newNames.Length " entries | New (not in working file): " newCount " | Working file: " CaptureNames.Length " captures"
    
    if (selectedNames.Length = 1)
        TrayTip("Deleted from backup.", selectedNames[1], "1")
    else
        TrayTip(selectedNames.Length " entries deleted from backup.", "Deleted", "1")
}

CC_RestoreSelectedEntries(restoreGui) {
    global CaptureData, CaptureNames, DataFile, BaseDir
    
    listView := restoreGui["RestoreList"]
    backupData := restoreGui.backupData
    backupNames := restoreGui.backupNames
    moveToArchive := restoreGui["MoveToArchive"].Value
    
    ; Collect checked items
    selectedNames := []
    duplicates := []
    
    row := 0
    Loop {
        row := listView.GetNext(row, "C")  ; C = Checked
        if (row = 0)
            break
        
        name := listView.GetText(row, 2)
        
        ; Check for duplicate
        if CaptureData.Has(StrLower(name))
            duplicates.Push(name)
        else
            selectedNames.Push(name)
    }
    
    if (selectedNames.Length = 0 && duplicates.Length = 0) {
        MsgBox("No entries selected.`n`nCheck the boxes next to entries you want to restore.", "Nothing Selected", "48")
        return
    }
    
    ; Handle duplicates
    if (duplicates.Length > 0) {
        dupMsg := duplicates.Length " selected entries already exist in working file:`n`n"
        showCount := Min(duplicates.Length, 5)
        Loop showCount {
            dupMsg .= "• " duplicates[A_Index] "`n"
        }
        if (duplicates.Length > 5)
            dupMsg .= "• ... and " (duplicates.Length - 5) " more`n"
        
        dupMsg .= "`nSkip these and restore only new entries?"
        
        if (selectedNames.Length > 0) {
            dupMsg .= "`n`n(" selectedNames.Length " new entries will be restored)"
        } else {
            MsgBox("All selected entries already exist in your working file.`n`nUncheck existing entries or select different ones.", "All Duplicates", "48")
            return
        }
        
        result := MsgBox(dupMsg, "Duplicates Found", "YesNoCancel Icon!")
        if (result = "Cancel")
            return
        if (result = "No")
            return
    }
    
    ; Confirm restore
    confirmMsg := "Restore " selectedNames.Length " entries to your working file?`n`n"
    showCount := Min(selectedNames.Length, 8)
    Loop showCount {
        confirmMsg .= "• " selectedNames[A_Index] "`n"
    }
    if (selectedNames.Length > 8)
        confirmMsg .= "• ... and " (selectedNames.Length - 8) " more`n"
    
    if (moveToArchive)
        confirmMsg .= "`n📁 These will be moved to archive after restore."
    
    result := MsgBox(confirmMsg, "Confirm Restore", "YesNo Iconi")
    if (result = "No")
        return
    
    ; Collect entries to restore (for archive)
    restoredEntries := []
    
    ; Restore entries
    restoredCount := 0
    for name in selectedNames {
        if !backupData.Has(StrLower(name))
            continue
        
        cap := backupData[StrLower(name)]
        
        ; Add to CaptureData
        CaptureData[StrLower(name)] := cap
        CaptureNames.Push(name)
        restoredCount++
        
        ; Save for archive
        if (moveToArchive)
            restoredEntries.Push({name: name, data: cap})
    }
    
    ; Save and regenerate
    CC_SaveCaptureData()
    CC_GenerateHotstringFile()
    
    ; Update DynamicSuffixHandler
    DynamicSuffixHandler.Initialize(CaptureData, CaptureNames)
    
    ; Handle archive if checkbox was checked
    if (moveToArchive && restoredEntries.Length > 0) {
        CC_MoveToArchive(restoredEntries, backupData, backupNames)
    }
    
    CC_CloseRestoreGui(restoreGui)
    
    archiveMsg := moveToArchive ? "`nMoved to archive." : ""
    TrayTip("Restored " restoredCount " entries!" archiveMsg "`nHotstrings are ready to use.", "Restore Complete", "1")
    
    ; Ask about reload
    result := MsgBox("Restored " restoredCount " entries!" archiveMsg "`n`nReload script now to activate new hotstrings?", "Restore Complete", "YesNo Iconi")
    if (result = "Yes")
        Reload()
}

CC_MoveToArchive(restoredEntries, backupData, backupNames) {
    global BaseDir
    
    backupFile := BaseDir "\capturesbackup.dat"
    archiveFile := BaseDir "\capturesarchive.dat"
    
    ; Build a set of restored names for quick lookup
    restoredSet := Map()
    for entry in restoredEntries {
        restoredSet[StrLower(entry.name)] := true
    }
    
    ; === APPEND TO ARCHIVE ===
    archiveContent := ""
    
    ; Add header if archive doesn't exist
    if !FileExist(archiveFile) {
        archiveContent := "; ContentCapture Pro - Archive`n"
        archiveContent .= "; Entries moved from backup after restore`n"
        archiveContent .= "; Created: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n`n"
    }
    
    ; Add timestamp for this batch
    archiveContent .= "; --- Archived: " FormatTime(, "yyyy-MM-dd HH:mm:ss") " ---`n`n"
    
    ; Write each restored entry to archive
    for entry in restoredEntries {
        cap := entry.data
        name := entry.name
        
        archiveContent .= "[" name "]`n"
        
        if (cap.Has("url") && cap["url"] != "")
            archiveContent .= "url=" cap["url"] "`n"
        
        if (cap.Has("title") && cap["title"] != "")
            archiveContent .= "title=" cap["title"] "`n"
        
        if (cap.Has("date") && cap["date"] != "")
            archiveContent .= "date=" cap["date"] "`n"
        
        if (cap.Has("tags") && cap["tags"] != "")
            archiveContent .= "tags=" cap["tags"] "`n"
        
        if (cap.Has("note") && cap["note"] != "")
            archiveContent .= "note=" cap["note"] "`n"
        
        if (cap.Has("opinion") && cap["opinion"] != "")
            archiveContent .= "opinion=" cap["opinion"] "`n"
        
        if (cap.Has("short") && cap["short"] != "")
            archiveContent .= "short=" cap["short"] "`n"
        
        if (cap.Has("body") && cap["body"] != "") {
            archiveContent .= "body=<<<BODY`n"
            archiveContent .= cap["body"] "`n"
            archiveContent .= "BODY>>>`n"
        }
        
        archiveContent .= "`n"
    }
    
    ; Append to archive file
    try {
        FileAppend(archiveContent, archiveFile, "UTF-8")
    } catch as err {
        MsgBox("Could not write to archive file:`n" err.Message, "Archive Error", "48")
        return
    }
    
    ; === REWRITE BACKUP WITHOUT RESTORED ENTRIES ===
    newBackupContent := "; ContentCapture Pro - Backup`n"
    newBackupContent .= "; Updated: " FormatTime(, "yyyy-MM-dd HH:mm:ss") "`n"
    
    ; Count remaining entries
    remainingCount := 0
    for name in backupNames {
        if !restoredSet.Has(StrLower(name))
            remainingCount++
    }
    newBackupContent .= "; Entries: " remainingCount "`n`n"
    
    ; Write entries that were NOT restored
    for name in backupNames {
        ; Skip if this was restored
        if restoredSet.Has(StrLower(name))
            continue
        
        if !backupData.Has(StrLower(name))
            continue
        
        cap := backupData[StrLower(name)]
        
        newBackupContent .= "[" name "]`n"
        
        if (cap.Has("url") && cap["url"] != "")
            newBackupContent .= "url=" cap["url"] "`n"
        
        if (cap.Has("title") && cap["title"] != "")
            newBackupContent .= "title=" cap["title"] "`n"
        
        if (cap.Has("date") && cap["date"] != "")
            newBackupContent .= "date=" cap["date"] "`n"
        
        if (cap.Has("tags") && cap["tags"] != "")
            newBackupContent .= "tags=" cap["tags"] "`n"
        
        if (cap.Has("note") && cap["note"] != "")
            newBackupContent .= "note=" cap["note"] "`n"
        
        if (cap.Has("opinion") && cap["opinion"] != "")
            newBackupContent .= "opinion=" cap["opinion"] "`n"
        
        if (cap.Has("short") && cap["short"] != "")
            newBackupContent .= "short=" cap["short"] "`n"
        
        if (cap.Has("body") && cap["body"] != "") {
            newBackupContent .= "body=<<<BODY`n"
            newBackupContent .= cap["body"] "`n"
            newBackupContent .= "BODY>>>`n"
        }
        
        newBackupContent .= "`n"
    }
    
    ; Rewrite backup file
    try {
        if FileExist(backupFile)
            FileDelete(backupFile)
        FileAppend(newBackupContent, backupFile, "UTF-8")
    } catch as err {
        MsgBox("Could not update backup file:`n" err.Message, "Backup Error", "48")
    }
}

; ==============================================================================
; EDIT CAPTURE
; ==============================================================================

CC_EditCapture(name) {
    global CaptureData, AvailableTags

    if !CaptureData.Has(StrLower(name)) {
        MsgBox("Capture '" name "' not found.", "Error", "16")
        return
    }

    cap := CaptureData[StrLower(name)]

    currentURL := cap.Has("url") ? cap["url"] : ""
    currentTitle := cap.Has("title") ? cap["title"] : ""
    currentTags := cap.Has("tags") ? cap["tags"] : ""
    currentOpinion := cap.Has("opinion") ? cap["opinion"] : ""
    currentNote := cap.Has("note") ? cap["note"] : ""
    currentBody := cap.Has("body") ? cap["body"] : ""

    editGui := Gui("+Resize", "✏️ Edit: " name)
    editGui.SetFont("s10")
    editGui.BackColor := "F5F5F5"

    editGui.SetFont("s11 bold c333333")
    editGui.Add("Text", "x15 y10 w200", "::" name "::")

    editGui.SetFont("s9 norm c666666")
    editGui.Add("Text", "x15 y35", "URL:")
    editGui.SetFont("s10 norm c000000")
    editUrl := editGui.Add("Edit", "x15 y53 w670 h24 vEditURL", currentURL)

    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y85", "Title:")
    editGui.SetFont("s10 c000000")
    editTitle := editGui.Add("Edit", "x15 y103 w670 h24 vEditTitle", currentTitle)

    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y135", "Tags:")
    editGui.SetFont("s10 c000000")
    editTags := editGui.Add("Edit", "x15 y153 w400 h24 vEditTags", currentTags)

    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y185", "Opinion:")
    editGui.SetFont("s10 c000000")
    editOpinion := editGui.Add("Edit", "x15 y203 w670 h60 Multi vEditOpinion", currentOpinion)

    ; Private Note field (NEW)
    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y270", "📝 Private Note (only you see this):")
    editGui.SetFont("s10 c000000")
    editNote := editGui.Add("Edit", "x15 y288 w670 h45 Multi vEditNote", currentNote)

    editGui.SetFont("s9 c666666")
    editGui.Add("Text", "x15 y340", "Body:")
    editGui.SetFont("s8", "Segoe UI")
    formatBtn := editGui.Add("Button", "x60 y337 w90 h22", "🔧 Auto-Format")
    formatBtn.OnEvent("Click", (*) => CC_AutoFormatBody(editBody))
    editGui.SetFont("s10 c000000", "Consolas")
    editBody := editGui.Add("Edit", "x15 y358 w670 h135 Multi VScroll vEditBody", currentBody)

    editGui.SetFont("s10", "Segoe UI")
    saveBtn := editGui.Add("Button", "x15 y505 w120 h35", "💾 Save")
    saveBtn.OnEvent("Click", (*) => CC_SaveEditedCapture(editGui, name))

    cancelBtn := editGui.Add("Button", "x145 y505 w100 h35", "Cancel")
    cancelBtn.OnEvent("Click", (*) => editGui.Destroy())

    editGui.OnEvent("Close", (*) => editGui.Destroy())
    editGui.OnEvent("Escape", (*) => editGui.Destroy())

    editGui.Show("w700 h555")
}

CC_SaveEditedCapture(editGui, name) {
    global CaptureData

    saved := editGui.Submit(false)

    if CaptureData.Has(StrLower(name)) {
        CaptureData[StrLower(name)]["url"] := saved.EditURL
        CaptureData[StrLower(name)]["title"] := saved.EditTitle
        CaptureData[StrLower(name)]["tags"] := saved.EditTags
        CaptureData[StrLower(name)]["opinion"] := saved.EditOpinion
        CaptureData[StrLower(name)]["note"] := saved.EditNote  ; NOW SAVES THE NOTE!
        CaptureData[StrLower(name)]["body"] := saved.EditBody
    }

    CC_SaveCaptureData()
    editGui.Destroy()
    TrayTip("Capture '" name "' saved!", "ContentCapture Pro", "1")
    CC_ShowReadWindow(name)
}

; ==============================================================================
; AUTO-FORMAT BODY TEXT
; ==============================================================================
; Intelligently adds paragraph breaks to text that lost formatting during copy

CC_AutoFormatBody(editControl) {
    text := editControl.Value
    
    if (text = "") {
        TrayTip("No text to format", "Auto-Format", "2")
        return
    }
    
    ; First normalize existing line breaks
    text := StrReplace(text, "`r`n", "`n")
    text := StrReplace(text, "`r", "`n")
    
    ; If text already has line breaks, just clean it up
    if InStr(text, "`n`n") {
        text := CC_CleanContent(text)
        editControl.Value := text
        TrayTip("Text cleaned up!", "Auto-Format", "1")
        return
    }
    
    ; Common paragraph starters (after a period)
    starters := "I |You |We |They |He |She |It |The |This |That |These |Those |"
    starters .= "My |Your |Our |Their |His |Her |Its |"
    starters .= "In |On |At |By |For |From |With |To |"
    starters .= "However|But |And |So |Yet |Or |"
    starters .= "First|Second|Third|Finally|"
    starters .= "When |Where |What |Why |How |Who |"
    starters .= "If |Although |Because |Since |While |"
    starters .= "After |Before |During |Until |"
    starters .= "One |Two |Three |Four |Five |"
    starters .= "According |Additionally |Also |"
    starters .= "For example|For instance|In fact|"
    starters .= "Moreover|Furthermore|Therefore|Thus|Hence|"
    starters .= "As |Like |Unlike |"
    starters .= "[0-9]+\. |[0-9]+\) |• |- "
    
    ; Build regex pattern for paragraph detection
    ; Look for: period/!/? + space + capital letter that starts common patterns
    pattern := "([.!?])\s+(" starters ")"
    
    ; Replace with period + double newline + starter
    formatted := RegExReplace(text, pattern, "$1`n`n$2")
    
    ; Also break on clear topic shifts (sentences starting with "I " after any sentence)
    formatted := RegExReplace(formatted, "([.!?])\s+(I [a-z])", "$1`n`n$2")
    
    ; Clean up any triple+ newlines
    formatted := RegExReplace(formatted, "`n`n`n+", "`n`n")
    
    ; Convert to Windows line endings
    formatted := StrReplace(formatted, "`n", "`r`n")
    
    ; Update the edit control
    editControl.Value := Trim(formatted)
    
    TrayTip("Text reformatted!", "Auto-Format", "1")
}

; ==============================================================================
; RECENT WIDGET
; ==============================================================================

CC_ToggleRecentWidget() {
    global WidgetGui, WidgetVisible

    if (WidgetVisible) {
        if (WidgetGui != "")
            WidgetGui.Destroy()
        WidgetGui := ""
        WidgetVisible := false
        return
    }

    CC_ShowRecentWidget()
}

CC_ShowRecentWidget() {
    global WidgetGui, WidgetVisible, CaptureNames, CaptureData

    if (WidgetGui != "")
        WidgetGui.Destroy()

    WidgetGui := Gui("+AlwaysOnTop +ToolWindow -Caption +Border", "Recent")
    WidgetGui.SetFont("s9")
    WidgetGui.BackColor := "1a1a2e"

    WidgetGui.Add("Text", "x5 y5 w190 cWhite", "📌 Recent Captures")

    count := 0
    yPos := 25

    i := CaptureNames.Length
    while (i >= 1 && count < 5) {
        name := CaptureNames[i]
        if CaptureData.Has(StrLower(name)) {
            cap := CaptureData[StrLower(name)]
            title := cap.Has("title") ? SubStr(cap["title"], 1, 25) : name
            if (StrLen(title) > 25)
                title .= "..."

            btn := WidgetGui.Add("Button", "x5 y" yPos " w190 h22", name)
            btn.OnEvent("Click", CC_OpenWidgetURL.Bind(name))

            yPos += 24
            count++
        }
        i--
    }

    if (count = 0) {
        WidgetGui.Add("Text", "x5 y30 w190 cGray", "No captures yet.")
        yPos := 60
    }

    closeBtn := WidgetGui.Add("Button", "x5 y" yPos " w190 h20", "Close")
    closeBtn.OnEvent("Click", (*) => CC_ToggleRecentWidget())

    WidgetGui.Show("x" (A_ScreenWidth - 220) " y" (A_ScreenHeight - yPos - 80) " w200 h" (yPos + 25) " NoActivate")
    WidgetVisible := true
}

CC_OpenWidgetURL(name, *) {
    url := CC_GetCaptureURL(name)
    if (url != "")
        try Run(url)
}

CC_UpdateRecentWidget() {
    global WidgetVisible
    if (WidgetVisible)
        CC_ShowRecentWidget()
}

; ==============================================================================
; UTILITY FUNCTIONS
; ==============================================================================

CC_OpenDataFileInEditor() {
    global DataFile

    if (!FileExist(DataFile)) {
        MsgBox("No captures file yet.", "No File", "48")
        return
    }

    try Run(DataFile)
}

CC_ExportToHTML() {
    global BaseDir, CaptureData, CaptureNames

    if (CaptureNames.Length = 0) {
        MsgBox("No captures to export.", "Export", "48")
        return
    }

    htmlFile := BaseDir "\captures_export.html"

    html := "<!DOCTYPE html><html><head><meta charset='UTF-8'><title>My Captures</title>"
    html .= "<style>body{font-family:sans-serif;max-width:900px;margin:0 auto;padding:20px;background:#1a1a2e;color:#eee}"
    html .= ".card{background:#2a2a4a;padding:15px;margin:10px 0;border-radius:8px}"
    html .= ".name{color:#4a9eff;font-family:monospace}.title{font-size:1.1em;margin:5px 0}"
    html .= "a{color:#4a9eff}</style></head><body>"
    html .= "<h1>My Captures (" CaptureNames.Length ")</h1>"

    for name in CaptureNames {
        if !CaptureData.Has(StrLower(name))
            continue
        cap := CaptureData[StrLower(name)]
        url := cap.Has("url") ? cap["url"] : ""
        title := cap.Has("title") ? cap["title"] : name
        
        html .= "<div class='card'>"
        html .= "<span class='name'>" name "</span>"
        html .= "<div class='title'><a href='" url "' target='_blank'>" title "</a></div>"
        html .= "</div>"
    }

    html .= "</body></html>"

    try {
        if FileExist(htmlFile)
            FileDelete(htmlFile)
        FileAppend(html, htmlFile, "UTF-8")
        Run(htmlFile)
    } catch as err {
        MsgBox("Export failed: " err.Message, "Error", "16")
    }
}

CC_FormatTextToHotstring() {
    oldClip := ClipboardAll()
    A_Clipboard := ""

    Send("^c")
    if !ClipWait(0.5) {
        MsgBox("No text selected.", "No Text", "48")
        A_Clipboard := oldClip
        return
    }

    rawText := A_Clipboard
    cleanText := CC_CleanContent(rawText)

    nameGui := Gui("+AlwaysOnTop", "Hotstring Name")
    nameGui.Add("Text", , "Enter a short name:")
    nameEdit := nameGui.Add("Edit", "w300")
    nameGui.Add("Button", "w80 Default", "OK").OnEvent("Click", (*) => nameGui.Submit())
    nameGui.Add("Button", "x+10 w80", "Cancel").OnEvent("Click", (*) => nameGui.Destroy())
    nameGui.Show()
    WinWaitClose(nameGui.Hwnd)

    name := ""
    try name := RegExReplace(nameEdit.Value, "[\r\n\t\s]+", "")

    if (name = "") {
        A_Clipboard := oldClip
        return
    }

    timestamp := FormatTime(, "yyyy-MM-dd HH:mm:ss")
    CC_AddCapture(name, "", "Text snippet", timestamp, "", "", "", cleanText)

    A_Clipboard := oldClip
}

CC_CopyCleanPaste() {
    oldClip := ClipboardAll()
    A_Clipboard := ""

    Send("^c")
    if !ClipWait(1) {
        MsgBox("No text selected.", "No Selection", "48")
        A_Clipboard := oldClip
        return
    }

    cleanText := CC_CleanContent(A_Clipboard)

    A_Clipboard := cleanText
    ClipWait(1)
    Sleep(100)
    Send("^v")

    Sleep(500)
    A_Clipboard := oldClip
}

CC_EmailLastCapture() {
    global LastCapturedURL, LastCapturedTitle, LastCapturedBody

    if (LastCapturedURL = "") {
        MsgBox("No recent capture.", "No Content", "48")
        return
    }

    content := LastCapturedURL "`n`n" LastCapturedTitle "`n`n" LastCapturedBody
    CC_SendOutlookEmail(content)
}

CC_ResetDataFile() {
    global DataFile, ArchiveDir

    if !FileExist(DataFile) {
        MsgBox("No data file to reset.", "Not Found", "48")
        return
    }

    result := MsgBox("Reset all captures?`n`nThis will backup current data first.", "Confirm Reset", "YesNo Icon!")

    if (result = "No")
        return

    if !DirExist(ArchiveDir)
        DirCreate(ArchiveDir)

    backupFile := ArchiveDir "\captures_" FormatTime(, "yyyyMMdd_HHmmss") ".dat"

    try {
        FileCopy(DataFile, backupFile)
        FileDelete(DataFile)
        MsgBox("Reset complete!`n`nBackup: " backupFile, "Reset Complete", "64")
        Reload()
    } catch as err {
        MsgBox("Reset failed: " err.Message, "Error", "16")
    }
}

CC_ShowQuickHelp(isStartup := false) {
    helpGui := Gui("+AlwaysOnTop", "⌨️ Quick Reference")
    helpGui.SetFont("s10")
    helpGui.BackColor := "1a1a2e"

    helpGui.SetFont("s14 bold cWhite")
    helpGui.Add("Text", "x20 y15 w350 Center", "⌨️ ContentCapture Pro Help")

    helpGui.SetFont("s10 cWhite")
    yPos := 55

    commands := [
        ["Ctrl+Alt+M", "Show menu"],
        ["Ctrl+Alt+P", "Capture webpage"],
        ["Ctrl+Alt+B", "Browse captures"],
        ["Ctrl+Alt+L", "Reload script"]
    ]

    for cmd in commands {
        helpGui.Add("Text", "x20 y" yPos, cmd[1])
        helpGui.Add("Text", "x155 y" yPos " cAAAAAA", cmd[2])
        yPos += 22
    }

    yPos += 10
    helpGui.SetFont("s10 c00FFAA")
    helpGui.Add("Text", "x20 y" yPos, "HOTSTRING SUFFIXES:")
    yPos += 22

    helpGui.SetFont("s10 cWhite")
    suffixes := [
        ["name", "Paste content"],
        ["namego", "Open URL"],
        ["namerd", "Read window"],
        ["name?", "Action menu"]
    ]

    for sfx in suffixes {
        helpGui.Add("Text", "x20 y" yPos, sfx[1])
        helpGui.Add("Text", "x155 y" yPos " cAAAAAA", sfx[2])
        yPos += 22
    }

    yPos += 10
    helpGui.SetFont("s10")
    closeBtn := helpGui.Add("Button", "x140 y" yPos " w100 h30 Default", "Got it!")
    closeBtn.OnEvent("Click", (*) => helpGui.Destroy())

    helpGui.OnEvent("Close", (*) => helpGui.Destroy())
    helpGui.OnEvent("Escape", (*) => helpGui.Destroy())

    helpGui.Show("w390 h" (yPos + 50))
}

; ==============================================================================
; TEXT CLEANING
; ==============================================================================

CC_CleanURL(url) {
    ; Tracking parameters to remove from all URLs
    trackingParams := "utm_source,utm_medium,utm_campaign,utm_term,utm_content,fbclid,gclid,msclkid,_ga,si"
    
    ; YouTube timestamp parameters - these make videos start mid-way through
    ; We want clean URLs that start from the beginning
    youtubeTimeParams := "t,start,time_continue"

    if !InStr(url, "?")
        return url

    parts := StrSplit(url, "?", , 2)
    baseUrl := parts[1]
    queryString := parts.Length > 1 ? parts[2] : ""

    if (queryString = "")
        return baseUrl

    ; Determine if this is a YouTube URL
    isYouTube := RegExMatch(url, "i)youtube\.com|youtu\.be")
    
    ; Combine params to strip based on URL type
    paramsToStrip := trackingParams
    if (isYouTube)
        paramsToStrip .= "," youtubeTimeParams

    params := StrSplit(queryString, "&")
    cleanParams := ""

    for param in params {
        shouldRemove := false
        for stripParam in StrSplit(paramsToStrip, ",") {
            if (InStr(param, stripParam "=") = 1) {
                shouldRemove := true
                break
            }
        }
        if (!shouldRemove)
            cleanParams .= (cleanParams ? "&" : "") param
    }

    return baseUrl (cleanParams ? "?" cleanParams : "")
}

; ------------------------------------------------------------------------------
; CC_ParseTimestamp(timestamp)
; ------------------------------------------------------------------------------
; PURPOSE: Convert a timestamp string to seconds for YouTube URLs
;
; FORMATS SUPPORTED:
;   "1:30"     → 90 seconds (1 min 30 sec)
;   "1:15:30"  → 4530 seconds (1 hr 15 min 30 sec)
;   "90"       → 90 seconds (just seconds)
;   "2:05"     → 125 seconds
;
; RETURNS: Integer seconds, or 0 if invalid format
; ------------------------------------------------------------------------------
CC_ParseTimestamp(timestamp) {
    timestamp := Trim(timestamp)
    
    ; If just a number, assume seconds
    if RegExMatch(timestamp, "^\d+$")
        return Integer(timestamp)
    
    ; Parse MM:SS or HH:MM:SS format
    parts := StrSplit(timestamp, ":")
    
    if (parts.Length = 2) {
        ; MM:SS format
        minutes := Integer(parts[1])
        seconds := Integer(parts[2])
        return (minutes * 60) + seconds
    }
    else if (parts.Length = 3) {
        ; HH:MM:SS format
        hours := Integer(parts[1])
        minutes := Integer(parts[2])
        seconds := Integer(parts[3])
        return (hours * 3600) + (minutes * 60) + seconds
    }
    
    return 0  ; Invalid format
}

CC_GetPageTitle(title := "") {
    if (title = "")
        title := WinGetTitle("A")

    ; Remove browser names
    browsers := ["Google Chrome", "Mozilla Firefox", "LibreWolf", "Microsoft Edge", "Opera", "Brave", "Firefox", "Chrome"]
    for browser in browsers {
        title := RegExReplace(title, " - " browser "$", "")
        title := RegExReplace(title, " " browser "$", "")
    }

    title := RegExReplace(title, " - YouTube$", "")
    title := RegExReplace(title, "^\(\d+\)\s*", "")

    return Trim(title)
}

CC_CleanContent(text) {
    ; First, normalize all line break styles to `n
    text := StrReplace(text, "`r`n", "`n")      ; Windows CRLF → LF
    text := StrReplace(text, "`r", "`n")        ; Old Mac CR → LF
    
    ; Replace multiple spaces/tabs (but NOT line breaks) with single space
    text := RegExReplace(text, "[ \t]+", " ")
    
    ; Clean up lines: trim trailing spaces from each line
    text := RegExReplace(text, " +`n", "`n")
    text := RegExReplace(text, "`n +", "`n")
    
    ; Normalize multiple blank lines to max 2 line breaks (one blank line)
    text := RegExReplace(text, "`n`n`n+", "`n`n")
    
    ; Convert back to Windows line endings for Edit controls
    text := StrReplace(text, "`n", "`r`n")
    
    return Trim(text)
}

; ==============================================================================
; SHARING
; ==============================================================================

CC_SendOutlookEmail(content) {
    try {
        outlook := ComObject("Outlook.Application")
        mail := outlook.CreateItem(0)
        mail.Body := content
        mail.Display()
    } catch as err {
        MsgBox("Could not create email: " err.Message, "Error", "16")
    }
}

CC_ShareToFacebook(content) {
    url := StrSplit(content, "`n")[1]
    Run("https://www.facebook.com/sharer/sharer.php?u=" CC_UrlEncode(url))
    A_Clipboard := content
    TrayTip("Content copied!", "Facebook", "1")
}

CC_ShareToTwitter(content) {
    lines := StrSplit(content, "`n")
    url := lines.Has(1) ? lines[1] : ""
    title := lines.Has(2) ? lines[2] : ""
    Run("https://twitter.com/intent/tweet?text=" CC_UrlEncode(title " " url))
}

CC_ShareToBluesky(content) {
    lines := StrSplit(content, "`n")
    url := lines.Has(1) ? lines[1] : ""
    title := lines.Has(2) ? lines[2] : ""
    Run("https://bsky.app/intent/compose?text=" CC_UrlEncode(title " " url))
    A_Clipboard := content
    TrayTip("Content copied!", "Bluesky", "1")
}

CC_ShareToLinkedIn(content) {
    url := StrSplit(content, "`n")[1]
    Run("https://www.linkedin.com/sharing/share-offsite/?url=" CC_UrlEncode(url))
}

CC_ShareToMastodon(content) {
    lines := StrSplit(content, "`n")
    url := lines.Has(1) ? lines[1] : ""
    title := lines.Has(2) ? lines[2] : ""
    Run("https://mastodonshare.com/?text=" CC_UrlEncode(title " " url))
}

CC_UrlEncode(str) {
    encoded := ""
    Loop Parse, str {
        char := A_LoopField
        if RegExMatch(char, "[a-zA-Z0-9_.~-]")
            encoded .= char
        else
            encoded .= "%" Format("{:02X}", Ord(char))
    }
    return encoded
}

; ==============================================================================
; HELP SYSTEM - Contextual tips, tutorials, and guidance
; ==============================================================================

class CCHelp {
    ; Track what user has done (for contextual tips)
    static hasCaputredFirst := false
    static hasUsedHotstring := false
    static hasUsedBrowser := false
    static tipCount := 0
    static maxTipsPerSession := 3
    
    ; ==== FIRST RUN TUTORIAL ====
    static ShowFirstRunTutorial() {
        tutGui := Gui("+AlwaysOnTop", "Welcome to ContentCapture Pro!")
        tutGui.SetFont("s11")
        tutGui.BackColor := "FFFFFF"
        
        tutGui.SetFont("s16 bold")
        tutGui.Add("Text", "w450 Center", "👋 Welcome!")
        
        tutGui.SetFont("s11 norm")
        tutGui.Add("Text", "w450 y+15", "ContentCapture Pro lets you save any webpage and instantly recall it by typing a short name.")
        tutGui.Add("Text", "w450 y+15", "Let me show you how it works in 3 quick steps...")
        
        tutGui.Add("Button", "w150 h35 y+20 Default", "Start Tutorial →").OnEvent("Click", (*) => this.TutorialStep1(tutGui))
        tutGui.Add("Button", "x+20 w150 h35", "Skip Tutorial").OnEvent("Click", (*) => this.SkipTutorial(tutGui))
        
        tutGui.Show()
    }
    
    static TutorialStep1(prevGui) {
        prevGui.Destroy()
        
        tutGui := Gui("+AlwaysOnTop", "Step 1 of 3: Capturing")
        tutGui.SetFont("s11")
        tutGui.BackColor := "F0F8FF"
        
        tutGui.SetFont("s14 bold")
        tutGui.Add("Text", "w450", "📸 Step 1: Capture a Webpage")
        
        tutGui.SetFont("s11 norm")
        tutGui.Add("Text", "w450 y+15", "1. Go to any webpage in your browser")
        tutGui.Add("Text", "w450 y+5", "2. Highlight text you want to save (optional)")
        tutGui.Add("Text", "w450 y+5", "3. Press  Ctrl + Alt + P")
        tutGui.Add("Text", "w450 y+5", "4. Give it a short name like 'recipe' or 'article'")
        
        tutGui.SetFont("s10 c666666")
        tutGui.Add("Text", "w450 y+15", "💡 Tip: Short names are easier to remember!")
        
        tutGui.SetFont("s11 norm")
        tutGui.Add("Button", "w100 h35 y+20", "← Back").OnEvent("Click", (*) => (tutGui.Destroy(), this.ShowFirstRunTutorial()))
        tutGui.Add("Button", "x+20 w150 h35 Default", "Next: Using →").OnEvent("Click", (*) => this.TutorialStep2(tutGui))
        
        tutGui.Show()
    }
    
    static TutorialStep2(prevGui) {
        prevGui.Destroy()
        
        tutGui := Gui("+AlwaysOnTop", "Step 2 of 3: Using Captures")
        tutGui.SetFont("s11")
        tutGui.BackColor := "F0FFF0"
        
        tutGui.SetFont("s14 bold")
        tutGui.Add("Text", "w450", "⌨️ Step 2: Use Your Captures")
        
        tutGui.SetFont("s11 norm")
        tutGui.Add("Text", "w450 y+15", "Once saved, type the name with colons to paste it:")
        
        tutGui.SetFont("s13 bold c0066CC")
        tutGui.Add("Text", "w450 y+15 Center", "::recipe::")
        
        tutGui.SetFont("s11 norm")
        tutGui.Add("Text", "w450 y+10", "That's it! The content appears instantly.")
        
        tutGui.Add("Text", "w450 y+15", "Add suffixes for more options:")
        tutGui.SetFont("s10")
        tutGui.Add("Text", "w450 y+5", "  ::recipe?::   → Shows action menu")
        tutGui.Add("Text", "w450 y+3", "  ::recipeem::  → Email it")
        tutGui.Add("Text", "w450 y+3", "  ::recipego::  → Open the URL")
        
        tutGui.SetFont("s11 norm")
        tutGui.Add("Button", "w100 h35 y+20", "← Back").OnEvent("Click", (*) => this.TutorialStep1(tutGui))
        tutGui.Add("Button", "x+20 w150 h35 Default", "Next: Sharing →").OnEvent("Click", (*) => this.TutorialStep3(tutGui))
        
        tutGui.Show()
    }
    
    static TutorialStep3(prevGui) {
        prevGui.Destroy()
        
        tutGui := Gui("+AlwaysOnTop", "Step 3 of 3: Sharing")
        tutGui.SetFont("s11")
        tutGui.BackColor := "FFF0F5"
        
        tutGui.SetFont("s14 bold")
        tutGui.Add("Text", "w450", "🚀 Step 3: Share Anywhere")
        
        tutGui.SetFont("s11 norm")
        tutGui.Add("Text", "w450 y+15", "Share to social media with suffixes:")
        
        tutGui.SetFont("s10")
        tutGui.Add("Text", "w450 y+10", "  ::recipefb::  → Facebook")
        tutGui.Add("Text", "w450 y+3", "  ::recipex::   → Twitter/X")
        tutGui.Add("Text", "w450 y+3", "  ::recipebs::  → Bluesky")
        tutGui.Add("Text", "w450 y+3", "  ::recipeli::  → LinkedIn")
        
        tutGui.SetFont("s11 norm")
        tutGui.Add("Text", "w450 y+15", "If content is too long, you'll get an edit window.")
        
        tutGui.SetFont("s10 c666666")
        tutGui.Add("Text", "w450 y+15", "💡 Press Ctrl+Alt+F12 anytime for help!")
        
        tutGui.SetFont("s11 norm")
        tutGui.Add("Button", "w100 h35 y+20", "← Back").OnEvent("Click", (*) => this.TutorialStep2(tutGui))
        tutGui.Add("Button", "x+20 w150 h35 Default", "🎉 Start Using!").OnEvent("Click", (*) => this.FinishTutorial(tutGui))
        
        tutGui.Show()
    }
    
    static FinishTutorial(prevGui) {
        prevGui.Destroy()
        global ConfigFile
        try {
            IniWrite("1", ConfigFile, "Settings", "TutorialComplete")
        }
        
        MsgBox("You're all set! 🎉`n`n"
            . "Quick reference:`n"
            . "• Ctrl+Alt+P → Capture webpage`n"
            . "• Ctrl+Alt+B → Browse captures`n"
            . "• Ctrl+Alt+Space → Quick search`n"
            . "• Ctrl+Alt+F12 → Show help`n`n"
            . "Try capturing your first webpage now!",
            "Tutorial Complete", "64")
    }
    
    static SkipTutorial(prevGui) {
        prevGui.Destroy()
        global ConfigFile
        try {
            IniWrite("1", ConfigFile, "Settings", "TutorialComplete")
        }
        TrayTip("Press Ctrl+Alt+F12 anytime for help!", "ContentCapture Pro", "1")
    }
    
    ; ==== CONTEXTUAL TIPS ====
    static ShowTip(message, title := "💡 Tip") {
        if (this.tipCount >= this.maxTipsPerSession)
            return
        this.tipCount++
        TrayTip(message, title, "1")
    }
    
    static TipAfterFirstCapture(name) {
        if (this.hasCaputredFirst)
            return
        this.hasCaputredFirst := true
        this.ShowTip("Type ::" name ":: anywhere to paste it!`nOr ::" name "?:: for more options.", "First Capture! 🎉")
    }
    
    static TipAfterFirstHotstring() {
        if (this.hasUsedHotstring)
            return
        this.hasUsedHotstring := true
        this.ShowTip("Add 'em' to email: ::nameem::`nAdd 'go' to open URL: ::namego::", "Hotstring Tip ⌨️")
    }
    
    static TipAfterFirstBrowse() {
        if (this.hasUsedBrowser)
            return
        this.hasUsedBrowser := true
        SetTimer(() => TrayTip("Double-click any capture to paste it!`nOr select and use the buttons below.", "Browser Tip 🔍", "1"), -2000)
    }
    
    ; ==== CHECK IF TUTORIAL NEEDED ====
    static ShouldShowTutorial() {
        global ConfigFile
        try {
            complete := IniRead(ConfigFile, "Settings", "TutorialComplete", "0")
            return complete != "1"
        } catch {
            return true
        }
    }
    
    ; ==== ENHANCED QUICK HELP ====
    static ShowQuickHelp() {
        helpGui := Gui("+AlwaysOnTop", "📚 ContentCapture Pro Help")
        helpGui.SetFont("s10")
        helpGui.BackColor := "FFFFFF"
        
        tabs := helpGui.Add("Tab3", "w520 h420", ["⌨️ Shortcuts", "📝 Suffixes", "🚀 Sharing", "❓ FAQ"])
        
        ; Tab 1: Shortcuts
        tabs.UseTab(1)
        helpGui.SetFont("s11 bold")
        helpGui.Add("Text", "x20 y50 w480", "Keyboard Shortcuts")
        helpGui.SetFont("s10 norm")
        
        shortcuts := [
            ["Ctrl+Alt+P", "Capture current webpage"],
            ["Ctrl+Alt+B", "Browse all captures"],
            ["Ctrl+Alt+Shift+B", "Restore from backup"],
            ["Ctrl+Alt+Space", "Quick search"],
            ["Ctrl+Alt+N", "Manual capture (no browser)"],
            ["Ctrl+Alt+M", "Show main menu"],
            ["Ctrl+Alt+E", "Email last capture"],
            ["Ctrl+Alt+L", "Reload script"],
            ["Ctrl+Alt+K", "Backup captures"],
            ["Ctrl+Alt+F12", "Show this help"]
        ]
        
        yPos := 75
        for item in shortcuts {
            helpGui.Add("Text", "x20 y" yPos " w130 c0066CC", item[1])
            helpGui.Add("Text", "x160 y" yPos " w350", item[2])
            yPos += 24
        }
        
        ; Tab 2: Suffixes
        tabs.UseTab(2)
        helpGui.SetFont("s11 bold")
        helpGui.Add("Text", "x20 y50 w480", "Hotstring Suffixes")
        helpGui.SetFont("s10 norm c666666")
        helpGui.Add("Text", "x20 y75 w480", "Type ::name:: with these letters before the last ::")
        
        helpGui.SetFont("s10 norm c000000")
        suffixes := [
            ["::name::", "Paste full content"],
            ["::name?::", "Show action menu"],
            ["::nameem::", "Email via Outlook"],
            ["::namego::", "Open URL in browser"],
            ["::namerd::", "Read in popup window"],
            ["::namevi::", "View/Edit capture"]
        ]
        
        yPos := 105
        for item in suffixes {
            helpGui.Add("Text", "x20 y" yPos " w130 c0066CC", item[1])
            helpGui.Add("Text", "x160 y" yPos " w350", item[2])
            yPos += 26
        }
        
        ; Tab 3: Sharing
        tabs.UseTab(3)
        helpGui.SetFont("s11 bold")
        helpGui.Add("Text", "x20 y50 w480", "Social Media Sharing")
        helpGui.SetFont("s10 norm")
        
        social := [
            ["::namefb::", "Share to Facebook"],
            ["::namex::", "Share to Twitter/X"],
            ["::namebs::", "Share to Bluesky"],
            ["::nameli::", "Share to LinkedIn"],
            ["::namemt::", "Share to Mastodon"]
        ]
        
        yPos := 80
        for item in social {
            helpGui.Add("Text", "x20 y" yPos " w130 c0066CC", item[1])
            helpGui.Add("Text", "x160 y" yPos " w350", item[2])
            yPos += 26
        }
        
        helpGui.SetFont("s10 c666666")
        helpGui.Add("Text", "x20 y" (yPos + 20) " w480", 
            "💡 If content exceeds the character limit, you'll get an edit window. Check 'Save as short version' to reuse it.")
        
        ; Tab 4: FAQ
        tabs.UseTab(4)
        helpGui.SetFont("s11 bold")
        helpGui.Add("Text", "x20 y50 w480", "Frequently Asked Questions")
        helpGui.SetFont("s10 norm")
        
        helpGui.SetFont("s10 bold")
        helpGui.Add("Text", "x20 y80 w480", "Q: Where are my captures saved?")
        helpGui.SetFont("s10 norm c666666")
        helpGui.Add("Text", "x20 y98 w480", "A: In captures.dat - a plain text file you can open in any editor.")
        
        helpGui.SetFont("s10 bold c000000")
        helpGui.Add("Text", "x20 y130 w480", "Q: How do I edit a capture?")
        helpGui.SetFont("s10 norm c666666")
        helpGui.Add("Text", "x20 y148 w480", "A: Type ::name?:: for the menu, or ::namevi:: to edit directly.")
        
        helpGui.SetFont("s10 bold c000000")
        helpGui.Add("Text", "x20 y180 w480", "Q: Why doesn't my hotstring work?")
        helpGui.SetFont("s10 norm c666666")
        helpGui.Add("Text", "x20 y198 w480", "A: Make sure you type :: before AND after. Example: ::myname::")
        
        helpGui.SetFont("s10 bold c000000")
        helpGui.Add("Text", "x20 y230 w480", "Q: How do I delete a capture?")
        helpGui.SetFont("s10 norm c666666")
        helpGui.Add("Text", "x20 y248 w480", "A: Open Browser (Ctrl+Alt+B), select it, click Delete.")
        
        tabs.UseTab()
        
        helpGui.Add("Button", "x210 y440 w120 h30 Default", "Close").OnEvent("Click", (*) => helpGui.Destroy())
        helpGui.Show("w540 h490")
    }
}

; ==============================================================================
; DEVELOPER NOTES - For Those Who Want to Modify This Code
; ==============================================================================
;
; NAMING CONVENTIONS:
;   All functions start with "CC_" (ContentCapture) to avoid conflicts
;   when this file is #Included into other scripts.
;
; GUI PATTERNS:
;   Most GUIs follow this pattern:
;   1. Create Gui with options (+AlwaysOnTop, +Resize, etc.)
;   2. Set font and background color
;   3. Add controls with event handlers
;   4. Define nested functions for button actions
;   5. Show the GUI
;
; EVENT HANDLING:
;   We use fat arrow syntax for simple handlers:
;     button.OnEvent("Click", (*) => DoSomething())
;   
;   And named functions for complex handlers:
;     button.OnEvent("Click", HandleButtonClick)
;     HandleButtonClick(*) { ... complex logic ... }
;
; DATA STORAGE:
;   CaptureData is a Map where:
;     Key = lowercase capture name
;     Value = Map with keys: name, url, title, date, tags, note, opinion, body, short
;   
;   CaptureNames is an Array of all capture names (for ordered iteration)
;
; ADDING A NEW SUFFIX:
;   1. Add pattern in DynamicSuffixHandler.ahk
;   2. Create CC_HotstringXXX(name) function in this file
;   3. Update the help documentation
;
; ADDING A NEW SOCIAL PLATFORM:
;   1. Add pattern to socialPatterns in CC_DetectSocialMedia()
;   2. Add character limit to CC_GetSocialMediaLimit()
;   3. Add friendly name to CC_GetSocialMediaName()
;   4. If platform shortens URLs, add to urlLength map in CC_CountSocialChars()
;   5. If platform has title suffix (e.g., " - NewPlatform"), add to CC_CleanTitleForSocial()
;
; DEBUGGING TIPS:
;   • Use ToolTip("debug message") for quick debugging
;   • Use OutputDebug("message") for console output (view with DebugView)
;   • Add MsgBox() calls to trace execution flow
;   • Check A_LastError after WinHttp calls for API issues
;
; COMMON ISSUES:
;   Q: Hotstrings not triggering?
;   A: Check that ContentCapture_Generated.ahk was created and #Included
;
;   Q: Social media not detected?
;   A: Window title might not contain expected pattern — add new pattern
;
;   Q: Character count wrong?
;   A: Platform may have changed URL counting rules — check their docs
;
;   Q: Capture data not saving?
;   A: Check file permissions on captures.dat, ensure UTF-8 encoding
;
; TESTING CHANGES:
;   Press Ctrl+Alt+L to reload the script after making changes.
;   This reloads from disk and re-generates hotstrings.
;
; ==============================================================================

; ==============================================================================
; INCLUDE GENERATED HOTSTRINGS
; Uses relative path for portability
; ==============================================================================

#Include *i ContentCapture_Generated.ahk

