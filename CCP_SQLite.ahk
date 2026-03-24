; CCP_SQLite.ahk
; ContentCapture Pro - SQLite Wrapper
; Uses winsqlite3.dll — checks script folder first, then Windows System32
; AHK v2 - UTF-8 with BOM
;
; CHANGELOG:
;   v1.2 2026-03-23
;     - FIXED: DLL resolution now checks A_ScriptDir first (winsqlite3.dll is
;       included in the CCP folder), then falls back to Windows System32.
;       The old approach (hardcoded System32 path) failed because winsqlite3.dll
;       in System32 does not reliably export sqlite3_open16 on all Windows builds.
;     - FIXED: Switched from sqlite3_open16 back to sqlite3_open_v2 which is
;       consistently exported by both the bundled DLL and System32 copy.
;     - FIXED: CCP_DB_Begin/Commit/Rollback were one-liners — expanded to
;       multi-line bodies which AHK v2 requires.
;     - ADDED: CCP_SQLite_DLL() helper centralises DLL path resolution.

#Requires AutoHotkey v2.0

; ---------------------------------------------------------------------------
; DLL RESOLUTION — call this instead of hardcoding the path anywhere
; ---------------------------------------------------------------------------
CCP_SQLite_DLL() {
    scriptDll := A_ScriptDir "\winsqlite3.dll"
    sysDll    := A_WinDir   "\System32\winsqlite3.dll"
    if FileExist(scriptDll)
        return scriptDll
    if FileExist(sysDll)
        return sysDll
    throw Error("winsqlite3.dll not found.`n`nChecked:`n  " scriptDll "`n  " sysDll
        . "`n`nCopy winsqlite3.dll from System32 into your CCP folder.")
}

; ---------------------------------------------------------------------------
; OPEN / CLOSE
; ---------------------------------------------------------------------------
CCP_DB_Open(dbPath) {
    dll := CCP_SQLite_DLL()
    ; Delete zero-byte DB left by a previously failed open
    if FileExist(dbPath) && FileGetSize(dbPath) = 0
        FileDelete(dbPath)
    pathBuf := Buffer(StrPut(dbPath, "UTF-8"))
    StrPut(dbPath, pathBuf, "UTF-8")
    db := 0
    try {
        rc := DllCall(dll "\sqlite3_open_v2",
            "Ptr",   pathBuf,
            "UPtr*", &db,
            "Int",   6,          ; SQLITE_OPEN_READWRITE | SQLITE_OPEN_CREATE
            "Ptr",   0,
            "Int")
    } catch as e {
        throw Error("sqlite3_open_v2 DllCall failed.`nDLL: " dll "`nError: " e.Message)
    }
    if rc != 0 || !db
        throw Error("sqlite3_open_v2 rc=" rc " db=" db "`nPath: " dbPath "`nDLL: " dll)
    return db
}

CCP_DB_Close(db) {
    if db
        DllCall(CCP_SQLite_DLL() "\sqlite3_close", "UPtr", db)
}

; ---------------------------------------------------------------------------
; EXECUTE (no result set)
; ---------------------------------------------------------------------------
CCP_DB_Execute(db, sql) {
    dll    := CCP_SQLite_DLL()
    sqlBuf := Buffer(StrPut(sql, "UTF-8"))
    StrPut(sql, sqlBuf, "UTF-8")
    errPtr := 0
    rc := DllCall(dll "\sqlite3_exec",
        "UPtr",  db, "Ptr", sqlBuf,
        "Ptr",   0,  "Ptr", 0,
        "UPtr*", &errPtr, "Int")
    if rc != 0 {
        msg := errPtr ? StrGet(errPtr, "UTF-8") : "unknown error"
        if errPtr
            DllCall(dll "\sqlite3_free", "Ptr", errPtr)
        throw Error("SQL error [rc=" rc "]: " msg "`nSQL: " sql)
    }
}

; ---------------------------------------------------------------------------
; QUERY (returns array of Maps)
; ---------------------------------------------------------------------------
CCP_DB_Query(db, sql) {
    dll    := CCP_SQLite_DLL()
    sqlBuf := Buffer(StrPut(sql, "UTF-8"))
    StrPut(sql, sqlBuf, "UTF-8")
    stmt := 0
    rc := DllCall(dll "\sqlite3_prepare_v2",
        "UPtr", db, "Ptr", sqlBuf, "Int", -1, "UPtr*", &stmt, "Ptr", 0, "Int")
    if rc != 0 || !stmt
        throw Error("sqlite3_prepare_v2 failed (rc=" rc ")`nSQL: " sql)
    colCount := DllCall(dll "\sqlite3_column_count", "UPtr", stmt, "Int")
    colNames := []
    Loop colCount {
        p := DllCall(dll "\sqlite3_column_name",
            "UPtr", stmt, "Int", A_Index - 1, "UPtr")
        colNames.Push(p ? StrGet(p, "UTF-8") : "col" A_Index)
    }
    rows := []
    Loop {
        rc := DllCall(dll "\sqlite3_step", "UPtr", stmt, "Int")
        if rc = 101  ; SQLITE_DONE
            break
        if rc != 100  ; SQLITE_ROW
            break
        row := Map()
        Loop colCount {
            ci  := A_Index - 1
            typ := DllCall(dll "\sqlite3_column_type", "UPtr", stmt, "Int", ci, "Int")
            if typ = 1      ; SQLITE_INTEGER
                row[colNames[A_Index]] := DllCall(dll "\sqlite3_column_int64",
                    "UPtr", stmt, "Int", ci, "Int64")
            else if typ = 2 ; SQLITE_FLOAT
                row[colNames[A_Index]] := DllCall(dll "\sqlite3_column_double",
                    "UPtr", stmt, "Int", ci, "Double")
            else if typ = 5 ; SQLITE_NULL
                row[colNames[A_Index]] := ""
            else {           ; SQLITE_TEXT (3) or SQLITE_BLOB (4)
                p := DllCall(dll "\sqlite3_column_text", "UPtr", stmt, "Int", ci, "UPtr")
                row[colNames[A_Index]] := p ? StrGet(p, "UTF-8") : ""
            }
        }
        rows.Push(row)
    }
    DllCall(dll "\sqlite3_finalize", "UPtr", stmt)
    return rows
}

; Return the first column of the first row, or default if no rows
CCP_DB_QueryOne(db, sql, default := "") {
    rows := CCP_DB_Query(db, sql)
    if rows.Length = 0
        return default
    for k, v in rows[1]
        return v
    return default
}

; ---------------------------------------------------------------------------
; HELPERS
; ---------------------------------------------------------------------------
CCP_DB_Escape(str) {
    return StrReplace(String(str), "'", "''")
}

CCP_DB_Begin(db) {
    CCP_DB_Execute(db, "BEGIN TRANSACTION")
}

CCP_DB_Commit(db) {
    CCP_DB_Execute(db, "COMMIT")
}

CCP_DB_Rollback(db) {
    CCP_DB_Execute(db, "ROLLBACK")
}

; ---------------------------------------------------------------------------
; IMAGES TABLE
; ---------------------------------------------------------------------------
CCP_DB_InitImages(db) {
    CCP_DB_Execute(db,
        "CREATE TABLE IF NOT EXISTS images ("
        . "key TEXT PRIMARY KEY COLLATE NOCASE,"
        . "b64 TEXT NOT NULL,"
        . "source_file TEXT DEFAULT '',"
        . "folder TEXT DEFAULT '',"
        . "orig_kb REAL DEFAULT 0,"
        . "b64_kb REAL DEFAULT 0,"
        . "encoded_date TEXT DEFAULT '')")
    CCP_DB_Execute(db,
        "CREATE INDEX IF NOT EXISTS idx_folder ON images (folder)")
}

CCP_DB_UpsertImage(db, key, b64, srcFile, folder, origKB, b64KB, encDate) {
    CCP_DB_Execute(db,
        "INSERT OR REPLACE INTO images"
        . "(key,b64,source_file,folder,orig_kb,b64_kb,encoded_date) VALUES("
        . "'" CCP_DB_Escape(key)     "',"
        . "'" CCP_DB_Escape(b64)     "',"
        . "'" CCP_DB_Escape(srcFile) "',"
        . "'" CCP_DB_Escape(folder)  "',"
        . CCP_DB_Escape(origKB)      ","
        . CCP_DB_Escape(b64KB)       ","
        . "'" CCP_DB_Escape(encDate) "')")
}

CCP_DB_GetImage(db, key) {
    return CCP_DB_QueryOne(db,
        "SELECT b64 FROM images WHERE key='" CCP_DB_Escape(key) "' LIMIT 1", "")
}

CCP_DB_KeyExists(db, key) {
    return CCP_DB_QueryOne(db,
        "SELECT COUNT(*) FROM images WHERE key='" CCP_DB_Escape(key) "'", 0) > 0
}

CCP_DB_DeleteImage(db, key) {
    CCP_DB_Execute(db,
        "DELETE FROM images WHERE key='" CCP_DB_Escape(key) "'")
}

CCP_DB_RenameImage(db, oldKey, newKey) {
    CCP_DB_Execute(db,
        "UPDATE images SET key='" CCP_DB_Escape(newKey)
        . "' WHERE key='" CCP_DB_Escape(oldKey) "'")
}

CCP_DB_GetAllImages(db) {
    return CCP_DB_Query(db,
        "SELECT key,source_file,folder,orig_kb,b64_kb,encoded_date"
        . " FROM images ORDER BY folder,key")
}

CCP_DB_SearchImages(db, srch) {
    s := CCP_DB_Escape(srch)
    return CCP_DB_Query(db,
        "SELECT key,source_file,folder,orig_kb,b64_kb,encoded_date"
        . " FROM images WHERE key LIKE '%" s "%'"
        . " OR source_file LIKE '%" s "%'"
        . " OR folder LIKE '%" s "%'"
        . " ORDER BY folder,key")
}

CCP_DB_ImageCount(db) {
    return CCP_DB_QueryOne(db, "SELECT COUNT(*) FROM images", 0)
}
