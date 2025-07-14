# Simple Hotkey Daemon (skhd)

> Source: `.config/skhd/skhdrc`

A powerful hotkey daemon for macOS that enables complex keyboard shortcuts and system automation.

## Installation

1. Using Homebrew:
   ```bash
   brew install koekeishiya/formulae/skhd
   ```

2. Service Management:
   ```bash
   # Start skhd
   brew services start skhd
   
   # Stop skhd
   brew services stop skhd
   
   # Restart skhd
   brew services restart skhd
   ```

3. Configuration Location:
   ```bash
   ~/.config/skhd/skhdrc
   ```

## Overview

skhd is configured to provide a comprehensive set of keyboard shortcuts for:
- Application launching and management
- System controls
- Window management
- Custom modes and sequences
- System maintenance
- Quick actions

## Syntax Guide

1. Basic Format:
   ```skhd
   # Simple hotkey
   alt - h : command
   
   # Complex hotkey with multiple modifiers
   cmd + alt + ctrl - h : command
   
   # Mode-based hotkey
   mode < key > : command
   
   # Key sequence
   a -> b : command
   ```

2. Modifier Keys:
   - `cmd` - Command key (⌘)
   - `alt` - Option key (⌥)
   - `ctrl` - Control key (⌃)
   - `shift` - Shift key (⇧)
   - `fn` - Function key

3. Special Syntax:
   ```skhd
   # Mode definition
   :: mode_name @ : notification_command
   
   # Mode entry
   key ; mode_name
   
   # Mode exit
   mode_name < escape > ; default
   ```

## Key Binding Categories

### Application Shortcuts

1. Terminal:
   ```skhd
   cmd - return : kitty --single-instance    # Open terminal
   ```

2. Common Applications:
   ```skhd
   cmd + shift - b : Arc                     # Browser
   cmd + shift - s : Slack                   # Communication
   cmd + shift - n : Notion                  # Notes
   cmd + shift - v : VS Code                 # Code Editor
   cmd + shift - f : Finder                  # File Manager
   cmd + shift - m : Messages                # Messages
   cmd + shift - c : Calendar                # Calendar
   ```

### System Controls

1. Display and Power:
   ```skhd
   cmd + shift - q : pmset displaysleepnow   # Sleep display
   cmd + alt - b : Brightness up
   cmd + alt + shift - b : Brightness down
   cmd + alt - n : Toggle Night Shift
   ```

2. Audio Controls:
   ```skhd
   fn + shift - f10 : Toggle mute
   fn + shift - f11 : Volume down
   fn + shift - f12 : Volume up
   ```

3. Media Controls:
   ```skhd
   fn - f7 : Play/Pause
   fn - f8 : Previous track
   fn - f9 : Next track
   ```

### Window Management

1. Basic Positioning:
   ```skhd
   cmd + alt - c : Center window
   cmd + alt - left : Left half
   cmd + alt - right : Right half
   ```

2. Resize Mode:
   ```skhd
   cmd - r ; resize                          # Enter resize mode
   resize < h > : 800x600
   resize < j > : 1024x768
   resize < k > : 1280x800
   resize < l > : 1440x900
   ```

### Quick Access

1. Folders:
   ```skhd
   cmd + shift - d : Desktop
   cmd + shift - h : Home
   cmd + shift - p : Projects
   cmd + shift - w : Downloads
   ```

2. Screenshots:
   ```skhd
   cmd + shift - 4 : Interactive screenshot to Desktop
   ```

### Mode-based Operations

1. Timer Mode:
   ```skhd
   timer < / > : 5 minute timer
   timer < + > : 10 minute timer
   ```

2. Launch Mode:
   ```skhd
   cmd - a ; launch                          # Enter launch mode
   launch < b > : Arc
   launch < s > : Slack
   launch < v > : VS Code
   launch < f > : Finder
   ```

### System Maintenance

1. System Tasks:
   ```skhd
   shift + cmd - backspace : Empty trash
   cmd + shift + alt - i : Rebuild Spotlight
   cmd + shift + alt - d : Flush DNS cache
   ```

2. Configuration:
   ```skhd
   ctrl + alt - r : Reload skhd config
   ```

## Advanced Features

### Key Sequences
```skhd
a -> b : Notification
x -> y -> z : XYZ sequence
```

### Window Layouts
```skhd
cmd + alt - 1 : coding layout
cmd + alt - 2 : writing layout
cmd + alt - 3 : communication layout
```

### Custom Scripts
```skhd
cmd + shift - w : weather notification
cmd + shift - v : toggle VPN
```

## Tips

1. Mode Usage:
   - Use modes for context-specific shortcuts
   - Escape key exits any mode
   - Modes shown in notification center

2. Window Management:
   - Center windows for focus
   - Use layouts for specific tasks
   - Quick half-screen positioning

3. Maintenance:
   - Reload config after changes
   - Check syntax with `skhd -c`
   - Use comments for organization

4. Performance:
   - Keep commands lightweight
   - Use native macOS commands
   - Avoid complex scripts

## Customization

1. Adding New Shortcuts:
   ```skhd
   mode < key > : command                    # Basic format
   mod + key : command                       # Direct shortcut
   key -> key : command                      # Sequence
   ```

2. Creating Modes:
   ```skhd
   :: modename @ : echo "Mode activated"     # Define mode
   key ; modename                           # Enter mode
   modename < escape > ; default            # Exit to default
   ```

3. Script Integration:
   ```skhd
   key : ~/.local/bin/script                # Run script
   key : osascript -e 'command'             # AppleScript
   ```

## Debugging

1. Check Configuration:
   ```bash
   skhd -c ~/.config/skhd/skhdrc
   ```

2. View Logs:
   ```bash
   # View service logs
   brew services info skhd
   
   # Tail logs
   tail -f /usr/local/var/log/skhd.log
   ```

3. Common Issues:
   - Permission problems with scripts
   - Conflicting system shortcuts
   - Invalid syntax in configuration
   - Application permissions

## Integration

1. With Yabai:
   ```skhd
   # Window focus
   alt - h : yabai -m window --focus west
   
   # Space management
   shift + alt - n : yabai -m space --create
   ```

2. With AppleScript:
   ```skhd
   # Complex window management
   cmd + alt - c : osascript ~/.config/skhd/scripts/center-window.scpt
   
   # System interactions
   cmd + shift - v : osascript -e 'tell application "System Events" to key code 9 using command down'
   ```

3. With Shell Scripts:
   ```skhd
   # Custom utilities
   cmd + shift - w : ~/.config/skhd/scripts/weather.sh
   
   # System management
   cmd + shift - p : ~/.config/skhd/scripts/toggle-vpn.sh
   ```

## Best Practices

1. Configuration Organization:
   - Group related shortcuts
   - Use consistent naming
   - Comment all shortcuts
   - Separate complex scripts

2. Performance Optimization:
   - Use direct commands when possible
   - Minimize script dependencies
   - Cache frequent operations
   - Profile heavy operations

3. Maintenance:
   - Regular config review
   - Remove unused shortcuts
   - Update documentation
   - Test all modes

4. Security:
   - Secure script permissions
   - Validate external commands
   - Check script sources
   - Monitor system access

## Troubleshooting

1. Shortcut Not Working:
   - Check syntax with `skhd -c`
   - Verify no system conflicts
   - Check application permissions
   - Review log files

2. Performance Issues:
   - Monitor script execution time
   - Check for blocking operations
   - Verify resource usage
   - Optimize complex commands

3. Mode Problems:
   - Verify mode definitions
   - Check exit conditions
   - Test mode transitions
   - Review mode feedback

## Resources

1. Official Documentation:
   - [skhd GitHub](https://github.com/koekeishiya/skhd)
   - [Wiki](https://github.com/koekeishiya/skhd/wiki)

2. Community:
   - [GitHub Issues](https://github.com/koekeishiya/skhd/issues)
   - [Reddit r/MacOS](https://reddit.com/r/MacOS)

3. Related Tools:
   - [Yabai](https://github.com/koekeishiya/yabai)
   - [Karabiner-Elements](https://karabiner-elements.pqrs.org/)
   - [BetterTouchTool](https://folivora.ai/) 