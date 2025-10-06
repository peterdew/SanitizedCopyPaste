#!/bin/bash
# SanitizedCopyPaste - Shell Script Version
# Privacy-focused tool for automatically anonymizing clipboard content

CONFIG_FILE="translations.json"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_PATH="$SCRIPT_DIR/$CONFIG_FILE"

# Initialize counters
IP_COUNTER=1
STRING_COUNTER=1

# Load translations from JSON config
load_translations() {
    if [[ ! -f "$CONFIG_PATH" ]]; then
        # Create default config
        cat > "$CONFIG_PATH" << 'EOF'
{
  "companies": {},
  "names": {},
  "custom_strings": {}
}
EOF
        return
    fi
    
    # Extract translations using jq (if available)
    if command -v jq >/dev/null 2>&1; then
        # Load companies
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                key=$(echo "$line" | jq -r 'keys[0]')
                value=$(echo "$line" | jq -r '.[]')
                echo "$key|$value"
            fi
        done < <(jq -c '.companies | to_entries[]' "$CONFIG_PATH" 2>/dev/null)
        
        # Load names
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                key=$(echo "$line" | jq -r 'keys[0]')
                value=$(echo "$line" | jq -r '.[]')
                echo "$key|$value"
            fi
        done < <(jq -c '.names | to_entries[]' "$CONFIG_PATH" 2>/dev/null)
        
        # Load custom strings
        while IFS= read -r line; do
            if [[ -n "$line" ]]; then
                key=$(echo "$line" | jq -r 'keys[0]')
                value=$(echo "$line" | jq -r '.[]')
                echo "$key|$value"
            fi
        done < <(jq -c '.custom_strings | to_entries[]' "$CONFIG_PATH" 2>/dev/null)
    else
        echo "Warning: jq not found. Install jq for full functionality."
    fi
}

# Get clipboard content
get_clipboard() {
    if command -v xclip >/dev/null 2>&1; then
        xclip -selection clipboard -o 2>/dev/null
    elif command -v xsel >/dev/null 2>&1; then
        xsel --clipboard --output 2>/dev/null
    else
        echo "Error: Neither xclip nor xsel found. Please install one of them." >&2
        exit 1
    fi
}

# Set clipboard content
set_clipboard() {
    local text="$1"
    if command -v xclip >/dev/null 2>&1; then
        echo "$text" | xclip -selection clipboard
    elif command -v xsel >/dev/null 2>&1; then
        echo "$text" | xsel --clipboard --input
    else
        echo "Error: Neither xclip nor xsel found. Please install one of them." >&2
        exit 1
    fi
}

# Get last 6 characters
get_last_6_chars() {
    local str="$1"
    echo "${str: -6}"
}

# Sanitize IP addresses
sanitize_ip() {
    local text="$1"
    # IPv4 addresses - replace last two octets with x.x
    echo "$text" | sed -E 's/\b([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\.([0-9]{1,3})\b/\1.\2.x.x/g'
}

# Add string to memory
add_string_to_memory() {
    local text="$1"
    local sanitized_text="[STRING$STRING_COUNTER]"
    
    # Add to JSON config using jq
    if command -v jq >/dev/null 2>&1; then
        jq --arg key "$text" --arg value "$sanitized_text" \
           '.custom_strings[$key] = $value' "$CONFIG_PATH" > "$CONFIG_PATH.tmp" && \
        mv "$CONFIG_PATH.tmp" "$CONFIG_PATH"
    else
        echo "Warning: jq not found. Cannot save to memory." >&2
    fi
    
    ((STRING_COUNTER++))
    echo "$sanitized_text"
}

# Sanitize text
sanitize_text() {
    local text="$1"
    local result="$text"
    
    # Apply basic translations
    while IFS='|' read -r key value; do
        if [[ -n "$key" && -n "$value" ]]; then
            result="${result//$key/$value}"
        fi
    done < <(load_translations)
    
    # Process line by line for pattern matching
    local processed_lines=()
    while IFS= read -r line; do
        # Match GUIDs (8-4-4-4-12 format)
        if [[ $line =~ ([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12}) ]]; then
            local match="${BASH_REMATCH[1]}"
            local sanitized="...$(get_last_6_chars "$match")"
            line="${line//$match/$sanitized}"
        fi
        
        # Match Base64-like tokens (at least 20 chars)
        if [[ $line =~ ([a-zA-Z0-9+/=_-]{20,}) ]]; then
            local match="${BASH_REMATCH[1]}"
            # Skip if it contains common readable patterns
            if [[ ! $match =~ (Request|interrupted|user|error|warning|info|success|failed|started|stopped|completed|processing) ]]; then
                local sanitized="...$(get_last_6_chars "$match")"
                line="${line//$match/$sanitized}"
            fi
        fi
        
        # Match hex strings (at least 32 chars)
        if [[ $line =~ ([a-fA-F0-9]{32,}) ]]; then
            local match="${BASH_REMATCH[1]}"
            local sanitized="...$(get_last_6_chars "$match")"
            line="${line//$match/$sanitized}"
        fi
        
        # Match long alphanumeric strings (25+ chars)
        if [[ $line =~ ([a-zA-Z0-9_\-\.]{25,}) ]]; then
            local match="${BASH_REMATCH[1]}"
            # Skip if it contains common readable patterns
            if [[ ! $match =~ (Request|interrupted|user|error|warning|info|success|failed|started|stopped|completed|processing) ]]; then
                local sanitized="...$(get_last_6_chars "$match")"
                line="${line//$match/$sanitized}"
            fi
        fi
        
        processed_lines+=("$line")
    done <<< "$result"
    
    result=$(printf '%s\n' "${processed_lines[@]}")
    
    # Apply IP address sanitization
    result=$(sanitize_ip "$result")
    
    echo "$result"
}

# Desanitize text
desanitize_text() {
    local text="$1"
    local result="$text"
    
    # Apply reverse translations
    while IFS='|' read -r key value; do
        if [[ -n "$key" && -n "$value" ]]; then
            result="${result//$value/$key}"
        fi
    done < <(load_translations)
    
    echo "$result"
}

# Copy sanitized
copy_sanitized() {
    # Simulate Ctrl+C
    xdotool key ctrl+c 2>/dev/null || echo "Warning: xdotool not found. Please select text manually."
    sleep 0.1
    
    local clipboard_content
    clipboard_content=$(get_clipboard)
    local sanitized_content
    sanitized_content=$(sanitize_text "$clipboard_content")
    set_clipboard "$sanitized_content"
    echo "Content sanitized and copied to clipboard"
}

# Paste desanitized
paste_desanitized() {
    local clipboard_content
    clipboard_content=$(get_clipboard)
    local desanitized_content
    desanitized_content=$(desanitize_text "$clipboard_content")
    
    set_clipboard "$desanitized_content"
    
    # Simulate Ctrl+V
    xdotool key ctrl+v 2>/dev/null || echo "Warning: xdotool not found. Please paste manually."
    echo "Content desanitized and pasted"
}

# Add selection to memory
add_selection_to_memory() {
    # Simulate Ctrl+C
    xdotool key ctrl+c 2>/dev/null || echo "Warning: xdotool not found. Please select text manually."
    sleep 0.1
    
    local selected_text
    selected_text=$(get_clipboard)
    if [[ -n "${selected_text// }" ]]; then
        local sanitized_text
        sanitized_text=$(add_string_to_memory "$selected_text")
        echo "Added to memory as: $sanitized_text"
    else
        echo "No text selected"
    fi
}

# Main function
main() {
    case "${1:-}" in
        "sanitize")
            copy_sanitized
            ;;
        "desanitize")
            paste_desanitized
            ;;
        "add-memory")
            add_selection_to_memory
            ;;
        "interactive")
            echo "SanitizedCopyPaste Interactive Mode"
            echo "Commands: sanitize, desanitize, add-memory, quit"
            while true; do
                read -p "> " cmd
                case "$cmd" in
                    "sanitize")
                        copy_sanitized
                        ;;
                    "desanitize")
                        paste_desanitized
                        ;;
                    "add-memory")
                        add_selection_to_memory
                        ;;
                    "quit")
                        break
                        ;;
                    *)
                        echo "Unknown command"
                        ;;
                esac
            done
            ;;
        *)
            echo "Usage: $0 {sanitize|desanitize|add-memory|interactive}"
            echo ""
            echo "Commands:"
            echo "  sanitize     - Copy current selection with sanitization"
            echo "  desanitize   - Paste with desanitization"
            echo "  add-memory   - Add current selection to memory"
            echo "  interactive  - Run in interactive mode"
            ;;
    esac
}

# Run main function with all arguments
main "$@"
