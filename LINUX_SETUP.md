# SanitizedCopyPaste - Linux Setup Guide

Dit project is nu beschikbaar voor Linux! Hier zijn de verschillende implementatie opties.

## 🚀 Snelle Start

### Optie 1: Python Implementatie (Aanbevolen)

**Voordelen:**
- Volledige functionaliteit
- Cross-platform compatibiliteit
- Rijke regex support
- Makkelijk uit te breiden

**Installatie:**
```bash
# Installeer systeem dependencies
sudo apt install xclip xdotool  # Ubuntu/Debian
# of
sudo dnf install xclip xdotool  # Fedora
# of
sudo pacman -S xclip xdotool    # Arch

# Maak script uitvoerbaar
chmod +x sanitized_copy_paste.py

# Test de installatie
./sanitized_copy_paste.py --help
```

**Gebruik:**
```bash
# Sanitize clipboard content
./sanitized_copy_paste.py --sanitize

# Desanitize and paste
./sanitized_copy_paste.py --desanitize

# Add selection to memory
./sanitized_copy_paste.py --add-memory

# Interactive mode
./sanitized_copy_paste.py --interactive
```

### Optie 2: Shell Script (Lichtgewicht)

**Voordelen:**
- Geen Python dependencies
- Zeer lichtgewicht
- Snelle uitvoering

**Installatie:**
```bash
# Installeer dependencies
sudo apt install xclip xdotool jq  # Ubuntu/Debian
# of
sudo dnf install xclip xdotool jq  # Fedora
# of
sudo pacman -S xclip xdotool jq    # Arch

# Maak script uitvoerbaar
chmod +x sanitized_copy_paste.sh
```

**Gebruik:**
```bash
# Sanitize clipboard content
./sanitized_copy_paste.sh sanitize

# Desanitize and paste
./sanitized_copy_paste.sh desanitize

# Add selection to memory
./sanitized_copy_paste.sh add-memory

# Interactive mode
./sanitized_copy_paste.sh interactive
```

## 🔧 Configuratie

### Configuratie Bestand
Beide implementaties gebruiken `translations.json`:

```json
{
  "companies": {
    "microsoft": "[BEDR_mcs]",
    "clientcorp": "[BEDR_CC]"
  },
  "names": {
    "John Doe": "[NAME_JD]",
    "Jane Smith": "[NAME_JS]"
  },
  "custom_strings": {
    "sensitive_data": "[STRING1]"
  }
}
```

### Hotkey Setup (Optioneel)

Voor automatische hotkeys, kun je een window manager configuratie gebruiken:

**i3wm:**
```bash
# In ~/.config/i3/config
bindsym $mod+Shift+c exec ~/path/to/sanitized_copy_paste.py --sanitize
bindsym $mod+Shift+v exec ~/path/to/sanitized_copy_paste.py --desanitize
bindsym $mod+Shift+a exec ~/path/to/sanitized_copy_paste.py --add-memory
```

**GNOME/KDE:**
Gebruik de "Custom Shortcuts" instellingen in je desktop environment.

## 🎯 Functionaliteit

### Automatische Detectie
- **GUIDs**: `550e8400-e29b-41d4-a716-446655440000` → `...440000`
- **API Keys**: `sk_test_FAKE_STRIPE_KEY_FOR_DEMO_PURPOSES_ONLY` → `...PURPOSES_ONLY`
- **JWT Tokens**: `eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...` → `...IkpXVCJ9`
- **IP Adressen**: `192.168.1.100` → `192.168.x.x`
- **Hex Strings**: `a1b2c3d4e5f6...` → `...e5f6`

### Handmatige Toevoeging
```bash
# Selecteer tekst en voeg toe aan geheugen
./sanitized_copy_paste.py --add-memory
```

## 🔄 Workflow

### Typische Workflow:
1. **Selecteer gevoelige tekst** (code, logs, etc.)
2. **Sanitize**: `./sanitized_copy_paste.py --sanitize`
3. **Deel veilig** (email, chat, documentatie)
4. **Ontvanger desanitize**: `./sanitized_copy_paste.py --desanitize`

### Voorbeeld:
```bash
# Originele tekst:
GET /api/users/12345 HTTP/1.1
Authorization: Bearer eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...
X-API-Key: sk_test_FAKE_STRIPE_KEY_FOR_DEMO_PURPOSES_ONLY

# Na sanitization:
GET /api/users/12345 HTTP/1.1
Authorization: Bearer ...IkpXVCJ9
X-API-Key: ...456789
```

## 🛠️ Troubleshooting

### Veelvoorkomende Problemen:

**"Neither xclip nor xsel found"**
```bash
sudo apt install xclip  # Ubuntu/Debian
```

**"xdotool not found"**
```bash
sudo apt install xdotool  # Ubuntu/Debian
```

**"jq not found" (shell script)**
```bash
sudo apt install jq  # Ubuntu/Debian
```

**Wayland Support:**
Voor Wayland gebruikers, installeer `wl-clipboard`:
```bash
sudo apt install wl-clipboard
# En pas de scripts aan om wl-copy/wl-paste te gebruiken
```

## 🚀 Geavanceerde Setup

### Systemd Service (Optioneel)
Voor automatische hotkey detection:

```bash
# Maak service file
sudo nano /etc/systemd/system/sanitized-copypaste.service

[Unit]
Description=SanitizedCopyPaste Service
After=graphical-session.target

[Service]
Type=simple
User=yourusername
ExecStart=/home/yourusername/path/to/sanitized_copy_paste.py --interactive
Restart=always

[Install]
WantedBy=graphical-session.target
```

### Docker Support
```dockerfile
FROM python:3.9-slim

RUN apt-get update && apt-get install -y \
    xclip xdotool \
    && rm -rf /var/lib/apt/lists/*

COPY sanitized_copy_paste.py /usr/local/bin/
RUN chmod +x /usr/local/bin/sanitized_copy_paste.py

ENTRYPOINT ["sanitized_copy_paste.py"]
```

## 📝 Notities

- **Python versie**: Werkt met Python 3.6+
- **Shell versie**: Werkt met Bash 4.0+
- **Dependencies**: Minimale systeem dependencies
- **Configuratie**: JSON formaat voor eenvoudige bewerking
- **Performance**: Shell script is sneller, Python is flexibeler

Kies de implementatie die het beste past bij jouw workflow!
