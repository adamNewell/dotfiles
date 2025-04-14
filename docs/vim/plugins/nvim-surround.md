# Nvim Surround

> Source: [kylechui/nvim-surround](https://github.com/kylechui/nvim-surround)

A plugin for adding, changing, and removing surroundings (parentheses, brackets, quotes, XML tags, etc.).

## Features

- Add surroundings around text objects
- Change existing surroundings
- Delete surroundings
- Works in normal and visual modes
- Supports custom surroundings
- Works with tags, quotes, and brackets

## Key Bindings

### Normal Mode
- `ys{motion}{char}` - Add surround around motion
- `ds{char}` - Delete surround
- `cs{target}{replacement}` - Change surround
- `yss{char}` - Add surround around entire line

### Visual Mode
- `S{char}` - Add surround around selection

## Examples

1. Add surroundings:
   - `ysiw)` - Surround word with parentheses
   - `ysiw]` - Surround word with brackets
   - `ysiw}` - Surround word with braces
   - `ysiw"` - Surround word with quotes

2. Change surroundings:
   - `cs'"` - Change single quotes to double quotes
   - `cs)]` - Change parentheses to brackets
   - `cst<div>` - Change tag to div

3. Delete surroundings:
   - `ds"` - Delete surrounding quotes
   - `ds)` - Delete surrounding parentheses
   - `dst` - Delete surrounding tags

## Tips

1. Use `yss` to surround entire lines
2. Works with any motion (e.g., `ys2w` for two words)
3. Visual mode surround is great for precise selections
4. Can be used with dot-repeat for multiple changes
5. Supports HTML/XML tags with `t` as the surround character 