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
    Send "{Blind}+{Left}"

    if (GetKeyState("Shift", "P"))
        Send "{Shift up}^c{Shift down}"
    else
        Send "^c"
    
    if !ClipWait(0.3)
    {
        SoundPlay "*64"
        return
    }

    ; Replace
    if (Table.Has(A_Clipboard))
        Send "{Blind}{Text}" Table[A_Clipboard]
    else
        Send "{Blind}+{Right}"

    ; Restore clipboard
    A_Clipboard := ClipSaved
    ClipSaved := ""
}

doubleWindow := 500
lastChar := ""
lastTime := 0

Loop {
    ih := InputHook("L1")
    ih.KeyOpt("{Backspace}", "ES")
    ih.Start()
    ih.Wait()
    if (ih.EndReason = "EndKey" && ih.EndKey = "Backspace") {
        Send "{Blind}{Backspace}"
        lastChar := ""
        lastTime := 0
        continue
    }
    ch := ih.Input
    now := A_TickCount

    isLetter := RegExMatch(ch, "^[A-Za-z]$")

    if (isLetter && Table.Has(ch) && ch = lastChar && (now - lastTime) <= doubleWindow) {
        ToggleChar()
    } else {
        Send "{Blind}{Text}" ch
    }

    lastChar := ch
    lastTime := now
}