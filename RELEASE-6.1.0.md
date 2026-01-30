# ContentCapture Pro v6.1.0 Release

**Release Date:** January 28, 2025  
**Release Type:** Feature Release

---

## 🎯 Release Summary

This release adds image attachment support to the Manual Capture dialog, enabling users to associate images with their captures for enhanced content management and social media sharing workflows.

---

## 📋 Commit Message

```
feat: Add image attachment support to Manual Capture GUI

- Add Browse/Clear buttons for image selection
- Support JPG, PNG, GIF, BMP, WEBP formats
- Display file name and size on selection
- Generate 'nameimg' hotstring for image path recall
- Add _imagePath() function for programmatic access
- Store image path in JSON capture data
```

---

## 📝 CHANGELOG Entry

```markdown
## [6.1.0] - 2025-01-28

### Added
- **Image Attachment Support** in Manual Capture dialog
  - New "Browse..." button to select image files (JPG, PNG, GIF, BMP, WEBP)
  - "Clear" button to remove selected image
  - File info display showing filename and size
  - New `nameimg` suffix hotstring copies image path to clipboard
  - New `_imagePath()` function for programmatic access
  - Image paths stored in capture JSON data for browser integration

### Changed
- Manual Capture GUI restructured with grouped image attachment section
- Improved visual feedback for image selection state (color-coded status)

### Technical
- ManualCapture.ahk module created/updated with image handling class methods
- Automatic backup created before appending new hotstrings
- JSON storage updated to include imagePath field
```

---

## 🚀 GitHub Release Notes

### ContentCapture Pro v6.1.0 - Image Attachment Support

#### What's New

**📷 Image Attachments in Manual Capture**

You can now attach images to any capture directly from the Manual Capture dialog:

- **Browse button** - Select image files with a native file picker
- **Clear button** - Remove selected image with one click
- **Visual feedback** - See filename and file size immediately after selection
- **Supported formats** - JPG, PNG, GIF, BMP, WEBP

**New Hotstring Suffix: `nameimg`**

Every capture with an attached image gets a new suffix:
- Type `captureimg` → Copies the full image path to clipboard
- Perfect for pasting into file dialogs or social media uploads

**New Function: `_imagePath()`**

Access image paths programmatically in your scripts:
```autohotkey
imgPath := mycapture_imagePath()
```

#### Installation

1. Download `ManualCapture.ahk`
2. Replace your existing Manual Capture module, or add to your project:
   ```autohotkey
   #Include ManualCapture.ahk
   ```
3. Reload ContentCapture Pro

#### Usage

1. Press `Ctrl+Alt+M` to open Manual Capture
2. Fill in your capture details as usual
3. Click **Browse...** in the Image Attachment section
4. Select your image file
5. Click **Save**

After saving, use these hotstrings:
| Suffix | Action |
|--------|--------|
| `name` | Paste full content |
| `namego` | Open URL in browser |
| `namesh` | Paste short version (300 char) |
| `nameimg` | Copy image path |
| `nameem` | Open in Outlook email |
| `namem` | Copy and show in MsgBox |

#### Full Changelog

See [CHANGELOG.md](CHANGELOG.md) for complete version history.

---

## 📖 README Updates

Add to your README.md under Features or Usage section:

```markdown
### Image Attachments

Attach images to any capture using the Manual Capture dialog (`Ctrl+Alt+M`):

1. Click **Browse...** to select an image file
2. Supported formats: JPG, PNG, GIF, BMP, WEBP
3. Image path is saved with your capture data

**Recall image path:**
| Hotstring | Result |
|-----------|--------|
| `nameimg` | Copies full image path to clipboard |

**Programmatic access:**
```autohotkey
; Get image path for a capture
imgPath := mycapture_imagePath()

; Use in social media sharing
if (mycapture_imagePath()) {
    ; Image exists, include in share
}
```

**Use Cases:**
- Attach screenshots to bug reports
- Include infographics with political content shares
- Associate memes with commentary captures
- Store image evidence with research notes
```

---

## 🔧 Files Changed

| File | Change Type | Description |
|------|-------------|-------------|
| `ManualCapture.ahk` | Modified/New | Added image attachment UI and logic |
| `CHANGELOG.md` | Updated | Added v6.1.0 entry |
| `README.md` | Updated | Added image attachment documentation |

---

## ✅ Pre-Release Checklist

- [ ] ManualCapture.ahk tested with image selection
- [ ] All supported formats verified (JPG, PNG, GIF, BMP, WEBP)
- [ ] Hotstring generation confirmed with `nameimg` suffix
- [ ] JSON storage verified with imagePath field
- [ ] Backup creation confirmed before file append
- [ ] README updated
- [ ] CHANGELOG updated
- [ ] Version number updated in main script
- [ ] Git commit with proper message
- [ ] GitHub release created with notes

---

## 🏷️ Git Commands

```bash
# Stage changes
git add ManualCapture.ahk CHANGELOG.md README.md

# Commit with message
git commit -m "feat: Add image attachment support to Manual Capture GUI

- Add Browse/Clear buttons for image selection
- Support JPG, PNG, GIF, BMP, WEBP formats
- Display file name and size on selection
- Generate 'nameimg' hotstring for image path recall
- Add _imagePath() function for programmatic access
- Store image path in JSON capture data"

# Tag the release
git tag -a v6.1.0 -m "Version 6.1.0 - Image Attachment Support"

# Push with tags
git push origin main --tags
```

---

## 📣 Social Media Announcement

**For AutoHotkey Forums / X / Bluesky:**

```
ContentCapture Pro v6.1.0 released! 📷

New: Attach images to your captures
- Browse/select image files directly in Manual Capture
- New 'nameimg' suffix copies image path instantly
- Perfect for social media workflows

Free & open source: github.com/smogmanus1/ContentCapture-Pro

#AutoHotkey #Productivity #OpenSource
```

---

*Generated for ContentCapture Pro by Claude*
