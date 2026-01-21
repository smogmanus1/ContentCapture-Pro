# ContentCapture Pro - Suffix Reference

Type your capture name followed by a suffix, then press space/tab/enter.

## Quick Reference

| Suffix | Action | Example |
|--------|--------|---------|
| *(none)* | Paste full content | `mypost` |
| `em` | Email via Outlook | `mypostem` |
| `vi` | View/Edit in GUI | `mypostvi` |
| `go` | Open URL in browser | `mypostgo` |
| `rd` | Read in popup | `mypostrd` |
| `sh` | Paste short version | `mypostsh` |

---

## Social Media (Text Only)

| Suffix | Platform | Example |
|--------|----------|---------|
| `fb` | Facebook | `mypostfb` |
| `x` | Twitter/X | `mypostx` |
| `bs` | Bluesky | `mypostbs` |
| `li` | LinkedIn | `mypostli` |
| `mt` | Mastodon | `mypostmt` |

---

## 🖼️ Image Suffixes (NEW in v5.9.2)

| Suffix | Action | Example |
|--------|--------|---------|
| `img` | Copy image to clipboard | `mypostimg` |
| `imgo` | Open image in viewer | `mypostimgo` |
| `fbi` | Facebook + image(s) | `mypostfbi` |
| `xi` | Twitter/X + image(s) | `mypostxi` |
| `bsi` | Bluesky + image(s) | `mypostbsi` |
| `lii` | LinkedIn + image(s) | `mypostlii` |
| `mti` | Mastodon + image(s) | `mypostmti` |
| `emi` | Email + image(s) | `mypostemi` |

### Platform Image Limits

| Platform | Max Images |
|----------|------------|
| Facebook (post) | 10 |
| Facebook (comment) | 1 |
| Twitter/X | 4 |
| Bluesky | 4 |
| LinkedIn | 9 |
| Mastodon | 4 |

### Image Sharing Hotkeys

| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+V` | Paste pending text (after image upload) |
| `Ctrl+Alt+I` | Copy next image to clipboard |

---

## AI & Research Tools

| Suffix | Tool | Example |
|--------|------|---------|
| `sum` | AI Summarize | `mypostsum` |
| `yt` | YouTube Transcript | `mypostyt` |
| `pp` | Perplexity AI | `mypostpp` |
| `fc` | Fact Check (Snopes) | `mypostfc` |
| `mb` | Media Bias Check | `mypostmb` |
| `wb` | Wayback Machine | `mypostwb` |
| `gs` | Google Scholar | `mypostgs` |
| `av` | Archive.today | `mypostav` |

---

## Examples

### Basic Usage
```
recipe        → Pastes full content of "recipe" capture
recipego      → Opens the URL in browser
recipeem      → Creates email with content
```

### Social Sharing
```
newsbs        → Copies content for Bluesky
newsx         → Opens Twitter compose with content
```

### Image Sharing
```
protestimg    → Copies attached image to clipboard
protestfbi    → Facebook sharing workflow with image
protestxi     → Twitter with image ready
```

### Research
```
claimfc       → Opens Snopes to fact-check
articlewb     → Opens Wayback Machine archive
```

---

## Attaching Images

### Via Edit Dialog
1. Open capture: `mypostvi`
2. Click "Attach Doc..." or Image section
3. Select image file(s)
4. Save

### Via images.dat
```
mypost|photo1.jpg|photo2.png
another|infographic.jpg
```

---

## Tips

1. **Video URLs last** - Put video URLs at the end of your content so the video thumbnail shows as the preview card

2. **Short versions** - Create short versions for platforms with character limits using the `sh` suffix

3. **Multiple images** - Use `Ctrl+Alt+I` to cycle through additional images during sharing

4. **Platform detection** - The system auto-detects Facebook post vs comment context
