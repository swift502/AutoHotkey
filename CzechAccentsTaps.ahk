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
modKeys := "{LCtrl}{RCtrl}{LAlt}{RAlt}{LWin}{RWin}"
funcKeys := "{F1}{F2}{F3}{F4}{F5}{F6}{F7}{F8}{F9}{F10}{F11}{F12}"

ih := InputHook("L1 V")
ih.KeyOpt(editKeys navKeys modKeys funcKeys, "N")
ih.OnKeyDown := ResetState

; State
sequenceChain := 2
isEnabled := false
lastInputChar := ""
consecutiveTaps := 0
currentOutputLen := 0

; Mapping
Accents := [
    ["a", "á"],
    ["c", "č"],
    ["d", "ď"],
    ["e", "ě", "é"],
    ["i", "í"],
    ["n", "ň"],
    ["o", "ó"],
    ["r", "ř"],
    ["s", "š"],
    ["t", "ť"],
    ["u", "ů", "ú"],
    ["y", "ý"],
    ["z", "ž"],
    ["~", "°"]
]

Table := Map()
for _, arr in Accents
{
    upperArr := []
    for _, char in arr
        upperArr.Push(StrUpper(char))
        
    for _, char in arr
    {
        Table[char] := arr
        Table[StrUpper(char)] := upperArr
    }
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
        
        cycle := Table[inputChar]
        cycleIndex := Mod(consecutiveTaps - 1, cycle.Length) + 1
        
        charToRepeat := cycle[cycleIndex]
        repeatCount := Ceil(consecutiveTaps / cycle.Length)

        charsToType := ""
        Loop repeatCount
            charsToType .= charToRepeat

        Send("{Blind}{Backspace " currentOutputLen + 1 "}{Text}" charsToType)
        currentOutputLen := repeatCount

        if (repeatCount >= sequenceChain && cycleIndex == cycle.Length)
        {
            ResetState()
            continue
        }
    }
    else
    {
        consecutiveTaps := 1
        currentOutputLen := 1
    }

    lastInputChar := inputChar
}