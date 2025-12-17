; ==============================================================================
; DynamicSuffixHandler - Dynamic Hotstring Suffix Processing
; ==============================================================================
; Version: 2.0 (for ContentCapture Pro 4.5)
; 
; This class handles the magic of suffix hotstrings. When you type ::name::,
; ::namego::, ::namevi::, etc., this handler routes to the correct function.
;
; SUPPORTED SUFFIXES:
;   (none)  - Paste content          → CC_HotstringPaste(name)
;   ?       - Show action menu       → CC_HotstringMenu(name)
;   go      - Open URL in browser    → CC_HotstringGo(name)
;   em      - Email via Outlook      → CC_HotstringEmail(name)
;   rd      - Read in popup          → CC_ShowReadWindow(name)
;   vi      - View/Edit capture      → CC_HotstringView(name)
;   fb      - Share to Facebook      → CC_HotstringFacebook(name)
;   x       - Share to Twitter/X     → CC_HotstringTwitter(name)
;   bs      - Share to Bluesky       → CC_HotstringBluesky(name)
;   li      - Share to LinkedIn      → CC_HotstringLinkedIn(name)
;   mt      - Share to Mastodon      → CC_HotstringMastodon(name)
;
; HOW IT WORKS:
;   1. Initialize() creates an InputHook that listens for :: triggers
;   2. When :: is typed, it starts buffering keystrokes
;   3. When :: is typed again, it checks if the buffer matches a capture name
;   4. If matched, it calls the appropriate CC_Hotstring* function
;   5. Suffixes are stripped and routed to their handlers
;
; ==============================================================================

class DynamicSuffixHandler {
    ; Store references to capture data
    static CaptureData := Map()
    static CaptureNames := []
    static inputHook := ""
    static isActive := false
    
    ; ===========================================================================
    ; Initialize(captureData, captureNames)
    ; ===========================================================================
    ; PURPOSE: Set up the dynamic hotstring listener
    ; PARAMETERS:
    ;   captureData - Map of capture name → capture data
    ;   captureNames - Array of all capture names
    ; ===========================================================================
    static Initialize(captureData, captureNames) {
        this.CaptureData := captureData
        this.CaptureNames := captureNames
        
        ; Only create hook once
        if (!this.isActive) {
            this.SetupInputHook()
            this.isActive := true
        }
    }
    
    ; ===========================================================================
    ; SetupInputHook()
    ; ===========================================================================
    ; PURPOSE: Create the input hook that listens for hotstring triggers
    ; ===========================================================================
    static SetupInputHook() {
        ; Create hotstring for the :: trigger
        ; Using EndChars to detect when user completes a hotstring
        
        ; We use a Hotstring approach - create hotstrings for all known names
        ; This is more reliable than InputHook for this use case
        
        ; The hotstrings are generated in ContentCapture_Generated.ahk
        ; This handler provides the routing logic
    }
    
    ; ===========================================================================
    ; ProcessHotstring(input)
    ; ===========================================================================
    ; PURPOSE: Route a hotstring to the appropriate handler
    ; PARAMETERS:
    ;   input - The typed text between :: markers (e.g., "recipego")
    ; ===========================================================================
    static ProcessHotstring(input) {
        input := StrLower(Trim(input))
        
        ; Check for suffix patterns (order matters - check longer suffixes first)
        suffixes := [
            {suffix: "go", handler: "CC_HotstringGo"},
            {suffix: "em", handler: "CC_HotstringEmail"},
            {suffix: "rd", handler: "CC_ShowReadWindow"},
            {suffix: "vi", handler: "CC_HotstringView"},
            {suffix: "fb", handler: "CC_HotstringFacebook"},
            {suffix: "bs", handler: "CC_HotstringBluesky"},
            {suffix: "li", handler: "CC_HotstringLinkedIn"},
            {suffix: "mt", handler: "CC_HotstringMastodon"},
            {suffix: "x", handler: "CC_HotstringTwitter"},
            {suffix: "?", handler: "CC_HotstringMenu"}
        ]
        
        ; Check each suffix
        for item in suffixes {
            if (SubStr(input, -StrLen(item.suffix)) = item.suffix) {
                baseName := SubStr(input, 1, StrLen(input) - StrLen(item.suffix))
                if (this.CaptureData.Has(baseName)) {
                    ; Get original case name
                    originalName := this.CaptureData[baseName]["name"]
                    ; Call the handler
                    %item.handler%(originalName)
                    return true
                }
            }
        }
        
        ; No suffix - check for base name (plain paste)
        if (this.CaptureData.Has(input)) {
            originalName := this.CaptureData[input]["name"]
            CC_HotstringPaste(originalName)
            return true
        }
        
        return false
    }
    
    ; ===========================================================================
    ; HasCapture(name)
    ; ===========================================================================
    ; PURPOSE: Check if a capture exists
    ; ===========================================================================
    static HasCapture(name) {
        return this.CaptureData.Has(StrLower(name))
    }
    
    ; ===========================================================================
    ; GetCapture(name)
    ; ===========================================================================
    ; PURPOSE: Get capture data by name
    ; ===========================================================================
    static GetCapture(name) {
        name := StrLower(name)
        if (this.CaptureData.Has(name))
            return this.CaptureData[name]
        return ""
    }
    
    ; ===========================================================================
    ; RefreshNames()
    ; ===========================================================================
    ; PURPOSE: Update the names list (called after adding/removing captures)
    ; ===========================================================================
    static RefreshNames(captureData, captureNames) {
        this.CaptureData := captureData
        this.CaptureNames := captureNames
    }
}
