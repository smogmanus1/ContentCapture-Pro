# ContentCapture Pro - Changelog

All notable changes to ContentCapture Pro will be documented in this file.

---

## [6.0.1] - 2026-01-28

### Added
- **ManualCaptureImageGUI.ahk** - GUI controls for image attachment in Manual Capture
  - Browse button with file picker
  - Paste button (supports clipboard bitmap capture via GDI+)
  - Drag-and-drop image support onto GUI
  - Thumbnail preview (150x100, maintains aspect ratio)
  - Multiple image support
  - Integrates with existing ImageDatabase.ahk (`IDB_*` functions)

### Fixed
- **"Control is destroyed" error** - Fixed crash when closing setup wizard while folder picker dialog is open

### Integration
Add one line to your ManualCapture GUI build:
```autohotkey
MCIG.AddToGUI(myGui)
```

And in your Save function:
```autohotkey
imageCount := MCIG.SaveImages(hotstringName)
```

---

## [6.0.0] - 2026-01-24

### Added
- **22 Automatic Suffix Variants** per capture for precise control
- New suffixes: `t` (title only), `url` (URL only), `body` (body only), `cp` (copy without paste)
- **DynamicSuffixHandler.ahk** completely rewritten for v6.0

### Suffix Reference (22 variants)
| Suffix | Action |
|--------|--------|
| (none) | Paste full content |
| `m` | Show in MsgBox |
| `go` | Open URL in browser |
| `em` | Email via Outlook |
| `fb` | Share to Facebook |
| `x` | Share to Twitter/X |
| `bs` | Share to Bluesky |
| `li` | Share to LinkedIn |
| `mt` | Share to Mastodon |
| `rd` | Reddit share |
| `gpt` | Send to ChatGPT |
| `claude` | Send to Claude |
| `ollama` | Send to local Ollama |
| `perp` | Send to Perplexity |
| `sh` | Short version |
| `t` | Title only |
| `url` | URL only |
| `body` | Body only |
| `img` | Copy image path |
| `pic` | Open attached image |
| `imgc` | Copy image to clipboard |
| `cp` | Copy to clipboard (no paste) |

### Fixed
- Removed "1" character appearing before pasted content
- Backspace count now correctly calculated from suffix length
- Map syntax corrected throughout (`capture["key"]` not `capture.key`)

---

## [5.9.1] - 2026-01-21

### Added
- **CC_HoverPreview.ahk** - Hover tooltips in Capture Browser
- **Copy for AI Research** submenu in Research Tools
- Share button icon changed from 🔗 to 📤

### Hover Preview Features
- Shows: Name, Title, URL, Body preview (300 chars), Opinion, Tags
- Status indicators: 📅 date, ⭐ favorite, 📷 image, 🔬 research, 📝 transcript

---

## [5.9.0] - 2026-01-19

### Added
- **CC_ShareModule.ahk** - Export/Import system for sharing captures
- Export captures to `.ccp` files (JSON format)
- Import captures from other users
- Bulk export/import support

---

## [5.8.0] - 2026-01-17

### Added
- **ImageSharing.ahk** - Multi-image social media sharing
- Platform image limits enforced (Facebook: 10, Twitter: 4, etc.)
- `Ctrl+Alt+I` hotkey to cycle through images when sharing
- Email attachments via Outlook COM

### Image Suffixes
| Suffix | Action |
|--------|--------|
| `fbi` | Facebook with image |
| `xi` | Twitter/X with image |
| `bsi` | Bluesky with image |
| `emi` | Email with image attachment |

---

## [5.7.0] - 2026-01-12

### Added
- **ImageDatabase.ahk** - Multiple images per capture support
- `images.dat` file format: `captureName|image1|image2|...`
- **ImageClipboard.ahk** - Fast GDI+ clipboard operations

---

## [5.6.0] - 2026-01-10

### Added
- **ResearchTools.ahk** - AI research integration
- ChatGPT, Claude, Perplexity, Ollama support
- YouTube transcript fetching

---

## File Structure

```
ContentCapture-Pro/
├── ContentCapture.ahk          # Launcher (run this)
├── ContentCapture-Pro.ahk      # Main application
├── DynamicSuffixHandler.ahk    # Suffix processing engine
├── CC_HoverPreview.ahk         # Browser hover tooltips
├── CC_ShareModule.ahk          # Export/Import system
├── ImageCapture.ahk            # Single image attachment
├── ImageClipboard.ahk          # GDI+ clipboard operations
├── ImageDatabase.ahk           # Multi-image management
├── ImageSharing.ahk            # Social sharing with images
├── ManualCaptureImageGUI.ahk   # GUI controls for image attachment
├── ResearchTools.ahk           # AI research integration
├── SocialShare.ahk             # Social platform sharing
├── images/                     # Stored images folder
├── README.md
├── INSTALL.md
├── CHANGELOG.md
└── LICENSE
```

---

## Credits

- **Brad** - Creator and lead developer
- **Joe Glines** (the-Automator.com) - AutoHotkey education
- **Isaias Baez** (RaptorX) - Code contributions
- **Jack Dunning** - AutoHotkey books and tutorials
- **AutoHotkey Community** - Feedback and support

---

## License

MIT License - See LICENSE file
