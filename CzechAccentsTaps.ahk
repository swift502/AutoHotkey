#Requires AutoHotkey v2.0

ih := InputHook("L1 V")
ih.KeyOpt("{Backspace}{Delete}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}", "N")
ih.OnKeyDown := SequenceBreakerKeyDown

tapInterval := 300
lastInputChar := ""
lastTime := 0
sequenceChar := ""

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
            Send "{Blind}{Backspace 2}{Text}" sequenceChar
        }
    }
    else
    {
        sequenceChar := inputChar
    }

    lastInputChar := inputChar
    lastTime := time
}