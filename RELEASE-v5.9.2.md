# ContentCapture Pro v5.9.2 Release Notes

## 🖼️ Multi-Image Social Media Sharing

This release adds comprehensive image attachment and sharing support across all social media platforms.

---

## New Features

### Image Suffixes

Share your captures with attached images using these new suffixes:

| Suffix | Action | Example |
|--------|--------|---------|
| `img` | Copy image to clipboard | `mypostimg` + space |
| `imgo` | Open image in default viewer | `mypostimgo` + space |
| `fbi` | Facebook + image(s) | `mypostfbi` + space |
| `xi` | Twitter/X + image(s) | `mypostxi` + space |
| `bsi` | Bluesky + image(s) | `mypostbsi` + space |
| `lii` | LinkedIn + image(s) | `mypostlii` + space |
| `mti` | Mastodon + image(s) | `mypostmti` + space |
| `emi` | Email with image attachment(s) | `mypostemi` + space |

### Multi-Image Support

- Attach **multiple images** to a single capture
- System respects platform limits automatically:
  - Facebook posts: up to 10 images
  - Twitter/X: up to 4 images
  - Bluesky: up to 4 images
  - LinkedIn: up to 9 images
  - Mastodon: up to 4 images

### Guided Sharing Workflow

When sharing with images, you get a guided workflow:
1. Choose image-first or text-first order
2. **Ctrl+Alt+V** pastes pending text after image upload
3. **Ctrl+Alt+I** cycles through additional images

---

## New Files

| File | Description |
|------|-------------|
| `ImageDatabase.ahk` | Manages multiple images per capture |
| `ImageSharing.ahk` | Platform-specific image sharing logic |
| `IMAGE_SHARING_GUIDE.md` | Complete usage documentation |

---

## Updated Files

- **DynamicSuffixHandler.ahk** - Added image suffix routing
- **ContentCapture-Pro.ahk** - Updated #Include order

---

## Installation

### New Users
Run `install.bat` or follow instructions in `QUICKSTART.md`

### Existing Users

1. Download the new/updated files
2. Update your `#Include` section in `ContentCapture-Pro.ahk`:

```autohotkey
#Include ImageCapture.ahk
#Include ImageClipboard.ahk
#Include ImageDatabase.ahk      ; NEW
#Include ImageSharing.ahk       ; NEW
#Include DynamicSuffixHandler.ahk
#Include SocialShare.ahk
#Include ResearchTools.ahk
#Include CC_ShareModule.ahk
#Include CC_HoverPreview.ahk
```

3. Reload the script (Ctrl+Alt+R)

---

## Attaching Images to Captures

### Method 1: Edit Dialog
1. Open a capture with `vi` suffix (e.g., `mypostvi`)
2. Click "Attach Doc..." or use the Image section
3. Select your image file(s)
4. Save

### Method 2: images.dat
Edit `images.dat` directly. Format:
```
capturename|image1.jpg|image2.png|image3.jpg
```

Example:
```
mypost|protest-sign.jpg|crowd-photo.png
anotherpost|infographic.jpg
```

---

## Usage Examples

```
mypostimg     → Copies attached image to clipboard
mypostfbi     → Opens Facebook sharing workflow with image
mypostxi      → Opens Twitter with image ready to paste
mypostemi     → Creates Outlook email with image attached
```

---

## Full Suffix Reference

See `SUFFIX-REFERENCE.md` for the complete list of all available suffixes.

---

## Bug Fixes

- Fixed function naming conflict with `EncodeURIComponent`
- Fixed #Include order dependency issues
- Removed auto-load that ran before BaseDir was set

---

## Contributors

Thanks to the AutoHotkey community for feedback and testing!

---

**Full Changelog**: v5.9.1...v5.9.2
