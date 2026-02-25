#Requires AutoHotkey v2.0

; Config
A_IconTip := "Czech Accents"
tapInterval := 500
enabledIcon := A_ScriptDir "\assets\enabled.png"
disabledIcon := A_ScriptDir "\assets\disabled.png"
startupDir := EnvGet("AppData") "\Microsoft\Windows\Start Menu\Programs\Startup"

; Menu
A_TrayMenu.Delete()
A_TrayMenu.Add("Enabled", (*) => ToggleEnabled())
A_TrayMenu.Add("Reload Script", (*) => Reload())
A_TrayMenu.Add()
A_TrayMenu.Add("Open Script Folder", (*) => Run(A_ScriptDir))
A_TrayMenu.Add("Open Startup Folder", (*) => Run(startupDir))
A_TrayMenu.Add()
A_TrayMenu.Add("Exit", (*) => ExitApp())
A_TrayMenu.Default := "Enabled"

; Input
ih := InputHook("L1 B")
ih.KeyOpt("{Backspace}{Delete}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}", "N")
ih.OnKeyDown := HandleKeyDown

; State
isEnabled := false
lastInputChar := ""
lastTime := 0
sequenceChar := ""
highlightActive := false

; Mapping
Table := Map(
    "a", "á",   "á", "a",
    "c", "č",   "č", "c",
    "d", "ď",   "ď", "d",
    "e", "ě",   "ě", "é",   "é", "e",
    "i", "í",   "í", "i",
    "n", "ň",   "ň", "n",
    "o", "ó",   "ó", "o",
    "r", "ř",   "ř", "r",
    "s", "š",   "š", "s",
    "t", "ť",   "ť", "t",
    "u", "ů",   "ů", "ú",   "ú", "u",
    "y", "ý",   "ý", "y",
    "z", "ž",   "ž", "z"
)

for k, v in Table.Clone()
{
    Table[StrUpper(k)] := StrUpper(v)
}

; Functions
ToggleEnabled()
{
    SetEnabled(!isEnabled)
}

SetEnabled(value)
{
    global isEnabled
    isEnabled := value
    SetScrollLockState(isEnabled)

    if (isEnabled)
    {
        TraySetIcon(enabledIcon)
        A_TrayMenu.Check("Enabled")
    }
    else
    {
        TraySetIcon(disabledIcon)
        A_TrayMenu.Uncheck("Enabled")
    }
}

ResetState(*)
{
    global lastInputChar, lastTime, sequenceChar
    lastInputChar := ""
    lastTime := A_TickCount
    sequenceChar := ""
    CancelHighlight()
}

HandleKeyDown(ih, vk, sc)
{
    keyName := GetKeyName(Format("vk{:x}sc{:x}", vk, sc))
    if (keyName ~= "^(Backspace|Delete|Left|Right|Up|Down|Home|End|PgUp|PgDn)$")
        ResetState()
}

StartHighlight()
{
    global highlightActive, tapInterval
    highlightActive := true
    Send("+{Left}")
    SetTimer(ClearHighlight, -tapInterval)
}

ClearHighlight()
{
    global highlightActive
    if (!highlightActive)
        return
    Send("{Right}")
    highlightActive := false
}

CancelHighlight()
{
    global highlightActive
    SetTimer(ClearHighlight, 0)
    highlightActive := false
}

CollapseHighlight()
{
    global highlightActive
    SetTimer(ClearHighlight, 0)
    Send("{Right}")
    highlightActive := false
}

; Hotkeys
#Space::ToggleEnabled()

; Init
SetEnabled(false)

Loop
{
    ih.Start()
    ih.Wait()

    inputChar := ih.Input
    time := A_TickCount

    if (!isEnabled)
    {
        SendText(inputChar)
        ResetState()
        continue
    }

    if (highlightActive && inputChar != lastInputChar && lastInputChar != "" && Table.Has(sequenceChar))
        CollapseHighlight()

    if ((time - lastTime) <= tapInterval && inputChar == lastInputChar && Table.Has(sequenceChar))
    {
        sequenceChar := Table[sequenceChar]
        backspaceCount := highlightActive ? 1 : 2
        Send("{Blind}{Backspace " backspaceCount "}")
        SendText(sequenceChar)
        StartHighlight()
    }
    else
    {
        sequenceChar := inputChar
        SendText(inputChar)
        if (Table.Has(sequenceChar))
            StartHighlight()
    }

    lastInputChar := inputChar
    lastTime := time
}