# Changelog

All notable changes to ContentCapture Pro will be documented in this file.

## [4.5] - 2025-12-16

### Added
- **Smart Social Media Character Limits** — Auto-detects platform and warns when over limit
- **Platform-Accurate Character Counting** — URLs count as 23 chars on Twitter/Bluesky
- **Auto-Clean Titles** — Removes "- YouTube", "| CNN", "- The New York Times", etc.
- **Social Edit Window** — Live character counter, edit content before posting
- **Save Short Versions** — Save trimmed content for one-click future sharing
- **YouTube Timestamp Support** — Option to save videos starting at specific time
- **Installation Location Warnings** — Warns if installed in Program Files
- **First-Run Welcome Message** — Guides new users on data backup importance
- **Alphabetical Sorting** — Browser and Quick Search display captures A-Z
- **Comprehensive Code Documentation** — Inline comments explaining all functions

### Fixed
- Bluesky paste button now works correctly (fixed GUI scope issue)
- YouTube title suffix variants now properly cleaned (including em dash patterns)

### Changed
- Titles now cleaned at capture time, not just when pasting
- Enhanced suffix patterns for more title variations

## [4.4] - 2025-12-15

### Added
- **Smart Social Paste** — Detects when you're on social media
- **Restore Browser** — Recover captures from any backup
- **AI Integration** — Support for OpenAI, Anthropic Claude, and Ollama
- **Quick Search** — Alfred/Raycast-style popup search (`Ctrl+Alt+Space`)
- **Favorites System** — Star frequently-used captures

### Changed
- Improved tray menu with favorites section
- Better error handling throughout

## [4.3] - 2025-12-14

### Added
- **Recent Captures Widget** — Desktop overlay showing latest captures
- **Tag Filtering** — Filter by tag in browser
- **Export to HTML** — Export all captures to viewable HTML file

## [4.2] - 2025-12-12

### Added
- **Auto-Backup System** — Configurable automatic backups
- **Manual Backup/Restore** — One-click backup and restore browser
- **Cloud Folder Detection** — Auto-detects Dropbox, OneDrive, Google Drive

### Fixed
- Various AHK v2 syntax improvements
- Better clipboard handling

## [4.1] - 2025-12-10

### Added
- **AI Assist Menu** — Summarize, rewrite, improve content
- **Multiple AI Providers** — OpenAI, Anthropic, Ollama support
- **AI Settings Panel** — Configure API keys and models

## [4.0] - 2025-12-08

### Changed
- **Complete AHK v2 Rewrite** — Modern AutoHotkey v2 syntax throughout
- **New GUI Framework** — Dark-themed, resizable windows
- **Improved Performance** — Faster startup and search

### Added
- **DynamicSuffixHandler** — Handles all suffix variants automatically
- **Setup Wizard** — First-run configuration
- **Better Browser Support** — Chrome, Firefox, Edge, Brave

## [3.x and Earlier]

Legacy versions using AutoHotkey v1 syntax. Not documented here.

---

## Version Numbering

- **Major.Minor** format (e.g., 4.5)
- Major: Significant new features or breaking changes
- Minor: New features, improvements, and bug fixes

## Upgrade Notes

### From 4.x to 4.5
- Just replace the .ahk files
- Your `captures.dat` and `config.ini` are compatible
- Reload script with `Ctrl+Alt+L`

### From 3.x to 4.x
- Requires AutoHotkey v2.0 (not v1.x)
- Data files are compatible
- Review new hotkey shortcuts
