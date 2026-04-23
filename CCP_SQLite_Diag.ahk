; CCP_SQLite_Diag.ahk  v2
; Crash-proof diagnostic - saves report immediately after each test
; AHK v2 - UTF-8 with BOM

#Requires AutoHotkey v2.0
#SingleInstance Force

dllPath    := A_ScriptDir "\winsqlite3.dll"
reportFile := A_ScriptDir "\ccp_sqlite_diag.txt"
report     := ""

AppendReport(msg) {
    global report, reportFile
    report .= msg . "`n"
    try FileAppend(msg . "`n", reportFile)
}

; Start fresh
try FileDelete(reportFile)

AppendReport("winsqlite3.dll Diagnostics")
AppendReport("Path: " dllPath)
AppendReport("Exists: " (FileExist(dllPath) ? "YES" : "NO"))
AppendReport("")

if !FileExist(dllPath) {
    MsgBox(report, "Diagnostic - DLL NOT FOUND", "Icon!")
    ExitApp()
}

; Load DLL
hDll := 0
try hDll := DllCall("LoadLibraryW", "Str", dllPath, "Ptr")
AppendReport("LoadLibrary handle: " hDll)
AppendReport("")

if !hDll {
    MsgBox(report, "Diagnostic - Load Failed", "Icon!")
    ExitApp()
}

; Check function exports
AppendReport("=== Function exports ===")
funcs := ["sqlite3_open","sqlite3_open16","sqlite3_open_v2",
          "sqlite3_close","sqlite3_exec","sqlite3_prepare_v2",
          "sqlite3_step","sqlite3_finalize","sqlite3_free",
          "sqlite3_column_count","sqlite3_column_text",
          "sqlite3_column_int64","sqlite3_column_double",
          "sqlite3_column_type","sqlite3_column_name","sqlite3_errmsg"]

for fn in funcs {
    addr := 0
    try addr := DllCall("GetProcAddress", "Ptr", hDll, "AStr", fn, "Ptr")
    AppendReport(fn ": " (addr ? "FOUND" : "NOT FOUND"))
}
AppendReport("")

; Free library - use try so crash here doesn't stop us
try DllCall("FreeLibrary", "Ptr", hDll)

; Test open calls
testDb := A_Temp "\ccp_diag_test.db"
AppendReport("=== Open tests (testDb=" testDb ") ===")

; Test 1: sqlite3_open UTF-8
AppendReport("--- sqlite3_open (UTF-8) ---")
try {
    buf := Buffer(StrPut(testDb, "UTF-8"))
    StrPut(testDb, buf, "UTF-8")
    db := 0
    rc := DllCall(dllPath "\sqlite3_open", "Ptr", buf, "UPtr*", &db, "Int")
    AppendReport("rc=" rc "  handle=" db)
    if db
        try DllCall(dllPath "\sqlite3_close", "UPtr", db)
} catch as e {
    AppendReport("EXCEPTION: " e.Message)
}
try FileDelete(testDb)

; Test 2: sqlite3_open16 UTF-16
AppendReport("--- sqlite3_open16 (UTF-16) ---")
try {
    buf := Buffer((StrLen(testDb)+1)*2, 0)
    StrPut(testDb, buf, "UTF-16")
    db := 0
    rc := DllCall(dllPath "\sqlite3_open16", "Ptr", buf, "UPtr*", &db, "Int")
    AppendReport("rc=" rc "  handle=" db)
    if db
        try DllCall(dllPath "\sqlite3_close", "UPtr", db)
} catch as e {
    AppendReport("EXCEPTION: " e.Message)
}
try FileDelete(testDb)

; Test 3: sqlite3_open_v2 UTF-8
AppendReport("--- sqlite3_open_v2 (UTF-8, flags=6) ---")
try {
    buf := Buffer(StrPut(testDb, "UTF-8"))
    StrPut(testDb, buf, "UTF-8")
    db := 0
    rc := DllCall(dllPath "\sqlite3_open_v2",
        "Ptr", buf, "UPtr*", &db, "Int", 6, "Ptr", 0, "Int")
    AppendReport("rc=" rc "  handle=" db)
    if db
        try DllCall(dllPath "\sqlite3_close", "UPtr", db)
} catch as e {
    AppendReport("EXCEPTION: " e.Message)
}
try FileDelete(testDb)

AppendReport("")
AppendReport("=== DONE ===")

MsgBox(report, "SQLite Diagnostic", "Iconi")
