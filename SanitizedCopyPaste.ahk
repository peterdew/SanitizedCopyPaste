; AutoHotkey v2 version

translations := Map(
    "bedrijf1" => "[BEDRIJF]",
    "bedrijf2" => "[ORGANISATIE]",
    "naam1" => "[NAAM]",
    "naam2" => "[PERSOON]"
    ; Add more translations here
)

; Function to sanitize text (replace original text with labels)
SanitizeText(text) {
    result := text
    for original, replacement in translations {
        result := StrReplace(result, original, replacement)
    }
    return result
}

; Function to desanitize text (replace labels back to original text)
DesanitizeText(text) {
    result := text
    for original, replacement in translations {
        result := StrReplace(result, replacement, original)
    }
    return result
}

^+c:: {  ; Ctrl+Shift+C for sanitizing
    A_Clipboard := ""
    Send("^c")
    ClipWait(1)
    A_Clipboard := SanitizeText(A_Clipboard)
}

^+v:: {  ; Ctrl+Shift+V for desanitizing
    A_Clipboard := ""
    Send("^c")
    ClipWait(1)
    A_Clipboard := DesanitizeText(A_Clipboard)
    Send("^v")
}