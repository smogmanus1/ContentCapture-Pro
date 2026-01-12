# How to Create ContentCapture Pro .exe File

## Why Create an .exe?

- Share with others who don't have AutoHotkey installed
- Easier to run (just double-click)
- Can add to Windows startup more easily

---

## Method 1: VS Code (Recommended)

### One-Time Setup
1. Install VS Code: https://code.visualstudio.com/
2. Install AutoHotkey v2: https://www.autohotkey.com/
3. In VS Code, go to Extensions (Ctrl+Shift+X)
4. Search for "AutoHotkey v2" and install it

### Compile Steps
1. Open VS Code
2. Open the file `ContentCapture.ahk` (the launcher, NOT ContentCapture-Pro.ahk)
3. Right-click anywhere in the code
4. Select **"Compile Script"** or **"Compile Script (GUI)"**
5. Choose where to save the .exe
6. Done!

---

## Method 2: Ahk2Exe (Built-in Compiler)

### Find Ahk2Exe
After installing AutoHotkey v2, find the compiler at:
```
C:\Program Files\AutoHotkey\Compiler\Ahk2Exe.exe
```

### Compile Steps
1. Run Ahk2Exe.exe
2. **Source (script file):** Click Browse, select `ContentCapture.ahk`
3. **Destination (.exe file):** Click Browse, choose save location
4. **Base File (.bin, .exe):** Leave as default (auto-detected)
5. Click **Convert**
6. Wait for "Conversion complete" message
7. Done!

---

## IMPORTANT: Files Needed with the .exe

The .exe file alone WON'T WORK. You need these files in the SAME FOLDER:

```
📁 ContentCapture Pro/
   ├── ContentCapture.exe           ← Your compiled file
   ├── ContentCapture-Pro.ahk       ← MUST INCLUDE
   └── DynamicSuffixHandler.ahk     ← MUST INCLUDE
```

### Why?
The main script uses `#Include` to load the other files. The .exe still needs access to these files at runtime.

---

## Distribution Package

When sharing with others, create a ZIP file containing:

```
📁 ContentCapture-Pro-v4.4/
   ├── ContentCapture.exe           ← Main executable
   ├── ContentCapture-Pro.ahk       ← Required
   ├── DynamicSuffixHandler.ahk     ← Required
   ├── README.txt                   ← Instructions
   └── QUICK-START.txt              ← Quick reference
```

### Instructions for Recipients
Tell them to:
1. Extract all files to the same folder
2. Double-click ContentCapture.exe
3. Complete the setup wizard
4. Done!

They do NOT need AutoHotkey installed - it's bundled in the .exe.

---

## Troubleshooting

### "Script file not found" Error
- Make sure `ContentCapture-Pro.ahk` is in the same folder as the .exe

### "Could not load DynamicSuffixHandler" Error  
- Make sure `DynamicSuffixHandler.ahk` is in the same folder as the .exe

### .exe Won't Run at All
- Try running as Administrator
- Check if antivirus is blocking it (AutoHotkey .exe files sometimes get flagged)
- Add an exception in your antivirus

### "This app can't run on your PC" Error
- You may have compiled with wrong base file
- Re-compile making sure to use the v2 Unicode 64-bit base

---

## Advanced: Single-File .exe (Optional)

If you want ONE file with no dependencies, you need to combine all code first:

### Steps
1. Create a new file called `ContentCapture-Combined.ahk`
2. Copy the ENTIRE contents of `DynamicSuffixHandler.ahk` into it
3. Copy the ENTIRE contents of `ContentCapture-Pro.ahk` below that
4. Copy the ENTIRE contents of `ContentCapture.ahk` below that
5. Remove all `#Include` lines
6. Compile `ContentCapture-Combined.ahk`

This creates a true standalone .exe but is harder to maintain/update.

---

## File Reference

| File | Purpose | Include in Distribution? |
|------|---------|-------------------------|
| ContentCapture.ahk | Launcher script | Compile this to .exe |
| ContentCapture-Pro.ahk | Main script | YES - Required |
| DynamicSuffixHandler.ahk | Suffix handler | YES - Required |
| config.ini | User settings | NO - Created automatically |
| captures.dat | User data | NO - Created automatically |
| README.md | Documentation | Optional but recommended |

---

## Quick Checklist

- [ ] AutoHotkey v2 installed
- [ ] VS Code with AHK extension (or use Ahk2Exe)
- [ ] Compile `ContentCapture.ahk` (not ContentCapture-Pro.ahk)
- [ ] Put .exe in folder with ContentCapture-Pro.ahk
- [ ] Put .exe in folder with DynamicSuffixHandler.ahk
- [ ] Test by double-clicking the .exe
- [ ] Zip all files together for distribution
