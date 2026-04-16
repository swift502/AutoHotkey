#Requires AutoHotkey v2.0

; Config
A_IconTip := "Czech Accents"
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
editKeys := "{Backspace}{Delete}{Insert}"
navKeys := "{Left}{Right}{Up}{Down}{Home}{End}{PgUp}{PgDn}"
modKeys := "{LCtrl}{RCtrl}{LAlt}{RAlt}{LShift}{RShift}{LWin}{RWin}"
funcKeys := "{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}"

ih := InputHook("L1 V")
ih.KeyOpt(editKeys navKeys modKeys funcKeys, "N")
ih.OnKeyDown := ResetState

; State
isEnabled := false
lastInputChar := ""
consecutiveTaps := 0
currentOutputLen := 0

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
    "z", "ž",   "ž", "z",
    "~", "°",   "°", "~"
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
    global lastInputChar, consecutiveTaps, currentOutputLen
    lastInputChar := ""
    consecutiveTaps := 0
    currentOutputLen := 0
}

; Hotkeys
~*LButton::ResetState()
~*RButton::ResetState()
~*MButton::ResetState()
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

    if (inputChar == lastInputChar && Table.Has(inputChar))
    {
        consecutiveTaps++
        
        cycle := [inputChar]
        curr := Table[inputChar]
        while (curr != inputChar && curr != "") {
            cycle.Push(curr)
            curr := Table.Has(curr) ? Table[curr] : ""
            if (cycle.Length > 10)
                break
        }
        
        cycleIndex := Mod(consecutiveTaps - 1, cycle.Length) + 1
        charToRepeat := cycle[cycleIndex]
        repeatCount := Ceil(consecutiveTaps / cycle.Length)

        backspaceCount := currentOutputLen + 1
        Send("{Blind}{Backspace " backspaceCount "}")
        
        charsToType := ""
        Loop repeatCount
        {
            charsToType .= charToRepeat
        }
        
        Send("{Text}" charsToType)
        currentOutputLen := StrLen(charsToType)
    }
    else
    {
        consecutiveTaps := 1
        currentOutputLen := 1
    }

    lastInputChar := inputChar
}