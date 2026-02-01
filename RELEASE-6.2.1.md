# ContentCapture Pro v6.2.1 Release Notes

**Release Date:** February 1, 2026  
**Type:** Stable Release - Architecture Improvement

---

## 🎯 Overview

Version 6.2.1 introduces a **centralized clipboard architecture** that permanently eliminates the "stale clipboard" bug class. This is a stability-focused release that refactors how all clipboard operations work under the hood.

---

## 🐛 Critical Bug Fixed

### The "Stale Clipboard" Bug

**Symptom:** When typing a hotstring like `cotonebb `, sometimes the wrong content would paste - typically whatever was on your clipboard before (like ChatGPT responses, copied text, etc.) instead of your capture content.

**Root Cause:** Windows clipboard operations are asynchronous. Setting `A_Clipboard := content` doesn't guarantee immediate replacement of existing content. Without explicitly clearing the clipboard first and waiting, the old content could persist and get pasted.

**Affected Operations:** 19 clipboard operations across 3 files were vulnerable to this bug.

**The Fix:** All clipboard operations now go through a centralized module (CC_Clipboard.ahk) that guarantees the correct sequence:
1. Save original clipboard
2. Clear clipboard completely
3. Wait for clear to complete
4. Set new content
5. Wait for content to be ready
6. Perform paste
7. Wait for paste to complete
8. Restore original clipboard

---

## 🏗️ New Architecture

### New File: CC_Clipboard.ahk

A centralized clipboard operations module that provides:

| Function | Purpose |
|----------|---------|
| `CC_ClipPaste(content)` | Paste content, restore original clipboard |
| `CC_ClipCopy(content)` | Copy to clipboard (no paste) |
| `CC_ClipPasteKeep(content)` | Paste content, keep it on clipboard |
| `CC_ClipNotify(msg, type)` | Show user notification |
| `CC_ClipGet()` | Get current clipboard text |
| `CC_ClipClear()` | Clear clipboard |

### Backward Compatibility

Legacy function names still work:
- `CC_SafePaste()` → calls `CC_ClipPaste()`
- `CC_SafeCopy()` → calls `CC_ClipCopy()`
- `CC_SafePasteNoRestore()` → calls `CC_ClipPasteKeep()`

---

## 📁 Files Changed

### New Files
- **CC_Clipboard.ahk** - Centralized clipboard module (303 lines)

### Modified Files
- **ContentCapture-Pro.ahk** - 28 clipboard operations refactored
- **ResearchTools.ahk** - 2 clipboard operations fixed
- **CC_ShareModule.ahk** - 2 clipboard operations fixed

### Removed Files
- **ManualCapture.ahk** - Legacy file, was not used
- **ManualCaptureImageGUI.ahk** - Legacy file, was not used

### Unchanged Files
- ContentCapture.ahk
- DynamicSuffixHandler.ahk
- ImageCapture.ahk
- ImageClipboard.ahk
- ImageDatabase.ahk
- ImageSharing.ahk
- SocialShare.ahk
- CC_HoverPreview.ahk

---

## 📥 Upgrade Instructions

### From v6.1.1

1. **Backup your data:**
   - `captures.dat`
   - `config.ini` (if you have one)
   - `images/` folder

2. **Delete old .ahk files** (keep your documentation and installers)

3. **Copy new .ahk files** from this release

4. **Restore your data** (`captures.dat`, `config.ini`, `images/`)

5. **Run ContentCapture.ahk**

### Important Notes

- The new `CC_Clipboard.ahk` file **must** be in the same folder as other .ahk files
- Your `captures.dat` and `images/` folder are fully compatible - no migration needed
- All your hotstrings will work exactly as before

---

## ✅ How to Verify the Fix

1. Copy some random text to your clipboard (Ctrl+C anything)
2. Type a capture name followed by space (e.g., `recipe `)
3. **Expected:** Your capture content pastes correctly
4. **Old bug:** The random text you copied would paste instead

If your capture content always pastes correctly regardless of what was on your clipboard, the fix is working.

---

## 🔧 For Developers

### New Rule: Always Use CC_Clipboard.ahk

```ahk
; ✅ CORRECT
CC_ClipCopy(content)      ; Copy to clipboard
CC_ClipPaste(content)     ; Paste with restore

; ❌ WRONG - Never do this anymore
A_Clipboard := content    ; Bug-prone: missing clear
```

### Acceptable Exceptions

Direct `A_Clipboard` assignments are only allowed for:
1. Clearing: `A_Clipboard := ""`
2. Restoring saved clipboard: `A_Clipboard := savedClip`

---

## 📊 Technical Stats

- **Clipboard operations fixed:** 19
- **Files refactored:** 3
- **New module size:** 303 lines
- **Legacy files removed:** 2
- **Breaking changes:** None

---

## 🙏 Credits

- **Brad** - Creator and lead developer
- **Claude AI** - Comprehensive audit and refactoring assistance

---

## 📞 Support

- **GitHub:** https://github.com/smogmanus1/ContentCapture-Pro
- **Website:** https://crisisoftruth.org

---

*ContentCapture Pro v6.2.1 - Built for reliability.*
