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
ih := InputHook("L1 V")
ih.KeyOpt("{Backspace}{Delete}{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}", "N")
ih.OnKeyDown := ResetState

; State
isEnabled := false
lastInputChar := ""
lastTime := 0
sequenceChar := ""

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
}

; Hotkeys
#Space::ToggleEnabled()

; Init
SetEnabled(false)

Loop
{
    ih.Start()
    ih.Wait()

    if (!isEnabled)
        continue

    inputChar := ih.Input
    time := A_TickCount

    if ((time - lastTime) <= tapInterval && inputChar == lastInputChar && Table.Has(sequenceChar))
    {
        sequenceChar := Table[sequenceChar]
        Send("{Blind}{Backspace 2}{Text}" sequenceChar)
    }
    else
    {
        sequenceChar := inputChar
    }

    lastInputChar := inputChar
    lastTime := time
}