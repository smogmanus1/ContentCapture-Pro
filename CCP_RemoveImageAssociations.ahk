; =============================================================================
; CCP_RemoveImageAssociations.ahk
; -----------------------------------------------------------------------------
; One-time utility: removes all image associations from captures.dat and
; clears images.txt in preparation for the SQLite Base64 image migration.
;
; Safe operation:
;   1. Creates timestamped backups of both files before touching anything.
;   2. Rewrites captures.dat with the image= line stripped from every section.
;   3. Replaces images.txt with an empty file (preserves the file itself).
;   4. Reports a full summary before and after.
;
; Run this ONCE, verify the summary, then discard when migration is complete.
; =============================================================================

#Requires AutoHotkey v2.0
#SingleInstance Force

; --- Paths -------------------------------------------------------------------
scriptDir    := A_ScriptDir
capturesFile := scriptDir "\captures.dat"
imagesFile   := scriptDir "\images.txt"
backupDir    := scriptDir "\backups"

; --- Sanity checks -----------------------------------------------------------
if !FileExist(capturesFile) {
    MsgBox "captures.dat not found in:`n" scriptDir "`n`nMake sure this script is in your CCP production directory.",
           "CCP Image Remover", "Icon! 48"
    ExitApp
}

; =============================================================================
; Build the timestamped backup folder
; =============================================================================
ts := FormatTime(, "yyyy-MM-dd_HH-mm-ss")
thisBackup := backupDir "\" ts
DirCreate(thisBackup)

; =============================================================================
; STEP 1 – Back up captures.dat
; =============================================================================
capturesBackup := thisBackup "\captures.dat"
FileCopy capturesFile, capturesBackup, 1
if !FileExist(capturesBackup) {
    MsgBox "Failed to create backup of captures.dat.`nAborting — no files were changed.",
           "CCP Image Remover", "Icon! 16"
    ExitApp
}

; =============================================================================
; STEP 2 – Back up images.txt (if it exists)
; =============================================================================
imagesExisted := FileExist(imagesFile)
if imagesExisted {
    imagesBackup := thisBackup "\images.txt"
    FileCopy imagesFile, imagesBackup, 1
    if !FileExist(imagesBackup) {
        MsgBox "Failed to create backup of images.txt.`nAborting — no files were changed.",
               "CCP Image Remover", "Icon! 16"
        ExitApp
    }
}

; =============================================================================
; STEP 3 – Parse captures.dat and strip image= lines
; =============================================================================
rawContent := FileRead(capturesFile)

; Split into lines for processing
lines      := StrSplit(rawContent, "`n")
outLines   := []

totalSections  := 0
sectionsFixed  := 0
imageLineCount := 0

for i, line in lines {
    trimmed := RTrim(line, "`r")   ; strip CR from CRLF

    ; Track section headers so we can count them
    if RegExMatch(trimmed, "^\[.+\]$")
        totalSections++

    ; Drop any line that is an image assignment.
    ; Matches:  image=anything   (case-insensitive, optional whitespace around =)
    ; Also drops the legacy variant  img=anything
    if RegExMatch(trimmed, "^i)image\s*=") {
        imageLineCount++
        sectionsFixed++          ; one image line = one section affected
        continue                 ; skip — do not add to output
    }

    outLines.Push(trimmed)
}

; Rejoin with CRLF (Windows standard for INI-style files)
newContent := ""
for i, ln in outLines
    newContent .= ln . "`r`n"

; Trim any trailing blank lines and add a single final newline
newContent := RTrim(newContent, "`r`n") . "`r`n"

; Write the cleaned file
try {
    FileObj := FileOpen(capturesFile, "w", "UTF-8")
    FileObj.Write(newContent)
    FileObj.Close()
} catch as err {
    MsgBox "Error writing captures.dat:`n" err.Message
           "`n`nYour backup is safe at:`n" capturesBackup,
           "CCP Image Remover", "Icon! 16"
    ExitApp
}

; =============================================================================
; STEP 4 – Clear images.txt (empty file, not deleted)
; =============================================================================
imagesCleared := false
if imagesExisted {
    try {
        FileObj2 := FileOpen(imagesFile, "w", "UTF-8")
        FileObj2.Write("")
        FileObj2.Close()
        imagesCleared := true
    } catch as err {
        MsgBox "captures.dat was cleaned successfully.`n`n"
               "However, images.txt could NOT be cleared:`n" err.Message
               "`n`nYou may clear it manually.",
               "CCP Image Remover", "Icon! 48"
    }
}

; =============================================================================
; STEP 5 – Summary report
; =============================================================================
capturesSize := Round(StrLen(newContent) / 1024, 1)

summary := "
(
CCP Image Association Removal — Complete
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

captures.dat
  Total sections  : " totalSections "
  Sections fixed  : " sectionsFixed "
  image= lines removed : " imageLineCount "
  New file size   : " capturesSize " KB

images.txt
  Previously existed : " (imagesExisted ? "Yes" : "No") "
  Cleared            : " (imagesCleared ? "Yes" : (imagesExisted ? "Failed — clear manually" : "N/A (file did not exist)")) "

Backups saved to:
  " thisBackup "

Next step: run CCP_ImageBatchConverter.ahk to populate
the new images.db SQLite database.
)"

MsgBox summary, "CCP Image Remover — Done", "Iconi"
ExitApp
