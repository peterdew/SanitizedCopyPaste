; AutoHotkey v2 version

; IP address counter for consistent anonymization
global ipCounter := 1
global domainCounter := 1

translations := Map(
    "bedrijf1" => "[BEDRIJF]",
    "bedrijf2" => "[ORGANISATIE]",
    "naam1" => "[NAAM]",
    "naam2" => "[PERSOON]"
    ; Add more translations here
)

; HTTP headers that should be anonymized
httpHeaders := Map(
    "x-forwarded-for" => true,
    "host" => true,
    "origin" => true,
    "user-agent" => true,
    "referer" => true,
    "set-cookie" => true,
    "cookie" => true,
    "authorization" => true,
    "x-api-key" => true,
    "api-key" => true,
    "bearer" => true
)

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

; Function to sanitize HTTP headers while preserving structure
SanitizeHeaders(text) {
    result := text
    
    ; Process each header type
    for header, _ in httpHeaders {
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
                ; Preserve auth type but anonymize token
                result := RegExReplace(result, "i)(authorization|bearer):\s*([^\s]+)\s+([^\r\n]*)", 
                    "$1: $2 SanitizedToken")
            
            case "x-api-key", "api-key":
                ; Preserve key structure but anonymize value
                result := RegExReplace(result, "i)(x-api-key|api-key):\s*([^\r\n]*)", 
                    "$1: SanitizedKey")
            
            case "user-agent":
                ; Preserve browser/OS info but anonymize version
                result := RegExReplace(result, "i)user-agent:\s*([^/]+)/([^\r\n]*)", 
                    "user-agent: $1/SanitizedVersion")
            
            default:
                ; For other headers, preserve structure but anonymize value
                result := RegExReplace(result, "i)" . header . ":\s*([^\r\n]*)", 
                    header . ": SanitizedValue")
        }
    }
    
    return result
}

; Function to sanitize text (replace original text with labels)
SanitizeText(text) {
    result := text
    
    ; Apply basic translations
    for original, replacement in translations {
        result := StrReplace(result, original, replacement)
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