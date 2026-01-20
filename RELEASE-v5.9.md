# ContentCapture Pro v5.9 - Share Your Captures! 🎉

## The Big Update: Share & Import

Ever wanted to share a capture with a friend or family member who also uses ContentCapture Pro? Now you can!

Version 5.9 introduces a complete **Share & Import system** that lets you export captures and share them with other ContentCapture Pro users. The best part? **Everything transfers** - not just the basic content, but research notes, transcripts, summaries, and even attached images.

---

## What's New

### 🔗 Share Button
Select one or more captures in the Browser and click **Share** (or press `Ctrl+S`). You get options to:
- **Copy to Clipboard (Full)** - Includes everything, even images
- **Copy to Clipboard (No Images)** - Smaller, faster for quick shares
- **Save to .ccp File** - Perfect for email attachments

### 📥 Import Button
Click **Import** (or press `Ctrl+I`) to bring in captures someone shared with you:
- Paste JSON from clipboard
- Load a `.ccp` file
- Preview what you're importing before committing
- Smart conflict handling if you already have a capture with the same name

---

## Everything Transfers

When you share a capture, the recipient gets the **complete package**:

| Data | Included |
|------|----------|
| URL, Title, Body | ✅ |
| Tags & Date | ✅ |
| Your Opinion/Notes | ✅ |
| Favorite Status | ✅ |
| Research Notes | ✅ |
| YouTube Transcripts | ✅ |
| AI Summaries | ✅ |
| Attached Images | ✅ (embedded as Base64) |

**Images are fully portable** - they're embedded directly in the export, so you don't need to send separate files. When imported, they automatically restore to the recipient's `images/` folder.

---

## How It Works

### Sharing a Capture

1. Open Capture Browser (`Ctrl+Alt+B`)
2. Select one or more captures (use `Ctrl+Click` for multiple)
3. Click **🔗 Share** or press `Ctrl+S`
4. Choose your export option
5. Send the JSON or file to your friend

### Importing a Capture

1. Open Capture Browser
2. Click **📥 Import** or press `Ctrl+I`
3. Paste the JSON or load the `.ccp` file
4. Click **Preview** to see what's included
5. Handle any conflicts (skip, replace, or rename)
6. Click **Import All**

---

## Import Preview

The preview window shows exactly what you're getting:

```
┌──────────────────────────────────────────────────────────────────┐
│ 📋 Import Preview                                                │
├──────────────────────────────────────────────────────────────────┤
│ Total: 3 | Ready: 2 | Conflicts: 1 | 📷 2 images | 🔬 1 research │
│                                                                  │
│ Status      │ Name      │ Title           │ 📷 │ 🔬 │ 📝 │        │
│ ✅ Ready    │ opensecr  │ OpenSecrets...  │ ✓  │ ✓  │    │ No     │
│ ✅ Ready    │ leejamil  │ Leeja Miller... │ ✓  │    │ ✓  │ No     │
│ ⚠️ Conflict │ projcens  │ Project Cens... │    │    │    │ Yes    │
│                                                                  │
│ 📷 = Has image | 🔬 = Has research | 📝 = Has transcript         │
└──────────────────────────────────────────────────────────────────┘
```

The icons tell you at a glance:
- 📷 = Capture includes an image
- 🔬 = Capture has research notes attached
- 📝 = Capture has a transcript or AI summary

---

## Conflict Handling

If you try to import a capture that already exists in your database, you have three options:

1. **Skip** - Don't import, keep your existing version
2. **Replace** - Overwrite your version with the imported one
3. **Rename** - Import as `capturename_imported`

---

## Use Cases

### Share Verified Content
You've fact-checked an article, added research notes about the source's bias rating, and attached a screenshot. Share the whole package with family members so they have the verified content ready to use.

### Build a Team Knowledge Base
Working on a project? Share relevant captures with colleagues. They get everything you've gathered, organized and ready to paste.

### Help New Users Get Started
Share a starter pack of useful captures to help someone new to ContentCapture Pro hit the ground running.

### Backup and Migrate
Export all your captures to a `.ccp` file as a portable backup. Restore on a new machine or share your entire collection.

---

## New Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+S` | Share selected capture(s) |
| `Ctrl+I` | Import captures |

---

## Technical Details

The export format is JSON-based and human-readable:

```json
{
  "ccpVersion": "2.0",
  "exportDate": "2025-01-19T14:30:00",
  "captureCount": 1,
  "includesImages": true,
  "includesResearch": true,
  "captures": [
    {
      "name": "opensecrets",
      "url": "https://www.opensecrets.org/",
      "title": "OpenSecrets - Following the Money",
      "body": "Track money in politics...",
      "tags": "politics, transparency",
      "research": "✓ Reliable source (Media Bias)",
      "hasImage": true,
      "imageData": "/9j/4AAQSkZJRg..."
    }
  ]
}
```

Images are Base64-encoded, which adds about 33% to the file size but makes everything completely portable. For large batches with many images, use the "No Images" option and share images separately.

---

## Installation

If you're upgrading from a previous version:

1. Download the new files
2. Replace `ContentCapture-Pro.ahk`
3. Add the new `CC_ShareModule.ahk` file
4. Reload the script

The Share and Import buttons will appear in your Capture Browser automatically.

---

## What's Next?

This update sets the foundation for community sharing. Future possibilities include:
- Community capture libraries
- One-click import from shared links
- Capture collections/packs

---

## Download

Get ContentCapture Pro v5.9 from GitHub:
**github.com/smogmanus1/ContentCapture-Pro**

---

## Feedback

Found a bug? Have ideas for improvements? Open an issue on GitHub or leave a comment!

Special thanks to the AutoHotkey community for the continued support and feedback.

Happy capturing! 🚀
