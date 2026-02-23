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

cycleInterval := 300
currentKey := ""
currentChar := ""

SendChar(ch)
{
    Send "{Text}" ch
}

ReplaceChar(ch)
{
    Send "{Backspace}{Text}" ch
}

StopCycle()
{
    global currentKey, currentChar
    SetTimer(CycleTick, 0)
    currentKey := ""
    currentChar := ""
}

StartCycle(keyChar)
{
    global currentKey, currentChar, cycleInterval
    StopCycle()
    currentKey := keyChar
    currentChar := keyChar
    SendChar(currentChar)
    SetTimer(CycleTick, cycleInterval)
}

CycleTick(*)
{
    global currentKey, currentChar, Table
    if (currentKey = "")
    {
        SetTimer(CycleTick, 0)
        return
    }
    if (!Table.Has(currentChar))
    {
        return
    }
    currentChar := Table[currentChar]
    ReplaceChar(currentChar)
}

IsModifier(keyName)
{
    switch keyName
    {
        case "Shift", "LShift", "RShift", "Ctrl", "LControl", "RControl", "Control":
            return true
        case "Alt", "LAlt", "RAlt", "Win", "LWin", "RWin":
            return true
    }
    return false
}

NormalizeLetter(keyName)
{
    if !(keyName ~= "^[A-Za-z]$")
    {
        return keyName
    }

    shifted := GetKeyState("Shift", "P")
    caps := GetKeyState("CapsLock", "T")
    if (shifted ^ caps)
    {
        return StrUpper(keyName)
    }
    return StrLower(keyName)
}

OnKeyDown(ih, vk, sc)
{
    global currentKey, Table
    keyName := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
    if (IsModifier(keyName))
    {
        return
    }

    keyName := NormalizeLetter(keyName)

    if (currentKey != "" && keyName != currentKey)
    {
        StopCycle()
    }

    if (Table.Has(keyName))
    {
        if (currentKey = keyName)
        {
            return
        }
        StartCycle(keyName)
    }
}

OnKeyUp(ih, vk, sc)
{
    global currentKey
    keyName := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
    if (IsModifier(keyName))
    {
        return
    }

    keyName := NormalizeLetter(keyName)
    if (keyName = currentKey)
    {
        StopCycle()
    }
}

keySet := Map()
for k in Table
{
    if (StrLen(k) = 1 && k ~= "^[A-Za-z]$")
    {
        keySet[StrLower(k)] := true
    }
}

keyList := ""
for k in keySet
{
    keyList .= "{" k "}"
}

ih := InputHook("L0 V")
ih.KeyOpt("{All}", "N")
if (keyList != "")
{
    ih.KeyOpt(keyList, "S")
}
ih.OnKeyDown := OnKeyDown
ih.OnKeyUp := OnKeyUp
ih.Start()