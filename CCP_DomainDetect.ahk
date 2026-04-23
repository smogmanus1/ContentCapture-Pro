; CCP_DomainDetect.ahk
; ContentCapture Pro - Browser Domain Detection
; Detects which social media platform is active in any browser
; and maps it to the correct images.db key suffix
; AHK v2 - UTF-8 with BOM

#Requires AutoHotkey v2.0

; All supported browsers - add new ones here freely
global CCP_BROWSERS := [
    "librewolf.exe",  "firefox.exe",   "chrome.exe",
    "msedge.exe",     "brave.exe",     "opera.exe",
    "vivaldi.exe",    "waterfox.exe",  "floorp.exe",
    "thorium.exe",    "palemoon.exe",  "chromium.exe",
    "arc.exe",        "iexplore.exe",  "seamonkey.exe",
    "basilisk.exe",   "falkon.exe",    "icecat.exe"
]

; Platform name -> images.db key suffix
; "" means use the original (no variant) key
global CCP_PLATFORM_SUFFIX := Map(
    "facebook",   "",
    "twitter",    "",
    "bluesky",    "_bsky",
    "linkedin",   "_li",
    "pinterest",  "_pin",
    "mastodon",   "",
    "instagram",  "",
    "",           ""
)

; -- Detect which social platform is active in any browser ------------------
; Returns: "facebook" | "twitter" | "bluesky" | "linkedin" |
;          "pinterest" | "mastodon" | "instagram" | ""
CCP_DetectActivePlatform() {
    global CCP_BROWSERS

    ; Check active window first
    try {
        activeExe   := WinGetProcessName("A")
        activeTitle := StrLower(WinGetTitle("A"))
        if CCP_IsBrowser(activeExe) {
            p := CCP_TitleToPlatform(activeTitle)
            if p != ""
                return p
        }
    }

    ; Fall back: scan all browser windows
    for browser in CCP_BROWSERS {
        try {
            if WinExist("ahk_exe " browser) {
                title := StrLower(WinGetTitle("ahk_exe " browser))
                p := CCP_TitleToPlatform(title)
                if p != ""
                    return p
            }
        }
    }

    return ""
}

; -- Check if a process name is a known browser ----------------------------
CCP_IsBrowser(exeName) {
    global CCP_BROWSERS
    lower := StrLower(exeName)
    for b in CCP_BROWSERS
        if lower = b
            return true
    return false
}

; -- Map window title keywords to platform name ----------------------------
CCP_TitleToPlatform(titleLower) {
    ; Order matters - check more specific patterns first
    if InStr(titleLower, "facebook.com") || InStr(titleLower, "| facebook") || InStr(titleLower, "facebook -")
        return "facebook"
    if InStr(titleLower, "x.com") || InStr(titleLower, "twitter.com") || InStr(titleLower, "| twitter") || InStr(titleLower, "on x)")
        return "twitter"
    if InStr(titleLower, "bsky.app") || InStr(titleLower, "bluesky")
        return "bluesky"
    if InStr(titleLower, "linkedin.com") || InStr(titleLower, "| linkedin")
        return "linkedin"
    if InStr(titleLower, "pinterest.com") || InStr(titleLower, "| pinterest")
        return "pinterest"
    if InStr(titleLower, "mastodon") || InStr(titleLower, ".social")
        return "mastodon"
    if InStr(titleLower, "instagram.com") || InStr(titleLower, "| instagram")
        return "instagram"
    return ""
}

; -- Get DB suffix for a platform ------------------------------------------
CCP_GetPlatformSuffix(platform) {
    global CCP_PLATFORM_SUFFIX
    return CCP_PLATFORM_SUFFIX.Has(platform) ? CCP_PLATFORM_SUFFIX[platform] : ""
}

; -- Get the right DB key for a capture image on the current platform ------
; baseKey  = the imagekey stored on the capture (e.g. "weyrich-ogpage")
; platform = detected platform string (e.g. "bluesky")
; Falls back to base key if the variant is not in the DB
CCP_GetPlatformImageKey(baseKey, platform) {
    if baseKey = ""
        return ""

    suffix  := CCP_GetPlatformSuffix(platform)
    fullKey := baseKey . suffix

    ; No suffix needed for this platform
    if suffix = ""
        return baseKey

    ; Check the variant exists in images.db
    dbPath := A_ScriptDir "\images.db"
    if !FileExist(dbPath)
        return baseKey

    try {
        db     := CCP_DB_Open(dbPath)
        exists := CCP_DB_KeyExists(db, fullKey)
        CCP_DB_Close(db)
        if exists
            return fullKey
    }

    ; Variant not found - fall back to original
    return baseKey
}

; -- Convenience: detect platform and return the right image key -----------
; captureName = the capture record name
; Returns the temp file path of the decoded image, or ""
CCP_GetImageForCurrentPlatform(captureName) {
    global CaptureData
    if !CaptureData.Has(StrLower(captureName))
        return ""

    cap := CaptureData[StrLower(captureName)]
    if !cap.Has("imagekey") || cap["imagekey"] = ""
        return ""

    baseKey  := cap["imagekey"]
    platform := CCP_DetectActivePlatform()
    dbKey    := CCP_GetPlatformImageKey(baseKey, platform)

    if dbKey = ""
        return ""

    ; Decode from DB to temp file
    dbPath := A_ScriptDir "\images.db"
    if !FileExist(dbPath)
        return ""

    try {
        db  := CCP_DB_Open(dbPath)
        b64 := CCP_DB_GetImage(db, dbKey)
        CCP_DB_Close(db)
        if b64 != ""
            return IS_Base64ToTempFile(b64)
    }
    return ""
}

; ============================================================================
; PLATFORM PICKER POPUP (Option B fallback)
; Small button popup shown when no platform is detected automatically
; Returns platform string or "" if user cancels
; ============================================================================
CCP_ShowPlatformPicker() {
    result := ""

    pGui := Gui("+AlwaysOnTop +ToolWindow", "Share to which platform?")
    pGui.SetFont("s10", "Segoe UI")
    pGui.OnEvent("Close", (*) => pGui.Destroy())

    pGui.Add("Text", "x10 y10 w300 Center",
        "Platform not detected. Choose one:")

    ; Row 1
    pGui.Add("Button", "x10  y38 w90 h34", "Facebook").OnEvent("Click",
        (*) => (result := "facebook", pGui.Destroy()))
    pGui.Add("Button", "x108 y38 w90 h34", "X / Twitter").OnEvent("Click",
        (*) => (result := "twitter", pGui.Destroy()))
    pGui.Add("Button", "x206 y38 w90 h34", "Bluesky").OnEvent("Click",
        (*) => (result := "bluesky", pGui.Destroy()))

    ; Row 2
    pGui.Add("Button", "x10  y78 w90 h34", "LinkedIn").OnEvent("Click",
        (*) => (result := "linkedin", pGui.Destroy()))
    pGui.Add("Button", "x108 y78 w90 h34", "Pinterest").OnEvent("Click",
        (*) => (result := "pinterest", pGui.Destroy()))
    pGui.Add("Button", "x206 y78 w90 h34", "Mastodon").OnEvent("Click",
        (*) => (result := "mastodon", pGui.Destroy()))

    ; Cancel row
    pGui.Add("Button", "x108 y118 w90 h28", "Cancel").OnEvent("Click",
        (*) => pGui.Destroy())

    pGui.Show("w306 h158")
    WinWaitClose(pGui.Hwnd)
    return result
}

; ============================================================================
; SMART PLATFORM RESOLUTION
; Detects platform from browser, falls back to picker if not found
; Returns platform string - always returns something unless user cancels
; ============================================================================
CCP_ResolvePlatform() {
    platform := CCP_DetectActivePlatform()
    if platform = ""
        platform := CCP_ShowPlatformPicker()
    return platform
}
