# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview
SanitizedCopyPaste is a privacy-focused AutoHotkey v2 tool that automatically anonymizes clipboard content by replacing sensitive information on-the-fly while copying. The tool sanitizes tokens, GUIDs, API keys, IP addresses, and custom strings.

## Key Components
- `SanitizedCopyPaste.ahk` - Main AutoHotkey v2 script containing all sanitization logic and hotkey bindings
- `translations.ini` - Configuration file with company names, personal names, and custom string mappings for anonymization

## Core Architecture
The application uses a translation-based approach where:
1. **Translation System**: Text is replaced using key-value pairs from `translations.ini` sections (Companies, Names, CustomStrings)
2. **Pattern Matching**: Automatic detection and sanitization of:
   - GUIDs (8-4-4-4-12 format) → `...last6chars`
   - Base64-like tokens (20+ chars) → `...last6chars`
   - Hex strings (32+ chars) → `...last6chars`
   - Long alphanumeric strings (25+ chars) → `...last6chars`
   - IPv4 addresses → `x.x.x.x` (preserves first two octets)
   - IPv6 addresses → `xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx`
3. **Bidirectional Processing**: Both sanitize (original→anonymized) and desanitize (anonymized→original) functions

## Key Hotkeys
- `Ctrl+Shift+C` - Sanitize clipboard content (copy with anonymization)
- `Ctrl+Shift+V` - Desanitize and paste (restore original values before pasting)
- `Ctrl+Shift+A` - Add selected text to memory as custom string for future sanitization

## Configuration
Edit `translations.ini` to customize:
- `[Companies]` - Company name mappings
- `[Names]` - Personal name mappings  
- `[CustomStrings]` - User-added custom string mappings (populated via Ctrl+Shift+A)

## Development Notes
- AutoHotkey v2 syntax is used throughout
- Global variables track counters for consistent anonymization
- INI file operations handle persistent storage of custom strings
- Pattern matching uses regex with capture groups for token detection