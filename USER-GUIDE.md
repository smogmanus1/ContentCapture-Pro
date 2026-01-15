# ContentCapture Pro - User Guide

Complete documentation for all features.

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Capturing Content](#capturing-content)
3. [Using Hotstrings](#using-hotstrings)
4. [The Suffix System](#the-suffix-system)
5. [Capture Browser](#capture-browser)
6. [Email Integration](#email-integration)
7. [Social Media Sharing](#social-media-sharing)
8. [Research Tools](#research-tools)
9. [Document Attachments](#document-attachments)
10. [Tags and Organization](#tags-and-organization)
11. [Settings and Configuration](#settings-and-configuration)
12. [Backup and Recovery](#backup-and-recovery)
13. [Keyboard Shortcuts](#keyboard-shortcuts)
14. [Tips and Best Practices](#tips-and-best-practices)

---

## Getting Started

### What is ContentCapture Pro?

ContentCapture Pro transforms how you save and share web content. Instead of bookmarks you'll never find again, you create memorable short names that work anywhere on your computer.

### The Basic Workflow

1. **Find** interesting content online
2. **Capture** it with `Ctrl+Alt+G`
3. **Name** it something memorable (like `recipe`)
4. **Use** it later by typing `recipe` or `recipego` or `recipefb`

### Why This is Better Than Bookmarks

| Bookmarks | ContentCapture Pro |
|-----------|-------------------|
| Buried in folders | Type anywhere to access |
| Just saves URL | Saves URL + title + notes |
| Can't share easily | One-suffix sharing |
| Hard to search | Full-text search |
| Browser-specific | Works in any app |

---

## Capturing Content

### Standard Capture (Ctrl+Alt+G)

1. Navigate to any webpage
2. Press `Ctrl+Alt+G`
3. The capture dialog appears with:
   - **URL** (auto-filled from browser)
   - **Title** (auto-filled from page)
   - **Name** (you choose this)
   - **Tags** (optional categories)
   - **Opinion/Notes** (your thoughts)
   - **Body** (optional - highlight text first)

### Capturing Highlighted Text

To include specific text from a page:

1. Highlight the text you want
2. Press `Ctrl+Alt+G`
3. The highlighted text appears in the Body field

### Manual Capture (Ctrl+Alt+N)

Create a capture without visiting a webpage:

1. Press `Ctrl+Alt+N`
2. Fill in all fields manually
3. Useful for:
   - Notes and reminders
   - Frequently-used text snippets
   - Content from non-browser sources

### Naming Best Practices

**Good names:**
- Short: `recipe` not `my-favorite-pasta-recipe`
- Memorable: `guitar` not `vid123`
- Unique: Don't reuse names

**Naming rules:**
- Letters and numbers only
- No spaces or special characters
- Case-insensitive (`Recipe` = `recipe`)

---

## Using Hotstrings

### What is a Hotstring?

A hotstring is text that automatically expands when you type it. In ContentCapture Pro, your capture names become hotstrings.

### Basic Usage

Type your capture name followed by a trigger:

- `recipe` + Space → Pastes content
- `recipe` + Tab → Pastes content
- `recipe` + Enter → Pastes content
- `recipe` + Period → Pastes content

### Where Hotstrings Work

Hotstrings work in virtually any Windows application:

- ✅ Microsoft Office (Word, Excel, PowerPoint, Outlook)
- ✅ Web browsers (Chrome, Edge, Firefox)
- ✅ Email clients
- ✅ Social media sites
- ✅ Chat apps (Slack, Discord, Teams)
- ✅ Note-taking apps (Notion, Obsidian, Notepad)
- ✅ Any text input field

### Hotstring Format

```
capture-name + trigger = action
```

Example: `recipe` + Space = Paste recipe content

---

## The Suffix System

The suffix system is ContentCapture Pro's superpower. Add a suffix to perform different actions.

### How It Works

```
recipe      →  Paste content
recipego    →  Open URL
recipeem    →  Email it
recipefb    →  Share to Facebook
```

### Available Suffixes

See [SUFFIX-REFERENCE.md](SUFFIX-REFERENCE.md) for the complete list.

### The ? Menu

Forgot what suffixes exist? Add `?` to any name:

```
recipe?
```

A menu appears with all available actions.

---

## Capture Browser

Press `Ctrl+Alt+B` to open the full Capture Browser.

### Features

- **Search** - Find captures by name, title, URL, or content
- **Filter by Tag** - Show only captures with specific tags
- **Sort** - By name, date, or title
- **Edit** - Modify any capture
- **Delete** - Remove captures you no longer need
- **Export** - Generate HTML or backup

### Searching

The search box finds matches in:
- Capture name
- Page title
- URL
- Body text
- Tags
- Your notes/opinion

### Filtering by Tag

1. Click the Tag dropdown
2. Select a tag
3. Only matching captures appear

### Editing Captures

1. Select a capture
2. Click **Edit** (or double-click)
3. Modify any field
4. Click **Save**

---

## Email Integration

ContentCapture Pro integrates with Microsoft Outlook.

### Creating New Emails (em suffix)

Type `recipeem` to:
1. Open Outlook
2. Create a new email
3. Populate the body with your capture content

### Inserting into Open Emails (oi suffix)

Type `recipeoi` to:
1. Find your open Outlook compose window
2. Insert content at the cursor position

**Requirements for oi suffix:**
- Outlook must be open
- You must have a compose/reply window open
- Cursor must be in the email body (not To or Subject)

### Email with Attachments (ed suffix)

If your capture has an attached document:
- Type `recipeed` to email with the document attached

---

## Social Media Sharing

Share to multiple platforms with simple suffixes.

### Supported Platforms

| Suffix | Platform | Character Limit |
|--------|----------|-----------------|
| `fb` | Facebook | 63,206 |
| `x` | Twitter/X | 280 |
| `bs` | Bluesky | 300 |
| `li` | LinkedIn | 3,000 |
| `mt` | Mastodon | 500 |

### How Sharing Works

1. Type `recipefb`
2. Your default browser opens
3. Facebook compose window appears
4. Content is ready to post

### Tips for Social Sharing

**Video Thumbnails:**
Put video URLs (YouTube, etc.) **last** in your content. Social platforms show the thumbnail of the last link.

**Character Limits:**
Content is automatically trimmed. For Twitter/X and Bluesky, keep it concise.

**Cross-Posting:**
Capture once, share to all platforms with different suffixes.

---

## Research Tools

Verify and research your captures with built-in tools.

### Available Research Suffixes

| Suffix | Tool | Purpose |
|--------|------|---------|
| `yt` | YouTube | Extract transcript from video |
| `pp` | Perplexity | AI-powered research |
| `fc` | Snopes | Fact-check claims |
| `mb` | Media Bias | Check source reliability |
| `wb` | Wayback Machine | View archived versions |
| `gs` | Google Scholar | Academic sources |
| `av` | Archive.today | Create permanent archive |

### Fact-Checking Workflow

1. Capture a questionable article as `claim`
2. Type `claimfc` → Search Snopes
3. Type `claimmb` → Check source bias
4. Type `claimwb` → See how it changed over time

---

## Document Attachments

Attach files to your captures for quick access.

### Adding a Document

When capturing, enter a file path in the Document field:
```
C:\Users\YourName\Documents\recipe.pdf
```

### Using Documents

| Suffix | Action |
|--------|--------|
| `d.` | Open the attached document |
| `ed` | Email with document attached |

### Example

1. Capture a cooking video, name it `pasta`
2. Attach the PDF recipe: `C:\Recipes\pasta.pdf`
3. Later:
   - `pastago` opens the video
   - `pastad.` opens the PDF
   - `pastaed` emails both

---

## Tags and Organization

Use tags to categorize and find captures.

### Adding Tags

When capturing, enter tags separated by commas:
```
work, report, quarterly
```

Or use hashtag format:
```
#work #report #quarterly
```

### Filtering by Tag

1. Open Capture Browser (`Ctrl+Alt+B`)
2. Click the Tag dropdown
3. Select a tag
4. Only matching captures appear

### Suggested Tag System

| Category | Example Tags |
|----------|--------------|
| Topics | `work`, `personal`, `hobby`, `news` |
| Actions | `todo`, `reference`, `share`, `archive` |
| Projects | `project-x`, `client-abc`, `home-reno` |
| Priority | `important`, `urgent`, `someday` |

---

## Settings and Configuration

Press `Ctrl+Alt+S` to open settings.

### Available Settings

- **Capture Location** - Where captures are stored
- **Default Tags** - Tags added to every capture
- **Hotkey Customization** - Change keyboard shortcuts
- **Startup Behavior** - Auto-start with Windows
- **Backup Settings** - Automatic backup options

### Config File

Settings are stored in `config.ini`:
```ini
[General]
CaptureFolder=C:\Users\YourName\Documents\ContentCapture-Pro
DefaultTags=

[Hotkeys]
CaptureKey=^!g
BrowserKey=^!b

[Backup]
AutoBackup=1
BackupInterval=7
```

---

## Backup and Recovery

Protect your valuable captures.

### Automatic Backups

ContentCapture Pro automatically backs up to the `backups/` folder.

### Manual Backup

1. Copy `captures.dat` to a safe location
2. This single file contains all your captures

### Recovery

1. Replace `captures.dat` with your backup
2. Reload the script (`Ctrl+Alt+L`)

### What to Back Up

| File | Contains | Priority |
|------|----------|----------|
| `captures.dat` | All your captures | **Critical** |
| `config.ini` | Your settings | Important |
| `ContentCapture_Generated.ahk` | Generated hotstrings | Can be regenerated |

---

## Keyboard Shortcuts

### Primary Shortcuts

| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+G` | Capture current webpage |
| `Ctrl+Alt+B` | Open Capture Browser |
| `Ctrl+Alt+N` | Create manual capture |
| `Ctrl+Alt+M` | Show Main Menu |

### Additional Shortcuts

| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+W` | Show Recent Captures widget |
| `Ctrl+Alt+H` | Export captures to HTML |
| `Ctrl+Alt+L` | Reload script |
| `Ctrl+Alt+S` | Open Settings |

### In Capture Browser

| Hotkey | Action |
|--------|--------|
| `Enter` | Open selected capture |
| `Delete` | Delete selected capture |
| `Ctrl+E` | Edit selected capture |
| `Escape` | Close browser |

---

## Tips and Best Practices

### Naming Strategy

**Be consistent:**
- Use a naming pattern: `work-report`, `work-meeting`, `work-project`
- Or use prefixes: `w-report`, `p-recipe`, `h-guitar` (work, personal, hobby)

**Keep it short:**
- `news` beats `latest-news-article-2024`
- Aim for 3-8 characters

### Organization

**Use tags:**
- Add 2-3 tags per capture
- Create a consistent tag vocabulary
- Review and clean up tags periodically

**Regular maintenance:**
- Delete outdated captures monthly
- Update broken URLs when found
- Back up weekly

### Productivity Tips

1. **Create templates** - Capture email signatures, common responses
2. **Batch capture** - When researching, capture all relevant pages
3. **Use the widget** - `Ctrl+Alt+W` for quick access to recent captures
4. **Export to HTML** - Create a searchable archive with `Ctrl+Alt+H`

### Troubleshooting Tips

**Hotstring not working?**
- Check if script is running (system tray icon)
- Verify capture name spelling
- Reload script (`Ctrl+Alt+L`)

**Wrong content pasting?**
- Check for duplicate names in browser
- Edit the capture to verify content

**Social share not working?**
- Check internet connection
- Verify you're logged into the platform
- Try a different browser

---

## Getting Help

### Built-in Help

Press `Ctrl+Alt+M` for the main menu with help options.

### Online Resources

- **GitHub Issues:** Report bugs and request features
- **AutoHotkey Forums:** Community support
- **Documentation:** This guide and related docs

### Support

If you encounter issues:
1. Check [TROUBLESHOOTING.md](TROUBLESHOOTING.md)
2. Search existing GitHub issues
3. Create a new issue with:
   - What you tried to do
   - What happened
   - Your Windows version
   - Error messages (if any)

---

**Happy capturing!** 🎯
