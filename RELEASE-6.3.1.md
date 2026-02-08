# ContentCapture Pro v6.3.1 — Stability & Social Sharing Fix

---

## ⚙️ Git Commands

```bash
cd E:\contentcap\ContentCapture-GitHub\ContentCapture-Pro

# Stage updated files
git add ContentCapture-Pro.ahk DynamicSuffixHandler.ahk CHANGELOG.md README.md

# Commit
git commit -m "v6.3.1 - Fix permanent hotstring suspension + social media short text"

# Tag
git tag v6.3.1

# Push
git push origin main
git push origin v6.3.1
```

---

## 📋 GitHub Release Notes

**Copy everything below this line into the GitHub Release description:**

---

# ContentCapture Pro v6.3.1

**Critical stability fix + social media sharing now uses your Short Version field.**

---

## 🐛 Critical Fix: Hotstrings Permanently Disabled After Editing

**The Problem:** After editing and saving any capture, ALL hotstrings would stop working — not just ContentCapture hotstrings, but your entire AHK setup. The only fix was manually reloading the script.

**Root Cause:** When a GUI window opens, ContentCapture suspends hotstring recognition (to prevent keyboard lockup with thousands of active hotstrings). But 7 of 9 GUI windows never resumed hotstrings when they closed. The `Suspend(true)` state is script-wide in AHK v2, so it knocked out everything.

**The Fix (22 code changes across 2 files):**
- All 9 GUI functions now properly resume hotstrings on every exit path
- Close button, Escape key, Cancel button, Save, early returns — all covered
- Added resume calls before every `Reload()` to prevent suspension carrying over
- Fixed `DynamicSuffixHandler.Initialize()` so re-initialization after edits uses fresh data

### GUIs Fixed
| GUI | What Was Broken |
|-----|----------------|
| AI Setup | No Close/Escape handler, Save didn't resume |
| AI Select Capture | No Close/Escape handler |
| Read Window | Close/Escape/buttons just destroyed without resuming |
| Manual Capture | Close/Escape/Cancel just destroyed without resuming |
| Capture Browser | Close/Escape/Close button just destroyed without resuming |
| Edit Capture | Close/Escape/Cancel just destroyed, Save didn't resume before Reload |
| Format to Hotstring | Cancel just destroyed, no Close/Escape handlers |
| Browser Delete | Destroyed browser GUI without resuming before reopening |
| Duplicate Capture | Destroyed browser GUI without resuming |

---

## 🐛 Fix: Social Media Suffixes Now Use Your Short Version

**The Problem:** You carefully write a 300-character Short Version for Bluesky/X in the Edit GUI, but typing `namex` or `namebs` ignores it completely and pastes `opinion + title + url` instead — which is almost always too long.

**The Fix:** The `x`, `bs`, `fb`, `li`, and `mt` suffixes now check for a Short Version first:
1. If Short Version exists → uses it as the post content
2. Automatically appends the URL if it fits within the character limit
3. Falls back to `opinion + title + url` only if no Short Version exists

This makes the Short Version field actually useful — write once in the Edit GUI, share everywhere with hotstrings.

---

## 📦 Files Changed

| File | Version | Changes |
|------|---------|---------|
| `ContentCapture-Pro.ahk` | 6.3.1 | 22 suspend/resume fixes across 9 GUI functions |
| `DynamicSuffixHandler.ahk` | 2.5 | ActionSocial uses Short Version, Initialize() data refresh fix |

## ⬆️ Upgrading

1. Back up your `captures.dat` file (just in case)
2. Replace `ContentCapture-Pro.ahk` and `DynamicSuffixHandler.ahk`
3. **Important:** Press `Ctrl+Alt+L` to reload the script after replacing files
4. Your captures and settings are preserved

## 💡 Tip: Using the Short Version Field

1. Open any capture in the Edit GUI
2. Scroll to **📱 Short Version (Bluesky/X - 300 char max)**
3. Write your post text, or click **✂️ Auto-Format** to generate one from your opinion/body
4. Save the capture
5. Now `namex` and `namebs` will paste your Short Version + URL automatically

---

## 🙏 Credits

**Created by:** Brad
**Website:** [crisisoftruth.org](https://crisisoftruth.org)
**GitHub:** [github.com/smogmanus1/ContentCapture-Pro](https://github.com/smogmanus1/ContentCapture-Pro)
**Built with assistance from:** Claude AI

Special thanks to Joe Glines ([the-Automator.com](https://the-automator.com)), Isaias Baez (RaptorX), Jack Dunning, and the AutoHotkey community!

---

## 📝 CHANGELOG.md Entry

**Add this to the top of your CHANGELOG.md:**

```markdown
## [6.3.1] - 2026-02-08

### Critical Fix
- **Hotstrings permanently disabled after editing** — `Suspend(true)` was called when GUIs opened but never reversed when they closed, permanently disabling ALL hotstrings and hotkeys for the entire AHK process

### Fixed
- 7 of 9 GUI functions had missing `CC_ResumeHotstrings()` calls on Close, Escape, Cancel, and Save paths
- `CC_SaveEditedCapture` didn't resume before `Reload()`, causing suspension to carry over
- `CC_AddCapture` didn't resume before `Reload()`
- `CC_BrowserDeleteCapture` destroyed browser GUI without resuming
- `CC_DoDuplicate` destroyed browser GUI without resuming
- `DynamicSuffixHandler.Initialize()` early-return guard skipped updating capture data references
- Social media suffixes (`x`, `bs`, `fb`, `li`, `mt`) ignored the Short Version field entirely — always built content from opinion+title+url instead

### Improved
- Social sharing now uses Short Version as primary content when available
- URL automatically appended to Short Version if it fits within character limit
- All GUI exit paths (Close, Escape, Cancel, Save, early returns) properly balanced
```

---

## 📝 README.md Update

**Replace your "What's New" section with:**

```markdown
## 🆕 What's New in v6.3.1

**Critical Stability Fix:**
- ✅ Fixed hotstrings permanently stopping after editing captures
- ✅ All 9 GUI windows now properly resume hotstrings on every exit path
- ✅ Script no longer knocks out your entire AHK setup

**Social Media Fix:**
- ✅ `namex` and `namebs` suffixes now use your Short Version field
- ✅ URL automatically appended if it fits within character limit
- ✅ The Short Version you write in the Edit GUI finally works!

**Previous (v6.3.0):**
- ✅ Built-in Help system — press F1 or click ❓ in Capture Browser
- ✅ Centralized clipboard system for rock-solid reliability

See [CHANGELOG.md](CHANGELOG.md) for full history.
```

---

## 📢 AutoHotkey Forum / Social Media Post

```
ContentCapture Pro v6.3.1 — Critical Stability Fix

If hotstrings stopped working after editing captures, this update fixes it.
Also: social media suffixes (x, bs, fb) now use your Short Version field.

🔗 https://github.com/smogmanus1/ContentCapture-Pro

What's fixed:
• Hotstrings no longer permanently disabled after GUI close/save
• Short Version field now actually used for social media sharing
• All 9 GUI windows properly resume hotstrings on every exit path

Free & open source | AutoHotkey v2
#AutoHotkey #Productivity #OpenSource
```
