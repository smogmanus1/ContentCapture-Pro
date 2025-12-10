# ContentCapture Pro v4.2

**Professional Content Capture System for AutoHotkey v2**

Capture webpages, save them with memorable hotstring names, and recall them instantly anywhere you can type. Share to social media with a single command.

![AutoHotkey v2](https://img.shields.io/badge/AutoHotkey-v2.0+-blue)
![License](https://img.shields.io/badge/License-MIT-green)

---

## ✨ Features

- **🔥 Instant Capture** - Press `Ctrl+Alt+P` on any webpage to capture URL, title, and selected text
- **⚡ Quick Search** - Alfred/Raycast-style popup search with `Ctrl+Alt+Space`
- **🤖 AI Integration** - Summarize, rewrite, and improve content (OpenAI, Anthropic, or local Ollama)
- **📱 Social Sharing** - One-command sharing to Facebook, Twitter/X, Bluesky, LinkedIn, Mastodon
- **🏷️ Tags & Organization** - Categorize captures with tags for easy filtering
- **💾 Cloud Backup** - Automatic backup detection for Dropbox, OneDrive, Google Drive
- **📤 HTML Export** - Export all captures to a searchable HTML file

---

## 🚀 Quick Start

### Requirements
- Windows 10/11
- [AutoHotkey v2.0+](https://www.autohotkey.com/) installed

### Installation

1. **Download** and extract the zip to your preferred location
2. **Double-click** `ContentCapture-Pro.ahk` to run
3. **First run** will launch the Setup Wizard - choose where to save your captures
4. **Start capturing!** Press `Ctrl+Alt+P` in your browser

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+P` | **Capture** current webpage |
| `Ctrl+Alt+Space` | **Quick Search** popup |
| `Ctrl+Alt+A` | **AI Assist** menu |
| `Ctrl+Alt+B` | **Browse** all captures |
| `Ctrl+Alt+N` | **Manual** capture (no browser) |
| `Ctrl+Alt+M` | Show main **Menu** |
| `Ctrl+Alt+E` | **Email** last capture |
| `Ctrl+Alt+K` | **Backup**/Restore |
| `Ctrl+Alt+H` | Export to **HTML** |
| `Ctrl+Alt+F12` | Show **Help** |

---

## 📝 Using Hotstrings

After capturing a webpage with name `recipe`, you can type:

| Hotstring | Action |
|-----------|--------|
| `::recipe::` | Paste full content |
| `::recipe?::` | Show action menu |
| `::recipeem::` | Email via Outlook |
| `::recipego::` | Open URL in browser |
| `::reciperd::` | Read in popup window |
| `::recipevi::` | View/Edit capture |

### Social Media Suffixes

| Hotstring | Platform |
|-----------|----------|
| `::recipefb::` | Share to Facebook |
| `::recipex::` | Share to Twitter/X |
| `::recipebs::` | Share to Bluesky |
| `::recipeli::` | Share to LinkedIn |
| `::recipemt::` | Share to Mastodon |

> **Tip:** If content exceeds character limits, you'll get an edit window to trim it.

---

## 📁 File Structure

```
ContentCapture-Pro-v4.2/
├── ContentCapture-Pro.ahk      # Main script
├── DynamicSuffixHandler.ahk    # Suffix detection engine
├── ContentCapture_Generated.ahk # Auto-generated hotstrings
├── config.ini                  # Settings (created on first run)
├── captures.dat                # Your captures database
├── README.md                   # This file
├── LICENSE                     # MIT License
├── CHANGELOG.md                # Version history
├── docs/
│   ├── QuickReference.md       # Quick reference card
│   └── AI-Setup-Guide.md       # AI provider setup instructions
└── backups/                    # Backup storage
```

---

## 🔧 Configuration

### First-Time Setup

The Setup Wizard will ask you to:
1. Choose a save location (cloud folders auto-detected)
2. Select which social platforms to enable
3. (Optional) Configure AI integration

### AI Integration

ContentCapture Pro supports:
- **OpenAI** (GPT-4, GPT-3.5)
- **Anthropic** (Claude)
- **Ollama** (Local, free, private)

📖 **See [docs/AI-Setup-Guide.md](docs/AI-Setup-Guide.md) for detailed setup instructions.**

To enable: `Ctrl+Alt+S` → Configure AI settings

---

## 💡 Tips & Tricks

### YouTube URLs
YouTube timestamps are automatically stripped so shared links start from the beginning, not where you stopped watching.

### Duplicate Detection
The system warns you if you try to capture a URL that's already saved.

### Quick Actions
- Type `::name?::` for a quick action menu on any capture
- Use Quick Search (`Ctrl+Alt+Space`) for instant fuzzy finding

### Backup Strategy
- Automatic backup to detected cloud folders
- Manual backup to USB drives supported
- HTML export creates a standalone searchable archive

---

## 🙏 Credits

- **AutoHotkey Team** - [autohotkey.com](https://www.autohotkey.com/)
- **Jack Dunning** - Author of "AutoHotkey Applications" - [computoredge.com](https://www.computoredge.com/AutoHotkey/)
- **Joe Glines / The Automator** - [the-automator.com](https://www.the-automator.com/)
- **Antonio Bueno** - Browser URL capture techniques
- **Claude AI (Anthropic)** - Development assistance

---

## 📄 License

MIT License - Free to use, modify, and distribute.

---

## 🐛 Troubleshooting

### "Script not running"
- Make sure AutoHotkey v2.0+ is installed
- Right-click the script → Run as Administrator (if needed)

### "Hotstrings not working"
- Reload the script (`Ctrl+Alt+L`)
- Check that the generated file exists

### "Can't capture URL"
- Make sure you're in a browser window
- Try clicking in the address bar first

---

**Made with ❤️ for the AutoHotkey community**
