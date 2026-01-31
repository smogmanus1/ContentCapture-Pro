# ContentCapture Pro v6.1.1 Release Notes

**Release Date:** January 31, 2026  
**Type:** Bug Fix Release

## 🔧 Critical Bug Fixes

### 1. Fixed Infinite Recursion in DynamicSuffixHandler (CRITICAL)

**Problem:** The wrapper functions in `DynamicSuffixHandler.ahk` were calling themselves instead of the intended functions, causing stack overflow errors.

**Affected Functions:**
- `DSH_SafePaste()` was calling itself instead of `CC_SafePaste()`
- `DSH_SafeCopy()` was calling itself instead of `CC_SafeCopy()`
- `DSH_UrlEncode()` had incorrect function name references

**Fix:** Corrected all wrapper function calls to properly delegate to the main script's functions.

### 2. Fixed Stale Content in Social Media Sharing

**Problem:** Global state variables (`IS_PendingContent`, `IS_PendingImages`, `IS_CurrentImageIndex`) in `ImageSharing.ahk` were never cleared after sharing operations completed. This caused:
- Wrong images appearing in subsequent shares
- Old text content being pasted instead of new content
- "Ghost" hotkeys remaining active

**Fix:** 
- Added `IS_ClearPendingState()` function to properly reset all global state
- Added cleanup calls after all sharing operations complete
- Added cleanup on errors and cancellations
- Added timeout-based cleanup for edge cases

### 3. Fixed Missing DynamicSuffixHandler Methods

**Problem:** `ContentCapture-Pro.ahk` was calling social media methods that didn't exist:
- `DynamicSuffixHandler.ActionFacebook()`
- `DynamicSuffixHandler.ActionTwitter()`
- `DynamicSuffixHandler.ActionBluesky()`
- `DynamicSuffixHandler.ActionLinkedIn()`
- `DynamicSuffixHandler.ActionMastodon()`

**Fix:** Added all missing static methods to the `DynamicSuffixHandler` class.

### 4. Fixed Clipboard Operations Missing Clear Step

**Problem:** Several functions were setting clipboard content without clearing first, which could result in stale data being pasted.

**Affected Functions:**
- `CC_HotstringCopyOnly()`
- `DynamicSuffixHandler.ActionCopy()`
- Various `ImageSharing.ahk` functions

**Fix:** All clipboard operations now follow the pattern:
```autohotkey
A_Clipboard := ""      ; Clear first
Sleep(50)              ; Wait for clear
A_Clipboard := content ; Set new content
ClipWait(2)            ; Wait for ready
```

## 📁 Files Changed

| File | Changes |
|------|---------|
| `ContentCapture-Pro.ahk` | Version bump, CC_HotstringCopyOnly fix |
| `DynamicSuffixHandler.ahk` | Fixed wrapper functions, added missing methods |
| `ImageSharing.ahk` | Added state cleanup, safe clipboard operations |

## 🔄 Upgrade Instructions

1. **Backup your data files:**
   - `captures.dat`
   - `config.ini`
   - Any images in your images folder

2. **Replace the following files:**
   - `ContentCapture-Pro.ahk`
   - `DynamicSuffixHandler.ahk`
   - `ImageSharing.ahk`

3. **Reload the script** (Right-click tray icon → Reload)

4. **Test social media sharing** to verify the fixes work correctly

## 🧪 Testing Checklist

After upgrading, verify these scenarios work correctly:

- [ ] Type `::capturenamebs::` to share to Bluesky - content should be correct
- [ ] Share an image to Facebook, then share different content - no stale images
- [ ] Use `::capturenamecp::` to copy - clipboard should have fresh content
- [ ] Cancel a multi-image share midway, then start a new share - no old images

## 💡 Technical Details

### Root Cause Analysis

The "stale content" bug had multiple contributing factors:

1. **Wrapper Function Bug:** When `DSH_SafePaste(text)` was called:
   ```autohotkey
   ; BEFORE (broken):
   DSH_SafePaste(text) {
       if IsSet(CC_SafePaste)
           DSH_SafePaste(text)  ; ← Calls itself!
       else
           _DSH_SafePaste(text)
   }
   
   ; AFTER (fixed):
   DSH_SafePaste(text) {
       if IsSet(CC_SafePaste)
           CC_SafePaste(text)   ; ← Calls correct function
       else
           _DSH_SafePaste(text)
   }
   ```

2. **Global State Never Cleared:** The sharing workflow stored pending content in global variables but never cleaned them up:
   ```autohotkey
   ; These persisted forever:
   global IS_PendingContent := "old content"
   global IS_PendingImages := ["old_image.jpg"]
   ```

3. **Missing Method Implementations:** The hotstring handlers called methods that didn't exist in the class, causing silent failures.

## 🙏 Acknowledgments

Bug identified through systematic code audit. Thanks to the AutoHotkey community for the debugging techniques used in this analysis.

---

**Full Changelog:** See `CHANGELOG.md` for complete version history.
