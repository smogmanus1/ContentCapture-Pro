# ContentCapture Pro - Suffix Reference

## Quick Reference

| Suffix | Action | Example |
|--------|--------|---------|
| (none) | Paste full content | `::recipe::` |
| `?` | Show action menu | `::recipe?::` |
| `t` | Title only | `::recipet::` |
| `url` | URL only | `::recipeurl::` |
| `body` | Body only | `::recipebody::` |
| `cp` | Copy (no paste) | `::recipecp::` |
| `sh` | Short version | `::recipesh::` |
| `em` | Email via Outlook | `::recipeem::` |
| `oi` | Insert in Outlook | `::recipeoi::` |
| `go` | Open URL | `::recipego::` |
| `rd` | Read popup | `::reciperd::` |
| `vi` | View/Edit | `::recipevi::` |
| `i` | Image path | `::recipei::` |
| `ti` | Title + image | `::recipeti::` |
| `img` | Image to clipboard | `::recipeimg::` |
| `imgo` | Open image | `::recipeimgo::` |
| `fb` | Facebook | `::recipefb::` |
| `x` | Twitter/X | `::recipex::` |
| `bs` | Bluesky | `::recipebs::` |
| `li` | LinkedIn | `::recipeli::` |
| `mt` | Mastodon | `::recipemt::` |
| `fbi` | Facebook + image | `::recipefbi::` |
| `xi` | Twitter + image | `::recipexi::` |
| `bsi` | Bluesky + image | `::recipebsi::` |
| `d.` | Open document | `::reciped.::` |
| `ed` | Email + document | `::recipeed::` |
| `pr` | Print | `::recipepr::` |
| `sum` | AI summarize | `::recipesum::` |

---

## Detailed Guide

### Core Content Suffixes

#### `(none)` - Full Content
Pastes the complete capture: URL, title, opinion, and body.
```
::recipe::  →  https://example.com/pasta
                Delicious Pasta Recipe
                My Take: Best recipe ever!
                [Full body content]
```

#### `t` - Title Only
Pastes just the title. Perfect for references and citations.
```
::recipet::  →  Delicious Pasta Recipe
```

#### `url` - URL Only
Pastes just the URL. Quick link sharing.
```
::recipeurl::  →  https://example.com/pasta
```

#### `body` - Body Only
Pastes body content without URL or title.
```
::recipebody::  →  [Just the body text]
```

#### `cp` - Copy Only
Copies full content to clipboard WITHOUT pasting. Use when you want to edit before pasting.
```
::recipecp::  →  [Copied to clipboard, shows notification]
```

#### `sh` - Short Version
Pastes the saved short version (must be saved first via action menu).
```
::recipesh::  →  [Your saved short version]
```

---

### View & Navigation

#### `?` - Action Menu
Shows a GUI with all available actions for quick selection.

#### `go` - Open URL
Opens the capture's URL in your default browser.

#### `rd` - Read
Shows content in a popup window for reading.

#### `vi` - View/Edit
Opens the capture in the edit dialog for modifications.

---

### Email Suffixes

#### `em` - Email
Creates a NEW Outlook email with the capture content.

#### `oi` - Outlook Insert
Inserts content at cursor in an OPEN Outlook email. Use when replying or composing.

#### `ed` - Email with Document
Creates email with attached document (if one is linked).

---

### Image Suffixes

#### `i` - Image Path
Pastes the image file PATH as text. Perfect for:
- File Open dialogs (paste path to navigate)
- Command line usage
- Documentation
```
::recipei::  →  C:\Users\You\ContentCapture\images\pasta.jpg
```

#### `ti` - Title + Image Path
Pastes title on one line, then image path on the next.
```
::recipeti::  →  Delicious Pasta Recipe
                 C:\Users\You\ContentCapture\images\pasta.jpg
```

#### `img` - Image to Clipboard
Copies the image as a BITMAP to clipboard for pasting into apps like Word, Paint, etc.

#### `imgo` - Open Image
Opens the attached image in your default image viewer.

---

### Social Media

#### Text Only
| Suffix | Platform | Character Limit |
|--------|----------|-----------------|
| `fb` | Facebook | 63,206 |
| `x` | Twitter/X | 280 |
| `bs` | Bluesky | 300 |
| `li` | LinkedIn | 3,000 |
| `mt` | Mastodon | 500 |

#### With Images
| Suffix | Platform |
|--------|----------|
| `fbi` | Facebook + image |
| `xi` | Twitter/X + image |
| `bsi` | Bluesky + image |
| `lii` | LinkedIn + image |
| `mti` | Mastodon + image |

---

### Document & Print

#### `d.` - Open Document
Opens the attached document in its default application.

#### `pr` - Print
Opens print dialog for a formatted capture.

---

### AI & Research

#### `sum` - Summarize
Triggers AI summarization of the capture content.

---

## Usage Examples

### Quick Social Post
```
::newst::      → Paste title for headline
::newsurl::    → Paste link
::newsfb::     → Share to Facebook with full content
```

### File Dialog Navigation
```
::logoi::      → Pastes: C:\Projects\logos\company.png
                 (In file dialog, press Enter to navigate there)
```

### Email Workflow
```
::reportem::   → Creates new email with report content
::reportoi::   → Inserts into email you're already writing
```

### Research
```
::article::    → Paste full article for reference
::articlet::   → Just the title for citation
::articlego::  → Open original source
```

---

## Tips

1. **Can't remember suffixes?** Type `::name?::` to see all options

2. **Image suffixes:**
   - `i` = path as text (for file dialogs)
   - `img` = bitmap (for pasting into apps)

3. **Email efficiency:**
   - `em` = NEW email
   - `oi` = INSERT into existing email

4. **The Dynamic Suffix Handler** catches these even if the hotstring file hasn't regenerated yet.
