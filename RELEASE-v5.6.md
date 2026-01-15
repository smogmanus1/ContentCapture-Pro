# ContentCapture Pro v5.6 Release Notes

## What's New

### 🔇 Quiet Mode
Tired of notifications? Now you can silence them!

- **Toggle:** Right-click the system tray icon → "🔇 Quiet Mode"
- Checkmark shows when enabled
- Suppresses all success notifications (capture saved, copied, etc.)
- **Errors always show** - you won't miss important issues
- Setting persists between sessions

### 🎬 YouTube Transcript Workflow
Capture YouTube videos with AI-powered summaries!

When you capture a YouTube video (`Ctrl+Alt+G`), ContentCapture Pro now offers to help you get the transcript and summarize it:

1. **Get Transcript** - Step-by-step instructions for YouTube's built-in transcript feature
2. **AI Summary Options** - Choose your preferred AI:
   - **ChatGPT** - Opens chat.openai.com
   - **Claude** - Opens claude.ai
   - **Ollama (Local)** - Summarizes automatically on your computer - no internet needed, 100% private!
   - **Skip AI** - Use raw transcript as-is

The summary (or raw transcript) is saved to your capture's Body field, giving you better content for social media posts.

---

## Why These Features?

**Quiet Mode:** Power users with thousands of captures don't need constant "Capture saved!" notifications. Toggle them off and work in peace.

**YouTube Transcripts + AI:** Writing good social media posts about videos is hard when you can't remember what was said. Now you can grab the transcript and have AI summarize the key points - all within the capture workflow.

---

## Installation

### New Users
1. Download the ZIP
2. Extract to any folder
3. Run `install.bat` (or double-click `ContentCapture-Pro.ahk`)

### Existing Users
1. Replace your `ContentCapture-Pro.ahk` with the new version
2. Reload the script (`Ctrl+Alt+L`)
3. Your captures and settings are preserved

---

## Full Changelog

### Added
- Quiet Mode toggle in system tray menu
- YouTube transcript detection during capture
- AI service selection dialog (ChatGPT, Claude, Ollama, Skip)
- Local Ollama summarization - automatic, private, no API key needed
- `CC_ShowAIChoiceDialog()` - reusable AI picker GUI
- `CC_SummarizeWithOllama()` - local AI summarization function

### Changed
- All success notifications now respect Quiet Mode setting
- YouTube capture flow improved with transcript guidance
- Startup notification respects Quiet Mode

### Fixed
- Duplicate `CC_EscapeJSON` function removed

---

## Documentation

Full documentation included in the `docs/` folder:
- **QUICK-START.md** - Get running in 5 minutes
- **INSTALL.md** - Detailed installation guide
- **USER-GUIDE.md** - Complete feature documentation
- **SUFFIX-REFERENCE.md** - All 25+ suffixes at a glance
- **TROUBLESHOOTING.md** - Common issues and fixes

---

## Requirements

- Windows 10 or 11
- AutoHotkey v2.0+
- Microsoft Outlook (optional, for email features)
- Ollama (optional, for local AI summarization)

---

## Links

- **AutoHotkey v2:** https://www.autohotkey.com/
- **Ollama:** https://ollama.ai/

---

## Credits

- **Author:** Brad Schrunk ([@smogmanus1](https://github.com/smogmanus1))
- **Built with:** AutoHotkey v2, Claude AI assistance
- **Community:** AutoHotkey Forums, Joe Glines (the-Automator.com), Isaias Baez (RaptorX)

---

**Feedback welcome!** Open an issue or use the 👍/👎 buttons to let me know how it's working for you.
