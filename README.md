# ContentCapture Pro

### *Save it once. Recall it forever. Share it anywhere.*

[![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0-blue)](https://www.autohotkey.com/)
[![License](https://img.shields.io/badge/License-MIT-green.svg)](LICENSE)
[![Version](https://img.shields.io/badge/Version-4.5-orange)]()

---

## 🎯 What is ContentCapture Pro?

ContentCapture Pro transforms how you save, organize, and share web content. Instead of bookmarks you never revisit or scattered notes, capture any webpage with a simple hotkey and recall it instantly by typing a short name.

**Press `Ctrl+Alt+P` on any webpage → Give it a name like "recipe" → Type `::recipe::` anywhere to paste it.**

That's it. Your content is saved forever and accessible from any application.

---

## ✨ Key Features

| Feature | Description |
|---------|-------------|
| ⚡ **Instant Capture** | Press `Ctrl+Alt+P` to capture any webpage - URL, title, and content |
| 🚀 **Lightning Recall** | Type `::name::` anywhere to instantly paste your saved content |
| 🔍 **Powerful Search** | Quick Search (`Ctrl+Alt+Space`) finds any capture in seconds |
| 📱 **Smart Social Sharing** | Auto-detects platform limits, counts characters correctly |
| 🤖 **AI Integration** | Summarize, rewrite, and improve content with AI (optional) |
| ⭐ **Favorites & Tags** | Organize captures with stars and custom tags |
| 💾 **Auto-Backup** | Never lose your data with automatic backups |
| 🎬 **YouTube Timestamps** | Save videos starting at any timestamp |

---

## 📱 Smart Social Sharing

ContentCapture Pro knows social media:

- ✅ **Auto-detects** when you're on Facebook, Twitter/X, Bluesky, LinkedIn, etc.
- ✅ **Warns you** when content exceeds platform character limits
- ✅ **Counts characters correctly** — URLs count as 23 chars on Twitter/Bluesky
- ✅ **Cleans titles** — removes "- YouTube", "| CNN" to save space
- ✅ **Saves short versions** — one-click sharing forever after

| Platform | Character Limit |
|----------|----------------|
| Bluesky | 300 |
| Twitter/X | 280 |
| Mastodon | 500 |
| LinkedIn | 3,000 |
| Threads | 500 |

---

## 🎯 Smart Suffixes

Every capture gets **11 automatic hotstrings**:

| Suffix | Action | Example |
|--------|--------|---------|
| *(none)* | Paste content | `::recipe::` |
| `?` | Show action menu | `::recipe?::` |
| `go` | Open URL in browser | `::recipego::` |
| `em` | Email via Outlook | `::recipeem::` |
| `rd` | Read in popup | `::reciperd::` |
| `vi` | View/Edit capture | `::recipevi::` |
| `fb` | Share to Facebook | `::recipefb::` |
| `x` | Share to Twitter/X | `::recipex::` |
| `bs` | Share to Bluesky | `::recipebs::` |
| `li` | Share to LinkedIn | `::recipeli::` |
| `mt` | Share to Mastodon | `::recipemt::` |

---

## 🔧 Installation

### Easy Install (Recommended)

1. **Download** this repository (Code → Download ZIP)
2. **Extract** to a safe location (see note below)
3. **Double-click `INSTALL.bat`**

That's it! The installer will:
- ✅ Check if AutoHotkey v2 is installed
- ✅ Guide you to download it if needed
- ✅ Launch ContentCapture Pro when ready

### Where to Extract (Important!)

> ⚠️ **Your captures are stored where the script runs. Choose wisely!**

| Location | Recommendation |
|----------|----------------|
| ✅ `D:\ContentCapture\` | **BEST** - Secondary drive survives Windows reinstalls |
| ✅ `C:\Users\You\Documents\ContentCapture\` | Good - Usually backed up |
| ✅ Dropbox/OneDrive folder | Good - Cloud backup |
| ❌ `C:\Program Files\` | **BAD** - Windows blocks writes |
| ❌ Desktop | **BAD** - Easy to accidentally delete |

### Manual Install (Advanced)

If you prefer manual installation:

1. Install [AutoHotkey v2.0+](https://www.autohotkey.com/) (click Download → v2.0)
2. Double-click `ContentCapture.ahk` to run

---

## 🚀 Quick Start

### Capture Your First Webpage

1. Go to any webpage in your browser
2. Press `Ctrl+Alt+P`
3. Give it a short name like "test"
4. Click Save

### Recall It Anywhere

1. Open any text field (Word, email, chat, anywhere)
2. Type `::test::`
3. Watch your content appear! 🎉

### Find Your Captures

- **Quick Search:** `Ctrl+Alt+Space` → Type to filter → Enter to paste
- **Full Browser:** `Ctrl+Alt+B` → Search, filter, edit, delete

---

## ⌨️ Keyboard Shortcuts

### Capture & Create
| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+P` | Capture current webpage |
| `Ctrl+Alt+N` | Manual capture (no browser) |

### Search & Browse
| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+Space` | Quick Search popup |
| `Ctrl+Alt+B` | Full Capture Browser |
| `Ctrl+Alt+Shift+B` | Restore from backup |

### Utilities
| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+M` | Show main menu |
| `Ctrl+Alt+A` | AI Assist menu |
| `Ctrl+Alt+H` | Export to HTML |
| `Ctrl+Alt+K` | Backup/Restore |
| `Ctrl+Alt+L` | Reload script |
| `Ctrl+Alt+F12` | Show help |

---

## 🤖 AI Integration (Optional)

Connect your favorite AI to enhance your content:

- **Summarize** long articles into bullet points
- **Rewrite for Twitter** — engaging, under 280 chars
- **Rewrite for LinkedIn** — professional tone
- **Improve writing** — grammar, clarity, flow

### Supported Providers

| Provider | Cost | Privacy |
|----------|------|---------|
| [OpenAI](https://openai.com/) | Pay per use | Cloud |
| [Anthropic Claude](https://anthropic.com/) | Pay per use | Cloud |
| [Ollama](https://ollama.ai/) | **Free** | **100% Local** |

Setup: Press `Ctrl+Alt+A` → AI Settings

---

## 📁 File Structure

```
ContentCapture-Pro/
├── ContentCapture.ahk          # Launcher (run this!)
├── ContentCapture-Pro.ahk      # Main application
├── DynamicSuffixHandler.ahk    # Suffix hotstring handler
├── config.ini                  # Your settings (auto-created)
├── captures.dat                # Your saved captures (auto-created)
├── ContentCapture_Generated.ahk # Auto-generated hotstrings
├── favorites.txt               # Your starred captures
└── backups/                    # Automatic backups folder
```

---

## 🧠 How It Handles 10,000+ Captures

ContentCapture Pro uses intelligent indexing:

- **Hash Map lookup** — O(1) instant retrieval regardless of size
- **Full-text search** — Searches name, title, URL, tags, notes, and body
- **Sorted arrays** — Alphabetical browsing stays fast

You don't need to remember exact names. Search for *any word* from *any field* and it finds your capture.

---

## 💡 Pro Tips

1. **Keep names short** — "pasta" beats "italian-pasta-recipe-from-grandma"
2. **Use the `?` suffix** — `::name?::` shows all options
3. **Save short versions** — Next time it's one-click sharing
4. **Star favorites** — They appear in the tray menu
5. **Use tags** — Filter by #news, #tutorial, #work
6. **Back up your data** — Set up auto-backup in settings

---

## 🔄 Updating

1. Download the new version
2. Replace these files:
   - `ContentCapture-Pro.ahk`
   - `DynamicSuffixHandler.ahk`
   - `ContentCapture.ahk`
3. **Keep** your `captures.dat` and `config.ini`!
4. Reload the script (`Ctrl+Alt+L`)

---

## 🐛 Troubleshooting

### Hotstrings not working?
- Make sure you type `::` before AND after: `::name::`
- Check that the script is running (look for tray icon)
- Press `Ctrl+Alt+L` to reload

### Can't capture webpage?
- Make sure you're in a supported browser
- Try clicking in the page first, then `Ctrl+Alt+P`

### Character count seems wrong?
- Social platforms count URLs as 23 characters
- Our counter matches their counting method

### Script won't start?
- Verify AutoHotkey v2.0+ is installed
- Right-click → Run as Administrator (once)

---

## 🤝 Credits

- **[AutoHotkey Team](https://www.autohotkey.com/)** — The foundation
- **[Joe Glines & The Automator](https://www.the-automator.com/)** — Education & inspiration
- **[Jack Dunning](https://www.computoredge.com/AutoHotkey/)** — Books & tutorials
- **Claude AI (Anthropic)** — Development assistance

---

## 📄 License

MIT License — Use it, modify it, share it.

See [LICENSE](LICENSE) for details.

---

## 🌟 Star This Repo!

If ContentCapture Pro saves you time, consider starring ⭐ this repo!

---

*Stop losing great content. Start capturing it.*

**ContentCapture Pro** — Save it once. Recall it forever. Share it anywhere.
