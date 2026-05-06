#Requires AutoHotkey v2.0
#SingleInstance Force

; ============================================================================
; Social Media Image Resizer
; Batch-resize an image into Facebook presets via ImageMagick.
; Requires: magick.exe on PATH (https://imagemagick.org/)
; ============================================================================

class App {
    static Presets := [
        { label: "Facebook Cover  (1640 x 624)",  w: 1640, h: 624,  suffix: "fb_cover"     },
        { label: "Square Post     (1080 x 1080)", w: 1080, h: 1080, suffix: "fb_square"    },
        { label: "Vertical Post   (1080 x 1350)", w: 1080, h: 1350, suffix: "fb_vertical"  }
    ]

    static Run() {
        if !this.HasOwnProp("gui")
            this.BuildGui()
        this.gui.Show()
    }

    static BuildGui() {
        this.gui := Gui("+Resize", "Social Media Image Resizer")
        this.gui.SetFont("s10", "Segoe UI")
        this.gui.MarginX := 14, this.gui.MarginY := 14

        this.gui.Add("Text",, "Input image (drop a file or browse):")
        this.inputEdit := this.gui.Add("Edit", "w560 vInputPath")
        this.gui.Add("Button", "x+6 w90", "Browse...").OnEvent("Click", (*) => this.BrowseInput())

        this.gui.Add("Text", "xm y+12", "Output directory:")
        this.outputEdit := this.gui.Add("Edit", "w560 vOutputDir")
        this.gui.Add("Button", "x+6 w90", "Browse...").OnEvent("Click", (*) => this.BrowseOutput())

        this.gui.Add("Text", "xm y+12", "Mode:")
        this.modeCrop := this.gui.Add("Radio", "x+10 Checked", "Crop to fill (no bars)")
        this.modePad  := this.gui.Add("Radio", "x+14",         "Fit with padding")
        this.gui.Add("Text", "x+18", "Pad color:")
        this.padColor := this.gui.Add("Edit", "x+6 w80", "#d9d7b9")

        this.gui.Add("Text", "xm y+14", "Generate:")
        this.cbs := []
        for p in App.Presets {
            cb := this.gui.Add("Checkbox", "xm y+4 Checked", p.label)
            this.cbs.Push({ cb: cb, preset: p })
        }

        this.statusTxt := this.gui.Add("Text", "xm y+16 w560 cBlue", "Ready. Drop an image or click Browse.")
        this.runBtn := this.gui.Add("Button", "x+6 w90 Default", "Process")
        this.runBtn.OnEvent("Click", (*) => this.Process())

        this.gui.OnEvent("Close", (*) => this.gui.Hide())
        this.gui.OnEvent("DropFiles", (g, ctrl, files, x, y) => this.HandleDrop(files))
    }

    static BrowseInput() {
        p := FileSelect(1, , "Select Image", "Images (*.jpg;*.jpeg;*.png;*.webp;*.bmp;*.tif;*.tiff)")
        if p
            this.SetInput(p)
    }

    static BrowseOutput() {
        p := DirSelect(, 3, "Select Output Directory")
        if p
            this.outputEdit.Value := p
    }

    static HandleDrop(files) {
        if files.Length
            this.SetInput(files[1])
    }

    static SetInput(path) {
        this.inputEdit.Value := path
        if !this.outputEdit.Value {
            SplitPath(path, , &dir)
            this.outputEdit.Value := dir
        }
    }

    static SetStatus(text, color := "Blue") {
        this.statusTxt.Opt("c" color)
        this.statusTxt.Text := text
        this.statusTxt.Redraw()
    }

    static Process() {
        input  := Trim(this.inputEdit.Value)
        outDir := Trim(this.outputEdit.Value)

        if !FileExist(input) {
            this.SetStatus("Input file not found.", "Red")
            return
        }
        if !outDir {
            this.SetStatus("Please choose an output directory.", "Red")
            return
        }
        if !DirExist(outDir) {
            try DirCreate(outDir)
            catch as e {
                this.SetStatus("Could not create output directory: " e.Message, "Red")
                return
            }
        }

        SplitPath(input, , , , &baseName)
        bgColor  := Trim(this.padColor.Value) || "#d9d7b9"
        cropMode := this.modeCrop.Value

        this.runBtn.Enabled := false
        count := 0, failed := []

        for item in this.cbs {
            if !item.cb.Value
                continue
            p := item.preset
            outPath := outDir "\" baseName "_" p.w "x" p.h ".jpg"
            this.SetStatus("Processing " p.label " ...")

            if cropMode {
                args := Format('"{1}" -resize {2}x{3}^ -gravity center -extent {2}x{3} -quality 92 "{4}"',
                    input, p.w, p.h, outPath)
            } else {
                args := Format('"{1}" -resize {2}x{3} -background "{5}" -gravity center -extent {2}x{3} -quality 92 "{4}"',
                    input, p.w, p.h, outPath, bgColor)
            }

            try {
                code := RunWait("magick.exe " args, , "Hide")
                if code = 0
                    count++
                else
                    failed.Push(p.label " (exit " code ")")
            } catch OSError {
                this.SetStatus("magick.exe not found on PATH.", "Red")
                MsgBox("ImageMagick (magick.exe) is not on your PATH.`n`nInstall from:`nhttps://imagemagick.org/script/download.php#windows",
                    "Missing Dependency", "Iconx")
                this.runBtn.Enabled := true
                return
            }
        }

        this.runBtn.Enabled := true

        if failed.Length {
            this.SetStatus(Format("{} succeeded, {} failed: {}", count, failed.Length, this.Join(failed)), "Red")
        } else if count = 0 {
            this.SetStatus("No presets selected.", "Red")
        } else {
            this.SetStatus(Format("Done. {} file(s) created.", count), "Green")
            if "Yes" = MsgBox(Format("{} file(s) created in:`n{}`n`nOpen folder?", count, outDir), "Done", "YesNo Iconi")
                Run('explorer.exe "' outDir '"')
        }
    }

    static Join(arr, sep := ", ") {
        s := ""
        for i, v in arr
            s .= (i > 1 ? sep : "") v
        return s
    }
}

; --- Hotstring trigger: type "resizeimg" followed by space/enter/etc ---
::resizeimg::App.Run()
