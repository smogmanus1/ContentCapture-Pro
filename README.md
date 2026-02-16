# ContentCapture Pro v6.4.0

![ContentCapture Pro - Save Once, Share Everywhere](images/ccpimage.png)

## 🍪 Save Recipes, Articles, Videos & Transcripts from the Internet! 🍪

**ContentCapture Pro** is a free, open-source productivity tool that lets you capture webpage content with one hotkey and instantly recall it anywhere using short, memorable names. Capture once, share everywhere — to email, social media, AI research tools, and more.

Built with [AutoHotkey v2](https://www.autohotkey.com/) for Windows.

---

# ⛔ STOP! READ THIS FIRST! ⛔

# You MUST Install AutoHotkey BEFORE This Will Work!

---

## 📥 STEP 1: Install AutoHotkey v2

# 👉 [CLICK HERE TO DOWNLOAD](https://www.autohotkey.com/download/) 👈

1. Click that link ☝️
2. Click the big green **"Download"** button
3. Click **"Download v2.0"** (the TOP one, NOT v1.1!)
4. **Double-click** the downloaded file
5. Click **Next → Next → Install → Finish**

### ✅ Done? You should see "Installation Complete"

---

## 📥 STEP 2: Install ContentCapture Pro

**Find the file called `install.bat` and double-click it!**

* If Windows says "Windows protected your PC" → Click **"More info"** → Click **"Run anyway"**
* Click **"Yes"** when it asks questions
* When it's done, look for a **green "H" icon** near your clock (bottom-right corner of screen)

💡 *Having problems? Try right-clicking `install.bat` and selecting "Run as administrator"*

**🎉 That's it! You're ready to start saving!**

---

## 🍳 STEP 3: Save Something!

1. Open your web browser (Chrome, Edge, Firefox, LibreWolf)
2. Go to any webpage — a recipe, news article, YouTube video, anything
3. **Highlight** the text you want to save (click and drag your mouse over it)
4. Press **Ctrl + Alt + G** at the same time
   * Hold **Ctrl** (corner of keyboard)
   * Hold **Alt** (next to spacebar)
   * Tap the letter **G**
5. Type a short name like `soup1` (no spaces!)
6. Click **Save**

---

## 🔮 STEP 4: Get It Back!

Want your content back? Easy!

1. Click where you want to type (Word, email, anywhere)
2. Type: `soup1` then press **Space**
3. ✨ Your content appears! ✨

---

## 📋 Quick Reference (Print This!)

| To Do This... | Press These Keys |
| --- | --- |
| **Save from website** | **Ctrl + Alt + G** |
| **See all your saves** | **Ctrl + Alt + B** |
| **Get help** | **F1** (inside the browser) or click **❓** |

| Type This... | To Do This... |
| --- | --- |
| `soup1` then Space | Paste your saved content |
| `soup1go` then Space | Open the original website |
| `soup1em` then Space | Email it to someone |
| `soup1fb` then Space | Share to Facebook |
| `soup1x` then Space | Share to Twitter/X |
| `soup1bs` then Space | Share to Bluesky |
| `soup1gpt` then Space | Send to ChatGPT |
| `soup1cl` then Space | Send to Claude |

---

## 🚀 What Can ContentCapture Pro Do?

### 📸 Capture Anything
One hotkey captures the URL, page title, and any highlighted text from your browser. YouTube videos? It grabs the transcript too and saves it in a dedicated field so you can reference it anytime without re-downloading.

### ⌨️ 22 Suffix Actions Per Capture
Every capture gets 22 hotstring variants automatically. Type the name with a suffix to paste, email, share to social media, open the URL, send to AI, and more. Power users can access any capture in under 2 seconds.

### 🤖 AI-Powered Research
Select any capture and send its content directly to ChatGPT, Claude, Perplexity, or Ollama with one click. The new **AI Summarize** menu builds platform-specific prompts — tell it to write a Facebook post, a tweet, a LinkedIn share, fact-check the content, or explain it simply. Your opinion and source are included automatically.

### 📜 Dedicated Transcript Field
YouTube and video transcripts now get their own field, separate from your body text. Write your own notes and opinions in the Body field while the raw transcript is preserved for AI analysis, fact-checking, or reference. Paste a transcript with one click during capture or in the Edit screen.

### 🔍 Deep Search
Search across everything — your JSON capture database and legacy files. Find any URL, title, or text across thousands of captures instantly.

### 📊 Research & Verification Toolkit
Built-in tools for Snopes fact-checking, Media Bias ratings, Google Scholar, Wayback Machine, and Archive.today. Research notes are saved directly to each capture with quick-tag buttons for verified/false/mixed ratings.

### 🖱️ Hover Preview
Mouse over any capture in the browser to see a tooltip preview with the title, URL, body snippet, tags, and status — no clicking required.

### ❓ Built-In Help System
Press F1 or click ❓ in the Capture Browser for a tabbed help window covering Quick Start, all 22 suffixes, browser controls, hotkeys, and tips. Stays on top while you work.

### 📤 Share Everywhere
Share to Facebook, Twitter/X, Bluesky, LinkedIn, and email. The Short Version field lets you craft character-limited posts for each platform. Social media sharing automatically uses your Short Version when available.

### 💾 Rock-Solid Reliability
Every clipboard operation follows the correct save → clear → set → wait → paste → restore pattern. GUI windows never permanently disable your hotstrings. Error dialogs catch crashes visibly instead of silent failures.

---

## 🆕 What's New in v6.4.0

**New: Dedicated Transcript Field 📜**
* YouTube transcripts save to their own field — separate from your body text
* Write your own notes in Body while the raw transcript is preserved
* One-click Paste button in the Edit GUI for quick transcript entry
* AI tools can target the transcript specifically for analysis

**New: AI Summarize for Platforms 🤖**
* Research menu → AI Summarize for → Facebook / Twitter / Bluesky / LinkedIn
* Also: Write a Comment, Fact-Check, Key Points, and ELI5 prompts
* Automatically includes your title, URL, opinion, and transcript/body
* Choose ChatGPT, Claude, Perplexity, Ollama, or just copy to clipboard

**Fixed: WinGetTitle Error 🛡️**
* No more "Target window not found" error dialogs during capture
* Graceful fallback when active window changes mid-capture

**Previous Highlights (v6.3.x):**
* Built-in Help System with 5 tabbed sections
* Deep Search across all capture sources
* 19 clipboard handling bugs fixed across the codebase
* GUI suspension system completely rebuilt — hotstrings never get permanently stuck
* Social media Short Version field now properly used by sharing functions

---

## ❓ PROBLEMS? READ THIS!

### "Nothing happens when I press Ctrl+Alt+G"

1. Look for a green **"H"** near your clock (might need to click the little **^** arrow to see hidden icons)
2. **No green H?** Double-click `ContentCapture.ahk` to start the program
3. **Still nothing?** You probably need to install AutoHotkey — go back to STEP 1!

### "I see an error about v2"

You installed the wrong version! Go to [autohotkey.com/download](https://www.autohotkey.com/download/) and make sure you download **v2.0** (the top option), NOT v1.1

### "Windows blocked the program"

This is normal! Click **"More info"** then **"Run anyway"** — the program is safe!

### "Where are my saves stored?"

In a file called `captures.dat` — **DON'T DELETE THIS FILE!** It has all your saves!

---

## 💾 How to Back Up Your Data

Copy these to a USB drive or email them to yourself:

* The file called `captures.dat`
* The folder called `images`

---

## 👵 Tips for Naming Your Saves

**GOOD names:**

* `cookies1`
* `meatloaf`
* `momsoup`
* `xmasstuffing`
* `climatevid`

**BAD names:**

* `Grandma's Cookies` ❌ (no spaces or apostrophes!)
* `a` ❌ (too short, you'll forget what it is)
* `recipe` ❌ (too generic)

---

## 🗂️ Project Structure

```
ContentCapture-Pro/
├── ContentCapture.ahk          # Main launcher (run this!)
├── ContentCapture-Pro.ahk      # Core application
├── DynamicSuffixHandler.ahk    # Suffix hotstring engine
├── ResearchTools.ahk           # AI & research toolkit
├── CC_Clipboard.ahk            # Clipboard management
├── CC_GrepAll.ahk              # Deep Search module
├── CC_HelpWindow.ahk           # Built-in help system
├── CC_HoverPreview.ahk         # Hover tooltip previews
├── CC_ShareModule.ahk          # Import/Export
├── SocialShare.ahk             # Social media sharing
├── ImageCapture.ahk            # Image attachments
├── ImageClipboard.ahk          # Image clipboard handling
├── ImageDatabase.ahk           # Image storage
├── ImageSharing.ahk            # Image sharing
├── install.bat                 # One-click installer
├── Install-ContentCapture.ps1  # PowerShell installer
├── captures.dat                # Your data (created on first run)
├── config.ini                  # Settings (created on first run)
└── images/                     # Attached images
```

---

## 📞 Need Help?

* **Website:** [crisisoftruth.org](https://crisisoftruth.org)
* **GitHub Issues:** [Report a bug](https://github.com/smogmanus1/ContentCapture-Pro/issues)
* **AutoHotkey Forums:** [Discussion thread](https://www.autohotkey.com/boards/)

---

## 🙏 Credits

Created by Brad | [crisisoftruth.org](https://crisisoftruth.org)

Special thanks to the AutoHotkey community, Joe Glines, Isaias Baez, and Jack Dunning for inspiration and contributions.

---

## 📄 License

[MIT License](LICENSE) — Free to use, modify, and share.

---

**Made with ❤️ by Brad**

**Happy Capturing! 🚀**
