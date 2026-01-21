; ==============================================================================
; ContentCapture Pro - Hover Preview Module v1.3
; ==============================================================================
; Shows a tooltip preview when hovering over captures in the Browser ListView
; ==============================================================================

class CC_HoverPreview {
    
    static HoverDelay := 400
    static MaxBodyChars := 300
    static MaxTitleChars := 60
    
    static IsActive := false
    static CurrentRow := 0
    static HoverStartTime := 0
    static TooltipVisible := false
    static BrowserGui := ""
    static ListViewCtrl := ""
    static CheckTimer := 0
    
    static Initialize(browserGui, listView) {
        this.BrowserGui := browserGui
        this.ListViewCtrl := listView
        this.IsActive := true
        this.CurrentRow := 0
        this.TooltipVisible := false
        this.HoverStartTime := A_TickCount
        
        this.CheckTimer := ObjBindMethod(this, "CheckHover")
        SetTimer(this.CheckTimer, 100)
        
        browserGui.OnEvent("Close", (*) => this.Cleanup())
    }
    
    static Cleanup() {
        this.IsActive := false
        if this.CheckTimer {
            SetTimer(this.CheckTimer, 0)
            this.CheckTimer := 0
        }
        this.HideTooltip()
        this.BrowserGui := ""
        this.ListViewCtrl := ""
    }
    
    static CheckHover() {
        if !this.IsActive
            return
        
        if !this.BrowserGui || !this.ListViewCtrl
            return
        
        try {
            if !WinExist("ahk_id " this.BrowserGui.Hwnd) {
                this.Cleanup()
                return
            }
        } catch {
            this.Cleanup()
            return
        }
        
        ; Force screen coordinates
        CoordMode("Mouse", "Screen")
        MouseGetPos(&mouseX, &mouseY, &winHwnd, &ctrlHwnd, 2)
        
        try {
            lvHwnd := this.ListViewCtrl.Hwnd
        } catch {
            return
        }
        
        if (ctrlHwnd != lvHwnd) {
            this.ResetHover()
            return
        }
        
        row := this.GetRowUnderMouse(mouseX, mouseY)
        
        if (row = 0) {
            this.ResetHover()
            return
        }
        
        if (row != this.CurrentRow) {
            this.CurrentRow := row
            this.HoverStartTime := A_TickCount
            this.HideTooltip()
            return
        }
        
        if (!this.TooltipVisible && (A_TickCount - this.HoverStartTime) >= this.HoverDelay) {
            this.ShowTooltipForRow(row)
        }
    }
    
    static ResetHover() {
        if (this.CurrentRow != 0 || this.TooltipVisible) {
            this.CurrentRow := 0
            this.HoverStartTime := 0
            this.HideTooltip()
        }
    }
    
    static GetRowUnderMouse(screenX, screenY) {
        try {
            lvHwnd := this.ListViewCtrl.Hwnd
            
            ; Get ListView screen rectangle
            rect := Buffer(16, 0)
            DllCall("GetWindowRect", "Ptr", lvHwnd, "Ptr", rect)
            lvLeft := NumGet(rect, 0, "Int")
            lvTop := NumGet(rect, 4, "Int")
            
            ; Calculate client coordinates
            clientX := screenX - lvLeft
            clientY := screenY - lvTop
            
            if (clientX < 0 || clientY < 0)
                return 0
            
            hitTest := Buffer(24, 0)
            NumPut("Int", clientX, hitTest, 0)
            NumPut("Int", clientY, hitTest, 4)
            
            result := SendMessage(0x1012, 0, hitTest, lvHwnd)
            
            if (result = -1 || result = 0xFFFFFFFF)
                return 0
            
            return result + 1
        } catch {
            return 0
        }
    }
    
    static ShowTooltipForRow(row) {
        global CaptureData
        
        if !this.ListViewCtrl
            return
        
        try {
            capName := this.ListViewCtrl.GetText(row, 3)
        } catch {
            return
        }
        
        if (capName = "" || !CaptureData.Has(capName))
            return
        
        data := CaptureData[capName]
        tipText := this.BuildTooltipContent(capName, data)
        
        CoordMode("ToolTip", "Screen")
        MouseGetPos(&mx, &my)
        ToolTip(tipText, mx + 15, my + 15)
        this.TooltipVisible := true
    }
    
    static BuildTooltipContent(capName, data) {
        lines := []
        
        lines.Push("📋 " capName)
        lines.Push("──────────────────────────────────────────────────")
        
        if data.Has("title") && data["title"] != "" {
            title := data["title"]
            if StrLen(title) > this.MaxTitleChars
                title := SubStr(title, 1, this.MaxTitleChars) "..."
            lines.Push(title)
            lines.Push("")
        }
        
        if data.Has("url") && data["url"] != "" {
            url := data["url"]
            if StrLen(url) > 55
                url := SubStr(url, 1, 55) "..."
            lines.Push("🔗 " url)
            lines.Push("")
        }
        
        if data.Has("body") && data["body"] != "" {
            body := data["body"]
            body := StrReplace(body, "`r`n", " ")
            body := StrReplace(body, "`n", " ")
            body := RegExReplace(body, "\s+", " ")
            body := Trim(body)
            
            if StrLen(body) > this.MaxBodyChars
                body := SubStr(body, 1, this.MaxBodyChars) "..."
            
            lines.Push(body)
            lines.Push("")
        }
        
        if data.Has("tags") && data["tags"] != ""
            lines.Push("🏷️ " data["tags"])
        
        statusParts := []
        if data.Has("date") && data["date"] != ""
            statusParts.Push("📅 " data["date"])
        if data.Has("favorite") && data["favorite"]
            statusParts.Push("⭐")
        if data.Has("image") && data["image"] != ""
            statusParts.Push("📷")
        if data.Has("research") && data["research"] != ""
            statusParts.Push("🔬")
        if data.Has("transcript") && data["transcript"] != ""
            statusParts.Push("📝")
        
        if statusParts.Length > 0 {
            lines.Push("──────────────────────────────────────────────────")
            statusLine := ""
            for i, part in statusParts {
                if i > 1
                    statusLine .= "  "
                statusLine .= part
            }
            lines.Push(statusLine)
        }
        
        output := ""
        for i, line in lines {
            if i > 1
                output .= "`n"
            output .= line
        }
        return output
    }
    
    static HideTooltip() {
        if this.TooltipVisible {
            ToolTip()
            this.TooltipVisible := false
        }
    }
}
