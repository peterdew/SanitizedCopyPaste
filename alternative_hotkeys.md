# Alternative Hotkey Configurations

## 🎯 **Current Setup (All Ctrl+Alt - Maximum Clarity)**
- **`Ctrl+Alt+C`** → Sanitize clipboard
- **`Ctrl+Alt+V`** → Desanitize and paste  
- **`Ctrl+Alt+A`** → Add selection to memory

## 🔄 **Alternative Options**

### **Option 1: Function Keys**
- **`F9`** → Sanitize clipboard
- **`F10`** → Desanitize and paste
- **`F11`** → Add selection to memory

### **Option 2: Super Key Combinations**
- **`Super+Shift+C`** → Sanitize clipboard
- **`Super+Shift+V`** → Desanitize and paste
- **`Super+Shift+A`** → Add selection to memory

### **Option 3: Alt Key Combinations**
- **`Alt+Shift+C`** → Sanitize clipboard
- **`Alt+Shift+V`** → Desanitize and paste
- **`Alt+Shift+A`** → Add selection to memory

### **Option 4: Custom Prefix**
- **`Ctrl+Shift+S`** → Sanitize clipboard
- **`Ctrl+Shift+D`** → Desanitize and paste
- **`Ctrl+Shift+M`** → Add selection to memory

## 🛠️ **How to Change Hotkeys**

### **Method 1: GNOME Settings**
1. Go to **Settings → Keyboard → Custom Shortcuts**
2. Find "SanitizedCopyPaste" entries
3. Click on the shortcut and press new keys
4. Save changes

### **Method 2: Command Line**
```bash
# Change desanitize to F10
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "F10"

# Change add-memory to F11  
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding "F11"
```

### **Method 3: Edit Script**
Modify the binding values in `setup_gnome_hotkeys.sh`:
```bash
# Change from <Ctrl><Alt>v to F10
binding "F10"
```

## 🎮 **Gaming/Development Friendly Options**

### **For Developers:**
- **`Ctrl+Shift+S`** → Sanitize (S for Sanitize)
- **`Ctrl+Shift+R`** → Restore (R for Restore)  
- **`Ctrl+Shift+M`** → Memory (M for Memory)

### **For Gamers:**
- **`F9`** → Sanitize
- **`F10`** → Desanitize
- **`F11`** → Add to memory

### **For Terminal Heavy Users:**
- **`Ctrl+Alt+C`** → Sanitize
- **`Ctrl+Alt+V`** → Desanitize (current)
- **`Ctrl+Alt+A`** → Add to memory

## 🔧 **Quick Setup Commands**

```bash
# Set to Function keys
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "F9"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "F10"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding "F11"

# Set to Super key combinations
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/ binding "<Super><Shift>c"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/ binding "<Super><Shift>v"
gsettings set org.gnome.settings-daemon.plugins.media-keys.custom-keybinding:/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/ binding "<Super><Shift>a"
```

## 🎯 **Recommendation**

The current setup (`Ctrl+Alt+V` for desanitize) should work well because:
- ✅ No conflict with terminal paste (`Ctrl+Shift+V`)
- ✅ Easy to remember (Alt instead of Shift)
- ✅ Similar to original AutoHotkey pattern
- ✅ Works across all applications
