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
isEnabled := false
lastInputChar := ""
consecutiveTaps := 0
currentOutputLen := 0

; Mapping
Mapping := [
    ["a", "á"],
    ["c", "č", "cc", "čc"],
    ["d", "ď"],
    ["e", "ě", "é"],
    ["i", "í"],
    ["n", "ň"],
    ["o", "ó"],
    ["r", "ř"],
    ["s", "š", "ss", "šš"],
    ["t", "ť"],
    ["u", "ů", "ú"],
    ["y", "ý"],
    ["z", "ž"],
    ["~", "°"]
]

MappingTable := Map()
for _, arr in Mapping
{
    upperArr := []
    for _, char in arr
        upperArr.Push(StrUpper(char))

    MappingTable[arr[1]] := arr
    MappingTable[StrUpper(arr[1])] := upperArr
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

    if (inputChar == lastInputChar && MappingTable.Has(inputChar))
    {
        consecutiveTaps++

        arr := MappingTable[inputChar]
        prefixCount := (consecutiveTaps - 1) // arr.Length
        index := Mod(consecutiveTaps - 1, arr.Length) + 1

        output := ""
        Loop prefixCount
            output .= arr[1]
        output .= arr[index]

        Send("{Blind}{Backspace " currentOutputLen + 1 "}{Text}" output)
        currentOutputLen := StrLen(output)
    }
    else
    {
        consecutiveTaps := 1
        currentOutputLen := 1
    }

    lastInputChar := inputChar
}