# ContentCapture Pro - Development Roadmap

**Last Updated:** February 1, 2026  
**Current Version:** 6.2.1

This document tracks potential features and improvements for future versions. Items are prioritized by user value and implementation risk.

---

## ✅ Completed (v6.2.1)

- [x] Centralized clipboard architecture (CC_Clipboard.ahk)
- [x] Fixed stale clipboard bug (19 operations)
- [x] Removed legacy unused files (ManualCapture.ahk, ManualCaptureImageGUI.ahk)

---

## 🎯 High Priority (v6.3)

### Consolidate Repetitive Hotstring Handlers
**Effort:** Low | **Risk:** Low | **Value:** Maintenance

The functions `CC_HotstringTitle`, `CC_HotstringURL`, `CC_HotstringBody`, etc. share 90% identical code. Consolidating into a single generic handler would:
- Reduce code by ~100 lines
- Make future changes easier
- Reduce chance of inconsistent behavior

```ahk
; Current: 6 separate functions
CC_HotstringTitle(name, *)
CC_HotstringURL(name, *)
CC_HotstringBody(name, *)
; ... etc

; Proposed: 1 generic function
CC_HotstringPasteField(name, fieldName, fallback := "")
```

---

### Configurable Timing Constants
**Effort:** Low | **Risk:** Low | **Value:** Power Users

Move clipboard timing values to config.ini so users on slower machines can adjust without editing code:

```ini
[Clipboard]
ClearDelay=50
PasteBaseDelay=100
PasteMaxDelay=300
WaitTimeout=2
```

---

### Capture Tags/Categories
**Effort:** Medium | **Risk:** Low | **Value:** High for heavy users

Add optional tags to captures for better organization:

```
[capture]
name=recipe
tags=cooking,favorites
url=...
```

Browser interface would allow filtering by tag. Especially valuable for users with 1000+ captures.

---

## 🔶 Medium Priority (v6.4+)

### Hotstring Conflict Detection
**Effort:** Medium | **Risk:** Low | **Value:** New Users

Warn users during capture creation if their name conflicts with existing captures:
- `test` vs `testing` (prefix conflict)
- `recipe` vs `recipe` (duplicate)

Show warning but allow override for advanced users who understand the implications.

---

### Import from JSON
**Effort:** Medium | **Risk:** Medium | **Value:** Medium

CC_ShareModule can export to JSON but there's no import. Adding import would enable:
- Sharing captures between users
- Restoring from JSON backups
- Migrating between machines

Need careful handling of:
- Duplicate name conflicts
- Image path resolution
- Data validation

---

### Backup Versioning
**Effort:** Low | **Risk:** Low | **Value:** Data Safety

Instead of overwriting single backup, keep rolling backups:

```
backups/
  captures-2026-02-01.dat
  captures-2026-01-31.dat
  captures-2026-01-30.dat
```

Auto-delete backups older than 30 days or keep last N backups.

---

### Suffix Enable/Disable GUI
**Effort:** Medium | **Risk:** Low | **Value:** Customization

Let users enable/disable specific suffix groups:

```
☑ Social Media (fb, tw, bsky, li, mast)
☑ AI Tools (gpt, claude, pplx, ollama)
☐ Research (wiki, scholar, arxiv)
☑ Email (em, oe, oi)
```

Reduces generated hotstrings for users who don't use certain features.

---

## 🔷 Low Priority / Future (v7.0)

### Dynamic Hotstring Handler
**Effort:** High | **Risk:** High | **Value:** Performance

Replace generated hotstrings with true dynamic handling:

```ahk
; Instead of 100,000+ lines of:
::recipe ::
::recipet::
::recipeurl::
; ... for every capture

; Single dynamic handler:
Hotstring(":*?::", DynamicHandler)
```

**Pros:**
- ContentCapture_Generated.ahk goes from 20,000+ lines to ~500
- Faster script load time
- Instant hotstring updates (no regeneration needed)

**Cons:**
- Major architectural change
- Risk of breaking existing behavior
- Needs extensive testing

**Recommendation:** Only pursue if users report performance issues with large capture counts.

---

### Search Within Capture Content
**Effort:** Medium | **Risk:** Low | **Value:** Medium

Browser currently searches capture names. Add option to search within body/content text.

Would require indexing for performance with large datasets.

---

### Cloud Sync
**Effort:** High | **Risk:** High | **Value:** Multi-device users

Sync captures across machines via:
- Dropbox/OneDrive/Google Drive folder
- Or dedicated sync service

**Complications:**
- Conflict resolution
- Image sync
- Privacy concerns

**Recommendation:** Low priority. Users can manually sync their data folder via cloud storage.

---

## 🚫 Decided Against

### SQLite Database
**Reason:** Adds external dependency, complexity. Current .dat format is simple, portable, human-readable, and works fine even with 4,800+ captures. Would only reconsider if users report performance issues.

### Web Interface
**Reason:** Scope creep. ContentCapture Pro is a desktop productivity tool. A web interface would require a server component, authentication, etc. Not aligned with the tool's purpose.

### Auto-Update System
**Reason:** Security/trust concerns. Users should consciously decide to update. GitHub releases provide clear versioning and changelogs.

---

## 📝 Notes

- **Philosophy:** Perfection over speed. Features should be polished before release.
- **Compatibility:** All changes must maintain backward compatibility with existing captures.dat
- **Testing:** Major changes should be tested in Hyper-V VMs before release
- **Community:** Feature requests from GitHub issues should be added to this roadmap

---

## 💡 How to Suggest Features

1. Open an issue on GitHub: https://github.com/smogmanus1/ContentCapture-Pro/issues
2. Use the label `enhancement`
3. Describe the use case, not just the feature

---

*This roadmap is a living document and will be updated as priorities evolve.*
