#Requires AutoHotkey v2.0

ih := InputHook("L1 V")
tapInterval := 1000
lastTime := 0
sequenceChar := ""

~*Shift::HandleShiftTrigger()

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
for k, v in Table.Clone()
{
    Table[StrUpper(k)] := StrUpper(v)
}

HandleShiftTrigger()
{
    global lastTime, sequenceChar, tapInterval, Table

    time := A_TickCount
    if ((time - lastTime) <= tapInterval && Table.Has(sequenceChar))
    {
        sequenceChar := Table[sequenceChar]
        Send "{Blind}{Backspace}{Text}" sequenceChar
        lastTime := time
    }
}

Loop
{
    ih.Start()
    ih.Wait()

    inputChar := ih.Input
    time := A_TickCount

    if (Ord(inputChar) >= 32)
    {
        sequenceChar := inputChar
        lastTime := time
    }
    else
    {
        sequenceChar := ""
        lastTime := 0
    }
}