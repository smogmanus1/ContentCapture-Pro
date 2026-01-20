# ContentCapture Pro - Changelog

All notable changes to ContentCapture Pro are documented here.

---

## [5.9] - 2026-01-19

### Added
- **🔗 Share & Import System** - Share captures with other ContentCapture Pro users!
  - Export single or multiple captures to clipboard or `.ccp` file
  - Includes ALL data: content, research notes, transcripts, summaries, images
  - Images embedded as Base64 - fully portable, no separate files needed
  - Smart import preview shows what's included (📷 image, 🔬 research, 📝 transcript)
  - Conflict handling: skip, replace, or rename duplicates
  - Images auto-restore to recipient's `images/` folder
- **New Capture Browser buttons:**
  - 🔗 **Share** (`Ctrl+S`) - Share selected capture(s)
  - 📥 **Import** (`Ctrl+I`) - Import shared captures
- **New file:** `CC_ShareModule.ahk` - Share/Import functionality
- Keyboard shortcuts: `Ctrl+S` for Share, `Ctrl+I` for Import

### Changed
- Status bar now shows Share/Import shortcuts
- Updated README with Share & Import documentation

---

## [5.8] - 2026-01-19

### Added
- **4 new Capture Browser buttons:**
  - ➕ **New** (`Ctrl+N`) - Create new manual capture without leaving browser
  - 🔗 **Link** (`Ctrl+L`) - Copy just the URL to clipboard
  - 👁 **Preview** (`Ctrl+P`) - View full capture details in popup window
  - 🔄 **Refresh** (`F5`) - Reload captures from disk
- Preview window with dark theme and action buttons (Close, Copy All, Copy URL, Open URL)
- Keyboard shortcuts for all new browser buttons
- Status bar now shows F5=Refresh hint

### Changed
- Browser window height increased from 470 to 510 pixels
- Buttons now arranged in two rows for better organization

---

## [5.7] - 2026-01-15

### Added
- **"Capture First, Process Later" workflow**
  - Captures never fail due to Ollama/AI being unavailable
  - AI processing is now optional and on-demand
- **`sum` suffix** for on-demand AI summarization
  - Type `capturenamesum` to summarize any capture when YOU want
- Removed AI choice dialog from YouTube capture flow

### Fixed
- Ollama errors no longer block captures

---

## [5.6] - 2026-01-10

### Added
- **Quiet Mode** toggle in tray menu (right-click system tray icon)
  - Suppresses success notifications when enabled
  - Errors still show for troubleshooting
  - Setting persists between sessions
- **YouTube transcript workflow** during capture:
  - Shows how to get transcript from YouTube's built-in feature
  - Option to send transcript to ChatGPT, Claude, or Ollama for summarization
  - Ollama runs locally - no API key needed, 100% private
  - Summary or raw transcript saved to Body field

---

## [5.4] - 2026-01-05

### Added
- **`oi` suffix** for Outlook Insert at cursor
  - `nameoi` inserts content into OPEN Outlook email at cursor position
  - Works in replies and compose windows
  - Different from `em` which creates NEW email

---

## [5.3] - 2026-01-02

### Fixed
- **Paste truncation for large content** (5000+ chars)
  - CC_SafePaste now scales delay based on content length
  - Prevents clipboard restore from interrupting long pastes

---

## [5.2] - 2025-12-28

### Fixed
- **Clipboard reliability issues**
  - Clear clipboard before setting new content
  - Proper timeout handling

### Added
- `CC_SafePaste` helper function
- `CC_SafeCopy` helper function
- All paste operations now use safe clipboard handling

---

## [5.1] - 2025-12-20

### Added
- Image attachment support (`📷 Img` button)
- Image indicator column in Capture Browser (`📷`)

### Changed
- ListView columns reorganized for better visibility

---

## [5.0] - 2025-12-15

### Added
- **Research Tools integration**
  - YouTube Transcript (`yt`)
  - Perplexity AI (`pp`)
  - Fact Check via Snopes (`fc`)
  - Media Bias Check (`mb`)
  - Wayback Machine (`wb`)
  - Google Scholar (`gs`)
  - Archive.today (`av`)
- Research button in Capture Browser
- Research Notes field for captures

### Changed
- Major code refactoring for AHK v2 compatibility
- Improved GUI layouts with dark theme option

---

## [4.9.1] - 2025-12-01 (Initial Public Release)

### Added
- **Short Version suffix** (`sh`)
  - Type `namesh` to paste just your short version
  - Perfect for comments and quick shares
- Auto-reload after save - no more manual reloads needed
- Auto-reopen Capture Browser after save
- Larger Short Version field for easier editing

### Fixed
- Multi-line Short Version now saves correctly
- Double paste bug fixed
- Research Notes now persist properly

---

## [4.9] - 2025-11-25

### Added
- Initial Capture Browser with ListView
- Tag system for organization
- Favorites system with tray menu access
- Social media sharing suffixes (fb, x, bs, li, mt)
- Platform character limit warnings
- Auto-clean titles (removes "- YouTube", "| CNN", etc.)

---

## [4.5] - 2025-11-15

### Added
- AI Integration framework
  - OpenAI (GPT) support
  - Anthropic (Claude) support
  - Ollama (local) support
- AI Assist menu (`Ctrl+Alt+A`)
- Summarize, rewrite, and improve content

---

## [4.0] - 2025-11-01

### Added
- Quick Search popup (`Ctrl+Alt+Space`)
- Fuzzy search matching
- Email integration with Outlook
- Document attachment support

### Changed
- Complete rewrite for AutoHotkey v2

---

## [3.0] - 2025-10-15

### Added
- Manual capture mode (`Ctrl+Alt+N`)
- Edit capture functionality
- Delete with confirmation
- Backup and restore system

---

## [2.0] - 2025-10-01

### Added
- Multiple browser support (Chrome, Firefox, Edge, Brave)
- Selected text capture
- Tags and notes fields
- Basic suffix system (go, em, vi)

---

## [1.0] - 2025-09-15

### Added
- Initial release
- Basic webpage capture (`Ctrl+Alt+G`)
- URL and title extraction
- Simple hotstring paste

---

## Version Summary

| Version | Date | Major Features |
|---------|------|----------------|
| 5.9 | 2026-01-19 | Share & Import system with images |
| 5.8 | 2026-01-19 | 4 new browser buttons, Preview window |
| 5.7 | 2026-01-15 | Capture First Process Later, sum suffix |
| 5.6 | 2026-01-10 | Quiet Mode, YouTube transcript workflow |
| 5.4 | 2026-01-05 | Outlook Insert (oi suffix) |
| 5.3 | 2026-01-02 | Large content paste fix |
| 5.2 | 2025-12-28 | Safe clipboard functions |
| 5.1 | 2025-12-20 | Image attachments |
| 5.0 | 2025-12-15 | Research Tools |
| 4.9.1 | 2025-12-01 | Initial public release |

**Total: 10 updates since initial release!**
