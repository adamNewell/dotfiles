# Substitute

> Source: [gbprod/substitute.nvim](https://github.com/gbprod/substitute.nvim)

A plugin for quick text substitution with motions and visual selections.

## Features

- Quick substitution with motions
- Visual mode substitution
- Line substitution
- End of line substitution
- Preserves registers
- Works with all text objects

## Key Bindings

- `s{motion}` - Substitute with motion (e.g., `sw` for word)
- `ss` - Substitute entire line
- `S` - Substitute to end of line
- `s` - Substitute selection (in visual mode)

## Usage Examples

1. Motion-based substitution:
   - `sw` - Substitute word
   - `s2w` - Substitute two words
   - `sip` - Substitute inner paragraph

2. Line operations:
   - `ss` - Substitute entire current line
   - `S` - Substitute from cursor to end of line

3. Visual mode:
   - Select text in visual mode
   - Press `s` to substitute selection

## Tips

1. The substituted text is stored in the default register
2. Can be combined with any text object or motion
3. Use with count for multiple substitutions
4. Works seamlessly with dot-repeat
5. Preserves your unnamed register for other operations
