# ContentCapture Pro - Quick Start Guide

## First Time Setup

1. **Install AutoHotkey v2** from https://www.autohotkey.com/
2. **Put these files in one folder:**
   - ContentCapture.ahk (run this one)
   - ContentCapture-Pro.ahk
   - DynamicSuffixHandler.ahk
3. **Double-click ContentCapture.ahk**
4. **Follow the setup wizard**

That's it! You're ready to capture.

---

## The 5 Hotkeys You Need to Know

| Press This | What It Does |
|------------|--------------|
| `Ctrl+Alt+P` | **Capture** the current webpage |
| `Ctrl+Alt+B` | **Browse** all your captures |
| `Ctrl+Alt+Shift+B` | **Restore** from backup file |
| `Ctrl+Alt+Space` | **Quick Search** popup |
| `Ctrl+Alt+M` | **Menu** of all commands |

---

## How to Capture a Webpage

1. Go to a webpage you want to save
2. Press `Ctrl+Alt+P`
3. Enter a short name (like `14thar` or `recipe1`)
4. Add your opinion (optional)
5. Click OK
6. Done! Now type `::14thar::` anywhere to paste it

---

## How to Use Your Captures

Type `::name::` followed by Enter or Space:

- `::14thar::` → Pastes the full content
- `::14thar?::` → Shows a menu of options
- `::14thargo::` → Opens the URL
- `::14tharem::` → Sends via email

---

## The Restore Browser (New!)

Press `Ctrl+Alt+Shift+B` to:

- Search your backup file
- Edit old entries before restoring
- Delete entries you don't need
- Create new variations of old content
- Save directly to your working file

---

## Creating an .exe File

### What You Need
- VS Code with AutoHotkey v2 extension (easiest method)

### Steps
1. Open `ContentCapture.ahk` in VS Code
2. Right-click → **Compile Script**
3. Save the .exe wherever you want

### Files to Include with the .exe
```
YourFolder/
├── ContentCapture.exe        ← The compiled file
├── ContentCapture-Pro.ahk    ← REQUIRED
├── DynamicSuffixHandler.ahk  ← REQUIRED
```

The .exe needs those two .ahk files in the same folder to work!

---

## File Cheat Sheet

| File | What It Is |
|------|------------|
| `captures.dat` | Your active hotstrings |
| `capturesbackup.dat` | Your backup/archive |
| `capturesarchive.dat` | Permanently archived |
| `config.ini` | Your settings |

---

## Pro Tips

1. **Keep captures.dat small** - Only keep what you use regularly
2. **Use the backup as your library** - Pull entries when you need them
3. **Create short versions** - For Twitter/Bluesky (auto-detected!)
4. **Use "Save As New"** - To create variations of the same content

---

## Need Help?

- Press `Ctrl+Alt+F12` for help popup
- Press `Ctrl+Alt+M` for the main menu
- Check the full README for details
