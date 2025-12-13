# ContentCapture Pro v4.4

## What Is It?

ContentCapture Pro is a tool that lets you capture web content (URLs, titles, and text) and instantly recall it anywhere by typing a short hotstring. 

**Example:** You find a great article about the 14th Amendment. You capture it as `14thar`. Later, anywhere on your computer, you just type `::14thar::` and the full content pastes automatically.

---

## Features

### Core Features
- **One-click web capture** - Press `Ctrl+Alt+P` on any webpage to capture URL, title, and text
- **Instant recall** - Type `::name::` anywhere to paste your saved content
- **Multiple output formats** - Email, Facebook, X/Twitter, Bluesky, LinkedIn, and more
- **Smart Social Paste** - Automatically uses short version when you're on social media sites

### New in v4.4
- **Restore Browser** (`Ctrl+Alt+Shift+B`) - Search and restore entries from your backup file
- **Edit Before Restore** - Clean up old entries before restoring them
- **Save As New** - Create variations of entries with different names
- **Save Directly to Working File** - Skip the backup, make it ready to use immediately
- **Auto URL Cleanup** - One-click removal of duplicate URLs from body text
- **Short Version Field** - Create Twitter/Bluesky-friendly versions (280 chars)
- **Smart Social Detection** - Automatically pastes short version on social media sites
- **Bulk Delete** - Remove multiple unwanted entries from backup at once
- **Archive System** - Move restored entries to permanent archive

---

## Installation

### Requirements
- Windows 10 or 11
- AutoHotkey v2.0 or later (https://www.autohotkey.com/)

### Quick Install (Run from Source)
1. Download and install AutoHotkey v2 from https://www.autohotkey.com/
2. Download these files to the same folder:
   - `ContentCapture-Pro.ahk` (main script)
   - `DynamicSuffixHandler.ahk` (required helper)
   - `ContentCapture.ahk` (launcher - this is what you run)
3. Double-click `ContentCapture.ahk` to start
4. Complete the setup wizard on first run

### File Structure
```
YourFolder/
├── ContentCapture.ahk           (Launcher - RUN THIS)
├── ContentCapture-Pro.ahk       (Main script)
├── DynamicSuffixHandler.ahk     (Required helper)
├── config.ini                   (Created automatically)
├── captures.dat                 (Your saved content)
├── capturesbackup.dat           (Your backup file)
├── capturesarchive.dat          (Archived entries)
└── ContentCapture_Generated.ahk (Auto-generated hotstrings)
```

---

## Creating an Executable (.exe)

If you want to share ContentCapture Pro or run it without installing AutoHotkey, you can compile it to an .exe file.

### Method 1: Using VS Code (Easiest)

1. Install the **AutoHotkey v2** extension in VS Code
2. Open `ContentCapture.ahk` (the launcher file)
3. Right-click in the editor
4. Select **"Compile Script"** or **"Compile Script (GUI)"**
5. Choose your output location
6. Done! You now have `ContentCapture.exe`

### Method 2: Using Ahk2Exe Directly

1. Find Ahk2Exe in your AutoHotkey installation folder:
   - Usually: `C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe`
2. Run Ahk2Exe
3. Set these options:
   - **Source:** Browse to `ContentCapture.ahk` (the launcher)
   - **Destination:** Where you want the .exe saved
   - **Base File:** Choose the v2 base (usually auto-detected)
4. Click **Convert**

### What Files to Include with the .exe

When distributing, include these files in the SAME FOLDER as the .exe:

```
Distribution Folder/
├── ContentCapture.exe           (The compiled executable)
├── ContentCapture-Pro.ahk       (Main script - REQUIRED)
├── DynamicSuffixHandler.ahk     (Helper - REQUIRED)
└── README.txt                   (Optional - instructions)
```

**Important:** The .exe needs the `.ahk` helper files in the same folder because it uses `#Include` to load them.

### Alternative: Single-File Exe (Advanced)

To create a true single-file executable, you would need to merge all the code into one file before compiling. This is more complex but possible:

1. Copy the contents of `DynamicSuffixHandler.ahk` into `ContentCapture-Pro.ahk`
2. Copy the contents of `ContentCapture-Pro.ahk` into `ContentCapture.ahk`
3. Remove all `#Include` lines
4. Compile the combined `ContentCapture.ahk`

---

## Keyboard Shortcuts

### Main Hotkeys
| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+Space` | Quick Search - fast popup to find and paste |
| `Ctrl+Alt+P` | Capture current webpage |
| `Ctrl+Alt+N` | Manual capture (no browser needed) |
| `Ctrl+Alt+B` | Browse all captures |
| `Ctrl+Alt+Shift+B` | **Restore Browser** - restore from backup |
| `Ctrl+Alt+M` | Show main menu |
| `Ctrl+Alt+A` | AI Assist menu (if configured) |
| `Ctrl+Alt+E` | Email last capture |
| `Ctrl+Alt+K` | Backup captures |
| `Ctrl+Alt+L` | Reload script |
| `Ctrl+Alt+F12` | Show help |

### Hotstring Suffixes
Once you've captured content as `name`, you can use these suffixes:

| Type This | What Happens |
|-----------|--------------|
| `::name::` | Paste full content |
| `::name?::` | Show action menu |
| `::namego::` | Open the URL in browser |
| `::nameem::` | Email via Outlook |
| `::namerd::` | Read in popup window |
| `::namevi::` | View/Edit the capture |
| `::namefb::` | Share to Facebook |
| `::namex::` | Share to X/Twitter |
| `::namebs::` | Share to Bluesky |
| `::nameli::` | Share to LinkedIn |

---

## Using the Restore Browser

The Restore Browser (`Ctrl+Alt+Shift+B`) lets you pull old entries from your backup file.

### Basic Workflow
1. Press `Ctrl+Alt+Shift+B` to open
2. Search for what you need
3. Check the boxes next to entries you want
4. Click **RESTORE**

### Features
- **Search** - Searches name, title, AND body content
- **Hide duplicates** - Shows only entries not in your working file
- **Preview pane** - See content before restoring
- **Edit before restore** - Double-click to edit an entry
- **Delete** - Remove unwanted entries from backup
- **Move to archive** - Checkbox to archive after restoring

### Editing Entries
1. Double-click an entry (or select and click "Edit Selected")
2. Edit any field:
   - **Hotstring Name** - Change to create a new entry
   - **Title** - The title/headline
   - **URL** - The source link
   - **Short version** - For Twitter/Bluesky (280 chars max)
   - **Opinion** - Your take on it
   - **Note** - Private notes (not shared)
   - **Body** - The main content
3. Click **🧹 Clean URLs** to remove duplicate URLs from body
4. Save options:
   - **Save Changes** - Update this entry in backup
   - **Save As New** - Create a copy with new name (change name first!)
   - **Save Directly to Working File** - Ready to use immediately

---

## Smart Social Paste

When you paste on social media sites, ContentCapture Pro automatically uses your short version (if you've created one).

### Supported Sites
- X.com / Twitter
- Bluesky (bsky.app)
- Facebook
- Mastodon (various instances)
- LinkedIn
- Threads
- Reddit
- Truth Social
- Gab
- Tumblr
- And more...

### How It Works
1. Create a capture with a **Short version** (in the edit window)
2. Go to any social media site
3. Type your hotstring `::name::`
4. It automatically pastes the short version instead of the full content
5. You'll see a notification confirming which site was detected

---

## Files Explained

| File | Purpose |
|------|---------|
| `captures.dat` | Your active working file with current hotstrings |
| `capturesbackup.dat` | Backup/archive of all entries (use Restore Browser to access) |
| `capturesarchive.dat` | Permanent archive of restored entries |
| `config.ini` | Your settings and preferences |
| `ContentCapture_Generated.ahk` | Auto-generated hotstrings (don't edit) |

---

## Tips & Tricks

### Organizing Your Content
- Keep `captures.dat` lean with only frequently-used entries
- Use `capturesbackup.dat` as your library/archive
- Pull entries from backup only when you need them

### Creating Good Short Versions
- Keep under 280 characters for Twitter/Bluesky
- Include the key point without the full context
- The URL is added automatically

### Cleaning Up Old Entries
1. Open Restore Browser (`Ctrl+Alt+Shift+B`)
2. Search for entries you don't need
3. Check multiple boxes
4. Click **🗑️ Delete**

### Creating Variations
Have different takes on the same topic:
- `14thar` - Full legal explanation
- `14thar2` - Short punchy version
- `14tharfacts` - Just the facts

---

## Troubleshooting

### Hotstring Not Working
- Make sure you type `::` before AND after the name
- Try reloading the script (`Ctrl+Alt+L`)
- Check if the name exists in your captures

### Script Won't Start
- Make sure AutoHotkey v2 is installed (not v1)
- Check that all required files are in the same folder
- Run as Administrator if needed

### Backup File Not Found
- The backup file must be named `capturesbackup.dat`
- It must be in the same folder as your `captures.dat`

---

## Credits

- **AutoHotkey** - https://www.autohotkey.com/
- **Jack Dunning** - AutoHotkey books and tutorials
- **Joe Glines / The Automator** - https://www.the-automator.com/
- **Claude AI (Anthropic)** - Development assistance

---

## Version History

### v4.4 (December 2025)
- Smart Social Paste - auto-detects social media sites
- Restore Browser with search, edit, delete
- Save As New / Save to Working File options
- URL cleanup button
- Short version field for social media
- Bulk delete from backup

### v4.3
- Restore Browser introduced
- Archive system

### v4.2
- AI Integration
- Quick Search
- Favorites system

---

## License

MIT License - Free to use, modify, and distribute.

---

*Created by Brad with assistance from Claude AI*
