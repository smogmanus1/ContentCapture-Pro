# Changelog

All notable changes to ContentCapture Pro are documented here.

## [6.0.0] - 2026-01-24

### Added
- **New `t` suffix** - Paste title only (`::recipet::`)
- **New `url` suffix** - Paste URL only (`::recipeurl::`)
- **New `body` suffix** - Paste body content only (`::recipebody::`)
- **New `cp` suffix** - Copy to clipboard without pasting (`::recipecp::`)
- **New `i` suffix** - Paste image PATH as text (`::recipei::`) - perfect for file dialogs
- **New `ti` suffix** - Paste title then image path on next line (`::recipeti::`)
- Updated action menu (`::name?::`) with all new options
- Hotstring generator now creates 22 suffixes per capture

### Fixed
- Fixed "1" character appearing before pasted content (backspace count bug)
- Added `#Warn VarUnset, Off` to suppress false warnings about globals

## [5.9.2] - 2026-01-19

### Fixed
- Image sharing workflow improvements
- Social media platform URL handling

## [5.8.0] - 2026-01-19

### Added
- **Capture Browser enhancements**:
  - New (Ctrl+N) - Create capture without leaving browser
  - Link (Ctrl+L) - Copy just the URL
  - Preview (Ctrl+P) - Show full content in popup
  - Refresh (F5) - Reload capture list
- Browser window height increased for new buttons

## [5.7.0] - 2026-01-15

### Added
- **"Capture First, Process Later" workflow**
- Captures NEVER fail due to Ollama being down
- New `sum` suffix for on-demand AI summarization
- Type `::capturenamesum::` to summarize when YOU want

### Changed
- Removed AI choice dialog from YouTube capture flow
- Ollama errors no longer block captures

## [5.6.0] - 2026-01-10

### Added
- "Quiet Mode" toggle in tray menu
- Suppresses success notifications when enabled
- YouTube transcript workflow:
  - Option to send to ChatGPT, Claude, or Ollama
  - Ollama runs locally - 100% private
  - Summary saved to Body field

## [5.5.0] - 2026-01-05

### Added
- Multi-image support per capture
- Image database system (images.dat)
- Social media image sharing suffixes (fbi, xi, bsi, lii, mti)

## [5.4.0] - 2025-12-20

### Added
- `oi` suffix for Outlook Insert at cursor
- Works in replies and compose windows

## [5.3.0] - 2025-12-15

### Fixed
- Paste truncation for large content (5000+ chars)
- CC_SafePaste now scales delay based on content length

## [5.2.0] - 2025-12-10

### Fixed
- Clipboard reliability issues
- Added CC_SafePaste, CC_SafeCopy helper functions

## [5.1.0] - 2025-12-01

### Added
- Document attachment system
- `d.` suffix to open attached documents
- `ed` suffix to email with document attached

## [5.0.0] - 2025-11-15

### Added
- Complete rewrite in AutoHotkey v2
- Dynamic suffix handler system
- Social media character counting
- Capture Browser with search and filters
- Quick Search popup (Ctrl+Alt+Space)
- Tag system for organization
- Favorites marking
- Import/Export captures (.ccp format)
- Hover preview in browser

### Changed
- Modern GUI design
- Improved performance
- Better clipboard handling
