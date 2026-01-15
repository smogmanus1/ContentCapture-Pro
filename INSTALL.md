# ContentCapture Pro - Installation Guide

Complete installation instructions for all skill levels.

---

## System Requirements

- **Operating System:** Windows 10 or Windows 11
- **AutoHotkey:** Version 2.0 or later (free)
- **Browser:** Chrome, Edge, Firefox, or Brave
- **Disk Space:** Less than 10 MB
- **Email (optional):** Microsoft Outlook (for email features)

---

## Method 1: Automatic Installer (Recommended)

The easiest way to install ContentCapture Pro.

### Step 1: Download the Package

1. Go to the [ContentCapture Pro GitHub page](https://github.com/smogmanus1/ContentCapture-Pro)
2. Click the green **Code** button
3. Click **Download ZIP**
4. Extract the ZIP to a temporary location

### Step 2: Run the Installer

1. Find `install.bat` in the extracted folder
2. **Right-click** → **Run as administrator**
3. Follow the prompts

### What the Installer Does

- Checks if AutoHotkey v2 is installed
- Downloads and installs AutoHotkey v2 if needed
- Creates the ContentCapture Pro folder in your Documents
- Copies all necessary files
- Offers to create a desktop shortcut
- Offers to add to Windows startup

### Installation Location

The installer places files in:
```
C:\Users\YourName\Documents\ContentCapture-Pro\
```

This location is chosen because:
- It's in your local Documents (not OneDrive)
- It survives Windows updates
- It's easy to find and backup

---

## Method 2: Manual Installation

For users who prefer full control.

### Step 1: Install AutoHotkey v2

1. Visit [autohotkey.com](https://www.autohotkey.com/)
2. Click **Download**
3. Select **v2.0** (NOT v1.x)
4. Run the downloaded installer
5. Accept defaults and complete installation

**Verify installation:**
- Open File Explorer
- Navigate to `C:\Program Files\AutoHotkey\`
- You should see `v2\AutoHotkey64.exe`

### Step 2: Download ContentCapture Pro

**Option A: Download ZIP**
1. Go to [github.com/smogmanus1/ContentCapture-Pro](https://github.com/smogmanus1/ContentCapture-Pro)
2. Click green **Code** button → **Download ZIP**
3. Extract to your desired location

**Option B: Git Clone**
```bash
git clone https://github.com/smogmanus1/ContentCapture-Pro.git
```

### Step 3: Choose Your Location

Recommended locations:
- `C:\Users\YourName\Documents\ContentCapture-Pro\`
- `D:\Tools\ContentCapture-Pro\`

**Avoid:**
- OneDrive folders (sync conflicts)
- Program Files (permission issues)
- Desktop (clutter)

### Step 4: Run the Script

1. Double-click `ContentCapture-Pro.ahk`
2. Complete the first-run setup wizard
3. Look for the green "H" icon in your system tray

---

## First-Run Setup

When you first run ContentCapture Pro:

### Setup Wizard

1. **Welcome Screen** - Click "Let's Go!"
2. **Choose Folder** - Select where to store your captures
   - Default: Same folder as the script
   - Recommended: Keep the default
3. **Confirmation** - Review your settings
4. **Done!** - You'll see a system tray icon

### Files Created

After setup, you'll have:
```
ContentCapture-Pro/
├── ContentCapture-Pro.ahk       # Main script
├── DynamicSuffixHandler.ahk     # Suffix engine
├── ContentCapture_Generated.ahk # Your hotstrings (auto-created)
├── captures.dat                 # Your database (auto-created)
├── config.ini                   # Settings (auto-created)
└── backups/                     # Backup folder (auto-created)
```

---

## Auto-Start with Windows (Optional)

### Method 1: During Installation

The installer asks if you want to start with Windows. Say yes!

### Method 2: Manual Setup

1. Press `Win+R`
2. Type `shell:startup` and press Enter
3. The Startup folder opens
4. Create a shortcut to `ContentCapture-Pro.ahk` here

### Method 3: From the Script

1. Right-click the system tray icon
2. Click **Settings**
3. Check **Start with Windows**

---

## Verifying Installation

### Check 1: System Tray Icon

Look for the green "H" icon in your system tray (bottom-right of screen).

### Check 2: Test Capture

1. Open any webpage
2. Press `Ctrl+Alt+G`
3. The capture dialog should appear

### Check 3: Test Hotstring

1. Save a test capture named `test`
2. Open Notepad
3. Type `test` and press Space
4. Your captured content should appear

---

## Troubleshooting Installation

### "AutoHotkey not found"

**Solution:** Install AutoHotkey v2 manually from [autohotkey.com](https://www.autohotkey.com/)

### Script doesn't start

**Check:**
1. Is AutoHotkey v2 installed? (not v1)
2. Right-click the .ahk file → Open with → AutoHotkey
3. Check for error messages in popup

### "Script not running" after double-click

**Solution:**
1. Make sure .ahk files are associated with AutoHotkey v2
2. Right-click → Properties → Opens with: should show AutoHotkey

### Capture hotkey doesn't work

**Check:**
1. Is another program using `Ctrl+Alt+G`?
2. Try running as administrator (right-click → Run as admin)
3. Check if script is running (system tray icon)

### OneDrive conflicts

**Solution:** Install to local Documents, not OneDrive:
```
C:\Users\YourName\Documents\ContentCapture-Pro\
```
NOT:
```
C:\Users\YourName\OneDrive\Documents\ContentCapture-Pro\
```

---

## Updating ContentCapture Pro

### Method 1: Download New Version

1. Download the latest ZIP from GitHub
2. Extract to a temporary folder
3. Copy new `.ahk` files over your existing ones
4. Your `captures.dat` is preserved (your data is safe)
5. Reload the script (`Ctrl+Alt+L`)

### Method 2: Git Pull (if using Git)

```bash
cd ContentCapture-Pro
git pull origin main
```

### What to Keep

- `captures.dat` - Your captures (NEVER delete this!)
- `config.ini` - Your settings
- `ContentCapture_Generated.ahk` - Your hotstrings

### What to Replace

- `ContentCapture-Pro.ahk` - Main script
- `DynamicSuffixHandler.ahk` - Suffix engine
- Any other `.ahk` files from the download

---

## Uninstalling

### Keep Your Data

1. Copy `captures.dat` somewhere safe
2. Delete the ContentCapture-Pro folder
3. Remove from Startup folder if added

### Complete Removal

1. Delete the ContentCapture-Pro folder
2. Remove from Startup folder
3. Optionally uninstall AutoHotkey v2 (Control Panel → Programs)

---

## Getting Help

- **GitHub Issues:** [Report problems](https://github.com/smogmanus1/ContentCapture-Pro/issues)
- **AutoHotkey Forums:** [Community help](https://www.autohotkey.com/boards/)
- **Main Menu:** Press `Ctrl+Alt+M` for built-in help

---

## Next Steps

Installation complete? Head to the [Quick Start Guide](QUICK-START.md) to make your first capture!
