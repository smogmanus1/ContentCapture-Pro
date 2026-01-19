# ContentCapture Pro - User Manual

**Version 5.8 | Complete Reference Guide**

---

## Table of Contents

1. [Introduction](#introduction)
2. [Installation](#installation)
3. [Getting Started](#getting-started)
4. [Capturing Content](#capturing-content)
5. [Using Your Captures](#using-your-captures)
6. [The Suffix System](#the-suffix-system)
7. [Capture Browser](#capture-browser)
8. [Quick Search](#quick-search)
9. [Social Media Sharing](#social-media-sharing)
10. [Research Tools](#research-tools)
11. [AI Integration](#ai-integration)
12. [Backup & Restore](#backup--restore)
13. [Settings & Configuration](#settings--configuration)
14. [Troubleshooting](#troubleshooting)
15. [Keyboard Reference](#keyboard-reference)

---

## Introduction

ContentCapture Pro is a productivity tool that lets you:

- **Capture** any webpage with one hotkey
- **Recall** it instantly by typing a short name
- **Share** to social media, email, and more
- **Research** and fact-check content
- **Organize** with tags and favorites

### The Problem It Solves

How many times have you:
- Found a great article but lost track of it?
- Copy-pasted the same link to multiple platforms?
- Hit character limits and had to manually edit?
- Wanted to share something but couldn't find it?

ContentCapture Pro solves all of this. Capture once, share forever.

---

## Installation

### System Requirements
- Windows 10 or Windows 11
- AutoHotkey v2.0 or higher
- 50MB disk space
- Internet connection (for AI features only)

### Step-by-Step Installation

1. **Install AutoHotkey v2**
   - Visit [autohotkey.com](https://www.autohotkey.com)
   - Download AutoHotkey v2.0 (not v1.1)
   - Run installer with default settings

2. **Download ContentCapture Pro**
   - Download the ZIP from GitHub
   - Extract ALL files to a folder
   - Recommended: `C:\ContentCapture-Pro\`

3. **First Run**
   - Double-click `ContentCapture.ahk`
   - A tray icon appears in your system tray
   - First-time setup wizard will guide you

### File Structure
```
ContentCapture-Pro/
├── ContentCapture.ahk          # Launcher (run this!)
├── ContentCapture-Pro.ahk      # Main application
├── DynamicSuffixHandler.ahk    # Suffix engine
├── ContentCapture_Generated.ahk # Your hotstrings (auto-created)
├── captures.dat                # Your data (auto-created)
├── favorites.dat               # Favorites list
├── config.ini                  # Settings
└── backups/                    # Automatic backups
```

---

## Getting Started

### Your First Capture

1. Open any webpage in your browser
2. Optionally, highlight text you want to include
3. Press `Ctrl+Alt+G`
4. A capture dialog appears with:
   - **Name**: Short identifier (e.g., `recipe1`)
   - **Title**: Auto-filled from page
   - **URL**: Auto-filled from browser
   - **Body**: Your highlighted text (if any)
   - **Tags**: Comma-separated categories
   - **Opinion**: Your personal commentary
   - **Note**: Private notes (not shared)

5. Click **Save**

### Using Your Capture

Now type your capture name anywhere:
- In a Word document
- In an email
- In a Facebook post
- In a chat message
- Anywhere you can type!

Type `recipe1` + Space → Your content appears instantly.

---

## Capturing Content

### Capture Methods

| Method | Hotkey | Use When |
|--------|--------|----------|
| Web Capture | `Ctrl+Alt+G` | On a webpage you want to save |
| Manual Capture | `Ctrl+Alt+N` | Creating content without a URL |
| Duplicate | `Ctrl+D` in Browser | Creating variations of existing |

### Web Capture (`Ctrl+Alt+G`)

1. Navigate to any webpage
2. (Optional) Select/highlight specific text
3. Press `Ctrl+Alt+G`
4. Fill in the capture form:

**Required:**
- **Name**: 1-50 characters, letters and numbers only

**Auto-filled:**
- **Title**: Extracted from page
- **URL**: Current page address
- **Body**: Your selected text

**Optional:**
- **Tags**: Categories like `news`, `recipe`, `work`
- **Opinion**: Your take on the content (included when sharing)
- **Note**: Private notes (never shared)
- **Short Version**: Abbreviated version for character-limited platforms

### Manual Capture (`Ctrl+Alt+N`)

For content without a webpage:
- Quotes you want to remember
- Personal notes
- Templates for repeated use
- Contact information

### Capture Tips

**Good names:**
- `chickensoup` (memorable)
- `tax2025` (includes context)
- `jobemail1` (numbered for multiple)

**Bad names:**
- `a` (too short, forgettable)
- `my recipe for chicken soup` (too long, has spaces)
- `recipe#1` (special characters not allowed)

---

## Using Your Captures

### Basic Paste

Type your capture name followed by a trigger:
- `recipe1` + Space
- `recipe1` + Tab
- `recipe1` + Enter

The trigger character is consumed and your content appears.

### What Gets Pasted

Default paste format:
```
Recipe Title Here
https://example.com/recipe

Your opinion about this recipe...

The body content you captured or highlighted...
```

### Quick Action Menu

Type `recipe1?` to see all available actions without pasting.

---

## The Suffix System

The suffix system is ContentCapture Pro's superpower. Every capture automatically gets 20+ variations.

### How Suffixes Work

Your capture name + suffix = specific action

| You Type | What Happens |
|----------|--------------|
| `recipe1` | Paste full content |
| `recipe1go` | Open URL in browser |
| `recipe1em` | Create Outlook email |
| `recipe1fb` | Share to Facebook |

### Complete Suffix Reference

#### Basic Actions
| Suffix | Action | Example |
|--------|--------|---------|
| (none) | Paste full content | `recipe1` |
| `?` | Show action menu | `recipe1?` |
| `sh` | Paste short version | `recipe1sh` |
| `go` | Open URL in browser | `recipe1go` |
| `vi` | View/Edit capture | `recipe1vi` |
| `rd` | Read in popup window | `recipe1rd` |
| `pr` | Print formatted | `recipe1pr` |

#### Email Actions
| Suffix | Action | Example |
|--------|--------|---------|
| `em` | New Outlook email | `recipe1em` |
| `oi` | Insert in open email | `recipe1oi` |
| `ed` | Email with attachment | `recipe1ed` |
| `d.` | Open attachment | `recipe1d.` |

#### Social Media
| Suffix | Platform | Char Limit |
|--------|----------|------------|
| `fb` | Facebook | 63,206 |
| `x` | Twitter/X | 280 |
| `bs` | Bluesky | 300 |
| `li` | LinkedIn | 3,000 |
| `mt` | Mastodon | 500 |

#### Research Tools
| Suffix | Tool | Example |
|--------|------|---------|
| `yt` | YouTube Transcript | `video1yt` |
| `pp` | Perplexity AI | `article1pp` |
| `fc` | Snopes Fact Check | `claim1fc` |
| `mb` | Media Bias Check | `news1mb` |
| `wb` | Wayback Machine | `page1wb` |
| `gs` | Google Scholar | `topic1gs` |
| `av` | Archive.today | `page1av` |

#### AI Actions
| Suffix | Action | Example |
|--------|--------|---------|
| `sum` | AI Summarize | `article1sum` |

---

## Capture Browser

The Capture Browser (`Ctrl+Alt+B`) is your command center.

### Opening the Browser

- Press `Ctrl+Alt+B`
- Or right-click tray icon → "Capture Browser"

### Browser Interface

```
┌─────────────────────────────────────────────────────┐
│ Search: [____________] Tag: [All Tags ▼] [Filter]   │
├─────────────────────────────────────────────────────┤
│ ⭐ │ 📷 │ Name     │ Title              │ Tags │Date│
├────┼────┼──────────┼────────────────────┼──────┼────┤
│ ⭐ │    │ recipe1  │ Best Chicken Soup  │ food │1/19│
│    │ 📷 │ article1 │ Breaking News...   │ news │1/18│
│    │    │ howto1   │ Python Tutorial    │ code │1/17│
├─────────────────────────────────────────────────────┤
│ [Open][Copy][Email][Fav][Hotstring][Read][Edit][Del]│
│ [Img][Research][New][Link][Preview][Refresh][Close] │
├─────────────────────────────────────────────────────┤
│ Showing 218 captures | Enter=Paste | F5=Refresh     │
└─────────────────────────────────────────────────────┘
```

### Browser Buttons

**Row 1 - Main Actions:**
| Button | Action |
|--------|--------|
| 🌐 Open | Open URL in browser |
| 📋 Copy | Copy to clipboard or duplicate |
| 📧 Email | Send via Outlook |
| ⭐ Fav | Toggle favorite status |
| ❓ Hotstring | Show all available suffixes |
| 📖 Read | Read full content in popup |
| ✏️ Edit | Edit the capture |
| 🗑️ Del | Delete (with confirmation) |
| 📷 Img | Attach/manage image |
| 🔬 Research | Research tools menu |

**Row 2 - Utility Buttons (New in v5.8):**
| Button | Shortcut | Action |
|--------|----------|--------|
| ➕ New | `Ctrl+N` | Create new capture |
| 🔗 Link | `Ctrl+L` | Copy URL only |
| 👁 Preview | `Ctrl+P` | Full content preview |
| 🔄 Refresh | `F5` | Reload from disk |

### Searching & Filtering

**Search Box:**
- Searches ALL fields: name, title, body, opinion, tags, URL, notes
- Updates as you type (300ms delay)

**Tag Filter:**
- Dropdown shows all your tags
- Select a tag to filter results

### Keyboard Navigation

| Key | Action |
|-----|--------|
| `Enter` | Paste selected capture |
| `Delete` | Delete selected capture |
| `Ctrl+F` | Focus search box |
| `Ctrl+D` | Duplicate selected |
| `Ctrl+N` | New capture |
| `Ctrl+L` | Copy link only |
| `Ctrl+P` | Preview capture |
| `F5` | Refresh list |
| `Escape` | Close browser |

---

## Quick Search

Quick Search (`Ctrl+Alt+Space`) provides instant access without the full browser.

### Using Quick Search

1. Press `Ctrl+Alt+Space`
2. Start typing a capture name
3. Results appear as you type
4. Press `Enter` to paste
5. Or click a result

### Quick Search Features

- Fuzzy matching (finds `recpe1` even if you typed `recipe1`)
- Shows title preview
- Recent captures shown first
- Press `Escape` to close

---

## Social Media Sharing

### Auto-Detection

ContentCapture Pro detects when you're on:
- Facebook
- Twitter/X
- Bluesky
- LinkedIn
- Mastodon

When detected, it:
- Shows character count
- Warns if over limit
- Formats content appropriately

### Character Limits

| Platform | Limit | URL Counts As |
|----------|-------|---------------|
| Twitter/X | 280 | 23 chars |
| Bluesky | 300 | 23 chars |
| Mastodon | 500 | Full length |
| LinkedIn | 3,000 | Full length |
| Facebook | 63,206 | Full length |

### Title Cleaning

Automatically removes:
- "- YouTube"
- "| CNN"
- "| The New York Times"
- And 20+ other common suffixes

### Saving Short Versions

1. Edit a capture (`Ctrl+Alt+B` → Edit)
2. Fill in the "Short Version" field
3. Use `namesh` suffix to paste the short version

---

## Research Tools

Access via `🔬 Research` button or suffixes.

### Available Tools

| Tool | Suffix | Description |
|------|--------|-------------|
| YouTube Transcript | `yt` | Extract video captions |
| Perplexity AI | `pp` | AI-powered research |
| Snopes | `fc` | Fact-check claims |
| Media Bias | `mb` | Check source credibility |
| Wayback Machine | `wb` | View archived versions |
| Google Scholar | `gs` | Find academic sources |
| Archive.today | `av` | Save page permanently |

### Using Research Tools

**Option 1: From Browser**
1. Select a capture
2. Click `🔬 Research`
3. Choose a tool

**Option 2: Via Suffix**
- Type `article1fc` to fact-check
- Type `video1yt` to get transcript

---

## AI Integration

### Supported Providers

| Provider | Cost | Privacy | Setup |
|----------|------|---------|-------|
| OpenAI (GPT) | Pay-per-use | Cloud | API key |
| Anthropic (Claude) | Pay-per-use | Cloud | API key |
| Ollama | Free | 100% Local | Install app |

### Setting Up AI

1. Press `Ctrl+Alt+A`
2. Click "AI Settings" or follow setup prompt
3. Choose your provider
4. Enter API key (or Ollama URL)

### AI Actions

| Action | What It Does |
|--------|--------------|
| Summarize | Condense to key points |
| Rewrite for Twitter | 280 chars with hashtags |
| Rewrite for LinkedIn | Professional tone |
| Rewrite for Email | Formal business style |
| Extract Key Points | Bullet-point summary |
| Improve Writing | Grammar, clarity, flow |

### On-Demand Summarization

Type `capturenamesum` to summarize any capture instantly.

Example: `article1sum` → AI summary appears

---

## Backup & Restore

### Automatic Backups

ContentCapture Pro backs up automatically:
- On every save
- Stored in `backups/` folder
- Keeps last 10 backups

### Manual Backup

1. Right-click tray icon
2. Click "Backup Now"
3. Choose location (USB, cloud, etc.)

### Restoring from Backup

1. Right-click tray icon
2. Click "Restore Backup"
3. Browse to backup file
4. Confirm restore

### Backup Best Practices

- Keep backups in cloud storage (Dropbox, OneDrive)
- Copy `captures.dat` to USB monthly
- Export to HTML periodically

---

## Settings & Configuration

### Accessing Settings

- Right-click tray icon → Settings
- Or edit `config.ini` directly

### Available Settings

| Setting | Description | Default |
|---------|-------------|---------|
| Quiet Mode | Suppress notifications | Off |
| Auto-backup | Backup on save | On |
| Dark Theme | Dark GUI colors | On |
| AI Provider | OpenAI/Anthropic/Ollama | None |
| Startup | Run on Windows start | Off |

### Quiet Mode

Suppresses success notifications while keeping error alerts. Toggle via tray menu.

---

## Troubleshooting

### Hotstrings Not Working

**Symptoms:** Type capture name, nothing happens

**Solutions:**
1. Check script is running (tray icon visible?)
2. Reload script: `Ctrl+Alt+L`
3. Verify `ContentCapture_Generated.ahk` exists
4. Check for typos in capture name

### Paste Is Truncated

**Symptoms:** Only part of content pastes

**Solutions:**
1. Update to v5.3+ (SafePaste fix)
2. Try slower typing speed in settings
3. Check clipboard isn't being modified by other software

### Browser Not Detected

**Symptoms:** "Cannot detect browser" message

**Solutions:**
1. Make sure browser is the active window
2. Try a different browser (Chrome, Firefox, Edge)
3. Refresh the page and try again

### AI Not Responding

**Symptoms:** AI features hang or fail

**Solutions:**
1. Check API key is valid
2. For Ollama: verify it's running (`ollama serve`)
3. Check internet connection (for cloud providers)
4. Try "Capture First, Process Later" workflow

### Data Not Saving

**Symptoms:** Captures disappear after restart

**Solutions:**
1. Check folder permissions (need write access)
2. Run as administrator if needed
3. Check antivirus isn't blocking file writes
4. Verify `captures.dat` file exists

---

## Keyboard Reference

### Global Hotkeys (Work Anywhere)

| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+G` | Capture webpage |
| `Ctrl+Alt+N` | Manual capture |
| `Ctrl+Alt+B` | Open browser |
| `Ctrl+Alt+Space` | Quick search |
| `Ctrl+Alt+A` | AI assist |
| `Ctrl+Alt+L` | Reload script |

### Browser Hotkeys (In Capture Browser)

| Hotkey | Action |
|--------|--------|
| `Enter` | Paste selected |
| `Delete` | Delete selected |
| `Ctrl+F` | Focus search |
| `Ctrl+D` | Duplicate |
| `Ctrl+N` | New capture |
| `Ctrl+L` | Copy link |
| `Ctrl+P` | Preview |
| `F5` | Refresh |
| `Escape` | Close |

### Suffix Quick Reference

| Suffix | Action |
|--------|--------|
| (none) | Paste all |
| `?` | Action menu |
| `sh` | Short version |
| `go` | Open URL |
| `em` | New email |
| `oi` | Insert in email |
| `vi` | Edit |
| `rd` | Read popup |
| `fb` | Facebook |
| `x` | Twitter |
| `bs` | Bluesky |
| `li` | LinkedIn |
| `mt` | Mastodon |
| `sum` | AI summarize |
| `fc` | Fact check |
| `mb` | Media bias |

---

## Getting Help

- **GitHub Issues**: Report bugs and request features
- **AutoHotkey Forums**: [Topic Link](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=139887)
- **README**: Quick reference at [README.md](README.md)

---

*ContentCapture Pro v5.8 | Built with ❤️ and Claude AI*
