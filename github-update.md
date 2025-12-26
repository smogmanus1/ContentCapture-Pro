# ContentCapture Pro - GitHub Update

## Release Notes (v4.7)

### What's New in This Update

#### 🔍 Enhanced Search - Full-Text Search Across All Fields
The Capture Browser search now searches **all capture fields**, not just the script name and title:
- **Script Name** - The hotstring trigger name
- **Title** - The webpage or content title
- **Body** - Full body text content
- **Opinion** - Your personal commentary
- **Tags** - All assigned tags
- **URL** - The source URL
- **Private Note** - Your private notes

This means you can now find captures by remembering ANY word from the content - a phrase from the article, part of a URL like "youtube" or "nytimes", or keywords from your opinion.

#### 🛡️ Improved Error Handling
- Added try/catch protection around hotstring reinitialization
- Better error messages if something goes wrong during save
- Clearer TrayTip notifications confirming "Hotstrings updated!" after saving edits

#### 🔧 Bug Fixes
- Improved stability when saving edited captures
- Better feedback during rename operations

---

## Commit Message (Short)
```
v4.7: Full-text search across all fields, improved error handling

- Search now checks body, opinion, tags, URL, and notes (not just name/title)
- Added try/catch around DynamicSuffixHandler.Initialize()
- Clearer TrayTip confirmations after save
```

---

## Full Feature Description (README.md)

# ContentCapture Pro

**A comprehensive AutoHotkey v2 application for capturing, organizing, and sharing web content across multiple platforms.**

ContentCapture Pro transforms how you save and share content. Capture URLs, titles, and highlighted text from any webpage, then instantly share to email, social media, or paste anywhere using simple hotstring shortcuts.

## ✨ Key Features

### 📥 Content Capture
- **One-Click Capture** (Ctrl+Alt+C) - Grab URL, title, and highlighted text from any browser
- **Smart Text Extraction** - Automatically captures selected text as the body
- **Auto-Generated Script Names** - Creates memorable hotstring names from titles
- **Duplicate Detection** - Warns before creating duplicate captures
- **Date Stamping** - Automatically records capture date

### 🔤 Dynamic Hotstring System
Type simple shortcuts to instantly access your content:
| Suffix | Action |
|--------|--------|
| `scriptname` | Paste full content |
| `scriptnamec` | Copy to clipboard |
| `scriptnamego` | Open URL in browser |
| `scriptnamer.` | Run/open the URL |
| `scriptname?` | Show available commands |
| `scriptnamevi` | View in reading window |
| `scriptnameeg` | Edit capture |
| `scriptnamerd` | Read content aloud |

### 📤 One-Click Social Sharing
Share to any platform with a simple suffix:
| Suffix | Platform |
|--------|----------|
| `scriptnameeem` | Email via Outlook |
| `scriptnamefb` | Facebook |
| `scriptnamex` | Twitter/X |
| `scriptnamebs` | Bluesky |
| `scriptnameli` | LinkedIn |
| `scriptnamemt` | Mastodon |

### 📂 Capture Browser (Ctrl+Alt+B)
- **Full-Text Search** - Search across ALL fields (name, title, body, opinion, tags, URL, notes)
- **Tag Filtering** - Filter by custom tags
- **Favorites System** - Star your most-used captures
- **Multi-Select Operations** - Batch actions on multiple captures
- **Sortable Columns** - Sort by name, title, tags, or date
- **Quick Actions** - Open, Read, Copy, Email, Edit, Delete from one interface

### ✏️ Edit & Organize
- **Full Edit Dialog** - Modify all capture fields
- **Rename Captures** - Change script names with automatic data migration
- **Auto-Format** - Clean up body text that lost line breaks during copy/paste
- **Private Notes** - Add personal notes that aren't shared publicly
- **Tag Management** - Organize with custom tags

### 📖 Reading Window
- **Clean Display** - Read captures in a formatted, easy-to-read window
- **Quick Actions** - Copy, Email, Edit, or Open URL directly from reading view
- **Character Count** - See content length for social media planning

### 💾 Backup & Restore
- **Automatic Backups** - Creates timestamped backups before major operations
- **Cloud Detection** - Automatically finds Dropbox, OneDrive, Google Drive
- **USB Drive Support** - Backup to removable drives
- **Restore Interface** - Browse and restore from any backup
- **Data Integrity** - Copy-then-delete approach prevents data loss

### 🛠️ Additional Features
- **First-Run Setup Wizard** - Easy configuration for new users
- **Tray Menu** - Quick access to all functions from system tray
- **Export to HTML** - Generate browsable HTML reports of all captures
- **Index File** - Searchable plain-text index of all hotstrings
- **Keyboard Shortcuts** - Full keyboard navigation support
- **Always-On-Top Option** - Keep windows visible while working

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+C` | Capture current page |
| `Ctrl+Alt+B` | Open Capture Browser |
| `Ctrl+Alt+L` | Reload script |
| `Ctrl+Alt+H` | Show help |

## 📋 Requirements

- Windows 10/11
- AutoHotkey v2.0+
- Microsoft Outlook (for email features)

## 🚀 Quick Start

### Easy Install (Recommended)
1. Download ContentCapture Pro
2. **Double-click `install.bat`**
3. Follow the prompts - it will install AutoHotkey v2 if needed
4. Press `Ctrl+Alt+C` on any webpage to capture
5. Type your script name + suffix to use!

### Manual Install
1. Install [AutoHotkey v2](https://www.autohotkey.com/download/)
2. Download ContentCapture Pro
3. Run `ContentCapture-Pro.ahk`
4. Press `Ctrl+Alt+C` on any webpage to capture
5. Type your script name + suffix to use!

## 📁 File Structure

```
ContentCapture-Pro/
├── install.bat                 # Easy installer for new users
├── ContentCapture-Pro.ahk      # Main application
├── DynamicSuffixHandler.ahk    # Hotstring pattern detection
├── captures.dat                # Your capture database
├── favorites.txt               # Starred captures list
├── index.txt                   # Searchable hotstring index
└── backups/                    # Automatic backups
```

## 🙏 Credits

- **Joe Glines (The Automator)** - AutoHotkey inspiration and techniques ([the-automator.com](https://the-automator.com))
- **Jack Dunning** - AutoHotkey inspiration and techniques
- **AutoHotkey Community** - Continued support and feedback
- **Anthropic Claude** - Development assistance

## 📄 License

MIT License - Feel free to use, modify, and share!

---

*ContentCapture Pro - Capture once, share everywhere.*
