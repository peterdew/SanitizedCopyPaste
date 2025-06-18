; AutoHotkey v2 version

; IP address counter for consistent anonymization
global ipCounter := 1
global domainCounter := 1
global stringCounter := 1  ; Counter for manual string additions

; Load translations from INI file
global translations := []
LoadTranslations() {
    global translations
    translations := []  ; Clear existing translations
    
    ; Read all sections from the INI file
    iniPath := A_ScriptDir . "\translations.ini"
    if !FileExist(iniPath) {
        MsgBox("translations.ini not found!")
        return
    }
    
    ; Read Companies section
    Loop Parse, IniRead(iniPath, "Companies"), "`n" {
        if A_LoopField {
            key := StrSplit(A_LoopField, "=")[1]
            value := StrSplit(A_LoopField, "=")[2]
            translations.Push([key, value])
        }
    }
    
    ; Read Names section
    Loop Parse, IniRead(iniPath, "Names"), "`n" {
        if A_LoopField {
            key := StrSplit(A_LoopField, "=")[1]
            value := StrSplit(A_LoopField, "=")[2]
            translations.Push([key, value])
        }
    }
    
    ; Read CustomStrings section if it exists
    try {
        Loop Parse, IniRead(iniPath, "CustomStrings"), "`n" {
            if A_LoopField {
                key := StrSplit(A_LoopField, "=")[1]
                value := StrSplit(A_LoopField, "=")[2]
                translations.Push([key, value])
            }
        }
    }
}

; Load translations when script starts
LoadTranslations()

; httpHeaders als gewone array
httpHeaders := [
    "x-forwarded-for",
    "host",
    "origin",
    "user-agent",
    "referer",
    "set-cookie",
    "cookie",
    "authorization",
    "x-api-key",
    "api-key",
    "bearer"
]

; Function to sanitize IP addresses while preserving structure
SanitizeIP(text) {
    result := text
    
    ; Match IPv4 addresses
    static ipv4Pattern := "\b(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\b"
    result := RegExReplace(result, ipv4Pattern, "$1.$2.x.x")
    
    ; Match IPv6 addresses (simplified)
    static ipv6Pattern := "([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}"
    result := RegExReplace(result, ipv6Pattern, "xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx")
    
    return result
}

; Function to sanitize domains while preserving structure
SanitizeDomain(text) {
    result := text
    
    ; Match domains but preserve subdomain structure and TLD
    ; This will convert internal.clientcorp.com to internal.[client].com
    static domainPattern := "([a-zA-Z0-9-]+\.)([a-zA-Z0-9-]+)(\.[a-zA-Z]{2,})"
    result := RegExReplace(result, domainPattern, "$1[client]$3")
    
    return result
}

; Function to get last 6 chars of a string
GetLast6Chars(str) {
    return SubStr(str, -5)
}

; Function to sanitize HTTP headers while preserving structure
SanitizeHeaders(text) {
    result := text
    
    ; Process each header type
    for index, header in httpHeaders {
        switch header {
            case "set-cookie":
                ; Preserve cookie structure but anonymize values
                result := RegExReplace(result, "i)set-cookie:\s*([^=]+)=([^;]+)(.*)", 
                    "set-cookie: $1=SanitizedValue$3")
            
            case "cookie":
                ; Preserve cookie structure but anonymize values
                result := RegExReplace(result, "i)cookie:\s*([^=]+)=([^;]+)(.*)", 
                    "cookie: $1=SanitizedValue$3")
            
            case "authorization", "bearer":
                ; Show only last 6 characters of tokens preceded by dots
                Loop Parse, result, "`n", "`r" {
                    line := A_LoopField
                    if RegExMatch(line, "i)(authorization|bearer):\s*([^\s]+)\s+([^\r\n]{7,})", &match) {
                        sanitized := match[1] ": " match[2] " ..." GetLast6Chars(match[3])
                        result := StrReplace(result, match[0], sanitized)
                    }
                }
            
            case "x-api-key", "api-key":
                ; Show only last 6 characters of API keys preceded by dots
                Loop Parse, result, "`n", "`r" {
                    line := A_LoopField
                    if RegExMatch(line, "i)(x-api-key|api-key):\s*([^\r\n]{7,})", &match) {
                        sanitized := match[1] ": ..." GetLast6Chars(match[2])
                        result := StrReplace(result, match[0], sanitized)
                    }
                }
            
            case "user-agent":
                ; Preserve browser/OS info but anonymize version
                result := RegExReplace(result, "i)user-agent:\s*([^/]+)/([^\r\n]*)", 
                    "user-agent: $1/SanitizedVersion")
        }
    }
    
    return result
}

; Function to add a new string to translations
AddStringToMemory(text) {
    global stringCounter, translations
    sanitizedText := "[STRING" . stringCounter . "]"
    
    ; Add to translations array
    translations.Push([text, sanitizedText])
    
    ; Add to INI file in CustomStrings section
    iniPath := A_ScriptDir . "\translations.ini"
    IniWrite(sanitizedText, iniPath, "CustomStrings", text)
    
    stringCounter++
    return sanitizedText
}

; Function to sanitize text (replace original text with labels)
SanitizeText(text) {
    result := text
    
    ; First apply basic translations (company names, domains, etc)
    for index, pair in translations {
        result := StrReplace(result, pair[1], pair[2])
    }
    
    ; Then look for any long strings that look like tokens (at least 20 chars, typical for JWT/API keys)
    Loop Parse, result, "`n", "`r" {
        line := A_LoopField
        ; Skip lines that are URLs or standard headers
        if !RegExMatch(line, "i)(referer|origin|host):\s") {
            if RegExMatch(line, "([a-zA-Z0-9_\-\.]{20,})", &match) {
                ; Only sanitize if it looks like a token (not a URL)
                if !RegExMatch(match[1], "i)(http|www|\.com|\.net|\.org|\.nl)") {
                    sanitized := "..." . GetLast6Chars(match[1])
                    result := StrReplace(result, match[1], sanitized)
                }
            }
        }
    }
    
    ; Apply IP address sanitization
    result := SanitizeIP(result)
    
    ; Apply domain sanitization
    result := SanitizeDomain(result)
    
    ; Apply HTTP header sanitization
    result := SanitizeHeaders(result)
    
    return result
}

; Function to desanitize text (replace labels back to original text)
DesanitizeText(text) {
    result := text
    for index, pair in translations {
        result := StrReplace(result, pair[2], pair[1])
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

^+a:: {  ; Ctrl+Shift+A to add selected text to memory
    A_Clipboard := ""
    Send("^c")
    ClipWait(1)
    selectedText := A_Clipboard
    if (selectedText != "") {
        sanitizedText := AddStringToMemory(selectedText)
        MsgBox("Added to memory as: " . sanitizedText)
    }
}