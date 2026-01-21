# ContentCapture Pro - Image Sharing Quick Reference

## New Image Suffixes

| Suffix | Action | Example |
|--------|--------|---------|
| `img` | Copy attached image to clipboard | `oneenableimg` + space |
| `imgo` | Open image in default viewer | `oneenableimgo` + space |
| `fbi` | Facebook post/comment + image(s) | `oneenablefbi` + space |
| `xi` | Twitter/X + image(s) | `oneenablexi` + space |
| `bsi` | Bluesky + image(s) | `oneenablebsi` + space |
| `lii` | LinkedIn + image(s) | `oneenablelii` + space |
| `mti` | Mastodon + image(s) | `oneenablemti` + space |
| `emi` | Email with image attachment(s) | `oneenableemi` + space |

## Platform Image Limits

| Platform | Max Images |
|----------|------------|
| Facebook (post) | 10 |
| Facebook (comment) | 1 |
| Twitter/X | 4 |
| Bluesky | 4 |
| LinkedIn (post) | 9 |
| Mastodon | 4 |

## How It Works

### Method 1: Image First
1. Type `oneenablefbi` and press space
2. Dialog asks: YES = Image first, NO = Text first
3. Click YES
4. Image copied to clipboard - paste with Ctrl+V
5. After image uploads, press **Ctrl+Alt+V** for text
6. If multiple images, press **Ctrl+Alt+I** for each additional image

### Method 2: Text First
1. Type `oneenablefbi` and press space
2. Click NO for text first
3. Text copied to clipboard - paste with Ctrl+V
4. Press **Ctrl+Alt+I** to cycle through images

## Hotkeys During Image Sharing

| Hotkey | Action |
|--------|--------|
| `Ctrl+Alt+V` | Paste pending text (after image upload) |
| `Ctrl+Alt+I` | Copy next image to clipboard |

## Adding Images to Captures

### Via Edit Dialog
1. Open capture in Edit mode
2. Click "Attach Doc..." button or use Image section
3. Select image file(s)
4. Save

### Via images.dat
Edit `images.dat` directly. Format:
```
captureName|image1.jpg|image2.png|image3.jpg
```

Example:
```
oneenable|congresscensorship.jpg
dtenable3|fascism-warning.png|trump-lies.jpg
```

## File Structure

```
ContentCapture-Pro/
├── ContentCapture-Pro.ahk      # Main script
├── DynamicSuffixHandler.ahk    # Suffix routing (UPDATED)
├── ImageSharing.ahk            # NEW - Multi-image sharing
├── ImageDatabase.ahk           # NEW - Image management
├── ImageCapture.ahk            # Image GUI integration
├── ImageClipboard.ahk          # GDI+ clipboard handling
├── SocialShare.ahk             # Social media functions
├── captures.dat                # Your captures
├── images.dat                  # Image associations
└── images/                     # Image files folder
```

## Integration Steps

Add these #Include lines to ContentCapture-Pro.ahk:

```autohotkey
#Include DynamicSuffixHandler.ahk
#Include ImageCapture.ahk
#Include ImageClipboard.ahk
#Include ImageDatabase.ahk      ; NEW
#Include ImageSharing.ahk       ; NEW
#Include SocialShare.ahk
```

## Example Usage

### Capture: "oneenable" with attached image

**Paste text only:**
```
oneenable  (space)
```

**Copy just the image:**
```
oneenableimg  (space)
→ Image on clipboard, paste anywhere
```

**Share to Facebook with image:**
```
oneenablefbi  (space)
→ Prompts for image/text order
→ Guides you through upload process
```

**Share to Twitter with image:**
```
oneenablexi  (space)
→ Opens Twitter compose
→ Notifies you to add images
→ Ctrl+Alt+I cycles through images
```

**Email with image attachment:**
```
oneenableemi  (space)
→ Opens Outlook with image attached
→ Ready to send
```

## Tips

1. **Video URLs**: Put video URLs LAST in your content - this ensures the video thumbnail shows as the preview card

2. **Multiple Images**: When a capture has multiple images, you can cycle through them with Ctrl+Alt+I

3. **Platform Detection**: The system auto-detects Facebook post vs comment context and adjusts image limits

4. **Tracking Cleanup**: URLs are automatically cleaned of utm_ tracking parameters when sharing
