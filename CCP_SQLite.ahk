; CCP_SQLite.ahk
; ContentCapture Pro - SQLite Wrapper
; Uses winsqlite3.dll (Windows 10/11 built-in)
; AHK v2 - UTF-8 with BOM

#Requires AutoHotkey v2.0

global CCP_SQLITE_DLL := A_ScriptDir "\winsqlite3.dll"

CCP_DB_Open(dbPath) {
    if !FileExist(CCP_SQLITE_DLL)
        throw Error("winsqlite3.dll not found at: " CCP_SQLITE_DLL)
    pathBuf := Buffer(StrPut(dbPath, "UTF-8"))
    StrPut(dbPath, pathBuf, "UTF-8")
    db := 0
    rc := DllCall(CCP_SQLITE_DLL "\sqlite3_open_v2",
        "Ptr", pathBuf, "UPtr*", &db, "Int", 6, "Ptr", 0, "Int")
    if rc != 0 || !db
        throw Error("Cannot open database (rc=" rc "): " dbPath)
    return db
}

CCP_DB_Close(db) {
    if db
        DllCall(CCP_SQLITE_DLL "\sqlite3_close", "UPtr", db)
}

CCP_DB_Execute(db, sql) {
    sqlBuf := Buffer(StrPut(sql, "UTF-8"))
    StrPut(sql, sqlBuf, "UTF-8")
    errPtr := 0
    rc := DllCall(CCP_SQLITE_DLL "\sqlite3_exec",
        "UPtr", db, "Ptr", sqlBuf, "Ptr", 0, "Ptr", 0, "UPtr*", &errPtr, "Int")
    if rc != 0 {
        msg := errPtr ? StrGet(errPtr, "UTF-8") : "unknown error"
        if errPtr
            DllCall(CCP_SQLITE_DLL "\sqlite3_free", "Ptr", errPtr)
        throw Error("SQL error [rc=" rc "]: " msg)
    }
}

CCP_DB_Query(db, sql) {
    sqlBuf := Buffer(StrPut(sql, "UTF-8"))
    StrPut(sql, sqlBuf, "UTF-8")
    stmt := 0
    rc := DllCall(CCP_SQLITE_DLL "\sqlite3_prepare_v2",
        "UPtr", db, "Ptr", sqlBuf, "Int", -1, "UPtr*", &stmt, "Ptr", 0, "Int")
    if rc != 0 || !stmt
        throw Error("sqlite3_prepare_v2 failed (rc=" rc ")")
    colCount := DllCall(CCP_SQLITE_DLL "\sqlite3_column_count", "UPtr", stmt, "Int")
    colNames := []
    Loop colCount {
        p := DllCall(CCP_SQLITE_DLL "\sqlite3_column_name",
            "UPtr", stmt, "Int", A_Index - 1, "UPtr")
        colNames.Push(p ? StrGet(p, "UTF-8") : "col" A_Index)
    }
    rows := []
    Loop {
        rc := DllCall(CCP_SQLITE_DLL "\sqlite3_step", "UPtr", stmt, "Int")
        if rc = 101
            break
        if rc != 100
            break
        row := Map()
        Loop colCount {
            ci  := A_Index - 1
            typ := DllCall(CCP_SQLITE_DLL "\sqlite3_column_type",
                       "UPtr", stmt, "Int", ci, "Int")
            if typ = 1
                row[colNames[A_Index]] := DllCall(CCP_SQLITE_DLL "\sqlite3_column_int64",
                    "UPtr", stmt, "Int", ci, "Int64")
            else if typ = 2
                row[colNames[A_Index]] := DllCall(CCP_SQLITE_DLL "\sqlite3_column_double",
                    "UPtr", stmt, "Int", ci, "Double")
            else if typ = 5
                row[colNames[A_Index]] := ""
            else {
                p := DllCall(CCP_SQLITE_DLL "\sqlite3_column_text",
                    "UPtr", stmt, "Int", ci, "UPtr")
                row[colNames[A_Index]] := p ? StrGet(p, "UTF-8") : ""
            }
        }
        rows.Push(row)
    }
    DllCall(CCP_SQLITE_DLL "\sqlite3_finalize", "UPtr", stmt)
    return rows
}

CCP_DB_QueryOne(db, sql, default := "") {
    rows := CCP_DB_Query(db, sql)
    if rows.Length = 0
        return default
    for k, v in rows[1]
        return v
    return default
}

CCP_DB_Escape(str) {
    return StrReplace(String(str), "'", "''")
}

CCP_DB_Begin(db)    { CCP_DB_Execute(db, "BEGIN TRANSACTION") }
CCP_DB_Commit(db)   { CCP_DB_Execute(db, "COMMIT") }
CCP_DB_Rollback(db) { CCP_DB_Execute(db, "ROLLBACK") }

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
    CCP_DB_Execute(db, "DELETE FROM images WHERE key='" CCP_DB_Escape(key) "'")
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
