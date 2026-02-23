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
for k, v in Table.Clone()
{
    Table[StrUpper(k)] := StrUpper(v)
}

ReplaceWithVariant(ch)
{
    Send "{Blind}{Backspace 2}{Text}" ch
}

ResetState()
{
    global lastChar, lastTime, sequenceChar
    lastChar := ""
    lastTime := 0
    sequenceChar := ""
}

SequenceBreakerKeyDown(*)
{
    ResetState()
}

ih := InputHook("L1 V")
ih.KeyOpt("{Backspace}{Delete}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}", "N")
ih.OnKeyDown := SequenceBreakerKeyDown

doubleWindow := 300
lastChar := ""
lastTime := 0
sequenceChar := ""

Loop
{
    ih.Start()
    ih.Wait()

    ch := ih.Input
    now := A_TickCount

    if (ch != "" && Ord(ch) < 32)
    {
        ResetState()
        continue
    }

    isDoubleTap := (now - lastTime) <= doubleWindow

    if (!isDoubleTap || ch != lastChar)
    {
        sequenceChar := ch
    }
    else
    {
        if (Table.Has(sequenceChar))
        {
            sequenceChar := Table[sequenceChar]
            ReplaceWithVariant(sequenceChar)
        }
    }

    lastChar := ch
    lastTime := now
}