# ContentCapture Pro v5.8

**Capture any webpage and recall it instantly by typing a short keyword.**

![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0+-green)
![Windows](https://img.shields.io/badge/Windows-10%2F11-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)
![Version](https://img.shields.io/badge/Version-5.8-orange)

---

## What is ContentCapture Pro?

ContentCapture Pro is a Windows productivity tool that lets you:

1. **Capture** any webpage with one hotkey (`Ctrl+Alt+G`)
2. **Store** the URL, title, and any text you've selected
3. **Recall** content instantly by typing a short name you choose
4. **Share** to email, social media, or anywhere you can type

### Example Workflow

```
1. You find an article about climate change
2. Press Ctrl+Alt+G, name it "climate1"
3. Later, type "climate1" anywhere → full content pastes instantly
4. Or type "climate1em" → creates an Outlook email
5. Or type "climate1fb" → shares to Facebook
6. Or type "climate1sum" → AI summarizes the content
```

---

## Quick Start (5 Minutes)

### Step 1: Install AutoHotkey v2

Download from [autohotkey.com](https://www.autohotkey.com) → Choose v2.0+

### Step 2: Download ContentCapture Pro

- Click the green Code button → **Download ZIP**
- Extract all files to a folder
- Keep all files together

### Step 3: Run It

Double-click `ContentCapture.ahk`

### Step 4: Capture Your First Page

1. Go to any webpage in your browser
2. Press `Ctrl+Alt+G`
3. Give it a short name like "test1"
4. Click Save

### Step 5: Use Your Capture

Type your name followed by a space, tab, or enter:

| You Type | What Happens |
|----------|--------------|
| `test1` | Pastes full content |
| `test1go` | Opens the URL in browser |
| `test1em` | Creates Outlook email |
| `test1fb` | Shares to Facebook |
| `test1sum` | AI summarizes content |

---

## Features

### Core Features

- **One-Key Capture** (`Ctrl+Alt+G`) - Capture URL, title, and selected text
- **Instant Recall** - Type name + space to paste anywhere
- **Smart Detection** - Auto-detects social media platforms
- **Character Limits** - Warns when content exceeds platform limits
- **Title Cleaning** - Auto-removes "- YouTube", "| CNN", etc.
- **Preview Window** - View full capture details before sharing (New in v5.8!)
- **Fuzzy Search** - Find captures even with typos

### AI Features

- **Summarize** - Condense long articles to key points
- **Rewrite** - Adapt content for Twitter, LinkedIn, email
- **On-Demand** - Type `namesum` to summarize any capture
- **Local Option** - Use Ollama for 100% private AI processing

---

## Sharing Options (Suffixes)

### Basic Actions

| Suffix | What It Does |
|--------|--------------|
| (none) | Paste full content |
| `?` | Show action menu |
| `sh` | Paste short version |
| `go` | Open URL in browser |
| `vi` | View/Edit capture |
| `rd` | Read in popup window |
| `pr` | Print formatted |
| `sum` | AI summarize on demand |

### Email Options

| Suffix | Action |
|--------|--------|
| `em` | Create new Outlook email |
| `oi` | Insert into open Outlook email at cursor |
| `ed` | Email with document attached |
| `d.` | Open attached document |

### Social Media Sharing

| Suffix | Platform | Limit |
|--------|----------|-------|
| `fb` | Facebook | 63,206 chars |
| `x` | Twitter/X | 280 chars |
| `bs` | Bluesky | 300 chars |
| `li` | LinkedIn | 3,000 chars |
| `mt` | Mastodon | 500 chars |

### Research Tools

| Suffix | Tool | Action |
|--------|------|--------|
| `yt` | YouTube Transcript | Extract video captions |
| `pp` | Perplexity AI | AI-powered research |
| `fc` | Snopes | Fact-check claims |
| `mb` | Media Bias Check | Check source credibility |
| `wb` | Wayback Machine | View archived versions |
| `gs` | Google Scholar | Find academic sources |
| `av` | Archive.today | Save page permanently |

---

## Capture Browser

Press `Ctrl+Alt+B` to open the Capture Browser.

### Button Row 1 - Main Actions

| Button | Action |
|--------|--------|
| 🌐 Open | Open URL in browser |
| 📋 Copy | Copy content / Duplicate |
| 📧 Email | Send via Outlook |
| ⭐ Fav | Toggle favorite |
| ❓ Hotstring | Show available suffixes |
| 📖 Read | Read in popup |
| ✏️ Edit | Edit capture |
| 🗑️ Del | Delete capture |
| 📷 Img | Attach image |
| 🔬 Research | Research tools menu |

### Button Row 2 - Utilities (New in v5.8!)

| Button | Shortcut | Action |
|--------|----------|--------|
| ➕ New | `Ctrl+N` | Create new manual capture |
| 🔗 Link | `Ctrl+L` | Copy URL only to clipboard |
| 👁 Preview | `Ctrl+P` | Full content preview window |
| 🔄 Refresh | `F5` | Reload captures from disk |

---

## Keyboard Shortcuts

### Global (Work Anywhere)

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+G` | Capture current webpage |
| `Ctrl+Alt+N` | New manual capture (no browser needed) |
| `Ctrl+Alt+B` | Open Capture Browser |
| `Ctrl+Alt+Space` | Quick Search popup |
| `Ctrl+Alt+A` | AI Assist menu |
| `Ctrl+Alt+L` | Reload script |

### In Capture Browser

| Shortcut | Action |
|----------|--------|
| `Enter` | Paste selected capture |
| `Delete` | Delete selected capture |
| `Ctrl+F` | Focus search box |
| `Ctrl+D` | Duplicate capture |
| `Ctrl+N` | New capture |
| `Ctrl+L` | Copy link only |
| `Ctrl+P` | Preview capture |
| `F5` | Refresh list |
| `Escape` | Close browser |

---

## Installation

See [QUICKSTART.md](QUICKSTART.md) for detailed installation instructions.

### Requirements

- Windows 10 or 11
- AutoHotkey v2.0 or higher

---

## Documentation

- **[QUICKSTART.md](QUICKSTART.md)** - Get running in 5 minutes
- **[USER_MANUAL.md](USER_MANUAL.md)** - Complete reference guide
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and updates
- **[SUFFIX-REFERENCE.md](SUFFIX-REFERENCE.md)** - All suffixes at a glance
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute

---

## File Structure

```
ContentCapture-Pro/
├── ContentCapture.ahk           # Main launcher (run this!)
├── ContentCapture-Pro.ahk       # Core application
├── DynamicSuffixHandler.ahk     # Suffix system
├── ContentCapture-Setup.ahk     # First-run setup
├── ResearchTools.ahk            # Research integration
├── ImageCapture.ahk             # Image features
├── ImageClipboard.ahk           # Clipboard handling
├── SocialShare.ahk              # Social media
├── ContentCapture_Generated.ahk # Auto-generated hotstrings
├── captures.dat                 # Your capture data
├── config.ini                   # Settings
└── backups/                     # Automatic backups
```

---

## What's New in v5.8

- **4 new browser buttons**: New, Link, Preview, Refresh
- **Keyboard shortcuts**: `Ctrl+N`, `Ctrl+L`, `Ctrl+P`, `F5` in browser
- **Preview window**: View all capture fields with action buttons
- **Better organization**: Two button rows for easier access

See [CHANGELOG.md](CHANGELOG.md) for full version history (9 updates since initial release!)

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## Credits

**Author:** Brad Schrunk ([the-automator.com](https://www.the-automator.com))

**Built with:** Claude AI (Anthropic)

**Community Support:**
- [AutoHotkey Forums](https://www.autohotkey.com/boards/)
- Joe Glines @ [the-Automator.com](https://www.the-automator.com)
- Isaias Baez (RaptorX) - Essential AHK libraries
- Jack Dunning - AutoHotkey education
- Antonio Bueno (atnbueno) - URL capture concepts

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

## Support

- **Issues:** [GitHub Issues](../../issues)
- **AutoHotkey Forums:** [Forum Thread](https://www.autohotkey.com/boards/viewtopic.php?f=83&t=139887)

---

Made with ❤️ for the AutoHotkey community
