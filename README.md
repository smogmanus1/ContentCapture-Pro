# ContentCapture Pro v6.0.0

**Professional Content Capture & Sharing System for Windows**

Capture web content with a single hotkey, save it with a memorable name, and instantly recall it using hotstrings. Share to social media, email, or research tools with simple suffix commands.

![AutoHotkey](https://img.shields.io/badge/AutoHotkey-v2.0+-green)
![License](https://img.shields.io/badge/License-MIT-blue)
![Version](https://img.shields.io/badge/Version-6.0.0-orange)

---

## ✨ Features

- **One-Key Capture**: Press `Ctrl+Alt+G` to capture URL, title, and highlighted text
- **Instant Recall**: Type your capture name + suffix to paste content anywhere
- **22 Suffix Variants**: Each capture generates 22 automatic hotstrings
- **Social Media Integration**: Share directly to Facebook, Twitter/X, Bluesky, LinkedIn, Mastodon
- **Image Support**: Attach and share images with your captures
- **Research Tools**: YouTube transcripts, fact-checking, media bias analysis
- **Email Integration**: Outlook compose with attachments
- **Backup & Restore**: Import/export captures with date management

---

## 🚀 Quick Start

1. **Install [AutoHotkey v2.0+](https://www.autohotkey.com/)**
2. **Download** and extract this release
3. **Run** `ContentCapture.ahk`
4. **Capture**: Press `Ctrl+Alt+G` on any webpage
5. **Use**: Type your capture name to paste content

---

## 📋 Complete Suffix Reference

### Core Content
| Suffix | Action | Example |
|--------|--------|---------|
| *(none)* | Paste full content | `myarticle` |
| `t` | Title only | `myarticlet` |
| `url` | URL only | `myarticleurl` |
| `body` | Body text only | `myarticlebody` |
| `sh` | Short version | `myarticlesh` |
| `cp` | Copy to clipboard (no paste) | `myarticlecp` |

### View & Edit
| Suffix | Action | Example |
|--------|--------|---------|
| `?` | Show action menu | `myarticle?` |
| `rd` | Read in popup | `myarticlerd` |
| `vi` | View/Edit GUI | `myarticlevi` |
| `go` | Open URL in browser | `myarticlego` |

### Email
| Suffix | Action | Example |
|--------|--------|---------|
| `em` | New Outlook email | `myarticleem` |
| `oi` | Insert at cursor in Outlook | `myarticleoi` |
| `ed` | Email with document | `myarticleed` |
| `emi` | Email with image(s) | `myarticleemi` |

### Social Media (Text)
| Suffix | Action | Example |
|--------|--------|---------|
| `fb` | Share to Facebook | `myarticlefb` |
| `x` | Share to Twitter/X | `myarticlex` |
| `bs` | Share to Bluesky | `myarticlebs` |
| `li` | Share to LinkedIn | `myarticleli` |
| `mt` | Share to Mastodon | `myarticlemt` |

### Images
| Suffix | Action | Example |
|--------|--------|---------|
| `i` | Paste image path | `myarticlei` |
| `img` | Copy image to clipboard | `myarticleimg` |
| `imgo` | Open image in viewer | `myarticleimgo` |
| `ti` | Title + image path | `myarticleti` |

### Social Media + Images
| Suffix | Action | Example |
|--------|--------|---------|
| `fbi` | Facebook + image(s) | `myarticlefbi` |
| `xi` | Twitter/X + image(s) | `myarticlexi` |
| `bsi` | Bluesky + image(s) | `myarticlebsi` |
| `lii` | LinkedIn + image(s) | `myarticlelii` |
| `mti` | Mastodon + image(s) | `myarticlemti` |

---

## ⌨️ Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| `Ctrl+Alt+G` | Capture current page |
| `Ctrl+Alt+B` | Open Capture Browser |
| `Ctrl+Alt+M` | Manual capture (no browser needed) |
| `Ctrl+Alt+L` | Reload script |

### In Capture Browser
| Shortcut | Action |
|----------|--------|
| `Ctrl+N` | New manual capture |
| `Ctrl+E` | Edit selected |
| `Ctrl+I` | Import from file |
| `Ctrl+L` | Copy link |
| `Ctrl+P` | Preview |
| `F5` | Refresh list |
| `Delete` | Delete selected |

---

## 📁 File Structure

```
ContentCapture-Pro-v6.0.0/
├── ContentCapture.ahk          # Launcher (run this)
├── ContentCapture-Pro.ahk      # Main application
├── DynamicSuffixHandler.ahk    # Suffix routing system
├── SocialShare.ahk             # Social media sharing
├── ResearchTools.ahk           # Research & fact-checking
├── ImageCapture.ahk            # Image attachment system
├── ImageClipboard.ahk          # GDI+ clipboard operations
├── ImageDatabase.ahk           # Multi-image management
├── ImageSharing.ahk            # Social media + images
├── CC_HoverPreview.ahk         # Tooltip previews
├── CC_ShareModule.ahk          # Export/share captures
├── README.md                   # This file
├── CHANGELOG.md                # Version history
└── LICENSE                     # MIT License
```

---

## 💾 Data Files (Auto-Created)

| File | Purpose |
|------|---------|
| `captures.dat` | Your captures database |
| `capturesbackup.dat` | Automatic backup |
| `capturesarchive.dat` | Archived captures |
| `images.dat` | Image associations |
| `ContentCapture_Generated.ahk` | Generated hotstrings |
| `/images/` | Stored image files |

---

## 🔧 Requirements

- Windows 10/11
- [AutoHotkey v2.0+](https://www.autohotkey.com/)
- Microsoft Outlook (for email features)
- Web browser (Chrome, Firefox, Edge, etc.)

---

## 📝 Credits

**Created by:** Brad  
**Website:** [crisisoftruth.org](https://crisisoftruth.org)  
**GitHub:** [github.com/smogmanus1/ContentCapture-Pro](https://github.com/smogmanus1/ContentCapture-Pro)

**Built with assistance from Claude AI**

### Special Thanks
- Joe Glines ([the-Automator.com](https://the-automator.com))
- Isaias Baez (RaptorX)
- Jack Dunning
- The AutoHotkey Community

---

## 📄 License

MIT License - See [LICENSE](LICENSE) file for details.

---

## 🐛 Issues & Contributions

Found a bug? Have a feature request?  
[Open an issue on GitHub](https://github.com/smogmanus1/ContentCapture-Pro/issues)

---

**Happy Capturing!** 🎯
