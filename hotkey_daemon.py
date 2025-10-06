#!/usr/bin/env python3
"""
SanitizedCopyPaste Hotkey Daemon
Runs in background and listens for hotkeys
"""

import subprocess
import sys
import time
import signal
import os
from pathlib import Path

# Try to import keyboard library
try:
    import keyboard
    KEYBOARD_AVAILABLE = True
except ImportError:
    KEYBOARD_AVAILABLE = False
    print("Warning: 'keyboard' library not found. Install with: pip install keyboard")

class HotkeyDaemon:
    def __init__(self):
        self.script_dir = Path(__file__).parent
        self.python_script = self.script_dir / "sanitized_copy_paste.py"
        self.running = True
        
        # Setup signal handlers
        signal.signal(signal.SIGINT, self.signal_handler)
        signal.signal(signal.SIGTERM, self.signal_handler)
    
    def signal_handler(self, signum, frame):
        print("\nShutting down hotkey daemon...")
        self.running = False
        sys.exit(0)
    
    def run_command(self, command):
        """Run a command and handle errors"""
        try:
            result = subprocess.run([str(self.python_script)] + command, 
                                  capture_output=True, text=True, timeout=5)
            if result.returncode == 0:
                print(f"✅ {result.stdout.strip()}")
            else:
                print(f"❌ Error: {result.stderr.strip()}")
        except subprocess.TimeoutExpired:
            print("❌ Command timed out")
        except Exception as e:
            print(f"❌ Error: {e}")
    
    def setup_hotkeys(self):
        """Setup hotkey bindings"""
        if not KEYBOARD_AVAILABLE:
            print("❌ Cannot setup hotkeys: 'keyboard' library not available")
            print("Install with: pip install keyboard")
            return False
        
        try:
            # Ctrl+Alt+C - Sanitize
            keyboard.add_hotkey('ctrl+alt+c', 
                              lambda: self.run_command(['--sanitize']))
            
            # Ctrl+Alt+V - Desanitize  
            keyboard.add_hotkey('ctrl+alt+v',
                              lambda: self.run_command(['--desanitize']))
            
            # Ctrl+Alt+A - Add to memory
            keyboard.add_hotkey('ctrl+alt+a',
                              lambda: self.run_command(['--add-memory']))
            
            print("✅ Hotkeys registered:")
            print("  Ctrl+Alt+C - Sanitize clipboard")
            print("  Ctrl+Alt+V - Desanitize and paste") 
            print("  Ctrl+Alt+A - Add selection to memory")
            print("  Ctrl+C - Exit daemon")
            
            return True
        except Exception as e:
            print(f"❌ Error setting up hotkeys: {e}")
            return False
    
    def run(self):
        """Main daemon loop"""
        print("🚀 Starting SanitizedCopyPaste Hotkey Daemon...")
        
        if not self.setup_hotkeys():
            return
        
        print("📡 Daemon running. Press Ctrl+C to exit.")
        
        try:
            while self.running:
                time.sleep(0.1)
        except KeyboardInterrupt:
            print("\n👋 Shutting down...")
        finally:
            if KEYBOARD_AVAILABLE:
                keyboard.unhook_all()

def main():
    # Check if running as root (required for global hotkeys)
    if os.geteuid() == 0:
        print("⚠️  Running as root. This may cause issues.")
        print("Consider running without sudo for better security.")
    
    daemon = HotkeyDaemon()
    daemon.run()

if __name__ == "__main__":
    main()
