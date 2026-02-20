; =============================================================================
; clipw() — Redesigned Clipboard Paste Function for AHK v1
; =============================================================================
;
; ROOT CAUSE OF "SECOND HOTSTRING DOESN'T FIRE":
;
;   AutoHotkey's SendInput (used when SendMode Input is set) DISABLES the
;   keyboard hook while it's running. The hotstring recognizer depends on
;   the keyboard hook. So when clipw() does "Send ^v" followed by
;   "Send {enter}", those keystrokes bypass the hotstring recognizer
;   entirely. The recognizer's internal buffer is left in a dirty state
;   from the FIRST hotstring's trigger text. When you type the second
;   hotstring, the buffer still contains remnants from the first, so the
;   match fails and the second hotstring never fires.
;
;   Source: AutoHotkey documentation and community confirmation:
;   "Send/SendInput automatically disable the script's keyboard hook
;    while they're running. The same is true of the hotstring recognizer,
;    since its reset is triggered by the keyboard hook."
;
; THE FIX:
;   1. Use SendEvent for the paste (^v) instead of SendInput. SendEvent
;      does NOT suppress the keyboard hook, so the recognizer can properly
;      track what's happening.
;   2. Call Hotstring("Reset") after every paste to explicitly clear the
;      recognizer buffer and give the next hotstring a clean slate.
;   3. Do NOT send {Enter} — user controls when to submit.
;   4. Save/restore clipboard so the user's clipboard isn't destroyed.
;   5. Robust error handling with retry logic and user feedback.
;
; INSTALLATION (2 changes):
;
;   CHANGE 1: Add this line near the top of gramshare.ahk (and sharejason.ahk)
;   right after "SendMode Input" and BEFORE any hotstrings:
;
;       #Hotstring Z
;
;   The Z option tells AHK to reset the hotstring recognizer after EVERY
;   hotstring fires. Belt-and-suspenders with the Hotstring("Reset") call.
;
;   CHANGE 2: Replace the old clipw() function (lines 42-76 in gramshare.ahk)
;   with the clipw() function below.
;
; NOTHING ELSE CHANGES. All ~1,977 hotstrings in gramshare.ahk and all
; ~3,799 in sharejason.ahk call clipw() exactly the same way:
;
;   ::myhotstring::
;   stline =
;   (
;   My content here
;   )
;   clipw()
;   return
;
; That pattern is unchanged. This is a pure drop-in replacement.
; =============================================================================

clipw() {
    global stline

    ; --- Validate: Make sure we actually have content ---
    if (stline = "") {
        TrayTip, clipw(), No content to paste - stline is empty, 3, 2
        Hotstring("Reset")
        return
    }

    ; --- Save the user's original clipboard (ALL formats) ---
    clipSaved := ClipboardAll

    ; --- Clear clipboard ---
    clipboard :=
    Sleep, 50

    ; --- Set clipboard to our content ---
    clipboard := stline

    ; --- Wait for clipboard to be ready (with retry) ---
    clipReady := false
    Loop, 3
    {
        ClipWait, 2
        if (!ErrorLevel)
        {
            clipReady := true
            break
        }
        ; Retry: clear and set again
        clipboard :=
        Sleep, 50
        clipboard := stline
    }

    if (!clipReady)
    {
        TrayTip, clipw(), Clipboard failed after 3 retries, 5, 3
        clipboard := clipSaved
        clipSaved :=
        Hotstring("Reset")
        return
    }

    ; --- Paste using SendEvent (NOT SendInput) ---
    ; SendEvent does not suppress the keyboard hook, which means the
    ; hotstring recognizer stays active and can properly reset after
    ; the paste operation completes.
    SendEvent, ^v

    ; --- Dynamic delay based on content length ---
    ; Gives the browser time to process the paste (especially Facebook
    ; which renders link previews and processes rich text).
    contentLen := StrLen(stline)
    if (contentLen > 2000)
        Sleep, 1200
    else if (contentLen > 500)
        Sleep, 800
    else
        Sleep, 500

    ; --- Restore the user's clipboard ---
    clipboard := clipSaved
    clipSaved :=

    ; --- Clear stline to prevent stale data ---
    stline :=

    ; --- CRITICAL: Reset the hotstring recognizer ---
    ; This clears the internal buffer so the next hotstring you type
    ; will be recognized from a clean slate. Without this, the buffer
    ; may contain leftover characters from the trigger text, the
    ; SendEvent keystrokes, or other artifacts that prevent the next
    ; hotstring from matching.
    Hotstring("Reset")
}
