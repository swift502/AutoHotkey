#Requires AutoHotkey v2.0

; Config
A_IconTip := "Czech Accents"
enabledIcon := A_ScriptDir "\assets\enabled.png"
disabledIcon := A_ScriptDir "\assets\disabled.png"
startupDir := EnvGet("AppData") "\Microsoft\Windows\Start Menu\Programs\Startup"
comboTimeout := 60 ; ms window for combo detection

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
lastChar := ""
lastCharTime := 0

; Combo Mapping
; Right combos: letter + right neighbor key → first variant (accentPos 1 = first char is accented)
; Left combos: left neighbor key + letter → second variant (accentPos 2 = second char is accented)
; Note: "yu" → ý wins over "yu" → ú (conflict)
ComboMap := Map()
ComboMap["as"] := {char: "á", accentPos: 1}
ComboMap["cv"] := {char: "č", accentPos: 1}
ComboMap["df"] := {char: "ď", accentPos: 1}
ComboMap["er"] := {char: "ě", accentPos: 1}
ComboMap["io"] := {char: "í", accentPos: 1}
ComboMap["nm"] := {char: "ň", accentPos: 1}
ComboMap["op"] := {char: "ó", accentPos: 1}
ComboMap["rt"] := {char: "ř", accentPos: 1}
ComboMap["sd"] := {char: "š", accentPos: 1}
ComboMap["ty"] := {char: "ť", accentPos: 1}
ComboMap["ui"] := {char: "ů", accentPos: 1}
ComboMap["yu"] := {char: "ý", accentPos: 1}
ComboMap["zx"] := {char: "ž", accentPos: 1}
ComboMap["we"] := {char: "é", accentPos: 2}

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
    global lastChar, lastCharTime
    lastChar := ""
    lastCharTime := 0
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
    {
        ResetState()
        continue
    }

    inputChar := ih.Input
    currentTime := A_TickCount

    ; Check for combo: previous char + current char within timeout
    if (lastChar != "" && (currentTime - lastCharTime) <= comboTimeout)
    {
        combo := StrLower(lastChar) StrLower(inputChar)

        if (ComboMap.Has(combo))
        {
            entry := ComboMap[combo]

            ; Determine case from the accent-bearing character
            accentSource := (entry.accentPos == 1) ? lastChar : inputChar
            result := IsUpper(accentSource) ? StrUpper(entry.char) : entry.char

            ; Delete both characters (previous + current) and type the accent
            Send("{Blind}{Backspace 2}{Text}" result)
            ResetState()
            continue
        }
    }

    lastChar := inputChar
    lastCharTime := currentTime
}

IsUpper(char)
{
    return char == StrUpper(char) && char != StrLower(char)
}