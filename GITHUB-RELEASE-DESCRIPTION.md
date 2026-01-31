# 🔧 ContentCapture Pro v6.1.1 - Critical Bug Fixes

This release fixes several critical bugs related to clipboard handling and social media sharing that caused "stale content" issues where old images or text would appear in new posts.

## 🚨 Critical Fixes

### Infinite Recursion Bug (DynamicSuffixHandler.ahk)
- **Issue:** Wrapper functions were calling themselves instead of the intended functions
- **Symptoms:** Stack overflow, script crashes, or silent failures when using suffix commands
- **Fixed:** `DSH_SafePaste()`, `DSH_SafeCopy()`, and `DSH_UrlEncode()` now correctly delegate to main script functions

### Stale Content Bug (ImageSharing.ahk)  
- **Issue:** Global state variables were never cleared after sharing operations
- **Symptoms:** Wrong images/text appearing in subsequent shares
- **Fixed:** Added `IS_ClearPendingState()` cleanup function, called after all operations

### Missing Methods Bug (DynamicSuffixHandler.ahk)
- **Issue:** Social media hotstring handlers called non-existent methods
- **Symptoms:** No action when typing `::namefb::`, `::namex::`, etc.
- **Fixed:** Added `ActionFacebook()`, `ActionTwitter()`, `ActionBluesky()`, `ActionLinkedIn()`, `ActionMastodon()` methods

### Clipboard Clear Bug (Multiple Files)
- **Issue:** Clipboard was set without clearing first
- **Symptoms:** Old clipboard content sometimes appearing instead of new content
- **Fixed:** All clipboard operations now clear before setting

## 📦 Installation

**Existing Users:**
1. Backup `captures.dat` and `config.ini`
2. Replace `ContentCapture-Pro.ahk`, `DynamicSuffixHandler.ahk`, and `ImageSharing.ahk`
3. Reload script

**New Users:**
1. Download and extract to any folder
2. Run `ContentCapture.ahk`
3. Follow first-run setup wizard

## 📁 Changed Files
- `ContentCapture-Pro.ahk` - Version bump, clipboard fix
- `DynamicSuffixHandler.ahk` - Fixed wrappers, added methods
- `ImageSharing.ahk` - Added state cleanup

## 🧪 Verified Working
- ✅ Social media sharing (Facebook, Twitter/X, Bluesky, LinkedIn, Mastodon)
- ✅ Image sharing workflows
- ✅ Copy to clipboard operations
- ✅ Multi-step sharing (images + text)

---
**Full Release Notes:** See `RELEASE-6.1.1.md` in the download
