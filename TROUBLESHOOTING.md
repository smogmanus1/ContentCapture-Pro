# ContentCapture Pro - Troubleshooting Guide

Solutions to common issues and problems.

---

## Quick Fixes

Before diving into specific issues, try these:

1. **Reload the script:** Press `Ctrl+Alt+L`
2. **Check system tray:** Is the green "H" icon visible?
3. **Run as administrator:** Right-click → Run as administrator
4. **Restart script:** Right-click tray icon → Exit, then relaunch

---

## Installation Issues

### "AutoHotkey not found"

**Problem:** Installer can't find AutoHotkey

**Solutions:**
1. Install AutoHotkey v2 manually from [autohotkey.com](https://www.autohotkey.com/)
2. Make sure you install v2, not v1
3. Restart the installer after installing AutoHotkey

### Script won't start / Double-click does nothing

**Problem:** Nothing happens when you double-click the .ahk file

**Solutions:**
1. Check file association:
   - Right-click `.ahk` file → Open with → Choose another app
   - Select AutoHotkey (should show v2 path)
   - Check "Always use this app"

2. Try running directly:
   - Open Command Prompt
   - Navigate to script folder
   - Run: `"C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe" ContentCapture-Pro.ahk`

3. Check for errors:
   - If there's a syntax error, a popup will appear
   - Screenshot the error and report it

### "Wrong AutoHotkey version" error

**Problem:** Script requires v2 but v1 is installed

**Solutions:**
1. Install AutoHotkey v2 from [autohotkey.com](https://www.autohotkey.com/)
2. You can have both v1 and v2 installed
3. Associate .ahk files with v2:
   - Right-click any .ahk file
   - Open with → Choose another app
   - Browse to `C:\Program Files\AutoHotkey\v2\AutoHotkey64.exe`

---

## Capture Issues

### Ctrl+Alt+G doesn't work

**Problem:** Pressing the capture hotkey does nothing

**Solutions:**
1. **Check if script is running:**
   - Look for green "H" icon in system tray
   - If not there, double-click `ContentCapture-Pro.ahk`

2. **Hotkey conflict:**
   - Another program may be using Ctrl+Alt+G
   - Try closing other apps one by one
   - Or change the hotkey in settings

3. **Run as administrator:**
   - Some apps need admin rights to receive hotkeys
   - Right-click script → Run as administrator

4. **Browser focus:**
   - Make sure browser window is active
   - Click in the browser before pressing hotkey

### URL not captured correctly

**Problem:** Wrong URL or blank URL in capture

**Solutions:**
1. **Wait for page to load:**
   - Let the page fully load before capturing
   
2. **Check browser compatibility:**
   - Supported: Chrome, Edge, Firefox, Brave
   - Try a different browser
   
3. **Special pages:**
   - Some pages (like PDFs, local files) may not capture correctly
   - Use manual capture (Ctrl+Alt+N) for these

### Title is wrong or contains extra text

**Problem:** Title includes browser name or other unwanted text

**Solutions:**
1. ContentCapture Pro automatically removes browser names
2. If still wrong, edit the capture afterward
3. Report consistent issues on GitHub

---

## Hotstring Issues

### Hotstring doesn't trigger

**Problem:** Typing capture name does nothing

**Solutions:**
1. **Check spelling:**
   - Names are case-insensitive but must be exact
   - `Recipe` = `recipe` but `recip` ≠ `recipe`

2. **Need a trigger:**
   - Type the name, then press Space, Tab, Enter, or punctuation
   - `recipe` + Space = triggers
   - `recipe` alone = nothing

3. **Verify capture exists:**
   - Open browser (Ctrl+Alt+B)
   - Search for your capture name
   - If not there, re-capture

4. **Reload script:**
   - Press Ctrl+Alt+L to reload
   - New captures need a reload to activate

### Wrong content pastes

**Problem:** Different content than expected

**Solutions:**
1. **Duplicate names:**
   - Check browser for captures with same name
   - Rename or delete duplicates

2. **Edited but not saved:**
   - Make sure you clicked Save after editing

3. **Old generated file:**
   - Delete `ContentCapture_Generated.ahk`
   - Reload script (Ctrl+Alt+L)
   - File regenerates from database

### Hotstrings work in some apps but not others

**Problem:** Works in Notepad but not in specific app

**Solutions:**
1. **Admin apps:**
   - Some apps run as administrator
   - Run ContentCapture Pro as admin to match

2. **Special input fields:**
   - Some apps use non-standard text fields
   - Try copying (c suffix) and pasting manually

---

## Suffix Issues

### Suffix not recognized

**Problem:** `recipefb` doesn't share to Facebook

**Solutions:**
1. **Check spelling:**
   - No space between name and suffix
   - `recipefb` not `recipe fb`

2. **Verify suffix exists:**
   - Type `recipe?` to see available suffixes
   - Check [SUFFIX-REFERENCE.md](SUFFIX-REFERENCE.md)

3. **Check capture has URL:**
   - Some suffixes (like `go`) need a URL
   - Edit capture to add URL if missing

### Social share opens wrong platform

**Problem:** Typing `recipex` opens wrong site

**Solutions:**
1. **Verify suffix:**
   - `x` = Twitter/X
   - `fb` = Facebook
   - See [SUFFIX-REFERENCE.md](SUFFIX-REFERENCE.md)

2. **Check for name collision:**
   - If you have a capture named `recipex`, it conflicts
   - Rename that capture

---

## Email Issues

### em suffix doesn't work

**Problem:** `recipeem` doesn't create email

**Solutions:**
1. **Outlook required:**
   - Microsoft Outlook must be installed
   - Web-based email won't work

2. **Outlook not configured:**
   - Open Outlook and set up your account first
   - Try sending a test email manually

3. **Outlook not running:**
   - The em suffix will start Outlook if closed
   - Wait a few seconds for it to open

### oi suffix doesn't insert

**Problem:** `recipeoi` doesn't insert into email

**Solutions:**
1. **Email must be open:**
   - Open a compose or reply window first
   - The script can't create new emails with oi

2. **Cursor position:**
   - Click in the email BODY
   - Won't work if cursor is in To, CC, or Subject

3. **Outlook focus:**
   - Make sure Outlook is the active window
   - Click in the email body immediately before typing

---

## Database Issues

### Captures disappeared

**Problem:** All captures are gone

**Solutions:**
1. **Check file location:**
   - Open script folder
   - Is `captures.dat` there?
   - Check file size (should not be 0 KB)

2. **Wrong folder:**
   - Script may be looking in different folder
   - Check `config.ini` for `CaptureFolder` setting

3. **Restore from backup:**
   - Check `backups/` folder for recent copies
   - Copy backup file over `captures.dat`
   - Reload script

### Duplicate entries

**Problem:** Same capture appears multiple times

**Solutions:**
1. **Edit and merge:**
   - Open browser (Ctrl+Alt+B)
   - Delete duplicates, keep best one

2. **Prevent future duplicates:**
   - ContentCapture Pro warns about duplicate URLs
   - Pay attention to the warning

---

## Performance Issues

### Script is slow

**Problem:** Hotstrings take a long time to trigger

**Solutions:**
1. **Large database:**
   - If you have thousands of captures, it may slow down
   - Export old captures to HTML
   - Delete ones you don't use

2. **Regenerate hotstrings:**
   - Delete `ContentCapture_Generated.ahk`
   - Reload script (Ctrl+Alt+L)

3. **Close other scripts:**
   - Other AutoHotkey scripts may interfere
   - Try with only ContentCapture Pro running

### High CPU usage

**Problem:** Script uses too much CPU

**Solutions:**
1. **Check for loops:**
   - Reload script (Ctrl+Alt+L)
   - If problem persists, report on GitHub

2. **Disable recent widget:**
   - The floating widget updates frequently
   - Close it if not needed

---

## Browser Issues

### Can't open Capture Browser

**Problem:** Ctrl+Alt+B doesn't open browser

**Solutions:**
1. **Check script is running:**
   - Look for system tray icon
   - Reload if needed

2. **Window may be hidden:**
   - Check taskbar for ContentCapture window
   - Press Alt+Tab to find it

### Browser is empty

**Problem:** Browser shows no captures

**Solutions:**
1. **No captures yet:**
   - Create your first capture with Ctrl+Alt+G

2. **Wrong database:**
   - Check `config.ini` for correct folder path
   - Verify `captures.dat` exists and has content

3. **Filter active:**
   - Check if a tag filter is selected
   - Click "All" or clear the filter

---

## Getting More Help

### Before Reporting an Issue

1. Try the quick fixes at the top of this guide
2. Search existing GitHub issues
3. Check if running as administrator helps

### When Reporting an Issue

Include:
- Windows version (10 or 11)
- AutoHotkey version (v2.x.x)
- ContentCapture Pro version
- What you tried to do
- What happened instead
- Any error messages (screenshot if possible)

### Where to Get Help

- **GitHub Issues:** [Report bugs](https://github.com/smogmanus1/ContentCapture-Pro/issues)
- **AutoHotkey Forums:** [Community help](https://www.autohotkey.com/boards/)
- **Built-in help:** Press Ctrl+Alt+M for main menu

---

## Error Messages

### Common Error Messages

| Error | Meaning | Solution |
|-------|---------|----------|
| "Script not found" | File was moved or deleted | Re-download |
| "Database corrupted" | captures.dat is damaged | Restore from backup |
| "Outlook not available" | Outlook not installed | Install Outlook or skip email features |
| "URL required" | Capture has no URL | Edit capture to add URL |
| "Hotkey already in use" | Another program uses same key | Change hotkey or close other program |

---

**Still having issues?** Create a GitHub issue with details!
