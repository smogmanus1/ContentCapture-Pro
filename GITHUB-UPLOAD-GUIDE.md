# Git Commit Message

## Short version (for commit):
```
v5.6: Add Quiet Mode and YouTube transcript AI workflow
```

## Full commit message:
```
v5.6: Add Quiet Mode and YouTube transcript AI workflow

Features:
- Quiet Mode toggle in tray menu - suppress success notifications
- YouTube transcript workflow during video capture
- AI summary options: ChatGPT, Claude, Ollama (local), or skip
- Local Ollama summarization - no API key, 100% private

Changes:
- All success notifications respect Quiet Mode
- Improved YouTube capture flow with transcript guidance

Fix:
- Remove duplicate CC_EscapeJSON function
```

---

# Steps to Upload to GitHub

1. **Open GitHub Desktop** or terminal

2. **Copy updated files to your repo folder:**
   - `ContentCapture-Pro.ahk` (main script)
   - `README.md` (updated)
   - `CHANGELOG.md` (updated)
   - `docs/` folder (documentation)

3. **In GitHub Desktop:**
   - You'll see the changed files listed
   - Enter commit message: `v5.6: Add Quiet Mode and YouTube transcript AI workflow`
   - Click "Commit to main"
   - Click "Push origin"

4. **Create a Release (optional but recommended):**
   - Go to your repo on github.com
   - Click "Releases" → "Create a new release"
   - Tag: `v5.6`
   - Title: `ContentCapture Pro v5.6 - Quiet Mode & AI Transcripts`
   - Paste the RELEASE-v5.6.md content in the description
   - Upload the ZIP file
   - Check "Set as the latest release"
   - Click "Publish release"

---

# Make Repository Public (if still private)

1. Go to https://github.com/smogmanus1/ContentCapture-Pro
2. Click **Settings** (gear icon)
3. Scroll to **Danger Zone**
4. Click **Change visibility** → **Public**
5. Confirm by typing repo name

Now anyone can download and test!
