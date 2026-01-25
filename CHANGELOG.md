# Changelog

All notable changes to ContentCapture Pro are documented here.

---

## [6.0.0] - 2026-01-25

### Added
- **Complete 22-suffix system** - Each capture now generates 22 automatic hotstring variants:
  - Core: (none), `t`, `url`, `body`, `cp`, `sh`
  - View: `rd`, `vi`, `go`
  - Email: `em`, `oi`, `ed`, `emi`
  - Social: `fb`, `x`, `bs`, `li`, `mt`
  - Image: `i`, `img`, `imgo`, `ti`
  - Social+Image: `fbi`, `xi`, `bsi`, `lii`, `mti`
- **Import from ANY .dat file** - Import captures from backups, archives, or exports
  - Click "📥 Import" button in Capture Browser or press `Ctrl+I`
  - Browse and select any .dat file
  - Preview entries before importing
  - Filter by search text or hide duplicates
- **"📅 Update date to today" checkbox** - In Import and Restore browsers
  - Checked by default - imported/restored captures get today's date
  - Makes them sort to top when sorted by date
  - Uncheck to preserve original capture dates
- New handler functions: `CC_HotstringTitle`, `CC_HotstringURL`, `CC_HotstringBody`, `CC_HotstringImagePath`, `CC_HotstringTitleImage`, `CC_HotstringCopyOnly`

### Fixed
- **Backspace count in DynamicSuffixHandler** - Added +1 for trigger character to prevent leftover characters
- **ImageSharing.ahk EncodeURIComponent** - Corrected to `IS_EncodeURIComponent` (was causing errors with Twitter image sharing)

---

## [5.9] - 2026-01-24

### Added
- Restore browser with overwrite option for duplicates
- Detailed restore messages showing new vs overwritten counts

---

## [5.8] - 2026-01-19

### Added
- 4 new buttons in Capture Browser:
  - New (`Ctrl+N`) - Create manual capture without leaving browser
  - Link (`Ctrl+L`) - Copy just the URL to clipboard
  - Preview (`Ctrl+P`) - Show full capture content in popup
  - Refresh (`F5`) - Reload capture list from disk
- Browser window height increased for new button row
- Keyboard shortcuts for all new buttons

---

## [5.7] - 2026-01-15

### Added
- "Capture First, Process Later" workflow
- `sum` suffix for on-demand summarization
- Ollama errors no longer block captures

### Changed
- Removed AI choice dialog from YouTube capture flow

---

## [5.6] - 2026-01-10

### Added
- "Quiet Mode" toggle in tray menu
- YouTube transcript workflow during capture
- Ollama local AI integration (no API key needed)

---

## [5.5] - 2026-01-05

### Added
- `oi` suffix for Outlook Insert at cursor
- Works in replies and compose windows

---

## [5.4] - 2026-01-02

### Fixed
- Paste truncation for large content (5000+ chars)
- CC_SafePaste now scales delay based on content length

---

## [5.3] - 2025-12-28

### Fixed
- Clipboard reliability issues
- Proper timeout handling

### Added
- `CC_SafePaste` helper function
- `CC_SafeCopy` helper function

---

## [5.2] - 2025-12-20

### Added
- Image attachment support (`📷 Img` button)
- Image indicator column in Capture Browser

---

## [5.1] - 2025-12-15

### Added
- Research Tools integration
  - YouTube Transcript (`yt`)
  - Perplexity AI (`pp`)
  - Fact Check (`fc`)
  - Media Bias (`mb`)
  - Wayback Machine (`wb`)
  - Google Scholar (`gs`)
  - Archive Page (`av`)
- Research button in Capture Browser
- Research Notes field for captures

---

## [5.0] - 2025-12-01

### Added
- Short Version suffix (`sh`)
- Auto-reload after save
- Auto-reopen Capture Browser after save
- Larger Short Version field

### Fixed
- Multi-line Short Version now saves correctly
- Double paste bug
- Research Notes persistence

---

## [4.9] - 2025-11-25

### Added
- Initial Capture Browser with ListView
- Tag system for organization
- Favorites system with tray menu
- Social media sharing suffixes (`fb`, `x`, `bs`, `li`, `mt`)
- Platform character limit warnings
- Auto-clean titles

---

## Credits

**Created by:** Brad  
**With assistance from:** Claude AI  
**Special thanks to:** Joe Glines, Isaias Baez, Jack Dunning, and the AutoHotkey community
