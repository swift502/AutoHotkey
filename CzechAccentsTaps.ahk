#Requires AutoHotkey v2.0

ih := InputHook("L1 V")
ih.KeyOpt("{Backspace}{Delete}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}", "N")
ih.OnKeyDown := SequenceBreakerKeyDown

tapInterval := 300
lastInputChar := ""
lastTime := 0
sequenceChar := ""

Table := Map(
    "a",  "á",
    "c",  "č",
    "d",  "ď",
    "e",  "ě",   "ě", "é",
    "i",  "í",
    "n",  "ň",
    "o",  "ó",
    "r",  "ř",
    "s",  "š",
    "t",  "ť",
    "u",  "ů",   "ů", "ú",
    "y",  "ý",
    "z",  "ž"
)

; Generate uppercase
for k, v in Table.Clone()
{
    Table[StrUpper(k)] := StrUpper(v)
}

ResetState()
{
    global lastInputChar, lastTime, sequenceChar
    lastInputChar := ""
    lastTime := 0
    sequenceChar := ""
}

SequenceBreakerKeyDown(*)
{
    ResetState()
}

Loop
{
    ih.Start()
    ih.Wait()

    inputChar := ih.Input
    time := A_TickCount

    if (Ord(inputChar) < 32)
    {
        ResetState()
        continue
    }

    if ((time - lastTime) <= tapInterval && inputChar == lastInputChar)
    {
        if (Table.Has(sequenceChar))
        {
            sequenceChar := Table[sequenceChar]
        }
        else
        {
            ; When no mapping is found, loop back to beginning
            sequenceChar := inputChar
        }

        Send "{Blind}{Backspace 2}{Text}" sequenceChar
    }
    else
    {
        sequenceChar := inputChar
    }

    lastInputChar := inputChar
    lastTime := time
}