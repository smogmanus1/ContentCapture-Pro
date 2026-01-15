# Changelog

All notable changes to ContentCapture Pro.

---

## [5.6] - 2026-01-15

### Added
- **Quiet Mode** - Toggle in tray menu to suppress success notifications
  - Right-click system tray icon → "🔇 Quiet Mode"
  - Errors still show regardless of setting
  - Setting persists between sessions via config.ini
- **YouTube Transcript Workflow** - When capturing YouTube videos:
  - Guidance for using YouTube's built-in transcript feature
  - AI service selection dialog (ChatGPT, Claude, Ollama, Skip)
  - Ollama option runs locally - no API key needed, 100% private
  - Summary or raw transcript saved to Body field

### Changed
- All success notifications now respect Quiet Mode setting
- Startup notification respects Quiet Mode

### Fixed
- Removed duplicate CC_EscapeJSON function

---

## [5.4] - 2026-01-14

### Added
- **Outlook Insert suffix (`oi`)** - Insert captured content directly into open Outlook compose/reply windows at cursor position
- Improved clipboard handling for images - text pasting now works correctly when images are on clipboard

### Fixed
- Clipboard operations with image content no longer interfere with text paste
- `ClipWait` now specifically waits for TEXT format, preventing image conflicts

---

## [5.3] - 2026-01-12

### Fixed
- Installer now correctly installs to local Documents folder (not OneDrive)
- Improved AutoHotkey v2 detection in installer

---

## [5.2] - 2026-01-10

### Fixed
- Clipboard timing issues causing truncated pastes
- Longer delays ensure clipboard properly clears before setting new content

---

## [5.1] - 2026-01-08

### Changed
- **Capture hotkey changed** from `Ctrl+Alt+P` to `Ctrl+Alt+G` to avoid conflicts with common applications

### Updated
- All documentation and help text updated to reflect new hotkey

---

## [5.0] - 2026-01-01

### Added
- **Document attachment system** - Attach files to captures
- `d.` suffix - Open attached document
- `ed` suffix - Email with document attached

### Improved
- Email integration stability
- Social media detection for compose windows

---

## [4.9] - 2025-12-15

### Added
- **Research tools suffixes:**
  - `yt` - YouTube transcript extraction
  - `pp` - Perplexity AI research
  - `fc` - Snopes fact-checking
  - `mb` - Media Bias/Fact Check
  - `wb` - Wayback Machine archives
  - `gs` - Google Scholar search
  - `av` - Archive.today snapshot

---

## [4.8] - 2025-12-10

### Added
- AI integration support (OpenAI, Anthropic, Ollama)
- AI Setup Guide documentation

### Improved
- Configuration system
- Error handling

---

## [4.5] - 2025-12-05

### Added
- **Mastodon support** (`mt` suffix)
- Tag filtering in Capture Browser
- HTML export with search functionality

---

## [4.2] - 2025-12-01

### Added
- Bluesky support (`bs` suffix)
- LinkedIn support (`li` suffix)
- Recent Captures widget (`Ctrl+Alt+W`)

### Improved
- Social media sharing workflow
- URL placement for video thumbnails

---

## [4.0] - 2025-11-25

### Changed
- **Major architecture change:** Dynamic suffix handler
- Hotstrings now handled dynamically instead of generated statically
- Significantly reduced file sizes

### Added
- `?` suffix for action menu
- `vi` suffix for view/edit
- `rd` suffix for read popup

---

## [3.1] - 2025-11-15

### Added
- Migration tool for v2 captures
- Duplicate URL detection
- Automatic URL cleaning (removes tracking parameters)

---

## [3.0] - 2025-11-01

### Changed
- **Data-driven architecture** - captures stored in `captures.dat` instead of generated code
- Each capture now ~10 lines of data instead of ~70 lines of code

### Added
- Tags system
- Searchable Capture Browser
- Opinion/Notes field

---

## [2.x] - Legacy

Original static hotstring generation system. Each capture created multiple hotstring variants in code.

---

## [1.x] - Legacy

Original AutoHotkey v1 versions. See archive for historical code.

---

## Version Numbering

- **Major.Minor** format (e.g., 5.4)
- Major: Significant feature additions or architecture changes
- Minor: Bug fixes, small features, improvements
