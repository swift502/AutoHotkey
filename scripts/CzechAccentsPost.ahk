#Requires AutoHotkey v2.0

Table := Map(
    "a",  "á",   "á", "a",
    "c",  "č",   "č", "c",
    "d",  "ď",   "ď", "d",
    "e",  "ě",   "ě", "é",   "é", "e",
    "i",  "í",   "í", "i",
    "n",  "ň",   "ň", "n",
    "o",  "ó",   "ó", "o",
    "r",  "ř",   "ř", "r",
    "s",  "š",   "š", "s",
    "t",  "ť",   "ť", "t",
    "u",  "ů",   "ů", "ú",   "ú", "u",
    "y",  "ý",   "ý", "y",
    "z",  "ž",   "ž", "z"
)

; Generate uppercase
for k, v in Table.Clone() {
    Table[StrUpper(k)] := StrUpper(v)
}

ToggleChar() {
    ; Save clipboard
    ClipSaved := ClipboardAll()
    A_Clipboard := ""

    ; Copy last character
    Send "+{Left}^c"
    if !ClipWait(0.3)
    {
        SoundPlay "*64"
        return
    }

    ; Replace
    if (Table.Has(A_Clipboard))
        SendText Table[A_Clipboard]
    else
        Send "+{Right}"

    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
}

*RAlt:: ToggleChar()