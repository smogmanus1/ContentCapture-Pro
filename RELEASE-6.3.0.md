# ContentCapture Pro v6.3.0 Release Notes

**Release Date:** February 4, 2026  
**Type:** Feature Release - In-App Help System

---

## 🎯 Overview

Version 6.3.0 adds a **built-in Quick Reference help window** that lets users learn ContentCapture Pro while they keep working. The help window is non-modal and always-on-top, so users can read instructions and immediately apply them in the Capture Browser without switching windows.

This feature is especially useful for new users, people you've shared the software with, and anyone who wants a quick reminder of the 22 suffix actions, keyboard shortcuts, or button functions.

---

## ✨ New Features

### CC_HelpWindow.ahk - In-App Quick Reference

A tabbed help window accessible from the Capture Browser via the ❓ button or F1 key.

| Tab | Contents |
|-----|----------|
| 🚀 Quick Start | How ContentCapture Pro works, example workflow |
| 🔤 Suffixes | All 22 suffix actions with examples |
| 🖥️ Browser | Every button explained, keyboard shortcuts |
| ⌨️ Hotkeys | All global keyboard shortcuts |
| 💡 Tips | Naming strategies, power user workflows, social media tips |

### Key Behaviors

- **Non-modal** - Click back to the Capture Browser and keep working while help stays visible
- **Always-on-top** - Floats above other windows for easy reference
- **Toggle on/off** - Click ❓ again (or press F1 again) to dismiss
- **Remembers position** - Reopens where you last placed it
- **Resizable** - Drag the window edges to resize; content scales with it

### New Keyboard Shortcut

| Shortcut | Where | Action |
|----------|-------|--------|
| F1 | Capture Browser | Toggle help window |

### Updated Status Bar

The Capture Browser status bar now displays `F1=Help` alongside the existing shortcut hints:

```
Showing 323 captures | Enter=Paste | Del=Delete | Ctrl+S=Share | Ctrl+I=Import | F1=Help
```

---

## 🎓 Who This Helps

- **New users** - Step-by-step Quick Start tab walks through the Capture → Recall → Share workflow
- **Suffix learners** - Complete reference for all 22 suffix actions in one place, with examples
- **Occasional users** - Quick reminder of hotkeys without digging through documentation
- **People you share CCP with** - They can learn the system at their own pace while using it

---

## 📁 Files Changed

### New Files
- **CC_HelpWindow.ahk** - In-app help reference module (435 lines)
- **RELEASE-6.3.0.md** - This file

### Modified Files
- **ContentCapture-Pro.ahk** - Three additions:
  - `#Include CC_HelpWindow.ahk` added to include block (line 444)
  - ❓ Help button added to Capture Browser button bar (row 1)
  - `F1` hotkey binding added to Browser keyboard shortcuts
  - Status bar text updated to show `F1=Help`
- **CHANGELOG.md** - Added v6.3.0 entry

### Removed Files
- **HELP_INTEGRATION_PATCH.ahk** - Integration instructions (now applied)
- **AutoHotkey-v2-setup.exe** - Installer (too large for GitHub repository)

### Unchanged Files
- ContentCapture.ahk
- CC_Clipboard.ahk
- CC_HoverPreview.ahk
- CC_ShareModule.ahk
- DynamicSuffixHandler.ahk
- ImageCapture.ahk
- ImageClipboard.ahk
- ImageDatabase.ahk
- ImageSharing.ahk
- SocialShare.ahk
- ResearchTools.ahk

---

## 📥 Upgrade Instructions

### From v6.2.1

1. **Backup your data:**
   - `captures.dat`
   - `config.ini` (if you have one)
   - `images/` folder

2. **Copy new/updated files:**
   - Add `CC_HelpWindow.ahk` (new)
   - Replace `ContentCapture-Pro.ahk` (updated)
   - Replace `CHANGELOG.md` (updated)

3. **Run ContentCapture.ahk**

### Important Notes

- `CC_HelpWindow.ahk` must be in the same folder as your other .ahk files
- Your `captures.dat` and `images/` folder are fully compatible - no migration needed
- All existing hotstrings and suffixes work exactly as before
- This is a purely additive feature - nothing existing was changed or removed

---

## ✅ How to Verify

1. Open the Capture Browser (Ctrl+Alt+B)
2. Look for the ❓ button between Research and Close on the top button row
3. Click it - the help window should appear and stay visible
4. Click back on the Capture Browser - you should be able to interact with both
5. Press F1 - the help window should toggle off
6. Press F1 again - it should reappear in the same position

---

## 🔧 For Developers

### Adding Help Content

The help content is organized by tabs in the `CC_Help.BuildGUI()` method. To add or modify content:

```ahk
; Each tab uses an Edit control with ReadOnly text
tabs.UseTab(1)  ; Tab number (1-5)
helpText := "
(
Your content here...
)"
hg.Add("Edit", "x15 y35 w450 h480 ReadOnly -WantReturn +Multi", helpText)
```

### Integration Pattern

The help window uses a simple public function for button binding:

```ahk
; In any GUI, add a help button:
myGui.Add("Button", "w30", "❓").OnEvent("Click", (*) => CC_ShowHelp())
```

---

## 📊 Technical Stats

- **New module size:** 435 lines
- **Help tabs:** 5
- **Suffix actions documented:** 22
- **Hotkeys documented:** 18 global + 7 browser
- **Browser buttons documented:** 17
- **Files changed:** 2
- **Breaking changes:** None

---

## 🙏 Credits

- **Brad** - Creator and lead developer
- **Claude AI** - Help system design and integration

---

## 📞 Support

- **GitHub:** https://github.com/smogmanus1/ContentCapture-Pro
- **Website:** https://crisisoftruth.org

---

*ContentCapture Pro v6.3.0 - Help when you need it, out of the way when you don't.*
