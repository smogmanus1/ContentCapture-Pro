# Installing ContentCapture Pro

## Quick Install (Recommended)

**Double-click `INSTALL.bat`** - that's it!

The installer will:
1. ✅ Check if AutoHotkey v2 is installed (install it if not)
2. ✅ Ask where to install (default: your user folder)
3. ✅ Copy all files
4. ✅ Preserve your existing captures if upgrading
5. ✅ Create a Start Menu shortcut
6. ✅ Launch ContentCapture Pro

---

## Alternative Install Methods

### Method 2: PowerShell Direct
1. Right-click `Install-ContentCapture.ps1`
2. Select **"Run with PowerShell"**

### Method 3: Manual Install
1. Install [AutoHotkey v2](https://www.autohotkey.com/download/) if you haven't
2. Copy all `.ahk` files to a folder of your choice
3. Double-click `ContentCapture.ahk` to run

---

## After Installation

- **Capture content:** Press `Ctrl+Alt+G` on any webpage
- **Recall content:** Type your capture name + space
- **Access the app:** Find "ContentCapture Pro" in your Start Menu

---

## Upgrading from a Previous Version

The installer automatically detects existing installations and preserves:
- Your captures (`captures.dat`)
- Your settings (`config.ini`)
- Your images (`images/` folder)
- Your personal shortcuts (`personal-shortcuts.ahk`)

Just run `INSTALL.bat` again - your data is safe!

---

## Troubleshooting

**"Windows protected your PC" message:**
- Click "More info" → "Run anyway"
- This is normal for unsigned scripts

**PowerShell won't run:**
- Right-click `Install-ContentCapture.ps1`
- Select "Run with PowerShell"

**Still having issues?**
- See `TROUBLESHOOTING.md` for more help
- Open an issue on GitHub

---

## Uninstalling

1. Delete the ContentCapture Pro folder
2. Delete the Start Menu shortcut (optional):
   - `%APPDATA%\Microsoft\Windows\Start Menu\Programs\ContentCapture Pro.lnk`

Your captures are stored in the install folder - back them up first if needed!
