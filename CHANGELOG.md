# Changelog

All notable changes to ContentCapture Pro will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/).

---

## [4.2] - 2025-12-10

### Added
- **YouTube URL Cleanup** - Automatically strips timestamp parameters (`t=`, `start=`, `time_continue=`) so shared videos start from the beginning
- Portable installation - No hardcoded paths, works from any folder
- GitHub-ready distribution with LICENSE, .gitignore, CHANGELOG

### Fixed
- Tag checkbox syntax error in capture dialog (AHK v2 compatibility)
- URL cleanup now properly handles YouTube-specific parameters

### Changed
- `CC_CleanURL()` now intelligently detects YouTube URLs and removes time parameters while preserving other important params (playlist IDs, video IDs)

---

## [4.1] - 2025-12-08

### Added
- **AI Integration** - Support for OpenAI, Anthropic (Claude), and local Ollama
- AI actions: Summarize, Generate Title, Rewrite, Improve, Custom Prompt
- **Quick Search** - Alfred/Raycast-style popup with `Ctrl+Alt+Space`
- **Favorites System** - Star captures for quick access from tray menu
- First-run tutorial for new users
- Contextual tips system

### Changed
- Improved tray menu organization
- Enhanced GUI styling throughout

---

## [4.0] - 2025-12-01

### Added
- **Dynamic Suffix Handler** - Reduced generated hotstrings file from ~2MB to ~200KB
- Social media sharing: Facebook, Twitter/X, Bluesky, LinkedIn, Mastodon
- Character limit detection with edit windows for social platforms
- Multi-select deletion in Capture Browser
- HTML export with search functionality

### Changed
- Complete rewrite for AutoHotkey v2
- Data-driven architecture with INI-style storage
- Modular code organization

---

## [3.0] - 2025-11-15

### Added
- Capture Browser GUI with search and filtering
- Tag system for organizing captures
- Opinion field (included in output) vs Note field (private)
- Duplicate URL detection
- Cloud folder auto-detection (Dropbox, OneDrive, Google Drive)
- Automatic backup system

### Changed
- Migrated from flat file to structured data format
- Improved URL cleaning (tracking parameters removed)

---

## [2.0] - 2025-10-01

### Added
- Manual capture mode (`Ctrl+Alt+N`)
- Email integration via Outlook
- Action menu with `?` suffix
- Read window for viewing captures

### Changed
- Restructured hotstring generation
- Better title extraction from browser windows

---

## [1.0] - 2025-09-01

### Added
- Initial release
- Basic webpage capture with `Ctrl+Alt+P`
- Hotstring generation for instant recall
- URL and title capture from browsers
- Body text selection support

---

## Legend

- **Added** - New features
- **Changed** - Changes to existing functionality
- **Fixed** - Bug fixes
- **Removed** - Removed features
- **Security** - Security improvements
