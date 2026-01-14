; ContentCapture Pro - Social Media / Forum Posts
; Add these hotstrings to your personal hotstrings file

; ==============================================================================
; FULL POST - For forums, Reddit, Facebook groups, etc.
; ==============================================================================
::contcap:: {
    text := "
(
ContentCapture Pro - Capture Any Webpage, Recall It Instantly
https://github.com/smogmanus1/ContentCapture-Pro

I kept losing recipes, repair guides, and guitar tabs buried in bookmarks I never revisited. So I built a tool that lets me capture any webpage and recall it by typing a short name.

HOW IT WORKS:
1. Find a page worth keeping
2. Press Ctrl+Alt+G
3. Name it something memorable (like "brisket" or "carbfix")
4. Done

Now anywhere in Windows, type ::brisket:: and the full content pastes instantly. Type ::brisketgo:: to open the URL. Type ::brisketrd:: to read it in a popup.

WHY THIS BEATS BOOKMARKS:
• You name things the way YOUR brain works
• Search 1000+ captures in under 3 seconds (Ctrl+Alt+B)
• Highlight text before capturing - it saves your selection
• Add personal notes and tags for organization
• Auto-backup to cloud or USB - survives computer death
• Share to Facebook, Twitter/X, Bluesky with character limit warnings

I've saved almost 5,000 pages - recipes, repair manuals, code docs, articles, tutorials. Finding any of them takes seconds, not minutes of digging through browser history.

Free, open source, AutoHotkey v2.

Built with assistance from Claude AI. Credits to the AutoHotkey community - Joe Glines, Isaias Baez, Jack Dunning, and Antonio Bueno for techniques that made this possible.
)"
    A_Clipboard := text
    Send("^v")
}

; ==============================================================================
; SHORT POST - For Twitter/X, quick shares
; ==============================================================================
::contcapsh:: {
    text := "
(
I got tired of losing useful webpages in bookmark graveyards.

Built ContentCapture Pro - press Ctrl+Alt+G on any page, name it, then type that name anywhere to instantly paste the content.

5,000 captures. Find any in 3 seconds.

Free, open source, AHK v2.
https://github.com/smogmanus1/ContentCapture-Pro
)"
    A_Clipboard := text
    Send("^v")
}

; ==============================================================================
; TECHNICAL POST - For AutoHotkey forums
; ==============================================================================
::contcapahk:: {
    text := "
(
ContentCapture Pro v5.2 - Web Content Capture & Hotstring Recall System
https://github.com/smogmanus1/ContentCapture-Pro

An AutoHotkey v2 application for capturing web content and generating dynamic hotstrings for instant recall.

FEATURES:
• Ctrl+Alt+G captures URL, title, and highlighted text from any browser
• Dynamic suffix system: ::name:: pastes, ::namego:: opens URL, ::namevi:: edits, ::namefb/x/bs/li/mt:: shares to social platforms
• Character limit detection for social media with auto-formatting
• Tag system, favorites, full-text search
• Auto-backup with cloud/USB detection
• Plain-text data storage (easy to edit/migrate)
• Modular architecture - main app + DynamicSuffixHandler + generated hotstrings

TECHNICAL NOTES:
• Uses Acc library for browser URL/title capture
• COM integration for Outlook email
• Map-based data structure with JSON-style text storage
• All functions prefixed CC_ to avoid conflicts when #Included

Credits to Antonio Bueno for browser capture concepts, Joe Glines and Isaias Baez at The Automator, and Jack Dunning for educational resources.

Feedback welcome!
)"
    A_Clipboard := text
    Send("^v")
}

; ==============================================================================
; GITHUB LINK ONLY
; ==============================================================================
::ghccp:: {
    A_Clipboard := "https://github.com/smogmanus1/ContentCapture-Pro"
    Send("^v")
}
