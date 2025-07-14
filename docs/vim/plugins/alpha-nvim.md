# Alpha Dashboard

> Source: [goolord/alpha-nvim](https://github.com/goolord/alpha-nvim)

A fast and fully programmable greeter for Neovim.

## Features

- Custom startup screen for Neovim
- Configurable header with ASCII art
- Quick action buttons
- Session management integration
- Fast and lightweight
- Fully customizable layout

## Configuration

The dashboard is configured with the following sections:

### Header
```
  ███╗   ██╗███████╗ ██████╗ ██╗   ██╗██╗███╗   ███╗
  ████╗  ██║██╔════╝██╔═══██╗██║   ██║██║████╗ ████║
  ██╔██╗ ██║█████╗  ██║   ██║██║   ██║██║██╔████╔██║
  ██║╚██╗██║██╔══╝  ██║   ██║╚██╗ ██╔╝██║██║╚██╔╝██║
  ██║ ╚████║███████╗╚██████╔╝ ╚████╔╝ ██║██║ ╚═╝ ██║
  ╚═╝  ╚═══╝╚══════╝ ╚═════╝   ╚═══╝  ╚═╝╚═╝     ╚═╝
```

### Quick Actions
- `e` - New File
- `SPC ee` - Toggle file explorer
- `SPC ff` - Find File
- `SPC fs` - Find Word
- `SPC wr` - Restore Session
- `q` - Quit NVIM

## Tips

1. The dashboard appears automatically when you start Neovim with no arguments
2. Use the quick actions for common operations
3. The session restore option helps you continue where you left off
4. All buttons show the actual keybindings they represent
5. The dashboard is optimized for fast startup time 