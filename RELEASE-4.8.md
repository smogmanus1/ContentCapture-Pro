# ContentCapture Pro v4.8

**Release Date:** 2025-12-27

## Bug Fix

### Restore Browser Column Index Fix

Fixed a critical bug in the Restore Browser (`Ctrl+Alt+Shift+B`) that prevented entries from being restored from backup files.

**The Problem:**  
The Restore Browser ListView uses columns: `[Status, Name, Title, Date]`, where Name is column 2. However, four functions were incorrectly reading column 3 (Title) instead of column 2 (Name) when processing selected entries. This caused the restore operation to fail silently—reporting "Restored 0 entries" even when items were checked.

**Affected Functions:**
- `CC_UpdateRestorePreview()` — Preview pane showed nothing or wrong data
- `CC_PreviewBackupEntry()` — Edit dialog loaded wrong entry
- `CC_DeleteFromBackup()` — Delete operation failed to find entries
- `CC_RestoreSelectedEntries()` — Restore reported 0 entries restored

**The Fix:**  
Changed `listView.GetText(row, 3)` to `listView.GetText(row, 2)` in all four functions (lines 4099, 4152, 4597, 4685).

## Upgrade Instructions

1. Replace `ContentCapture-Pro.ahk` with the new version
2. Reload the script (`Ctrl+Alt+L`)

No changes to your `captures.dat`, `capturesbackup.dat`, or `config.ini` files are required.

## Full Changelog

```
Fixed: Restore Browser now correctly reads hotstring names from column 2
Fixed: Preview pane updates properly when selecting backup entries  
Fixed: "Edit Selected" loads the correct entry data
Fixed: "Delete" removes the correct entries from backup
Fixed: "Restore" actually restores checked entries to working file
```
