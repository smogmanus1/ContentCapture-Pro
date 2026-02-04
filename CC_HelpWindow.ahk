#Requires AutoHotkey v2.0+

; ==============================================================================
; CC_HelpWindow.ahk - In-App Help Reference for ContentCapture Pro
; ==============================================================================
; Non-modal, always-on-top help window that stays open while users work.
; Accessed via the Help button (?) in the Capture Browser.
;
; Features:
;   - Tabbed interface: Quick Start, Suffixes, Browser, Hotkeys, Tips
;   - Always-on-top so it floats above the Capture Browser
;   - Non-modal: users can click back to Browser and keep working
;   - Remembers position between opens
;   - Search/filter within help content
;
; Integration:
;   Add this button to your Capture Browser button bar:
;     browserGui.Add("Button", "x__ y__ w30", "❓").OnEvent("Click", (*) => CC_ShowHelp())
;
;   And #Include this file in your main script:
;     #Include CC_HelpWindow.ahk
; ==============================================================================

class CC_Help {
    static helpGui := ""
    static tabCtrl := ""
    static isOpen := false
    static lastX := ""
    static lastY := ""
    
    ; ================================================================
    ; Show the help window (toggle on/off)
    ; ================================================================
    static Show() {
        ; Toggle off if already open
        if (this.isOpen) {
            try this.helpGui.Destroy()
            this.isOpen := false
            return
        }
        
        this.BuildGUI()
    }
    
    ; ================================================================
    ; Build the tabbed help GUI
    ; ================================================================
    static BuildGUI() {
        ; Destroy any existing instance
        try this.helpGui.Destroy()
        
        hg := Gui("+AlwaysOnTop -MinimizeBox +Resize", "ContentCapture Pro - Quick Reference")
        hg.BackColor := "FFFFFF"
        hg.SetFont("s10", "Segoe UI")
        this.helpGui := hg
        
        ; --- Tab control ---
        tabs := hg.Add("Tab3", "x5 y5 w470 h520", [
            "🚀 Quick Start",
            "🔤 Suffixes", 
            "🖥️ Browser",
            "⌨️ Hotkeys",
            "💡 Tips"
        ])
        this.tabCtrl := tabs
        
        ; ============================================================
        ; TAB 1: Quick Start
        ; ============================================================
        tabs.UseTab(1)
        
        quickStartText := "
        (
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HOW CONTENTCAPTURE PRO WORKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

① CAPTURE  —  Press Ctrl+Alt+G on any webpage
   → Saves: URL, page title, highlighted text
   → You give it a short, memorable name

② RECALL  —  Type that name anywhere, anytime
   → The captured content is instantly pasted

③ SHARE  —  Add a suffix for instant actions
   → Type: mycaptureem  → Emails it
   → Type: mycapturego  → Opens the URL
   → Type: mycapturegpt → Sends to ChatGPT


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  EXAMPLE WORKFLOW
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

You find a great article about climate change.

1. Highlight a key paragraph
2. Press Ctrl+Alt+G
3. Name it: climarticle
4. Done! Now anywhere you can type:

   climarticle      → Pastes the full content
   climarticleem    → Emails it to someone
   climarticlegpt   → Asks ChatGPT about it
   climarticlego    → Opens the original URL
   climarticlefb    → Shares on Facebook


━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CAPTURE BROWSER  (this window!)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Press Ctrl+Alt+B to open the Capture Browser.
Search, sort, tag, and manage all your captures.
See the "Browser" tab for button details.
        )"
        
        hg.Add("Edit", "x15 y35 w450 h480 ReadOnly -WantReturn +Multi", quickStartText)
        
        ; ============================================================
        ; TAB 2: Suffix Reference
        ; ============================================================
        tabs.UseTab(2)
        
        suffixText := "
        (
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  22 SUFFIX ACTIONS PER CAPTURE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Type your capture name + suffix to trigger.
Example capture name: mysite

BASIC ACTIONS
─────────────────────────────────
  mysite          Paste full content
  mysitem         Show in message box
  mysitego        Open URL in browser
  mysitecp        Copy only (no paste)

CONTENT PARTS
─────────────────────────────────
  mysitet         Title only
  mysiteurl       URL only
  mysitebody      Body/notes only
  mysitesh        Short version

EMAIL & SHARING
─────────────────────────────────
  mysiteem        Email via Outlook
  mysitefb        Share to Facebook
  mysitex         Share to Twitter/X
  mysitebs        Share to Bluesky
  mysiteli        Share to LinkedIn
  mysitemt        Share to Mastodon
  mysitered       Share to Reddit

AI INTEGRATION
─────────────────────────────────
  mysitegpt       Send to ChatGPT
  mysiteclaude    Send to Claude
  mysiteperp      Send to Perplexity
  mysiteollama    Send to local Ollama

IMAGE ACTIONS
─────────────────────────────────
  mysiteimg       Copy image path
  mysitepic       Open attached image
  mysiteimgc      Copy image to clipboard

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  HOW SUFFIXES WORK
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Suffixes are appended directly to your 
capture name with no spaces or separators.

  ✓  mysiteem      (correct)
  ✗  mysite em     (won't work - space)
  ✗  mysite.em     (won't work - dot)
        )"
        
        hg.Add("Edit", "x15 y35 w450 h480 ReadOnly -WantReturn +Multi", suffixText)
        
        ; ============================================================
        ; TAB 3: Browser Buttons
        ; ============================================================
        tabs.UseTab(3)
        
        browserText := "
        (
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  CAPTURE BROWSER BUTTONS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Open the Browser with Ctrl+Alt+B

ROW 1 — Action Buttons
─────────────────────────────────
  🌐 Open      Open URL in your browser
  📋 Copy      Copy content to clipboard
  📧 Email     Create email with content
  ⭐ Fav       Toggle favorite status
  ❓ Hotstring Show hotstring name & suffixes
  📖 Read      Read content in viewer
  ✏️ Edit      Edit the capture details
  🗑️ Del       Delete the capture
  📷 Img       Attach or view an image
  🔬 Research  Fact-check & research tools
  ❓ Help      This help window (also F1)

ROW 2 — Management Buttons
─────────────────────────────────
  ➕ New       Create a new capture manually
  🔗 Link      Copy the URL only
  👁 Preview   Preview formatted content
  🔄 Refresh   Reload captures from file
  📤 Share     Export captures (.ccp file)
  📥 Import    Import captures (Ctrl+I)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  KEYBOARD SHORTCUTS (in Browser)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Enter        Paste selected capture
  Delete       Delete selected capture
  Ctrl+F       Jump to search box
  Ctrl+S       Share/export capture
  Ctrl+I       Import captures
  Ctrl+D       Duplicate selected capture
  F1           Open this help window
  Escape       Close the browser
  Double-click Open URL in browser

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  SEARCH & FILTER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Search box   Fuzzy search by name/title
  Tag dropdown Filter by tag category
  Filter btn   Apply tag filter
  Column click Sort by that column
  ⭐ column    Click to toggle favorite
        )"
        
        hg.Add("Edit", "x15 y35 w450 h480 ReadOnly -WantReturn +Multi", browserText)
        
        ; ============================================================
        ; TAB 4: Global Hotkeys
        ; ============================================================
        tabs.UseTab(4)
        
        hotkeyText := "
        (
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  GLOBAL KEYBOARD SHORTCUTS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
These work anywhere in Windows:

CAPTURE & BROWSE
─────────────────────────────────
  Ctrl+Alt+G    Capture webpage content
                (URL + title + selection)

  Ctrl+Alt+B    Open Capture Browser
                (search & manage captures)

  Ctrl+Alt+N    New manual capture
                (type in content by hand)

  Ctrl+Alt+Space  Quick Search captures

TOOLS & UTILITIES
─────────────────────────────────
  Ctrl+Alt+M    Main menu
  Ctrl+Alt+A    AI Assist menu
  Ctrl+Alt+O    Open data file in editor
  Ctrl+Alt+W    Toggle Recent Captures widget
  Ctrl+Alt+H    Export captures to HTML
  Ctrl+Alt+K    Backup captures
  Ctrl+Alt+E    Email last capture
  Ctrl+Alt+C    Copy, clean, and paste text
  Ctrl+Alt+F    Format text to hotstring
  Ctrl+Alt+S    Open settings
  Ctrl+Alt+R    Reset data file
  Ctrl+Alt+F12  Quick Help popup

  Ctrl+Alt+Shift+B  Restore Browser
                     (recover deleted captures)

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  INSIDE CAPTURE BROWSER
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Enter         Paste selected capture
  Delete        Delete selected capture
  Ctrl+F        Jump to search box
  Ctrl+S        Share/export
  Ctrl+I        Import
  Ctrl+D        Duplicate capture
  F1            Open help window
  Escape        Close browser

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  IN ANY TEXT FIELD
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

  Type capture name → content appears
  Add suffix → triggers that action
  
  Example:
    mycap        → pastes content
    mycapem      → emails it
    mycapgo      → opens URL
        )"
        
        hg.Add("Edit", "x15 y35 w450 h480 ReadOnly -WantReturn +Multi", hotkeyText)
        
        ; ============================================================
        ; TAB 5: Tips & Tricks
        ; ============================================================
        tabs.UseTab(5)
        
        tipsText := "
        (
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
  TIPS & TRICKS
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

NAMING YOUR CAPTURES
─────────────────────────────────
Keep names short and memorable!

  ✓  climart     (climate article)
  ✓  taxref      (tax reference)
  ✓  momrecipe   (mom's recipe)
  ✗  this-is-a-really-long-name

Tip: Use abbreviations you'll remember.
Think "what would I type to find this?"


POWER USER WORKFLOW
─────────────────────────────────
1. Capture everything interesting
   (you can organize later)

2. Use tags to categorize
   (politics, recipes, work, etc.)

3. Star your favorites ⭐
   (quick access to your best stuff)

4. Use suffixes for speed
   (skip menus entirely!)


SOCIAL MEDIA TIPS
─────────────────────────────────
• URL order matters for preview cards
  The LAST URL generates the thumbnail

• Video URLs should be last in content
  for proper thumbnail display

• Use 'sh' suffix for short versions
  that fit character limits


AI RESEARCH
─────────────────────────────────
• 'gpt' suffix opens ChatGPT with
  your capture content pre-loaded

• 'claude' does the same for Claude

• 'perp' sends to Perplexity for
  fact-checking with sources

• 'ollama' uses your local AI
  (no data leaves your computer)


BACKUP & SHARING
─────────────────────────────────
• Ctrl+S in Browser = Export captures
• Share .ccp files with other users
• Ctrl+I = Import captures from others
• Your data file is a simple text file
  (easy to back up!)
        )"
        
        hg.Add("Edit", "x15 y35 w450 h480 ReadOnly -WantReturn +Multi", tipsText)
        
        ; --- End tabs ---
        tabs.UseTab(0)
        
        ; --- Bottom bar: Close button ---
        hg.Add("Button", "x190 y535 w100", "Got It!").OnEvent("Click", (*) => this.Close())
        
        ; --- Events ---
        hg.OnEvent("Close", (*) => this.Close())
        hg.OnEvent("Size", (guiObj, minMax, w, h) => this.OnResize(guiObj, minMax, w, h))
        
        ; --- Show (remember position or default to right side) ---
        if (this.lastX != "" && this.lastY != "") {
            hg.Show("w480 h570 x" this.lastX " y" this.lastY)
        } else {
            ; Position to the right of the Capture Browser by default
            hg.Show("w480 h570")
        }
        
        this.isOpen := true
    }
    
    ; ================================================================
    ; Handle resize - stretch Edit controls to fill tab
    ; ================================================================
    static OnResize(guiObj, minMax, w, h) {
        if (minMax = -1)  ; Minimized
            return
        
        ; Resize the tab control
        try this.tabCtrl.Move(, , w - 10, h - 50)
        
        ; Resize all Edit controls within tabs
        for ctrl in guiObj {
            if (ctrl.Type = "Edit") {
                ctrl.Move(, , w - 30, h - 90)
            }
        }
    }
    
    ; ================================================================
    ; Close and remember position
    ; ================================================================
    static Close() {
        try {
            ; Save position for next open
            this.helpGui.GetPos(&x, &y)
            this.lastX := x
            this.lastY := y
            this.helpGui.Destroy()
        }
        this.isOpen := false
    }
}

; ==============================================================================
; Public function for easy button binding
; ==============================================================================
CC_ShowHelp() {
    CC_Help.Show()
}
