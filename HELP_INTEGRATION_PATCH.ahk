; ==============================================================================
; HELP BUTTON INTEGRATION PATCH - ContentCapture Pro v6.2.1
; ==============================================================================
; This file shows exactly what to add to your existing code.
; DO NOT run this file directly - follow the steps below.
; ==============================================================================


; ==============================================================================
; STEP 1: Add #Include to your main script (near your other #Include lines)
; ==============================================================================

#Include CC_HelpWindow.ahk


; ==============================================================================
; STEP 2: Add the Help button to your Capture Browser button bar
; ==============================================================================
;
; In CC_ShowBrowser() or wherever your buttons are defined (around line 2468),
; find the ROW 1 buttons. Add the Help button BEFORE the Close button.
;
; CURRENT (your existing line):
;   browserGui.Add("Button", "x530 y405 w70", "🔬 Research").OnEvent("Click", ...)
;   browserGui.Add("Button", "x605 y405 w70", "Close").OnEvent("Click", ...)
;
; UPDATED (add Help between Research and Close):
;   browserGui.Add("Button", "x530 y405 w70", "🔬 Research").OnEvent("Click", ...)

browserGui.Add("Button", "x530 y405 w80 h25", "🔬 Research").OnEvent("Click", (*) => ResearchTools.ShowResearchMenu(browserGui, listView))
browserGui.Add("Button", "x615 y405 w30 h25", "❓").OnEvent("Click", (*) => CC_ShowHelp())
browserGui.Add("Button", "x650 y405 w70 h25", "Close").OnEvent("Click", (*) => browserGui.Destroy())

;   ^ Research          ^ Help (❓)       ^ Close
;
; NOTE: You may need to adjust x-coordinates depending on your exact layout.
;       The Help button is intentionally small (w30) - just a "❓" icon.
;       This keeps it unobtrusive but always available.
;
; ALTERNATIVE: If space is tight, add it to ROW 2 instead:
;
;   browserGui.Add("Button", "x___ y435 w60 h25", "❓ Help").OnEvent("Click", (*) => CC_ShowHelp())


; ==============================================================================
; STEP 3: (OPTIONAL) Add F1 hotkey inside the Capture Browser
; ==============================================================================
;
; If you want F1 to open help while the Browser is focused, add this
; inside your CC_ShowBrowser() function after creating the GUI:
;
;   browserGui.Add("Hotkey", "Hidden", "F1").OnEvent("Change", (*) => CC_ShowHelp())
;
; Or use a simpler approach - bind it to the GUI's key events:

; Add this line right after browserGui.Show(...):
; HotIfWinActive("ahk_id " browserGui.Hwnd)
; Hotkey("F1", (*) => CC_ShowHelp())


; ==============================================================================
; THAT'S IT! The help window will:
; ==============================================================================
;
;   ✓ Open as always-on-top (floats above Browser)
;   ✓ Non-modal (click back to Browser, keep working)
;   ✓ Toggle on/off with repeated clicks
;   ✓ Remember its position between opens
;   ✓ Resize with content
;   ✓ Show 5 tabbed sections:
;       🚀 Quick Start  - How CCP works (for new users)
;       🔤 Suffixes     - All 22 suffix actions
;       🖥️ Browser      - Button & navigation reference
;       ⌨️ Hotkeys      - Global keyboard shortcuts
;       💡 Tips         - Power user tricks
;
; ==============================================================================
