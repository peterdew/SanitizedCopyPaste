#!/bin/bash
# Setup GNOME Custom Shortcuts for SanitizedCopyPaste

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PYTHON_SCRIPT="$SCRIPT_DIR/sanitized_copy_paste.py"
SHELL_SCRIPT="$SCRIPT_DIR/sanitized_copy_paste.sh"

echo "Setting up GNOME Custom Shortcuts for SanitizedCopyPaste..."

# Check if gsettings is available
if ! command -v gsettings >/dev/null 2>&1; then
    echo "Error: gsettings not found. This script requires GNOME."
    exit 1
fi

# Create custom shortcuts
echo "Creating custom shortcuts..."

# Sanitize shortcut (Ctrl+Alt+C)
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ name "Sanitize Clipboard"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ command "$PYTHON_SCRIPT --sanitize"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Ctrl><Alt>c"

# Desanitize shortcut (Ctrl+Alt+V)
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/']"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ name "Desanitize Clipboard"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ command "$PYTHON_SCRIPT --desanitize"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Ctrl><Alt>v"

# Add to memory shortcut (Ctrl+Alt+A)
gsettings set org.gnome.settings-daemon.plugins.media-keys custom-keybindings "['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/', '/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/']"

gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ name "Add to Memory"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ command "$PYTHON_SCRIPT --add-memory"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding "<Ctrl><Alt>a"

echo "✅ GNOME Custom Shortcuts created successfully!"
echo ""
echo "Hotkeys:"
echo "  Ctrl+Alt+C - Sanitize clipboard"
echo "  Ctrl+Alt+V - Desanitize and paste"
echo "  Ctrl+Alt+A - Add selection to memory"
echo ""
echo "You can also set these manually in:"
echo "  Settings → Keyboard → Custom Shortcuts"
