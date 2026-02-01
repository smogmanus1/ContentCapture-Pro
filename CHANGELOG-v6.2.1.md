# ContentCapture Pro Changelog

All notable changes to ContentCapture Pro will be documented in this file.

---

## [6.2.1] - 2026-02-01

### Added
- **CC_Clipboard.ahk** - New centralized clipboard operations module
  - `CC_ClipPaste()` - Paste with clipboard restore
  - `CC_ClipCopy()` - Copy to clipboard
  - `CC_ClipPasteKeep()` - Paste without restore
  - `CC_ClipNotify()` - User notifications
  - Backward-compatible wrappers for legacy function names

### Fixed
- **Critical: Stale clipboard bug** - Fixed 19 clipboard operations that could paste wrong content
  - All hotstring paste operations (title, url, body, image path)
  - Browser copy operations
  - Share to social media operations
  - Ollama summary copy
  - Research tools copy operations
  - Export to clipboard operations

### Changed
- Refactored clipboard handling architecture for reliability
- All clipboard operations now use centralized CC_Clipboard.ahk module
- Consistent error handling via CC_ClipNotify()

### Removed
- ManualCapture.ahk (legacy file, was not included in #Include chain)
- ManualCaptureImageGUI.ahk (legacy file, was not included in #Include chain)
- Duplicate CC_SafePaste/CC_SafeCopy/CC_SafePasteNoRestore functions (now in CC_Clipboard.ahk)

---

## [6.1.1] - 2026-01-31

### Fixed
- Clipboard handling improvements in CC_SafePaste
- Dynamic paste delays based on content length
- Improved clipboard clearing reliability

### Changed
- Enhanced error messages for clipboard operations

---

## [6.1.0] - 2026-01-28

### Added
- Hover preview tooltips in browser interface
- CC_HoverPreview.ahk module
- Image attachment support for captures
- YouTube transcript extraction with Ollama summarization
- 22 dynamic suffix variants per capture
- Social media sharing (Facebook, Twitter/X, LinkedIn, Bluesky, Mastodon)
- AI integration suffixes (ChatGPT, Claude, Perplexity, Ollama)
- Research tools module
- Share/export module with JSON format

### Changed
- Complete rewrite for AutoHotkey v2
- Modular architecture with separate concerns
- Enhanced browser interface with search and filtering

---

## [6.0.0] - 2026-01-xx

### Added
- Initial AutoHotkey v2 release
- Dynamic suffix system
- Browser interface for managing captures
- Image capture and attachment system
- Backup system with cloud storage detection

---

*For detailed release information, see the RELEASE-x.x.x.md files.*
