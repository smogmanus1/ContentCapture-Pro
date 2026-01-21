# ContentCapture Pro v5.9.1 Release Notes

**Release Date:** January 21, 2026

---

## 🎉 What's New in v5.9.1

### 🔍 Hover Preview Tooltips
Hover over any capture in the Browser for ~400ms to see a preview!

**What you see:**
- 📋 Capture name
- Title and URL
- Body preview (first 300 characters)
- 💭 Opinion/notes
- 🏷️ Tags
- Status line: 📅 date, ⭐ favorite, 📷 image, 🔬 research, 📝 transcript

**How to use:**
1. Open Capture Browser (`Ctrl+Alt+B`)
2. Move mouse over any capture row
3. Hold still for ~half second
4. Tooltip appears with preview!

---

### 📋 Copy for AI Research
New submenu in Research Tools for quick AI research workflows!

**Access:** Click `🔬 Research` → `📋 Copy for AI Research`

| Option | What It Does |
|--------|--------------|
| 📄 Copy Body Text | Copy body to clipboard |
| 📝 Copy Transcript | Copy transcript to clipboard |
| 📋 Copy Summary | Copy AI summary to clipboard |
| 🤖 Copy → ChatGPT | Copy content & open ChatGPT |
| 🧠 Copy → Claude | Copy content & open Claude |
| 🔍 Copy → Perplexity | Copy content & open Perplexity |
| 🦙 Copy → Ollama | Copy content & open local Ollama |

**The "Copy → Open" options:**
- Automatically build a prompt with title and content
- Open the AI tool in your browser
- Just paste with `Ctrl+V`!

---

### 🔧 Fixes
- **Share button icon** changed from `🔗` to `📤` (no longer confused with Link button)

---

## 📦 Files

### New Files
| File | Description |
|------|-------------|
| `CC_HoverPreview.ahk` | Hover preview tooltip functionality |

### Updated Files
| File | Changes |
|------|---------|
| `ContentCapture-Pro.ahk` | Share icon fix, hover preview integration |
| `ResearchTools.ahk` | Added Copy for AI submenu |
| `CC_ShareModule.ahk` | Share & Import system (from v5.9) |
| `README.md` | Updated documentation |
| `CHANGELOG.md` | Added v5.9.1 notes |

---

## 📥 Installation

### New Users
1. Download all files
2. Run `ContentCapture.ahk`
3. Follow the setup wizard

### Existing Users
Replace these files in your ContentCapture folder:
1. `ContentCapture-Pro.ahk`
2. `ResearchTools.ahk`
3. `CC_HoverPreview.ahk` (new file)
4. Reload script (`Ctrl+Alt+L`)

---

## 🔄 Upgrade from v5.9

If you already have v5.9:
1. Download `CC_HoverPreview.ahk` (new)
2. Replace `ContentCapture-Pro.ahk`
3. Replace `ResearchTools.ahk`
4. Reload your script

Your captures, settings, and data are preserved!

---

## 💡 Tips

### Hover Preview
- Adjust delay: Edit `HoverDelay := 400` in `CC_HoverPreview.ahk` (milliseconds)
- Adjust body length: Edit `MaxBodyChars := 300`

### Copy for AI
- Prefers transcript over body when both exist
- Prompt includes title for context
- Works with any AI that accepts pasted text

---

## 🐛 Bug Reports

Found an issue? Please report it:
- GitHub Issues: [Create Issue](https://github.com/yourusername/ContentCapture-Pro/issues)
- Include: AHK version, Windows version, steps to reproduce

---

## ❤️ Thank You

Thanks to the AutoHotkey community for continued support and feedback!

Special thanks to:
- Joe Glines (the-Automator.com)
- Isaias Baez (RaptorX)
- Jack Dunning
- Everyone who reported issues and suggested features!

---

## 📊 Version History

| Version | Date | Highlights |
|---------|------|------------|
| **5.9.1** | 2026-01-21 | Hover preview, Copy for AI |
| 5.9 | 2026-01-19 | Share & Import with images |
| 5.8 | 2026-01-19 | Browser buttons, Preview window |
| 5.7 | 2026-01-15 | Capture First Process Later |

See `CHANGELOG.md` for full history.
