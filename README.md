# ContentCapture Pro v5.8

**Capture any webpage and recall it instantly with hotstrings. Built-in research tools to verify content before sharing.**

![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0+-green)
![Windows](https://img.shields.io/badge/Windows-10%2F11-blue)
![License](https://img.shields.io/badge/License-MIT-yellow)

---

## What is ContentCapture Pro?

ContentCapture Pro transforms how you save, organize, and share web content. Instead of bookmarks you never revisit or scattered notes, capture any webpage with a simple hotkey and recall it instantly by typing a short name.

Think of it as a personal knowledge base that lives at your fingertips — accessible from ANY application with just a few keystrokes.

---

## Key Features

### 🚀 Instant Capture
- Press `Ctrl+Alt+G` on any webpage to capture URL, title, and content
- Highlight text before capturing to save specific excerpts
- Add tags, notes, and your personal opinion/commentary
- Works with Chrome, Firefox, Edge, Brave, and most browsers

### ⚡ Lightning-Fast Recall
- Type `recipe1` anywhere to instantly paste your saved "recipe1" capture
- No app switching, no searching — just type and it appears
- Works in Word, email, social media, chat apps — everywhere you can type

### 🔍 Powerful Search
- **Quick Search** (`Ctrl+Alt+Space`): Alfred/Raycast-style instant popup
- **Full Browser** (`Ctrl+Alt+B`): Search by name, tags, URL, date, or content
- Filter by favorites, date range, or specific tags

### 📱 Smart Social Sharing
- Auto-detects Facebook, Twitter/X, Bluesky, LinkedIn, Mastodon
- Warns when content exceeds platform character limits
- Auto-cleans titles (removes "- YouTube", "| CNN", etc.)

### 🤖 AI Integration (Optional)
- Summarize long articles into key points
- Rewrite content for different platforms
- Supports OpenAI, Anthropic Claude, or local Ollama models
- 100% private with Ollama (runs locally)

### 🔬 Research Tools
- YouTube Transcript extraction
- Perplexity AI research
- Fact Check (Snopes)
- Media Bias Check
- Wayback Machine
- Google Scholar
- Archive.today

### 🔗 Share & Import (NEW in v5.9!)
- **Share captures** with other ContentCapture Pro users
- Export single or multiple captures to clipboard or `.ccp` file
- **Includes everything:** content, research notes, transcripts, summaries, images
- Images embedded as Base64 - fully portable, no separate files needed
- Smart conflict handling when importing (skip, replace, or rename)
- Perfect for sharing verified content with friends and family

---

## Installation

### Requirements
- AutoHotkey v2.0 or higher
- Windows 10 or 11

### Quick Install
1. Download and install [AutoHotkey v2](https://www.autohotkey.com/)
2. Download the latest release from this repository
3. Extract all files to a folder
4. Double-click `ContentCapture.ahk`
5. Press `Ctrl+Alt+G` on any webpage to make your first capture!

---

## Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+G` | Capture current webpage |
| `Ctrl+Alt+N` | New manual capture (no browser needed) |
| `Ctrl+Alt+B` | Open Capture Browser |
| `Ctrl+Alt+Space` | Quick Search |
| `Ctrl+Alt+A` | AI Assist menu |
| `Ctrl+Alt+L` | Reload script |

### Capture Browser Shortcuts
| Shortcut | Action |
|----------|--------|
| `Enter` | Paste selected capture |
| `Delete` | Delete selected capture |
| `Ctrl+F` | Focus search box |
| `Ctrl+D` | Duplicate capture |
| `Ctrl+N` | New capture |
| `Ctrl+L` | Copy link only |
| `Ctrl+P` | Preview capture |
| `Ctrl+S` | Share capture(s) |
| `Ctrl+I` | Import captures |
| `F5` | Refresh list |

---

## Suffix System

Every capture automatically gets these hotstring variants. If your capture is named `recipe1`:

### Basic Actions
| Type This | Action |
|-----------|--------|
| `recipe1` | Paste full content |
| `recipe1?` | Show action menu |
| `recipe1sh` | Paste short version |
| `recipe1go` | Open URL in browser |
| `recipe1vi` | View/Edit capture |
| `recipe1rd` | Read content in popup |
| `recipe1pr` | Print formatted record |
| `recipe1sum` | AI summarize on demand |

### Email
| Type This | Action |
|-----------|--------|
| `recipe1em` | Create new Outlook email |
| `recipe1oi` | Insert into open Outlook email |
| `recipe1ed` | Email with document attached |
| `recipe1d.` | Open attached document |

### Social Media
| Type This | Platform |
|-----------|----------|
| `recipe1fb` | Facebook |
| `recipe1x` | Twitter/X |
| `recipe1bs` | Bluesky |
| `recipe1li` | LinkedIn |
| `recipe1mt` | Mastodon |

### Research Tools
| Type This | Tool |
|-----------|------|
| `recipe1yt` | YouTube Transcript |
| `recipe1pp` | Perplexity AI |
| `recipe1fc` | Fact Check (Snopes) |
| `recipe1mb` | Media Bias Check |
| `recipe1wb` | Wayback Machine |
| `recipe1gs` | Google Scholar |
| `recipe1av` | Archive to Archive.today |

---

## Share & Import

Share your captures with other ContentCapture Pro users! Perfect for sharing verified content with friends, family, or colleagues.

### What Gets Shared
- ✅ Core content (URL, title, body, tags, opinion)
- ✅ Research notes (fact-check results, bias ratings)
- ✅ YouTube transcripts and AI summaries
- ✅ Attached images (embedded as Base64)

### How to Share
1. Open Capture Browser (`Ctrl+Alt+B`)
2. Select one or more captures (`Ctrl+Click` for multiple)
3. Click **🔗 Share** or press `Ctrl+S`
4. Choose:
   - **Copy to Clipboard (Full)** - includes images
   - **Copy to Clipboard (No Images)** - smaller/faster
   - **Save to .ccp File** - for email attachments

### How to Import
1. Open Capture Browser
2. Click **📥 Import** or press `Ctrl+I`
3. Paste JSON or load a `.ccp` file
4. Preview what will be imported
5. Handle any conflicts (skip, replace, or rename)
6. Click **Import All**

### Import Preview Shows
```
✅ Ready    │ opensecr  │ OpenSecrets...  │ 📷 │ 🔬 │ 📝 │
⚠️ Conflict │ projcens  │ Already exists  │    │    │    │

📷 = Has image | 🔬 = Has research | 📝 = Has transcript
```

---

## Capture Browser

The Capture Browser (`Ctrl+Alt+B`) is your home base for managing captures.

### Button Row 1
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
| Close | Close browser |

### Button Row 2 (New in v5.8+)
| Button | Shortcut | Action |
|--------|----------|--------|
| ➕ New | `Ctrl+N` | Create new manual capture |
| 🔗 Link | `Ctrl+L` | Copy URL only |
| 👁 Preview | `Ctrl+P` | Full content preview |
| 🔄 Refresh | `F5` | Reload from disk |
| 🔗 Share | `Ctrl+S` | Share capture(s) with other users |
| 📥 Import | `Ctrl+I` | Import shared captures |

---

## AI Integration

ContentCapture Pro supports three AI providers:

### OpenAI (GPT)
- Requires API key from [platform.openai.com](https://platform.openai.com)
- Cloud-based, pay-per-use

### Anthropic (Claude)
- Requires API key from [console.anthropic.com](https://console.anthropic.com)
- Cloud-based, pay-per-use

### Ollama (Local/Free)
- Download from [ollama.ai](https://ollama.ai)
- Runs 100% locally on your computer
- No API key needed, completely free
- Your content never leaves your machine

### Setup
Press `Ctrl+Alt+A` to open AI Assist and configure your preferred provider.

---

## File Structure

```
ContentCapture-Pro/
├── ContentCapture.ahk          # Main launcher (run this)
├── ContentCapture-Pro.ahk      # Core application
├── DynamicSuffixHandler.ahk    # Suffix system
├── CC_ShareModule.ahk          # Share & Import functionality
├── ResearchTools.ahk           # Research tools
├── ImageCapture.ahk            # Image attachments
├── ImageClipboard.ahk          # Clipboard image handling
├── SocialShare.ahk             # Social media integration
├── ContentCapture_Generated.ahk # Auto-generated hotstrings
├── captures.dat                # Your capture data
├── favorites.dat               # Favorite captures
├── config.ini                  # Settings
├── images/                     # Attached images
└── backups/                    # Automatic backups
```

---

## Troubleshooting

### Hotstrings not working?
- Make sure `ContentCapture_Generated.ahk` was created
- Try reloading: `Ctrl+Alt+L`

### Capture data not saving?
- Check file permissions on the script folder
- Ensure UTF-8 encoding is supported

### Social media not detected?
- The window title must contain the platform name
- Try refreshing the page

---

## Credits

Built with help from **Claude AI** (Anthropic)

Special thanks to the AutoHotkey community:
- **Joe Glines** & The Automator ([the-automator.com](https://www.the-automator.com))
- **Isaias Baez** (RaptorX)
- **Jack Dunning** ([computoredge.com](https://www.computoredge.com/AutoHotkey/))
- **Antonio Bueno** (atnbueno) - Original URL capture concepts

---

## License

MIT License - See [LICENSE](LICENSE) for details.

---

## Feedback

Found a bug? Have a feature request? Open an issue or leave a comment!
