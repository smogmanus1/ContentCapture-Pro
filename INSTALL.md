# Installation Guide

## Requirements

- **Windows 10/11**
- **AutoHotkey v2.0+** - [Download here](https://www.autohotkey.com/)
- **Microsoft Outlook** (optional, for email features)

## Quick Start

1. **Install AutoHotkey v2**
   - Download from https://www.autohotkey.com/
   - Run the installer, select "AutoHotkey v2"

2. **Download ContentCapture Pro**
   - Clone: `git clone https://github.com/smogmanus1/ContentCapture-Pro.git`
   - Or download ZIP and extract

3. **Run the Application**
   - Double-click `ContentCapture.ahk`
   - First run will launch Setup Wizard

4. **Setup Wizard**
   - Choose where to store your captures
   - Recommended: Cloud folder (Dropbox, OneDrive, Google Drive) for sync
   - Or use Documents folder for local-only storage

5. **Start Capturing!**
   - Go to any webpage
   - Press `Ctrl+Alt+G`
   - Enter a short name (e.g., "recipe")
   - Done! Now type `::recipe::` anywhere to paste it

## File Locations

After setup, ContentCapture Pro creates:

```
[Your chosen folder]/
├── captures.dat          # Your capture database
├── images.dat            # Image associations
├── images/               # Attached images
├── config.ini            # Settings
├── archive/              # Deleted captures
└── backups/              # Automatic backups
```

## Auto-Start with Windows

To run ContentCapture Pro at startup:

1. Press `Win+R`, type `shell:startup`, press Enter
2. Create a shortcut to `ContentCapture.ahk` in this folder

Or use the tray menu: Right-click icon → Add to Startup

## Portable Installation

ContentCapture Pro is portable:

1. Copy the entire folder to a USB drive
2. Run `ContentCapture.ahk` from there
3. Choose a data location on the USB drive
4. Take your captures anywhere!

## Troubleshooting

### Script won't start
- Make sure AutoHotkey v2 is installed (not v1)
- Right-click the .ahk file → Open with → AutoHotkey

### Hotstrings don't work
- Check that `ContentCapture_Generated.ahk` exists
- Reload: Right-click tray icon → Reload Script
- Some apps block hotstrings (try Notepad first)

### Capture doesn't grab content
- Make sure the browser window is active
- Some sites block clipboard access
- Try highlighting text before capturing

### Missing images
- Check that the `images` folder exists
- Verify image paths in `images.dat`

## Updating

1. Backup your data folder (captures.dat, images.dat, images/)
2. Download new version
3. Replace all .ahk files
4. Delete `ContentCapture_Generated.ahk` (it will regenerate)
5. Reload the script

Your captures are safe - they're stored separately from the code!

## Uninstalling

1. Exit ContentCapture Pro (right-click tray → Exit)
2. Delete the program folder
3. (Optional) Delete your data folder
4. Remove from Startup if added

---

Need help? Open an issue on [GitHub](https://github.com/smogmanus1/ContentCapture-Pro/issues)
