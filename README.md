# ContentCapture Pro v5.6

**Capture any webpage and recall it instantly by typing a short keyword.**

![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0+-green)
![Version](https://img.shields.io/badge/version-5.6-blue)
![License](https://img.shields.io/badge/License-MIT-orange)
![Platform](https://img.shields.io/badge/Platform-Windows%2010%2F11-lightgrey)

---

## What is ContentCapture Pro?

ContentCapture Pro is a Windows productivity tool that lets you:

1. **Capture** any webpage with one hotkey (`Ctrl+Alt+G`)
2. **Store** the URL, title, and your notes in a searchable database
3. **Recall** content instantly by typing a short name you choose
4. **Share** to social media, email, or open the URL—all with simple suffixes

### Example Workflow

```
1. You find an article about electric cars
2. Press Ctrl+Alt+G → Name it "evcars" → Add your notes
3. Later, type "evcarsgo" → Opens that article instantly
4. Or type "evcarsfb" → Shares to Facebook
5. Or type "evcarsem" → Creates an email with the content
```

---

## Quick Start (5 Minutes)

### Step 1: Install AutoHotkey v2

Download from [autohotkey.com](https://www.autohotkey.com/) → Choose **v2.0**

### Step 2: Download ContentCapture Pro

- Click the green **Code** button → **Download ZIP**
- Extract to any folder

### Step 3: Run It

- Double-click `ContentCapture-Pro.ahk`
- Complete the quick setup wizard
- Done!

### Step 4: Capture Your First Page

1. Open any webpage in your browser
2. Press `Ctrl+Alt+G`
3. Enter a short name (like `recipe` or `article`)
4. Click Save

### Step 5: Use Your Capture

Type your name followed by `::` to paste, or add a suffix:

| You Type | What Happens |
|----------|--------------|
| `recipe` | Pastes the full content |
| `recipego` | Opens the URL in browser |
| `recipeem` | Creates an Outlook email |
| `recipefb` | Shares to Facebook |

---

## Features

### Core Features
- **One-Key Capture** (`Ctrl+Alt+G`) - Captures URL, title, and optional notes
- **Instant Recall** - Type short names to paste content or open URLs
- **Searchable Browser** (`Ctrl+Alt+B`) - Find any capture by name, title, or tags
- **Tags & Categories** - Organize captures with customizable tags
- **Personal Notes** - Add opinions and private notes to each capture
- **Quiet Mode** - Toggle notifications on/off via tray menu
- **YouTube Transcript + AI** - Get transcripts and summarize with ChatGPT, Claude, or Ollama (local)

### Sharing Options (Suffixes)

| Suffix | Action |
|--------|--------|
| (none) | Paste full content |
| `?` | Show action menu |
| `go` | Open URL in browser |
| `em` | Email via Outlook |
| `oi` | Insert into open Outlook email at cursor |
| `rd` | Read in popup window |
| `vi` | View/Edit the capture |
| `sh` | Paste short version (title + URL only) |

### Social Media Sharing

| Suffix | Platform | Limit |
|--------|----------|-------|
| `fb` | Facebook | 63,206 chars |
| `x` | Twitter/X | 280 chars |
| `bs` | Bluesky | 300 chars |
| `li` | LinkedIn | 3,000 chars |
| `mt` | Mastodon | 500 chars |

### Research Tools

| Suffix | Tool | Purpose |
|--------|------|---------|
| `yt` | YouTube Transcript | Extract video transcripts |
| `pp` | Perplexity AI | AI-powered research |
| `fc` | Snopes | Fact-check claims |
| `mb` | Media Bias Check | Check source credibility |
| `wb` | Wayback Machine | View archived versions |
| `gs` | Google Scholar | Find academic sources |
| `av` | Archive.today | Save permanent copy |

### Document Attachments

| Suffix | Action |
|--------|--------|
| `d.` | Open attached document |
| `ed` | Email with document attached |

---

## Keyboard Shortcuts

| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+G` | Capture current webpage |
| `Ctrl+Alt+B` | Open Capture Browser |
| `Ctrl+Alt+N` | Create manual capture (no webpage) |
| `Ctrl+Alt+W` | Show Recent Captures widget |
| `Ctrl+Alt+H` | Export captures to HTML |
| `Ctrl+Alt+L` | Reload script |
| `Ctrl+Alt+S` | Open Settings |
| `Ctrl+Alt+M` | Show Main Menu |

---

## Installation

See [INSTALL.md](docs/INSTALL.md) for detailed installation instructions.

**Requirements:**
- Windows 10 or 11
- AutoHotkey v2.0 or later (free)

---

## Documentation

- [Quick Start Guide](docs/QUICK-START.md) - Get running in 5 minutes
- [Installation Guide](docs/INSTALL.md) - Detailed setup instructions
- [User Guide](docs/USER-GUIDE.md) - Complete feature documentation
- [Suffix Reference](docs/SUFFIX-REFERENCE.md) - All suffixes at a glance
- [Troubleshooting](docs/TROUBLESHOOTING.md) - Common issues and fixes

---

## File Structure

```
ContentCapture-Pro/
├── ContentCapture-Pro.ahk       # Main script
├── DynamicSuffixHandler.ahk     # Suffix detection engine
├── ContentCapture_Generated.ahk # Auto-generated hotstrings
├── captures.dat                 # Your captures database
├── config.ini                   # Settings (auto-created)
├── README.md                    # This file
├── LICENSE                      # MIT License
├── CHANGELOG.md                 # Version history
└── docs/                        # Documentation folder
    ├── QUICK-START.md
    ├── INSTALL.md
    ├── USER-GUIDE.md
    ├── SUFFIX-REFERENCE.md
    └── TROUBLESHOOTING.md
```

---

## Contributing

Contributions are welcome! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for guidelines.

---

## Credits

**Author:** Brad Schrunk ([@smogmanus1](https://github.com/smogmanus1))

**Built with:**
- [AutoHotkey v2](https://www.autohotkey.com/) - The automation platform

**Community Support:**
- AutoHotkey Forums
- Joe Glines ([the-Automator.com](https://the-automator.com))
- Jack Dunning (AutoHotkey educator)
- Isaias Baez (RaptorX)

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

## Support

- **Issues:** [GitHub Issues](https://github.com/smogmanus1/ContentCapture-Pro/issues)
- **AutoHotkey Forums:** [autohotkey.com/boards](https://www.autohotkey.com/boards/)

---

**Made with ❤️ for the AutoHotkey community**
