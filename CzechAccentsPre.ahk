#Requires AutoHotkey v2.0

sendSymbol(lower, upper) {
    isUpper := GetKeyState("Shift", "P") ^ GetKeyState("CapsLock", "T")
    SendText isUpper ? upper : lower
}

RAlt & a:: sendSymbol("á", "Á")
RAlt & c:: sendSymbol("č", "Č")
RAlt & d:: sendSymbol("ď", "Ď")
RAlt & e:: sendSymbol("ě", "Ě")
RAlt & i:: sendSymbol("í", "Í")
RAlt & n:: sendSymbol("ň", "Ň")
RAlt & o:: sendSymbol("ó", "Ó")
RAlt & r:: sendSymbol("ř", "Ř")
RAlt & s:: sendSymbol("š", "Š")
RAlt & t:: sendSymbol("ť", "Ť")
RAlt & u:: sendSymbol("ú", "Ú")
RAlt & y:: sendSymbol("ý", "Ý")
RAlt & z:: sendSymbol("ž", "Ž")
RAlt & `;:: sendSymbol("ů", "Ů")
RAlt & ':: sendSymbol("é", "É")