# ContentCapture Pro - Suffix Reference

Complete guide to all available suffixes and actions.

---

## How Suffixes Work

Every capture you create gets a name (like `recipe`). Add a suffix to perform different actions:

```
recipego    →  Opens the URL in your browser
recipeem    →  Creates an email with the content
recipefb    →  Shares to Facebook
```

Just type the name + suffix, then press Space, Tab, or Enter.

---

## Core Suffixes

These are the most commonly used suffixes.

| Suffix | Action | Example |
|--------|--------|---------|
| (none) | Paste full content | `recipe` |
| `?` | Show action menu | `recipe?` |
| `go` | Open URL in browser | `recipego` |
| `sh` | Paste short version (title + URL only) | `recipesh` |
| `c` | Copy to clipboard (no paste) | `recipec` |

---

## Email Suffixes

For Microsoft Outlook integration.

| Suffix | Action | Example |
|--------|--------|---------|
| `em` | Create new email with content | `recipeem` |
| `oi` | Insert at cursor in open Outlook email | `recipeoi` |
| `ed` | Email with attached document | `recipeed` |

### Email Workflow

**`em` suffix** - Creates a brand new email:
1. Type `recipeem`
2. Outlook opens with a new email
3. Content is in the body, ready to send

**`oi` suffix** - Inserts into an existing email:
1. Open or reply to an email in Outlook
2. Click where you want the content
3. Type `recipeoi`
4. Content appears at cursor position

---

## Social Media Suffixes

Share directly to your favorite platforms.

| Suffix | Platform | Character Limit | Example |
|--------|----------|-----------------|---------|
| `fb` | Facebook | 63,206 | `recipefb` |
| `x` | Twitter/X | 280 | `recipex` |
| `bs` | Bluesky | 300 | `recipebs` |
| `li` | LinkedIn | 3,000 | `recipeli` |
| `mt` | Mastodon | 500 | `recipemt` |

### Social Sharing Tips

**URL Placement Matters:**
- Put video URLs **last** for better preview cards
- Facebook shows the last URL's thumbnail

**Character Limits:**
- Content is automatically trimmed to fit
- Add your own commentary before the limit

---

## View & Edit Suffixes

| Suffix | Action | Example |
|--------|--------|---------|
| `rd` | Read in popup window (no editing) | `reciperd` |
| `vi` | View and edit the capture | `recipevi` |

### View vs Edit

**`rd` (Read):**
- Quick popup to see content
- Copy button included
- Can't make changes

**`vi` (View/Edit):**
- Full editor window
- Change title, URL, body, tags
- Save changes back to database

---

## Document Suffixes

For captures with attached files.

| Suffix | Action | Example |
|--------|--------|---------|
| `d.` | Open the attached document | `reciped.` |
| `ed` | Email with document attached | `recipeed` |

### Attaching Documents

When capturing, you can attach a document path. Then:
- `named.` opens that document
- `nameed` emails the content with the document attached

---

## Research Suffixes

Tools for fact-checking and research.

| Suffix | Tool | What It Does | Example |
|--------|------|--------------|---------|
| `yt` | YouTube | Extract video transcript | `videoyt` |
| `pp` | Perplexity | AI-powered research | `topicpp` |
| `fc` | Snopes | Fact-check the content | `claimfc` |
| `mb` | Media Bias | Check source credibility | `articlemb` |
| `wb` | Wayback Machine | View archived versions | `pagewb` |
| `gs` | Google Scholar | Find academic sources | `topicgs` |
| `av` | Archive.today | Save a permanent copy | `pageav` |

### Research Workflow Example

1. Capture a news article as `election`
2. Type `electionfc` → Searches Snopes for fact-checks
3. Type `electionmb` → Checks if source is reliable
4. Type `electionwb` → Sees archived versions

---

## Quick Reference Card

Print this out and keep it handy!

```
BASIC ACTIONS
─────────────────────────────────
(name)      Paste full content
(name)?     Show action menu
(name)go    Open URL
(name)sh    Paste short version
(name)c     Copy only (no paste)

EMAIL
─────────────────────────────────
(name)em    New Outlook email
(name)oi    Insert in open email
(name)ed    Email with attachment

SOCIAL MEDIA
─────────────────────────────────
(name)fb    Facebook
(name)x     Twitter/X
(name)bs    Bluesky
(name)li    LinkedIn
(name)mt    Mastodon

VIEW & EDIT
─────────────────────────────────
(name)rd    Read in popup
(name)vi    View/Edit capture

DOCUMENTS
─────────────────────────────────
(name)d.    Open document
(name)ed    Email with document

RESEARCH
─────────────────────────────────
(name)yt    YouTube transcript
(name)pp    Perplexity AI
(name)fc    Snopes fact-check
(name)mb    Media Bias check
(name)wb    Wayback Machine
(name)gs    Google Scholar
(name)av    Archive.today
```

---

## The `?` Menu

Can't remember a suffix? Just add `?` to any capture name:

```
recipe?
```

A menu pops up showing ALL available actions for that capture. Click one to execute it.

---

## Tips & Tricks

### Combine with Tags

Organize captures by topic, then use suffixes efficiently:
- All `work-` captures can use `work-reportem` for email
- All `recipe-` captures can use `recipe-pastash` for short paste

### Speed Tips

- **`go`** is fastest for opening links
- **`sh`** is best for quick sharing (no body text)
- **`?`** when you can't remember what's available

### Social Media Pro Tips

1. **Video URLs last** - Put YouTube/video links at the end for preview thumbnails
2. **Short names** - `news` is faster to type than `latestnews`
3. **Use `sh`** - Short version often works better for social

---

## Troubleshooting Suffixes

### Suffix not recognized

- Make sure there's no space between name and suffix
- Check spelling: `recipefb` not `recipe fb`
- Verify the capture exists in browser (`Ctrl+Alt+B`)

### Social share opens wrong platform

- Check suffix spelling: `x` for Twitter, `fb` for Facebook
- Make sure you're not typing `twitter` or `facebook` as suffix

### Email not working

- Outlook must be installed and configured
- Try `em` suffix first (easier than `oi`)
- For `oi`, cursor must be in email body, not To/Subject field

---

## Complete Suffix List

| Suffix | Category | Action |
|--------|----------|--------|
| (none) | Core | Paste full content |
| `?` | Core | Show action menu |
| `go` | Core | Open URL in browser |
| `sh` | Core | Paste short (title + URL) |
| `c` | Core | Copy to clipboard |
| `em` | Email | Create Outlook email |
| `oi` | Email | Insert in open email |
| `ed` | Email | Email with document |
| `fb` | Social | Share to Facebook |
| `x` | Social | Share to Twitter/X |
| `bs` | Social | Share to Bluesky |
| `li` | Social | Share to LinkedIn |
| `mt` | Social | Share to Mastodon |
| `rd` | View | Read in popup |
| `vi` | View | View/Edit capture |
| `d.` | Document | Open attached document |
| `yt` | Research | YouTube transcript |
| `pp` | Research | Perplexity AI |
| `fc` | Research | Snopes fact-check |
| `mb` | Research | Media Bias check |
| `wb` | Research | Wayback Machine |
| `gs` | Research | Google Scholar |
| `av` | Research | Archive.today |

---

**Remember:** When in doubt, add `?` to see all options!
