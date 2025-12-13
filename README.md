# ContentCapture Pro

![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0%2B-green)
![License](https://img.shields.io/badge/License-MIT-blue)
![Version](https://img.shields.io/badge/Version-4.2-orange)

**Capture web content, create instant hotstrings, share anywhere.**

ContentCapture Pro is a powerful AutoHotkey v2 application that lets you capture webpage content (URLs, titles, text) and instantly recall it using simple hotstrings. Share to email, social media, or paste anywhere with just a few keystrokes.

## ✨ Features

- **One-Click Capture** - Press `Ctrl+Alt+P` on any webpage to capture URL, title, and selected text
- **Instant Recall** - Type your capture name to paste content anywhere
- **Smart Suffixes** - Add `em`, `go`, `fb`, `x` to trigger actions instantly
- **Quick Search** - `Ctrl+Alt+Space` for Alfred/Raycast-style instant search
- **Social Sharing** - Built-in support for Facebook, Twitter/X, Bluesky, LinkedIn, Mastodon
- **Email Integration** - Send captures directly via Outlook
- **Backup System** - Automatic backups with cloud drive detection
- **HTML Export** - Export your entire capture library

## 🚀 Quick Start

### Installation

1. Install [AutoHotkey v2](https://www.autohotkey.com/download/)
2. Download the latest release
3. Extract to a folder
4. Double-click `ContentCapture.ahk`
5. Follow the first-run setup wizard

### Basic Usage

| Action | How |
|--------|-----|
| Capture webpage | `Ctrl+Alt+P` |
| Browse captures | `Ctrl+Alt+B` |
| Quick search | `Ctrl+Alt+Space` |
| Paste capture | Type `::name::` |
| Action menu | Type `::name?::` |

## ⌨️ Hotstring Suffixes

Type your capture name followed by a suffix, then press space:

| Suffix | Action | Example |
|--------|--------|---------|
| *(none)* | Paste full content | `myrecipe` + space |
| `em` | Email via Outlook | `myrecipeem` + space |
| `go` | Open URL in browser | `myrecipego` + space |
| `rd` | Read in popup | `myreciperd` + space |
| `vi` | View/Edit capture | `myrecipevi` + space |
| `fb` | Share to Facebook | `myrecipefb` + space |
| `x` | Share to Twitter/X | `myrecipex` + space |
| `bs` | Share to Bluesky | `myrecipebs` + space |
| `li` | Share to LinkedIn | `myrecipeli` + space |
| `mt` | Share to Mastodon | `myrecipemt` + space |

## 🎹 Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+P` | Capture current webpage |
| `Ctrl+Alt+B` | Open capture browser |
| `Ctrl+Alt+Space` | Quick search popup |
| `Ctrl+Alt+N` | Manual capture (no browser) |
| `Ctrl+Alt+M` | Show main menu |
| `Ctrl+Alt+E` | Email last capture |
| `Ctrl+Alt+H` | Export to HTML |
| `Ctrl+Alt+K` | Backup captures |
| `Ctrl+Alt+S` | Settings/Setup |
| `Ctrl+Alt+F12` | Show help |

## 📁 File Structure

```
ContentCapture-Pro/
├── ContentCapture.ahk          # Main launcher (run this)
├── ContentCapture-Pro.ahk      # Core application
├── DynamicSuffixHandler.ahk    # Suffix hotstring engine
├── ContentCapture-Setup.ahk    # First-run wizard
├── ContentCapture_Generated.ahk # Auto-generated (created on first run)
├── captures.dat                # Your capture data (created on first run)
├── capture_index.txt           # Quick lookup index (created on first run)
└── config.ini                  # Settings (created on first run)
```

## 🔧 Configuration

On first run, the setup wizard will guide you through:

1. **Storage Location** - Where to save your captures
2. **Startup Option** - Run automatically with Windows
3. **Social Media** - Enable/disable sharing platforms

Settings can be changed anytime via `Ctrl+Alt+S`.

## 📝 Data Format

Captures are stored in a simple INI-style format in `captures.dat`:

```ini
[mycapture]
url=https://example.com/article
title=Example Article Title
tags=news,reference
opinion=My thoughts on this article
body=<<<BODY
The full text content of the capture
goes here, supporting multiple lines.
BODY>>>
```

## 🙏 Credits

- [AutoHotkey Development Team](https://www.autohotkey.com/)
- [Jack Dunning](https://www.computoredge.com/AutoHotkey/) - AutoHotkey educator & author
- [Joe Glines & The Automator](https://www.the-automator.com/) - AHK education & community
- Antonio Bueno (atnbueno) - Browser URL capture concepts

## 📄 License

MIT License - See [LICENSE](LICENSE) for details.

## 🤝 Contributing

Contributions welcome! Please feel free to submit issues and pull requests.

---

**Made with ❤️ by Brad Schrunk**
