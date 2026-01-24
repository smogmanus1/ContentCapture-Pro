# ContentCapture Pro

**Professional Content Capture & Sharing System for Windows**

Transform how you save, organize, and share web content. Capture any webpage with a single hotkey and recall it instantly by typing a short name — from ANY application.

![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0+-green)
![License](https://img.shields.io/badge/License-MIT-blue)
![Version](https://img.shields.io/badge/Version-6.0.0-orange)

## ✨ Key Features

### 🚀 Instant Capture
- Press `Ctrl+Alt+G` on any webpage to capture URL, title, and content
- Highlight text before capturing to save specific excerpts
- Add tags, notes, and your personal commentary
- Works with Chrome, Firefox, Edge, Brave, and most browsers

### ⚡ Lightning-Fast Recall
- Type `::recipe::` anywhere to instantly paste your saved "recipe" capture
- No app switching, no searching — just type and it appears
- Works in Word, email, social media, chat apps — everywhere you can type

### 🔍 Powerful Search
- **Quick Search** (`Ctrl+Alt+Space`): Alfred/Raycast-style instant popup
- **Full Browser** (`Ctrl+Alt+B`): Search by name, tags, URL, date, or content
- Filter by favorites, date range, or specific tags

### 📱 Smart Social Sharing
- Auto-detects when you're on Facebook, Twitter/X, Bluesky, LinkedIn
- Warns when content exceeds platform character limits
- Save shortened versions for one-click sharing

### 🎯 Powerful Suffix System

Every capture gets automatic hotstring variants:

| Suffix | Action | Example |
|--------|--------|---------|
| (none) | Paste full content | `::recipe::` |
| `?` | Show action menu | `::recipe?::` |
| `t` | Title only | `::recipet::` |
| `url` | URL only | `::recipeurl::` |
| `body` | Body only | `::recipebody::` |
| `cp` | Copy (no paste) | `::recipecp::` |
| `i` | Image path | `::recipei::` |
| `ti` | Title + image | `::recipeti::` |
| `go` | Open URL | `::recipego::` |
| `em` | Email via Outlook | `::recipeem::` |
| `fb` | Share to Facebook | `::recipefb::` |
| `x` | Share to Twitter/X | `::recipex::` |
| `bs` | Share to Bluesky | `::recipebs::` |

See [SUFFIX-REFERENCE.md](SUFFIX-REFERENCE.md) for the complete list.

## 📦 Installation

1. **Requirements**: [AutoHotkey v2.0+](https://www.autohotkey.com/)

2. **Download**: Clone this repo or download the ZIP

3. **Run**: Double-click `ContentCapture.ahk`

4. **First Run**: Follow the setup wizard to choose your data location

See [INSTALL.md](INSTALL.md) for detailed instructions.

## 🎹 Hotkeys

| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+G` | Capture current webpage |
| `Ctrl+Alt+Space` | Quick Search |
| `Ctrl+Alt+B` | Open Capture Browser |
| `Ctrl+Alt+M` | Main Menu |
| `Ctrl+Alt+N` | Manual Capture (no browser) |
| `Ctrl+Alt+E` | Email last capture |
| `Ctrl+Alt+W` | Toggle recent widget |

## 📁 File Structure

```
ContentCapture-Pro/
├── ContentCapture.ahk       # Launcher (run this)
├── ContentCapture-Pro.ahk   # Main application
├── DynamicSuffixHandler.ahk # Suffix routing system
├── ImageCapture.ahk         # Image attachment system
├── ImageClipboard.ahk       # GDI+ clipboard operations
├── ImageDatabase.ahk        # Multi-image management
├── ImageSharing.ahk         # Image sharing features
├── SocialShare.ahk          # Social media integration
├── ResearchTools.ahk        # Research & fact-checking
├── CC_ShareModule.ahk       # Import/Export captures
├── CC_HoverPreview.ahk      # Browser hover previews
└── images/                  # Attached images folder
```

## 🤝 Credits

- **Creator**: Brad ([@smogmanus1](https://github.com/smogmanus1))
- **Website**: [crisisoftruth.org](https://crisisoftruth.org)

### Special Thanks
- Joe Glines ([the-Automator.com](https://the-automator.com))
- Isaias Baez (RaptorX)
- Jack Dunning
- The AutoHotkey Community

## 📄 License

MIT License - see [LICENSE](LICENSE)

## 🐛 Issues & Contributions

Found a bug? Have a feature request? 
- Open an issue on [GitHub](https://github.com/smogmanus1/ContentCapture-Pro/issues)
- See [CONTRIBUTING.md](CONTRIBUTING.md) for contribution guidelines

---

**ContentCapture Pro** — *Your personal knowledge base at your fingertips*
