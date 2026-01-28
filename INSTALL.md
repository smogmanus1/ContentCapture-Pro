# Installation Guide

## Requirements

- **Windows 10 or 11**
- **AutoHotkey v2.0+** - [Download here](https://www.autohotkey.com/)
- **Microsoft Outlook** (optional, for email features)

---

## New Installation

### Step 1: Install AutoHotkey v2

1. Go to [autohotkey.com](https://www.autohotkey.com/)
2. Download **AutoHotkey v2.0** (not v1.1)
3. Run the installer and follow the prompts

### Step 2: Download ContentCapture Pro

1. Download the latest release ZIP file
2. Extract to a location of your choice, for example:
   - `C:\ContentCapture-Pro\`
   - `D:\Tools\ContentCapture-Pro\`

### Step 3: Run ContentCapture Pro

1. Double-click `ContentCapture.ahk`
2. Look for the green "H" icon in your system tray
3. You're ready to capture!

### Step 4: (Optional) Start Automatically

To run ContentCapture Pro when Windows starts:

1. Press `Win+R` and type `shell:startup`
2. Create a shortcut to `ContentCapture.ahk` in this folder

---

## Upgrading from Previous Version

### Backup First!
Your data files are safe during upgrade, but it's good practice to backup:
- `captures.dat` - Your captures
- `capturesbackup.dat` - Automatic backup
- `images/` folder - Your attached images

### Upgrade Steps

1. **Close** ContentCapture Pro (right-click tray icon → Exit)
2. **Backup** your data files (see above)
3. **Replace** these files with the new versions:
   - `ContentCapture-Pro.ahk`
   - `DynamicSuffixHandler.ahk`
   - `ImageSharing.ahk`
   - All other `.ahk` files
4. **Keep** your data files:
   - `captures.dat`
   - `capturesbackup.dat`
   - `capturesarchive.dat`
   - `images.dat`
   - `images/` folder
   - `ContentCapture_Generated.ahk` (will be regenerated)
5. **Run** `ContentCapture.ahk`
6. The script will regenerate hotstrings automatically

---

## File Locations

All files should be in the same folder:

```
ContentCapture-Pro/
├── ContentCapture.ahk          ← Run this file
├── ContentCapture-Pro.ahk
├── DynamicSuffixHandler.ahk
├── SocialShare.ahk
├── ResearchTools.ahk
├── ImageCapture.ahk
├── ImageClipboard.ahk
├── ImageDatabase.ahk
├── ImageSharing.ahk
├── CC_HoverPreview.ahk
├── CC_ShareModule.ahk
├── ManualCaptureImageGUI.ahk   ← NEW in v6.0.1
├── captures.dat                ← Created automatically
├── capturesbackup.dat          ← Created automatically
├── ContentCapture_Generated.ahk ← Created automatically
└── images/                     ← Created automatically
```

---

## Verifying Installation

1. **Check tray icon**: You should see a green "H" icon
2. **Test capture**: 
   - Open a webpage in your browser
   - Press `Ctrl+Alt+G`
   - You should see the capture dialog
3. **Test hotstring**:
   - After saving a capture named "test"
   - Type `test` followed by space
   - Content should be pasted

---

## Troubleshooting

### "Script not running"
- Make sure AutoHotkey v2 is installed
- Right-click `ContentCapture.ahk` → Run as administrator

### "Hotstrings not working"
- Press `Ctrl+Alt+L` to reload the script
- Check that `ContentCapture_Generated.ahk` exists

### "Capture dialog doesn't appear"
- Make sure you're in a browser window
- Try pressing `Ctrl+Alt+G` again
- Check if another AHK script is blocking the hotkey

### "Outlook features not working"
- Make sure Outlook is installed and configured
- Run Outlook at least once before using email features

---

## Getting Help

- **GitHub Issues**: [Report bugs](https://github.com/smogmanus1/ContentCapture-Pro/issues)
- **AutoHotkey Forums**: [Community support](https://www.autohotkey.com/boards/)

---

## Uninstallation

1. Right-click tray icon → Exit
2. Delete the ContentCapture-Pro folder
3. (Optional) Remove from Startup folder if added
