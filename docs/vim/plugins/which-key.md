# Which Key

> Source: [folke/which-key.nvim](https://github.com/folke/which-key.nvim)

A plugin that displays a popup with possible key bindings of the command you started typing.

## Features

- Shows available keybindings in a popup window
- Groups related commands together
- Helps learn and remember key mappings
- Reduces the need to memorize all keybindings
- Timeout configuration for popup display

## Configuration

The plugin is configured with the following settings:

```lua
{
  timeoutlen = 500, -- Time in milliseconds to wait for a mapped sequence to complete
}
```

## Usage

1. Start typing a command (e.g., press the leader key `<Space>`)
2. Wait for the popup to appear (500ms by default)
3. See all available key bindings that start with your input
4. Continue typing to narrow down options or select a command

## Tips

1. Use the leader key (`<Space>`) to see all available leader commands
2. The popup will show descriptions for commands where available
3. Commands are grouped by category for easier navigation
4. You can press `?` in the popup for more help
5. The popup will automatically hide when you complete a command
