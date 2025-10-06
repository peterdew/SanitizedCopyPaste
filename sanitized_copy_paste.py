#!/usr/bin/env python3
"""
SanitizedCopyPaste - Linux version
Privacy-focused tool for automatically anonymizing clipboard content
"""

import re
import json
import os
import sys
import subprocess
import time
from pathlib import Path
from typing import Dict, List, Tuple, Optional
import argparse

class SanitizedCopyPaste:
    def __init__(self, config_file: str = "translations.json"):
        self.config_file = Path(config_file)
        self.translations = []
        self.ip_counter = 1
        self.string_counter = 1
        self.load_translations()
        
    def load_translations(self):
        """Load translations from JSON config file"""
        if not self.config_file.exists():
            # Create default config
            default_config = {
                "companies": {},
                "names": {},
                "custom_strings": {}
            }
            with open(self.config_file, 'w') as f:
                json.dump(default_config, f, indent=2)
            self.translations = []
            return
            
        with open(self.config_file, 'r') as f:
            config = json.load(f)
            
        # Convert to list format for compatibility
        self.translations = []
        for key, value in config.get("companies", {}).items():
            self.translations.append([key, value])
        for key, value in config.get("names", {}).items():
            self.translations.append([key, value])
        for key, value in config.get("custom_strings", {}).items():
            self.translations.append([key, value])
            
        # Update string counter
        max_string = 0
        for _, value in config.get("custom_strings", {}).items():
            if value.startswith("[STRING") and value.endswith("]"):
                try:
                    num = int(value[7:-1])
                    max_string = max(max_string, num)
                except ValueError:
                    pass
        self.string_counter = max_string + 1

    def save_translations(self):
        """Save translations to JSON config file"""
        config = {
            "companies": {},
            "names": {},
            "custom_strings": {}
        }
        
        for key, value in self.translations:
            if value.startswith("[BEDR_"):
                config["companies"][key] = value
            elif value.startswith("[NAME_"):
                config["names"][key] = value
            elif value.startswith("[STRING"):
                config["custom_strings"][key] = value
                
        with open(self.config_file, 'w') as f:
            json.dump(config, f, indent=2)

    def get_clipboard(self) -> str:
        """Get clipboard content using xclip or xsel"""
        try:
            # Try xclip first (more common)
            result = subprocess.run(['xclip', '-selection', 'clipboard', '-o'], 
                                  capture_output=True, text=True, check=True)
            return result.stdout
        except (subprocess.CalledProcessError, FileNotFoundError):
            try:
                # Fallback to xsel
                result = subprocess.run(['xsel', '--clipboard', '--output'], 
                                      capture_output=True, text=True, check=True)
                return result.stdout
            except (subprocess.CalledProcessError, FileNotFoundError):
                print("Error: Neither xclip nor xsel found. Please install one of them.")
                sys.exit(1)

    def set_clipboard(self, text: str):
        """Set clipboard content using xclip or xsel"""
        try:
            # Try xclip first
            subprocess.run(['xclip', '-selection', 'clipboard'], 
                          input=text, text=True, check=True)
        except (subprocess.CalledProcessError, FileNotFoundError):
            try:
                # Fallback to xsel
                subprocess.run(['xsel', '--clipboard', '--input'], 
                              input=text, text=True, check=True)
            except (subprocess.CalledProcessError, FileNotFoundError):
                print("Error: Neither xclip nor xsel found. Please install one of them.")
                sys.exit(1)

    def get_last_6_chars(self, text: str) -> str:
        """Get last 6 characters of a string"""
        return text[-6:] if len(text) >= 6 else text

    def sanitize_ip(self, text: str) -> str:
        """Sanitize IP addresses while preserving structure"""
        result = text
        
        # IPv4 addresses
        ipv4_pattern = r'\b(\d{1,3})\.(\d{1,3})\.(\d{1,3})\.(\d{1,3})\b'
        result = re.sub(ipv4_pattern, r'\1.\2.x.x', result)
        
        # IPv6 addresses (simplified)
        ipv6_pattern = r'([0-9a-fA-F]{1,4}:){7}[0-9a-fA-F]{1,4}'
        result = re.sub(ipv6_pattern, 'xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx:xxxx', result)
        
        return result

    def add_string_to_memory(self, text: str) -> str:
        """Add a new string to translations"""
        sanitized_text = f"[STRING{self.string_counter}]"
        
        # Add to translations list
        self.translations.append([text, sanitized_text])
        
        # Save to config file
        self.save_translations()
        
        self.string_counter += 1
        return sanitized_text

    def sanitize_text(self, text: str) -> str:
        """Sanitize text by replacing sensitive information"""
        result = text
        
        # Apply basic translations first
        for original, replacement in self.translations:
            result = result.replace(original, replacement)
        
        # Process line by line for pattern matching
        lines = result.split('\n')
        processed_lines = []
        
        for line in lines:
            # Match GUIDs (8-4-4-4-12 format)
            guid_pattern = r'([a-fA-F0-9]{8}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{4}-[a-fA-F0-9]{12})'
            for match in re.finditer(guid_pattern, line):
                sanitized = "..." + self.get_last_6_chars(match.group(1))
                line = line.replace(match.group(1), sanitized)
            
            # Match Base64-like tokens (at least 20 chars)
            base64_pattern = r'([a-zA-Z0-9+/=_-]{20,})'
            for match in re.finditer(base64_pattern, line):
                sanitized = "..." + self.get_last_6_chars(match.group(1))
                line = line.replace(match.group(1), sanitized)
            
            # Match hex strings (at least 32 chars)
            hex_pattern = r'([a-fA-F0-9]{32,})'
            for match in re.finditer(hex_pattern, line):
                sanitized = "..." + self.get_last_6_chars(match.group(1))
                line = line.replace(match.group(1), sanitized)
            
            # Match long alphanumeric strings (25+ chars)
            alphanum_pattern = r'([a-zA-Z0-9_\-\.]{25,})'
            for match in re.finditer(alphanum_pattern, line):
                # Skip if it contains common readable patterns
                if not re.search(r'(?i)(Request|interrupted|user|error|warning|info|success|failed|started|stopped|completed|processing)', match.group(1)):
                    sanitized = "..." + self.get_last_6_chars(match.group(1))
                    line = line.replace(match.group(1), sanitized)
            
            processed_lines.append(line)
        
        result = '\n'.join(processed_lines)
        
        # Apply IP address sanitization
        result = self.sanitize_ip(result)
        
        return result

    def desanitize_text(self, text: str) -> str:
        """Desanitize text by replacing labels back to original text"""
        result = text
        for original, replacement in self.translations:
            result = result.replace(replacement, original)
        return result

    def copy_sanitized(self):
        """Copy current selection with sanitization"""
        # Simulate Ctrl+C
        subprocess.run(['xdotool', 'key', 'ctrl+c'])
        time.sleep(0.1)  # Wait for clipboard to update
        
        clipboard_content = self.get_clipboard()
        sanitized_content = self.sanitize_text(clipboard_content)
        self.set_clipboard(sanitized_content)
        print("Content sanitized and copied to clipboard")

    def paste_desanitized(self):
        """Paste with desanitization"""
        # Get current clipboard content
        clipboard_content = self.get_clipboard()
        desanitized_content = self.desanitize_text(clipboard_content)
        
        # Set desanitized content to clipboard
        self.set_clipboard(desanitized_content)
        
        # Simulate Ctrl+V
        subprocess.run(['xdotool', 'key', 'ctrl+v'])
        print("Content desanitized and pasted")

    def add_selection_to_memory(self):
        """Add current selection to memory"""
        # Simulate Ctrl+C
        subprocess.run(['xdotool', 'key', 'ctrl+c'])
        time.sleep(0.1)  # Wait for clipboard to update
        
        selected_text = self.get_clipboard()
        if selected_text.strip():
            sanitized_text = self.add_string_to_memory(selected_text.strip())
            print(f"Added to memory as: {sanitized_text}")
        else:
            print("No text selected")

def main():
    parser = argparse.ArgumentParser(description='SanitizedCopyPaste - Privacy-focused clipboard anonymizer')
    parser.add_argument('--config', default='translations.json', help='Config file path')
    parser.add_argument('--sanitize', action='store_true', help='Sanitize clipboard content')
    parser.add_argument('--desanitize', action='store_true', help='Desanitize clipboard content')
    parser.add_argument('--add-memory', action='store_true', help='Add selection to memory')
    parser.add_argument('--interactive', action='store_true', help='Run in interactive mode')
    
    args = parser.parse_args()
    
    scp = SanitizedCopyPaste(args.config)
    
    if args.sanitize:
        scp.copy_sanitized()
    elif args.desanitize:
        scp.paste_desanitized()
    elif args.add_memory:
        scp.add_selection_to_memory()
    elif args.interactive:
        print("SanitizedCopyPaste Interactive Mode")
        print("Commands: sanitize, desanitize, add-memory, quit")
        while True:
            try:
                cmd = input("> ").strip().lower()
                if cmd == 'sanitize':
                    scp.copy_sanitized()
                elif cmd == 'desanitize':
                    scp.paste_desanitized()
                elif cmd == 'add-memory':
                    scp.add_selection_to_memory()
                elif cmd == 'quit':
                    break
                else:
                    print("Unknown command")
            except KeyboardInterrupt:
                break
    else:
        parser.print_help()

if __name__ == "__main__":
    main()
