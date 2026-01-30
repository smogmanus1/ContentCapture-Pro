# PROGRAMMER'S INSIGHTS

## Building ContentCapture Pro: Lessons Learned in AutoHotkey v2 Development

**Version 1.0**  
**Author:** Brad Schrunk  
**Project:** ContentCapture Pro  
**Repository:** [github.com/smogmanus1/ContentCapture-Pro](https://github.com/smogmanus1/ContentCapture-Pro)

---

> *"Perfection is much more important than creation speed."*

This document distills the hard-won knowledge gained from building ContentCapture Pro—a production-quality AutoHotkey v2 application with over 4,800 captures in active daily use. These insights emerged from months of trial and error, debugging sessions, and real-world usage. If you're building serious AHK v2 applications, especially those involving GUIs, clipboard manipulation, social media integration, or COM automation, these lessons will save you significant time and frustration.

---

## Table of Contents

1. [Introduction](#1-introduction)
2. [Architecture Overview](#2-architecture-overview)
3. [The Suffix System](#3-the-suffix-system)
4. [GUI Gotchas](#4-gui-gotchas)
5. [Clipboard Mastery](#5-clipboard-mastery)
6. [COM Automation: Outlook Integration](#6-com-automation-outlook-integration)
7. [Social Media Quirks](#7-social-media-quirks)
8. [Image Handling](#8-image-handling)
9. [Error Handling Patterns](#9-error-handling-patterns)
10. [Testing Strategies](#10-testing-strategies)
11. [Development Philosophy](#11-development-philosophy)
12. [Contributing & Extending](#12-contributing--extending)

---

## 1. Introduction

### Who This Document Is For

This isn't a beginner's AutoHotkey tutorial. It's for developers who:

- Have basic AHK v2 syntax down
- Are building real applications, not just simple hotkeys
- Want to learn from someone else's mistakes
- Need patterns for GUI applications, clipboard handling, and external integrations

### What ContentCapture Pro Does

ContentCapture Pro allows users to capture webpage content (URLs, titles, highlighted text) and instantly recall it anywhere using memorable hotstrings. Type `recipe` followed by a suffix like `fb`, and the content shares to Facebook. Type `recipeem` and it creates an Outlook email. Type `recipeu` and it pastes just the URL.

The system generates **23 hotstring variants** per capture, enabling precise control over how content is shared across different contexts.

### Why This Document Exists

The AutoHotkey v2 ecosystem has excellent reference documentation but sparse coverage of real-world application patterns. When I hit a wall with `Submit(false)` not capturing Edit control values, I couldn't find anyone discussing it. When I discovered that link ordering affects social media preview cards, there was no documentation. This document fills those gaps.

---

## 2. Architecture Overview

### Why Modular Architecture Matters

ContentCapture Pro started as a monolithic script. It became unmaintainable around 3,000 lines. The refactoring into modules was painful but essential.

**Current File Structure:**

```
ContentCapture-Pro/
├── ContentCapture-Pro.ahk      # Main entry point (~7,000 lines)
├── DynamicSuffixHandler.ahk    # Suffix pattern matching
├── SocialShare.ahk             # Social media integration
├── ImageCapture.ahk            # Image attachment system
├── ImageClipboard.ahk          # Clipboard image handling
├── ImageDatabase.ahk           # Image data persistence
├── ImageSharing.ahk            # Image sharing to platforms
├── ResearchTools.ahk           # Fact-checking integrations
├── captures.dat                # JSON data storage
├── images.dat                  # Image attachment mappings
└── ContentCapture-Config.ini   # User configuration
```

### Key Architectural Decisions

**1. Static Classes for Modules**

AHK v2's class system works well for organizing related functionality:

```autohotkey
class SocialShare {
    static CHAR_LIMITS := Map(
        "twitter", 280,
        "bluesky", 300,
        "mastodon", 500,
        "linkedin", 3000,
        "facebook", 63206
    )
    
    static ShareToTwitter(content) {
        ; Implementation
    }
}
```

Static classes mean you never instantiate—you just call `SocialShare.ShareToTwitter(content)`. This keeps memory footprint low and makes the API obvious.

**2. Centralized Configuration**

Never hardcode paths or settings in multiple places:

```autohotkey
class Config {
    static APP_NAME := "ContentCapture Pro"
    static VERSION := "6.1.0"
    static DATA_FILE := A_ScriptDir "\captures.dat"
    static CONFIG_FILE := A_ScriptDir "\ContentCapture-Config.ini"
    static BACKUP_DIR := A_ScriptDir "\backups"
}
```

**3. Single Source of Truth for Data**

All captures live in one JSON file. Loading happens once at startup. Saves happen immediately after changes. This prevents sync issues and makes backup trivial.

### The `#Include` Pattern

Order matters. Include dependencies before dependents:

```autohotkey
#Requires AutoHotkey v2.0
#SingleInstance Force

; Core utilities first
#Include %A_ScriptDir%\lib\Utilities.ahk

; Then modules that depend on utilities
#Include %A_ScriptDir%\DynamicSuffixHandler.ahk
#Include %A_ScriptDir%\SocialShare.ahk

; Main application last
; ... rest of ContentCapture-Pro.ahk
```

---

## 3. The Suffix System

### The Core Innovation

The suffix system is the heart of ContentCapture Pro. Every capture gets a memorable base name (like `recipe`), and suffixes determine what happens:

| Suffix | Action | Example |
|--------|--------|---------|
| *(none)* | Paste full content | `recipe` |
| `u` | Paste URL only | `recipeu` |
| `t` | Paste title only | `recipet` |
| `em` | Create Outlook email | `recipeem` |
| `fb` | Share to Facebook | `recipefb` |
| `x` | Share to Twitter/X | `recipex` |
| `rd` | Read in MsgBox | `reciperd` |
| `go` | Open URL in browser | `recipego` |
| `fc` | Open in Snopes fact-check | `recipefc` |
| `fbi` | Facebook + image | `recipefbi` |

This generates 23 variants per capture—all from one base name.

### Implementation: The SUFFIX_MAP

```autohotkey
class DynamicSuffixHandler {
    static SUFFIX_MAP := Map(
        ; Core actions
        "u",   "url",
        "em",  "email",
        "oi",  "outlookinsert",
        "vi",  "view",
        "go",  "openurl",
        "rd",  "read",
        "sh",  "short",
        "t",   "title",
        "cp",  "copy",
        "pr",  "print",
        
        ; Social media (text only)
        "fb",  "facebook",
        "x",   "twitter",
        "bs",  "bluesky",
        "li",  "linkedin",
        "mt",  "mastodon",
        
        ; Social media with image
        "fbi", "facebookimg",
        "xi",  "twitterimg",
        "bsi", "blueskyimg",
        "lii", "linkedinimg",
        "mti", "mastodonimg",
        
        ; Research tools
        "yt",  "transcript",
        "pp",  "perplexity",
        "fc",  "factcheck",
        "mb",  "mediabias",
        "wb",  "wayback",
        "gs",  "scholar",
        "av",  "archive"
    )
}
```

### Pattern Matching Logic

The suffix handler uses an InputHook to capture typing in real-time:

```autohotkey
static StartListening() {
    this.inputHook := InputHook("V I1")
    this.inputHook.OnChar := ObjBindMethod(this, "OnCharReceived")
    this.inputHook.OnEnd := ObjBindMethod(this, "OnInputEnd")
    this.inputHook.Start()
}

static OnCharReceived(ih, char) {
    this.inputBuffer .= char
    
    ; Check if buffer matches a capture name + suffix
    for suffix, action in this.SUFFIX_MAP {
        if (this.BufferEndsWith(suffix)) {
            baseName := this.ExtractBaseName(suffix)
            if (this.CaptureExists(baseName)) {
                this.TriggerAction(baseName, action)
                this.ClearBuffer()
                return
            }
        }
    }
}
```

**Key Insight:** The InputHook approach is more flexible than registering thousands of static hotstrings. With 4,800 captures × 23 suffixes = 110,400 potential hotstrings, dynamic matching is the only viable approach.

### Adding New Suffixes

To add a new suffix, you only need to:

1. Add the mapping to `SUFFIX_MAP`
2. Implement the action handler

```autohotkey
; In SUFFIX_MAP
"sum", "summarize",

; In the action router
case "summarize":
    this.SummarizeCapture(baseName)
```

The architecture means new features don't require touching existing code.

---

## 4. GUI Gotchas

This chapter documents the non-obvious pitfalls in AHK v2 GUI programming that aren't well-documented elsewhere.

### The Submit(false) Problem

**The Bug:** You create an Edit control, user types text, clicks Save, and the saved value is empty or stale.

**The Cause:** `gui.Submit(false)` captures control values at a specific moment. If an Edit control still has focus when Submit is called, the value might not be "committed" to the Submit object yet.

**The Wrong Way:**
```autohotkey
CC_SaveEditedCapture(editGui, name) {
    saved := editGui.Submit(false)  ; ❌ Unreliable!
    
    updatedCapture["title"] := saved.EditTitle  ; May be empty/stale
}
```

**The Right Way:**
```autohotkey
CC_SaveEditedCapture(editGui, name) {
    saved := editGui.Submit(false)
    
    ; Read directly from the control instead
    updatedCapture["title"] := editGui["EditTitle"].Value  ; ✓ Always current
    updatedCapture["url"] := editGui["EditURL"].Value
    updatedCapture["body"] := editGui["EditBody"].Value
}
```

**The Rule:** When you need the current value of a GUI control at the moment of a button click, read `.Value` directly from the control rather than relying on `Submit()`.

### Global Variable Declaration for GUI Controls

In AHK v1, GUI control variables had to be declared global. AHK v2 handles this differently, but there are still gotchas.

**If You See This Error:**
```
A control's variable must be global or static.
Specifically: vEditorStatus
```

**The Fix:** In v2, use the `v` prefix in the control options and access via `gui["ControlName"]`:

```autohotkey
; Creating the control
editGui.Add("Edit", "x100 y110 w500 h20 vEditTitle", currentTitle)

; Accessing the value
titleValue := editGui["EditTitle"].Value
```

### Dynamic GUI Updates and Thread Safety

AHK v2 GUIs can exhibit unexpected behavior with rapid updates:

```autohotkey
; Problematic: Too fast
Loop 100 {
    gui["StatusText"].Value := "Processing " A_Index "..."
}

; Better: Allow GUI thread to breathe
Loop 100 {
    gui["StatusText"].Value := "Processing " A_Index "..."
    Sleep(10)  ; Give the GUI thread time to redraw
}
```

### Event Handler Binding

When binding methods to GUI events, `ObjBindMethod` is your friend:

```autohotkey
; Wrong: Anonymous function loses context
btn.OnEvent("Click", (*) => this.HandleClick())  ; `this` may be wrong

; Right: Explicit binding
btn.OnEvent("Click", ObjBindMethod(this, "HandleClick"))
```

---

## 5. Clipboard Mastery

Clipboard operations in AHK are deceptively complex. Getting them right requires understanding Windows clipboard timing.

### The Fundamental Problem

When you set `A_Clipboard := content` and immediately call `Send("^v")`, the paste might fail or paste old content. Windows clipboard operations are asynchronous.

### Content-Length-Based Delays

**The Discovery:** Short content pastes fine with minimal delay. Long content (5,000+ characters) needs more time. The solution is dynamic delay calculation:

```autohotkey
CC_SafePaste(content, timeout := 2) {
    ; Save original clipboard
    originalClip := ClipboardAll()
    
    ; Set new content
    A_Clipboard := ""
    A_Clipboard := content
    
    ; Wait for clipboard to populate
    if !ClipWait(timeout) {
        A_Clipboard := originalClip
        return false
    }
    
    ; Calculate delay based on content length
    ; Base: 400ms, plus ~100ms per 1000 chars, max 2000ms
    contentLen := StrLen(content)
    pasteDelay := Min(400 + (contentLen // 1000) * 100, 2000)
    
    ; Paste
    Send("^v")
    Sleep(pasteDelay)  ; Wait for paste to complete
    
    ; Restore original clipboard
    Sleep(100)
    A_Clipboard := originalClip
    
    return true
}
```

**The Math:** A 5,248-character paste needs ~920ms delay. The 350ms we started with only got the URL (the first ~100 characters) before the clipboard was restored.

### ClipWait Is Essential

Never skip `ClipWait()`:

```autohotkey
; Wrong: Race condition
A_Clipboard := content
Send("^v")

; Right: Wait for clipboard
A_Clipboard := ""
A_Clipboard := content
ClipWait(2)  ; Wait up to 2 seconds
Send("^v")
```

### Preserving User's Clipboard

Users get frustrated when your tool destroys their clipboard contents:

```autohotkey
SafeClipboardOperation(content) {
    ; Save what user had
    savedClip := ClipboardAll()
    
    try {
        A_Clipboard := content
        ClipWait(2)
        Send("^v")
        Sleep(500)
    } finally {
        ; Always restore, even on error
        Sleep(100)
        A_Clipboard := savedClip
    }
}
```

### Image Clipboard Operations

Putting images on the clipboard requires Windows API calls:

```autohotkey
CopyImageToClipboard(imagePath) {
    if !FileExist(imagePath)
        return false
    
    ; Load image using GDI+
    hBitmap := LoadPicture(imagePath, "GDI+")
    if !hBitmap
        return false
    
    ; Open clipboard
    if !DllCall("OpenClipboard", "Ptr", A_ScriptHwnd)
        return false
    
    DllCall("EmptyClipboard")
    
    ; CF_BITMAP = 2
    DllCall("SetClipboardData", "UInt", 2, "Ptr", hBitmap)
    
    DllCall("CloseClipboard")
    return true
}
```

---

## 6. COM Automation: Outlook Integration

Microsoft Outlook COM automation enables powerful email features—creating emails with pre-filled content, attaching files, and even inserting text into existing drafts.

### Creating New Emails

```autohotkey
SendOutlookEmail(content, subject := "") {
    try {
        ; Get or create Outlook instance
        try {
            ol := ComObject("Outlook.Application")
        } catch {
            ol := ComObjActive("Outlook.Application")
        }
        
        mail := ol.CreateItem(0)  ; 0 = olMailItem
        
        ; Set subject from first line if not provided
        if (subject = "") {
            firstLine := StrSplit(content, "`n")[1]
            subject := StrLen(firstLine) > 100 
                     ? SubStr(firstLine, 1, 97) "..." 
                     : firstLine
        }
        
        mail.Subject := subject
        mail.Body := content
        mail.Display()  ; Show for user to review
        
        return true
    } catch as err {
        MsgBox("Outlook error: " err.Message, "Email Error", "Icon!")
        return false
    }
}
```

### Adding Attachments

```autohotkey
SendOutlookEmailWithDoc(content, docPath := "", subject := "") {
    try {
        ol := ComObject("Outlook.Application")
        mail := ol.CreateItem(0)
        
        mail.Subject := subject
        mail.Body := content
        
        ; Add attachment if provided and exists
        if (docPath != "" && FileExist(docPath)) {
            mail.Attachments.Add(docPath)
        }
        
        mail.Display()
        return true
    } catch as err {
        MsgBox("Could not create email: " err.Message)
        return false
    }
}
```

### Inserting Into Existing Emails

This is more complex—it requires accessing the WordEditor of an open compose window:

```autohotkey
InsertIntoOpenEmail(text) {
    try {
        ol := ComObjActive("Outlook.Application")
        insp := ol.ActiveInspector
        
        if !insp {
            MsgBox("No email compose window is open.")
            return false
        }
        
        ; Get the WordEditor (email body is a Word document)
        wd := insp.WordEditor
        sel := wd.Application.Selection
        
        ; Normalize line breaks for Word
        text := StrReplace(text, "`r`n", "`n")
        text := StrReplace(text, "`n", "`r")
        
        ; Insert at cursor
        sel.TypeText(text)
        return true
    } catch as err {
        MsgBox("Insert failed: " err.Message)
        return false
    }
}
```

### COM Error Handling

COM objects can fail in many ways. Always use try/catch:

```autohotkey
try {
    ol := ComObjActive("Outlook.Application")
} catch as e {
    try {
        ol := ComObject("Outlook.Application")
    } catch as e2 {
        MsgBox("Outlook not available: " e2.Message)
        return false
    }
}
```

---

## 7. Social Media Quirks

Each social media platform has its own idiosyncrasies. This chapter documents what we learned the hard way.

### Character Limits

```autohotkey
static CHAR_LIMITS := Map(
    "twitter",  280,
    "bluesky",  300,
    "mastodon", 500,
    "linkedin", 3000,
    "facebook", 63206
)
```

### Video URL Ordering Affects Preview Cards

**The Discovery:** When sharing a post with multiple URLs, social media platforms generate a preview card for the *last* URL (on most platforms). If you have a GitHub link after a YouTube link, you get a boring GitHub card instead of a video thumbnail.

**The Solution:** Detect video URLs and move them to the end of content before sharing:

```autohotkey
ReorderURLsForVideoPreview(content) {
    ; Video URL patterns
    static videoPatterns := "i)(youtube\.com/watch|youtu\.be/|vimeo\.com/\d|tiktok\.com)"
    
    ; Extract all URLs
    urls := []
    videoUrls := []
    nonVideoUrls := []
    
    pos := 1
    while (pos := RegExMatch(content, "https?://[^\s<>]+", &match, pos)) {
        url := match[0]
        if RegExMatch(url, videoPatterns)
            videoUrls.Push(url)
        else
            nonVideoUrls.Push(url)
        pos += StrLen(url)
    }
    
    ; If no reordering needed, return original
    if (videoUrls.Length = 0)
        return content
    
    ; Remove all URLs from content
    cleanContent := RegExReplace(content, "https?://[^\s<>]+", "")
    cleanContent := Trim(cleanContent)
    
    ; Rebuild: text, then non-video URLs, then video URLs
    result := cleanContent
    for url in nonVideoUrls
        result .= "`n" url
    for url in videoUrls
        result .= "`n" url
    
    return result
}
```

### Platform-Specific Share URLs

```autohotkey
static ShareURLs := Map(
    "twitter",  "https://twitter.com/intent/tweet?text=",
    "facebook", "https://www.facebook.com/sharer/sharer.php?quote=",
    "linkedin", "https://www.linkedin.com/shareArticle?mini=true&url=",
    "bluesky",  "https://bsky.app/intent/compose?text=",
    "mastodon", ""  ; Requires instance-specific handling
)
```

### URL Encoding

Always URL-encode content before passing to share URLs:

```autohotkey
UrlEncode(str) {
    static doc := ComObject("HTMLFile")
    doc.write("<meta http-equiv='X-UA-Compatible' content='IE=9'>")
    return doc.parentWindow.encodeURIComponent(str)
}

ShareToTwitter(content) {
    encoded := UrlEncode(content)
    Run("https://twitter.com/intent/tweet?text=" encoded)
}
```

### Handling Content Too Long for Platform

```autohotkey
PrepareForPlatform(content, platform) {
    limit := CHAR_LIMITS[platform]
    
    if (StrLen(content) <= limit)
        return content
    
    ; Show editing dialog
    editGui := Gui("+Resize", platform " - Content Too Long")
    editGui.Add("Text",, "Content is " StrLen(content) " chars (limit: " limit ")")
    editGui.Add("Edit", "w400 h200 vContent", content)
    editGui.Add("Button", "Default", "Share").OnEvent("Click", ShareEdited)
    editGui.Show()
}
```

---

## 8. Image Handling

Image attachments added significant complexity to ContentCapture Pro. Here's what we learned.

### Image Database Structure

Images are stored separately from captures, linked by mnemonic name:

```
; images.dat format
recipe|C:\Users\Brad\Pictures\recipe-photo.jpg
vacation|C:\Users\Brad\Pictures\beach.png|sunset.jpg
```

Multiple images per capture are pipe-delimited.

### Loading Images to Clipboard

Different approaches for different needs:

```autohotkey
; Using shell for simplicity
CopyImageViaShell(imagePath) {
    ; PowerShell can handle clipboard images
    cmd := 'powershell -command "Add-Type -AssemblyName System.Windows.Forms; '
    cmd .= '[System.Windows.Forms.Clipboard]::SetImage([System.Drawing.Image]::FromFile(''' 
    cmd .= imagePath '''))"'
    RunWait(cmd,, "Hide")
}

; Using Windows API for speed
CopyImageViaAPI(imagePath) {
    ; Implementation using GDI+ and clipboard APIs
    ; (See Clipboard Mastery chapter)
}
```

### Platform Image Limits

```autohotkey
static IMAGE_LIMITS := Map(
    "twitter",  4,
    "facebook", 10,
    "linkedin", 9,
    "bluesky",  4,
    "mastodon", 4
)
```

### The Image Suffix Pattern

Image suffixes append `i` to the base social suffix:

| Suffix | Meaning |
|--------|---------|
| `fb` | Facebook text only |
| `fbi` | Facebook with image |
| `x` | Twitter text only |
| `xi` | Twitter with image |

---

## 9. Error Handling Patterns

### The Try/Finally Pattern

Always clean up, even on errors:

```autohotkey
ProcessCapture(name) {
    savedClip := ClipboardAll()
    
    try {
        ; Dangerous operations
        content := BuildContent(name)
        A_Clipboard := content
        ClipWait(2)
        Send("^v")
    } catch as err {
        LogError("ProcessCapture failed: " err.Message)
        MsgBox("Failed to process capture: " err.Message)
    } finally {
        ; Always restore clipboard
        Sleep(100)
        A_Clipboard := savedClip
    }
}
```

### Silent Failures for Non-Critical Operations

Not everything needs to interrupt the user:

```autohotkey
; Usage tracking should never break core functionality
UpdateUsageStats(name) {
    try {
        stats := FileRead(Config.STATS_FILE)
        ; ... update stats
        FileWrite(stats, Config.STATS_FILE)
    } catch {
        ; Silently fail - stats aren't critical
    }
}
```

### Graceful Degradation

When an optional feature fails, continue with reduced functionality:

```autohotkey
ShareWithImage(content, imagePath, platform) {
    ; Try to include image
    if (imagePath != "" && FileExist(imagePath)) {
        try {
            CopyImageToClipboard(imagePath)
        } catch {
            ; Image failed, but we can still share text
            TrayTip("Image unavailable - sharing text only")
        }
    }
    
    ; Always share the text content
    OpenShareDialog(content, platform)
}
```

---

## 10. Testing Strategies

### Hyper-V Virtual Machines

Testing on a clean Windows installation catches issues your development machine hides:

- Missing dependencies
- Path assumptions
- Registry settings you forgot you made
- Different AHK versions

**Setup:** Create a Windows 10/11 VM, install only AHK v2, and test the release package.

### Browser Compatibility

We discovered that LibreWolf's privacy settings blocked some Google-based functionality. Always test on:

- Chrome (baseline)
- Firefox (privacy modes)
- Edge (enterprise scenarios)

### Regression Testing Checklist

Before each release:

1. ☐ Fresh capture works
2. ☐ All 23 suffixes produce correct output
3. ☐ Clipboard restored after operations
4. ☐ GUI edit saves correctly
5. ☐ Outlook integration works (if installed)
6. ☐ Social share URLs open correctly
7. ☐ Image attachments work
8. ☐ Backup/restore functions
9. ☐ Config changes persist

### Debug Mode

Include a debug mode for troubleshooting:

```autohotkey
global DEBUG_MODE := false

DebugLog(msg) {
    if DEBUG_MODE {
        FileAppend(FormatTime(, "yyyy-MM-dd HH:mm:ss") " - " msg "`n", Config.LOG_FILE)
    }
}
```

---

## 11. Development Philosophy

### Perfection Over Speed

> *"Perfection is much more important than creation speed."*

It's tempting to ship features quickly. Resist. A buggy release damages trust and creates support burden. I've temporarily made the repository private to fix issues rather than leaving broken software public.

### Accessibility for Non-Technical Users

ContentCapture Pro is designed for people who may never have heard of AutoHotkey. This means:

- **Prominent installation warnings** - "This requires AutoHotkey v2"
- **Step-by-step instructions with screenshots**
- **Compiled .exe option** - No AHK installation required
- **Meaningful error messages** - "Outlook not found" not "COM error 0x80040154"

Design for *"grandma who is computer illiterate but wants to keep her recipes."*

### Documentation Is Part of the Product

Every feature needs:

- User-facing documentation (how to use it)
- Technical documentation (how it works)
- Code comments (why it works this way)

### Release Process

Each release gets a comprehensive document containing:

1. Commit messages
2. Changelog entries
3. GitHub release notes
4. README updates
5. Pre-release checklist
6. Git commands
7. Social media announcements

One document to work through, copy sections as needed.

### Attribution

Always credit contributors and inspirations:

- Joe Glines (the-Automator.com) - AHK education
- Isaias Baez (RaptorX) - AHK tools
- Jack Dunning - AHK books
- AutoHotkey development team

The community is generous; give back.

---

## 12. Contributing & Extending

### How to Add a New Suffix

1. **Add to SUFFIX_MAP:**
```autohotkey
"newsuffix", "actionname",
```

2. **Add case to action router:**
```autohotkey
case "actionname":
    this.HandleNewAction(baseName)
```

3. **Implement the handler:**
```autohotkey
static HandleNewAction(baseName) {
    capture := GetCapture(baseName)
    ; Do something with capture
}
```

4. **Update documentation**

5. **Test all variants**

### Code Style Guidelines

- **Class methods:** PascalCase (`HandleNewAction`)
- **Local variables:** camelCase (`baseName`)
- **Constants:** UPPER_SNAKE (`SUFFIX_MAP`)
- **Functions:** PascalCase (`SendOutlookEmail`)

### Pull Request Checklist

- [ ] Code follows style guidelines
- [ ] No new warnings from `#Warn All`
- [ ] Tested on clean Windows install
- [ ] Documentation updated
- [ ] Changelog entry added

---

## Appendix A: Quick Reference

### Common Patterns

```autohotkey
; Safe clipboard operation
savedClip := ClipboardAll()
try {
    A_Clipboard := content
    ClipWait(2)
    Send("^v")
    Sleep(CalculateDelay(content))
} finally {
    A_Clipboard := savedClip
}

; GUI control value (safe)
value := myGui["ControlName"].Value

; COM with fallback
try {
    app := ComObjActive("Application.Name")
} catch {
    app := ComObject("Application.Name")
}
```

### Useful Built-in Variables

| Variable | Use |
|----------|-----|
| `A_ScriptDir` | Script's directory |
| `A_ScriptHwnd` | Script's window handle |
| `A_Clipboard` | Text clipboard content |
| `ClipboardAll()` | Full clipboard (preserves format) |

---

## Appendix B: Resources

### Official Documentation

- [AutoHotkey v2 Docs](https://www.autohotkey.com/docs/v2/)
- [AHK v2 Changes from v1](https://www.autohotkey.com/docs/v2/v2-changes.htm)

### Community Resources

- [AutoHotkey Forums](https://www.autohotkey.com/boards/)
- [the-Automator](https://www.the-automator.com/) - Joe Glines' tutorials

### ContentCapture Pro

- [GitHub Repository](https://github.com/smogmanus1/ContentCapture-Pro)
- [Issue Tracker](https://github.com/smogmanus1/ContentCapture-Pro/issues)

---

*This document is a living resource. As ContentCapture Pro evolves and new insights emerge, this guide will be updated. Contributions and corrections are welcome.*

---

**Last Updated:** January 2026  
**ContentCapture Pro Version:** 6.1.1  
**Document Version:** 1.0
